From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [v1 PATCH 7/14] netfilter: Use rhashtable_lookup instead of
 lookup_compare
Date: Fri, 20 Mar 2015 20:27:03 +1100
Message-ID: <20150320092703.GA17081@gondor.apana.org.au>
References: <20150315104306.GA21999@gondor.apana.org.au>
 <E1YX624-0005ns-CB@gondolin.me.apana.org.au>
 <20150316082842.GA10896@casper.infradead.org>
 <20150316091415.GA31089@gondor.apana.org.au>
 <20150316111345.GA22070@acer.localdomain>
 <20150320085509.GA16748@gondor.apana.org.au>
 <20150320092216.GE21258@acer.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Graf <tgraf@suug.ch>, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:53447 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751676AbbCTJ1L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2015 05:27:11 -0400
Content-Disposition: inline
In-Reply-To: <20150320092216.GE21258@acer.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 20, 2015 at 09:22:17AM +0000, Patrick McHardy wrote:
>
> I need the compare functions for transaction support to decide whether
> an element is already activated or has been deactivated and, with a
> further patch, for timeouts. Inactive and timed out elements are treated
> as non-existant but are in case of transactions present in the hash
> until the transaction is committed, in case of timeouts until GC.

I still don't understand what is in the compare callback.  Can
you provide some code example?

More importantly, why is that you can't lookup and then just do
whatever you need to do in the caller of lookup? If you're planning
on having multiple objects in the hash table with the same key then
I'm afraid I'll have to say no because we want to use the chain
length to determine whether we're being attacked and having multiple
objects with the same key defeats that mechanism.

Of course many hash table users need to be able to keep multiple
objects under the same key.  My suggestion would be to allocate
your own linked list and have the linked list be the object that
is inserted into the hash table.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
