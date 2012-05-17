From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 3/7] netfilter: xt_HMARK: modulus is expensive for hash calculation
Date: Thu, 17 May 2012 09:16:11 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B6F10@saturn3.aculab.com>
References: <1337209604-3412-4-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: <pablo@netfilter.org>, <netfilter-devel@vger.kernel.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-class: urn:content-classes:message
In-Reply-To: <1337209604-3412-4-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 
> From: Pablo Neira Ayuso <pablo@netfilter.org>
> 
> Use:
> 
> ((u64)(HASH_VAL * HASH_SIZE)) >> 32
> 
> as suggested by David S. Miller.

That (u64) cast is very unlikely to have any effect.
If you want a 64 bit result from the product of two
32 bit values, you have to cast one of the 32 bit values
prior to the multiply - as in the patch below.

	David

> 
> Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
> ---
>  net/netfilter/xt_HMARK.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/netfilter/xt_HMARK.c b/net/netfilter/xt_HMARK.c
> index 5817d03..0a96a43 100644
> --- a/net/netfilter/xt_HMARK.c
> +++ b/net/netfilter/xt_HMARK.c
> @@ -109,7 +109,7 @@ hmark_hash(struct hmark_tuple *t, const 
> struct xt_hmark_info *info)
>  	hash = jhash_3words(t->src, t->dst, t->uports.v32, 
> info->hashrnd);
>  	hash = hash ^ (t->proto & info->proto_mask);
>  
> -	return (hash % info->hmodulus) + info->hoffset;
> +	return (((u64)hash * info->hmodulus) >> 32) + info->hoffset;
>  }
>  
>  static void
> -- 
> 1.7.10
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 


