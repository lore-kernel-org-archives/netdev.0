From: =?iso-8859-1?Q?Ga=EBl?= Roualland <gael.roualland@dial.oleane.com>
Subject: 3c59x random initialisation issues on 2.6
Date: Tue, 10 Feb 2004 22:32:41 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40294DF9.9260813E@dial.oleane.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello,

Since I switched to 2.6 (at 2.6-test10 and up to 2.6.2), I am
experiencing some random initialisation problems when loading the 3c59x
module for a 3c905 board. The board is found, but not the MII, and is
not usable.

Excerpt from messages:

PCI: Enabling device 0000:00:0b.0 (0000 -> 0003)
3c59x: Donald Becker and others. www.scyld.com/network/vortex.html
0000:00:0b.0: 3Com PCI 3c905B Cyclone 100baseTx at 0x6c00. Vers LK1.1.19
PCI: Setting latency timer of device 0000:00:0b.0 to 64
  ***WARNING*** No MII transceivers found!
eth0: command 0x5800 did not complete! Status=3D0xffff
eth0: command 0x2804 did not complete! Status=3D0xffff
[...]
NETDEV WATCHDOG: eth0: transmit timed out
eth0: transmit timed out, tx_status ff status ffff.
  diagnostics: net ffff media ffff dma ffffffff fifo ffff
eth0: Transmitter encountered 16 collisions -- network cable problem?
eth0: Interrupt posted but not delivered -- IRQ blocked by another
device?
  Flags; bus-master 1, dirty 0(0) current 16(0)
  Transmit list ffffffff vs. cf3f9200.
eth0: command 0x3002 did not complete! Status=3D0xffff
  0: @cf3f9200  length 8000005a status 0000005a
  1: @cf3f92a0  length 8000004e status 0000004e
  2: @cf3f9340  length 80000046 status 00000046
  3: @cf3f93e0  length 8000006e status 0000006e
  4: @cf3f9480  length 8000004e status 0000004e
  5: @cf3f9520  length 80000046 status 00000046
  6: @cf3f95c0  length 8000002a status 0000002a
  7: @cf3f9660  length 8000002a status 0000002a
  8: @cf3f9700  length 8000002a status 0000002a
  9: @cf3f97a0  length 80000046 status 00000046
  10: @cf3f9840  length 8000002a status 0000002a
  11: @cf3f98e0  length 8000004a status 0000004a
  12: @cf3f9980  length 8000002a status 0000002a
  13: @cf3f9a20  length 8000002a status 0000002a
  14: @cf3f9ac0  length 8000002a status 8000002a
  15: @cf3f9b60  length 8000002a status 8000002a
eth0: command 0x5800 did not complete! Status=3D0xffff
eth0: Resetting the Tx ring pointer.

and so on...
One or two reboots are usually needed to solve the problem, in which
case the board is well initalised and works properly.
(warm or cold reboot doesn't seem to affect this).

Some information about the system :

$ cat /proc/version
Linux version 2.6.2 (root@tom) (version gcc 3.3.2 (Debian)) #6 Sun Feb 8
16:39:29 CET 2004

$ lspci -v [extract]
00:00.0 Host bridge: Intel Corp. 440BX/ZX/DX - 82443BX/ZX/DX Host bridge
(rev 02)
        Flags: bus master, medium devsel, latency 64
        Memory at e0000000 (32-bit, prefetchable) [size=3D128M]
        Capabilities: [a0] AGP version 1.0

00:01.0 PCI bridge: Intel Corp. 440BX/ZX/DX - 82443BX/ZX/DX AGP bridge
(rev 02) (prog-if 00 [Normal decode])
        Flags: bus master, 66Mhz, medium devsel, latency 64
        Bus: primary=3D00, secondary=3D01, subordinate=3D01, sec-latency=3D=
64
        I/O behind bridge: 0000e000-0000efff
        Memory behind bridge: d0000000-dfffffff
        Prefetchable memory behind bridge: a0000000-afffffff

00:0b.0 Ethernet controller: 3Com Corporation 3c905B 100BaseTX [Cyclone]
(rev 24)
        Subsystem: 3Com Corporation 3C905B Fast Etherlink XL 10/100
        Flags: bus master, medium devsel, latency 64, IRQ 9
        I/O ports at 6c00 [size=3D128]
        Memory at e8002000 (32-bit, non-prefetchable) [size=3D128]
        Expansion ROM at <unassigned> [disabled] [size=3D128K]
        Capabilities: [dc] Power Management version 1

The module is loaded with no options.
I'm not sure whether this is a driver or PCI/BIOS issue, since when it
works fine there are no PCI messages at driver load time. I might not be
writing to the right list, so please redirect me if needed ;)

Thanks for your help,

Ga=EBl.

--=20
Ga=EBl Roualland -+- gael.roualland@dial.oleane.com
