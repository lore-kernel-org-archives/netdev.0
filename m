From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH take 2] pkt_sched: Fix qdisc_watchdog() vs.
	dev_deactivate() race
Date: Thu, 21 Aug 2008 06:49:41 +0000
Message-ID: <20080821064941.GA2764@ff.dom.local>
References: <20080819.040200.155911269.davem@davemloft.net> <20080819164830.GA2533@ami.dom.local> <20080819222329.GA10297@gondor.apana.org.au> <20080821054911.GA4178@ff.dom.local> <20080821061024.GA721@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.174]:35619 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755187AbYHUGtr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Aug 2008 02:49:47 -0400
Received: by ug-out-1314.google.com with SMTP id c2so952176ugf.37
        for <netdev@vger.kernel.org>; Wed, 20 Aug 2008 23:49:46 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080821061024.GA721@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 21, 2008 at 04:10:24PM +1000, Herbert Xu wrote:
...
> > diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
> > index 84d25f2..b1d2cfe 100644
> > --- a/include/net/sch_generic.h
> > +++ b/include/net/sch_generic.h
> > @@ -193,6 +193,11 @@ static inline struct Qdisc *qdisc_root(struct Qdisc *qdisc)
> >  	return qdisc->dev_queue->qdisc;
> >  }
> >  
> > +static inline struct Qdisc *qdisc_root_sleeping(struct Qdisc *qdisc)
> > +{
> > +	return qdisc->dev_queue->qdisc_sleeping;
> > +}
> 
> When would we actually want the non-sleeping variant?
> 

We need to check if something depends on &noop_qdisc returned in the
similar state. Otherwise, there is a bit too much possibilities here,
so it would be nice to simplify this all.

Thanks,
Jarek P.
