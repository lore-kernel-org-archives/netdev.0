From: Arkadiusz =?utf-8?q?Mi=C5=9Bkiewicz?= <a.miskiewicz@gmail.com>
Subject: Re: forcedeth doesn't pass traffic (3.0.x kernel and earliers)
Date: Fri, 13 Jan 2012 18:33:29 +0100
Message-ID: <201201131833.29727.a.miskiewicz@gmail.com>
References: <201112102226.31546.a.miskiewicz@gmail.com> <201112102231.31206.a.miskiewicz@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:54559 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752805Ab2AMRde convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2012 12:33:34 -0500
Received: by eekd4 with SMTP id d4so1152667eek.19
        for <netdev@vger.kernel.org>; Fri, 13 Jan 2012 09:33:33 -0800 (PST)
In-Reply-To: <201112102231.31206.a.miskiewicz@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday 10 of December 2011, Arkadiusz Mi=C5=9Bkiewicz wrote:
> On Saturday 10 of December 2011, Arkadiusz Mi=C5=9Bkiewicz wrote:
> > Hello,
> >=20
> > I have few supermicro machines connected to edge-core switch using =
1Gbps
> > uplink. The problem is that after boot I have to restart net to get
> > network card pass traffic. The problem is only with forcedeth netwo=
rk
> > cards. It happens on different supermicro servers and it happens fo=
r as
> > far as I can remember (so, 2.6.3x kernels, too). Currently I'm on 3=
=2E0.13.
> >=20
> > Logs below show state after fresh boot where network traffic doesn'=
t get
> > through. Note that it shows that link is up but still - traffic doe=
sn't
> > get passed. tcpdump on eth0 interface sees only traffic initiated f=
rom
> > this server and no traffic from outside.
> >=20
> > Tried to set every offload (via ethtool -K) to off but that didn't =
help.
> >=20
> > I have to make:
> > ip link set eth0 down; ip link set eth0 up
> > wait few second and then traffic starts to get passed. When I do th=
at
> > this shows in dmesg: [ 1058.266480] forcedeth 0000:00:08.0: irq 40 =
for
> > MSI/MSI-X
> > [ 1069.163238] eth0: no IPv6 routers present
>=20
> One more note. This doesn't always happens like that. Sometimes I boo=
t
> and I get link working, traffic gets passed fine:

rmmod forcedeth; modprobe forcedeth; ifup doesn't help

Counters on switch side after forcedeth machine reboot, no traffic bein=
g=20
passed, switch counters reset.

#show interfaces counters ethernet 1/19
Ethernet 1/19
 Iftable Stats:
  Octets Input: 0, Octets Output: 11116437
  Unicast Input: 0, Unicast Output: 59
  Discard Input: 0, Discard Output: 0
  Error Input: 0, Error Output: 0
  Unknown Protos Input: 0, QLen Output: 0
 Extended Iftable Stats:
  Multi-cast Input: 0, Multi-cast Output: 24742
  Broadcast Input: 0, Broadcast Output: 790
 Ether-like Stats:
  Alignment Errors: 0, FCS Errors: 0
  Single Collision Frames: 0, Multiple Collision Frames: 0
  SQE Test Errors: 0, Deferred Transmissions: 0
  Late Collisions: 0, Excessive Collisions: 0
  Internal Mac Transmit Errors: 0, Internal Mac Receive Errors: 0
  Frames Too Long: 0, Carrier Sense Errors: 0
  Symbol Errors: 0
 RMON Stats:
  Drop Events: 0, Octets: 11075170, Packets: 25549
  Broadcast PKTS: 790, Multi-cast PKTS: 24742
  Undersize PKTS: 0, Oversize PKTS: 0
  Fragments: 0, Jabbers: 0
  CRC Align Errors: 0, Collisions: 0
  Packet Size <=3D 64 Octets: 2060, Packet Size 65 to 127 Octets: 12764
  Packet Size 128 to 255 Octets: 364, Packet Size 256 to 511 Octets: 29=
2
  Packet Size 512 to 1023 Octets: 8755, Packet Size 1024 to 1518 Octets=
: 1314

No errors here.

# dmesg|grep eth0
[   33.432266] forcedeth 0000:00:08.0: ifname eth0, PHY OUI 0x5043 @ 2,=
 addr=20
00:30:48:7a:57:a6
[   33.960287] Loading kernel module for a network device with CAP_SYS_=
MODULE=20
(deprecated).  Use CAP_NET_ADMIN and alias netdev-eth0 instead
[   33.967925] forcedeth 0000:00:08.0: eth0: no link during initializat=
ion
[   33.970995] ADDRCONF(NETDEV_UP): eth0: link is not ready
[   36.380311] forcedeth 0000:00:08.0: eth0: link up
[   36.384016] ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
[   47.150014] eth0: no IPv6 routers present

forcedeth side:

# ethtool -S eth0
NIC statistics:
     tx_bytes: 69926
     tx_zero_rexmt: 1011
     tx_one_rexmt: 0
     tx_many_rexmt: 0
     tx_late_collision: 0
     tx_fifo_errors: 0
     tx_carrier_errors: 0
     tx_excess_deferral: 0
     tx_retry_error: 0
     rx_frame_error: 0
     rx_extra_byte: 0
     rx_late_collision: 0
     rx_runt: 0
     rx_frame_too_long: 0
     rx_over_errors: 0
     rx_crc_errors: 0
     rx_frame_align_error: 0
     rx_length_error: 0
     rx_unicast: 3047
     rx_multicast: 0
     rx_broadcast: 2113
     rx_packets: 5160
     rx_errors_total: 0
     tx_errors_total: 0
     tx_deferral: 0
     tx_packets: 1011
     rx_bytes: 382259
     tx_pause: 0
     rx_pause: 0
     rx_drop_frame: 0


>=20
> [   34.038476] forcedeth: Reverse Engineered nForce ethernet driver.
> Version 0.64. [   34.038698] ACPI: PCI Interrupt Link [LMAC] enabled =
at
> IRQ 22
> [   34.038705] forcedeth 0000:00:08.0: PCI INT A -> Link[LMAC] -> GSI=
 22
> (level, low) -> IRQ 22 [   34.038710] forcedeth 0000:00:08.0: setting
> latency timer to 64 [   34.565309] forcedeth 0000:00:08.0: ifname eth=
0,
> PHY OUI 0x5043 @ 2, addr 00:30:48:7a:b4:88 [   34.565314] forcedeth
> 0000:00:08.0: highdma csum vlan pwrctl mgmt gbit lnktim msi desc-v3 [=
 =20
> 34.566823] ACPI: PCI Interrupt Link [LMAD] enabled at IRQ 21
> [   34.566831] forcedeth 0000:00:09.0: PCI INT A -> Link[LMAD] -> GSI=
 21
> (level, low) -> IRQ 21 [   34.566836] forcedeth 0000:00:09.0: setting
> latency timer to 64 [   35.091341] forcedeth 0000:00:09.0: ifname eth=
1,
> PHY OUI 0x5043 @ 3, addr 00:30:48:7a:b4:89 [   35.091346] forcedeth
> 0000:00:09.0: highdma csum vlan pwrctl mgmt gbit lnktim msi desc-v3 [=
 =20
> 35.093492] Loading kernel module for a network device with CAP_SYS_MO=
DULE
> (deprecated).  Use CAP_NET_ADMIN and alias netdev-eth0 instead [ =20
> 35.101074] forcedeth 0000:00:08.0: irq 40 for MSI/MSI-X
> [   35.101267] forcedeth 0000:00:08.0: eth0: no link during initializ=
ation
> [   35.102322] ADDRCONF(NETDEV_UP): eth0: link is not ready
> [   35.663785] ip_tables: (C) 2000-2006 Netfilter Core Team
> [   35.756083] nf_conntrack version 0.5.0 (16384 buckets, 65536 max)
> [   37.147869] forcedeth 0000:00:08.0: eth0: link up
> [   37.149108] ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
> [   47.176677] eth0: no IPv6 routers present
>=20
> > (CC to few people shown by get_maintainer.pl)
> >=20
> > LOGS/OUTPUTs from non working state after fresh boot.
> > # dmesg|grep eth
> > [   34.528326] forcedeth: Reverse Engineered nForce ethernet driver=
=2E
> > Version 0.64. [   34.528542] forcedeth 0000:00:08.0: PCI INT A ->
> > Link[LMAC] -> GSI 22 (level, low) -> IRQ 22 [   34.528547] forcedet=
h
> > 0000:00:08.0: setting latency timer to 64 [   35.055319] forcedeth
> > 0000:00:08.0: ifname eth0, PHY OUI 0x5043 @ 2, addr 00:30:48:7a:b4:=
88 [
> > 35.055324] forcedeth 0000:00:08.0: highdma csum vlan pwrctl mgmt gb=
it
> > lnktim msi desc-v3 [   35.056480] forcedeth 0000:00:09.0: PCI INT A=
 ->
> > Link[LMAD] -> GSI 21 (level, low) -> IRQ 21 [   35.056485] forcedet=
h
> > 0000:00:09.0: setting latency timer to 64 [   35.581960] forcedeth
> > 0000:00:09.0: ifname eth1, PHY OUI 0x5043 @ 3, addr 00:30:48:7a:b4:=
89 [
> > 35.581965] forcedeth 0000:00:09.0: highdma csum vlan pwrctl mgmt gb=
it
> > lnktim msi desc-v3 [   35.584211] Loading kernel module for a netwo=
rk
> > device with CAP_SYS_MODULE (deprecated).  Use CAP_NET_ADMIN and ali=
as
> > netdev-eth0 instead [   35.591778] forcedeth 0000:00:08.0: irq 40 f=
or
> > MSI/MSI-X
> > [   35.591970] forcedeth 0000:00:08.0: eth0: no link during
> > initialization [   35.593030] ADDRCONF(NETDEV_UP): eth0: link is no=
t
> > ready
> > [   37.666757] forcedeth 0000:00:08.0: eth0: link up
> > [   37.668624] ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
> > [   48.150006] eth0: no IPv6 routers present
> >=20
> > lspci -vv:
> > 00:09.0 Bridge: nVidia Corporation MCP55 Ethernet (rev a3)
> >=20
> >         Subsystem: Super Micro Computer Inc Device 1611
> >         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
> >         ParErr-
> >=20
> > Stepping- SERR- FastB2B- DisINTx- Status: Cap+ 66MHz+ UDF- FastB2B+
> > ParErr- DEVSEL=3Dfast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx=
-
> > Latency: 0 (250ns min, 5000ns max)
> >=20
> >         Interrupt: pin A routed to IRQ 21
> >         Region 0: Memory at feaf5000 (32-bit, non-prefetchable) [si=
ze=3D4K]
> >         Region 1: I/O ports at b080 [size=3D8]
> >         Region 2: Memory at feafa000 (32-bit, non-prefetchable)
> >         [size=3D256] Region 3: Memory at feaf4c00 (32-bit,
> >         non-prefetchable) [size=3D16] Capabilities: [44] Power Mana=
gement
> >         version 2
> >        =20
> >                 Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=3D0mA
> >=20
> > PME(D0+,D1+,D2+,D3hot+,D3cold+) Status: D0 NoSoftRst- PME-Enable- D=
Sel=3D0
> > DScale=3D0 PME- Capabilities: [70] MSI-X: Enable- Count=3D8 Masked-
> >=20
> >                 Vector table: BAR=3D2 offset=3D00000000
> >                 PBA: BAR=3D3 offset=3D00000000
> >        =20
> >         Capabilities: [50] MSI: Enable- Count=3D1/8 Maskable+ 64bit=
+
> >        =20
> >                 Address: 0000000000000000  Data: 0000
> >                 Masking: 00000000  Pending: 00000000
> >        =20
> >         Capabilities: [6c] HyperTransport: MSI Mapping Enable- Fixe=
d+
> >         Kernel driver in use: forcedeth
> >=20
> > # ethtool eth0
> >=20
> > Settings for eth0:
> >         Supported ports: [ MII ]
> >         Supported link modes:   10baseT/Half 10baseT/Full
> >        =20
> >                                 100baseT/Half 100baseT/Full
> >                                 1000baseT/Full
> >        =20
> >         Supported pause frame use: No
> >         Supports auto-negotiation: Yes
> >         Advertised link modes:  10baseT/Half 10baseT/Full
> >        =20
> >                                 100baseT/Half 100baseT/Full
> >                                 1000baseT/Full
> >        =20
> >         Advertised pause frame use: No
> >         Advertised auto-negotiation: Yes
> >         Speed: 1000Mb/s
> >         Duplex: Full
> >         Port: MII
> >         PHYAD: 2
> >         Transceiver: external
> >         Auto-negotiation: on
> >         Supports Wake-on: g
> >         Wake-on: d
> >         Link detected: yes
> >=20
> > # ethtool -S eth0
> >=20
> > NIC statistics:
> >      tx_bytes: 46352
> >      tx_zero_rexmt: 704
> >      tx_one_rexmt: 0
> >      tx_many_rexmt: 0
> >      tx_late_collision: 0
> >      tx_fifo_errors: 0
> >      tx_carrier_errors: 0
> >      tx_excess_deferral: 0
> >      tx_retry_error: 0
> >      rx_frame_error: 0
> >      rx_extra_byte: 0
> >      rx_late_collision: 0
> >      rx_runt: 0
> >      rx_frame_too_long: 0
> >      rx_over_errors: 1
> >      rx_crc_errors: 0
> >      rx_frame_align_error: 0
> >      rx_length_error: 0
> >      rx_unicast: 31
> >      rx_multicast: 0
> >      rx_broadcast: 436
> >      rx_packets: 467
> >      rx_errors_total: 1
> >      tx_errors_total: 0
> >      tx_deferral: 0
> >      tx_packets: 704
> >      rx_bytes: 35872
> >      tx_pause: 0
> >      rx_pause: 0
> >      rx_drop_frame: 170
> >=20
> > # ethtool -k eth0
> > Offload parameters for eth0:
> > rx-checksumming: on
> > tx-checksumming: on
> > scatter-gather: on
> > tcp-segmentation-offload: on
> > udp-fragmentation-offload: off
> > generic-segmentation-offload: on
> > generic-receive-offload: on
> > large-receive-offload: off
> > rx-vlan-offload: on
> > tx-vlan-offload: on
> > ntuple-filters: off
> > receive-hashing: off
> >=20
> >=20
> > 2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc sfq state=
 UP
> > qlen 1000 link/ether 00:30:48:7a:b4:88 brd ff:ff:ff:ff:ff:ff


--=20
Arkadiusz Mi=C5=9Bkiewicz        PLD/Linux Team
arekm / maven.pl            http://ftp.pld-linux.org/
