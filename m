From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH v2] tcp: splice as many packets as possible at once
Date: Tue, 3 Feb 2009 23:27:15 +1100
Message-ID: <20090203122715.GA9307@gondor.apana.org.au>
References: <20090202084358.GB4129@ff.dom.local> <20090202.235017.253437221.davem@davemloft.net> <20090203094108.GA4639@ff.dom.local> <20090203111012.GA16878@ioremap.net> <20090203112431.GA8746@gondor.apana.org.au> <20090203114944.GA21957@ioremap.net> <20090203115313.GA9018@gondor.apana.org.au> <20090203120715.GA22427@ioremap.net> <20090203121209.GA9154@gondor.apana.org.au> <20090203121836.GA23300@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	David Miller <davem@davemloft.net>, w@1wt.eu,
	dada1@cosmosbay.com, ben@zeus.com, mingo@elte.hu,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jens.axboe@oracle.com
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:47277 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752373AbZBCM1w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Feb 2009 07:27:52 -0500
Content-Disposition: inline
In-Reply-To: <20090203121836.GA23300@ioremap.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 03, 2009 at 03:18:36PM +0300, Evgeniy Polyakov wrote:
>
> I agree that this will work and will be better than nothing, but copying
> 9kb into 3 pages is rather CPU hungry operation, and I think (but have
> no numbers though) that system will behave faster if MTU is reduced to
> the standard one.

Reducing the MTU can create all sorts of problems so it should be
avoided if at all possible.  These days, path MTU discovery is
haphazard at best.  In fact MTU problems are the main reason why
jumbo frames simply don't get deployed.

> Another solution is to have a proper allocator which will be able to
> defragment the data, if talking about the alternatives to the drop.

Sure, if we can create an allocator that can guarantee contiguous
allocations all the time then by all means go for it.  But until
we get there, doing what I suggested is way better than stopping
the receiving process altogether.

> So:
> 1. copy the whole jumbo skb into fragmented one
> 2. reduce the MTU
> 3. rely on the allocator

Yes, improving the allocator would obviously inrease the performance,
however, there is nothing against employing both methods.  I'd
always avoid reducing the MTU at run-time though.

> For the 'good' hardware and drivers nothing from the above is really needed.

Right, that's why there is a point beyond which improving the
allocator is no longer worthwhile.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
