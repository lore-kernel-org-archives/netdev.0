From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: question about softirqs
Date: Wed, 13 May 2009 17:54:03 +0200 (CEST)
Message-ID: <alpine.LFD.2.00.0905131751150.3561@localhost.localdomain>
References: <18948.63755.279732.294842@cargo.ozlabs.ibm.com> <20090508.234815.127227651.davem@davemloft.net> <4A086DB2.8040703@nortel.com> <20090511.162436.193717082.davem@davemloft.net> <4A08C62F.1050105@nortel.com> <20090512081237.GA16403@elte.hu>
 <4A09933B.8010606@nortel.com> <874ovpmmdq.fsf@basil.nowhere.org> <4A0AC9EC.6070908@nortel.com> <20090513141532.GT19296@one.firstfloor.org> <alpine.LFD.2.00.0905131612180.3561@localhost.localdomain> <87my9hkrmw.fsf@basil.nowhere.org>
 <4A0AE19D.9040509@nortel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Andi Kleen <andi@firstfloor.org>, Ingo Molnar <mingo@elte.hu>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Steven Rostedt <rostedt@goodmis.org>,
	David Miller <davem@davemloft.net>, linuxppc-dev@ozlabs.org,
	paulus@samba.org, netdev@vger.kernel.org
To: Chris Friesen <cfriesen@nortel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.tglx.de ([62.245.132.106]:39855 "EHLO www.tglx.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757877AbZEMPyr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 May 2009 11:54:47 -0400
In-Reply-To: <4A0AE19D.9040509@nortel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 13 May 2009, Chris Friesen wrote:
> Andi Kleen wrote:
> > Thomas Gleixner <tglx@linutronix.de> writes:
> 
> >>Err, no. Chris is completely correct:
> >>
> >>        if (!in_interrupt())
> >>		wakeup_softirqd();
> > 
> > Yes you have to wake it up just in case, but it doesn't normally
> > process the data because a normal softirq comes in faster. It's
> > just a safety policy. 
> 
> What about the scenario I raised earlier, where we have incoming network
> packets, no hardware interrupts coming in other than the timer tick, and
> a high-priority userspace app is spinning on recvmsg() with MSG_DONTWAIT
> set?
> 
> As far as I can tell, in this scenario softirqs may not get processed on
> return from a syscall (contradicting the documentation).  In the worst
> case, they may not get processed until the next timer tick.

Right because your high prio tasks prevents that ksoftirqd runs,
because it can not preempt the high priority task.

Thanks,

	tglx
