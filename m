From: till busch <buti@gmx.at>
Subject: 3CXFE575BT full-duplex problem
Date: Fri, 19 Apr 2002 20:29:45 +0200
Sender: owner-netdev@oss.sgi.com
Message-ID: <200204192029.45577.buti@gmx.at>
Reply-To: buti@gmx.at
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 8bit
Cc: andrewm@uow.edu.au
Return-path: <owner-netdev@oss.sgi.com>
To: netdev@oss.sgi.com
List-Id: netdev.vger.kernel.org

hi.

having read Documentation/networking/vortex.txt i'm trying to make a bug 
report:

My "3Com Megahertz 10/100 LAN CardBus PC Card", a 3CXFE575BT has problems 
switching to full-duplex mode. (is there any difference between 3CC and 3CX?)

Is it really a driver problem?
yes, i've seen reports about this on many sites in the internet. also, i 
tested it with windows, where things work fine.

i'm running linux 2.4.18. the card is connected to a switch. and there is 
another machine with a 100baseT-FD card, connected to the switch, also. as 
the switch-leds indicate, these work fine, (and it's also advertising FD).

banner message:

3c59x: Donald Becker and others. www.scyld.com/network/vortex.html
See Documentation/networking/vortex.txt
05:00.0: 3Com PCI 3CCFE575BT Cyclone CardBus at 0x4800. Vers LK1.1.16
00:00:86:51:43:95, IRQ 10
product code 4e56 rev 07.1 date 03-10-98
05:00.0: CardBus functions mapped 11000080->c8bf9080
Internal config register is 1000000, transceivers 0x40.
8K byte-wide RAM 5:3 Rx:Tx split, autoselect/10baseT interface.
Enabling bus-master transmits and whole-frame receives.
scatter/gather enabled. h/w checksums enabled

lspci -vx:

05:00.0 Ethernet controller: 3Com Corporation 3c575 [Megahertz] 10/100 LAN 
CardBus (rev 01)
        Subsystem: 3Com Corporation 3C575 Megahertz 10/100 LAN Cardbus PC Card
        Flags: bus master, medium devsel, latency 64, IRQ 10
        I/O ports at 4800 [size=128]
        Memory at 11000000 (32-bit, non-prefetchable) [size=128]
        Memory at 11000080 (32-bit, non-prefetchable) [size=128]
        Expansion ROM at 10c00000 [size=128K]
        Capabilities: [50] Power Management version 1
00: b7 10 57 51 07 00 10 02 01 00 00 02 00 40 00 00
10: 01 48 00 00 00 00 00 11 80 00 00 11 00 00 00 00
20: 00 00 00 00 00 00 00 00 90 00 00 00 b7 10 57 5b
30: 01 00 c0 10 50 00 00 00 00 00 00 00 0a 01 0a 05

eth0:  Filling in the Rx ring.
eth0: using NWAY device table, not 0
eth0: Initial media type Autonegotiate.
vortex_up(): writing 0x1800000 to InternalConfig
eth0: vortex_up() InternalConfig 01800000.
eth0: MII #0 status 282d, link partner capability 45e1, info1 2010, setting 
full-duplex.
outw(0x20, 0x4806)	/* i've added this myself, just to see what happens */
eth0: vortex_up() InternalConfig 01800000.
eth0: vortex_up() irq 10 media status a000.


mii-diag -v:

mii-diag.c:v2.02 5/21/2001 Donald Becker (becker@scyld.com)
 http://www.scyld.com/diag/index.html
Using the default interface 'eth0'.
 The autonegotiated capability is 00a0.
The autonegotiated media type is 100baseTx.
 Basic mode control register 0x3000: Auto-negotiation enabled.
 You have link beat, and everything is working OK.
   This transceiver is capable of  100baseTx 10baseT.
   Able to perform Auto-negotiation, negotiation complete.
 Your link partner advertised 45e1: Flow-control 100baseTx-FD 100baseTx 
10baseT-FD 10baseT, w/ 802.3X flow control.
   End of basic transceiver informaion.

 MII PHY #0 transceiver registers:
   3000 282d 0300 e54b 00a1 45e1 0001 0000
   0000 0000 0000 0000 0000 0000 0000 0000
   0140 0000 0700 0000 0000 0000 0000 0000
   0000 0000 0000 0000 0000 0000 0000 0000.
 Basic mode control register 0x3000: Auto-negotiation enabled.
 Basic mode status register 0x282d ... 282d.
   Link status: established.
   Capable of  100baseTx 10baseT.
   Able to perform Auto-negotiation, negotiation complete.
 Vendor ID is 00:c0:39:--:--:--, model 20 rev. 11.
   Vendor/Part: TDK transceiver (unknown type).
 I'm advertising 00a1: 100baseTx 10baseT
   Advertising no additional info pages.
   IEEE 802.3 CSMA/CD protocol.
 Link partner capability is 45e1: Flow-control 100baseTx-FD 100baseTx 
10baseT-FD 10baseT.
   Negotiation  completed.
  TDK format vendor-specific registers 16..18 are 0x0140 0x0000 0x0700
      Link polarity is detected as normal.
      Auto-negotiation complete, 100Mbps half duplex.
      Rx link in pass state, PLL slipped since last read.
      No new link status events.

vortex-diag -aaee:

vortex-diag.c:v2.05 5/15/2001 Donald Becker (becker@scyld.com)
 http://www.scyld.com/diag/index.html
Index #1: Found a 3CCFE575BT CardBus adapter at 0x4800.
The Vortex chip may be active, so FIFO registers will not be read.
To see all register values use the '-f' flag.
Initial window 4, registers values by window:
  Window 0: 0000 0000 0000 0000 0000 06ff ffff 0000.
  Window 1: FIFO FIFO 0000 0000 0000 0000 0000 2000.
  Window 2: 0000 5186 9543 0000 0000 0000 0112 4000.
  Window 3: 0000 0180 05ea 0020 0040 1000 0800 6000.
  Window 4: 0000 0000 0000 0042 0003 a000 0000 8000.
  Window 5: 1ffc 0000 0000 0600 0807 0000 06c6 a000.
  Window 6: 0000 0000 0000 0000 0000 0000 0000 c000.
  Window 7: 0000 0000 0000 0000 0000 0000 0000 e000.
Vortex chip registers at 0x4800
  0x4810: **FIFO** 00000000 0000000a *STATUS*
  0x4820: 00000020 00000000 00080000 00000004
  0x4830: 00000000 513faec1 00000000 00080004
 Indication enable is 06c6, interrupt enable is 0000.
 No interrupt sources are pending.
 Transceiver/media interfaces available:  MII.
Transceiver type in use:  Autonegotiate.
 MAC settings: full-duplex.
 Station address set to 00:00:86:51:43:95.
 Configuration options 0112.
EEPROM contents (256 words, offset 0x30):
 0x000: 10b7 5157 0007 0000 0001 0200 4000 0000
 0x008: 0000 0000 0000 0000 0000 0000 0000 0000
 0x010: 0000 0000 0000 0000 0090 0000 10b7 5b57
 0x018: 0000 0000 0000 0000 0000 0000 0109 0a0a
 0x020: 0000 0060 0000 0000 0000 0000 0000 0000
 0x028: 0000 0000 0000 0000 0000 0000 0000 0000
 0x030: 0000 8651 4395 5157 c46a 0036 564e 6d50
 0x038: 3000 0009 0000 8651 4395 2010 0000 0006
 0x040: 32a6 1570 0000 0060 0007 0000 0000 0022
 0x048: 0313 4943 2053 0104 5701 0451 0306 0001
 0x050: 0000 0500 410c 019a 1eb5 5501 3002 ffff
 0x058: 0701 1106 4000 0000 1500 0534 3300 6f43
 0x060: 206d 6f43 7072 726f 7461 6f69 006e 4333
 0x068: 4643 3545 3537 5442 4c00 4e41 4320 7261
 0x070: 6264 7375 4320 7261 0064 3030 0031 21ff
 0x078: 0602 0501 0006 8080 8080 ff19 ffff ffff
 0x080: ffff ffff ffff ffff ffff ffff ffff ffff
 0x088: ffff ffff ffff ffff ffff ffff ffff ffff
 0x090: ffff ffff ffff ffff ffff ffff ffff ffff
 0x098: ffff ffff ffff ffff ffff ffff ffff ffff
 0x0a0: ffff ffff ffff ffff ffff ffff ffff ffff
 0x0a8: ffff ffff ffff ffff ffff ffff ffff ffff
 0x0b0: ffff ffff ffff ffff ffff ffff ffff ffff
 0x0b8: ffff ffff ffff ffff ffff ffff ffff ffff
 0x0c0: ffff ffff ffff ffff ffff ffff ffff ffff
 0x0c8: ffff ffff ffff ffff ffff ffff ffff ffff
 0x0d0: ffff ffff ffff ffff ffff ffff ffff ffff
 0x0d8: ffff ffff ffff ffff ffff ffff ffff ffff
 0x0e0: ffff ffff ffff ffff ffff ffff ffff ffff
 0x0e8: ffff ffff ffff ffff ffff ffff ffff ffff
 0x0f0: ffff ffff ffff ffff ffff ffff ffff ffff
 0x0f8: ffff ffff ffff ffff ffff ffff ffff ffff
 The word-wide EEPROM checksum is 0xc5a4.
Saved EEPROM settings of a 3Com Vortex/Boomerang:
 The CardBus product ID is 10b7 5157.
 3Com Node Address 00:00:86:51:43:95 (used as a unique ID only).
 OEM Station address 00:00:86:51:43:95 (used as the ethernet address).
 Manufacture date (MM/DD/YYYY) 3/10/1998, division 6, product NV.
 Options: negotiated duplex, link beat required.
  Vortex format checksum is correct (0022 vs. 0022).
  Cyclone format checksum is incorrect (0x1a vs. 00).
  Hurricane format checksum is incorrect (0x6b vs. 00).


mii-tool -v:

eth0: negotiated 100baseTx-HD, link ok
  product info: TDK 78Q2120 rev 11
  basic mode:   autonegotiation enabled
  basic status: autonegotiation complete, link ok
  capabilities: 100baseTx-HD 10baseT-HD
  advertising:  100baseTx-HD 10baseT-HD
  link partner: 100baseTx-FD 100baseTx-HD 10baseT-FD 10baseT-HD flow-control

i'll be happily providing any information you need, and so on, and so forth..

thanks for your help,
- till
