From: Andrew Morton <akpm@osdl.org>
Subject: Fw: Log full of "ing_filter:  fixed  ippp2 out ippp2"
Date: Thu, 10 Mar 2005 17:49:15 -0800
Message-ID: <20050310174915.3148c9a8.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Kimmo Sundqvist <kimmo.sundqvist@mbnet.fi>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Can you check to see if 2.6.11 is still doing this?


Begin forwarded message:

Date: Wed, 9 Mar 2005 22:07:41 +0200
From: Kimmo Sundqvist <kimmo.sundqvist@mbnet.fi>
To: linux-kernel@vger.kernel.org
Subject: Log full of "ing_filter:  fixed  ippp2 out ippp2"


Hello

Please cc all replies to me.

After upgrading my little NATting firewall/router from 2.6.7-ck4 to 
2.6.10-gentoo-r6 my /var/log/messages is 15MB in size and most of it looks 
like the text below.  All traffic to the Internet seems to cause this.  

"cat /var/log/messages | uniq | uniqmessages" results in a 3MB file.  I use 
syslog-ng.

Iptables setup script further down.

Mar  9 21:58:15 shadowgate ing_filter:  fixed  ippp2 out ippp2
Mar  9 21:58:15 shadowgate ing_filter:  fixed  ippp2 out ippp2
Mar  9 21:58:15 shadowgate ing_filter:  fixed  ippp2 out ippp2
Mar  9 21:58:15 shadowgate ing_filter:  fixed  ippp2 out ippp2
Mar  9 21:58:15 shadowgate ing_filter:  fixed  ippp2 out ippp2
Mar  9 21:58:16 shadowgate ing_filter:  fixed  ippp2 out ippp2
Mar  9 21:58:16 shadowgate ing_filter:  fixed  ippp2 out ippp2
Mar  9 21:58:16 shadowgate ing_filter:  fixed  ippp2 out ippp2
Mar  9 21:58:16 shadowgate ing_filter:  fixed  ippp2 out ippp2
Mar  9 21:58:16 shadowgate ing_filter:  fixed  ippp2 out ippp2
Mar  9 21:58:16 shadowgate ing_filter:  fixed  ippp2 out ippp2
Mar  9 21:58:16 shadowgate ing_filter:  fixed  ippp2 out ippp2
Mar  9 21:58:17 shadowgate ing_filter:  fixed  ippp2 out ippp2
Mar  9 21:58:17 shadowgate ing_filter:  fixed  ippp2 out ippp2
Mar  9 21:58:17 shadowgate ing_filter:  fixed  ippp2 out ippp2
Mar  9 21:58:17 shadowgate ing_filter:  fixed  ippp2 out ippp2
Mar  9 21:58:17 shadowgate ing_filter:  fixed  ippp2 out ippp2
Mar  9 21:58:17 shadowgate ing_filter:  fixed  ippp2 out ippp2
Mar  9 21:58:17 shadowgate ing_filter:  fixed  ippp2 out ippp2
Mar  9 21:58:17 shadowgate ing_filter:  fixed  ippp2 out ippp2
Mar  9 21:58:17 shadowgate ing_filter:  fixed  ippp2 out ippp2
Mar  9 21:58:17 shadowgate ing_filter:  fixed  ippp2 out ippp2
Mar  9 21:58:17 shadowgate ing_filter:  fixed  ippp2 out ippp2
Mar  9 21:58:17 shadowgate ing_filter:  fixed  ippp2 out ippp2
Mar  9 21:58:17 shadowgate ing_filter:  fixed  ippp2 out ippp2
Mar  9 21:58:17 shadowgate ing_filter:  fixed  ippp2 out ippp2

My firewall setup looks like:

IPTABLES=/sbin/iptables
MODPROBE=/sbin/modprobe
DEPMOD=/sbin/depmod

EXTIF="ippp2"
INTIF="eth0"
KAKKOSIF="eth1"

$DEPMOD -a

$MODPROBE ip_tables

#$MODPROBE ip_conntrack
#In the kernel

$MODPROBE ip_conntrack_ftp
$MODPROBE iptable_nat
$MODPROBE ip_nat_ftp

echo "1" > /proc/sys/net/ipv4/ip_forward
echo "1" > /proc/sys/net/ipv4/ip_dynaddr
#echo "1" > /proc/sys/net/ipv4/conf/all/proxy_arp

$IPTABLES -P INPUT ACCEPT
$IPTABLES -F INPUT
$IPTABLES -P OUTPUT ACCEPT
$IPTABLES -F OUTPUT
$IPTABLES -P FORWARD DROP
$IPTABLES -F FORWARD

$IPTABLES -t nat -F

/sbin/iptables -A FORWARD -i eth1 -o eth0 -j ACCEPT
/sbin/iptables -A FORWARD -i eth0 -o eth1 -j ACCEPT

$IPTABLES -A FORWARD -i $EXTIF -o $KAKKOSIF -m state --state \
ESTABLISHED,RELATED -j ACCEPT   # RJ-45

$IPTABLES -A FORWARD -i $EXTIF -o $INTIF -m state --state \
ESTABLISHED,RELATED  -j ACCEPT # BNC segment

$IPTABLES -A FORWARD -i $KAKKOSIF -o $EXTIF -j ACCEPT   # RJ-45
$IPTABLES -A FORWARD -i $INTIF -o $EXTIF -j ACCEPT        # BNC segment
$IPTABLES -t nat -A POSTROUTING -o $EXTIF -j MASQUERADE
$IPTABLES -A FORWARD -j LOG
exit 0

-Kimmo S.
