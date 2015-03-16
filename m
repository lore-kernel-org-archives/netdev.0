From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [v1 PATCH 7/14] netfilter: Use rhashtable_lookup instead of
 lookup_compare
Date: Mon, 16 Mar 2015 08:28:42 +0000
Message-ID: <20150316082842.GA10896@casper.infradead.org>
References: <20150315104306.GA21999@gondor.apana.org.au>
 <E1YX624-0005ns-CB@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>, kaber@trash.net
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:41496 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751170AbbCPI2p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Mar 2015 04:28:45 -0400
Content-Disposition: inline
In-Reply-To: <E1YX624-0005ns-CB@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/15/15 at 09:44pm, Herbert Xu wrote:
> The use of rhashtable_lookup_compare in nft_hash is gratuitous
> since the comparison function is just doing memcmp.  Furthermore,
> there is cruft embedded in the comparson function that should
> instead be moved into the caller of the lookup.
> 
> This patch moves that cruft over and replacces the call to
> rhashtable_lookup_compare with rhashtable_lookup.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

The reason for the indirection was to not bypass the abstraction
nft_data_cmp() provides.

No objection to the change but maybe leave a comment in
nft_data_cmp() that if one changes nft_data_cmp() one needs to
look at nft_hash and see if the direct use of rhashtable_lookup()
is still valid.

Copying Patrick as well.
