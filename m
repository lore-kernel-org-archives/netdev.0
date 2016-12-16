From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: ipv4: tcp_offload: check segs for NULL
Date: Thu, 15 Dec 2016 19:28:41 -0800
Message-ID: <1481858921.6603.5.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1481791661-21670-1-git-send-email-shakya.das@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        shakya89.das@gmail.com, vidushi.koul@samsung.com
To: shakya.das@samsung.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:34832 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753105AbcLPD2o (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Dec 2016 22:28:44 -0500
Received: by mail-pg0-f65.google.com with SMTP id p66so8159359pga.2
        for <netdev@vger.kernel.org>; Thu, 15 Dec 2016 19:28:44 -0800 (PST)
In-Reply-To: <1481791661-21670-1-git-send-email-shakya.das@samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-12-15 at 14:17 +0530, shakya.das@samsung.com wrote:
> From: Shakya Sundar Das <shakya.das@samsung.com>
> 
> This patch will check segs for being NULL in tcp_gso_segment()
> before calling skb_shinfo(segs) from skb_is_gso(segs), otherwise
> kernel can run into a NULL-pointer dereference.
> 
> Signed-off-by: Shakya Sundar Das <shakya.das@samsung.com>
> ---
>  net/ipv4/tcp_offload.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/ipv4/tcp_offload.c b/net/ipv4/tcp_offload.c
> index bc68da3..93feefd 100644
> --- a/net/ipv4/tcp_offload.c
> +++ b/net/ipv4/tcp_offload.c
> @@ -96,7 +96,7 @@ struct sk_buff *tcp_gso_segment(struct sk_buff *skb,
>  	skb->ooo_okay = 0;
>  
>  	segs = skb_segment(skb, features);
> -	if (IS_ERR(segs))
> +	if (IS_ERR_OR_NULL(segs))
>  		goto out;
>  
>  	/* Only first segment might have ooo_okay set */

I do not see how this can ever happen.

How did you come up with this patch exactly ???
