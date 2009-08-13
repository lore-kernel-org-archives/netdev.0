From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] Fix xfrm hash collisions by changing
	__xfrm4_daddr_saddr_hash to hash addresses with addition
Date: Thu, 13 Aug 2009 14:11:15 +1000
Message-ID: <20090813041115.GA19344@gondor.apana.org.au>
References: <20090813020606.GA18205@gondor.apana.org.au> <20090812.204247.183387787.davem@davemloft.net> <20090813035310.GA19182@gondor.apana.org.au> <20090812.205635.244644770.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: joamaki@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:41433 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750880AbZHMELS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Aug 2009 00:11:18 -0400
Content-Disposition: inline
In-Reply-To: <20090812.205635.244644770.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 12, 2009 at 08:56:35PM -0700, David Miller wrote:
> 
> 1) The client is on your private network, much more serious
>    mischief is possible.

Not necessarily as having an IPsec connection does not entail
full access to the network on the other side.

> 2) Whoever creates such a hash collision explosion can be
>    precisely identified.
> 
> The ikev1 failure case is an interesting situation I hadn't
> considered.
> 
> Maybe that can matter, but again the guilty party is easy to identify
> and easy to block via whatever means appropriate.

For corporate networks perhaps.  However, in other cases the
peer may be trusted even less.  For instance, if IPsec were
used for mobility purposes then you essentially don't know
the client at all.

It's like Facebook.  If one user mounts a DoS attack you can
block their account.  However, if they can simply come back
with a new account then you need to make sure that the attack
can be mitigated in other ways so that it doesn't bring the
whole thing down.

BTW, this isn't just exposed to IPsec peers.  It can also be
exposed to those behind the gateway not using IPsec.

Some IPsec applications use a policy that spawns one SA per
src/dst address pair.  In that case, even an entity that is
not on the IPsec side would be able to spawn SAs with the intent
of causing collisions.  It simply needs to send packets through
the IPsec gateway with the appropriate destination addresses.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
