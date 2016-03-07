From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V4 2/4] net-next: mediatek: add support for MT7623
 ethernet
Date: Mon, 07 Mar 2016 11:30:54 -0500 (EST)
Message-ID: <20160307.113054.2069588355987832062.davem@davemloft.net>
References: <1457340997-23116-1-git-send-email-blogic@openwrt.org>
	<1457340997-23116-3-git-send-email-blogic@openwrt.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	linux-mediatek@lists.infradead.org, steven.liu@mediatek.com,
	Carlos.Huang@mediatek.com, nbd@openwrt.org, igvtee@gmail.com
To: blogic@openwrt.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51036 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752418AbcCGQa4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2016 11:30:56 -0500
In-Reply-To: <1457340997-23116-3-git-send-email-blogic@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Crispin <blogic@openwrt.org>
Date: Mon,  7 Mar 2016 09:56:35 +0100

> +static int mtk_mdio_busy_wait(struct mtk_eth *eth)
> +{
> +	unsigned long t_start = jiffies;
> +
> +	while (1) {
> +		if (!(mtk_r32(eth, MTK_PHY_IAC) & PHY_IAC_ACCESS))
> +			return 0;
> +		if (time_after(jiffies, t_start + PHY_IAC_TIMEOUT))
> +			break;
> +	}
> +
> +	dev_err(eth->dev, "mdio: MDIO timeout\n");
> +	return -1;
> +}

Busy polling in a loop for up to 5 seconds with no preemption points
is not something you can do, sorry.
