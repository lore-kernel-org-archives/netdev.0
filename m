From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 4/4] rhashtable: Add parent argument to mutex_is_held
Date: Sat, 15 Nov 2014 23:51:08 +0800
Message-ID: <20141115155108.GA21998@gondor.apana.org.au>
References: <20141113101025.GA3728@gondor.apana.org.au>
 <E1XorN4-0000zn-0H@gondolin.me.apana.org.au>
 <20141113103723.GO19157@casper.infradead.org>
 <20141113103834.GA4024@gondor.apana.org.au>
 <20141113104124.GA24379@casper.infradead.org>
 <20141113104343.GA4112@gondor.apana.org.au>
 <20141115032512.GA19299@gondor.apana.org.au>
 <20141115111626.GP19157@casper.infradead.org>
 <20141115112313.GA20970@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	paulmck@linux.vnet.ibm.com, josh@joshtriplett.org,
	"David S. Miller" <davem@davemloft.net>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:46589 "EHLO
	helcar.apana.org.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754009AbaKOPvS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Nov 2014 10:51:18 -0500
Content-Disposition: inline
In-Reply-To: <20141115112313.GA20970@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Nov 15, 2014 at 07:23:13PM +0800, Herbert Xu wrote:
> 
> This is I think a show-stopper because for anything that can be
> influenced by remote parties we have to reseed and therefore
> be able to cope with hashes changing on the fly.  Since most
> hash tables in the network stack can be influenced by remote
> entities (including the xfrm policy bydst hash that I am currently
> working on), this is something rhashtable must be able to support
> if it is to be used throughout the network stack.

So I noticed that you got rid of the rehash when you converted
netlink over to rthashtable.  Was this aspect of the conversion
discussed anywhere? In particular, how do you protect against
a malicious user that's trying to attack the netlink hash table?

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
