From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] pkt_sched: Destroy gen estimators under rtnl_lock().
Date: Tue, 19 Aug 2008 10:31:51 +0000
Message-ID: <20080819103151.GA6408@ff.dom.local>
References: <20080817.184921.08829673.davem@davemloft.net> <20080818212946.GB3366@ami.dom.local> <20080818.164748.86676462.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f29.google.com ([209.85.217.29]:56702 "EHLO
	mail-gx0-f29.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753095AbYHSKcA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Aug 2008 06:32:00 -0400
Received: by gxk10 with SMTP id 10so6725453gxk.13
        for <netdev@vger.kernel.org>; Tue, 19 Aug 2008 03:31:58 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080818.164748.86676462.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 18, 2008 at 04:47:48PM -0700, David Miller wrote:
> From: Jarek Poplawski <jarkao2@gmail.com>
> Date: Mon, 18 Aug 2008 23:29:46 +0200
> 
> > Two little doubts below:
> > 
> > > diff --git a/net/core/dev.c b/net/core/dev.c
> > > index 600bb23..b88f669 100644
> > > --- a/net/core/dev.c
> > > +++ b/net/core/dev.c
> > > @@ -1341,6 +1341,9 @@ static void dev_queue_xmit_nit(struct sk_buff *skb, struct net_device *dev)
> > >  
> > >  void __netif_schedule(struct Qdisc *q)
> > >  {
> > > +	if (unlikely(test_bit(__QDISC_STATE_DEACTIVATED, &q->state)))
> > > +		return;
> > > +
> > 
> > Why I can't see this code in net-2.6? BTW, I guess it should be now
> > moved to the current __netif_reschedule()? 
> 
> I deleted it, it's unnecessary with your "both bits clear" fix
> which I also added.

Herbert was concerned earlier with this:
"What I mean is the extremely unlikely scenario of net_tx_action
always failing on trylock because dev_deactivate has grabbed the
lock to check whether net_tx_action has completed."

So, I guess this could help here.

Jarek P.
