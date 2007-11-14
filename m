From: David Miller <davem@davemloft.net>
Subject: Re: 2.6.24-rc2: Network commit causes SLUB performance regression
 with tbench
Date: Tue, 13 Nov 2007 17:58:04 -0800 (PST)
Message-ID: <20071113.175804.151698768.davem@davemloft.net>
References: <200711101229.35822.nickpiggin@yahoo.com.au>
	<Pine.LNX.4.64.0711121144001.26936@schroedinger.engr.sgi.com>
	<200711132241.59074.nickpiggin@yahoo.com.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: clameter@sgi.com, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au, linux-kernel@vger.kernel.org
To: nickpiggin@yahoo.com.au
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759619AbXKNB6Z@vger.kernel.org>
In-Reply-To: <200711132241.59074.nickpiggin@yahoo.com.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Nick Piggin <nickpiggin@yahoo.com.au>
Date: Tue, 13 Nov 2007 22:41:58 +1100

> On Tuesday 13 November 2007 06:44, Christoph Lameter wrote:
> > On Sat, 10 Nov 2007, Nick Piggin wrote:
> > > BTW. your size-2048 kmalloc cache is order-1 in the default setup,
> > > wheras kmalloc(1024) or kmalloc(4096) will be order-0 allocations. And
> > > SLAB also uses order-0 for size-2048. It would be nice if SLUB did the
> > > same...
> >
> > You can try to see the effect that order 0 would have by booting with
> >
> > slub_max_order=0
> 
> Yeah, that didn't help much, but in general I think it would give
> more consistent and reliable behaviour from slub.

Just a note that I'm not ignoring this issue, I just don't have time
to get to it yet.

I suspect the issue is about having a huge skb->data linear area for
TCP sends over loopback.  We're likely getting a much smaller
skb->data linear data area after the patch in question, the rest using
the sk_buff scatterlist pages which are a little bit more expensive to
process.
