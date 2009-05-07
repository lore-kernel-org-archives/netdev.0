From: Jon Smirl <jonsmirl@gmail.com>
Subject: Help interpreting MII negotiation
Date: Wed, 6 May 2009 22:03:39 -0400
Message-ID: <9e4733910905061903x693ca36av38ff4cc9aef4ce38@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f125.google.com ([209.85.221.125]:64388 "EHLO
	mail-qy0-f125.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751745AbZEGCDk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2009 22:03:40 -0400
Received: by qyk31 with SMTP id 31so867559qyk.33
        for <netdev@vger.kernel.org>; Wed, 06 May 2009 19:03:40 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I don't understand why speed selection is getting set at 10Mbps in this example.
It looks to me like the devices auto negotiated 100Mbps.

uboot> mii dump 0 0
0.     (1000)                 -- PHY control register --
 (8000:0000) 0.15    =     0    reset
 (4000:0000) 0.14    =     0    loopback
 (2040:0000) 0. 6,13 =   b00    speed selection = 10 Mbps
 (1000:1000) 0.12    =     1    A/N enable
 (0800:0000) 0.11    =     0    power-down
 (0400:0000) 0.10    =     0    isolate
 (0200:0000) 0. 9    =     0    restart A/N
 (0100:0000) 0. 8    =     0    duplex = half
 (0080:0000) 0. 7    =     0    collision test enable
 (003f:0000) 0. 5- 0 =     0    (reserved)


uboot> mii dump 0 1
1.     (786d)                 -- PHY status register --
 (8000:0000) 1.15    =     0    100BASE-T4 able
 (4000:4000) 1.14    =     1    100BASE-X  full duplex able
 (2000:2000) 1.13    =     1    100BASE-X  half duplex able
 (1000:1000) 1.12    =     1    10 Mbps    full duplex able
 (0800:0800) 1.11    =     1    10 Mbps    half duplex able
 (0400:0000) 1.10    =     0    100BASE-T2 full duplex able
 (0200:0000) 1. 9    =     0    100BASE-T2 half duplex able
 (0100:0000) 1. 8    =     0    extended status
 (0080:0000) 1. 7    =     0    (reserved)
 (0040:0040) 1. 6    =     1    MF preamble suppression
 (0020:0020) 1. 5    =     1    A/N complete
 (0010:0000) 1. 4    =     0    remote fault
 (0008:0008) 1. 3    =     1    A/N able
 (0004:0004) 1. 2    =     1    link status
 (0002:0000) 1. 1    =     0    jabber detect
 (0001:0001) 1. 0    =     1    extended capabilities


uboot> mii dump 0 2
2.     (0022)                 -- PHY ID 1 register --
 (ffff:0022) 2.15- 0 =    34    OUI portion


uboot> mii dump 0 3
3.     (161a)                 -- PHY ID 2 register --
 (fc00:1400) 3.15-10 =     5    OUI portion
 (03f0:0210) 3. 9- 4 =    33    manufacturer part number
 (000f:000a) 3. 3- 0 =    10    manufacturer rev. number


uboot> mii dump 0 4
4.     (01e1)                 -- Autonegotiation advertisement register --
 (8000:0000) 4.15    =     0    next page able
 (4000:0000) 4.14    =     0    reserved
 (2000:0000) 4.13    =     0    remote fault
 (1000:0000) 4.12    =     0    reserved
 (0800:0000) 4.11    =     0    asymmetric pause
 (0400:0000) 4.10    =     0    pause enable
 (0200:0000) 4. 9    =     0    100BASE-T4 able
 (0100:0100) 4. 8    =     1    100BASE-TX full duplex able
 (0080:0080) 4. 7    =     1    100BASE-TX able
 (0040:0040) 4. 6    =     1    10BASE-T   full duplex able
 (0020:0020) 4. 5    =     1    10BASE-T   able
 (001f:0001) 4. 4- 0 =     1    selector = IEEE 802.3


uboot> mii dump 0 5
5.     (c5e1)                 -- Autonegotiation partner abilities register --
 (8000:8000) 5.15    =     1    next page able
 (4000:4000) 5.14    =     1    acknowledge
 (2000:0000) 5.13    =     0    remote fault
 (1000:0000) 5.12    =     0    (reserved)
 (0800:0000) 5.11    =     0    asymmetric pause able
 (0400:0400) 5.10    =     1    pause able
 (0200:0000) 5. 9    =     0    100BASE-T4 able
 (0100:0100) 5. 8    =     1    100BASE-X full duplex able
 (0080:0080) 5. 7    =     1    100BASE-TX able
 (0040:0040) 5. 6    =     1    10BASE-T full duplex able
 (0020:0020) 5. 5    =     1    10BASE-T able
 (001f:0001) 5. 4- 0 =     1    selector = IEEE 802.3

Another example. This PHY device does not support autonegotiation and is
fixed at 100Mbs. Why is speed selection 10 Mbps in this case?

digiboot> mii dump 2 0
0.     (0000)                 -- PHY control register --
  (8000:0000) 0.15    =     0    reset
  (4000:0000) 0.14    =     0    loopback
  (2040:0000) 0. 6,13 =   b00    speed selection = 10 Mbps
  (1000:0000) 0.12    =     0    A/N enable
  (0800:0000) 0.11    =     0    power-down
  (0400:0000) 0.10    =     0    isolate
  (0200:0000) 0. 9    =     0    restart A/N
  (0100:0000) 0. 8    =     0    duplex = half
  (0080:0000) 0. 7    =     0    collision test enable
  (003f:0000) 0. 5- 0 =     0    (reserved)


digiboot> mii dump 2 1
1.     (2005)                 -- PHY status register --
  (8000:0000) 1.15    =     0    100BASE-T4 able
  (4000:0000) 1.14    =     0    100BASE-X  full duplex able
  (2000:2000) 1.13    =     1    100BASE-X  half duplex able
  (1000:0000) 1.12    =     0    10 Mbps    full duplex able
  (0800:0000) 1.11    =     0    10 Mbps    half duplex able
  (0400:0000) 1.10    =     0    100BASE-T2 full duplex able
  (0200:0000) 1. 9    =     0    100BASE-T2 half duplex able
  (0100:0000) 1. 8    =     0    extended status
  (0080:0000) 1. 7    =     0    (reserved)
  (0040:0000) 1. 6    =     0    MF preamble suppression
  (0020:0000) 1. 5    =     0    A/N complete
  (0010:0000) 1. 4    =     0    remote fault
  (0008:0000) 1. 3    =     0    A/N able
  (0004:0004) 1. 2    =     1    link status
  (0002:0000) 1. 1    =     0    jabber detect
  (0001:0001) 1. 0    =     1    extended capabilities


digiboot> mii dump 2 2
2.     (0012)                 -- PHY ID 1 register --
  (ffff:0012) 2.15- 0 =    18    OUI portion


digiboot> mii dump 2 3
3.     (1c01)                 -- PHY ID 2 register --
  (fc00:1c00) 3.15-10 =     7    OUI portion
  (03f0:0000) 3. 9- 4 =     0    manufacturer part number
  (000f:0001) 3. 3- 0 =     1    manufacturer rev. number


digiboot> mii dump 2 4
4.     (0000)                 -- Autonegotiation advertisement register --
  (8000:0000) 4.15    =     0    next page able
  (4000:0000) 4.14    =     0    reserved
  (2000:0000) 4.13    =     0    remote fault
  (1000:0000) 4.12    =     0    reserved
  (0800:0000) 4.11    =     0    asymmetric pause
  (0400:0000) 4.10    =     0    pause enable
  (0200:0000) 4. 9    =     0    100BASE-T4 able
  (0100:0000) 4. 8    =     0    100BASE-TX full duplex able
  (0080:0000) 4. 7    =     0    100BASE-TX able
  (0040:0000) 4. 6    =     0    10BASE-T   full duplex able
  (0020:0000) 4. 5    =     0    10BASE-T   able
  (001f:0000) 4. 4- 0 =     0    selector = ???




-- 
Jon Smirl
jonsmirl@gmail.com
