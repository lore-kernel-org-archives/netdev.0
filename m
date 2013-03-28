From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: core: Remove redundant call to 'nf_reset' in
 'dev_forward_skb'
Date: Thu, 28 Mar 2013 06:36:50 -0700
Message-ID: <1364477810.15753.39.camel@edumazet-glaptop>
References: <1364462006-5814-1-git-send-email-shmulik.ladkani@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Ben Greear <greearb@candelatech.com>, netdev@vger.kernel.org,
	Igor Michailov <rgohita@gmail.com>
To: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f51.google.com ([209.85.160.51]:44556 "EHLO
	mail-pb0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755715Ab3C1Ngw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Mar 2013 09:36:52 -0400
Received: by mail-pb0-f51.google.com with SMTP id rr4so3100557pbb.24
        for <netdev@vger.kernel.org>; Thu, 28 Mar 2013 06:36:52 -0700 (PDT)
In-Reply-To: <1364462006-5814-1-git-send-email-shmulik.ladkani@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-03-28 at 11:13 +0200, Shmulik Ladkani wrote:
> 'nf_reset' is called just prior calling 'netif_rx'.
> No need to call it twice.
> 
> Reported-by: Igor Michailov <rgohita@gmail.com>
> Signed-off-by: Shmulik Ladkani <shmulik.ladkani@gmail.com>
> ---
>  net/core/dev.c |    1 -
>  1 files changed, 0 insertions(+), 1 deletions(-)
> 
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 2db88df..071f398 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -1624,7 +1624,6 @@ int dev_forward_skb(struct net_device *dev, struct sk_buff *skb)
>  	}
>  
>  	skb_orphan(skb);
> -	nf_reset(skb);
>  
>  	if (unlikely(!is_skb_forwardable(dev, skb))) {
>  		atomic_long_inc(&dev->rx_dropped);

Acked-by: Eric Dumazet <edumazet@google.com>
