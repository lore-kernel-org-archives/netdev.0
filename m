From: Ben Greear <greearb@candelatech.com>
Subject: locked up my rtl8139C chip, connected to a 10bt hub.
Date: Fri, 21 Feb 2003 15:12:05 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3E56B245.9040704@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I can repeatedly lock up my rtl8139C NIC.  So far, it's always
been the one connected to a 10bt hub.  I have been running it as
fast as it can go, and it generally ides in 2-4 hours....

Driver:  stock RH 8.0 kernel, seems to be rtl8139too 0.9.25

Here is the output from rtldiag as found on Becker's site.
There is also some damning critique of the rtl8139too...any
truth to the accusations? :)

I have found bouncing the link does not necessarily fix it as long as
I keep trying to generate traffic.  However, bouncing the link and waiting
about 20 seconds to start traffic again seems to un-jam it.

Let me know if I can offer some more info.

It's the last chip down that seems to be the main culprit....


rtl8139-diag.c:v2.10 9/18/2002 Donald Becker (becker@scyld.com)
  http://www.scyld.com/diag/index.html
Index #1: Found a RealTek RTL8139 adapter at 0xd800.
RealTek chip registers at 0xd800
  0x000: 03f31000 000065a6 80000000 00000000 000ea0ba 000ea0ba 000ea0b6 000ea0b6
  0x020: 06b0e000 06b0e600 06b0ec00 06b0f200 069f0000 0d0a0000 173c172c 0000c07f
  0x040: 74000680 0000f78e 09c6002b 00000000 008d1000 00000000 0088c510 00100000
  0x060: 1100f00f 01e1782d 000145e1 00000000 00000004 000207c8 b0f243b9 8a36df43.
Realtek station address 00:10:f3:03:a6:65, chip type 'rtl8139C'.
   Receiver configuration: Normal unicast and hashed multicast
      Rx FIFO threshold 2048 bytes, maximum burst 2048 bytes, 32KB ring
   Transmitter enabled with NONSTANDARD! settings, maximum burst 1024 bytes.
     Tx entry #0 status 000ea0ba complete, 186 bytes.
     Tx entry #1 status 000ea0ba complete, 186 bytes.
     Tx entry #2 status 000ea0b6 complete, 182 bytes.
     Tx entry #3 status 000ea0b6 complete, 182 bytes.
   Flow control: Tx disabled  Rx disabled.
   The chip configuration is 0x10 0x8d, MII half-duplex mode.
   No interrupt sources are pending.
  The RTL8139 does not use a MII transceiver.
  It does have internal MII-compatible registers:
    Basic mode control register   0x1100.
    Basic mode status register    0x782d.
    Autonegotiation Advertisement 0x01e1.
    Link Partner Ability register 0x45e1.
    Autonegotiation expansion     0x0001.
    Disconnects                   0x0000.
    False carrier sense counter   0x0000.
    NWay test register            0x0004.
    Receive frame error count     0x0000.
  MII PHY #32 transceiver registers:
    1100 782d 0000 0000 01e1 45e1 0001 0000
    0000 0000 0000 0000 0000 0000 0000 0000
    0000 0000 0000 0000 0000 0000 0000 0000
    0000 0000 0000 0000 0000 0000 0000 0000.
  Basic mode control register 0x1100: Auto-negotiation enabled.
  Basic mode status register 0x782d ... 782d.
    Link status: established.
    Capable of  100baseTx-FD 100baseTx 10baseT-FD 10baseT.
    Able to perform Auto-negotiation, negotiation complete.
  This transceiver has no vendor identification.
  I'm advertising 01e1: 100baseTx-FD 100baseTx 10baseT-FD 10baseT
    Advertising no additional info pages.
    IEEE 802.3 CSMA/CD protocol.
  Link partner capability is 45e1: Flow-control 100baseTx-FD 100baseTx 10baseT-FD 10baseT.
    Negotiation  completed.
Index #2: Found a RealTek RTL8139 adapter at 0xdc00.
RealTek chip registers at 0xdc00
  0x000: 03f31000 000064a6 ffffffff ffffffff 000aa03c 000aa03c 000aa03c 000aa03c
  0x020: 06d50000 06d50600 06d50c00 06d51200 00420000 0d0a0000 389c388c 0000c07f
  0x040: 74000680 0000f78f 09c62a83 00000000 008d1000 00000000 0088c510 00100000
  0x060: 1100f00f 01e1782d 000141e1 00000000 00000004 000417c8 b0f243b9 8a36df43.
Realtek station address 00:10:f3:03:a6:64, chip type 'rtl8139C'.
   Receiver configuration: Promiscuous
      Rx FIFO threshold 2048 bytes, maximum burst 2048 bytes, 32KB ring
   Transmitter enabled with NONSTANDARD! settings, maximum burst 1024 bytes.
     Tx entry #0 status 000aa03c complete, 60 bytes.
     Tx entry #1 status 000aa03c complete, 60 bytes.
     Tx entry #2 status 000aa03c complete, 60 bytes.
     Tx entry #3 status 000aa03c complete, 60 bytes.
   Flow control: Tx disabled  Rx disabled.
   The chip configuration is 0x10 0x8d, MII half-duplex mode.
   No interrupt sources are pending.
  The RTL8139 does not use a MII transceiver.
  It does have internal MII-compatible registers:
    Basic mode control register   0x1100.
    Basic mode status register    0x782d.
    Autonegotiation Advertisement 0x01e1.
    Link Partner Ability register 0x41e1.
    Autonegotiation expansion     0x0001.
    Disconnects                   0x0000.
    False carrier sense counter   0x0000.
    NWay test register            0x0004.
    Receive frame error count     0x0000.
  MII PHY #32 transceiver registers:
    1100 782d 0000 0000 01e1 41e1 0001 0000
    0000 0000 0000 0000 0000 0000 0000 0000
    0000 0000 0000 0000 0000 0000 0000 0000
    0000 0000 0000 0000 0000 0000 0000 0000.
  Basic mode control register 0x1100: Auto-negotiation enabled.
  Basic mode status register 0x782d ... 782d.
    Link status: established.
    Capable of  100baseTx-FD 100baseTx 10baseT-FD 10baseT.
    Able to perform Auto-negotiation, negotiation complete.
  This transceiver has no vendor identification.
  I'm advertising 01e1: 100baseTx-FD 100baseTx 10baseT-FD 10baseT
    Advertising no additional info pages.
    IEEE 802.3 CSMA/CD protocol.
  Link partner capability is 41e1: 100baseTx-FD 100baseTx 10baseT-FD 10baseT.
    Negotiation  completed.
Index #3: Found a RealTek RTL8139 adapter at 0xe000.
RealTek chip registers at 0xe000
  0x000: 03f31000 000063a6 ffffffff ffffffff 9008a5ea 9008a042 9008a5ea 9008a5ea
  0x020: 06022000 06022600 06022c00 06023200 02980000 0d0a0000 44e844d8 0000c07f
  0x040: 74000680 0000f78f 09c6771d 00000000 008d1000 00000000 0088c518 00100000
  0x060: 1000f00f 01e1782d 00000000 00000000 00000005 000f77c0 b0f243b9 8a36df43.
Realtek station address 00:10:f3:03:a6:63, chip type 'rtl8139C'.
   Receiver configuration: Promiscuous
      Rx FIFO threshold 2048 bytes, maximum burst 2048 bytes, 32KB ring
   Transmitter enabled with NONSTANDARD! settings, maximum burst 1024 bytes.
     Tx entry #0 status 9008a5ea complete, 1514 bytes.
    Tx carrier lost
     Tx entry #1 status 9008a042 complete, 66 bytes.
    Tx carrier lost
     Tx entry #2 status 9008a5ea complete, 1514 bytes.
    Tx carrier lost
     Tx entry #3 status 9008a5ea complete, 1514 bytes.
    Tx carrier lost
   Flow control: Tx disabled  Rx disabled.
   The chip configuration is 0x10 0x8d, MII half-duplex mode.
   No interrupt sources are pending.
  The RTL8139 does not use a MII transceiver.
  It does have internal MII-compatible registers:
    Basic mode control register   0x1000.
    Basic mode status register    0x782d.
    Autonegotiation Advertisement 0x01e1.
    Link Partner Ability register 0x0000.
    Autonegotiation expansion     0x0000.
    Disconnects                   0x0000.
    False carrier sense counter   0x0000.
    NWay test register            0x0005.
    Receive frame error count     0x0000.
  MII PHY #32 transceiver registers:
    1000 782d 0000 0000 01e1 0000 0000 0000
    0000 0000 0000 0000 0000 0000 0000 0000
    0000 0000 0000 0000 0000 0000 0000 0000
    0000 0000 0000 0000 0000 0000 0000 0000.
  Basic mode control register 0x1000: Auto-negotiation enabled.
  Basic mode status register 0x782d ... 782d.
    Link status: established.
    Capable of  100baseTx-FD 100baseTx 10baseT-FD 10baseT.
    Able to perform Auto-negotiation, negotiation complete.
  This transceiver has no vendor identification.
  I'm advertising 01e1: 100baseTx-FD 100baseTx 10baseT-FD 10baseT
    Advertising no additional info pages.
    IEEE 802.3 CSMA/CD protocol.
  Link partner capability is 0000:.
    Negotiation did not complete.



-- 
Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
President of Candela Technologies Inc      http://www.candelatech.com
ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear
