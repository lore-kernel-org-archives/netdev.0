From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 0/2]: Remote softirq invocation infrastructure.
Date: Sun, 21 Sep 2008 15:05:45 +0900
Message-ID: <E1KhI4n-0002Fk-7C@gondolin.me.apana.org.au>
References: <20080920.125949.193703969.davem@davemloft.net>
Cc: dwalker@mvista.com, arjan@infradead.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jens.axboe@oracle.com, steffen.klassert@secunet.com
To: davem@davemloft.net (David Miller)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:48400 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751170AbYIUGGN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Sep 2008 02:06:13 -0400
In-Reply-To: <20080920.125949.193703969.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote:
>
> receive using multiple RX queues and MSI-X interrupts.  It's
> also for things like IPSEC where the per-packet cpu usage
> is so huge (to do the crypto) that it makes sense to even
> split up the work to multiple cpus within the same flow.

Unfortunately doing this with IPsec is going to be non-trivial
since we still want to maintain packet ordering inside IPsec
and you don't get the inner flow information until you decrypt
the packet.

So if we want to process IPsec packets in parallel it's best to
implement that from within the crypto API where we can queue the
result in order to ensure proper ordering.

Of course, we need to balance any effort spent on this with the
likelihood that hardware improvements will soon make this obsolete
(for IPsec anyway).

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
