From: "Marco Berizzi" <pupilla@hotmail.com>
Subject: 3C905 + options=0x8
Date: Mon, 20 Oct 2003 13:25:41 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Sea2-DAV19xSl5CjBaX00005d53@hotmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.
I have found a strange 3C905 behaviour on linux 2.4.22 (same behaviuor
with 2.4.19 and 2.6.0-test7).
When the linux box load the module with /etc/modules.conf containing:
options 3c59x options=0x8,0x8

the 3C905 NICs don't receive/send packet. 3C905B NIC is working good.
Here is the output from mii-diag:

mii-diag.c:v2.09 9/06/2003 Donald Becker (becker@scyld.com)
 http://www.scyld.com/diag/index.html
  Using the new SIOCGMIIPHY value on PHY 24 (BMCR 0x3100).
 The autonegotiated capability is 01e0.
The autonegotiated media type is 100baseTx-FD.
 Basic mode control register 0x3100: Auto-negotiation enabled.
 Basic mode status register 0x786f ... 786f.
   Link status: established.
   This transceiver is capable of  100baseTx-FD 100baseTx 10baseT-FD
10baseT.
   Able to perform Auto-negotiation, negotiation complete.
   *** Link Jabber! ***
 Your link partner advertised 45e1: Flow-control 100baseTx-FD 100baseTx
10baseT-FD 10baseT, w/ 802.3X flow control.
   End of basic transceiver information.

 MII PHY #24 transceiver registers:
   3100 786f 2000 5c01 01e1 45e1 0001 0000
   0000 0000 0000 0000 0000 0000 0000 0000
   0000 0000 0000 0000 0000 0000 0001 8060
   8020 0cb8 0000 1800 a3b9 005d 0c05 001d

Here is the output from vortex-diag

vortex-diag.c:v2.14 12/28/2002 Donald Becker (becker@scyld.com)
 http://www.scyld.com/diag/index.html
Index #1: Found a 3c905 Boomerang 100baseTx adapter at 0xe400.
 Station address 00:60:97:d8:e5:01.
  Receive mode is 0x00: Unknown/invalid.
 MII PHY found at address 24, status 786f.
 MII PHY 0 at #24 transceiver registers:
   3100 786f 2000 5c01 01e1 45e1 0001 0000
   0000 0000 0000 0000 0000 0000 0000 0000
   0000 0000 0000 0000 0000 0000 0001 8060
   8020 0cb8 0000 1800 a3b9 0063 5005 001d.
vortex-diag.c:v2.14 12/28/2002 Donald Becker (becker@scyld.com)
 http://www.scyld.com/diag/index.html
Index #1: Found a 3c905 Boomerang 100baseTx adapter at 0xe400.
 Station address 00:60:97:d8:e5:01.
  Receive mode is 0x00: Unknown/invalid.
Initial window 4, registers values by window:
  Window 0: 0000 0000 0000 0000 0000 00bf ffff 0000.
  Window 1: 0000 0000 0000 2000 8000 00ff 13fc 2000.
  Window 2: 6000 d897 01e5 0000 0000 0000 0000 4000.
  Window 3: 02d8 0163 0000 0000 e040 0bff 13ff 6000.
  Window 4: 0000 06d0 2000 0000 0003 8802 0000 8000.
  Window 5: 1ffc fffc 0000 1ffc 0000 0000 0000 a000.
  Window 6: 0000 0000 0000 0000 0000 0000 0000 c000.
  Window 7: 0000 0000 0000 0000 8000 00ff 0000 e000.
Vortex chip registers at 0xe400
  0xE410: 00800000 00000000 00008000 000013fc
  0xE420: 00000000 00000000 00000000 ff000000
  0xE430: 00000000 0000f7fb 00000000 00000000
 Indication enable is 0000, interrupt enable is 0000.
 No interrupt sources are pending.
 Transceiver/media interfaces available:  MII.
Transceiver type in use:  MII.
 MAC settings: half-duplex.
Maximum packet size is 0.
 Station address set to 00:60:97:d8:e5:01.
 Configuration options 0000.
vortex-diag.c:v2.14 12/28/2002 Donald Becker (becker@scyld.com)
 http://www.scyld.com/diag/index.html
Index #1: Found a 3c905 Boomerang 100baseTx adapter at 0xe400.
 Station address 00:60:97:d8:e5:01.
  Receive mode is 0x00: Unknown/invalid.
EEPROM format 64x16, configuration table at offset 0:
    00: 0060 97d8 e501 9050 c29c 0036 4848 6d50
  0x08: 0418 0001 0060 97d8 e501 0020 0000 0000
  0x10: 10a6 0000 02d8 0163 0000 0002 0000 00a4
  0x18: ffff ffff ffff ffff ffff ffff ffff ffff
      ...

 The word-wide EEPROM checksum is 0x1ce4.
Saved EEPROM settings of a 3Com Vortex/Boomerang:
 3Com Node Address 00:60:97:D8:E5:01 (used as a unique ID only).
 OEM Station address 00:60:97:D8:E5:01 (used as the ethernet address).
  Device ID 9050,  Manufacturer ID 6d50.
  Manufacture date (MM/DD/YYYY) 4/28/1997, division 6, product HH.
  No BIOS ROM is present.
 Transceiver selection: MII.
   Options: negotiated duplex, link beat required.
 PCI Subsystem IDs: Vendor 00a4 Device ffff.
 100baseT4 100baseTx 100baseFx 10baseT 10base2 AUI MII .
  Vortex format checksum is correct (a4 vs. a4).
  Cyclone format checksum is incorrect (00 vs. 0xff).
  Hurricane format checksum is incorrect (00 vs. 0xff).

Could you help me?

Please cc me, I'm not subscribed to the list.
