From: Tomas Papan <tomas.papan@gmail.com>
Subject: Re: 3.4-rc: NETDEV WATCHDOG: eth0 (r8169): transmit queue 0 timed out
Date: Mon, 11 Jun 2012 15:55:55 +0000 (UTC)
Message-ID: <loom.20120611T175322-643@post.gmane.org>
References: <20120501182405.3dda59b9@stein> <20120501172748.GA17117@electric-eye.fr.zoreil.com> <20120501200423.6804dcf0@stein> <20120501200403.GA20763@electric-eye.fr.zoreil.com> <20120503204813.65468df7@stein> <20120602111335.0b94fb59@stein>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:46991 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751972Ab2FKQAJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Jun 2012 12:00:09 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1Se72E-0000Ij-9z
	for netdev@vger.kernel.org; Mon, 11 Jun 2012 18:00:06 +0200
Received: from dial-109-230-4-153.orange.sk ([109.230.4.153])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 11 Jun 2012 18:00:06 +0200
Received: from tomas.papan by dial-109-230-4-153.orange.sk with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 11 Jun 2012 18:00:06 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stefan Richter <stefanr <at> s5r6.in-berlin.de> writes:

> 
> On May 03 Stefan Richter wrote:
> > On May 01 Francois Romieu wrote:
> > [...]
> > > Can you apply the patch below on top of current ethtool
> > > (git://git.kernel.org/pub/scm/network/ethtool/ethtool.git) and see
> > > if it is enough to compare the register dumps (ethtool -d eth0).
> > [...]
> > > This is a firmware free chipset anyway. Nothing strange in the interface
> > > stats (ethtool -S eth0) ?
> > > 
> > > You may have to narrow things. Can you check if the r8169.c at
> > > 036dafa28da1e2565a8529de2ae663c37b7a0060 behaves the same ?
> > 
> > I will follow up on this eventually, but it may take quite some time due
> > to interfering work.
> > 
> > Thank you for looking into it and giving directions,
> 
> I haven't had time to look further into it yet.  Just two minor findings:
> 
> (a) After update from 3.4-rc5 to 3.4, the problem persisted.
> 
> (b) Later I noticed that silent file corruptions on FireWire disks happened
> and happen under 3.4-rc5 and 3.4, so I reverted into 3.3.1 which fixed
> that issue.  Furthermore, since 6 days uptime of 3.3.1, the eth0 (r8169)
> transmit queue time-out did never occur.
> 
> I have no idea whether the FireWire and networking issues might be somehow
> connected, and I still lack time to investigate these issues (using Linux
> only at home, not at work), but I will eventually get back to it.


Hi,

I have the same problem on 3.4.1 and 3.4.2 (3.2.x is fine)
interestingly enough, the problem occurs only once, then it is running fine
(3.4.1 and six days uptime)


WARNING: at net/sched/sch_generic.c:256 dev_watchdog+0x16b/0x20f()
[ 2839.337554] Pid: 0, comm: swapper/3 Not tainted 3.4.2 #1
[ 2839.337556] Call Trace:
[ 2839.337559]  <IRQ>  [<ffffffff81026881>] ? warn_slowpath_common+0x78/0x8c
[ 2839.337571]  [<ffffffff81026936>] ? warn_slowpath_fmt+0x45/0x4a
[ 2839.337576]  [<ffffffff81042fc2>] ? scheduler_tick+0xaf/0xc3
[ 2839.337582]  [<ffffffff812535a0>] ? dev_watchdog+0x16b/0x20f
[ 2839.337588]  [<ffffffff8102f3ae>] ? run_timer_softirq+0x177/0x209
[ 2839.337594]  [<ffffffff8103e7b3>] ? hrtimer_interrupt+0x100/0x19b
[ 2839.337599]  [<ffffffff81253435>] ? qdisc_reset+0x35/0x35
[ 2839.337605]  [<ffffffff8102b256>] ? __do_softirq+0x7f/0x106
[ 2839.337611]  [<ffffffff812e298c>] ? call_softirq+0x1c/0x30
[ 2839.337616]  [<ffffffff81003376>] ? do_softirq+0x31/0x67
[ 2839.337621]  [<ffffffff8102b503>] ? irq_exit+0x44/0x75
[ 2839.337625]  [<ffffffff810032b5>] ? do_IRQ+0x94/0xad
[ 2839.337631]  [<ffffffff812e10a7>] ? common_interrupt+0x67/0x67
[ 2839.337634]  <EOI>  [<ffffffff81163f07>] ? intel_idle+0xde/0x103
[ 2839.337645]  [<ffffffff81163ee3>] ? intel_idle+0xba/0x103
[ 2839.337652]  [<ffffffff81220bfa>] ? cpuidle_idle_call+0x7e/0xc4
[ 2839.337659]  [<ffffffff81008e92>] ? cpu_idle+0x53/0x7c
[ 2839.337663] ---[ end trace 04a2b9c09e9d7860 ]---
[ 2839.341697] r8169 0000:01:00.0: eth1: link up

Regards
Tomas
