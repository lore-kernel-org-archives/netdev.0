From: Arkadiusz =?utf-8?q?Mi=C5=9Bkiewicz?= <a.miskiewicz@gmail.com>
Subject: forcedeth doesn't pass traffic (3.0.x kernel and earliers)
Date: Sat, 10 Dec 2011 22:26:31 +0100
Message-ID: <201112102226.31546.a.miskiewicz@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ian Campbell <ian.campbell@citrix.com>,
	David Decotigny <david.decotigny@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:38336 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751416Ab1LJV0g convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Dec 2011 16:26:36 -0500
Received: by eekc4 with SMTP id c4so932015eek.19
        for <netdev@vger.kernel.org>; Sat, 10 Dec 2011 13:26:35 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hello,

I have few supermicro machines connected to edge-core switch using 1Gbp=
s uplink.
The problem is that after boot I have to restart net to get network car=
d pass traffic. The problem
is only with forcedeth network cards. It happens on different supermicr=
o servers and it happens
for as far as I can remember (so, 2.6.3x kernels, too). Currently I'm o=
n 3.0.13.

Logs below show state after fresh boot where network traffic doesn't ge=
t through.
Note that it shows that link is up but still - traffic doesn't get pass=
ed. tcpdump on eth0
interface sees only traffic initiated from this server and no traffic f=
rom outside.

Tried to set every offload (via ethtool -K) to off but that didn't help=
=2E

I have to make:
ip link set eth0 down; ip link set eth0 up
wait few second and then traffic starts to get passed. When I do that t=
his shows in dmesg:
[ 1058.266480] forcedeth 0000:00:08.0: irq 40 for MSI/MSI-X
[ 1069.163238] eth0: no IPv6 routers present

(CC to few people shown by get_maintainer.pl)

LOGS/OUTPUTs from non working state after fresh boot.
# dmesg|grep eth
[   34.528326] forcedeth: Reverse Engineered nForce ethernet driver. Ve=
rsion 0.64.
[   34.528542] forcedeth 0000:00:08.0: PCI INT A -> Link[LMAC] -> GSI 2=
2 (level, low) -> IRQ 22
[   34.528547] forcedeth 0000:00:08.0: setting latency timer to 64
[   35.055319] forcedeth 0000:00:08.0: ifname eth0, PHY OUI 0x5043 @ 2,=
 addr 00:30:48:7a:b4:88
[   35.055324] forcedeth 0000:00:08.0: highdma csum vlan pwrctl mgmt gb=
it lnktim msi desc-v3
[   35.056480] forcedeth 0000:00:09.0: PCI INT A -> Link[LMAD] -> GSI 2=
1 (level, low) -> IRQ 21
[   35.056485] forcedeth 0000:00:09.0: setting latency timer to 64
[   35.581960] forcedeth 0000:00:09.0: ifname eth1, PHY OUI 0x5043 @ 3,=
 addr 00:30:48:7a:b4:89
[   35.581965] forcedeth 0000:00:09.0: highdma csum vlan pwrctl mgmt gb=
it lnktim msi desc-v3
[   35.584211] Loading kernel module for a network device with CAP_SYS_=
MODULE (deprecated).  Use CAP_NET_ADMIN and alias netdev-eth0 instead
[   35.591778] forcedeth 0000:00:08.0: irq 40 for MSI/MSI-X
[   35.591970] forcedeth 0000:00:08.0: eth0: no link during initializat=
ion
[   35.593030] ADDRCONF(NETDEV_UP): eth0: link is not ready
[   37.666757] forcedeth 0000:00:08.0: eth0: link up
[   37.668624] ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
[   48.150006] eth0: no IPv6 routers present

lspci -vv:
00:09.0 Bridge: nVidia Corporation MCP55 Ethernet (rev a3)
        Subsystem: Super Micro Computer Inc Device 1611
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- Par=
Err- Stepping- SERR- FastB2B- DisINTx-
        Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=3Dfast >TAbort=
- <TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 0 (250ns min, 5000ns max)
        Interrupt: pin A routed to IRQ 21
        Region 0: Memory at feaf5000 (32-bit, non-prefetchable) [size=3D=
4K]
        Region 1: I/O ports at b080 [size=3D8]
        Region 2: Memory at feafa000 (32-bit, non-prefetchable) [size=3D=
256]
        Region 3: Memory at feaf4c00 (32-bit, non-prefetchable) [size=3D=
16]
        Capabilities: [44] Power Management version 2
                Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=3D0mA PME(D0+,D1=
+,D2+,D3hot+,D3cold+)
                Status: D0 NoSoftRst- PME-Enable- DSel=3D0 DScale=3D0 P=
ME-
        Capabilities: [70] MSI-X: Enable- Count=3D8 Masked-
                Vector table: BAR=3D2 offset=3D00000000
                PBA: BAR=3D3 offset=3D00000000
        Capabilities: [50] MSI: Enable- Count=3D1/8 Maskable+ 64bit+
                Address: 0000000000000000  Data: 0000
                Masking: 00000000  Pending: 00000000
        Capabilities: [6c] HyperTransport: MSI Mapping Enable- Fixed+
        Kernel driver in use: forcedeth

# ethtool eth0
Settings for eth0:
        Supported ports: [ MII ]
        Supported link modes:   10baseT/Half 10baseT/Full=20
                                100baseT/Half 100baseT/Full=20
                                1000baseT/Full=20
        Supported pause frame use: No
        Supports auto-negotiation: Yes
        Advertised link modes:  10baseT/Half 10baseT/Full=20
                                100baseT/Half 100baseT/Full=20
                                1000baseT/Full=20
        Advertised pause frame use: No
        Advertised auto-negotiation: Yes
        Speed: 1000Mb/s
        Duplex: Full
        Port: MII
        PHYAD: 2
        Transceiver: external
        Auto-negotiation: on
        Supports Wake-on: g
        Wake-on: d
        Link detected: yes

# ethtool -S eth0
NIC statistics:
     tx_bytes: 46352
     tx_zero_rexmt: 704
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
     rx_over_errors: 1
     rx_crc_errors: 0
     rx_frame_align_error: 0
     rx_length_error: 0
     rx_unicast: 31
     rx_multicast: 0
     rx_broadcast: 436
     rx_packets: 467
     rx_errors_total: 1
     tx_errors_total: 0
     tx_deferral: 0
     tx_packets: 704
     rx_bytes: 35872
     tx_pause: 0
     rx_pause: 0
     rx_drop_frame: 170

# ethtool -k eth0
Offload parameters for eth0:
rx-checksumming: on
tx-checksumming: on
scatter-gather: on
tcp-segmentation-offload: on
udp-fragmentation-offload: off
generic-segmentation-offload: on
generic-receive-offload: on
large-receive-offload: off
rx-vlan-offload: on
tx-vlan-offload: on
ntuple-filters: off
receive-hashing: off


2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc sfq state UP =
qlen 1000
    link/ether 00:30:48:7a:b4:88 brd ff:ff:ff:ff:ff:ff

--=20
Arkadiusz Mi=C5=9Bkiewicz        PLD/Linux Team
arekm / maven.pl            http://ftp.pld-linux.org/
