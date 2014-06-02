From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 2/2] net: hisilicon: add hix5hd2 mac driver
Date: Mon, 02 Jun 2014 16:11:31 -0700 (PDT)
Message-ID: <20140602.161131.783479189097234753.davem@davemloft.net>
References: <1401440528-7804-1-git-send-email-zhangfei.gao@linaro.org>
	<1401440528-7804-3-git-send-email-zhangfei.gao@linaro.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: arnd@arndb.de, f.fainelli@gmail.com,
	sergei.shtylyov@cogentembedded.com, mark.rutland@arm.com,
	David.Laight@ACULAB.COM, eric.dumazet@gmail.com,
	haifeng.yan@linaro.org, jchxue@gmail.com,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	devicetree@vger.kernel.org
To: zhangfei.gao@linaro.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37551 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752132AbaFBXLd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jun 2014 19:11:33 -0400
In-Reply-To: <1401440528-7804-3-git-send-email-zhangfei.gao@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zhangfei Gao <zhangfei.gao@linaro.org>
Date: Fri, 30 May 2014 17:02:08 +0800

> +			skb = netdev_alloc_skb_ip_align(priv->netdev,
> +				MAC_MAX_FRAME_SIZE);

When a function call, declaration, or definition spans multiple lines,
you must start the arguments on the second and subsequent lines exactly
at the first column after the openning parenthesis.

Please therefore reindent this properly.

> +		addr = dma_map_single(priv->dev, skb->data,
> +					MAC_MAX_FRAME_SIZE, DMA_FROM_DEVICE);

Likewise.

> +		desc->cmd = cpu_to_le32(DESC_VLD_FREE |
> +			(MAC_MAX_FRAME_SIZE - 1) << DESC_BUFF_LEN_OFF);

Likewise.

> +	desc->cmd = cpu_to_le32(DESC_VLD_BUSY | DESC_FL_FULL |
> +			(skb->len & DESC_DATA_MASK) << DESC_DATA_LEN_OFF |
> +			(skb->len & DESC_DATA_MASK) << DESC_BUFF_LEN_OFF);

Likewise.

> +	priv->phy = of_phy_connect(dev, priv->phy_node,
> +		&hix5hd2_adjust_link, 0, priv->phy_mode);

Likewise.

> +static int hix5hd2_mdio_wait_ready(struct mii_bus *bus)
> +{
> +	struct hix5hd2_priv *priv = bus->priv;
> +	void __iomem *base = priv->base;
> +	int i, timeout = 10000;
> +
> +	for (i = 0; readl_relaxed(base + MDIO_SINGLE_CMD) & MDIO_START; i++) {
> +		if (i == timeout)
> +			return -ETIMEDOUT;
> +		udelay(1);
> +	}
> +
> +	return 0;
> +}

10,000 udelay(1)'s is a long time, consider changing to usleep() or
similar.

> +			dma_free_coherent(priv->dev, priv->pool[i].size,
> +					priv->pool[i].desc,
> +					priv->pool[i].phys_addr);

Indentation.

> +		virt_addr = dma_alloc_coherent(dev, size, &phys_addr,
> +				GFP_KERNEL);

Likewise.

> +		netdev_warn(ndev, "using random MAC address %pM\n",
> +			 ndev->dev_addr);

Likewise.
