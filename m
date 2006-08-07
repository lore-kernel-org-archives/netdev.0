From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC] avoid unnecessary alignement overhead in skb->data allocation.
Date: Mon, 07 Aug 2006 17:17:13 +1000
Message-ID: <E1G9zMP-0001MO-00@gondolin.me.apana.org.au>
References: <20060806.232339.30184217.davem@davemloft.net>
Cc: johnpol@2ka.mipt.ru, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:25611 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1751119AbWHGHRY
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Aug 2006 03:17:24 -0400
To: davem@davemloft.net (David Miller)
In-Reply-To: <20060806.232339.30184217.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> wrote:
> 
> I don't know if I want to eat an entire extra allocation for every SKB
> just to handle broken e1000 cards that can't be bothered to support
> non-power-of-2 receive buffer sizes and a proper MTU setting.
> 
> I guess we might have to, but this is extremely unfortunate. :-/

I'd hope not.  Apparently they are capable of putting data into
individual pages and chaining them together.  The only problem
is that half a page is wasted for 1500-byte packets.

However, allocating 16KB packets would waste even more memory
if only 1500 bytes end up getting used.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
