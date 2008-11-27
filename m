From: Willy Tarreau <w@1wt.eu>
Subject: Re: WARNING: at net/sched/sch_generic.c:219 dev_watchdog+0xfe/0x17e() with tg3 network
Date: Thu, 27 Nov 2008 21:33:37 +0100
Message-ID: <20081127203337.GA2114@1wt.eu>
References: <20081120215318.GB27907@xw6200.broadcom.net> <20081124132744.GB24851@1wt.eu> <20081124215247.GA29696@1wt.eu> <20081125015223.GA9151@xw6200.broadcom.net> <20081125053128.GA32426@1wt.eu> <20081125175413.GA9808@xw6200.broadcom.net> <20081126211220.GA22374@1wt.eu> <20081126225421.GA8906@xw6200.broadcom.net> <20081127051659.GA26057@1wt.eu> <492E7142.3030002@hanzlici.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Matt Carlson <mcarlson@broadcom.com>,
	Roger Heflin <rogerheflin@gmail.com>,
	Peter Zijlstra <peterz@infradead.org>,
	LKML <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Frantisek Hanzlik <franta@hanzlici.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:1408 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752888AbYK0Udt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Nov 2008 15:33:49 -0500
Content-Disposition: inline
In-Reply-To: <492E7142.3030002@hanzlici.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 27, 2008 at 11:06:58AM +0100, Frantisek Hanzlik wrote:
> Willy Tarreau wrote:
> >On Wed, Nov 26, 2008 at 02:54:21PM -0800, Matt Carlson wrote:
> >(...)
> >>>I've run a new test on a switch I have here at home (another el-cheapo,
> >>>non-manageable 100 Mbps, netgear this time). Unfortunately I cannot
> >>>reproduce the problem at all. I have disabled FC on my laptop, it did
> >>>not have any effect.
> >>Disabling FC should have a positive effect, not a negative one.  It
> >>might be the case that the switch does not advertise nor support FC.  If
> >>that is true, you might not be able to repro the problem no matter what
> >>you did (if your problem is what I think it is).  Can you check your
> >>link messages and see if it really is negotiated to off?  (I see the
> >>message above, but I don't think that is with the current switch.)
> >
> >yes the switch does advertuse FC :
> >
> >willy@wtap:~$ dmesg|grep eth0
> >eth0: Tigon3 [partno(BMC5705mA3) rev 3003 PHY(5705)] (PCI:33MHz:32-bit) 
> >10/100/1000Base-T Ethernet 00:0d:9d:91:ef:24
> >eth0: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[0] WireSpeed[0] TSOcap[1]
> >eth0: dma_rwctrl[763f0000] dma_mask[64-bit]
> >tg3: eth0: Link is up at 100 Mbps, full duplex.
> >tg3: eth0: Flow control is on for TX and on for RX.
> >
> >>>I have disabled auto-neg and manually forced the
> >>>speed to 100/Full on my laptop, and could not reproduce the problem
> >>>either (though the speed was much lower due to the switch obviously
> >>>negociating 100/Half when not seeing my NWay frames).
> >>Yes.  If you force the link, both sides must be forced.  The switch
> >>rightly assumes HD when bringing the link up.
> >
> >I know ;-) but not seeing the problem, I started to suspect that the other
> >switch was a little bit ill and tried to reproduce some problems I might
> >incidently have been encountering on it.
> >
> >Regards,
> >Willy
> >
> I got same issue two days ago on PCI-X Fiber 1000BASE-SX D-Link Adapter
> DGE-550SX/dl2k driver (I report it yesterday). This card work fine in
> old DEC Alphaserver 800/Fedora Core 5/kernel 2.6.17. We use it for our
> internet connections, which is limited to approx. 50 Mb/sec by ISP,
> then I think there should be no bottleneck in LAN card.
> We just tried install new i386 based router (Core2Duo E8500/4GB RAM/
> 4x Realtek 8111C and this D-Link from old Alphaserver, on Fedora 10,
> kernel 2.6.27.5). Router is connected to several gigabit backbones
> over other ois gigabit cards, then I'm not sure when any crapped internal
> machines could overload this DGE-550SX. Card in new router stop working
> after several secs/minutes - packed transmitting freeze (what is
> interesting, in one case after it sent exactly 8192 packets, and other
> cases are some multiples of 8 too) and stop transmit packets.
> Only workaround (but for a while) is rmmod + modprobe its dl2k driver.

I had been facing this same issue 5-6 years ago when I tried my first
DL2K. It always stopped transmitting after a few hundreds of packets
on my machine while it was OK on another one. Mine was dual-athlon
with an AMD chipset. A working one was a P3-933 with a ServerWorks
chipset. I noticed that it would only lock up when plugged into a
64-bit slot, and it was fine in 32-bit slots (though it did work well
on the P3 in a 64-bit slot). It was such a crappy chip that I finally
threw it away, so I could not compare anymore. I'd bet that your new
machine is too fast for this beast and it triggers some bugs in the
chip, probably on the PCI side.

Regards,
Willy

