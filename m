From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH v2] tcp: splice as many packets as possible at once
Date: Tue, 27 Jan 2009 07:40:48 +0000
Message-ID: <20090127074048.GA4197@ff.dom.local>
References: <20090120103122.GC9167@ioremap.net> <20090126082036.GB4183@ff.dom.local> <20090126212130.GA4338@ioremap.net> <20090126.221056.174077798.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: zbr@ioremap.net, herbert@gondor.apana.org.au, w@1wt.eu,
	dada1@cosmosbay.com, ben@zeus.com, mingo@elte.hu,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jens.axboe@oracle.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.156]:54442 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751213AbZA0Hkz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2009 02:40:55 -0500
Content-Disposition: inline
In-Reply-To: <20090126.221056.174077798.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 26, 2009 at 10:10:56PM -0800, David Miller wrote:
> From: Evgeniy Polyakov <zbr@ioremap.net>
> Date: Tue, 27 Jan 2009 00:21:30 +0300
> 
> > Hi Jarek.
> > 
> > On Mon, Jan 26, 2009 at 08:20:36AM +0000, Jarek Poplawski (jarkao2@gmail.com) wrote:
> > > > 1. Network (tree) allocator
> > > > http://www.ioremap.net/projects/nta
> > > 
> > > I looked at this a bit, but alas I didn't find much for this Herbert's
> > > idea of payload in fragments/pages. Maybe some kind of API RFC is
> > > needed before this resurrection?
> > 
> > Basic idea is to steal some (probably a lot) pages from the slab
> > allocator and put network buffers there without strict need for
> > power-of-two alignment and possible wraps when we add skb_shared_info at
> > the end, so that old e1000 driver required order-4 allocations for the
> > jumbo frames. We can do that in alloc_skb() and friends and put returned
> > buffers into skb's fraglist and updated reference counters for those
> > pages; and with additional copy of the network headers into skb->head.

I think the main problem is to respect put_page() more, and maybe you
mean to add this to your allocator too, but using slab pages for this
looks a bit complex to me, but I can miss something.

> We are going back and forth saying the same thing, I think :-)
> (BTW, I think NTA is cool and we might do something like that
> eventually)
> 
> The basic thing we have to do is make the drivers receive into
> pages, and then slide the network headers (only) into the linear
> SKB data area.

As a matter of fact, I wonder if these headers should be always
separated. Their "chunk" could be refcounted as well, I guess.

Jarek P.
