From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: 2.6.24-rc2: Network commit causes SLUB performance regression with tbench
Date: Wed, 14 Nov 2007 04:36:24 +1100
Message-ID: <200711140436.24492.nickpiggin@yahoo.com.au>
References: <200711101229.35822.nickpiggin@yahoo.com.au> <200711132241.59074.nickpiggin@yahoo.com.au> <20071113.175804.151698768.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: clameter@sgi.com, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp109.mail.mud.yahoo.com ([209.191.85.219]:41286 "HELO
	smtp109.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1758076AbXKNFiu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2007 00:38:50 -0500
In-Reply-To: <20071113.175804.151698768.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 14 November 2007 12:58, David Miller wrote:
> From: Nick Piggin <nickpiggin@yahoo.com.au>
> Date: Tue, 13 Nov 2007 22:41:58 +1100
>
> > On Tuesday 13 November 2007 06:44, Christoph Lameter wrote:
> > > On Sat, 10 Nov 2007, Nick Piggin wrote:
> > > > BTW. your size-2048 kmalloc cache is order-1 in the default setup,
> > > > wheras kmalloc(1024) or kmalloc(4096) will be order-0 allocations.
> > > > And SLAB also uses order-0 for size-2048. It would be nice if SLUB
> > > > did the same...
> > >
> > > You can try to see the effect that order 0 would have by booting with
> > >
> > > slub_max_order=0
> >
> > Yeah, that didn't help much, but in general I think it would give
> > more consistent and reliable behaviour from slub.
>
> Just a note that I'm not ignoring this issue, I just don't have time
> to get to it yet.

No problem. I would like to have helped more, but it's slow going given
my lack of network stack knowledge. If I get any more interesting data,
I'll send it.


> I suspect the issue is about having a huge skb->data linear area for
> TCP sends over loopback.  We're likely getting a much smaller
> skb->data linear data area after the patch in question, the rest using
> the sk_buff scatterlist pages which are a little bit more expensive to
> process.

It didn't seem to be noticeable at 1 client. Unless scatterlist
processing is going to cause cacheline bouncing, I don't see why this
hurts more as you add CPUs?
