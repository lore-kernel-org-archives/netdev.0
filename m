From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH] tcp: splice as many packets as possible at once
Date: Fri, 16 Jan 2009 00:42:55 +0100
Message-ID: <20090115234255.GE1123@1wt.eu>
References: <20090115231934.GA8328@gondor.apana.org.au> <20090115.152608.89323697.davem@davemloft.net> <20090115233205.GA8474@gondor.apana.org.au> <20090115.153449.204259387.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, jarkao2@gmail.com, zbr@ioremap.net,
	dada1@cosmosbay.com, ben@zeus.com, mingo@elte.hu,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jens.axboe@oracle.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:1530 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755865AbZAOXnO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Jan 2009 18:43:14 -0500
Content-Disposition: inline
In-Reply-To: <20090115.153449.204259387.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 15, 2009 at 03:34:49PM -0800, David Miller wrote:
> From: Herbert Xu <herbert@gondor.apana.org.au>
> Date: Fri, 16 Jan 2009 10:32:05 +1100
> 
> > On Thu, Jan 15, 2009 at 03:26:08PM -0800, David Miller wrote:
> > > +static inline struct page *linear_to_page(struct page *page, unsigned int len,
> > > +					  unsigned int offset)
> > > +{
> > > +	struct page *p = alloc_pages(GFP_KERNEL, 0);
> > > +
> > > +	if (!p)
> > > +		return NULL;
> > > +	memcpy(page_address(p) + offset, page_address(page) + offset, len);
> > 
> > This won't work very well if skb->head is longer than a page.
> > 
> > We'll need to divide it up into individual pages.
> 
> Oh yes the same bug I pointed out the other day.
> 
> But Willy can test this patch as-is,

Hey, nice work Dave. +3% performance from your previous patch
(31.6 MB/s). It's going fine and stable here.

> since he is not using jumbo frames in linear SKBs.

If you're interested, this week-end I can do some tests on my
myri10ge NICs which support LRO. I frequently observe 23 kB
packets there, and they also support jumbo frames. Those should
cover the case above.

I'm afraid that's all for me for this evening, I have to get some
sleep before going to work. If you want to cook up more patches,
I'll be able to do a bit of testing in 5 hours now.

Cheers!
Willy

