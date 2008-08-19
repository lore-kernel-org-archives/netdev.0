From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: qdisc_enqueue, NET_XMIT_SUCCESS and kfree_skb
Date: Tue, 19 Aug 2008 23:42:31 +1000
Message-ID: <20080819134230.GA6043@gondor.apana.org.au>
References: <E1KVQfg-0001Qf-00@gondolin.me.apana.org.au> <48AAC5E9.7050809@trash.net> <20080819131139.GA5754@gondor.apana.org.au> <48AAC884.30802@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, jussi.kivilinna@mbnet.fi,
	jarkao2@gmail.com, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:52578 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750824AbYHSNmm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Aug 2008 09:42:42 -0400
Content-Disposition: inline
In-Reply-To: <48AAC884.30802@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 19, 2008 at 03:20:04PM +0200, Patrick McHardy wrote:
> 
> I might have misunderstood you, but the way I imagine force_dequeue
> is that it would give you the packet peeked at, even if a higher
> priority packet is available.
> 
> But actually I don't understand the use for force_dequeue at all,
> assuming ->peek behaves correctly ->dequeue should already hand
> out the correct packet.

You're quite right, we don't need a forced dequeue at all because
all dequeueing and enqueueing occur under the root qdisc lock, so
the peek result has to be the same as that of the next dequeue.

Problem solved :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
