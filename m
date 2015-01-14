From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH net-next v12 3/3] net: hisilicon: new hip04 ethernet
 driver
Date: Tue, 13 Jan 2015 23:06:11 -0500 (EST)
Message-ID: <20150113.230611.375062426344934847.davem@davemloft.net>
References: <1421140290-5492-1-git-send-email-dingtianhong@huawei.com>
	<1421140290-5492-4-git-send-email-dingtianhong@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: arnd-r2nGTMty4D4@public.gmane.org, robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, grant.likely-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org,
	agraf-l3A5Bk7waGM@public.gmane.org, sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	xuwei5-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org, zhangfei.gao-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org
To: dingtianhong-hv44wF8Li93QT0dZR+AlfA@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1421140290-5492-4-git-send-email-dingtianhong-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Ding Tianhong <dingtianhong-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Date: Tue, 13 Jan 2015 17:11:30 +0800

> +static int hip04_alloc_ring(struct net_device *ndev, struct device *d)
> +{
> +	struct hip04_priv *priv = netdev_priv(ndev);
> +	int i;
> +
> +	priv->tx_desc = dma_alloc_coherent(d,
> +			TX_DESC_NUM * sizeof(struct tx_desc),
> +			&priv->tx_desc_dma, GFP_KERNEL);

When a function call spans multiple lines, the arguments on the
second and subsequent lines should start at the first column
after the openning parenthesis of the function call.

If you are only using TAB characters, your indentation is likely
to be incorrect.

> +	/*
> +	 * BQL will try to keep the TX queue as short as possible, but it can't
> +	 * be faster than tx_coalesce_usecs, so we need a fast timeout here,
> +	 * but also long enough to gather up enough frames to ensure we don't
> +	 * get more interrupts than necessary.
> +	 * 200us is enough for 16 frames of 1500 bytes at gigabit ethernet rate
> +	 */

Comments in the networking should be:

	/* Formatted
	 * like this.
	 */

> +	priv->phy_node = of_parse_phandle(node, "phy-handle", 0);
> +	if (priv->phy_node) {
> +		priv->phy = of_phy_connect(ndev, priv->phy_node,
> +			&hip04_adjust_link, 0, priv->phy_mode);

Please align the arguments to this function call correctly, as
per above.

Thanks.
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
