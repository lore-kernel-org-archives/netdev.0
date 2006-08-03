From: Martin Michlmayr <tbm@cyrius.com>
Subject: Re: r8169 driver problem with RTL8110SB chip (on iop3xx ARM board)
Date: Thu, 3 Aug 2006 12:31:19 +0200
Message-ID: <20060803103119.GG31534@deprecation.cyrius.com>
References: <20060728101109.GA25854@xi.wantstofly.org> <20060728104946.GA6710@electric-eye.fr.zoreil.com> <20060728111534.GD25854@xi.wantstofly.org> <20060728115237.GF21733@deprecation.cyrius.com> <20060728194933.GA14222@electric-eye.fr.zoreil.com> <20060728203437.GA6253@deprecation.cyrius.com> <20060802180244.GA32235@deprecation.cyrius.com> <20060802221629.GB28282@electric-eye.fr.zoreil.com> <20060802222623.GA27185@xi.wantstofly.org> <20060803081023.GA7502@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Lennert Buytenhek <buytenh@wantstofly.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sorrow.cyrius.com ([65.19.161.204]:25098 "EHLO
	sorrow.cyrius.com") by vger.kernel.org with ESMTP id S932402AbWHCKbx
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Aug 2006 06:31:53 -0400
To: Francois Romieu <romieu@fr.zoreil.com>
Content-Disposition: inline
In-Reply-To: <20060803081023.GA7502@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Francois Romieu <romieu@fr.zoreil.com> [2006-08-03 10:10]:
> If so I would welcome the same dump that Martin sent on 2006/07/28 (
> Message-ID: <20060728115237.GF21733@deprecation.cyrius.com>) applied to
> the kernel r8169 driver after it has been ifconfiged up.

I'm not sure what the state of the interface was last time, but this
time I made sure it was up - however, it doesn't make any difference:
ChipCmd is still not set.  Any idea?


dhcppc3:~# ifconfig | head -2
eth0      Link encap:Ethernet  HWaddr 00:14:FD:10:27:74
          inet addr:192.168.1.2  Bcast:192.168.1.255 Mask:255.255.255.0


RealTek RTL-8110 registers:
------------------------------
0x00: MAC Address                      00:14:fd:10:27:74
0x08: Multicast Address Filter     0x00000000 0x00000000
0x10: Dump Tally Counter Command   0xd7bbfac0 0xf754b27b
0x20: Tx Normal Priority Ring Addr 0x00000000 0x00000000
0x28: Tx High Priority Ring Addr   0xeffc2f00 0x7ef5f68c
0x30: Flash memory read/write                 0x00000000
0x34: Early Rx Byte Count                              0
0x36: Early Rx Status                               0x00
0x37: Command                                       0x00
      Rx off, Tx off
0x3C: Interrupt Mask                              0x0000

0x3E: Interrupt Status                            0x0000

0x40: Tx Configuration                        0x10000000
0x44: Rx Configuration                        0x00000002
0x48: Timer count                             0x1c7c67d2
0x4C: Missed packet counter                     0x000000
0x50: EEPROM Command                                0x00
0x51: Config 0                                      0x04
0x52: Config 1                                      0x1f
0x53: Config 2                                      0x10
0x54: Config 3                                      0x20
0x55: Config 4                                      0x80
0x56: Config 5                                      0x01
0x58: Timer interrupt                         0x00000000
0x5C: Multiple Interrupt Select                   0x0000
0x60: PHY access                              0x80001000
0x64: TBI control and status                  0x00000000
0x68: TBI Autonegotiation advertisement (ANAR)    0x0000
0x6A: TBI Link partner ability (LPAR)             0x0000
0x6C: PHY status                                    0x0b
0x84: PM wakeup frame 0            0xbcfa6f7f 0xd7fffe8f
0x8C: PM wakeup frame 1            0xa3f6cb3f 0xff7bdbbd
0x94: PM wakeup frame 2 (low)      0xdfbaefd7 0xbdbfbffd
0x9C: PM wakeup frame 2 (high)     0xaa71befc 0xc35aeab9
0xA4: PM wakeup frame 3 (low)      0xbbdf67df 0xf77e65b3
0xAC: PM wakeup frame 3 (high)     0xbbdef9b1 0xff7c7fff
0xB4: PM wakeup frame 4 (low)      0x7f3bde9f 0x3bbefa7c
0xBC: PM wakeup frame 4 (high)     0xae9fbdcd 0x36c8bbff
0xC4: Wakeup frame 0 CRC                          0xdaaf
0xC6: Wakeup frame 1 CRC                          0xffbf
0xC8: Wakeup frame 2 CRC                          0xaebf
0xCA: Wakeup frame 3 CRC                          0x2ffe
0xCC: Wakeup frame 4 CRC                          0xdc23
0xDA: RX packet maximum size                      0x3fff
0xE0: C+ Command                                  0x2028
      RX checksumming
      PCI Multiple RW
0xE2: Interrupt Mitigation                        0x0000
      TxTimer:       0
      TxPackets:     0
      RxTimer:       0
      RxPackets:     0
0xE4: Rx Ring Addr                 0x07422000 0x00000000
0xEC: Early Tx threshold                            0x3f

diff to the output from last time doesn't show any significant
changes:

--- r1	2006-08-03 12:24:07.000000000 +0200
+++ r2	2006-08-03 12:26:29.000000000 +0200
@@ -2,9 +2,9 @@
 ------------------------------
 0x00: MAC Address                      00:14:fd:10:27:74
 0x08: Multicast Address Filter     0x00000000 0x00000000
-0x10: Dump Tally Counter Command   0xd7bbfec0 0xfb74b6fb
+0x10: Dump Tally Counter Command   0xd7bbfac0 0xf754b27b
 0x20: Tx Normal Priority Ring Addr 0x00000000 0x00000000
-0x28: Tx High Priority Ring Addr   0xfffc3f00 0xfef7f6ad
+0x28: Tx High Priority Ring Addr   0xeffc2f00 0x7ef5f68c
 0x30: Flash memory read/write                 0x00000000
 0x34: Early Rx Byte Count                              0
 0x36: Early Rx Status                               0x00
@@ -16,7 +16,7 @@
 
 0x40: Tx Configuration                        0x10000000
 0x44: Rx Configuration                        0x00000002
-0x48: Timer count                             0x95887845
+0x48: Timer count                             0x1c7c67d2
 0x4C: Missed packet counter                     0x000000
 0x50: EEPROM Command                                0x00
 0x51: Config 0                                      0x04
@@ -31,20 +31,20 @@
 0x64: TBI control and status                  0x00000000
 0x68: TBI Autonegotiation advertisement (ANAR)    0x0000
 0x6A: TBI Link partner ability (LPAR)             0x0000
-0x6C: PHY status                                    0x6b
-0x84: PM wakeup frame 0            0xbcfeef7f 0xdffffe9f
-0x8C: PM wakeup frame 1            0xabf7cf3f 0xfffbdbbf
-0x94: PM wakeup frame 2 (low)      0xdfbbfedf 0xbfbffffd
-0x9C: PM wakeup frame 2 (high)     0xaa75befc 0xcb5feaf9
-0xA4: PM wakeup frame 3 (low)      0xbbdf6fdf 0xff7e75b7
-0xAC: PM wakeup frame 3 (high)     0xbbdffbf9 0xfbfcffff
-0xB4: PM wakeup frame 4 (low)      0x7f3bde9f 0x3bbffa7f
-0xBC: PM wakeup frame 4 (high)     0xae9fbdcd 0x32c8bbff
-0xC4: Wakeup frame 0 CRC                          0x9aff
-0xC6: Wakeup frame 1 CRC                          0xfdbf
-0xC8: Wakeup frame 2 CRC                          0xaeff
-0xCA: Wakeup frame 3 CRC                          0x6bfe
-0xCC: Wakeup frame 4 CRC                          0xdc2f
+0x6C: PHY status                                    0x0b
+0x84: PM wakeup frame 0            0xbcfa6f7f 0xd7fffe8f
+0x8C: PM wakeup frame 1            0xa3f6cb3f 0xff7bdbbd
+0x94: PM wakeup frame 2 (low)      0xdfbaefd7 0xbdbfbffd
+0x9C: PM wakeup frame 2 (high)     0xaa71befc 0xc35aeab9
+0xA4: PM wakeup frame 3 (low)      0xbbdf67df 0xf77e65b3
+0xAC: PM wakeup frame 3 (high)     0xbbdef9b1 0xff7c7fff
+0xB4: PM wakeup frame 4 (low)      0x7f3bde9f 0x3bbefa7c
+0xBC: PM wakeup frame 4 (high)     0xae9fbdcd 0x36c8bbff
+0xC4: Wakeup frame 0 CRC                          0xdaaf
+0xC6: Wakeup frame 1 CRC                          0xffbf
+0xC8: Wakeup frame 2 CRC                          0xaebf
+0xCA: Wakeup frame 3 CRC                          0x2ffe
+0xCC: Wakeup frame 4 CRC                          0xdc23
 0xDA: RX packet maximum size                      0x3fff
 0xE0: C+ Command                                  0x2028
       RX checksumming
@@ -54,5 +54,5 @@
       TxPackets:     0
       RxTimer:       0
       RxPackets:     0
-0xE4: Rx Ring Addr                 0x07bd4000 0x00000000
+0xE4: Rx Ring Addr                 0x07422000 0x00000000
 0xEC: Early Tx threshold                            0x3f

-- 
Martin Michlmayr
http://www.cyrius.com/
