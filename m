From: Ingo Molnar <mingo@elte.hu>
Subject: Re: 2.6.24 BUG: soft lockup - CPU#X
Date: Fri, 28 Mar 2008 15:09:24 +0100
Message-ID: <20080328140924.GC29218@elte.hu>
References: <47EC399E.90804@sun.com> <20080327.173418.18777696.davem@davemloft.net> <20080328012234.GA20465@gondor.apana.org.au> <20080327.183844.74572930.davem@davemloft.net> <20080328102931.GA23039@gondor.apana.org.au> <20080328105629.GG1011@elte.hu> <20080328110621.GA23342@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, Matheos.Worku@Sun.COM,
	jesse.brandeburg@intel.com, jarkao2@gmail.com,
	netdev@vger.kernel.org, hadi@cyberus.ca
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:39136 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752708AbYC1OJu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Mar 2008 10:09:50 -0400
Content-Disposition: inline
In-Reply-To: <20080328110621.GA23342@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Herbert Xu <herbert@gondor.apana.org.au> wrote:

> On Fri, Mar 28, 2008 at 11:56:29AM +0100, Ingo Molnar wrote:
> >
> > hm, what's the context of this discussion? The call chain looks ok, 
> > that's how we preempt tasks from the timer tick. But other code besides 
> > the scheduler shouldnt do this.
> 
> The code under discussion is __qdisc_run from net/sched/sch_generic.c.
> 
> It runs with BH off from either process context or softirq context. As 
> it is it can keep running forever.  We were discussing adding a 
> need_resched check in there.  So the question is would need_resched 
> ever get updated while BH is disabled?

yes, certainly - as long as the timer irq is allowed. (i.e. hardirqs are 
not disabled) The scheduler tick runs from hardirq context, not from 
softirq context. (that's how we can preempt softirq threads on the -rt 
kernel for example)

	Ingo
