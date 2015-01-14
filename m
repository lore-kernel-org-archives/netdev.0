From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next v13 3/3] net: hisilicon: new hip04 ethernet
 driver
Date: Wed, 14 Jan 2015 00:06:22 -0800
Message-ID: <1421222782.2847.1.camel@perches.com>
References: <1421217254-12008-1-git-send-email-dingtianhong@huawei.com>
	 <1421217254-12008-4-git-send-email-dingtianhong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: arnd@arndb.de, robh+dt@kernel.org, davem@davemloft.net,
	grant.likely@linaro.org, agraf@suse.de,
	sergei.shtylyov@cogentembedded.com,
	linux-arm-kernel@lists.infradead.org, eric.dumazet@gmail.com,
	xuwei5@hisilicon.com, zhangfei.gao@linaro.org,
	netdev@vger.kernel.org, devicetree@vger.kernel.org,
	linux@arm.linux.org.uk
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0155.hostedemail.com ([216.40.44.155]:48234 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932477AbbANIG2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2015 03:06:28 -0500
In-Reply-To: <1421217254-12008-4-git-send-email-dingtianhong@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-01-14 at 14:34 +0800, Ding Tianhong wrote:
> Support Hisilicon hip04 ethernet driver, including 100M / 1000M controller.
> The controller has no tx done interrupt, reclaim xmitted buffer in the poll.

Single comment:

> diff --git a/drivers/net/ethernet/hisilicon/hip04_eth.c b/drivers/net/ethernet/hisilicon/hip04_eth.c
[]
> +static int hip04_rx_poll(struct napi_struct *napi, int budget)
> +{
[]
> +	while (cnt && !last) {
> +		buf = priv->rx_buf[priv->rx_head];
> +		skb = build_skb(buf, priv->rx_buf_size);
> +		if (unlikely(!skb))
> +			net_dbg_ratelimited("build_skb failed\n");
> +
> +		dma_unmap_single(&ndev->dev, priv->rx_phys[priv->rx_head],
> +				 RX_BUF_SIZE, DMA_FROM_DEVICE);
> +		priv->rx_phys[priv->rx_head] = 0;
> +
> +		desc = (struct rx_desc *)skb->data;

Perhaps if (!skb) is possible, there shouldn't be
a dereference of that known null here.
