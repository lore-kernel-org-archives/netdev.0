From: Martin Michlmayr <tbm@cyrius.com>
Subject: Re: r8169 driver problem with RTL8110SB chip (on iop3xx ARM board)
Date: Thu, 3 Aug 2006 17:48:36 +0200
Message-ID: <20060803154836.GJ31534@deprecation.cyrius.com>
References: <20060728104946.GA6710@electric-eye.fr.zoreil.com> <20060728111534.GD25854@xi.wantstofly.org> <20060728115237.GF21733@deprecation.cyrius.com> <20060728194933.GA14222@electric-eye.fr.zoreil.com> <20060728203437.GA6253@deprecation.cyrius.com> <20060802180244.GA32235@deprecation.cyrius.com> <20060802221629.GB28282@electric-eye.fr.zoreil.com> <20060803135349.GH31534@deprecation.cyrius.com> <20060803142309.GA17166@deprecation.cyrius.com> <20060803150556.GA9433@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Lennert Buytenhek <buytenh@wantstofly.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sorrow.cyrius.com ([65.19.161.204]:48652 "EHLO
	sorrow.cyrius.com") by vger.kernel.org with ESMTP id S932580AbWHCPsk
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Aug 2006 11:48:40 -0400
To: Francois Romieu <romieu@fr.zoreil.com>
Content-Disposition: inline
In-Reply-To: <20060803150556.GA9433@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Francois Romieu <romieu@fr.zoreil.com> [2006-08-03 17:05]:
> > >From 192.168.1.2 icmp_seq=62 Destination Host Unreachable
> > >From 192.168.1.2 icmp_seq=63 Destination Host Unreachable
> > NETDEV WATCHDOG: eth0: transmit timed out
> > CmdTxEnb: 0x4
> > CmdTxEnb: 0x8
> > ChipCmd (before): 0x0
> > ChipCmd (after): 0xc
> > trying again...
> > ChipCmd: 0xc
> > >From 192.168.1.2 icmp_seq=64 Destination Host Unreachable
> > >From 192.168.1.2 icmp_seq=65 Destination Host Unreachable
> > >From 192.168.1.2 icmp_seq=66 Destination Host Unreachable
> 
> Did you take the dump right after 'ifconfig ... up' ? Otherwise, the
> watchdog may quickly come into play.

Oh, yes, when I do
    ifup eth0 ; ethtool -d eth0
I get better results.


RealTek RTL-8110 registers:
------------------------------
0x00: MAC Address                      00:14:fd:10:27:74
0x08: Multicast Address Filter     0x00000000 0x00000000
0x10: Dump Tally Counter Command   0xdfbbfac0 0xff74b67b
0x20: Tx Normal Priority Ring Addr 0x00000000 0x00000000
0x28: Tx High Priority Ring Addr   0xeffc2b00 0x7ef5f6ac
0x30: Flash memory read/write                 0x00000000
0x34: Early Rx Byte Count                              0
0x36: Early Rx Status                               0x00
0x37: Command                                       0x0c
      Rx on, Tx on
0x3C: Interrupt Mask                              0x807f
      SERR RxFIFO LinkChg RxNoBuf TxErr TxOK RxErr RxOK
0x3E: Interrupt Status                            0x0000

0x40: Tx Configuration                        0x13000600
0x44: Rx Configuration                        0x0000e60e
0x48: Timer count                             0x00630fd8
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
0x84: PM wakeup frame 0            0xbcfe6f7f 0xdffffe8f
0x8C: PM wakeup frame 1            0xabf6cb3f 0xff7bdbbd
0x94: PM wakeup frame 2 (low)      0xdfbaeed7 0xbdbfbffd
0x9C: PM wakeup frame 2 (high)     0xaa75befc 0xcb5feab9
0xA4: PM wakeup frame 3 (low)      0xbbdf67df 0xff7e65b3
0xAC: PM wakeup frame 3 (high)     0xbbdffbb1 0xff7c7fff
0xB4: PM wakeup frame 4 (low)      0x7f3bde9f 0x3bbffa7d
0xBC: PM wakeup frame 4 (high)     0x2e9ffdcd 0x36c8bbff
0xC4: Wakeup frame 0 CRC                          0x9abf
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
0xE4: Rx Ring Addr                 0x06ff1000 0x00000000
0xEC: Early Tx threshold                            0x3f

-- 
Martin Michlmayr
http://www.cyrius.com/
