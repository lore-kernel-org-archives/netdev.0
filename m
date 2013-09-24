From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: net_secret should not depend on TCP
Date: Tue, 24 Sep 2013 08:22:27 -0700
Message-ID: <1380036147.3165.72.camel@edumazet-glaptop>
References: <alpine.DEB.2.02.1309231535030.23896@tomh.mtv.corp.google.com>
	 <1379980991.3165.37.camel@edumazet-glaptop>
	 <20130924023038.GA22393@order.stressinduktion.org>
	 <20130924033505.GB22393@order.stressinduktion.org>
	 <1380001118.3165.41.camel@edumazet-glaptop>
	 <20130924054532.GA24446@order.stressinduktion.org>
	 <1380028797.3165.65.camel@edumazet-glaptop>
	 <20130924151333.GA1527@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <therbert@google.com>, davem@davemloft.net,
	netdev@vger.kernel.org, jesse.brandeburg@intel.com
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f51.google.com ([209.85.160.51]:46550 "EHLO
	mail-pb0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753005Ab3IXPWa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Sep 2013 11:22:30 -0400
Received: by mail-pb0-f51.google.com with SMTP id jt11so4676646pbb.38
        for <netdev@vger.kernel.org>; Tue, 24 Sep 2013 08:22:29 -0700 (PDT)
In-Reply-To: <20130924151333.GA1527@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-09-24 at 17:13 +0200, Hannes Frederic Sowa wrote:
> On Tue, Sep 24, 2013 at 06:19:57AM -0700, Eric Dumazet wrote:
> > -void net_secret_init(void)
> > +static u32 net_secret[NET_SECRET_SIZE] ____cacheline_aligned;
> > +
> > +static void net_secret_init(void)
> >  {
> > -	get_random_bytes(net_secret, sizeof(net_secret));
> > +	u32 tmp;
> > +	int i;
> > +
> > +	if (likely(net_secret[0]))
> > +		return;
> > +
> > +	for (i = NET_SECRET_SIZE; i > 0;) {
> > +		do {
> > +			get_random_bytes(&tmp, sizeof(tmp));
> > +		} while (!tmp);
> 
> I am afraid we can block here on embedded systems in an atomic section? Is
> this actually an issue? It does get called in a spin_lock_h.

I do not see issues : get_random_bytes() is irq safe.
