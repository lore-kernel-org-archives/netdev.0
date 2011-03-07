From: Weiping Pan <panweiping3@gmail.com>
Subject: Re: bonding can't change to another slave if you ifdown the active
 slave
Date: Mon, 07 Mar 2011 11:13:27 +0800
Message-ID: <4D744D57.9050908@gmail.com>
References: <4D704B35.20700@gmail.com> <20110305025332.GR11864@gospo.rdu.redhat.com> <4D723F83.7080309@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org,
	bonding-devel@lists.sourceforge.net, Linda Wang <lwang@redhat.com>
To: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:35268 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753934Ab1CGDRI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Mar 2011 22:17:08 -0500
Received: by vxi39 with SMTP id 39so3404312vxi.19
        for <netdev@vger.kernel.org>; Sun, 06 Mar 2011 19:17:07 -0800 (PST)
In-Reply-To: <4D723F83.7080309@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/05/2011 09:49 PM, Nicolas de Peslo=FCan wrote:
> Le 05/03/2011 03:53, Andy Gospodarek a =E9crit :
>> On Fri, Mar 04, 2011 at 10:15:17AM +0800, Weiping Pan wrote:
>>> Hi,
>>>
>>> I'm doing some Linux bonding driver test, and I find a problem in
>>> balance-rr mode.
>>> That's it can't change to another slave if you ifdown the active sl=
ave.
>>> Any comments are warmly welcomed!
>>>
>>> regards
>>> Weiping Pan
>>>
>>> My host is Fedora 14, and I install VirtualBox (4.0.2), and enable =
4
>>> nics for the guest system.
>>
>> Does this mean you are passing 4 NICs from your host to your guest
>> (maybe via direct pci-device assignment to the guest) or are you
>> creating 4 virtual devices on the host that are in a bridge group on=
 the
>> host?
>
> VirtualBox does not allow assignment of pci-device to the guest. The=20
> network interfaces on the guest are pure virtual one, with several=20
> modes available. In order to help you trouble shooting this problem,=20
> we need to know the mode form each of the virtual interfaces. Possibl=
e=20
> modes are NAT, bridged, internal-network, and host-only-network.
>
> Please provide the output of the following command:
>
> VBoxManage showvminfo <your-vm-uuid> | grep ^NIC
>
> To display your vm uuid, use the following command:
>
> VBoxManage list vms
[root@localhost ~]# VBoxManage showvminfo=20
67b83c47-0ee2-46bc-b0ff-e0eb43edc1c2 |grep ^NIC
NIC 1:           MAC: 0800270481A8, Attachment: Bridged Interface=20
'eth0', Cable connected: on, Trace: off (file: none), Type: 82540EM,=20
Reported speed: 0 Mbps, Boot priority: 0
NIC 2:           MAC: 08002778F641, Attachment: Bridged Interface=20
'eth0', Cable connected: on, Trace: off (file: none), Type: 82540EM,=20
Reported speed: 0 Mbps, Boot priority: 0
NIC 3:           MAC: 080027C408BA, Attachment: Bridged Interface=20
'eth0', Cable connected: on, Trace: off (file: none), Type: 82540EM,=20
Reported speed: 0 Mbps, Boot priority: 0
NIC 4:           MAC: 080027DB339A, Attachment: Bridged Interface=20
'eth0', Cable connected: on, Trace: off (file: none), Type: 82540EM,=20
Reported speed: 0 Mbps, Boot priority: 0
NIC 5:           disabled
NIC 6:           disabled
NIC 7:           disabled
NIC 8:           disabled

And when guest starts, i find that:
NIC 1: eth7
NIC 2: eth6
NIC 3: eth9
NIC 4: eth8

>
>>
>> [...]
>>> [root@localhost ~]# ifconfig eth7 down
>>
>> This is not a great way to test link failure with bonding.  The best=
 way
>> is to actually pull the cable so the interface is truly down.
>
> To virtually plug or unplug the cable from a virtual interface, use=20
> the following command, replacing the # with the interface number (fro=
m=20
> 1 to 8):
>
> VBoxManage controlvm setlinkstate# on
> VBoxManage controlvm setlinkstate# off
I repeat my test with your guide, but it still doesn't work!

=46irst on my host,
ifconfig eth0:0 192.168.1.100 netmask 255.255.255.0 up

And restart my guest,
[root@localhost ~]# ifconfig
eth6      Link encap:Ethernet  HWaddr 08:00:27:78:F6:41
           inet addr:10.66.65.128  Bcast:10.66.65.255  Mask:255.255.254=
=2E0
           inet6 addr: fe80::a00:27ff:fe78:f641/64 Scope:Link
           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
           RX packets:22 errors:0 dropped:0 overruns:0 frame:0
           TX packets:8 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:1000
           RX bytes:3608 (3.5 KiB)  TX bytes:1152 (1.1 KiB)

eth7      Link encap:Ethernet  HWaddr 08:00:27:04:81:A8
           inet addr:10.66.65.53  Bcast:10.66.65.255  Mask:255.255.254.=
0
           inet6 addr: fe80::a00:27ff:fe04:81a8/64 Scope:Link
           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
           RX packets:23 errors:0 dropped:0 overruns:0 frame:0
           TX packets:8 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:1000
           RX bytes:3668 (3.5 KiB)  TX bytes:1152 (1.1 KiB)

eth8      Link encap:Ethernet  HWaddr 08:00:27:DB:33:9A
           inet addr:10.66.65.237  Bcast:10.66.65.255  Mask:255.255.254=
=2E0
           inet6 addr: fe80::a00:27ff:fedb:339a/64 Scope:Link
           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
           RX packets:147 errors:0 dropped:0 overruns:0 frame:0
           TX packets:8 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:1000
           RX bytes:14783 (14.4 KiB)  TX bytes:1152 (1.1 KiB)

eth9      Link encap:Ethernet  HWaddr 08:00:27:C4:08:BA
           inet addr:10.66.65.125  Bcast:10.66.65.255  Mask:255.255.254=
=2E0
           inet6 addr: fe80::a00:27ff:fec4:8ba/64 Scope:Link
           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
           RX packets:147 errors:0 dropped:0 overruns:0 frame:0
           TX packets:8 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:1000
           RX bytes:14783 (14.4 KiB)  TX bytes:1152 (1.1 KiB)

lo        Link encap:Local Loopback
           inet addr:127.0.0.1  Mask:255.0.0.0
           inet6 addr: ::1/128 Scope:Host
           UP LOOPBACK RUNNING  MTU:16436  Metric:1
           RX packets:16 errors:0 dropped:0 overruns:0 frame:0
           TX packets:16 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:0
           RX bytes:880 (880.0 b)  TX bytes:880 (880.0 b)

[root@localhost ~]# ifconfig eth6 down
[root@localhost ~]# ifconfig eth7 down
[root@localhost ~]# ifconfig eth8 down
[root@localhost ~]# ifconfig eth9 down
[root@localhost ~]# ip route show
[root@localhost ~]# ip neigh show
[root@localhost ~]# ifconfig
lo        Link encap:Local Loopback
           inet addr:127.0.0.1  Mask:255.0.0.0
           inet6 addr: ::1/128 Scope:Host
           UP LOOPBACK RUNNING  MTU:16436  Metric:1
           RX packets:16 errors:0 dropped:0 overruns:0 frame:0
           TX packets:16 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:0
           RX bytes:880 (880.0 b)  TX bytes:880 (880.0 b)

[root@localhost ~]# dmesg -c &> /dev/null
[root@localhost ~]# modprobe bonding mode=3D0 miimon=3D100
[root@localhost ~]# ifconfig bond0 192.168.1.5 netmask 255.255.255.0 up
[root@localhost ~]# ifenslave bond0 eth6
[root@localhost ~]# ifenslave bond0 eth7
[root@localhost ~]# dmesg
[  164.865840] bonding: Ethernet Channel Bonding Driver: v3.6.0=20
(September 26, 2009)
[  164.865845] bonding: MII link monitoring set to 100 ms
[  181.186201] ADDRCONF(NETDEV_UP): bond0: link is not ready
[  191.549252] bonding: bond0: enslaving eth6 as an active interface=20
with a down link.
[  191.552653] e1000: eth6 NIC Link is Up 1000 Mbps Full Duplex, Flow=20
Control: RX
[  191.586166] bonding: bond0: link status definitely up for interface =
eth6.
[  191.586315] ADDRCONF(NETDEV_CHANGE): bond0: link becomes ready
[  193.420974] e1000: eth7 NIC Link is Up 1000 Mbps Full Duplex, Flow=20
Control: RX
[  193.434907] bonding: bond0: enslaving eth7 as an active interface=20
with an up link.

[root@localhost ~]# ifconfig
bond0     Link encap:Ethernet  HWaddr 08:00:27:78:F6:41
           inet addr:192.168.1.5  Bcast:192.168.1.255  Mask:255.255.255=
=2E0
           inet6 addr: fe80::a00:27ff:fe78:f641/64 Scope:Link
           UP BROADCAST RUNNING MASTER MULTICAST  MTU:1500  Metric:1
           RX packets:95 errors:0 dropped:0 overruns:0 frame:0
           TX packets:26 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:0
           RX bytes:13415 (13.1 KiB)  TX bytes:4140 (4.0 KiB)

eth6      Link encap:Ethernet  HWaddr 08:00:27:78:F6:41
           inet addr:10.66.65.128  Bcast:10.66.65.255  Mask:255.255.254=
=2E0
           UP BROADCAST RUNNING SLAVE MULTICAST  MTU:1500  Metric:1
           RX packets:48 errors:0 dropped:0 overruns:0 frame:0
           TX packets:13 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:1000
           RX bytes:7464 (7.2 KiB)  TX bytes:1822 (1.7 KiB)

eth7      Link encap:Ethernet  HWaddr 08:00:27:78:F6:41
           UP BROADCAST RUNNING SLAVE MULTICAST  MTU:1500  Metric:1
           RX packets:47 errors:0 dropped:0 overruns:0 frame:0
           TX packets:13 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:1000
           RX bytes:5951 (5.8 KiB)  TX bytes:2318 (2.2 KiB)

lo        Link encap:Local Loopback
           inet addr:127.0.0.1  Mask:255.0.0.0
           inet6 addr: ::1/128 Scope:Host
           UP LOOPBACK RUNNING  MTU:16436  Metric:1
           RX packets:16 errors:0 dropped:0 overruns:0 frame:0
           TX packets:16 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:0
           RX bytes:880 (880.0 b)  TX bytes:880 (880.0 b)

[root@localhost ~]# ping 192.168.1.100 -c 5
PING 192.168.1.100 (192.168.1.100) 56(84) bytes of data.
64 bytes from 192.168.1.100: icmp_req=3D1 ttl=3D64 time=3D1.98 ms
64 bytes from 192.168.1.100: icmp_req=3D2 ttl=3D64 time=3D0.955 ms
64 bytes from 192.168.1.100: icmp_req=3D3 ttl=3D64 time=3D0.209 ms
64 bytes from 192.168.1.100: icmp_req=3D4 ttl=3D64 time=3D0.277 ms
64 bytes from 192.168.1.100: icmp_req=3D5 ttl=3D64 time=3D0.289 ms

--- 192.168.1.100 ping statistics ---
5 packets transmitted, 5 received, 0% packet loss, time 4002ms
rtt min/avg/max/mdev =3D 0.209/0.742/1.984/0.678 ms

[root@localhost ~]# ip route show
192.168.1.0/24 dev bond0  proto kernel  scope link  src 192.168.1.5
10.66.64.0/23 dev eth6  proto kernel  scope link  src 10.66.65.128 =20
metric 1
default via 10.66.65.254 dev eth6  proto static
[root@localhost ~]# ip neigh show
192.168.1.100 dev bond0 lladdr 64:31:50:3a:b0:b5 STALE


And on host,
[root@localhost ~]# VBoxManage controlvm=20
67b83c47-0ee2-46bc-b0ff-e0eb43edc1c2 setlinkstate2 off

Then on guest,
[root@localhost ~]# ethtool eth6
Settings for eth6:
         Supported ports: [ TP ]
         Supported link modes:   10baseT/Half 10baseT/Full
                                 100baseT/Half 100baseT/Full
                                 1000baseT/Full
         Supports auto-negotiation: Yes
         Advertised link modes:  10baseT/Half 10baseT/Full
                                 100baseT/Half 100baseT/Full
                                 1000baseT/Full
         Advertised pause frame use: No
         Advertised auto-negotiation: Yes
         Speed: Unknown!
         Duplex: Unknown! (255)
         Port: Twisted Pair
         PHYAD: 0
         Transceiver: internal
         Auto-negotiation: on
         MDI-X: Unknown
         Supports Wake-on: umbg
         Wake-on: d
         Current message level: 0x00000007 (7)
         Link detected: no

[root@localhost ~]# dmesg
[  164.865840] bonding: Ethernet Channel Bonding Driver: v3.6.0=20
(September 26, 2009)
[  164.865845] bonding: MII link monitoring set to 100 ms
[  181.186201] ADDRCONF(NETDEV_UP): bond0: link is not ready
[  191.549252] bonding: bond0: enslaving eth6 as an active interface=20
with a down link.
[  191.552653] e1000: eth6 NIC Link is Up 1000 Mbps Full Duplex, Flow=20
Control: RX
[  191.586166] bonding: bond0: link status definitely up for interface =
eth6.
[  191.586315] ADDRCONF(NETDEV_CHANGE): bond0: link becomes ready
[  193.420974] e1000: eth7 NIC Link is Up 1000 Mbps Full Duplex, Flow=20
Control: RX
[  193.434907] bonding: bond0: enslaving eth7 as an active interface=20
with an up link.
[  202.018085] bond0: no IPv6 routers present
[  238.834001] e1000: eth7 NIC Link is Up 1000 Mbps Full Duplex, Flow=20
Control: RX
[  434.010205] e1000: eth6 NIC Link is Down
[  434.011661] bonding: bond0: link status definitely down for interfac=
e=20
eth6, disabling it

[root@localhost ~]# ping 192.168.1.100 -c 5
PING 192.168.1.100 (192.168.1.100) 56(84) bytes of data.
 From 192.168.1.5 icmp_seq=3D2 Destination Host Unreachable
 From 192.168.1.5 icmp_seq=3D3 Destination Host Unreachable
 From 192.168.1.5 icmp_seq=3D4 Destination Host Unreachable
 From 192.168.1.5 icmp_seq=3D5 Destination Host Unreachable

--- 192.168.1.100 ping statistics ---
5 packets transmitted, 0 received, +4 errors, 100% packet loss, time 40=
01ms
pipe 3

[root@localhost ~]# ip route show
192.168.1.0/24 dev bond0  proto kernel  scope link  src 192.168.1.5
[root@localhost ~]# ip neigh show
192.168.1.100 dev bond0  FAILED

ping on the guest while tcpdump on the host,
on guest:
[root@localhost ~]# ping 192.168.1.100
PING 192.168.1.100 (192.168.1.100) 56(84) bytes of data.
 From 192.168.1.5 icmp_seq=3D2 Destination Host Unreachable
 From 192.168.1.5 icmp_seq=3D3 Destination Host Unreachable
 From 192.168.1.5 icmp_seq=3D4 Destination Host Unreachable
 From 192.168.1.5 icmp_seq=3D6 Destination Host Unreachable
 From 192.168.1.5 icmp_seq=3D7 Destination Host Unreachable
 From 192.168.1.5 icmp_seq=3D8 Destination Host Unreachable
 From 192.168.1.5 icmp_seq=3D10 Destination Host Unreachable
 From 192.168.1.5 icmp_seq=3D11 Destination Host Unreachable
 From 192.168.1.5 icmp_seq=3D12 Destination Host Unreachable
 From 192.168.1.5 icmp_seq=3D14 Destination Host Unreachable
 From 192.168.1.5 icmp_seq=3D15 Destination Host Unreachable
 From 192.168.1.5 icmp_seq=3D16 Destination Host Unreachable
 From 192.168.1.5 icmp_seq=3D18 Destination Host Unreachable
 From 192.168.1.5 icmp_seq=3D19 Destination Host Unreachable
 From 192.168.1.5 icmp_seq=3D20 Destination Host Unreachable
^C
--- 192.168.1.100 ping statistics ---
21 packets transmitted, 0 received, +15 errors, 100% packet loss, time=20
20005ms
pipe 3

on host:
[root@localhost ~]# tcpdump -i eth0 -p arp
tcpdump: verbose output suppressed, use -v or -vv for full protocol dec=
ode
listening on eth0, link-type EN10MB (Ethernet), capture size 65535 byte=
s
11:00:50.474242 ARP, Request who-has 192.168.1.100 tell 192.168.1.5,=20
length 28
11:00:50.474256 ARP, Request who-has 192.168.1.100 tell 192.168.1.5,=20
length 28
11:00:52.469651 ARP, Request who-has 192.168.1.100 tell 192.168.1.5,=20
length 28
11:00:52.469661 ARP, Request who-has 192.168.1.100 tell 192.168.1.5,=20
length 28
11:00:52.632719 ARP, Request who-has dhcp-65-29.nay.redhat.com tell=20
corerouter.nay.redhat.com, length 46
11:00:53.192150 ARP, Request who-has dhcp-65-14.nay.redhat.com tell=20
corerouter.nay.redhat.com, length 46
11:00:53.471246 ARP, Request who-has 192.168.1.100 tell 192.168.1.5,=20
length 28
11:00:53.471257 ARP, Request who-has 192.168.1.100 tell 192.168.1.5,=20
length 28
11:00:54.474627 ARP, Request who-has 192.168.1.100 tell 192.168.1.5,=20
length 28
11:00:54.474636 ARP, Request who-has 192.168.1.100 tell 192.168.1.5,=20
length 28
11:00:56.472050 ARP, Request who-has 192.168.1.100 tell 192.168.1.5,=20
length 28
11:00:56.472060 ARP, Request who-has 192.168.1.100 tell 192.168.1.5,=20
length 28
11:00:57.475211 ARP, Request who-has 192.168.1.100 tell 192.168.1.5,=20
length 28
11:00:57.475220 ARP, Request who-has 192.168.1.100 tell 192.168.1.5,=20
length 28
11:00:58.476840 ARP, Request who-has 192.168.1.100 tell 192.168.1.5,=20
length 28
11:00:58.476849 ARP, Request who-has 192.168.1.100 tell 192.168.1.5,=20
length 28
11:00:58.624738 ARP, Request who-has dhcp-65-29.nay.redhat.com tell=20
corerouter.nay.redhat.com, length 46
11:01:00.477029 ARP, Request who-has 192.168.1.100 tell 192.168.1.5,=20
length 28
11:01:00.477038 ARP, Request who-has 192.168.1.100 tell 192.168.1.5,=20
length 28
^C
19 packets captured
19 packets received by filter
0 packets dropped by kernel
[root@localhost ~]# ip neigh show
192.168.1.5 dev eth0 lladdr 08:00:27:78:f6:41 STALE
10.66.65.254 dev eth0 lladdr 00:1d:45:20:d5:ff REACHABLE


regards
Weiping Pan
