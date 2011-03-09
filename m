From: Weiping Pan <panweiping3@gmail.com>
Subject: Re: bonding can't change to another slave if you ifdown the active
 slave
Date: Wed, 09 Mar 2011 10:40:36 +0800
Message-ID: <4D76E8A4.6080801@gmail.com>
References: <4D75D244.9070409@gmail.com> <il58p9$3ka$2@dough.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: WANG Cong <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:48756 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932073Ab1CICos (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Mar 2011 21:44:48 -0500
Received: by vws12 with SMTP id 12so105611vws.19
        for <netdev@vger.kernel.org>; Tue, 08 Mar 2011 18:44:47 -0800 (PST)
In-Reply-To: <il58p9$3ka$2@dough.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/08/2011 08:51 PM, WANG Cong wrote:
> On Tue, 08 Mar 2011 14:52:52 +0800, Weiping Pan wrote:
>
>> ok, I use "Host-only mode" and get
>>
>>
>>
>> an conclusion, that if the first enslaved nic is pulled out, bonding
>> can't handle well.
>>
>> First test.
>> I first enslave eth6, then pull it out, bonding doesn't work. on host,
> ...
>>
>> Second test
>> I first enslave eth6, then pull eth7 out, bonding works well. on guest,
> Can you show me your /proc/net/bonding/bond0 before and after pulling down
> eth6 or eth7? And what does `ip link show` say?
>
Ok, let me repeat my test, and gather more information.
on host,
[root@localhost ~]# VBoxManage -v
4.0.2r69518
[root@localhost ~]# VBoxManage showvminfo 
67b83c47-0ee2-46bc-b0ff-e0eb43edc1c2|grep ^NIC
NIC 1:           MAC: 0800270481A8, Attachment: Host-only Interface 
'vboxnet0', Cable connected: on, Trace: off (file: none), Type: 82540EM, 
Reported speed: 0 Mbps, Boot priority: 0
NIC 2:           MAC: 08002778F641, Attachment: Host-only Interface 
'vboxnet0', Cable connected: on, Trace: off (file: none), Type: 82540EM, 
Reported speed: 0 Mbps, Boot priority: 0
NIC 3:           MAC: 080027C408BA, Attachment: Host-only Interface 
'vboxnet0', Cable connected: on, Trace: off (file: none), Type: 82540EM, 
Reported speed: 0 Mbps, Boot priority: 0
NIC 4:           MAC: 080027DB339A, Attachment: Host-only Interface 
'vboxnet0', Cable connected: on, Trace: off (file: none), Type: 82540EM, 
Reported speed: 0 Mbps, Boot priority: 0


[root@localhost ~]# ifconfig
vboxnet0  Link encap:Ethernet  HWaddr 0A:00:27:00:00:00
           inet addr:192.168.56.1  Bcast:192.168.56.255  Mask:255.255.255.0
           inet6 addr: fe80::800:27ff:fe00:0/64 Scope:Link
           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
           RX packets:0 errors:0 dropped:0 overruns:0 frame:0
           TX packets:3438 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:1000
           RX bytes:0 (0.0 b)  TX bytes:296716 (289.7 KiB)

vboxnet0:0 Link encap:Ethernet  HWaddr 0A:00:27:00:00:00
           inet addr:192.168.1.100  Bcast:192.168.1.255  Mask:255.255.255.0
           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1

vboxnet0:1 Link encap:Ethernet  HWaddr 0A:00:27:00:00:00
           inet addr:192.168.1.101  Bcast:192.168.1.255  Mask:255.255.255.0
           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
[root@localhost ~]# route
Kernel IP routing table
Destination     Gateway         Genmask         Flags Metric Ref    Use 
Iface
192.168.1.0     *               255.255.255.0   U     0      0        0 
vboxnet0
192.168.56.0    *               255.255.255.0   U     0      0        0 
vboxnet0
10.66.64.0      *               255.255.254.0   U     1      0        0 eth0
default         corerouter.nay. 0.0.0.0         UG    0      0        0 eth0
[root@localhost ~]# ip neigh show
10.66.65.254 dev eth0 lladdr 00:1d:45:20:d5:ff REACHABLE


then restart guest,
[root@localhost ~]# ifconfig
eth6      Link encap:Ethernet  HWaddr 08:00:27:78:F6:41
           inet addr:192.168.56.101  Bcast:192.168.56.255  
Mask:255.255.255.0
           inet6 addr: fe80::a00:27ff:fe78:f641/64 Scope:Link
           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
           RX packets:14 errors:0 dropped:0 overruns:0 frame:0
           TX packets:8 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:1000
           RX bytes:6772 (6.6 KiB)  TX bytes:1152 (1.1 KiB)

eth7      Link encap:Ethernet  HWaddr 08:00:27:04:81:A8
           inet addr:192.168.56.102  Bcast:192.168.56.255  
Mask:255.255.255.0
           inet6 addr: fe80::a00:27ff:fe04:81a8/64 Scope:Link
           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
           RX packets:14 errors:0 dropped:0 overruns:0 frame:0
           TX packets:8 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:1000
           RX bytes:6772 (6.6 KiB)  TX bytes:1152 (1.1 KiB)

eth8      Link encap:Ethernet  HWaddr 08:00:27:DB:33:9A
           inet addr:192.168.56.104  Bcast:192.168.56.255  
Mask:255.255.255.0
           inet6 addr: fe80::a00:27ff:fedb:339a/64 Scope:Link
           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
           RX packets:14 errors:0 dropped:0 overruns:0 frame:0
           TX packets:8 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:1000
           RX bytes:6772 (6.6 KiB)  TX bytes:1152 (1.1 KiB)

eth9      Link encap:Ethernet  HWaddr 08:00:27:C4:08:BA
           inet addr:192.168.56.103  Bcast:192.168.56.255  
Mask:255.255.255.0
           inet6 addr: fe80::a00:27ff:fec4:8ba/64 Scope:Link
           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
           RX packets:14 errors:0 dropped:0 overruns:0 frame:0
           TX packets:8 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:1000
           RX bytes:6772 (6.6 KiB)  TX bytes:1152 (1.1 KiB)

so according to mac address,
NIC 1:           eth7
NIC 2:           eth6
NIC 3:           eth9
NIC 4:           eth8


[root@localhost ~]# ifconfig eth6 down
[root@localhost ~]# ifconfig eth7 down
[root@localhost ~]# ifconfig eth8 down
[root@localhost ~]# ifconfig eth9 down
[root@localhost ~]# modprobe bonding mode=0 miimon=100
[root@localhost ~]# ifconfig bond0 192.168.1.2 netmask 255.255.255.0 up
[root@localhost ~]# ifenslave bond0 eth6
[root@localhost ~]# ifenslave bond0 eth7
[root@localhost ~]# dmesg
[ 1436.344751] bonding: Ethernet Channel Bonding Driver: v3.6.0 
(September 26, 2009)
[ 1436.344756] bonding: MII link monitoring set to 100 ms
[ 1480.485933] ADDRCONF(NETDEV_UP): bond0: link is not ready
[ 1490.087608] e1000: eth6 NIC Link is Up 1000 Mbps Full Duplex, Flow 
Control: RX
[ 1490.091795] bonding: bond0: enslaving eth6 as an active interface 
with an up link.
[ 1490.092326] ADDRCONF(NETDEV_CHANGE): bond0: link becomes ready
[ 1492.676643] e1000: eth7 NIC Link is Up 1000 Mbps Full Duplex, Flow 
Control: RX
[ 1492.684839] bonding: bond0: enslaving eth7 as an active interface 
with an up link.
[root@localhost ~]# cat /proc/net/bonding/bond0
Ethernet Channel Bonding Driver: v3.6.0 (September 26, 2009)

Bonding Mode: load balancing (round-robin)
MII Status: up
MII Polling Interval (ms): 100
Up Delay (ms): 0
Down Delay (ms): 0

Slave Interface: eth6
MII Status: up
Link Failure Count: 0
Permanent HW addr: 08:00:27:78:f6:41

Slave Interface: eth7
MII Status: up
Link Failure Count: 0
Permanent HW addr: 08:00:27:04:81:a8
[root@localhost ~]# ifconfig
bond0     Link encap:Ethernet  HWaddr 08:00:27:78:F6:41
           inet addr:192.168.1.2  Bcast:192.168.1.255  Mask:255.255.255.0
           inet6 addr: fe80::a00:27ff:fe78:f641/64 Scope:Link
           UP BROADCAST RUNNING MASTER MULTICAST  MTU:1500  Metric:1
           RX packets:40 errors:0 dropped:0 overruns:0 frame:0
           TX packets:25 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:0
           RX bytes:19632 (19.1 KiB)  TX bytes:4070 (3.9 KiB)

eth6      Link encap:Ethernet  HWaddr 08:00:27:78:F6:41
           inet addr:192.168.56.101  Bcast:192.168.56.255  
Mask:255.255.255.0
           UP BROADCAST RUNNING SLAVE MULTICAST  MTU:1500  Metric:1
           RX packets:21 errors:0 dropped:0 overruns:0 frame:0
           TX packets:13 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:1000
           RX bytes:10158 (9.9 KiB)  TX bytes:1802 (1.7 KiB)

eth7      Link encap:Ethernet  HWaddr 08:00:27:78:F6:41
           inet addr:192.168.56.101  Bcast:192.168.56.255  
Mask:255.255.255.0
           UP BROADCAST RUNNING SLAVE MULTICAST  MTU:1500  Metric:1
           RX packets:19 errors:0 dropped:0 overruns:0 frame:0
           TX packets:12 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:1000
           RX bytes:9474 (9.2 KiB)  TX bytes:2268 (2.2 KiB)

[root@localhost ~]# ping 192.168.1.100 -c 5
PING 192.168.1.100 (192.168.1.100) 56(84) bytes of data.
64 bytes from 192.168.1.100: icmp_req=1 ttl=64 time=3.69 ms
64 bytes from 192.168.1.100: icmp_req=2 ttl=64 time=0.242 ms
64 bytes from 192.168.1.100: icmp_req=3 ttl=64 time=0.154 ms
64 bytes from 192.168.1.100: icmp_req=4 ttl=64 time=0.270 ms
64 bytes from 192.168.1.100: icmp_req=5 ttl=64 time=0.278 ms

--- 192.168.1.100 ping statistics ---
5 packets transmitted, 5 received, 0% packet loss, time 4004ms
rtt min/avg/max/mdev = 0.154/0.928/3.696/1.384 ms

[root@localhost ~]# dmesg -c &>/dev/null

on host,
[root@localhost ~]# VBoxManage controlvm 
67b83c47-0ee2-46bc-b0ff-e0eb43edc1c2 setlinkstate2 off

on guest,
[root@localhost ~]# dmesg
[ 1731.945272] e1000: eth6 NIC Link is Down
[ 1732.026207] bonding: bond0: link status definitely down for interface 
eth6, disabling it
[root@localhost ~]# cat /proc/net/bonding/bond0
Ethernet Channel Bonding Driver: v3.6.0 (September 26, 2009)

Bonding Mode: load balancing (round-robin)
MII Status: up
MII Polling Interval (ms): 100
Up Delay (ms): 0
Down Delay (ms): 0

Slave Interface: eth6
MII Status: down
Link Failure Count: 1
Permanent HW addr: 08:00:27:78:f6:41

Slave Interface: eth7
MII Status: up
Link Failure Count: 0
Permanent HW addr: 08:00:27:04:81:a8
[root@localhost ~]# ping 192.168.1.100 -c 5
PING 192.168.1.100 (192.168.1.100) 56(84) bytes of data.
 From 192.168.1.2 icmp_seq=2 Destination Host Unreachable
 From 192.168.1.2 icmp_seq=3 Destination Host Unreachable
 From 192.168.1.2 icmp_seq=4 Destination Host Unreachable
 From 192.168.1.2 icmp_seq=5 Destination Host Unreachable

--- 192.168.1.100 ping statistics ---
5 packets transmitted, 0 received, +4 errors, 100% packet loss, time 4001ms
pipe 3
[root@localhost ~]# ip link show
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 16436 qdisc noqueue state UNKNOWN
     link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: eth7: <BROADCAST,MULTICAST,SLAVE,UP,LOWER_UP> mtu 1500 qdisc 
pfifo_fast master bond0 state UP qlen 1000
     link/ether 08:00:27:78:f6:41 brd ff:ff:ff:ff:ff:ff
3: eth6: <NO-CARRIER,BROADCAST,MULTICAST,SLAVE,UP> mtu 1500 qdisc 
pfifo_fast master bond0 state DOWN qlen 1000
     link/ether 08:00:27:78:f6:41 brd ff:ff:ff:ff:ff:ff
4: eth9: <BROADCAST,MULTICAST> mtu 1500 qdisc pfifo_fast state DOWN qlen 
1000
     link/ether 08:00:27:c4:08:ba brd ff:ff:ff:ff:ff:ff
5: eth8: <BROADCAST,MULTICAST> mtu 1500 qdisc pfifo_fast state DOWN qlen 
1000
     link/ether 08:00:27:db:33:9a brd ff:ff:ff:ff:ff:ff
6: bond0: <BROADCAST,MULTICAST,MASTER,UP,LOWER_UP> mtu 1500 qdisc 
noqueue state UP
     link/ether 08:00:27:78:f6:41 brd ff:ff:ff:ff:ff:ff
[root@localhost ~]# ip neigh show
192.168.1.100 dev bond0  FAILED

on host,
[root@localhost ~]# ip neigh show
10.66.65.254 dev eth0 lladdr 00:1d:45:20:d5:ff STALE
192.168.1.2 dev vboxnet0 lladdr 08:00:27:78:f6:41 STALE

on guest, ping while tcpdump
[root@localhost ~]# ping 192.168.1.100
PING 192.168.1.100 (192.168.1.100) 56(84) bytes of data.
 From 192.168.1.2 icmp_seq=11 Destination Host Unreachable
 From 192.168.1.2 icmp_seq=12 Destination Host Unreachable
 From 192.168.1.2 icmp_seq=13 Destination Host Unreachable
 From 192.168.1.2 icmp_seq=15 Destination Host Unreachable
 From 192.168.1.2 icmp_seq=16 Destination Host Unreachable
 From 192.168.1.2 icmp_seq=17 Destination Host Unreachable
 From 192.168.1.2 icmp_seq=19 Destination Host Unreachable
 From 192.168.1.2 icmp_seq=20 Destination Host Unreachable
 From 192.168.1.2 icmp_seq=21 Destination Host Unreachable
 From 192.168.1.2 icmp_seq=23 Destination Host Unreachable
 From 192.168.1.2 icmp_seq=24 Destination Host Unreachable
 From 192.168.1.2 icmp_seq=25 Destination Host Unreachable
 From 192.168.1.2 icmp_seq=27 Destination Host Unreachable
 From 192.168.1.2 icmp_seq=28 Destination Host Unreachable
 From 192.168.1.2 icmp_seq=29 Destination Host Unreachable
^C
--- 192.168.1.100 ping statistics ---
30 packets transmitted, 0 received, +15 errors, 100% packet loss, time 
29011ms
pipe 3
[root@localhost ~]# tcpdump -i bond0 -p arp
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on bond0, link-type EN10MB (Ethernet), capture size 65535 bytes
21:22:40.694058 ARP, Request who-has 192.168.1.100 tell 192.168.1.2, 
length 28
21:22:41.695875 ARP, Request who-has 192.168.1.100 tell 192.168.1.2, 
length 28
21:22:42.698067 ARP, Request who-has 192.168.1.100 tell 192.168.1.2, 
length 28
21:22:44.689068 ARP, Request who-has 192.168.1.100 tell 192.168.1.2, 
length 28
21:22:45.689837 ARP, Request who-has 192.168.1.100 tell 192.168.1.2, 
length 28
21:22:46.692076 ARP, Request who-has 192.168.1.100 tell 192.168.1.2, 
length 28
21:22:48.691080 ARP, Request who-has 192.168.1.100 tell 192.168.1.2, 
length 28
21:22:49.693828 ARP, Request who-has 192.168.1.100 tell 192.168.1.2, 
length 28
21:22:50.696074 ARP, Request who-has 192.168.1.100 tell 192.168.1.2, 
length 28
21:22:52.693070 ARP, Request who-has 192.168.1.100 tell 192.168.1.2, 
length 28
21:22:53.693837 ARP, Request who-has 192.168.1.100 tell 192.168.1.2, 
length 28
21:22:54.696075 ARP, Request who-has 192.168.1.100 tell 192.168.1.2, 
length 28
21:22:56.694072 ARP, Request who-has 192.168.1.100 tell 192.168.1.2, 
length 28
21:22:57.696063 ARP, Request who-has 192.168.1.100 tell 192.168.1.2, 
length 28
21:22:58.698096 ARP, Request who-has 192.168.1.100 tell 192.168.1.2, 
length 28
21:23:00.696065 ARP, Request who-has 192.168.1.100 tell 192.168.1.2, 
length 28
21:23:01.698072 ARP, Request who-has 192.168.1.100 tell 192.168.1.2, 
length 28
21:23:02.700063 ARP, Request who-has 192.168.1.100 tell 192.168.1.2, 
length 28
21:23:04.698071 ARP, Request who-has 192.168.1.100 tell 192.168.1.2, 
length 28
21:23:05.700504 ARP, Request who-has 192.168.1.100 tell 192.168.1.2, 
length 28
21:23:06.702009 ARP, Request who-has 192.168.1.100 tell 192.168.1.2, 
length 28
^C
21 packets captured
21 packets received by filter
0 packets dropped by kernel

meanwhile on host,
[root@localhost ~]# tcpdump -i vboxnet0 -p arp
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on vboxnet0, link-type EN10MB (Ethernet), capture size 65535 bytes
10:22:56.936833 ARP, Request who-has 192.168.1.100 tell 192.168.1.2, 
length 28
10:22:56.936839 ARP, Request who-has 192.168.1.100 tell 192.168.1.2, 
length 28
10:22:57.938415 ARP, Request who-has 192.168.1.100 tell 192.168.1.2, 
length 28
10:22:57.938422 ARP, Request who-has 192.168.1.100 tell 192.168.1.2, 
length 28
10:22:58.939875 ARP, Request who-has 192.168.1.100 tell 192.168.1.2, 
length 28
10:22:58.939881 ARP, Request who-has 192.168.1.100 tell 192.168.1.2, 
length 28
10:23:00.937292 ARP, Request who-has 192.168.1.100 tell 192.168.1.2, 
length 28
10:23:00.937299 ARP, Request who-has 192.168.1.100 tell 192.168.1.2, 
length 28
10:23:01.939242 ARP, Request who-has 192.168.1.100 tell 192.168.1.2, 
length 28
10:23:01.939249 ARP, Request who-has 192.168.1.100 tell 192.168.1.2, 
length 28
10:23:02.940559 ARP, Request who-has 192.168.1.100 tell 192.168.1.2, 
length 28
10:23:02.940565 ARP, Request who-has 192.168.1.100 tell 192.168.1.2, 
length 28
10:23:04.938148 ARP, Request who-has 192.168.1.100 tell 192.168.1.2, 
length 28
10:23:04.938156 ARP, Request who-has 192.168.1.100 tell 192.168.1.2, 
length 28
10:23:05.939688 ARP, Request who-has 192.168.1.100 tell 192.168.1.2, 
length 28
10:23:05.939695 ARP, Request who-has 192.168.1.100 tell 192.168.1.2, 
length 28
10:23:06.941288 ARP, Request who-has 192.168.1.100 tell 192.168.1.2, 
length 28
10:23:06.941295 ARP, Request who-has 192.168.1.100 tell 192.168.1.2, 
length 28
^C
18 packets captured
18 packets received by filter
0 packets dropped by kernel


Maybe this is the cause of the problem.
The guest can't receive correct ARP reply, maybe the virtual network of 
VirtualBox doesn't transfer it.

on host,
[root@localhost ~]# VBoxManage controlvm 
67b83c47-0ee2-46bc-b0ff-e0eb43edc1c2 setlinkstate2 on

on guest,
[root@localhost ~]# dmesg
[ 2392.304591] e1000: eth6 NIC Link is Up 1000 Mbps Full Duplex, Flow 
Control: RX
[ 2392.381223] bonding: bond0: link status definitely up for interface eth6.
[root@localhost ~]# ping 192.168.1.100 -c5
PING 192.168.1.100 (192.168.1.100) 56(84) bytes of data.
64 bytes from 192.168.1.100: icmp_req=1 ttl=64 time=0.648 ms
64 bytes from 192.168.1.100: icmp_req=2 ttl=64 time=0.208 ms
64 bytes from 192.168.1.100: icmp_req=3 ttl=64 time=0.187 ms
64 bytes from 192.168.1.100: icmp_req=4 ttl=64 time=0.274 ms
64 bytes from 192.168.1.100: icmp_req=5 ttl=64 time=0.216 ms

--- 192.168.1.100 ping statistics ---
5 packets transmitted, 5 received, 0% packet loss, time 4002ms
rtt min/avg/max/mdev = 0.187/0.306/0.648/0.174 ms

[root@localhost ~]# ip neigh show
192.168.1.100 dev bond0 lladdr 0a:00:27:00:00:00 REACHABLE


thanks
Weiping Pan


