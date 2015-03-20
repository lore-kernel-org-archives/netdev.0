From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [v1 PATCH 7/14] netfilter: Use rhashtable_lookup instead of
 lookup_compare
Date: Fri, 20 Mar 2015 21:16:03 +1100
Message-ID: <20150320101603.GA17662@gondor.apana.org.au>
References: <20150315104306.GA21999@gondor.apana.org.au>
 <E1YX624-0005ns-CB@gondolin.me.apana.org.au>
 <20150316082842.GA10896@casper.infradead.org>
 <20150316091415.GA31089@gondor.apana.org.au>
 <20150316111345.GA22070@acer.localdomain>
 <20150320085509.GA16748@gondor.apana.org.au>
 <20150320092216.GE21258@acer.localdomain>
 <20150320092703.GA17081@gondor.apana.org.au>
 <20150320095908.GG21258@acer.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Graf <tgraf@suug.ch>, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:47738 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751672AbbCTKQQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2015 06:16:16 -0400
Content-Disposition: inline
In-Reply-To: <20150320095908.GG21258@acer.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 20, 2015 at 09:59:09AM +0000, Patrick McHardy wrote:
>
> Regarding the chain length as trigger - I'm sorry, but this doesn't work
> for us. I don't see why you would have to look at chain length. That
> implies that you don't trust your hash function - why not fix that
> instead?

Any hash function can be attacked.  That's why we need to be able
to rehash it.  And the best way to decide when to rehash is based
on chain length (otherwise you'd waste time rehashing periodically
like we used to do).  With name spaces these days anyone could be
an adversary.

Besides, putting multiple objects with the same key into a hash
table defeats the whole point of hashing.

> > Of course many hash table users need to be able to keep multiple
> > objects under the same key.  My suggestion would be to allocate
> > your own linked list and have the linked list be the object that
> > is inserted into the hash table.
> 
> That would require a huge amount of extra memory per element and having
> millions of them is not unrealistic for our use case.

You should be able to do it with just 8 extra bytes per unique
hash table key.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
