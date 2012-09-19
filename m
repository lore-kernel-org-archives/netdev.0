From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net/core: fix comment in skb_try_coalesce
Date: Wed, 19 Sep 2012 07:08:16 +0200
Message-ID: <1348031296.26523.277.camel@edumazet-glaptop>
References: <1348023201-7727-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:56502 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754536Ab2ISFIY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2012 01:08:24 -0400
Received: by wgbdr13 with SMTP id dr13so517023wgb.1
        for <netdev@vger.kernel.org>; Tue, 18 Sep 2012 22:08:23 -0700 (PDT)
In-Reply-To: <1348023201-7727-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-09-19 at 10:53 +0800, roy.qing.li@gmail.com wrote:
> From: Li RongQing <roy.qing.li@gmail.com>
> 
> It should be the skb which is not cloned
> 
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
> ---
>  net/core/skbuff.c |    4 +++-
>  1 files changed, 3 insertions(+), 1 deletions(-)
> 
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index fe00d12..354a4e4 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -3502,7 +3502,9 @@ bool skb_try_coalesce(struct sk_buff *to, struct sk_buff *from,
>  	if (!skb_cloned(from))
>  		skb_shinfo(from)->nr_frags = 0;
>  
> -	/* if the skb is cloned this does nothing since we set nr_frags to 0 */
> +	/* if the skb is not cloned this does nothing
> +	 * since we set nr_frags to 0.
> +	 */
>  	for (i = 0; i < skb_shinfo(from)->nr_frags; i++)
>  		skb_frag_ref(from, i);
>  

Yes I saw that yesterday and was about to submit the same change (more
or less)

Acked-by: Eric Dumazet <edumazet@google.com>
