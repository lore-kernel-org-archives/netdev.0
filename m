From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: arp_hash
Date: Mon, 23 Mar 2015 10:22:42 +1100
Message-ID: <20150322232242.GA9105@gondor.apana.org.au>
References: <20150322114204.GA5010@gondor.apana.org.au>
 <1427028981.25985.48.camel@edumazet-glaptop2.roam.corp.google.com>
 <20150322215612.GA8274@gondor.apana.org.au>
 <20150322225104.GA8853@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Roland Dreier <roland@purestorage.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:40576 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751980AbbCVXWq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Mar 2015 19:22:46 -0400
Content-Disposition: inline
In-Reply-To: <20150322225104.GA8853@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 23, 2015 at 09:51:04AM +1100, Herbert Xu wrote:
> 
> OK I'm wrong because net/core/neighbour.c uses only the high-order
> bits of the hash.

Unfortunately even the high-order bits are too predictable:

10.0.0.128	0xbd78b1f2
10.0.0.64	0xfd78b1f2
10.0.0.192	0x7d78b1f2
10.0.0.32	0x9d78b1f2
...
10.0.0.63	0xd078b1f2
10.0.0.191	0x5078b1f2
10.0.0.127	0x9078b1f2
10.0.0.255	0x1078b1f2
10.0.1.0	0x60bdb1f2

As you can see there is a bit-to-bit correspondence.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
