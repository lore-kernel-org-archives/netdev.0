From: Jan Engelhardt <jengelh@inai.de>
Subject: niu interface automatically goes up then down
Date: Wed, 9 Jan 2013 23:58:46 +0100 (CET)
Message-ID: <alpine.LNX.2.01.1301092342290.21351@nerf07.vanv.qr>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: sparclinux@vger.kernel.org
To: Linux Networking Developer Mailing List <netdev@vger.kernel.org>
Return-path: <sparclinux-owner@vger.kernel.org>
Sender: sparclinux-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I am observing that a machine with a niu card/driver automatically
enables itself and then goes dormant again.

[ 4410.930078] niu 0000:10:00.0 eth4: Link is up at 100Mbit/sec, full duplex
[ 4410.930137] br0: port 4(eth4) entered forwarding state
[ 4410.930156] br0: port 4(eth4) entered forwarding state
[ 4420.957745] niu 0000:10:00.0 eth4: Link is down

The interface itself is marked UP, and is part of a bridge,
if that matters. The kernel version is 3.7.1 on sparc64.

6: eth4: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500
qdisc mq master br0 state DOWN qlen 1000
    link/ether 00:21:28:71:32:5a brd ff:ff:ff:ff:ff:ff
    inet6 fe80::221:28ff:fe71:325a/64 scope link 
       valid_lft forever preferred_lft forever

At the same time, eth5, to which a cable+machine _is_ connected,
randomly goes out. At first I thought it might be the connected peer,
but seeing that eth4 randomly does a up-down cycle leads me to assume
that niu is doing a cycle here rather than the peer.

[ 3839.724721] niu 0000:10:00.1 eth5: Link is down
[ 3839.725077] br0: port 5(eth5) entered disabled state
[ 3840.725016] niu 0000:10:00.1 eth5: Link is up at 100Mbit/sec, half duplex
[ 3840.725195] br0: port 5(eth5) entered forwarding state
[ 3840.725327] br0: port 5(eth5) entered forwarding state
[ 3855.762171] br0: port 5(eth5) entered forwarding state

dmesg for niu:

[   60.158957] niu: niu.c:v1.1 (Apr 22, 2010)
[   60.160457] niu: niu0: Found PHY 002060b1 type MII at phy_port 10
[   60.160887] niu: niu0: Found PHY 002060b1 type MII at phy_port 11
[   60.161314] niu: niu0: Found PHY 002060b1 type MII at phy_port 12
[   60.161739] niu: niu0: Found PHY 002060b1 type MII at phy_port 13
[   60.168250] niu: niu0: Port 0 [4 RX chans] [6 TX chans]
[   60.168319] niu: niu0: Port 1 [4 RX chans] [6 TX chans]
[   60.168386] niu: niu0: Port 2 [4 RX chans] [6 TX chans]
[   60.168452] niu: niu0: Port 3 [4 RX chans] [6 TX chans]
[   60.168519] niu: niu0: Port 0 RDC tbl(0) [ 0 1 2 3 0 1 2 3 0 1 2 3 0 1 2 3 ]
[   60.168913] niu: niu0: Port 0 RDC tbl(1) [ 0 1 2 3 0 1 2 3 0 1 2 3 0 1 2 3 ]
[   60.169213] niu: niu0: Port 1 RDC tbl(2) [ 4 5 6 7 4 5 6 7 4 5 6 7 4 5 6 7 ]
[   60.169503] niu: niu0: Port 1 RDC tbl(3) [ 4 5 6 7 4 5 6 7 4 5 6 7 4 5 6 7 ]
[   60.169790] niu: niu0: Port 2 RDC tbl(4) [ 8 9 10 11 8 9 10 11 8 9 10 11 8 9 10 11 ]
[   60.170078] niu: niu0: Port 2 RDC tbl(5) [ 8 9 10 11 8 9 10 11 8 9 10 11 8 9 10 11 ]
[   60.170366] niu: niu0: Port 3 RDC tbl(6) [ 12 13 14 15 12 13 14 15 12 13 14 15 12 13 14 15 ]
[   60.170657] niu: niu0: Port 3 RDC tbl(7) [ 12 13 14 15 12 13 14 15 12 13 14 15 12 13 14 15 ]
[   60.416607] niu: eth4: NIU Ethernet 00:21:28:71:32:5a
[   60.416679] niu: eth4: Port type[XMAC] mode[1G:COPPER] XCVR[MII] phy[mif]
[   60.624669] niu: eth5: NIU Ethernet 00:21:28:71:32:5b
[   60.624741] niu: eth5: Port type[XMAC] mode[1G:COPPER] XCVR[MII] phy[mif]
[   60.832774] niu: eth6: NIU Ethernet 00:21:28:71:32:5c
[   60.832845] niu: eth6: Port type[BMAC] mode[1G:COPPER] XCVR[MII] phy[mif]
[   61.040806] niu: eth7: NIU Ethernet 00:21:28:71:32:5d
[   61.040877] niu: eth7: Port type[BMAC] mode[1G:COPPER] XCVR[MII] phy[mif]

lspci:
10:00.0 Ethernet controller: Sun Microsystems Computer Corp. Multithreaded 10-Gigabit Ethernet Network Controller (rev 01)
        Subsystem: Sun Microsystems Computer Corp. Device 0000
        Flags: bus master, fast devsel, latency 0, IRQ 00000015
        Memory at 01000000 (64-bit, non-prefetchable) [size=16M]
        Memory at 00d00000 (64-bit, non-prefetchable) [size=32K]
        Memory at 00d08000 (64-bit, non-prefetchable) [size=32K]
        Expansion ROM at 00e00000 [disabled] [size=1M]
        Capabilities: [40] Power Management version 2
        Capabilities: [50] MSI: Enable- Count=1/32 Maskable+ 64bit+
        Capabilities: [70] MSI-X: Enable+ Count=32 Masked-
        Capabilities: [80] Express Endpoint, MSI 00
        Capabilities: [94] Vendor Specific Information: Len=08 <?>
        Capabilities: [9c] Vendor Specific Information: Len=40 <?>
        Capabilities: [100] Advanced Error Reporting
        Kernel driver in use: niu

10:00.1 Ethernet controller: Sun Microsystems Computer Corp. Multithreaded 10-Gigabit Ethernet Network Controller (rev 01)
        Subsystem: Sun Microsystems Computer Corp. Device 0000
        Flags: bus master, fast devsel, latency 0, IRQ 00000016
        Memory at 02000000 (64-bit, non-prefetchable) [size=16M]
        Memory at 00d10000 (64-bit, non-prefetchable) [size=32K]
        Memory at 00d18000 (64-bit, non-prefetchable) [size=32K]
        Expansion ROM at 00f00000 [disabled] [size=1M]
        Capabilities: [40] Power Management version 2
        Capabilities: [50] MSI: Enable- Count=1/32 Maskable+ 64bit+
        Capabilities: [70] MSI-X: Enable+ Count=32 Masked-
        Capabilities: [80] Express Endpoint, MSI 00
        Capabilities: [94] Vendor Specific Information: Len=08 <?>
        Capabilities: [9c] Vendor Specific Information: Len=40 <?>
        Capabilities: [100] Advanced Error Reporting
        Kernel driver in use: niu

10:00.2 Ethernet controller: Sun Microsystems Computer Corp. Multithreaded 10-Gigabit Ethernet Network Controller (rev 01)
        Subsystem: Sun Microsystems Computer Corp. Device 0000
        Flags: bus master, fast devsel, latency 0, IRQ 00000017
        Memory at 03000000 (64-bit, non-prefetchable) [size=16M]
        Memory at 00d20000 (64-bit, non-prefetchable) [size=32K]
        Memory at 00d28000 (64-bit, non-prefetchable) [size=32K]
        Expansion ROM at 04000000 [disabled] [size=1M]
        Capabilities: [40] Power Management version 2
        Capabilities: [50] MSI: Enable- Count=1/32 Maskable+ 64bit+
        Capabilities: [70] MSI-X: Enable+ Count=32 Masked-
        Capabilities: [80] Express Endpoint, MSI 00
        Capabilities: [94] Vendor Specific Information: Len=08 <?>
        Capabilities: [9c] Vendor Specific Information: Len=40 <?>
        Capabilities: [100] Advanced Error Reporting
        Kernel driver in use: niu

10:00.3 Ethernet controller: Sun Microsystems Computer Corp. Multithreaded 10-Gigabit Ethernet Network Controller (rev 01)
        Subsystem: Sun Microsystems Computer Corp. Device 0000
        Flags: bus master, fast devsel, latency 0, IRQ 00000014
        Memory at 05000000 (64-bit, non-prefetchable) [size=16M]
        Memory at 00d30000 (64-bit, non-prefetchable) [size=32K]
        Memory at 00d38000 (64-bit, non-prefetchable) [size=32K]
        Expansion ROM at 04100000 [disabled] [size=1M]
        Capabilities: [40] Power Management version 2
        Capabilities: [50] MSI: Enable- Count=1/32 Maskable+ 64bit+
        Capabilities: [70] MSI-X: Enable+ Count=32 Masked-
        Capabilities: [80] Express Endpoint, MSI 00
        Capabilities: [94] Vendor Specific Information: Len=08 <?>
        Capabilities: [9c] Vendor Specific Information: Len=40 <?>
        Capabilities: [100] Advanced Error Reporting
        Kernel driver in use: niu

Any other info needed?
