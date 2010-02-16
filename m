From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH net-2.6] net: bug fix for vlan + gro issue
Date: Tue, 16 Feb 2010 19:40:15 +0800
Message-ID: <20100216114015.GB31642@gondor.apana.org.au>
References: <20100212053451.GA23351@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, kaber@trash.net,
	netdev <netdev@vger.kernel.org>
To: Ajit Khaparde <ajitk@serverengines.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:35148 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754227Ab0BPLkY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2010 06:40:24 -0500
Content-Disposition: inline
In-Reply-To: <20100212053451.GA23351@serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 12, 2010 at 11:04:53AM +0530, Ajit Khaparde wrote:
>
> diff --git a/net/core/dev.c b/net/core/dev.c
> index be9924f..16aac06 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -2761,7 +2761,10 @@ gro_result_t napi_frags_finish(struct napi_struct *napi, struct sk_buff *skb,
>  	switch (ret) {
>  	case GRO_NORMAL:
>  	case GRO_HELD:
> -		skb->protocol = eth_type_trans(skb, napi->dev);
> +		if (skb->vlan_tci)
> +			skb->protocol = eth_type_trans(skb, skb->dev);
> +		else
> +			skb->protocol = eth_type_trans(skb, napi->dev);

We should be able to just use skb->dev here.

Thanks!
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
