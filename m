From: Steve Langasek <vorlon@debian.org>
Subject: [Thecus 2100] r8169 won't talk 100Mbps when cross-connected to PC?
Date: Sat, 25 Jul 2009 17:00:17 +0200
Message-ID: <20090725150016.GC22703@dario.dodds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: romieu@fr.zoreil.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from minbar.dodds.net ([66.93.39.86]:53905 "EHLO minbar.dodds.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751098AbZGYPHF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Jul 2009 11:07:05 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi folks,

Per request of Martin Michlmayr, I'm sending you information about a curious
issue I'm experiencing with the ethernet on my Thecus 2100, running the
stock Debian 2.6.30 kernel package from unstable.

$ uname -a
Linux becquer 2.6.30-1-iop32x #1 Mon Jun 15 05:25:53 UTC 2009 armv5tel GNU/Linux
$ lspci -nn | grep Eth
00:01.0 Ethernet controller [0200]: Realtek Semiconductor Co., Ltd. RTL-8169 Gigabit Ethernet [10ec:8169] (rev 10)
00:02.0 Ethernet controller [0200]: Realtek Semiconductor Co., Ltd. RTL-8169 Gigabit Ethernet [10ec:8169] (rev 10)
$

If I connect this system to a 10/100Mbps netgear switch, it happily
negotiates 100baseTx-FD and chats away with the world:

# mii-diag eth0
Basic registers of MII PHY #32:  1000 796d 001c c913 0de1 45e1 0005 2001.
 The autonegotiated capability is 01e0.
The autonegotiated media type is 100baseTx-FD.
 Basic mode control register 0x1000: Auto-negotiation enabled.
 You have link beat, and everything is working OK.
 Your link partner advertised 45e1: Flow-control 100baseTx-FD 100baseTx
 10baseT-FD 10baseT, w/ 802.3X flow control.
   End of basic transceiver information.

#

If, however, I connect it with a crossover cable to either my mythtv box
(SiS900, max speed 100Mbps), or to my laptop (Intel 82573 GigE) hard-coded
to only negotiate 100Mbps, the Thecus successfully sends frames out
(verified with tcpdump), but never sees the replies from the other end.

If I poke things into either GigE mode or 10Mbps mode, it works fine.  But
this is somewhat unsatisfactory given that I want it hooked up to the box
with the SiS chip, and would rather not have it running at 10Mbps. :)

Cheers,
-- 
Steve Langasek                   Give me a lever long enough and a Free OS
Debian Developer                   to set it on, and I can move the world.
Ubuntu Developer                                    http://www.debian.org/
slangasek@ubuntu.com                                     vorlon@debian.org
