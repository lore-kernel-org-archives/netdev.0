From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] pkt_sched: Destroy gen estimators under rtnl_lock().
Date: Tue, 19 Aug 2008 20:51:33 +1000
Message-ID: <20080819105133.GA30020@gondor.apana.org.au>
References: <20080817.184921.08829673.davem@davemloft.net> <20080818212946.GB3366@ami.dom.local> <20080818.164748.86676462.davem@davemloft.net> <20080819103151.GA6408@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:43883 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751761AbYHSKvk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Aug 2008 06:51:40 -0400
Content-Disposition: inline
In-Reply-To: <20080819103151.GA6408@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 19, 2008 at 10:31:51AM +0000, Jarek Poplawski wrote:
>
> > > >  void __netif_schedule(struct Qdisc *q)
> > > >  {
> > > > +	if (unlikely(test_bit(__QDISC_STATE_DEACTIVATED, &q->state)))
> > > > +		return;
> > > 
> > > Why I can't see this code in net-2.6? BTW, I guess it should be now
> > > moved to the current __netif_reschedule()? 
> > 
> > I deleted it, it's unnecessary with your "both bits clear" fix
> > which I also added.
> 
> Herbert was concerned earlier with this:
> "What I mean is the extremely unlikely scenario of net_tx_action
> always failing on trylock because dev_deactivate has grabbed the
> lock to check whether net_tx_action has completed."
> 
> So, I guess this could help here.

Right.  Even though the live-lock is an extremely unlikely event,
as the aliveness flag check isn't on the fast path anyway I think
we should keep it.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
