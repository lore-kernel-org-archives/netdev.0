From: Ingo Molnar <mingo@elte.hu>
Subject: Re: 2.6.24 BUG: soft lockup - CPU#X
Date: Fri, 28 Mar 2008 11:56:29 +0100
Message-ID: <20080328105629.GG1011@elte.hu>
References: <47EC399E.90804@sun.com> <20080327.173418.18777696.davem@davemloft.net> <20080328012234.GA20465@gondor.apana.org.au> <20080327.183844.74572930.davem@davemloft.net> <20080328102931.GA23039@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, Matheos.Worku@Sun.COM,
	jesse.brandeburg@intel.com, jarkao2@gmail.com,
	netdev@vger.kernel.org, hadi@cyberus.ca
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:38744 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752122AbYC1K47 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Mar 2008 06:56:59 -0400
Content-Disposition: inline
In-Reply-To: <20080328102931.GA23039@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Herbert Xu <herbert@gondor.apana.org.au> wrote:

> > This runs from softirqs, the local thread's scheduling state is 
> > updated from timers which also run from softirqs, so this 
> > need_resched() test won't work.
> 
> I had a trawl through the scheduler/timer code and it appears that 
> even with softirqs disabled we should able to set the flag through 
> this call chain (on x86-32):
> 
> timer_interrupt => do_timer_interrupt_hook => tick_handle_periodic => 
> tick_periodic => update_process_times => scheduler_tick
> 
> Ingo, could you confirm that the scheduler is capable of setting 
> need_resched even with BH disabled?

hm, what's the context of this discussion? The call chain looks ok, 
that's how we preempt tasks from the timer tick. But other code besides 
the scheduler shouldnt do this.

	Ingo
