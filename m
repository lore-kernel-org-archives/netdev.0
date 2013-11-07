From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH net-next 3/3] net: allow to leave the buffer fragmented
 in skb_cow_data()
Date: Thu, 7 Nov 2013 17:01:35 +0800
Message-ID: <20131107090135.GA385@gondor.apana.org.au>
References: <cover.1381923854.git.mathias.krause@secunet.com>
 <14f30e8f5f8405c1ca73b6d3a554441c1736142d.1381923854.git.mathias.krause@secunet.com>
 <20131106093028.GA18435@gondor.apana.org.au>
 <527A109E.5040000@secunet.com>
 <20131106095217.GA18851@gondor.apana.org.au>
 <527A391B.4050907@secunet.com>
 <20131106124811.GA20404@gondor.apana.org.au>
 <527B5586.3090401@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Dmitry Tarnyagin <dmitry.tarnyagin@lockless.no>,
	netdev@vger.kernel.org
To: Mathias Krause <mathias.krause@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:46898 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753300Ab3KGJBo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Nov 2013 04:01:44 -0500
Content-Disposition: inline
In-Reply-To: <527B5586.3090401@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 07, 2013 at 09:55:34AM +0100, Mathias Krause wrote:
>
> Indeed. I want to avoid the costly memcpy() on the CPU serving the NIC
> interrupt, as that is a bottleneck in my setup. The packet processing --
> encrypting/decrypting of ESP packets -- gets mostly parallelized via
> pcrypt, so that's fine. But the initial network processing, i.e. getting
> to pcrypt, is what's throttling the throughput currently. (RPS only
> partly solves this problem as for the ESP receive path most traffic ends
> up on the same flow).

How about this: instead of doing in-place encryption/decryption
let's allocate a new destination buffer and encrypt/decrypt into
it.  Then we essentially get the copy for free.

So instead of modifying skb_cow_data you can change esp4.c, etc.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
