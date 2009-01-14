From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] tcp: splice as many packets as possible at once
Date: Wed, 14 Jan 2009 11:51:10 +1100
Message-ID: <20090114005110.GA6814@gondor.apana.org.au>
References: <20090113.161625.111759506.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: zbr@ioremap.net, dada1@cosmosbay.com, w@1wt.eu, ben@zeus.com,
	jarkao2@gmail.com, mingo@elte.hu, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, jens.axboe@oracle.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:38700 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754412AbZANAvv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2009 19:51:51 -0500
Content-Disposition: inline
In-Reply-To: <20090113.161625.111759506.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote:
>
> I wish there were some way we could make this code grab and release a
> reference to the SKB data area (I mean skb_shinfo(skb)->dataref) to
> accomplish it's goals.

We can probably do that for spliced data that end up going to
the networking stack again.  However, as splice is generic the
data may be headed to a destination other than the network stack.

In that case to make dataref work we'd need some mechanism
that allows non-network entities to get/drop this ref count.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
