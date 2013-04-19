From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] GRE: Use IS_ERR_OR_NULL in gre_gso_segment
Date: Fri, 19 Apr 2013 03:24:33 -0700
Message-ID: <1366367073.3205.105.camel@edumazet-glaptop>
References: <1366354120-11230-1-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Dmitry Kozlov <xeb@mail.ru>
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:36889 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756955Ab3DSKYg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Apr 2013 06:24:36 -0400
Received: by mail-pd0-f182.google.com with SMTP id 3so2157550pdj.13
        for <netdev@vger.kernel.org>; Fri, 19 Apr 2013 03:24:35 -0700 (PDT)
In-Reply-To: <1366354120-11230-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-04-19 at 15:48 +0900, Simon Horman wrote:
> Signed-off-by: Simon Horman <horms@verge.net.au>
> ---
>  net/ipv4/gre.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/ipv4/gre.c b/net/ipv4/gre.c
> index d2d5a99..0ae998b 100644
> --- a/net/ipv4/gre.c
> +++ b/net/ipv4/gre.c
> @@ -168,7 +168,7 @@ static struct sk_buff *gre_gso_segment(struct sk_buff *skb,
>  	/* segment inner packet. */
>  	enc_features = skb->dev->hw_enc_features & netif_skb_features(skb);
>  	segs = skb_mac_gso_segment(skb, enc_features);
> -	if (!segs || IS_ERR(segs))
> +	if (IS_ERR_OR_NULL(segs))
>  		goto out;
>  
>  	skb = segs;

Hi Simon

AFAIK I would change things so that NULL is not a possible value.

I don't really like IS_ERR_OR_NULL() because it hides some lazyness of
ours, and is more expensive (2 tests)

If we return NULL for an error, why not instead return -Esomething,
since caller is OK to get -ENOMEM,-Exxxxx,... ?

Anyway I presume this is a net-next patch ?

Thanks
