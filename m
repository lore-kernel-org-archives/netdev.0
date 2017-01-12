From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH/RFC net] ravb: do not use zero-length alighment DMA
 request
Date: Thu, 12 Jan 2017 10:21:02 -0500 (EST)
Message-ID: <20170112.102102.2249793963798495642.davem@davemloft.net>
References: <1484229217-25585-1-git-send-email-horms+renesas@verge.net.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sergei.shtylyov@cogentembedded.com, magnus.damm@gmail.com,
        netdev@vger.kernel.org, linux-renesas-soc@vger.kernel.org
To: horms+renesas@verge.net.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50718 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750791AbdALPb6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2017 10:31:58 -0500
In-Reply-To: <1484229217-25585-1-git-send-email-horms+renesas@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Horman <horms+renesas@verge.net.au>
Date: Thu, 12 Jan 2017 14:53:37 +0100

> diff --git a/drivers/net/ethernet/renesas/ravb_main.c b/drivers/net/ethernet/renesas/ravb_main.c
> index 92d7692c840d..3b4d2504285e 100644
> --- a/drivers/net/ethernet/renesas/ravb_main.c
> +++ b/drivers/net/ethernet/renesas/ravb_main.c
> @@ -1508,6 +1508,8 @@ static netdev_tx_t ravb_start_xmit(struct sk_buff *skb, struct net_device *ndev)
>  	buffer = PTR_ALIGN(priv->tx_align[q], DPTR_ALIGN) +
>  		 entry / NUM_TX_DESC * DPTR_ALIGN;
>  	len = PTR_ALIGN(skb->data, DPTR_ALIGN) - skb->data;
> +	if (len == 0)
> +		len = skb->len > 4 ? 4 : skb->len;
>  	memcpy(buffer, skb->data, len);
>  	dma_addr = dma_map_single(ndev->dev.parent, buffer, len, DMA_TO_DEVICE);
>  	if (dma_mapping_error(ndev->dev.parent, dma_addr))

Assume len ends up being skb->len, then the second DMA mapping will be
made of zero length.

This code needs a bit of TLC.
