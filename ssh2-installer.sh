#! /bin/bash
# Debian 8 SSH2 Installer
# Aws Server Installation Only
# Tutored: xam
# Script by: Juan

 # Now check if our machine is in root user, if not, this script exits
 # If you're on sudo user, run `sudo su -` first before running this script
 if [[ $EUID -ne 0 ]];then
 ScriptMessage
 echo -e "[\e[1;31mError\e[0m] This script must be run as root, exiting..."
 exit 1
fi

# Reset
Color_Off='\033[0m'       # Text Reset

# Regular Colors

Red='\033[0;31m'          # Red
Green='\033[0;32m'        # Green
Yellow='\033[0;33m'       # Yellow
Purple='\033[0;35m'       # Purple
Cyan='\033[0;36m'         # Cyan

function ip_address(){
  local IP="$( ip addr | egrep -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | egrep -v "^192\.168|^172\.1[6-9]\.|^172\.2[0-9]\.|^172\.3[0-2]\.|^10\.|^127\.|^255\.|^0\." | head -n 1 )"
  [ -z "${IP}" ] && IP="$( wget -qO- -t1 -T2 ipv4.icanhazip.com )"
  [ -z "${IP}" ] && IP="$( wget -qO- -t1 -T2 ipinfo.io/ip )"
  [ ! -z "${IP}" ] && echo "${IP}" || echo
} 
IPADDR="$(ip_address)"

# remove the existng sources.list file
 rm -rf /etc/apt/sources.list

# create new sources.list
 cat <<'sources_list' > /etc/apt/sources.list
deb http://cdn-fastly.deb.debian.org/debian/ jessie main
deb-src http://cdn-fastly.deb.debian.org/debian/ jessie main

deb http://security.debian.org/ jessie/updates main
deb-src http://security.debian.org/ jessie/updates main

deb http://archive.debian.org/debian jessie-backports main
deb-src http://archive.debian.org/debian jessie-backports main

sources_list

cat <<'aptconf' > /etc/apt/apt.conf
 Acquire::Check-Valid-Until "false";
 
aptconf


apt-get update
apt-get upgrade -y

# install dbus for timedatecl
apt-get install dbus -yy

# install fail2ban
apt install fail2ban -y

apt-get install apache2 -y
apt-get install cron curl unzip
apt-get install php5 libapache2-mod-php5 php5-mcrypt -y 
service apache2 restart
php -m
apt-get install mysql-server -y
mysql_install_db
mysql_secure_installation
apt-get install phpmyadmin -y
php5enmod mcrypt
service apache2 restart
ln -s /usr/share/phpmyadmin /var/www/html/phpmyadmin
apt-get install libssh2-1 libssh2-php
php -m |grep ssh2
apt-get install php5-curl

# setting default time zone Asia/Manila
 timedatectl set-timezone Asia/Manila
systemctl enable ntp
# set the system clock sync with RTC
hwclock --systohc --localtime
 
# removing existing apache2.conf
rm /etc/apache2/apache2.conf
# downloading new apache2.conf
wget -q 'https://github.com/yakult13/deb8-apache2/raw/main/apache2.conf'
chmod -R 777 apache2.conf
mv apache2.conf /etc/apache2/apache2.conf

# restart apache after modidying
service apache2 restart

# download models
wget -q https://github.com/yakult13/parte/raw/main/models.zip
chmod -R 777 models.zip
mv models.zip /var/www/html
unzip models.zip

clear

echo -e ""
echo -e "\033[0;31m Panel Success Installation \033[0m"
echo -e "\033[0;31m Script by: \033[0m  \033[0;36m Juan \033[0m"
echo -e ""
echo -e "\033[0;32m Panel Link \033[0m"
echo -e "\033[0;35m http://$IPADDR \033[0m"
echo -e ""
echo -e "\033[0;36m Database Link\033[0m"
echo -e "\033[0;36m http://$IPADDR/phpmyadmin \033[0m"
echo -e ""

 # Clearing all logs from installation
rm -rf /root/.bash_history && history -c && echo '' > /var/log/syslog

rm -f ssh2-installer*
exit 1
