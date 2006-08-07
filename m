From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC] avoid unnecessary alignement overhead in skb->data allocation.
Date: Mon, 07 Aug 2006 16:29:09 +1000
Message-ID: <E1G9ybt-0001GT-00@gondolin.me.apana.org.au>
References: <20060807060155.GA6487@2ka.mipt.ru>
Cc: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:12298 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1750887AbWHGG3Z
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Aug 2006 02:29:25 -0400
To: johnpol@2ka.mipt.ru (Evgeniy Polyakov)
In-Reply-To: <20060807060155.GA6487@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote:
> 
> Attached patch allows to avoid unnecessary alignment overhead
> in skb->data allocation.
> Main idea is to allocate struct skb_shared_info from cache when
> addition of sizeof(struct skb_shared_info) ens up in different order
> allocation than initial size order.
> This allows to solve problem with 4k allocations for 1500 MTU and 32k
> allocations for 9k jumbo frames for some chips.
> Patch was not tested, so if idea worth it I will complete it.

I thought the Intel guys were saying that their NIC could write the
full 16KB which means it it's unsafe to use the last four bytes, no?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
