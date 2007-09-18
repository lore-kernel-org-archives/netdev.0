From: "Marco Berizzi" <pupilla@hotmail.com>
Subject: wrong arp query with policy routing
Date: Tue, 18 Sep 2007 16:04:31 +0200
Message-ID: <BAY103-DAV2BC129A14C4A29986CC0CB2B80@phx.gbl>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bay0-omc3-s15.bay0.hotmail.com ([65.54.246.215]:52073 "EHLO
	bay0-omc3-s15.bay0.hotmail.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754316AbXIROEl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Sep 2007 10:04:41 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

1234567890123456789012345678901234567890123456789012345678901234567890
         1         2         3         4         5         6         7

Hello everybody.
I have a pretty strange problem with linux 2.6.22.6
This is my 'ip ru sh', 'ip a s', 'ip r s' and
'iptables -t mangle -nvxL' output:

0: from all lookup local
32766: from all lookup main
32767: from all lookup default

1: lo: <LOOPBACK,UP,LOWER_UP> mtu 16436 qdisc noqueue
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast
qlen 1000
    link/ether 00:30:05:cb:27:c1 brd ff:ff:ff:ff:ff:ff
    inet HDSL.254/27 brd HDSL.255 scope global eth0
3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast
qlen 1000
    link/ether 00:30:05:c2:56:0e brd ff:ff:ff:ff:ff:ff
    inet HDSL.254/27 brd HDSL.255 scope global eth1
    inet ADSL.134/29 brd ADSL.135 scope global eth1
4: eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast
qlen 100
    link/ether 00:04:23:d0:0f:02 brd ff:ff:ff:ff:ff:ff
    inet 172.16.1.1/23 brd 172.16.1.255 scope global eth2

HDSL.225 dev eth0  scope link
ADSL.129 dev eth0  scope link  src ADSL.134
ADSL.128/29 dev eth1  proto kernel  scope link  src ADSL.134
HDSL.224/27 dev eth1  proto kernel  scope link  src HDSL.254
172.16.0.0/23 dev eth2  proto kernel  scope link  src 172.16.1.1
127.0.0.0/8 dev lo  scope link
default via HDSL.225 dev eth0  metric 1

Chain OUTPUT (policy ACCEPT 2476380 packets, 1183993024 bytes)
    pkts      bytes target     prot opt in     out     source
destination
     312    20583 ACCEPT     all  --  *      *       0.0.0.0/0
HDSL.224/27
   61064  8582064 MARK       tcp  --  *      *       0.0.0.0/0
!172.16.0.0/12       multiport dports
20,21,80,123,443,2080,8080,8201,10000,8102,1443,81 MARK set 0x1
       0        0 MARK       udp  --  *      *       0.0.0.0/0
!172.16.0.0/12       multiport dports 123 MARK set 0x1
     105     5544 MARK       all  --  *      *       0.0.0.0/0
!172.16.0.0/12       helper match "ftp" MARK set 0x1

When I try to ping ADSL.129 I get this arp request
reply:

13:00:45.156697 00:30:05:cb:27:c1 > ff:ff:ff:ff:ff:ff, ethertype ARP
(0x0806), length 42: arp who-has ADSL.129 tell ADSL.134
13:00:45.157459 00:1b:90:c8:47:76 > 00:30:05:cb:27:c1, ethertype ARP
(0x0806), length 60: arp reply ADSL.129 is-at 00:1b:90:c8:47:76

But I get this wrong arp request:

15:12:38.246096 00:30:05:cb:27:c1 > ff:ff:ff:ff:ff:ff, ethertype ARP
(0x0806), length 42: arp who-has ADSL.129 tell HDSL.254
15:12:38.248568 00:07:50:7e:65:e0 > 00:30:05:cb:27:c1, ethertype ARP
(0x0806), length 60: arp reply ADSL.129 is-at 00:07:50:7e:65:e0

when I issue this:

ip rule add fwmark 1 table adsl priority 400

I really don't understand why linux is doing the
arp request for ADSL.129 from HDSL.254 when
I insert the above rule.
This is the output from ip r s table adsl:

default via ADSL.129 dev eth0


