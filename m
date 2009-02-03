From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH v2] tcp: splice as many packets as possible at once
Date: Tue, 3 Feb 2009 23:18:08 +1100
Message-ID: <20090203121808.GA9218@gondor.apana.org.au>
References: <20090202080855.GA4129@ff.dom.local> <20090202.001854.261399333.davem@davemloft.net> <20090202084358.GB4129@ff.dom.local> <20090202.235017.253437221.davem@davemloft.net> <20090203094108.GA4639@ff.dom.local> <20090203111012.GA16878@ioremap.net> <20090203112431.GA8746@gondor.apana.org.au> <20090203114944.GA21957@ioremap.net> <alpine.DEB.1.10.0902030458390.28633@asgard.lang.hm> <20090203121219.GB22427@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: david@lang.hm, Jarek Poplawski <jarkao2@gmail.com>,
	David Miller <davem@davemloft.net>, w@1wt.eu,
	dada1@cosmosbay.com, ben@zeus.com, mingo@elte.hu,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jens.axboe@oracle.com
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:53273 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752131AbZBCMTK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Feb 2009 07:19:10 -0500
Content-Disposition: inline
In-Reply-To: <20090203121219.GB22427@ioremap.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 03, 2009 at 03:12:19PM +0300, Evgeniy Polyakov wrote:
> 
> It is a solution, but I think it will behave noticebly worse than
> with decresed MTU.

Not necessarily.  Remember GSO/GRO in essence are just hacks to
get around the fact that we can't increase the MTU to where we
want it to be.  MTU reduces the cost over the entire path while
GRO/GSO only do so for the sender and the receiver.

In other words when given the choice between a larger MTU with
copying or GRO, the larger MTU will probably win anyway as it's
optimising the entire path rather than just the receiver.
 
> That's the main point: how to deal with broken hardware? I think (but
> have no strong numbers though) that having 6 packets with 1500 MTU
> combined into GRO/LRO frame will be processed way faster than copying 9k
> MTU into 3 pages and process single skb.

Please note that with my scheme, you'd only start copying if you
can't allocate a linear skb.  So if memory fragmentation doesn't
happen then there is no copying at all.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
