From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] pkt_sched: Destroy gen estimators under rtnl_lock().
Date: Wed, 20 Aug 2008 08:23:29 +1000
Message-ID: <20080819222329.GA10297@gondor.apana.org.au>
References: <20080819.040200.155911269.davem@davemloft.net> <20080819164830.GA2533@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:39617 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753164AbYHSWXg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Aug 2008 18:23:36 -0400
Content-Disposition: inline
In-Reply-To: <20080819164830.GA2533@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 19, 2008 at 06:48:31PM +0200, Jarek Poplawski wrote:
> 
> I can miss something, but probably it's needed in __netif_reschedule()

No this is a genuine bug.  However, it's also an old bug :) Even
with the locking and RCU barrier it could have occured.

> yet. Here is a scenario:
> 
> cpu1				cpu2
> dev_deactivate()
> dev_deactivate_queue()
> qdisc_reset()
> 				qdisc_run()
> 				qdisc_watchdog_schedule()
> 				(or hrtimer_restart in cbq)

We should add an aliveness check before scheduling the timer.  This
is the slow path so adding a check shouldn't hurt.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
