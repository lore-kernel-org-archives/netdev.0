From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] 3c515: Write outside array bounds
Date: Sun, 26 Jul 2009 23:16:45 +0200
Message-ID: <4A6CC7BD.9020602@gmail.com>
References: <4A6B88B1.9000907@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: Roel Kluin <roel.kluin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f228.google.com ([209.85.218.228]:39724 "EHLO
	mail-bw0-f228.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753971AbZGZVQy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Jul 2009 17:16:54 -0400
Received: by bwz28 with SMTP id 28so2272936bwz.37
        for <netdev@vger.kernel.org>; Sun, 26 Jul 2009 14:16:53 -0700 (PDT)
In-Reply-To: <4A6B88B1.9000907@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Roel Kluin wrote, On 07/26/2009 12:35 AM:

> if dev_alloc_skb() fails on the first iteration, a write to
> cp->rx_ring[-1] occurs.
> 
> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
> ---
> Please review: can we error return like this?


I doubt we can return here: there is a lot of cleaning missing.

Jarek P.

> 
> diff --git a/drivers/net/3c515.c b/drivers/net/3c515.c
> index 3e00fa8..c84815a 100644
> --- a/drivers/net/3c515.c
> +++ b/drivers/net/3c515.c
> @@ -827,7 +827,7 @@ static int corkscrew_open(struct net_device *dev)
>  			skb = dev_alloc_skb(PKT_BUF_SZ);
>  			vp->rx_skbuff[i] = skb;
>  			if (skb == NULL)
> -				break;	/* Bad news!  */
> +				return -ENOMEM;	/* Bad news!  */
>  			skb->dev = dev;	/* Mark as being used by this device. */
>  			skb_reserve(skb, 2);	/* Align IP on 16 byte boundaries */
>  			vp->rx_ring[i].addr = isa_virt_to_bus(skb->data);
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 


