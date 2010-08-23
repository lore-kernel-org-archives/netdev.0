From: Bart De Schuymer <bdschuym@pandora.be>
Subject: Re: [Bridge] [PATCH v2] bridge: netfilter: fix a memory leak
Date: Mon, 23 Aug 2010 21:33:48 +0200
Message-ID: <4C72CD1C.7020901@pandora.be>
References: <1282539806-25496-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from jacques.telenet-ops.be ([195.130.132.50]:58396 "EHLO
	jacques.telenet-ops.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752292Ab0HWTdw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Aug 2010 15:33:52 -0400
In-Reply-To: <1282539806-25496-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Looks correct to me.

Signed-off-by: Bart De Schuymer <bdschuym@pandora.be>

Changli Gao schreef:
> nf_bridge_alloc() always reset the skb->nf_bridge, so we should always
> put the old one.
>
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
> ---
> v2: Should init tmp->use again because memcpy() overwrite it.
>  1 file changed, 1 insertion(+), 1 deletion(-)
> diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
> index 2c911c0..5ed00bd 100644
> --- a/net/bridge/br_netfilter.c
> +++ b/net/bridge/br_netfilter.c
> @@ -162,8 +162,8 @@ static inline struct nf_bridge_info *nf_bridge_unshare(struct sk_buff *skb)
>  		if (tmp) {
>  			memcpy(tmp, nf_bridge, sizeof(struct nf_bridge_info));
>  			atomic_set(&tmp->use, 1);
> -			nf_bridge_put(nf_bridge);
>  		}
> +		nf_bridge_put(nf_bridge);
>  		nf_bridge = tmp;
>  	}
>  	return nf_bridge;
> _______________________________________________
> Bridge mailing list
> Bridge@lists.linux-foundation.org
> https://lists.linux-foundation.org/mailman/listinfo/bridge
>
>   


-- 
Bart De Schuymer
www.artinalgorithms.be

