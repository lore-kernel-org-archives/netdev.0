From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: 2.6.24 BUG: soft lockup - CPU#X
Date: Fri, 28 Mar 2008 19:06:21 +0800
Message-ID: <20080328110621.GA23342@gondor.apana.org.au>
References: <47EC399E.90804@sun.com> <20080327.173418.18777696.davem@davemloft.net> <20080328012234.GA20465@gondor.apana.org.au> <20080327.183844.74572930.davem@davemloft.net> <20080328102931.GA23039@gondor.apana.org.au> <20080328105629.GG1011@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, Matheos.Worku@Sun.COM,
	jesse.brandeburg@intel.com, jarkao2@gmail.com,
	netdev@vger.kernel.org, hadi@cyberus.ca
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:42497 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750852AbYC1LGh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2008 07:06:37 -0400
Content-Disposition: inline
In-Reply-To: <20080328105629.GG1011@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 28, 2008 at 11:56:29AM +0100, Ingo Molnar wrote:
>
> hm, what's the context of this discussion? The call chain looks ok, 
> that's how we preempt tasks from the timer tick. But other code besides 
> the scheduler shouldnt do this.

The code under discussion is __qdisc_run from net/sched/sch_generic.c.

It runs with BH off from either process context or softirq context.
As it is it can keep running forever.  We were discussing adding
a need_resched check in there.  So the question is would need_resched
ever get updated while BH is disabled?

Anyway, I've just realised that even if it does get updated, we still
need a better bound to avoid starving other local softirq events so
this is probably moot.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
