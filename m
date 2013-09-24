From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] net: net_secret should not depend on TCP
Date: Tue, 24 Sep 2013 17:28:58 +0200
Message-ID: <20130924152858.GB1527@order.stressinduktion.org>
References: <alpine.DEB.2.02.1309231535030.23896@tomh.mtv.corp.google.com> <1379980991.3165.37.camel@edumazet-glaptop> <20130924023038.GA22393@order.stressinduktion.org> <20130924033505.GB22393@order.stressinduktion.org> <1380001118.3165.41.camel@edumazet-glaptop> <20130924054532.GA24446@order.stressinduktion.org> <1380028797.3165.65.camel@edumazet-glaptop> <20130924151333.GA1527@order.stressinduktion.org> <1380036147.3165.72.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Tom Herbert <therbert@google.com>, davem@davemloft.net,
	netdev@vger.kernel.org, jesse.brandeburg@intel.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:47917 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751559Ab3IXP27 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Sep 2013 11:28:59 -0400
Content-Disposition: inline
In-Reply-To: <1380036147.3165.72.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 24, 2013 at 08:22:27AM -0700, Eric Dumazet wrote:
> On Tue, 2013-09-24 at 17:13 +0200, Hannes Frederic Sowa wrote:
> > On Tue, Sep 24, 2013 at 06:19:57AM -0700, Eric Dumazet wrote:
> > > -void net_secret_init(void)
> > > +static u32 net_secret[NET_SECRET_SIZE] ____cacheline_aligned;
> > > +
> > > +static void net_secret_init(void)
> > >  {
> > > -	get_random_bytes(net_secret, sizeof(net_secret));
> > > +	u32 tmp;
> > > +	int i;
> > > +
> > > +	if (likely(net_secret[0]))
> > > +		return;
> > > +
> > > +	for (i = NET_SECRET_SIZE; i > 0;) {
> > > +		do {
> > > +			get_random_bytes(&tmp, sizeof(tmp));
> > > +		} while (!tmp);
> > 
> > I am afraid we can block here on embedded systems in an atomic section? Is
> > this actually an issue? It does get called in a spin_lock_h.
> 
> I do not see issues : get_random_bytes() is irq safe.

But couldn't it be that get_random_bytes always returns 0 and we won't make
any progress here. Does the reseed happen from irq context or from softirqs? I
always thought it would be from a softirq (which could be blocked).

Thanks,

  Hannes
