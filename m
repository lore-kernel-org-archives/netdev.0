From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sched: Optimize return value of qdisc_restart
Date: Thu, 10 May 2007 04:55:34 -0700 (PDT)
Message-ID: <20070510.045534.90119358.davem@davemloft.net>
References: <1178725965.4058.75.camel@localhost>
	<OFF9085DDC.F5960247-ON652572D7.001B794E-652572D7.001CA7E2@in.ibm.com>
	<20070510115039.GA24439@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: krkumar2@in.ibm.com, hadi@cyberus.ca, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45670
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755098AbXEJLzb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 May 2007 07:55:31 -0400
In-Reply-To: <20070510115039.GA24439@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 10 May 2007 21:50:39 +1000

> On Thu, May 10, 2007 at 10:42:59AM +0530, Krishna Kumar2 wrote:
> > 
> > But RUNNING is never relinquished till all the way back out to
> > __qdisc_run. Only the lock is dropped before calling xmit and
> > re-got after xmit is finished (all the while holding RUNNING).
> > After xmit both queue_lock and RUNNING are held. If some other
> > cpu enqueue'd during this release window (and they would have
> > returned after dropping the lock as they are pure enqueuer's),
> > qdisc_restart will find those skbs. Similarly if no skbs were
> > added, qdisc_restart will return 0.
> 
> Yes I agree with Krishna completely.  In fact this whole section
> is so 20th-century :) Let's fix up the comments too while we're
> at it.
> 
> [NET_SCHED]: Rationalise return value of qdisc_restart
> 
> The current return value scheme and associated comment was invented
> back in the 20th century when we still had that tbusy flag.  Things
> have changed quite a bit since then (even Tony Blair is moving on
> now, not to mention the new French president).
> 
> All we need to indicate now is whether the caller should continue
> processing the queue.  Therefore it's sufficient if we return 0 if
> we want to stop and non-zero otherwise.
> 
> This is based on a patch by Krishna Kumar.
> 
> Signed-off-by: <herbert@gondor.apana.org.au>

Fair enough, patch applied :-)
