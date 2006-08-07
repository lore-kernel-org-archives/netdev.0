From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [RFC] avoid unnecessary alignement overhead in skb->data allocation.
Date: Mon, 7 Aug 2006 10:36:36 +0400
Message-ID: <20060807063636.GB11483@2ka.mipt.ru>
References: <20060807060155.GA6487@2ka.mipt.ru> <E1G9ybt-0001GT-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:24979 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1751105AbWHGGhL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2006 02:37:11 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <E1G9ybt-0001GT-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 07, 2006 at 04:29:09PM +1000, Herbert Xu (herbert@gondor.apana.org.au) wrote:
> Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote:
> > 
> > Attached patch allows to avoid unnecessary alignment overhead
> > in skb->data allocation.
> > Main idea is to allocate struct skb_shared_info from cache when
> > addition of sizeof(struct skb_shared_info) ens up in different order
> > allocation than initial size order.
> > This allows to solve problem with 4k allocations for 1500 MTU and 32k
> > allocations for 9k jumbo frames for some chips.
> > Patch was not tested, so if idea worth it I will complete it.
> 
> I thought the Intel guys were saying that their NIC could write the
> full 16KB which means it it's unsafe to use the last four bytes, no?

Well, theirs comments in code say, that maximum allowed frame size is
0x3f00, so there is a little place at the end to put there a pointer,
so I allocate size + sizeof(void *).
If they actually can eat all 16k, then we need a pointer somewhere in
the skb for shared_info, since 16k + sizeof(void *) will be aligned to
32k.

> Cheers,
 -- 
> Visit Openswan at http://www.openswan.org/
> Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
> Home Page: http://gondor.apana.org.au/~herbert/
> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

-- 
	Evgeniy Polyakov
