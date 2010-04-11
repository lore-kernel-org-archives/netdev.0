From: Denys Fedorysychenko <nuclearcat@nuclearcat.com>
Subject: Re: NULL pointer dereference panic in stable (2.6.33.2), amd64
Date: Mon, 12 Apr 2010 02:36:25 +0300
Message-ID: <201004120236.25292.nuclearcat@nuclearcat.com>
References: <201004112338.47019.nuclearcat@nuclearcat.com> <201004120204.11405.nuclearcat@nuclearcat.com> <1271027483.2078.158.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Krishna Kumar <krkumar2@in.ibm.com>,
	David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:56147 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753092Ab0DKXiK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Apr 2010 19:38:10 -0400
In-Reply-To: <1271027483.2078.158.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 12 April 2010 02:11:23 Eric Dumazet wrote:
> Le lundi 12 avril 2010 =C3=A0 02:04 +0300, Denys Fedorysychenko a =C3=
=A9crit :
> > > It is IMHO not safe, because route for this socket might have jus=
t
> > > changed and we are transmitting an old packet (queued some milli
> > > seconds before, when route was different).
> > >
> > > We then memorize a queue_index that might be too big for the new =
device
> > > of new selected route.
> > >
> > > Next packet we want to transmit will take the cached value of
> > > queue_index, correct for old device, maybe not correct for new de=
vice.
> >
> > Yes, it is possible, i have there RIP with 1k+ routes, changing non=
-stop.
> >
> > > You could try to revert commit a4ee3ce3293dc931fab19beb472a8bde12=
95aebe
> > >
> > > commit a4ee3ce3293dc931fab19beb472a8bde1295aebe
> >
> > I will try to revert it now. But to trigger bug probably i need 1-2=
 days.
>=20
> I can try to reproduce bug here, with a multiqueue device, a non
> multiqueue device, and changing routes while transmitting bulk of
> packets, and of course some trafic shaping to slow down xmits.
>=20
> Could you send :
>=20
> ifconfig -a
> lspci
A bit more even, hopefully it is useful.
Additional note - i have few blackhole routes, so if specific route ann=
ounce=20
will disappear - it will be less specific blackhole route.

I have also some source routing (ip rule).


lspci

00:00.0 Host bridge: Intel Corporation 5000P Chipset Memory Controller =
Hub=20
(rev b1)
00:02.0 PCI bridge: Intel Corporation 5000 Series Chipset PCI Express x=
4 Port=20
2 (rev b1)
00:03.0 PCI bridge: Intel Corporation 5000 Series Chipset PCI Express x=
4 Port=20
3 (rev b1)
00:04.0 PCI bridge: Intel Corporation 5000 Series Chipset PCI Express x=
8 Port=20
4-5 (rev b1)
00:05.0 PCI bridge: Intel Corporation 5000 Series Chipset PCI Express x=
4 Port=20
5 (rev b1)
00:06.0 PCI bridge: Intel Corporation 5000 Series Chipset PCI Express x=
8 Port=20
6-7 (rev b1)
00:07.0 PCI bridge: Intel Corporation 5000 Series Chipset PCI Express x=
4 Port=20
7 (rev b1)
00:10.0 Host bridge: Intel Corporation 5000 Series Chipset FSB Register=
s (rev=20
b1)
00:10.1 Host bridge: Intel Corporation 5000 Series Chipset FSB Register=
s (rev=20
b1)
00:10.2 Host bridge: Intel Corporation 5000 Series Chipset FSB Register=
s (rev=20
b1)
00:11.0 Host bridge: Intel Corporation 5000 Series Chipset Reserved Reg=
isters=20
(rev b1)
00:13.0 Host bridge: Intel Corporation 5000 Series Chipset Reserved Reg=
isters=20
(rev b1)
00:15.0 Host bridge: Intel Corporation 5000 Series Chipset FBD Register=
s (rev=20
b1)
00:16.0 Host bridge: Intel Corporation 5000 Series Chipset FBD Register=
s (rev=20
b1)
00:1c.0 PCI bridge: Intel Corporation 631xESB/632xESB/3100 Chipset PCI =
Express=20
Root Port 1 (rev 09)
00:1d.0 USB Controller: Intel Corporation 631xESB/632xESB/3100 Chipset =
UHCI=20
USB Controller #1 (rev 09)
00:1d.1 USB Controller: Intel Corporation 631xESB/632xESB/3100 Chipset =
UHCI=20
USB Controller #2 (rev 09)
00:1d.2 USB Controller: Intel Corporation 631xESB/632xESB/3100 Chipset =
UHCI=20
USB Controller #3 (rev 09)
00:1d.3 USB Controller: Intel Corporation 631xESB/632xESB/3100 Chipset =
UHCI=20
USB Controller #4 (rev 09)
00:1d.7 USB Controller: Intel Corporation 631xESB/632xESB/3100 Chipset =
EHCI=20
USB2 Controller (rev 09)
00:1e.0 PCI bridge: Intel Corporation 82801 PCI Bridge (rev d9)
00:1f.0 ISA bridge: Intel Corporation 631xESB/632xESB/3100 Chipset LPC=20
Interface Controller (rev 09)
00:1f.1 IDE interface: Intel Corporation 631xESB/632xESB IDE Controller=
 (rev=20
09)
00:1f.2 SATA controller: Intel Corporation 631xESB/632xESB SATA AHCI=20
Controller (rev 09)
00:1f.3 SMBus: Intel Corporation 631xESB/632xESB/3100 Chipset SMBus Con=
troller=20
(rev 09)
01:00.0 PCI bridge: Intel Corporation 6311ESB/6321ESB PCI Express Upstr=
eam=20
Port (rev 01)
01:00.3 PCI bridge: Intel Corporation 6311ESB/6321ESB PCI Express to PC=
I-X=20
Bridge (rev 01)
02:00.0 PCI bridge: Intel Corporation 6311ESB/6321ESB PCI Express Downs=
tream=20
Port E1 (rev 01)
02:02.0 PCI bridge: Intel Corporation 6311ESB/6321ESB PCI Express Downs=
tream=20
Port E3 (rev 01)
04:00.0 Ethernet controller: Intel Corporation 80003ES2LAN Gigabit Ethe=
rnet=20
Controller (Copper) (rev 01)
04:00.1 Ethernet controller: Intel Corporation 80003ES2LAN Gigabit Ethe=
rnet=20
Controller (Copper) (rev 01)
07:00.0 RAID bus controller: Adaptec AAC-RAID (rev 09)
0b:00.0 Ethernet controller: Intel Corporation 82571EB Gigabit Ethernet=
=20
Controller (rev 06)
0b:00.1 Ethernet controller: Intel Corporation 82571EB Gigabit Ethernet=
=20
Controller (rev 06)
0c:05.0 VGA compatible controller: ASPEED Technology, Inc. AST2000

eth0      Link encap:Ethernet  HWaddr 00:1E:68:57:4B:CC                =
                                                                       =
                                  =20
          inet addr:194.146.153.17  Bcast:0.0.0.0  Mask:255.255.255.224=
                                                                       =
                                  =20
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1           =
                                                                       =
                                  =20
          RX packets:1047262147 errors:0 dropped:0 overruns:0 frame:0  =
                                                                       =
                                  =20
          TX packets:1017399476 errors:0 dropped:0 overruns:0 carrier:0=
                                                                       =
                                  =20
          collisions:0 txqueuelen:1000                                 =
                                                                       =
                                  =20
          RX bytes:698944316059 (650.9 GiB)  TX bytes:694648889407 (646=
=2E9 GiB)                                                              =
                                    =20
          Memory:fc6e0000-fc700000                                     =
                                                                       =
                                  =20
                                                                       =
                                                                       =
                                  =20
eth0.165  Link encap:Ethernet  HWaddr 00:1E:68:57:4B:CC                =
                                                                       =
                                  =20
          inet addr:172.30.1.2  Bcast:0.0.0.0  Mask:255.255.255.0      =
                                                                       =
                                  =20
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1           =
                                                                       =
                                  =20
          RX packets:5375126 errors:0 dropped:0 overruns:0 frame:0     =
                                                                       =
                                  =20
          TX packets:3446299 errors:0 dropped:2 overruns:0 carrier:0   =
                                                                       =
                                  =20
          collisions:0 txqueuelen:0                                    =
                                                                       =
                                  =20
          RX bytes:1910233297 (1.7 GiB)  TX bytes:814740452 (776.9 MiB)=
                                                                       =
                                  =20
                                                                       =
                                                                       =
                                  =20
eth0.32   Link encap:Ethernet  HWaddr 00:1E:68:57:4B:CC                =
                                                                       =
                                  =20
          inet addr:10.22.22.2  Bcast:0.0.0.0  Mask:255.255.255.0      =
                                                                       =
                                  =20
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1           =
                                                                       =
                                  =20
          RX packets:96167917 errors:0 dropped:0 overruns:0 frame:0    =
                                                                       =
                                  =20
          TX packets:166845841 errors:0 dropped:2 overruns:0 carrier:0 =
                                                                       =
                                  =20
          collisions:0 txqueuelen:0                                    =
                                                                       =
                                  =20
          RX bytes:14589314556 (13.5 GiB)  TX bytes:126771970521 (118.0=
 GiB)                                                                  =
                                  =20
                                                                       =
                                                                       =
                                  =20
eth0.33   Link encap:Ethernet  HWaddr 00:1E:68:57:4B:CC                =
                                                                       =
                                  =20
          inet addr:10.152.152.2  Bcast:0.0.0.0  Mask:255.255.255.248  =
                                                                       =
                                  =20
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1           =
                                                                       =
                                  =20
          RX packets:10171808 errors:0 dropped:0 overruns:0 frame:0    =
                                                                       =
                                  =20
          TX packets:130698572 errors:0 dropped:0 overruns:0 carrier:0 =
                                                                       =
                                  =20
          collisions:0 txqueuelen:0                                    =
                                                                       =
                                  =20
          RX bytes:2690522850 (2.5 GiB)  TX bytes:25223310290 (23.4 GiB=
)                                                                      =
                                  =20
                                                                       =
                                                                       =
                                  =20
eth0.34   Link encap:Ethernet  HWaddr 00:1E:68:57:4B:CC                =
                                                                       =
                                  =20
          inet addr:10.25.25.1  Bcast:0.0.0.0  Mask:255.255.255.0      =
                                                                       =
                                  =20
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1           =
                                                                       =
                                  =20
          RX packets:133415723 errors:0 dropped:0 overruns:0 frame:0   =
                                                                       =
                                  =20
          TX packets:1352 errors:0 dropped:1 overruns:0 carrier:0      =
                                                                       =
                                  =20
          collisions:0 txqueuelen:0                                    =
                                                                       =
                                  =20
          RX bytes:140007983122 (130.3 GiB)  TX bytes:117870 (115.1 KiB=
)                                                                      =
                                  =20
                                                                       =
                                                                       =
                                  =20
eth0.35   Link encap:Ethernet  HWaddr 00:1E:68:57:4B:CC                =
                                                                       =
                                  =20
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1           =
                                                                       =
                                  =20
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0           =
                                                                       =
                                  =20
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0         =
                                                                       =
                                  =20
          collisions:0 txqueuelen:0                                    =
                                                                       =
                                  =20
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)                       =
                                                                       =
                                  =20
                                                                       =
                                                                       =
                                  =20
eth0.36   Link encap:Ethernet  HWaddr 00:1E:68:57:4B:CC                =
                                                                       =
                                  =20
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1           =
                                                                       =
                                  =20
          RX packets:1474 errors:0 dropped:0 overruns:0 frame:0        =
                                                                       =
                                  =20
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0         =
                                                                       =
                                  =20
          collisions:0 txqueuelen:0                                    =
                                                                       =
                                  =20
          RX bytes:125741 (122.7 KiB)  TX bytes:0 (0.0 B)              =
                                                                       =
                                  =20
                                                                       =
                                                                       =
                                  =20
eth0.38   Link encap:Ethernet  HWaddr 00:1E:68:57:4B:CC                =
                                                                       =
                                  =20
          inet addr:10.0.4.1  Bcast:0.0.0.0  Mask:255.255.255.248      =
                                                                       =
                                  =20
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1           =
                                                                       =
                                  =20
          RX packets:674 errors:0 dropped:0 overruns:0 frame:0         =
                                                                       =
                                  =20
          TX packets:188760217 errors:0 dropped:0 overruns:0 carrier:0 =
                                                                       =
                                  =20
          collisions:0 txqueuelen:0                                    =
                                                                       =
                                  =20
          RX bytes:31004 (30.2 KiB)  TX bytes:212060676669 (197.4 GiB) =
                                                                       =
                                  =20
                                                                       =
                                                                       =
                                  =20
eth0.39   Link encap:Ethernet  HWaddr 00:1E:68:57:4B:CC                =
                                                                       =
                                  =20
          inet addr:10.22.24.1  Bcast:0.0.0.0  Mask:255.255.255.0      =
                                                                       =
                                  =20
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1           =
                                                                       =
                                  =20
          RX packets:270892875 errors:0 dropped:0 overruns:0 frame:0   =
                                                                       =
                                  =20
          TX packets:309713487 errors:0 dropped:3 overruns:0 carrier:0 =
                                                                       =
                                  =20
          collisions:0 txqueuelen:0                                    =
                                                                       =
                                  =20
          RX bytes:77224626928 (71.9 GiB)  TX bytes:215883462565 (201.0=
 GiB)                                                                  =
                                  =20
                                                                       =
                                                                       =
                                  =20
eth0.40   Link encap:Ethernet  HWaddr 00:1E:68:57:4B:CC                =
                                                                       =
                                  =20
          inet addr:62.84.94.13  Bcast:0.0.0.0  Mask:255.255.255.248   =
                                                                       =
                                  =20
          BROADCAST MULTICAST  MTU:1500  Metric:1                      =
                                                                       =
                                  =20
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0           =
                                                                       =
                                  =20
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0         =
                                                                       =
                                  =20
          collisions:0 txqueuelen:0                                    =
                                                                       =
                                  =20
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)                       =
                                                                       =
                                  =20
                                                                       =
                                                                       =
                                  =20
eth0.41   Link encap:Ethernet  HWaddr 00:1E:68:57:4B:CC                =
                                                                       =
                                  =20
          inet addr:2.2.3.1  Bcast:0.0.0.0  Mask:255.255.255.128       =
                                                                       =
                                  =20
          BROADCAST MULTICAST  MTU:1500  Metric:1                      =
                                                                       =
                                  =20
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0           =
                                                                       =
                                  =20
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0         =
                                                                       =
                                  =20
          collisions:0 txqueuelen:0                                    =
                                                                       =
                                  =20
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)                       =
                                                                       =
                                  =20
                                                                       =
                                                                       =
                                  =20
eth1      Link encap:Ethernet  HWaddr 00:1E:68:57:4B:CD                =
                                                                       =
                                  =20
          UP BROADCAST RUNNING PROMISC MULTICAST  MTU:1500  Metric:1   =
                                                                       =
                                  =20
          RX packets:949912 errors:0 dropped:0 overruns:0 frame:0      =
                                                                       =
                                  =20
          TX packets:192 errors:0 dropped:0 overruns:0 carrier:0       =
                                                                       =
                                  =20
          collisions:0 txqueuelen:1000                                 =
                                                                       =
                                  =20
          RX bytes:429565276 (409.6 MiB)  TX bytes:8064 (7.8 KiB)      =
                                                                       =
                                  =20
          Memory:fc6c0000-fc6e0000                                     =
                                                                       =
                                  =20
                                                                       =
                                                                       =
                                  =20
eth1.2    Link encap:Ethernet  HWaddr 00:1C:C0:19:23:80                =
                                                                       =
                                  =20
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1           =
                                                                       =
                                  =20
          RX packets:5462 errors:0 dropped:0 overruns:0 frame:0        =
                                                                       =
                                  =20
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0         =
                                                                       =
                                  =20
          collisions:0 txqueuelen:0                                    =
                                                                       =
                                  =20
          RX bytes:273100 (266.6 KiB)  TX bytes:0 (0.0 B)              =
                                                                       =
                                  =20
                                                                       =
                                                                       =
                                  =20
eth1.3    Link encap:Ethernet  HWaddr 00:1E:68:57:4B:CD                =
                                                                       =
                                  =20
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1           =
                                                                       =
                                  =20
          RX packets:5462 errors:0 dropped:0 overruns:0 frame:0        =
                                                                       =
                                  =20
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0         =
                                                                       =
                                  =20
          collisions:0 txqueuelen:0                                    =
                                                                       =
                                  =20
          RX bytes:273100 (266.6 KiB)  TX bytes:0 (0.0 B)              =
                                                                       =
                                  =20
                                                                       =
                                                                       =
                                  =20
eth1.4    Link encap:Ethernet  HWaddr 00:1E:68:57:4B:CD                =
                                                                       =
                                  =20
          inet addr:10.154.154.2  Bcast:0.0.0.0  Mask:255.255.255.0    =
                                                                       =
                                  =20
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1           =
                                                                       =
                                  =20
          RX packets:5461 errors:0 dropped:0 overruns:0 frame:0        =
                                                                       =
                                  =20
          TX packets:192 errors:0 dropped:0 overruns:0 carrier:0       =
                                                                       =
                                  =20
          collisions:0 txqueuelen:0                                    =
                                                                       =
                                  =20
          RX bytes:273050 (266.6 KiB)  TX bytes:8064 (7.8 KiB)         =
                                                                       =
                                  =20
                                                                       =
                                                                       =
                                  =20
eth2      Link encap:Ethernet  HWaddr 00:1E:68:57:4B:CE                =
                                                                       =
                                  =20
          BROADCAST MULTICAST  MTU:1500  Metric:1                      =
                                                                       =
                                  =20
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0           =
                                                                       =
                                  =20
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0         =
                                                                       =
                                  =20
          collisions:0 txqueuelen:1000                                 =
                                                                       =
                                  =20
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)                       =
                                                                       =
                                  =20
          Memory:fcde0000-fce00000                                     =
                                                                       =
                                  =20
                                                                       =
                                                                       =
                                  =20
eth3      Link encap:Ethernet  HWaddr 00:1E:68:57:4B:CF                =
                                                                       =
                                  =20
          BROADCAST MULTICAST  MTU:1500  Metric:1                      =
                                                                       =
                                  =20
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0           =
                                                                       =
                                  =20
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0         =
                                                                       =
                                  =20
          collisions:0 txqueuelen:1000                                 =
                                                                       =
                                  =20
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)                       =
                                                                       =
                                  =20
          Memory:fcd80000-fcda0000                                     =
                                                                       =
                                  =20
                                                                       =
                                                                       =
                                  =20
ifb0      Link encap:Ethernet  HWaddr 6A:73:52:ED:4A:D6                =
                                                                       =
                                  =20
          UP BROADCAST RUNNING NOARP  MTU:1500  Metric:1               =
                                                                       =
                                  =20
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:32
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)

ifb1      Link encap:Ethernet  HWaddr C2:97:7A:32:8B:59
          UP BROADCAST RUNNING NOARP  MTU:1500  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:32
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)

ifb2      Link encap:Ethernet  HWaddr 96:AC:DD:0D:68:B0
          UP BROADCAST RUNNING NOARP  MTU:1500  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:32
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)

ifb3      Link encap:Ethernet  HWaddr FA:D9:59:C6:16:E7
          UP BROADCAST RUNNING NOARP  MTU:1500  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:32
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)

lo        Link encap:Local Loopback
          inet addr:127.0.0.1  Mask:255.0.0.0
          UP LOOPBACK RUNNING  MTU:16436  Metric:1
          RX packets:3192 errors:0 dropped:0 overruns:0 frame:0
          TX packets:3192 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:222919 (217.6 KiB)  TX bytes:222919 (217.6 KiB)

tunx0     Link encap:UNSPEC  HWaddr=20
00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00
          inet addr:1.1.1.2  P-t-P:1.1.1.2  Mask:255.255.255.255
          UP POINTOPOINT RUNNING  MTU:1500  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:12531732 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1024
          RX bytes:0 (0.0 B)  TX bytes:1888404300 (1.7 GiB)

Router-Dora ~ # tc -d qdisc
qdisc hfsc 1: dev eth0 root refcnt 2
qdisc bfifo 101: dev eth0 parent 1:101 limit 12500000b
qdisc bfifo 111: dev eth0 parent 1:111 limit 3125Kb
qdisc bfifo 112: dev eth0 parent 1:112 limit 3125Kb
qdisc pfifo_fast 0: dev eth1 root refcnt 2 bands 3 priomap  1 2 2 2 1 2=
 0 0 1=20
1 1 1 1 1 1 1
qdisc hfsc 1: dev eth0.33 root refcnt 2
 linklayer ethernet overhead 4 mpu 64 mtu 1500 tsize 1436
qdisc bfifo 110: dev eth0.33 parent 1:110 limit 3000000b
qdisc bfifo 120: dev eth0.33 parent 1:120 limit 100000b
qdisc bfifo 130: dev eth0.33 parent 1:130 limit 100000b
qdisc bfifo 140: dev eth0.33 parent 1:140 limit 100000b
qdisc bfifo 150: dev eth0.33 parent 1:150 limit 1000000b
qdisc bfifo 160: dev eth0.33 parent 1:160 limit 100000b
qdisc bfifo 170: dev eth0.33 parent 1:170 limit 100000b
qdisc bfifo 180: dev eth0.33 parent 1:180 limit 100000b
qdisc bfifo 190: dev eth0.33 parent 1:190 limit 100000b
qdisc hfsc 1: dev eth0.38 root refcnt 2
 linklayer ethernet overhead 4 mpu 64 mtu 2047 tsize 512
qdisc bfifo 3: dev eth0.38 parent 1:3 limit 5000000b
qdisc bfifo 4: dev eth0.38 parent 1:4 limit 5000000b
qdisc hfsc 1: dev eth0.39 root refcnt 2
 linklayer ethernet overhead 4 mpu 64 mtu 2047 tsize 512
qdisc bfifo 3: dev eth0.39 parent 1:3 limit 3000000b
qdisc bfifo 20: dev eth0.39 parent 1:20 limit 20000000b
qdisc bfifo 31: dev eth0.39 parent 1:31 limit 1000000b
qdisc bfifo 30: dev eth0.39 parent 1:30 limit 5000000b
qdisc ingress ffff: dev eth1.3 parent ffff:fff1 ----------------
qdisc pfifo_fast 0: dev ifb0 root refcnt 2 bands 3 priomap  1 2 2 2 1 2=
 0 0 1=20
1 1 1 1 1 1 1
qdisc pfifo_fast 0: dev ifb1 root refcnt 2 bands 3 priomap  1 2 2 2 1 2=
 0 0 1=20
1 1 1 1 1 1 1
qdisc pfifo_fast 0: dev ifb2 root refcnt 2 bands 3 priomap  1 2 2 2 1 2=
 0 0 1=20
1 1 1 1 1 1 1
qdisc pfifo_fast 0: dev ifb3 root refcnt 2 bands 3 priomap  1 2 2 2 1 2=
 0 0 1=20
1 1 1 1 1 1 1
qdisc pfifo_fast 0: dev tunx0 root refcnt 2 bands 3 priomap  1 2 2 2 1 =
2 0 0 1=20
1 1 1 1 1 1 1


Router-Dora ~ # ip link                                                =
                                                                       =
                                  =20
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 16436 qdisc noqueue state UNKNOWN    =
                                                                       =
                                  =20
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00              =
                                                                       =
                                  =20
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc hfsc state UP=
 qlen=20
1000                                                                   =
                            =20
    link/ether 00:1e:68:57:4b:cc brd ff:ff:ff:ff:ff:ff                 =
                                                                       =
                                  =20
3: eth1: <BROADCAST,MULTICAST,PROMISC,UP,LOWER_UP> mtu 1500 qdisc pfifo=
_fast=20
state UP qlen 1000
    link/ether 00:1e:68:57:4b:cd brd ff:ff:ff:ff:ff:ff
4: eth2: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN qlen 1000
    link/ether 00:1e:68:57:4b:ce brd ff:ff:ff:ff:ff:ff
5: eth3: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN qlen 1000
    link/ether 00:1e:68:57:4b:cf brd ff:ff:ff:ff:ff:ff
6: eth0.32@eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noque=
ue=20
state UP
    link/ether 00:1e:68:57:4b:cc brd ff:ff:ff:ff:ff:ff
7: eth0.33@eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc hfsc =
state=20
UP
    link/ether 00:1e:68:57:4b:cc brd ff:ff:ff:ff:ff:ff
8: eth0.34@eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noque=
ue=20
state UP
    link/ether 00:1e:68:57:4b:cc brd ff:ff:ff:ff:ff:ff
9: eth0.35@eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noque=
ue=20
state UP
    link/ether 00:1e:68:57:4b:cc brd ff:ff:ff:ff:ff:ff
10: eth0.36@eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqu=
eue=20
state UP
    link/ether 00:1e:68:57:4b:cc brd ff:ff:ff:ff:ff:ff
11: eth0.38@eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc hfsc=
 state=20
UP
    link/ether 00:1e:68:57:4b:cc brd ff:ff:ff:ff:ff:ff
12: eth0.39@eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc hfsc=
 state=20
UP
    link/ether 00:1e:68:57:4b:cc brd ff:ff:ff:ff:ff:ff
13: eth0.40@eth0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN
    link/ether 00:1e:68:57:4b:cc brd ff:ff:ff:ff:ff:ff
14: eth0.41@eth0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN
    link/ether 00:1e:68:57:4b:cc brd ff:ff:ff:ff:ff:ff
15: eth0.165@eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noq=
ueue=20
state UP
    link/ether 00:1e:68:57:4b:cc brd ff:ff:ff:ff:ff:ff
16: eth1.2@eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noque=
ue=20
state UP
    link/ether 00:1c:c0:19:23:80 brd ff:ff:ff:ff:ff:ff
17: eth1.3@eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noque=
ue=20
state UP
    link/ether 00:1e:68:57:4b:cd brd ff:ff:ff:ff:ff:ff
18: eth1.4@eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noque=
ue=20
state UP
    link/ether 00:1e:68:57:4b:cd brd ff:ff:ff:ff:ff:ff
19: ifb0: <BROADCAST,NOARP,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state=
=20
UNKNOWN qlen 32
    link/ether 6a:73:52:ed:4a:d6 brd ff:ff:ff:ff:ff:ff
20: ifb1: <BROADCAST,NOARP,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state=
=20
UNKNOWN qlen 32
    link/ether c2:97:7a:32:8b:59 brd ff:ff:ff:ff:ff:ff
21: ifb2: <BROADCAST,NOARP,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state=
=20
UNKNOWN qlen 32
    link/ether 96:ac:dd:0d:68:b0 brd ff:ff:ff:ff:ff:ff
22: ifb3: <BROADCAST,NOARP,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state=
=20
UNKNOWN qlen 32
    link/ether fa:d9:59:c6:16:e7 brd ff:ff:ff:ff:ff:ff
23: tunx0: <POINTOPOINT,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UN=
KNOWN=20
qlen 1024
    link/[65534]





>=20
> Thanks
>=20
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20
