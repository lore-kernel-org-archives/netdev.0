From: "Marco Berizzi" <pupilla@hotmail.com>
Subject: Re: 3C905 + options=0x8
Date: Tue, 21 Oct 2003 10:54:31 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Sea2-DAV56Hhjy3DzB8000069a3@hotmail.com>
References: <Pine.LNX.4.44.0310201130220.3313-100000@training.scyld.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "Donald Becker" <becker@scyld.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Donald Becker wrote:

> Baseline: what do you expect this option setting to do when used with
> the 3c905_ (no suffix)?

As you wrote: "...just to make sure..." ;-))

> Note that the 3c905 has an external MII transceiver (trasceiver type
6),
> while the 3c905B and 3c905C have on-chip transceivers (transceiver
type 8).

FYI: With a 3c905:
modprobe 3c59x options=0x8
rmmod 3c59x
modprobe 3c59x options=0x6 doesn't work anyway until I reboot the linux
box.

> You should not set driver options unless you have a non-standard
> configuration.  Setting driver options "just to make sure" is a common
> source of problems.

Ok.

> I suspect that just removing the module options will restore correct
> operation.

Yes it work when I remove the module options.

modprobe 3c59x options=0x6,0x6,0x8 (the linux box contains 3 NICs, two
3C905 and one 3C905B) sometimes I get this error when I switch the eth0
cable from a 10MBit/s HUB to a cross cable (to connect directly to
another system 100MBit/s FD):

Output from mii-diag:

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
   8020 0cb8 0000 1800 a3b9 005e 1f05 001d

Output from dmesg:

  13: @c6f5b540  length 8000002a status 0000002a
  14: @c6f5b580  length 8000002a status 0000002a
  15: @c6f5b5c0  length 8000002a status 8000002a
eth0: Resetting the Tx ring pointer.
eth0: Transmit error, Tx status register 90.
  Flags; bus-master 1, dirty 1(1) current 17(1)
  Transmit list 06f5b280 vs. c6f5b240.
  0: @c6f5b200  length 8000002a status 8000002a
  1: @c6f5b240  length 8000002a status 0000002a
  2: @c6f5b280  length 8000002a status 0000002a
  3: @c6f5b2c0  length 8000002a status 0000002a
  4: @c6f5b300  length 8000002a status 0000002a
  5: @c6f5b340  length 8000002a status 0000002a
  6: @c6f5b380  length 8000002a status 0000002a
  7: @c6f5b3c0  length 8000002a status 0000002a
  8: @c6f5b400  length 8000002a status 0000002a
  9: @c6f5b440  length 8000002a status 0000002a
  10: @c6f5b480  length 8000002a status 0000002a
  11: @c6f5b4c0  length 8000002a status 0000002a
  12: @c6f5b500  length 8000002a status 0000002a
  13: @c6f5b540  length 8000002a status 0000002a
  14: @c6f5b580  length 8000002a status 0000002a
  15: @c6f5b5c0  length 8000002a status 8000002a
NETDEV WATCHDOG: eth0: transmit timed out
eth0: transmit timed out, tx_status 00 status e000.
  diagnostics: net 0cc0 media 8802 dma 00000020.
  Flags; bus-master 1, dirty 1(1) current 17(1)
  Transmit list 00000000 vs. c6f5b240.
  0: @c6f5b200  length 8000002a status 8000002a
  1: @c6f5b240  length 8000002a status 0000002a
  2: @c6f5b280  length 8000002a status 0000002a
  3: @c6f5b2c0  length 8000002a status 0000002a
  4: @c6f5b300  length 8000002a status 0000002a
  5: @c6f5b340  length 8000002a status 0000002a
  6: @c6f5b380  length 8000002a status 0000002a
  7: @c6f5b3c0  length 8000002a status 0000002a
  8: @c6f5b400  length 8000002a status 0000002a
  9: @c6f5b440  length 8000002a status 0000002a
  10: @c6f5b480  length 8000002a status 0000002a
  11: @c6f5b4c0  length 8000002a status 0000002a
  12: @c6f5b500  length 8000002a status 0000002a
  13: @c6f5b540  length 8000002a status 0000002a
  14: @c6f5b580  length 8000002a status 0000002a
  15: @c6f5b5c0  length 8000002a status 8000002a
eth0: Resetting the Tx ring pointer.
eth0: Transmit error, Tx status register 90.
  Flags; bus-master 1, dirty 1(1) current 17(1)
  Transmit list 06f5b280 vs. c6f5b240.
  0: @c6f5b200  length 8000002a status 8000002a
  1: @c6f5b240  length 8000002a status 0000002a
  2: @c6f5b280  length 8000002a status 0000002a
  3: @c6f5b2c0  length 8000002a status 0000002a
  4: @c6f5b300  length 8000002a status 0000002a
  5: @c6f5b340  length 8000002a status 0000002a
  6: @c6f5b380  length 8000002a status 0000002a
  7: @c6f5b3c0  length 8000002a status 0000002a
  8: @c6f5b400  length 8000002a status 0000002a
  9: @c6f5b440  length 8000002a status 0000002a
  10: @c6f5b480  length 8000002a status 0000002a
  11: @c6f5b4c0  length 8000002a status 0000002a
  12: @c6f5b500  length 8000002a status 0000002a
  13: @c6f5b540  length 8000002a status 0000002a
  14: @c6f5b580  length 8000002a status 0000002a
  15: @c6f5b5c0  length 8000002a status 8000002a
NETDEV WATCHDOG: eth0: transmit timed out
eth0: transmit timed out, tx_status 00 status e000.
  diagnostics: net 0cc0 media 8802 dma 00000020.
  Flags; bus-master 1, dirty 1(1) current 17(1)
  Transmit list 00000000 vs. c6f5b240.
  0: @c6f5b200  length 8000002a status 8000002a
  1: @c6f5b240  length 8000002a status 0000002a
  2: @c6f5b280  length 8000002a status 0000002a
  3: @c6f5b2c0  length 8000002a status 0000002a
  4: @c6f5b300  length 8000002a status 0000002a
  5: @c6f5b340  length 8000002a status 0000002a
  6: @c6f5b380  length 8000002a status 0000002a
  7: @c6f5b3c0  length 8000002a status 0000002a
  8: @c6f5b400  length 8000002a status 0000002a
  9: @c6f5b440  length 8000002a status 0000002a
  10: @c6f5b480  length 8000002a status 0000002a
  11: @c6f5b4c0  length 8000002a status 0000002a
  12: @c6f5b500  length 8000002a status 0000002a
  13: @c6f5b540  length 8000002a status 0000002a
  14: @c6f5b580  length 8000002a status 0000002a
  15: @c6f5b5c0  length 8000002a status 8000002a
eth0: Resetting the Tx ring pointer.
eth0: Transmit error, Tx status register 90.
  Flags; bus-master 1, dirty 1(1) current 17(1)
  Transmit list 06f5b280 vs. c6f5b240.
  0: @c6f5b200  length 8000002a status 8000002a
  1: @c6f5b240  length 8000002a status 0000002a
  2: @c6f5b280  length 8000002a status 0000002a
  3: @c6f5b2c0  length 8000002a status 0000002a
  4: @c6f5b300  length 8000002a status 0000002a
  5: @c6f5b340  length 8000002a status 0000002a
  6: @c6f5b380  length 8000002a status 0000002a
  7: @c6f5b3c0  length 8000002a status 0000002a
  8: @c6f5b400  length 8000002a status 0000002a
  9: @c6f5b440  length 8000002a status 0000002a
  10: @c6f5b480  length 8000002a status 0000002a
  11: @c6f5b4c0  length 8000002a status 0000002a
  12: @c6f5b500  length 8000002a status 0000002a
  13: @c6f5b540  length 8000002a status 0000002a
  14: @c6f5b580  length 8000002a status 0000002a
  15: @c6f5b5c0  length 8000002a status 8000002a
NETDEV WATCHDOG: eth0: transmit timed out
eth0: transmit timed out, tx_status 00 status e000.
  diagnostics: net 0cc0 media 8802 dma 00000020.
  Flags; bus-master 1, dirty 1(1) current 17(1)
  Transmit list 00000000 vs. c6f5b240.
  0: @c6f5b200  length 8000002a status 8000002a
  1: @c6f5b240  length 8000002a status 0000002a
  2: @c6f5b280  length 8000002a status 0000002a
  3: @c6f5b2c0  length 8000002a status 0000002a
  4: @c6f5b300  length 8000002a status 0000002a
  5: @c6f5b340  length 8000002a status 0000002a
  6: @c6f5b380  length 8000002a status 0000002a
  7: @c6f5b3c0  length 8000002a status 0000002a
  8: @c6f5b400  length 8000002a status 0000002a
  9: @c6f5b440  length 8000002a status 0000002a
  10: @c6f5b480  length 8000002a status 0000002a
  11: @c6f5b4c0  length 8000002a status 0000002a
  12: @c6f5b500  length 8000002a status 0000002a
  13: @c6f5b540  length 8000002a status 0000002a
  14: @c6f5b580  length 8000002a status 0000002a
  15: @c6f5b5c0  length 8000002a status 8000002a
eth0: Resetting the Tx ring pointer.
eth0: Transmit error, Tx status register 90.
  Flags; bus-master 1, dirty 1(1) current 17(1)
  Transmit list 06f5b280 vs. c6f5b240.
  0: @c6f5b200  length 8000002a status 8000002a
  1: @c6f5b240  length 8000002a status 0000002a
  2: @c6f5b280  length 8000002a status 0000002a
  3: @c6f5b2c0  length 8000002a status 0000002a
  4: @c6f5b300  length 8000002a status 0000002a
  5: @c6f5b340  length 8000002a status 0000002a
  6: @c6f5b380  length 8000002a status 0000002a
  7: @c6f5b3c0  length 8000002a status 0000002a
  8: @c6f5b400  length 8000002a status 0000002a
  9: @c6f5b440  length 8000002a status 0000002a
  10: @c6f5b480  length 8000002a status 0000002a
  11: @c6f5b4c0  length 8000002a status 0000002a
  12: @c6f5b500  length 8000002a status 0000002a
  13: @c6f5b540  length 8000002a status 0000002a
  14: @c6f5b580  length 8000002a status 0000002a
  15: @c6f5b5c0  length 8000002a status 8000002a
NETDEV WATCHDOG: eth0: transmit timed out
eth0: transmit timed out, tx_status 00 status e000.
  diagnostics: net 0cc0 media 8802 dma 00000020.
  Flags; bus-master 1, dirty 1(1) current 17(1)
  Transmit list 00000000 vs. c6f5b240.
  0: @c6f5b200  length 8000002a status 8000002a
  1: @c6f5b240  length 8000002a status 0000002a
  2: @c6f5b280  length 8000002a status 0000002a
  3: @c6f5b2c0  length 8000002a status 0000002a
  4: @c6f5b300  length 8000002a status 0000002a
  5: @c6f5b340  length 8000002a status 0000002a
  6: @c6f5b380  length 8000002a status 0000002a
  7: @c6f5b3c0  length 8000002a status 0000002a
  8: @c6f5b400  length 8000002a status 0000002a
  9: @c6f5b440  length 8000002a status 0000002a
  10: @c6f5b480  length 8000002a status 0000002a
  11: @c6f5b4c0  length 8000002a status 0000002a
  12: @c6f5b500  length 8000002a status 0000002a
  13: @c6f5b540  length 8000002a status 0000002a
  14: @c6f5b580  length 8000002a status 0000002a
  15: @c6f5b5c0  length 8000002a status 8000002a
eth0: Resetting the Tx ring pointer.
eth0: Transmit error, Tx status register 90.
  Flags; bus-master 1, dirty 1(1) current 17(1)
  Transmit list 06f5b280 vs. c6f5b240.
  0: @c6f5b200  length 8000002a status 8000002a
  1: @c6f5b240  length 8000002a status 0000002a
  2: @c6f5b280  length 8000002a status 0000002a
  3: @c6f5b2c0  length 8000002a status 0000002a
  4: @c6f5b300  length 8000002a status 0000002a
  5: @c6f5b340  length 8000002a status 0000002a
  6: @c6f5b380  length 8000002a status 0000002a
  7: @c6f5b3c0  length 8000002a status 0000002a
  8: @c6f5b400  length 8000002a status 0000002a
  9: @c6f5b440  length 8000002a status 0000002a
  10: @c6f5b480  length 8000002a status 0000002a
  11: @c6f5b4c0  length 8000002a status 0000002a
  12: @c6f5b500  length 8000002a status 0000002a
  13: @c6f5b540  length 8000002a status 0000002a
  14: @c6f5b580  length 8000002a status 0000002a
  15: @c6f5b5c0  length 8000002a status 8000002a
NETDEV WATCHDOG: eth0: transmit timed out
eth0: transmit timed out, tx_status 00 status e000.
  diagnostics: net 0cc0 media 8802 dma 00000020.
  Flags; bus-master 1, dirty 1(1) current 17(1)
  Transmit list 00000000 vs. c6f5b240.
  0: @c6f5b200  length 8000002a status 8000002a
  1: @c6f5b240  length 8000002a status 0000002a
  2: @c6f5b280  length 8000002a status 0000002a
  3: @c6f5b2c0  length 8000002a status 0000002a
  4: @c6f5b300  length 8000002a status 0000002a
  5: @c6f5b340  length 8000002a status 0000002a
  6: @c6f5b380  length 8000002a status 0000002a
  7: @c6f5b3c0  length 8000002a status 0000002a
  8: @c6f5b400  length 8000002a status 0000002a
  9: @c6f5b440  length 8000002a status 0000002a
  10: @c6f5b480  length 8000002a status 0000002a
  11: @c6f5b4c0  length 8000002a status 0000002a
  12: @c6f5b500  length 8000002a status 0000002a
  13: @c6f5b540  length 8000002a status 0000002a
  14: @c6f5b580  length 8000002a status 0000002a
  15: @c6f5b5c0  length 8000002a status 8000002a
eth0: Resetting the Tx ring pointer.
eth0: Transmit error, Tx status register 90.
  Flags; bus-master 1, dirty 1(1) current 17(1)
  Transmit list 06f5b280 vs. c6f5b240.
  0: @c6f5b200  length 8000002a status 8000002a
  1: @c6f5b240  length 8000002a status 0000002a
  2: @c6f5b280  length 8000002a status 0000002a
  3: @c6f5b2c0  length 8000002a status 0000002a
  4: @c6f5b300  length 8000002a status 0000002a
  5: @c6f5b340  length 8000002a status 0000002a
  6: @c6f5b380  length 8000002a status 0000002a
  7: @c6f5b3c0  length 8000002a status 0000002a
  8: @c6f5b400  length 8000002a status 0000002a
  9: @c6f5b440  length 8000002a status 0000002a
  10: @c6f5b480  length 8000002a status 0000002a
  11: @c6f5b4c0  length 8000002a status 0000002a
  12: @c6f5b500  length 8000002a status 0000002a
  13: @c6f5b540  length 8000002a status 0000002a
  14: @c6f5b580  length 8000002a status 0000002a
  15: @c6f5b5c0  length 8000002a status 8000002a
NETDEV WATCHDOG: eth0: transmit timed out
eth0: transmit timed out, tx_status 00 status e000.
  diagnostics: net 0cc0 media 8802 dma 00000020.
  Flags; bus-master 1, dirty 1(1) current 17(1)
  Transmit list 00000000 vs. c6f5b240.
  0: @c6f5b200  length 8000002a status 8000002a
  1: @c6f5b240  length 8000002a status 0000002a
  2: @c6f5b280  length 8000002a status 0000002a
  3: @c6f5b2c0  length 8000002a status 0000002a
  4: @c6f5b300  length 8000002a status 0000002a
  5: @c6f5b340  length 8000002a status 0000002a
  6: @c6f5b380  length 8000002a status 0000002a
  7: @c6f5b3c0  length 8000002a status 0000002a
  8: @c6f5b400  length 8000002a status 0000002a
  9: @c6f5b440  length 8000002a status 0000002a
  10: @c6f5b480  length 8000002a status 0000002a
  11: @c6f5b4c0  length 8000002a status 0000002a
  12: @c6f5b500  length 8000002a status 0000002a
  13: @c6f5b540  length 8000002a status 0000002a
  14: @c6f5b580  length 8000002a status 0000002a
  15: @c6f5b5c0  length 8000002a status 8000002a
eth0: Resetting the Tx ring pointer.
eth0: Transmit error, Tx status register 90.
  Flags; bus-master 1, dirty 1(1) current 17(1)
  Transmit list 06f5b280 vs. c6f5b240.
  0: @c6f5b200  length 8000002a status 8000002a
  1: @c6f5b240  length 8000002a status 0000002a
  2: @c6f5b280  length 8000002a status 0000002a
  3: @c6f5b2c0  length 8000002a status 0000002a
  4: @c6f5b300  length 8000002a status 0000002a
  5: @c6f5b340  length 8000002a status 0000002a
  6: @c6f5b380  length 8000002a status 0000002a
  7: @c6f5b3c0  length 8000002a status 0000002a
  8: @c6f5b400  length 8000002a status 0000002a
  9: @c6f5b440  length 8000002a status 0000002a
  10: @c6f5b480  length 8000002a status 0000002a
  11: @c6f5b4c0  length 8000002a status 0000002a
  12: @c6f5b500  length 8000002a status 0000002a
  13: @c6f5b540  length 8000002a status 0000002a
  14: @c6f5b580  length 8000002a status 0000002a
  15: @c6f5b5c0  length 8000002a status 8000002a
NETDEV WATCHDOG: eth0: transmit timed out
eth0: transmit timed out, tx_status 00 status e000.
  diagnostics: net 0cc0 media 8802 dma 00000020.
  Flags; bus-master 1, dirty 1(1) current 17(1)
  Transmit list 00000000 vs. c6f5b240.
  0: @c6f5b200  length 8000002a status 8000002a
  1: @c6f5b240  length 8000002a status 0000002a
  2: @c6f5b280  length 8000002a status 0000002a
  3: @c6f5b2c0  length 8000002a status 0000002a
  4: @c6f5b300  length 8000002a status 0000002a
  5: @c6f5b340  length 8000002a status 0000002a
  6: @c6f5b380  length 8000002a status 0000002a
  7: @c6f5b3c0  length 8000002a status 0000002a
  8: @c6f5b400  length 8000002a status 0000002a
  9: @c6f5b440  length 8000002a status 0000002a
  10: @c6f5b480  length 8000002a status 0000002a
  11: @c6f5b4c0  length 8000002a status 0000002a
  12: @c6f5b500  length 8000002a status 0000002a
  13: @c6f5b540  length 8000002a status 0000002a
  14: @c6f5b580  length 8000002a status 0000002a
  15: @c6f5b5c0  length 8000002a status 8000002a
eth0: Resetting the Tx ring pointer.
eth0: Transmit error, Tx status register 90.
  Flags; bus-master 1, dirty 1(1) current 17(1)
  Transmit list 06f5b280 vs. c6f5b240.
  0: @c6f5b200  length 8000002a status 8000002a
  1: @c6f5b240  length 8000002a status 0000002a
  2: @c6f5b280  length 8000002a status 0000002a
  3: @c6f5b2c0  length 8000002a status 0000002a
  4: @c6f5b300  length 8000002a status 0000002a
  5: @c6f5b340  length 8000002a status 0000002a
  6: @c6f5b380  length 8000002a status 0000002a
  7: @c6f5b3c0  length 8000002a status 0000002a
  8: @c6f5b400  length 8000002a status 0000002a
  9: @c6f5b440  length 8000002a status 0000002a
  10: @c6f5b480  length 8000002a status 0000002a
  11: @c6f5b4c0  length 8000002a status 0000002a
  12: @c6f5b500  length 8000002a status 0000002a
  13: @c6f5b540  length 8000002a status 0000002a
  14: @c6f5b580  length 8000002a status 0000002a
  15: @c6f5b5c0  length 8000002a status 8000002a
eth0: Host error, FIFO diagnostic register 2000.
eth0: PCI bus error, bus status 00a00021
eth0: Media override to transceiver 6 (MII).
eth0: Host error, FIFO diagnostic register 2000.
eth0: PCI bus error, bus status 00000000
eth0: Media override to transceiver 6 (MII).
eth0: Host error, FIFO diagnostic register 2000.
eth0: PCI bus error, bus status 00000000
eth0: Media override to transceiver 6 (MII).
eth1: Host error, FIFO diagnostic register 2000.
eth1: PCI bus error, bus status 00000020
eth1: Media override to transceiver 6 (MII).
eth1: Host error, FIFO diagnostic register 2000.
eth1: PCI bus error, bus status 00000000
eth1: Media override to transceiver 6 (MII).
