From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH 10/13] ixp2000: use netdev_alloc_skb
Date: Thu, 17 Apr 2008 15:53:38 +0200
Message-ID: <20080417135338.GA17761@xi.wantstofly.org>
References: <20080416233727.732025083@vyatta.com> <20080416233757.698199646@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alephnull.demon.nl ([83.160.184.112]:48448 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753839AbYDQNxl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Apr 2008 09:53:41 -0400
Content-Disposition: inline
In-Reply-To: <20080416233757.698199646@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 16, 2008 at 04:37:37PM -0700, Stephen Hemminger wrote:

> Use netdev_alloc_skb. This sets skb->dev and allows arch specific
> allocation.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

No objections, I guess..


> --- a/drivers/net/ixp2000/ixpdev.c	2008-04-07 10:36:16.000000000 -0700
> +++ b/drivers/net/ixp2000/ixpdev.c	2008-04-07 12:43:41.000000000 -0700
> @@ -108,14 +108,14 @@ static int ixpdev_rx(struct net_device *
>  		if (unlikely(!netif_running(nds[desc->channel])))
>  			goto err;
>  
> -		skb = dev_alloc_skb(desc->pkt_length + 2);
> +		skb = netdev_alloc_skb(dev, desc->pkt_length + 2);
>  		if (likely(skb != NULL)) {
>  			skb_reserve(skb, 2);
>  			skb_copy_to_linear_data(skb, buf, desc->pkt_length);
>  			skb_put(skb, desc->pkt_length);
>  			skb->protocol = eth_type_trans(skb, nds[desc->channel]);
>  
> -			skb->dev->last_rx = jiffies;
> +			dev->last_rx = jiffies;
>  
>  			netif_receive_skb(skb);
>  		}
> 
> -- 
