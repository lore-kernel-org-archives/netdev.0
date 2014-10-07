From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: bcmgenet: fix Tx ring priority
 programming
Date: Mon, 06 Oct 2014 23:59:26 -0400 (EDT)
Message-ID: <20141006.235926.30933585433924137.davem@davemloft.net>
References: <20141007005001.61C1D100BC1@puck.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com
To: pgynther@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40806 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750705AbaJGEA1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2014 00:00:27 -0400
In-Reply-To: <20141007005001.61C1D100BC1@puck.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Petri Gynther <pgynther@google.com>
Date: Mon,  6 Oct 2014 17:50:01 -0700 (PDT)

> @@ -1731,11 +1744,12 @@ static void bcmgenet_init_multiq(struct net_device *dev)
>  	reg |= ring_cfg;
>  	bcmgenet_tdma_writel(priv, reg, DMA_RING_CFG);
>  
> -	/* Use configured rings priority and set ring #16 priority */
> -	reg = bcmgenet_tdma_readl(priv, DMA_RING_PRIORITY);
> -	reg |= ((GENET_Q0_PRIORITY + priv->hw_params->tx_queues) << 20);
> -	reg |= dma_priority;
> -	bcmgenet_tdma_writel(priv, reg, DMA_PRIORITY);
> +	/* Set ring 16 priority and program the hardware registers */
> +	dma_priority[2] |=
> +		((GENET_Q0_PRIORITY + priv->hw_params->tx_queues) << 20);

Please use "<< (16 - 12) * DMA_RING_BUF_PRIORITY_SHIFT" otherwise this
constant is magic.

You might, optionally, add macros for the subtraction adjustment each
priority register uses (0, 6, 12, respectively).
