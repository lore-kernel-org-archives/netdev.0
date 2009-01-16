From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] tcp: splice as many packets as possible at once
Date: Fri, 16 Jan 2009 06:51:08 +0000
Message-ID: <20090116065107.GA4170@ff.dom.local>
References: <20090115231934.GA8328@gondor.apana.org.au> <20090115.152608.89323697.davem@davemloft.net> <20090115233205.GA8474@gondor.apana.org.au> <20090115.153449.204259387.davem@davemloft.net> <20090115234255.GE1123@1wt.eu> <20090115234408.GA1693@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, herbert@gondor.apana.org.au,
	zbr@ioremap.net, dada1@cosmosbay.com, ben@zeus.com, mingo@elte.hu,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jens.axboe@oracle.com
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f31.google.com ([209.85.219.31]:43826 "EHLO
	mail-ew0-f31.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755320AbZAPGvP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jan 2009 01:51:15 -0500
Content-Disposition: inline
In-Reply-To: <20090115234408.GA1693@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 16, 2009 at 12:44:08AM +0100, Willy Tarreau wrote:
> On Fri, Jan 16, 2009 at 12:42:55AM +0100, Willy Tarreau wrote:
> > On Thu, Jan 15, 2009 at 03:34:49PM -0800, David Miller wrote:
> > > From: Herbert Xu <herbert@gondor.apana.org.au>
> > > Date: Fri, 16 Jan 2009 10:32:05 +1100
> > > 
> > > > On Thu, Jan 15, 2009 at 03:26:08PM -0800, David Miller wrote:
> > > > > +static inline struct page *linear_to_page(struct page *page, unsigned int len,
> > > > > +					  unsigned int offset)
> > > > > +{
> > > > > +	struct page *p = alloc_pages(GFP_KERNEL, 0);
> > > > > +
> > > > > +	if (!p)
> > > > > +		return NULL;
> > > > > +	memcpy(page_address(p) + offset, page_address(page) + offset, len);
> > > > 
> > > > This won't work very well if skb->head is longer than a page.
> > > > 
> > > > We'll need to divide it up into individual pages.
> > > 
> > > Oh yes the same bug I pointed out the other day.
> > > 
> > > But Willy can test this patch as-is,
> > 
> > Hey, nice work Dave. +3% performance from your previous patch
> > (31.6 MB/s). It's going fine and stable here.
> 
> And BTW feel free to add my Tested-by if you want in case you merge
> this fix.
> 
> Willy
> 

Herbert, good catch!

David, if it's not too late I think more credits are needed,
especially for Willy. He did "a bit" more than testing.

Alas, I can't see this problem with skb->head longer than page. There
is even some comment on this in __splice_segment(), but I can miss
something.

I'm more concerned with memory usage if these skbs are not acked for
some reason. Isn't there some DOS issue possible?

Thanks everybody,
Jarek P.
--------->
Based on a review by Changli Gao <xiaosuo@gmail.com>:
http://lkml.org/lkml/2008/2/26/210

Foreseen-by: Changli Gao <xiaosuo@gmail.com>
Diagnosed-by: Willy Tarreau <w@1wt.eu>
Reported-by: Willy Tarreau <w@1wt.eu>
Fixed-by: Jens Axboe <jens.axboe@oracle.com>
Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
