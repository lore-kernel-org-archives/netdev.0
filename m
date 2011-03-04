From: Weiping Pan <panweiping3@gmail.com>
Subject: bonding can't change to another slave if you ifdown the active slave
Date: Fri, 04 Mar 2011 10:15:17 +0800
Message-ID: <4D704B35.20700@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linda Wang <lwang@redhat.com>
To: netdev@vger.kernel.org, bonding-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:43060 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758756Ab1CDCSz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2011 21:18:55 -0500
Received: by qwd7 with SMTP id 7so1357679qwd.19
        for <netdev@vger.kernel.org>; Thu, 03 Mar 2011 18:18:54 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I'm doing some Linux bonding driver test, and I find a problem in
balance-rr mode.
That's it can't change to another slave if you ifdown the active slave.
Any comments are warmly welcomed!

regards
Weiping Pan

My host is Fedora 14, and I install VirtualBox (4.0.2), and enable 4
nics for the guest system.
My guest is Fedora 14 too.
First on my host, I run:
[pwp@localhost linux-2.6.35-comment]$ uname -a
Linux localhost.localdomain 2.6.35.11-83.fc14.i686 #1 SMP Mon Feb 7
07:04:18 UTC 2011 i686 i686 i386 GNU/Linux

[pwp@localhost linux-2.6.35-comment]$ sudo ifconfig eth0:0 192.168.1.100
netmask 255.255.255.0 up
[pwp@localhost linux-2.6.35-comment]$ sudo ifconfig
eth0      Link encap:Ethernet  HWaddr 64:31:50:3A:B0:B5
           inet addr:10.66.65.228  Bcast:10.66.65.255  Mask:255.255.254.0
           inet6 addr: fe80::6631:50ff:fe3a:b0b5/64 Scope:Link
           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
           RX packets:811505 errors:0 dropped:0 overruns:0 frame:0
           TX packets:777018 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:1000
           RX bytes:709681583 (676.8 MiB)  TX bytes:71520005 (68.2 MiB)
           Interrupt:17

eth0:0    Link encap:Ethernet  HWaddr 64:31:50:3A:B0:B5
           inet addr:192.168.1.100  Bcast:192.168.1.255  Mask:255.255.255.0
           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
           Interrupt:17

Then I enable bonding on my guest, I run:
[root@localhost ~]# uname -a
Linux localhost.localdomain 2.6.35.11-83.fc14.i686 #1 SMP Mon Feb 7
07:04:18 UTC 2011 i686 i686 i386 GNU/Linux

[root@localhost ~]# ifconfig
eth6      Link encap:Ethernet  HWaddr 08:00:27:3A:4D:BD
           inet addr:10.66.65.167  Bcast:10.66.65.255  Mask:255.255.254.0
           inet6 addr: fe80::a00:27ff:fe3a:4dbd/64 Scope:Link
           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
           RX packets:65 errors:0 dropped:0 overruns:0 frame:0
           TX packets:31 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:1000
           RX bytes:9916 (9.6 KiB)  TX bytes:3090 (3.0 KiB)

eth7      Link encap:Ethernet  HWaddr 08:00:27:26:1B:DB
           inet addr:10.66.65.154  Bcast:10.66.65.255  Mask:255.255.254.0
           inet6 addr: fe80::a00:27ff:fe26:1bdb/64 Scope:Link
           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
           RX packets:57 errors:0 dropped:0 overruns:0 frame:0
           TX packets:8 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:1000
           RX bytes:7358 (7.1 KiB)  TX bytes:1152 (1.1 KiB)

eth8      Link encap:Ethernet  HWaddr 08:00:27:B5:FC:D1
           inet addr:10.66.65.169  Bcast:10.66.65.255  Mask:255.255.254.0
           inet6 addr: fe80::a00:27ff:feb5:fcd1/64 Scope:Link
           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
           RX packets:57 errors:0 dropped:0 overruns:0 frame:0
           TX packets:8 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:1000
           RX bytes:7358 (7.1 KiB)  TX bytes:1152 (1.1 KiB)

eth9      Link encap:Ethernet  HWaddr 08:00:27:C7:7B:FC
           inet addr:10.66.65.216  Bcast:10.66.65.255  Mask:255.255.254.0
           inet6 addr: fe80::a00:27ff:fec7:7bfc/64 Scope:Link
           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
           RX packets:57 errors:0 dropped:0 overruns:0 frame:0
           TX packets:8 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:1000
           RX bytes:7358 (7.1 KiB)  TX bytes:1152 (1.1 KiB)

lo        Link encap:Local Loopback
           inet addr:127.0.0.1  Mask:255.0.0.0
           inet6 addr: ::1/128 Scope:Host
           UP LOOPBACK RUNNING  MTU:16436  Metric:1
           RX packets:123 errors:0 dropped:0 overruns:0 frame:0
           TX packets:123 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:0
           RX bytes:13036 (12.7 KiB)  TX bytes:13036 (12.7 KiB)

[root@localhost ~]# ifconfig eth7 down
[root@localhost ~]# ifconfig eth8 down
[root@localhost ~]# dmesg -c
[root@localhost ~]# modprobe bonding mode=0 miimon=100
[root@localhost ~]# ifconfig bond0 192.168.1.5 netmask 255.255.255.0 up
[root@localhost ~]# ifenslave bond0 eth7

[root@localhost ~]# dmesg
[  304.496463] bonding: Ethernet Channel Bonding Driver: v3.6.0
(September 26, 2009)
[  304.496468] bonding: MII link monitoring set to 100 ms
[  353.527680] ADDRCONF(NETDEV_UP): bond0: link is not ready
[  355.321626] e1000: eth7 NIC Link is Up 1000 Mbps Full Duplex, Flow
Control: RX
[  355.322250] bonding: bond0: enslaving eth7 as an active interface
with an up link.
[  355.323503] ADDRCONF(NETDEV_CHANGE): bond0: link becomes ready
[  365.394052] bond0: no IPv6 routers present

[pwp@localhost ~]$ ping 192.168.1.100 -c 10
PING 192.168.1.100 (192.168.1.100) 56(84) bytes of data.
64 bytes from 192.168.1.100: icmp_req=1 ttl=64 time=0.196 ms
64 bytes from 192.168.1.100: icmp_req=2 ttl=64 time=0.365 ms
64 bytes from 192.168.1.100: icmp_req=3 ttl=64 time=0.259 ms
64 bytes from 192.168.1.100: icmp_req=4 ttl=64 time=0.135 ms
64 bytes from 192.168.1.100: icmp_req=5 ttl=64 time=0.194 ms
64 bytes from 192.168.1.100: icmp_req=6 ttl=64 time=0.225 ms
64 bytes from 192.168.1.100: icmp_req=7 ttl=64 time=0.189 ms
64 bytes from 192.168.1.100: icmp_req=8 ttl=64 time=0.274 ms
64 bytes from 192.168.1.100: icmp_req=9 ttl=64 time=1.07 ms
64 bytes from 192.168.1.100: icmp_req=10 ttl=64 time=0.274 ms

--- 192.168.1.100 ping statistics ---
10 packets transmitted, 10 received, 0% packet loss, time 9002ms
rtt min/avg/max/mdev = 0.135/0.319/1.079/0.260 ms

[root@localhost ~]# ifenslave bond0 eth8
[root@localhost ~]# dmesg
[  304.496463] bonding: Ethernet Channel Bonding Driver: v3.6.0
(September 26, 2009)
[  304.496468] bonding: MII link monitoring set to 100 ms
[  353.527680] ADDRCONF(NETDEV_UP): bond0: link is not ready
[  355.321626] e1000: eth7 NIC Link is Up 1000 Mbps Full Duplex, Flow
Control: RX
[  355.322250] bonding: bond0: enslaving eth7 as an active interface
with an up link.
[  355.323503] ADDRCONF(NETDEV_CHANGE): bond0: link becomes ready
[  365.394052] bond0: no IPv6 routers present
[  510.913797] e1000: eth8 NIC Link is Up 1000 Mbps Full Duplex, Flow
Control: RX
[  510.917312] bonding: bond0: enslaving eth8 as an active interface
with an up link.

[pwp@localhost ~]$ ping 192.168.1.100 -c 10
PING 192.168.1.100 (192.168.1.100) 56(84) bytes of data.
64 bytes from 192.168.1.100: icmp_req=1 ttl=64 time=0.182 ms
64 bytes from 192.168.1.100: icmp_req=2 ttl=64 time=0.211 ms
64 bytes from 192.168.1.100: icmp_req=3 ttl=64 time=0.270 ms
64 bytes from 192.168.1.100: icmp_req=4 ttl=64 time=0.248 ms
64 bytes from 192.168.1.100: icmp_req=5 ttl=64 time=0.132 ms
64 bytes from 192.168.1.100: icmp_req=6 ttl=64 time=0.291 ms
64 bytes from 192.168.1.100: icmp_req=7 ttl=64 time=0.246 ms
64 bytes from 192.168.1.100: icmp_req=8 ttl=64 time=0.272 ms
64 bytes from 192.168.1.100: icmp_req=9 ttl=64 time=0.293 ms
64 bytes from 192.168.1.100: icmp_req=10 ttl=64 time=0.133 ms

--- 192.168.1.100 ping statistics ---
10 packets transmitted, 10 received, 0% packet loss, time 9000ms
rtt min/avg/max/mdev = 0.132/0.227/0.293/0.060 ms

[root@localhost ~]# ifconfig
bond0     Link encap:Ethernet  HWaddr 08:00:27:26:1B:DB
           inet addr:192.168.1.5  Bcast:192.168.1.255  Mask:255.255.255.0
           inet6 addr: fe80::a00:27ff:fe26:1bdb/64 Scope:Link
           UP BROADCAST RUNNING MASTER MULTICAST  MTU:1500  Metric:1
           RX packets:311 errors:0 dropped:0 overruns:0 frame:0
           TX packets:61 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:0
           RX bytes:38075 (37.1 KiB)  TX bytes:8698 (8.4 KiB)

eth7      Link encap:Ethernet  HWaddr 08:00:27:26:1B:DB
           inet addr:10.66.65.154  Bcast:10.66.65.255  Mask:255.255.254.0
           UP BROADCAST RUNNING SLAVE MULTICAST  MTU:1500  Metric:1
           RX packets:181 errors:0 dropped:0 overruns:0 frame:0
           TX packets:39 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:1000
           RX bytes:22297 (21.7 KiB)  TX bytes:4578 (4.4 KiB)

eth8      Link encap:Ethernet  HWaddr 08:00:27:26:1B:DB
           inet addr:192.168.1.15  Bcast:192.168.1.255  Mask:255.255.255.0
           UP BROADCAST RUNNING SLAVE MULTICAST  MTU:1500  Metric:1
           RX packets:130 errors:0 dropped:0 overruns:0 frame:0
           TX packets:22 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:1000
           RX bytes:15778 (15.4 KiB)  TX bytes:4120 (4.0 KiB)

[root@localhost ~]# ifconfig eth7 down
[root@localhost ~]# dmesg
[  304.496463] bonding: Ethernet Channel Bonding Driver: v3.6.0
(September 26, 2009)
[  304.496468] bonding: MII link monitoring set to 100 ms
[  353.527680] ADDRCONF(NETDEV_UP): bond0: link is not ready
[  355.321626] e1000: eth7 NIC Link is Up 1000 Mbps Full Duplex, Flow
Control: RX
[  355.322250] bonding: bond0: enslaving eth7 as an active interface
with an up link.
[  355.323503] ADDRCONF(NETDEV_CHANGE): bond0: link becomes ready
[  365.394052] bond0: no IPv6 routers present
[  510.913797] e1000: eth8 NIC Link is Up 1000 Mbps Full Duplex, Flow
Control: RX
[  510.917312] bonding: bond0: enslaving eth8 as an active interface
with an up link.
[  592.208534] bonding: bond0: link status definitely down for interface
eth7, disabling it

Now, if bonding driver works well, eth8 will be the active slave, and
the network connection is ok.
__But__ ...

[pwp@localhost ~]$ ping 192.168.1.100 -c 10
PING 192.168.1.100 (192.168.1.100) 56(84) bytes of data.
 From 192.168.1.5 icmp_seq=10 Destination Host Unreachable

--- 192.168.1.100 ping statistics ---
10 packets transmitted, 0 received, +1 errors, 100% packet loss, time 8999ms

How strange!

[root@localhost ~]# ifconfig
bond0     Link encap:Ethernet  HWaddr 08:00:27:26:1B:DB
           inet addr:192.168.1.5  Bcast:192.168.1.255  Mask:255.255.255.0
           inet6 addr: fe80::a00:27ff:fe26:1bdb/64 Scope:Link
           UP BROADCAST RUNNING MASTER MULTICAST  MTU:1500  Metric:1
           RX packets:357 errors:0 dropped:0 overruns:0 frame:0
           TX packets:76 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:0
           RX bytes:42971 (41.9 KiB)  TX bytes:9832 (9.6 KiB)

eth8      Link encap:Ethernet  HWaddr 08:00:27:26:1B:DB
           inet addr:192.168.1.15  Bcast:192.168.1.255  Mask:255.255.255.0
           UP BROADCAST RUNNING SLAVE MULTICAST  MTU:1500  Metric:1
           RX packets:163 errors:0 dropped:0 overruns:0 frame:0
           TX packets:37 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:1000
           RX bytes:19073 (18.6 KiB)  TX bytes:5254 (5.1 KiB)

[root@localhost ~]# arp
Address                  HWtype  HWaddress           Flags
Mask            Iface
corerouter.nay.redhat.c  ether   00:1d:45:20:d5:ff
C                     eth6
192.168.1.100
(incomplete)                              bond0

I think maybe there is something wrong about arp.
So I run ping and tcpdump synchronously.

[pwp@localhost ~]$ ping 192.168.1.100 -c 10
PING 192.168.1.100 (192.168.1.100) 56(84) bytes of data.
 From 192.168.1.5 icmp_seq=2 Destination Host Unreachable
 From 192.168.1.5 icmp_seq=3 Destination Host Unreachable
 From 192.168.1.5 icmp_seq=4 Destination Host Unreachable
 From 192.168.1.5 icmp_seq=6 Destination Host Unreachable
 From 192.168.1.5 icmp_seq=7 Destination Host Unreachable
 From 192.168.1.5 icmp_seq=8 Destination Host Unreachable
 From 192.168.1.5 icmp_seq=9 Destination Host Unreachable
 From 192.168.1.5 icmp_seq=10 Destination Host Unreachable

--- 192.168.1.100 ping statistics ---
10 packets transmitted, 0 received, +8 errors, 100% packet loss, time 9002ms
pipe 3

And meanwhile,
[root@localhost ~]# tcpdump -i bond0 -p arp
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on bond0, link-type EN10MB (Ethernet), capture size 65535 bytes
02:46:56.983092 ARP, Request who-has 192.168.1.100 tell 192.168.1.5,
length 28
02:46:57.984040 ARP, Request who-has 192.168.1.100 tell 192.168.1.5,
length 28
02:46:58.988442 ARP, Request who-has 192.168.1.100 tell 192.168.1.5,
length 28
02:47:00.987340 ARP, Request who-has 192.168.1.100 tell 192.168.1.5,
length 28
02:47:01.988136 ARP, Request who-has 192.168.1.100 tell 192.168.1.5,
length 28
02:47:02.990033 ARP, Request who-has 192.168.1.100 tell 192.168.1.5,
length 28
02:47:04.985086 ARP, Request who-has 192.168.1.100 tell 192.168.1.5,
length 28
02:47:05.992368 ARP, Request who-has 192.168.1.100 tell 192.168.1.5,
length 28
02:47:06.996727 ARP, Request who-has 192.168.1.100 tell 192.168.1.5,
length 28
02:47:17.231106 ARP, Request who-has dhcp-65-32.nay.redhat.com tell
dhcp-65-180.nay.redhat.com, length 46
^C
10 packets captured
10 packets received by filter
0 packets dropped by kernel


But I'm sure eth8 works well.

[root@localhost ~]# modprobe -r bonding
[root@localhost ~]# modprobe bonding mode=0 miimon=100
[root@localhost ~]# ifconfig bond0 192.168.1.5 netmask 255.255.255.0 up
[root@localhost ~]# ifenslave bond0 eth8

[pwp@localhost ~]$ ping 192.168.1.100 -c 10
PING 192.168.1.100 (192.168.1.100) 56(84) bytes of data.
64 bytes from 192.168.1.100: icmp_req=1 ttl=64 time=0.683 ms
64 bytes from 192.168.1.100: icmp_req=2 ttl=64 time=0.222 ms
64 bytes from 192.168.1.100: icmp_req=3 ttl=64 time=0.265 ms
64 bytes from 192.168.1.100: icmp_req=4 ttl=64 time=0.237 ms
64 bytes from 192.168.1.100: icmp_req=5 ttl=64 time=0.214 ms
64 bytes from 192.168.1.100: icmp_req=6 ttl=64 time=0.214 ms
64 bytes from 192.168.1.100: icmp_req=7 ttl=64 time=0.238 ms
64 bytes from 192.168.1.100: icmp_req=8 ttl=64 time=0.152 ms
64 bytes from 192.168.1.100: icmp_req=9 ttl=64 time=0.234 ms
64 bytes from 192.168.1.100: icmp_req=10 ttl=64 time=0.221 ms

--- 192.168.1.100 ping statistics ---
10 packets transmitted, 10 received, 0% packet loss, time 9004ms
rtt min/avg/max/mdev = 0.152/0.268/0.683/0.141 ms

[root@localhost ~]# ifconfig
bond0     Link encap:Ethernet  HWaddr 08:00:27:B5:FC:D1
           inet addr:192.168.1.5  Bcast:192.168.1.255  Mask:255.255.255.0
           inet6 addr: fe80::a00:27ff:feb5:fcd1/64 Scope:Link
           UP BROADCAST RUNNING MASTER MULTICAST  MTU:1500  Metric:1
           RX packets:263 errors:0 dropped:0 overruns:0 frame:0
           TX packets:79 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:0
           RX bytes:28246 (27.5 KiB)  TX bytes:9810 (9.5 KiB)

eth8      Link encap:Ethernet  HWaddr 08:00:27:B5:FC:D1
           UP BROADCAST RUNNING SLAVE MULTICAST  MTU:1500  Metric:1
           RX packets:263 errors:0 dropped:0 overruns:0 frame:0
           TX packets:79 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:1000
           RX bytes:28246 (27.5 KiB)  TX bytes:9810 (9.5 KiB)

[root@localhost ~]# arp
Address                  HWtype  HWaddress           Flags
Mask            Iface
corerouter.nay.redhat.c  ether   00:1d:45:20:d5:ff
C                     eth6
192.168.1.100            ether   64:31:50:3a:b0:b5
C                     bond0




