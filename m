From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 4/4] rhashtable: Add parent argument to mutex_is_held
Date: Sat, 15 Nov 2014 19:23:13 +0800
Message-ID: <20141115112313.GA20970@gondor.apana.org.au>
References: <20141113101025.GA3728@gondor.apana.org.au>
 <E1XorN4-0000zn-0H@gondolin.me.apana.org.au>
 <20141113103723.GO19157@casper.infradead.org>
 <20141113103834.GA4024@gondor.apana.org.au>
 <20141113104124.GA24379@casper.infradead.org>
 <20141113104343.GA4112@gondor.apana.org.au>
 <20141115032512.GA19299@gondor.apana.org.au>
 <20141115111626.GP19157@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	paulmck@linux.vnet.ibm.com, josh@joshtriplett.org,
	"David S. Miller" <davem@davemloft.net>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:38191 "EHLO
	helcar.apana.org.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752215AbaKOLZC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Nov 2014 06:25:02 -0500
Content-Disposition: inline
In-Reply-To: <20141115111626.GP19157@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Nov 15, 2014 at 11:16:26AM +0000, Thomas Graf wrote:
>
> > Thomas, it appears that rhashtable as it stands cannot handle
> > changing the random seed because of the way it constructs the
> > new hash table without degrading into a linked list.  Is there
> > something I'm missing?
> > 
> > FWIW my hashtable in net/bridge/br_multicast.c handles rehashing
> > correctly.  Any objections to me converting rhashtable to use my
> > scheme instead?
> 
> Can you elaborate a bit?
> 
> The point of rhashtable is to not require two sets of linked list
> pointers as done by MDB or OVS flow tables to work around the
> increased cache footprint of that approach. The difference of the
> two algos is dicussed in this paper [0].
> 
> The disadvantage of rhashtable is that, AFAIK, the hash function
> cannot change while resizing as it would break the mutual linked
> lists.

Well it doesn't break so much as degenerate into a linked list (I'm
talking about the concept rather than what the current code does).

This is I think a show-stopper because for anything that can be
influenced by remote parties we have to reseed and therefore
be able to cope with hashes changing on the fly.  Since most
hash tables in the network stack can be influenced by remote
entities (including the xfrm policy bydst hash that I am currently
working on), this is something rhashtable must be able to support
if it is to be used throughout the network stack.

Unless there is a better solution then I think keeping two lists
will have to do.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
