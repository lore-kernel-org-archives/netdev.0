From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: [RFC] export irq_set/get_affinity() for multiqueue network
 drivers
Date: Fri, 29 Aug 2008 09:52:03 -0700
Message-ID: <20080829095203.5732f331@infradead.org>
References: <48B708E1.4070001@inria.fr>
	<20080829055023.07966b4a@infradead.org>
	<8763pjpy2b.fsf@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Brice Goglin <Brice.Goglin@inria.fr>,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:39087 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752769AbYH2QwB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Aug 2008 12:52:01 -0400
In-Reply-To: <8763pjpy2b.fsf@basil.nowhere.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 29 Aug 2008 18:48:12 +0200
Andi Kleen <andi@firstfloor.org> wrote:

> Arjan van de Ven <arjan@infradead.org> writes:
> 
> > On Thu, 28 Aug 2008 22:21:53 +0200
> > Brice Goglin <Brice.Goglin@inria.fr> wrote:
> >
> >> Hello,
> >> 
> >> Is there any way to setup IRQ masks from within a driver? myri10ge
> >> currently relies on an external script (writing in
> >> /proc/irq/*/smp_affinity) to bind each queue/MSI-X to a different
> >> processor. By default, Linux will either:
> >> * round-robin the interrupts (killing the benefit of DCA for
> >> instance)
> >> * put all IRQs on the same CPU (killing much of th
> >
> > * do the right thing with the userspace irq balancer
> 
> It probably also needs to be hooked up the sched_mc_power_savings
> When the switch is on the interrupts shouldn't be spread out over
> that many sockets.

that's what irqbalance already does today.

> 
> Also I suspect handling SMT explicitely is a good idea. e.g. I would
> always set the affinity to all thread siblings in a core, not 
> just a single one, because context switch is very cheap between them.

that is what irqbalance already does today, at least for what it
considers somewhat slower irqs.
for networking it still sucks because the packet reordering logic is
per logical cpu so you still don't want to receive packets from the
same "stream" over multiple logical cpus.



-- 
If you want to reach me at my work email, use arjan@linux.intel.com
For development, discussion and tips for power savings, 
visit http://www.lesswatts.org
