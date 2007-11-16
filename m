From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] NET : convert ip_rt_acct to per_cpu variables
Date: Fri, 16 Nov 2007 10:35:46 +0100
Message-ID: <20071116103546.8320d985.dada1@cosmosbay.com>
References: <20071116095903.d2ef9c14.dada1@cosmosbay.com>
	<20071116.011243.48184084.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:42532 "EHLO pfx2.jmh.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751572AbXKPJfq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Nov 2007 04:35:46 -0500
In-Reply-To: <20071116.011243.48184084.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 16 Nov 2007 01:12:43 -0800 (PST)
David Miller <davem@davemloft.net> wrote:

> From: Eric Dumazet <dada1@cosmosbay.com>
> Date: Fri, 16 Nov 2007 09:59:03 +0100
> 
> > [PATCH] NET : NET_CLS_ROUTE : convert ip_rt_acct to per_cpu variables
> > 
> > ip_rt_acct needs 4096 bytes per cpu to perform some accounting.
> > It is actually allocated as a single huge array [4096*NR_CPUS]
> > (rounded up to a power of two)
> > 
> > Converting it to a per cpu variable is wanted to :
> >  - Save space on machines were num_possible_cpus() < NR_CPUS
> >  - Better NUMA placement (each cpu gets memory on its node)
> > 
> > Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
> 
> This is better in one sense but worse in another.
> 
> At least the previous code dynamically allocated the thing,
> now at least one copy is taking up core kernel text image
> space.

Oh I see, you think that adding 4096 null bytes to the static percpu area might be a problem.

> 
> I think it's an alloc_percpu() candidate, what do you think?
> 

Yes absolutely, I will submit a new version.

Thank you

