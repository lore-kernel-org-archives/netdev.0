From: "Carlos Fernandez Sanz" <cfs@nova.es>
Subject: vortex problems in 2.6?
Date: Tue, 6 Apr 2004 11:27:05 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <000e01c41bb9$536600b0$1530a8c0@HUSH>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----=_NextPart_000_000B_01C41BCA.16BCC430"
Return-path: <netdev-bounce@oss.sgi.com>
To: <netdev@oss.sgi.com>, <akpm@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.

------=_NextPart_000_000B_01C41BCA.16BCC430
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

<Please CC: me in the reply as I don't subscribe to this list. Thanks>

I'm trying to track down my problems with my NIC in 2.6.5 (worked fine =
in
2.4.22). The network "works" but very very slow, and ifconfig shows =
almost
the same count in the Tx packet and carrier count:

TX packets:23818 errors:0 dropped:0 overruns:0 carrier:23817

dmesg for 2.4.22 and 2.6.5 are almost identical, except for the last =
lines
in 2.4.22 (vortex_up, etc). There are no (apparently important) =
different in
vortex-diag. mii-diag, however, fails to run in 2.6.5 while it works in
2.4.22.

 Dumps follow, in case someone can shed light.

(BTW: lsmod in 2.4.22 shows the module as busy (used twice, because I =
have
two identical NICs, while in 2.6.5 it seems to be unused - I can unload =
the
module with both interfaces up, but obviously as soon as I do that they
dissapear - I assume this is the intended 2.6 behaviour).

*****
dmesg
*****
2.4.22:
PCI: Found IRQ 9 for device 02:0b.0
PCI: Sharing IRQ 9 with 00:1f.4
3c59x: Donald Becker and others. www.scyld.com/network/vortex.html
See Documentation/networking/vortex.txt
02:0b.0: 3Com PCI 3c905C Tornado at 0xd800. Vers LK1.1.18-ac
00:01:03:27:81:75, IRQ 9
product code 4a45 rev 00.12 date 10-15-00
Internal config register is 1800000, transceivers 0xa.
8K byte-wide RAM 5:3 Rx:Tx split, autoselect/Autonegotiate interface.
MII transceiver found at address 24, status 786d.
Enabling bus-master transmits and whole-frame receives.
02:0b.0: scatter/gather enabled. h/w checksums enabled
divert: allocating divert_blk for eth0
eth0: using NWAY device table, not 8
eth0: Initial media type Autonegotiate.
eth0: MII #24 status 786d, link partner capability 45e1, info1 0010, =
setting
full-duplex.
eth0: vortex_up() InternalConfig 01800000.
eth0: vortex_up() irq 9 media status 8880.

2.6.5:
PCI: Found IRQ 9 for device 0000:02:0b.0
PCI: Sharing IRQ 9 with 0000:00:1f.4
3c59x: Donald Becker and others. www.scyld.com/network/vortex.html
See Documentation/networking/vortex.txt
0000:02:0b.0: 3Com PCI 3c905C Tornado at 0xd800. Vers LK1.1.19
00:01:03:27:81:75, IRQ 9
product code 4a45 rev 00.12 date 10-15-00
Internal config register is 1800000, transceivers 0xa.
8K byte-wide RAM 5:3 Rx:Tx split, autoselect/Autonegotiate interface.
MII transceiver found at address 24, status 786d.
Enabling bus-master transmits and whole-frame receives.
0000:02:0b.0: scatter/gather enabled. h/w checksums enabled
*********
vortex-diag
*********

2.4.22:
Index #1: Found a 3c920 Series NIC adapter at 0xd800.
Station address 00:01:03:27:81:75.
Receive mode is 0x07: Normal unicast and all multicast.
The Vortex chip may be active, so FIFO registers will not be read.
To see all register values use the '-f' flag.
Initial window 7, registers values by window:
Window 0: 0000 0000 d93f 0000 e3e3 00bf ffff 0000.
Window 1: FIFO FIFO 0700 0000 0000 007e 0000 2000.
Window 2: 0100 2703 7581 0000 0000 0000 0042 4000.
Window 3: 0000 0180 05ea 0020 000a 0800 0800 6000.
Window 4: 0000 0000 0000 0cd8 0001 8880 0000 8000.
Window 5: 1ffc 0000 0000 0600 0807 06ce 06c6 a000.
Window 6: 0000 0000 0000 0a00 0000 02e2 0000 c000.
Window 7: 0000 0000 0000 0000 0000 0000 0000 e000.
Vortex chip registers at 0xd800
0xD810: **FIFO** 00000000 0000000a *STATUS*
0xD820: 00000020 00000000 00080000 00000004
0xD830: 00000000 44aebb52 03f58180 00080004
0xD840: 003eb253 00000000 000000b7 00000000
0xD850: 00000000 00000000 00000000 00000000
0xD860: 00000000 00000000 00000000 00000000
0xD870: 00009800 00000000 01600000 00000000
DMA control register is 00000020.
Tx list starts at 00000000.
Tx FIFO thresholds: min. burst 256 bytes, priority with 128 bytes to =
empty.
Rx FIFO thresholds: min. burst 256 bytes, priority with 128 bytes to =
full.
Poll period Tx 00 ns., Rx 0 ns.
Maximum burst recorded Tx 0, Rx 352.
Indication enable is 06c6, interrupt enable is 06ce.
No interrupt sources are pending.
Transceiver/media interfaces available: 100baseTx 10baseT.
Transceiver type in use: Autonegotiate.
MAC settings: full-duplex.
Station address set to 00:01:03:27:81:75.
Configuration options 0042.
EEPROM format 64x16, configuration table at offset 0:
00: 0001 0327 8175 9200 014f 0048 454a 6d50
0x08: 2940 0800 0001 0327 8175 0010 0000 00aa
0x10: 72a2 0000 0000 0180 0000 0000 0429 10b7
0x18: 1000 000a 0002 6300 ffb7 b7b7 0000 0000
0x20: 00ba 1234 5600 0000 0000 0000 0000 0000
0x28: 0000 0000 0000 0000 0000 0000 0000 0000
0x30: ffff ffff ffff ffff ffff ffff ffff ffff
...
The word-wide EEPROM checksum is 0x9dc7.
Saved EEPROM settings of a 3Com Vortex/Boomerang:
3Com Node Address 00:01:03:27:81:75 (used as a unique ID only).
OEM Station address 00:01:03:27:81:75 (used as the ethernet address).
Device ID 9200, Manufacturer ID 6d50.
Manufacture date (MM/DD/YYYY) 10/15/2000, division H, product JE.
A BIOS ROM of size 0Kx8 is expected.
Transceiver selection: Autonegotiate.
Options: negotiated duplex, link beat required.
PCI bus requested settings -- minimum grant 10, maximum latency 10 =
(250ns
units).
PCI Subsystem IDs: Vendor 10b7 Device 1000.
100baseTx 10baseT.
Vortex format checksum is incorrect (2c vs. 10b7).
Cyclone format checksum is incorrect (0xbc vs. 0xba).
Hurricane format checksum is incorrect (0x95 vs. 0xba).
MII PHY found at address 24, status 786d.
MII PHY 0 at #24 transceiver registers:
3000 786d 0180 7750 05e1 45e1 0001 0000
0000 0000 0000 0000 0000 0000 0000 0000
0238 0087 0000 0000 0000 0000 c4c8 0300
0100 0438 2010 2000 0000 0000 0000 0000.

2.6.5:
Index #1: Found a 3c920 Series NIC adapter at 0xd800.
 Station address 00:01:03:27:81:75.
  Receive mode is 0x07: Normal unicast and all multicast.
The Vortex chip may be active, so FIFO registers will not be read.
To see all register values use the '-f' flag.
Initial window 7, registers values by window:
  Window 0: 0000 0000 d93f 0000 e3e3 00bf ffff 0000.
  Window 1: FIFO FIFO 0700 0000 0000 007e 0000 2000.
  Window 2: 0100 2703 7581 0000 0000 0000 0042 4000.
  Window 3: 0000 0180 05ea 0000 000a 0800 0800 6000.
  Window 4: 0000 0000 0000 0cd8 0001 8c80 0000 8000.
  Window 5: 1ffc 0000 0000 0600 0807 06ce 06c6 a000.
  Window 6: 0000 0000 0000 0600 0000 0569 018c c000.
  Window 7: 0000 0000 0000 0000 0000 0000 0000 e000.
Vortex chip registers at 0xd800
  0xD810: **FIFO** 00000000 0000002a *STATUS*
  0xD820: 00000020 00000000 00080000 00000004
  0xD830: 00000000 d03a2fc6 1ce260c0 00080004
  0xD840: 00bb915d 00000000 000000b7 00000000
  0xD850: 00000000 00000000 00000000 00000000
  0xD860: 00000000 00000000 00000000 00000000
  0xD870: 00009800 00000000 01600160 00000000
  DMA control register is 00000020.
   Tx list starts at 00000000.
   Tx FIFO thresholds: min. burst 256 bytes, priority with 128 bytes to
empty.
   Rx FIFO thresholds: min. burst 256 bytes, priority with 128 bytes to
full.
   Poll period Tx 00 ns.,  Rx 0 ns.
   Maximum burst recorded Tx 352,  Rx 352.
 Indication enable is 06c6, interrupt enable is 06ce.
 No interrupt sources are pending.
 Transceiver/media interfaces available:  100baseTx 10baseT.
Transceiver type in use:  Autonegotiate.
 MAC settings: half-duplex.
 Station address set to 00:01:03:27:81:75.
 Configuration options 0042.
EEPROM format 64x16, configuration table at offset 0:
    00: 0001 0327 8175 9200 014f 0048 454a 6d50
  0x08: 2940 0800 0001 0327 8175 0010 0000 00aa
  0x10: 72a2 0000 0000 0180 0000 0000 0429 10b7
  0x18: 1000 000a 0002 6300 ffb7 b7b7 0000 0000
  0x20: 00ba 1234 5600 0000 0000 0000 0000 0000
  0x28: 0000 0000 0000 0000 0000 0000 0000 0000
  0x30: ffff ffff ffff ffff ffff ffff ffff ffff
      ...
 The word-wide EEPROM checksum is 0x9dc7.
Saved EEPROM settings of a 3Com Vortex/Boomerang:
 3Com Node Address 00:01:03:27:81:75 (used as a unique ID only).
 OEM Station address 00:01:03:27:81:75 (used as the ethernet address).
  Device ID 9200,  Manufacturer ID 6d50.
  Manufacture date (MM/DD/YYYY) 10/15/2000, division H, product JE.
  A BIOS ROM of size 0Kx8 is expected.
 Transceiver selection: Autonegotiate.
   Options: negotiated duplex, link beat required.
   PCI bus requested settings --  minimum grant 10, maximum latency 10
(250ns units).
 PCI Subsystem IDs: Vendor 10b7 Device 1000.
 100baseTx 10baseT.
  Vortex format checksum is incorrect (2c vs. 10b7).
  Cyclone format checksum is incorrect (0xbc vs. 0xba).
  Hurricane format checksum is incorrect (0x95 vs. 0xba).
 MII PHY found at address 24, status 786d.
 MII PHY 0 at #24 transceiver registers:
   3000 786d 0180 7750 05e1 45e1 0001 0000
   0000 0000 0000 0000 0000 0000 0000 0000
   0238 0087 0000 0000 0000 0000 c4c8 0300
   0100 0438 2010 2000 8000 0000 0000 0000.

******
mii-diag
******
2.4.22:
mii-diag.c:v2.09 9/06/2003 Donald Becker (becker@scyld.com)
http://www.scyld.com/diag/index.html
Using the new SIOCGMIIPHY value on PHY 24 (BMCR 0x3000).
The autonegotiated capability is 01e0.
The autonegotiated media type is 100baseTx-FD.
Basic mode control register 0x3000: Auto-negotiation enabled.
You have link beat, and everything is working OK.
This transceiver is capable of 100baseTx-FD 100baseTx 10baseT-FD =
10baseT.
Able to perform Auto-negotiation, negotiation complete.
Your link partner advertised 45e1: Flow-control 100baseTx-FD 100baseTx
10baseT-FD 10baseT, w/ 802.3X flow control.
End of basic transceiver information.
libmii.c:v2.10 4/22/2003 Donald Becker (becker@scyld.com)
http://www.scyld.com/diag/index.html
MII PHY #24 transceiver registers:
3000 786d 0180 7750 05e1 45e1 0001 0000
0000 0000 0000 0000 0000 0000 0000 0000
0238 0087 0000 0000 0000 0000 c4c8 0300
0100 0438 2010 2000 0000 0000 0000 0000.
Basic mode control register 0x3000: Auto-negotiation enabled.
Basic mode status register 0x786d ... 786d.
Link status: established.
Capable of 100baseTx-FD 100baseTx 10baseT-FD 10baseT.
Able to perform Auto-negotiation, negotiation complete.
Vendor ID is 00:60:1d:--:--:--, model 53 rev. 0.
No specific information is known about this transceiver type.
I'm advertising 05e1: Flow-control 100baseTx-FD 100baseTx 10baseT-FD =
10baseT
Advertising no additional info pages.
IEEE 802.3 CSMA/CD protocol.
Link partner capability is 45e1: Flow-control 100baseTx-FD 100baseTx
10baseT-FD 10baseT.
Negotiation completed.

2.6.5:
root@fulanito root]# mii-diag --force
Using the default interface 'eth0'.
Basic registers of MII PHY #24:  0000 0000 0000 0000 0000 0000 0000 =
0000.
  No MII transceiver present!.
 Basic mode control register 0x0000: Auto-negotiation disabled, with
 Speed fixed at 10 mbps, half-duplex.
 Basic mode status register 0x0000 ... 0000.
   Link status: not established.
 Link partner information is not exchanged when in fixed speed mode.
   End of basic transceiver information.

Thanks.



------=_NextPart_000_000B_01C41BCA.16BCC430
Content-Type: text/html;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML><HEAD>
<META http-equiv=3DContent-Type content=3D"text/html; =
charset=3Diso-8859-1">
<META content=3D"MSHTML 6.00.2800.1400" name=3DGENERATOR>
<STYLE></STYLE>
</HEAD>
<BODY bgColor=3D#ffffff>
<DIV><FONT face=3DArial size=3D2>&lt;Please CC: me in the reply as I =
don't subscribe=20
to this list. Thanks&gt;</FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV>I'm trying to track down my problems with my NIC in 2.6.5 (worked =
fine=20
in<BR>2.4.22). The network "works" but very very slow, and ifconfig =
shows=20
almost<BR>the same count in the Tx packet and carrier count:<BR><BR>TX=20
packets:23818 errors:0 dropped:0 overruns:0 carrier:23817<BR><BR>dmesg =
for=20
2.4.22 and 2.6.5 are almost identical, except for the last lines<BR>in =
2.4.22=20
(vortex_up, etc). There are no (apparently important) different=20
in<BR>vortex-diag. mii-diag, however, fails to run in 2.6.5 while it =
works=20
in<BR>2.4.22.<BR><BR>&nbsp;Dumps follow, in case someone can shed=20
light.<BR><BR>(BTW: lsmod in 2.4.22 shows the module as busy (used =
twice,=20
because I have<BR>two identical NICs, while in 2.6.5 it seems to be =
unused - I=20
can unload the<BR>module with both interfaces up, but obviously as soon =
as I do=20
that they<BR>dissapear - I assume this is the intended 2.6=20
behaviour).<BR><BR>*****<BR>dmesg<BR>*****<BR>2.4.22:<BR>PCI: Found IRQ =
9 for=20
device 02:0b.0<BR>PCI: Sharing IRQ 9 with 00:1f.4<BR>3c59x: Donald =
Becker and=20
others. <A=20
href=3D"http://www.scyld.com/network/vortex.html">www.scyld.com/network/v=
ortex.html</A><BR>See=20
Documentation/networking/vortex.txt<BR>02:0b.0: 3Com PCI 3c905C Tornado =
at=20
0xd800. Vers LK1.1.18-ac<BR>00:01:03:27:81:75, IRQ 9<BR>product code =
4a45 rev=20
00.12 date 10-15-00<BR>Internal config register is 1800000, transceivers =

0xa.<BR>8K byte-wide RAM 5:3 Rx:Tx split, autoselect/Autonegotiate=20
interface.<BR>MII transceiver found at address 24, status =
786d.<BR>Enabling=20
bus-master transmits and whole-frame receives.<BR>02:0b.0: =
scatter/gather=20
enabled. h/w checksums enabled<BR>divert: allocating divert_blk for=20
eth0<BR>eth0: using NWAY device table, not 8<BR>eth0: Initial media type =

Autonegotiate.<BR>eth0: MII #24 status 786d, link partner capability =
45e1, info1=20
0010, setting<BR>full-duplex.<BR>eth0: vortex_up() InternalConfig=20
01800000.<BR>eth0: vortex_up() irq 9 media status =
8880.<BR><BR>2.6.5:<BR>PCI:=20
Found IRQ 9 for device 0000:02:0b.0<BR>PCI: Sharing IRQ 9 with=20
0000:00:1f.4<BR>3c59x: Donald Becker and others. <A=20
href=3D"http://www.scyld.com/network/vortex.html">www.scyld.com/network/v=
ortex.html</A><BR>See=20
Documentation/networking/vortex.txt<BR>0000:02:0b.0: 3Com PCI 3c905C =
Tornado at=20
0xd800. Vers LK1.1.19<BR>00:01:03:27:81:75, IRQ 9<BR>product code 4a45 =
rev 00.12=20
date 10-15-00<BR>Internal config register is 1800000, transceivers =
0xa.<BR>8K=20
byte-wide RAM 5:3 Rx:Tx split, autoselect/Autonegotiate =
interface.<BR>MII=20
transceiver found at address 24, status 786d.<BR>Enabling bus-master =
transmits=20
and whole-frame receives.<BR>0000:02:0b.0: scatter/gather enabled. h/w =
checksums=20
enabled<BR>*********<BR>vortex-diag<BR>*********<BR><BR>2.4.22:<BR>Index =
#1:=20
Found a 3c920 Series NIC adapter at 0xd800.<BR>Station address=20
00:01:03:27:81:75.<BR>Receive mode is 0x07: Normal unicast and all=20
multicast.<BR>The Vortex chip may be active, so FIFO registers will not =
be=20
read.<BR>To see all register values use the '-f' flag.<BR>Initial window =
7,=20
registers values by window:<BR>Window 0: 0000 0000 d93f 0000 e3e3 00bf =
ffff=20
0000.<BR>Window 1: FIFO FIFO 0700 0000 0000 007e 0000 2000.<BR>Window 2: =
0100=20
2703 7581 0000 0000 0000 0042 4000.<BR>Window 3: 0000 0180 05ea 0020 =
000a 0800=20
0800 6000.<BR>Window 4: 0000 0000 0000 0cd8 0001 8880 0000 =
8000.<BR>Window 5:=20
1ffc 0000 0000 0600 0807 06ce 06c6 a000.<BR>Window 6: 0000 0000 0000 =
0a00 0000=20
02e2 0000 c000.<BR>Window 7: 0000 0000 0000 0000 0000 0000 0000 =
e000.<BR>Vortex=20
chip registers at 0xd800<BR>0xD810: **FIFO** 00000000 0000000a=20
*STATUS*<BR>0xD820: 00000020 00000000 00080000 00000004<BR>0xD830: =
00000000=20
44aebb52 03f58180 00080004<BR>0xD840: 003eb253 00000000 000000b7=20
00000000<BR>0xD850: 00000000 00000000 00000000 00000000<BR>0xD860: =
00000000=20
00000000 00000000 00000000<BR>0xD870: 00009800 00000000 01600000 =
00000000<BR>DMA=20
control register is 00000020.<BR>Tx list starts at 00000000.<BR>Tx FIFO=20
thresholds: min. burst 256 bytes, priority with 128 bytes to =
empty.<BR>Rx FIFO=20
thresholds: min. burst 256 bytes, priority with 128 bytes to =
full.<BR>Poll=20
period Tx 00 ns., Rx 0 ns.<BR>Maximum burst recorded Tx 0, Rx =
352.<BR>Indication=20
enable is 06c6, interrupt enable is 06ce.<BR>No interrupt sources are=20
pending.<BR>Transceiver/media interfaces available: 100baseTx=20
10baseT.<BR>Transceiver type in use: Autonegotiate.<BR>MAC settings:=20
full-duplex.<BR>Station address set to =
00:01:03:27:81:75.<BR>Configuration=20
options 0042.<BR>EEPROM format 64x16, configuration table at offset =
0:<BR>00:=20
0001 0327 8175 9200 014f 0048 454a 6d50<BR>0x08: 2940 0800 0001 0327 =
8175 0010=20
0000 00aa<BR>0x10: 72a2 0000 0000 0180 0000 0000 0429 10b7<BR>0x18: 1000 =
000a=20
0002 6300 ffb7 b7b7 0000 0000<BR>0x20: 00ba 1234 5600 0000 0000 0000 =
0000=20
0000<BR>0x28: 0000 0000 0000 0000 0000 0000 0000 0000<BR>0x30: ffff ffff =
ffff=20
ffff ffff ffff ffff ffff<BR>...<BR>The word-wide EEPROM checksum is=20
0x9dc7.<BR>Saved EEPROM settings of a 3Com Vortex/Boomerang:<BR>3Com =
Node=20
Address 00:01:03:27:81:75 (used as a unique ID only).<BR>OEM Station =
address=20
00:01:03:27:81:75 (used as the ethernet address).<BR>Device ID 9200,=20
Manufacturer ID 6d50.<BR>Manufacture date (MM/DD/YYYY) 10/15/2000, =
division H,=20
product JE.<BR>A BIOS ROM of size 0Kx8 is expected.<BR>Transceiver =
selection:=20
Autonegotiate.<BR>Options: negotiated duplex, link beat required.<BR>PCI =
bus=20
requested settings -- minimum grant 10, maximum latency 10=20
(250ns<BR>units).<BR>PCI Subsystem IDs: Vendor 10b7 Device =
1000.<BR>100baseTx=20
10baseT.<BR>Vortex format checksum is incorrect (2c vs. =
10b7).<BR>Cyclone format=20
checksum is incorrect (0xbc vs. 0xba).<BR>Hurricane format checksum is =
incorrect=20
(0x95 vs. 0xba).<BR>MII PHY found at address 24, status 786d.<BR>MII PHY =
0 at=20
#24 transceiver registers:<BR>3000 786d 0180 7750 05e1 45e1 0001 =
0000<BR>0000=20
0000 0000 0000 0000 0000 0000 0000<BR>0238 0087 0000 0000 0000 0000 c4c8 =

0300<BR>0100 0438 2010 2000 0000 0000 0000 0000.<BR><BR>2.6.5:<BR>Index =
#1:=20
Found a 3c920 Series NIC adapter at 0xd800.<BR>&nbsp;Station address=20
00:01:03:27:81:75.<BR>&nbsp; Receive mode is 0x07: Normal unicast and =
all=20
multicast.<BR>The Vortex chip may be active, so FIFO registers will not =
be=20
read.<BR>To see all register values use the '-f' flag.<BR>Initial window =
7,=20
registers values by window:<BR>&nbsp; Window 0: 0000 0000 d93f 0000 e3e3 =
00bf=20
ffff 0000.<BR>&nbsp; Window 1: FIFO FIFO 0700 0000 0000 007e 0000=20
2000.<BR>&nbsp; Window 2: 0100 2703 7581 0000 0000 0000 0042 =
4000.<BR>&nbsp;=20
Window 3: 0000 0180 05ea 0000 000a 0800 0800 6000.<BR>&nbsp; Window 4: =
0000 0000=20
0000 0cd8 0001 8c80 0000 8000.<BR>&nbsp; Window 5: 1ffc 0000 0000 0600 =
0807 06ce=20
06c6 a000.<BR>&nbsp; Window 6: 0000 0000 0000 0600 0000 0569 018c=20
c000.<BR>&nbsp; Window 7: 0000 0000 0000 0000 0000 0000 0000 =
e000.<BR>Vortex=20
chip registers at 0xd800<BR>&nbsp; 0xD810: **FIFO** 00000000 0000002a=20
*STATUS*<BR>&nbsp; 0xD820: 00000020 00000000 00080000 00000004<BR>&nbsp; =
0xD830:=20
00000000 d03a2fc6 1ce260c0 00080004<BR>&nbsp; 0xD840: 00bb915d 00000000 =
000000b7=20
00000000<BR>&nbsp; 0xD850: 00000000 00000000 00000000 00000000<BR>&nbsp; =
0xD860:=20
00000000 00000000 00000000 00000000<BR>&nbsp; 0xD870: 00009800 00000000 =
01600160=20
00000000<BR>&nbsp; DMA control register is 00000020.<BR>&nbsp;&nbsp; Tx =
list=20
starts at 00000000.<BR>&nbsp;&nbsp; Tx FIFO thresholds: min. burst 256 =
bytes,=20
priority with 128 bytes to<BR>empty.<BR>&nbsp;&nbsp; Rx FIFO thresholds: =
min.=20
burst 256 bytes, priority with 128 bytes to<BR>full.<BR>&nbsp;&nbsp; =
Poll period=20
Tx 00 ns.,&nbsp; Rx 0 ns.<BR>&nbsp;&nbsp; Maximum burst recorded Tx =
352,&nbsp;=20
Rx 352.<BR>&nbsp;Indication enable is 06c6, interrupt enable is=20
06ce.<BR>&nbsp;No interrupt sources are =
pending.<BR>&nbsp;Transceiver/media=20
interfaces available:&nbsp; 100baseTx 10baseT.<BR>Transceiver type in =
use:&nbsp;=20
Autonegotiate.<BR>&nbsp;MAC settings: half-duplex.<BR>&nbsp;Station =
address set=20
to 00:01:03:27:81:75.<BR>&nbsp;Configuration options 0042.<BR>EEPROM =
format=20
64x16, configuration table at offset 0:<BR>&nbsp;&nbsp;&nbsp; 00: 0001 =
0327 8175=20
9200 014f 0048 454a 6d50<BR>&nbsp; 0x08: 2940 0800 0001 0327 8175 0010 =
0000=20
00aa<BR>&nbsp; 0x10: 72a2 0000 0000 0180 0000 0000 0429 10b7<BR>&nbsp; =
0x18:=20
1000 000a 0002 6300 ffb7 b7b7 0000 0000<BR>&nbsp; 0x20: 00ba 1234 5600 =
0000 0000=20
0000 0000 0000<BR>&nbsp; 0x28: 0000 0000 0000 0000 0000 0000 0000 =
0000<BR>&nbsp;=20
0x30: ffff ffff ffff ffff ffff ffff ffff =
ffff<BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
...<BR>&nbsp;The word-wide EEPROM checksum is 0x9dc7.<BR>Saved EEPROM =
settings=20
of a 3Com Vortex/Boomerang:<BR>&nbsp;3Com Node Address 00:01:03:27:81:75 =
(used=20
as a unique ID only).<BR>&nbsp;OEM Station address 00:01:03:27:81:75 =
(used as=20
the ethernet address).<BR>&nbsp; Device ID 9200,&nbsp; Manufacturer ID=20
6d50.<BR>&nbsp; Manufacture date (MM/DD/YYYY) 10/15/2000, division H, =
product=20
JE.<BR>&nbsp; A BIOS ROM of size 0Kx8 is expected.<BR>&nbsp;Transceiver=20
selection: Autonegotiate.<BR>&nbsp;&nbsp; Options: negotiated duplex, =
link beat=20
required.<BR>&nbsp;&nbsp; PCI bus requested settings --&nbsp; minimum =
grant 10,=20
maximum latency 10<BR>(250ns units).<BR>&nbsp;PCI Subsystem IDs: Vendor =
10b7=20
Device 1000.<BR>&nbsp;100baseTx 10baseT.<BR>&nbsp; Vortex format =
checksum is=20
incorrect (2c vs. 10b7).<BR>&nbsp; Cyclone format checksum is incorrect =
(0xbc=20
vs. 0xba).<BR>&nbsp; Hurricane format checksum is incorrect (0x95 vs.=20
0xba).<BR>&nbsp;MII PHY found at address 24, status 786d.<BR>&nbsp;MII =
PHY 0 at=20
#24 transceiver registers:<BR>&nbsp;&nbsp; 3000 786d 0180 7750 05e1 45e1 =
0001=20
0000<BR>&nbsp;&nbsp; 0000 0000 0000 0000 0000 0000 0000 =
0000<BR>&nbsp;&nbsp;=20
0238 0087 0000 0000 0000 0000 c4c8 0300<BR>&nbsp;&nbsp; 0100 0438 2010 =
2000 8000=20
0000 0000=20
0000.<BR><BR>******<BR>mii-diag<BR>******<BR>2.4.22:<BR>mii-diag.c:v2.09 =

9/06/2003 Donald Becker (<A=20
href=3D"mailto:becker@scyld.com">becker@scyld.com</A>)<BR><A=20
href=3D"http://www.scyld.com/diag/index.html">http://www.scyld.com/diag/i=
ndex.html</A><BR>Using=20
the new SIOCGMIIPHY value on PHY 24 (BMCR 0x3000).<BR>The autonegotiated =

capability is 01e0.<BR>The autonegotiated media type is =
100baseTx-FD.<BR>Basic=20
mode control register 0x3000: Auto-negotiation enabled.<BR>You have link =
beat,=20
and everything is working OK.<BR>This transceiver is capable of =
100baseTx-FD=20
100baseTx 10baseT-FD 10baseT.<BR>Able to perform Auto-negotiation, =
negotiation=20
complete.<BR>Your link partner advertised 45e1: Flow-control =
100baseTx-FD=20
100baseTx<BR>10baseT-FD 10baseT, w/ 802.3X flow control.<BR>End of basic =

transceiver information.<BR>libmii.c:v2.10 4/22/2003 Donald Becker (<A=20
href=3D"mailto:becker@scyld.com">becker@scyld.com</A>)<BR><A=20
href=3D"http://www.scyld.com/diag/index.html">http://www.scyld.com/diag/i=
ndex.html</A><BR>MII=20
PHY #24 transceiver registers:<BR>3000 786d 0180 7750 05e1 45e1 0001=20
0000<BR>0000 0000 0000 0000 0000 0000 0000 0000<BR>0238 0087 0000 0000 =
0000 0000=20
c4c8 0300<BR>0100 0438 2010 2000 0000 0000 0000 0000.<BR>Basic mode =
control=20
register 0x3000: Auto-negotiation enabled.<BR>Basic mode status register =
0x786d=20
... 786d.<BR>Link status: established.<BR>Capable of 100baseTx-FD =
100baseTx=20
10baseT-FD 10baseT.<BR>Able to perform Auto-negotiation, negotiation=20
complete.<BR>Vendor ID is 00:60:1d:--:--:--, model 53 rev. 0.<BR>No =
specific=20
information is known about this transceiver type.<BR>I'm advertising =
05e1:=20
Flow-control 100baseTx-FD 100baseTx 10baseT-FD 10baseT<BR>Advertising no =

additional info pages.<BR>IEEE 802.3 CSMA/CD protocol.<BR>Link partner=20
capability is 45e1: Flow-control 100baseTx-FD 100baseTx<BR>10baseT-FD=20
10baseT.<BR>Negotiation completed.<BR><BR>2.6.5:<BR><A=20
href=3D"mailto:root@fulanito">root@fulanito</A> root]# mii-diag =
--force<BR>Using=20
the default interface 'eth0'.<BR>Basic registers of MII PHY #24:&nbsp; =
0000 0000=20
0000 0000 0000 0000 0000 0000.<BR>&nbsp; No MII transceiver=20
present!.<BR>&nbsp;Basic mode control register 0x0000: Auto-negotiation=20
disabled, with<BR>&nbsp;Speed fixed at 10 mbps, =
half-duplex.<BR>&nbsp;Basic mode=20
status register 0x0000 ... 0000.<BR>&nbsp;&nbsp; Link status: not=20
established.<BR>&nbsp;Link partner information is not exchanged when in =
fixed=20
speed mode.<BR>&nbsp;&nbsp; End of basic transceiver=20
information.<BR><BR>Thanks.<BR></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV></BODY></HTML>

------=_NextPart_000_000B_01C41BCA.16BCC430--
