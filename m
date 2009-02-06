From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH v2] tcp: splice as many packets as possible at once
Date: Fri, 6 Feb 2009 12:10:15 +0100
Message-ID: <20090206111015.GD15159@1wt.eu>
References: <20090202084358.GB4129@ff.dom.local> <20090202.235017.253437221.davem@davemloft.net> <20090203094108.GA4639@ff.dom.local> <20090205.235258.257422341.davem@davemloft.net> <20090206091034.GA4879@ff.dom.local> <20090206092326.GC6645@gondor.apana.org.au> <20090206095119.GC4879@ff.dom.local> <20090206102822.GB7175@gondor.apana.org.au> <20090206105807.GD4879@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>, zbr@ioremap.net,
	dada1@cosmosbay.com, ben@zeus.com, mingo@elte.hu,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jens.axboe@oracle.com
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:2070 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754437AbZBFLK4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Feb 2009 06:10:56 -0500
Content-Disposition: inline
In-Reply-To: <20090206105807.GD4879@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 06, 2009 at 10:58:07AM +0000, Jarek Poplawski wrote:
> On Fri, Feb 06, 2009 at 09:28:22PM +1100, Herbert Xu wrote:
> > On Fri, Feb 06, 2009 at 09:51:20AM +0000, Jarek Poplawski wrote:
> > >
> > > OK, but since there is not so much difference, and we need to waste
> > > it in some cases anyway, plus handle it later some special way, I'm
> > > a bit in doubt.
> > 
> > Well the thing is cards that don't support SG on tx probably
> > don't support jumbo frames either.
> 
> ?? I mean this 128 byte chunk would be hard to reuse after copying
> to skb->data, and if reused, we could miss this for some NICs on TX,
> so the whole packed would need a copy.

couldn't we stuff up to 32 128-byte chunks in a page and use a 32-bit
map to indicate which slot is used and which one is free ? This would
just be a matter of calling ffz() to find one spare place in a page.
Also, that bitmap might serve as a refcount, because if it drops to
zero, it means all slots are unused. And -1 means all slots are used.

This would reduce wastage if wee need to allocate 128 bytes often.

Willy

