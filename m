From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: netfilter: Fix potential crash in nft_hash walker
Date: Fri, 13 Mar 2015 11:50:50 +0100
Message-ID: <20150313105050.GA3546@salvia>
References: <20150312235214.GA26546@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, tgraf@suug.ch,
	netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:53059 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751547AbbCMKrD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Mar 2015 06:47:03 -0400
Content-Disposition: inline
In-Reply-To: <20150312235214.GA26546@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 13, 2015 at 10:52:14AM +1100, Herbert Xu wrote:
> When we get back an EAGAIN from rhashtable_walk_next we were
> treating it as a valid object which obviously doesn't work too
> well.
>     
> Luckily this is hard to trigger so it seems nobody has run into
> it yet.
>     
> This patch fixes it by redoing the next call when we get an EAGAIN.

I'll enqueue this for nf, thanks Herbert.

> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> 
> diff --git a/net/netfilter/nft_hash.c b/net/netfilter/nft_hash.c
> index c82df0a..37c15e6 100644
> --- a/net/netfilter/nft_hash.c
> +++ b/net/netfilter/nft_hash.c
> @@ -153,6 +153,8 @@ static void nft_hash_walk(const struct nft_ctx *ctx, const struct nft_set *set,
>  				iter->err = err;
>  				goto out;
>  			}
> +
> +			continue;
>  		}
>  
>  		if (iter->count < iter->skip)
> -- 
> Email: Herbert Xu <herbert@gondor.apana.org.au>
> Home Page: http://gondor.apana.org.au/~herbert/
> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
