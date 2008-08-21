From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH take 2] pkt_sched: Fix qdisc_watchdog() vs. dev_deactivate() race
Date: Thu, 21 Aug 2008 16:10:24 +1000
Message-ID: <20080821061024.GA721@gondor.apana.org.au>
References: <20080819.040200.155911269.davem@davemloft.net> <20080819164830.GA2533@ami.dom.local> <20080819222329.GA10297@gondor.apana.org.au> <20080821054911.GA4178@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:44113 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751827AbYHUGKa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Aug 2008 02:10:30 -0400
Content-Disposition: inline
In-Reply-To: <20080821054911.GA4178@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 21, 2008 at 05:49:11AM +0000, Jarek Poplawski wrote:
> ---------------> (take 2)
> 
> pkt_sched: Fix qdisc_watchdog() vs. dev_deactivate() race
> 
> dev_deactivate() can skip rescheduling of a qdisc by qdisc_watchdog()
> or other timer calling netif_schedule() after dev_queue_deactivate().
> We prevent this checking aliveness before scheduling the timer. Since
> during deactivation the root qdisc is available only as qdisc_sleeping
> additional accessor qdisc_root_sleeping() is created.
> 
> With feedback from Herbert Xu <herbert@gondor.apana.org.au>
> 
> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

Good catch!
 
> diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
> index 84d25f2..b1d2cfe 100644
> --- a/include/net/sch_generic.h
> +++ b/include/net/sch_generic.h
> @@ -193,6 +193,11 @@ static inline struct Qdisc *qdisc_root(struct Qdisc *qdisc)
>  	return qdisc->dev_queue->qdisc;
>  }
>  
> +static inline struct Qdisc *qdisc_root_sleeping(struct Qdisc *qdisc)
> +{
> +	return qdisc->dev_queue->qdisc_sleeping;
> +}

When would we actually want the non-sleeping variant?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
