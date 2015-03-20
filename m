From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [v1 PATCH 7/14] netfilter: Use rhashtable_lookup instead of
 lookup_compare
Date: Fri, 20 Mar 2015 20:36:34 +1100
Message-ID: <20150320093634.GA17344@gondor.apana.org.au>
References: <20150315104306.GA21999@gondor.apana.org.au>
 <E1YX624-0005ns-CB@gondolin.me.apana.org.au>
 <20150316082842.GA10896@casper.infradead.org>
 <20150316091415.GA31089@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>, kaber@trash.net
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:38828 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750990AbbCTJgj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2015 05:36:39 -0400
Content-Disposition: inline
In-Reply-To: <20150316091415.GA31089@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 16, 2015 at 08:14:15PM +1100, Herbert Xu wrote:
> On Mon, Mar 16, 2015 at 08:28:42AM +0000, Thomas Graf wrote:
>
> > The reason for the indirection was to not bypass the abstraction
> > nft_data_cmp() provides.
> > 
> > No objection to the change but maybe leave a comment in
> > nft_data_cmp() that if one changes nft_data_cmp() one needs to
> > look at nft_hash and see if the direct use of rhashtable_lookup()
> > is still valid.
> 
> Well we could preserve nft_data_cmp if necessary.  It'll just
> mean an extra indirect call to do the compare when needed.

FWIW I've decided to ditch nft_data_cmp unless someone can show
me that it's really necessary.  The reason is that nft_hash_lookup
already uses memcmp instead of nft_data_cmp.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
