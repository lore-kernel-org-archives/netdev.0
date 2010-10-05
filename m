From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCHv4 net-next-2.6 1/5] XFRM,IPv6: Remove xfrm_spi_hash()
	dependency on destination address
Date: Tue, 5 Oct 2010 12:17:07 +0800
Message-ID: <20101005041707.GA26458@gondor.apana.org.au>
References: <cover.1286139128.git.arno@natisbad.org> <5a0e320544e253cc903cfd3292600b6bec044a5f.1286139129.git.arno@natisbad.org> <20101004083306.GA17939@gondor.apana.org.au> <8739sl8yw5.fsf@small.ssi.corp> <20101005021114.GA25681@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	netdev@vger.kernel.org
To: Arnaud Ebalard <arno@natisbad.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:34816 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750826Ab0JEERV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Oct 2010 00:17:21 -0400
Content-Disposition: inline
In-Reply-To: <20101005021114.GA25681@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 05, 2010 at 10:11:14AM +0800, Herbert Xu wrote:
>
> I'm thinking about the case where each remote end (or one remote
> end with many IP addresses) chooses to use a single SPI which then
> all gets hashed to the same bucket.
> 
> Outbound SAs are hashed into the same SPI hash table as inbound SAs.

Another solution would be to create a hash table for inbound SAs
only.  Unfortunately I don't think we have anything in our current
user-interface to indicate whether an SA is inbound or outbound.

So to do this you'll need to use a heuristic such as doing a
lookup on the source/destination address at insertion time.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
