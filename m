From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: Use consume_skb() to free gso segmented
 skb
Date: Mon, 29 Apr 2013 17:33:42 -0700
Message-ID: <1367282022.8964.333.camel@edumazet-glaptop>
References: <1367276562.23068.7.camel@sridhar.usor.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Sridhar Samudrala <sri@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ia0-f170.google.com ([209.85.210.170]:55854 "EHLO
	mail-ia0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759229Ab3D3Ado (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Apr 2013 20:33:44 -0400
Received: by mail-ia0-f170.google.com with SMTP id k20so3093833iak.15
        for <netdev@vger.kernel.org>; Mon, 29 Apr 2013 17:33:44 -0700 (PDT)
In-Reply-To: <1367276562.23068.7.camel@sridhar.usor.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-04-29 at 16:02 -0700, Sridhar Samudrala wrote:
> Use consume_skb() to free the original skb that is successfully transmitted 
> as gso segmented skbs so that it is not treated as a drop due to an error.
> 
> Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>
> ---
> 
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 7c30dce..4040673 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -2565,8 +2565,11 @@ gso:
>  	} while (skb->next);
>  
>  out_kfree_gso_skb:
> -	if (likely(skb->next == NULL))
> +	if (likely(skb->next == NULL)) {
>  		skb->destructor = DEV_GSO_CB(skb)->destructor;
> +		consume_skb(skb);
> +		return rc;
> +	}
>  out_kfree_skb:
>  	kfree_skb(skb);
>  out:
> 

Acked-by: Eric Dumazet <edumazet@google.com>
