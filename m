From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 2/2] netdev: driver: ethernet: Add TI CPSW driver
Date: Mon, 13 Feb 2012 09:34:21 -0800
Message-ID: <20120213093421.06ca60a7@nehalam.linuxnetplumber.net>
References: <1329113061-13026-1-git-send-email-mugunthanvnm@ti.com>
	<1329113061-13026-3-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>
To: Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:58916 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755544Ab2BMReY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Feb 2012 12:34:24 -0500
In-Reply-To: <1329113061-13026-3-git-send-email-mugunthanvnm@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 13 Feb 2012 11:34:21 +0530
Mugunthan V N <mugunthanvnm@ti.com> wrote:

> +static ssize_t cpsw_hw_stats_show(struct device *dev,
> +				     struct device_attribute *attr,
> +				     char *buf)
> +{
> +	struct net_device	*ndev = to_net_dev(dev);
> +	struct cpsw_priv	*priv = netdev_priv(ndev);
> +	int			len = 0;
> +	struct cpdma_chan_stats	dma_stats;
> +
> +#define show_stat(x) do {						\
> +	len += __show_stat(buf + len, SZ_4K - len, #x,			\
> +			   __raw_readl(&priv->hw_stats->x));		\
> +} while (0)
> +
> +#define show_dma_stat(x) do {						\
> +	len += __show_stat(buf + len, SZ_4K - len, #x, dma_stats.x);	\
> +} while (0)
> +
> +	len += snprintf(buf + len, SZ_4K - len, "CPSW Statistics:\n");
> +	show_stat(rxgoodframes);	show_stat(rxbroadcastframes);
> +	show_stat(rxmulticastframes);	show_stat(rxpauseframes);
> +	show_stat(rxcrcerrors);		show_stat(rxaligncodeerrors);
> +	show_stat(rxoversizedframes);	show_stat(rxjabberframes);
> +	show_stat(rxundersizedframes);	show_stat(rxfragments);
> +	show_stat(rxoctets);		show_stat(txgoodframes);
> +	show_stat(txbroadcastframes);	show_stat(txmulticastframes);
> +	show_stat(txpauseframes);	show_stat(txdeferredframes);
> +	show_stat(txcollisionframes);	show_stat(txsinglecollframes);
> +	show_stat(txmultcollframes);	show_stat(txexcessivecollisions);
> +	show_stat(txlatecollisions);	show_stat(txunderrun);
> +	show_stat(txcarriersenseerrors); show_stat(txoctets);
> +	show_stat(octetframes64);	show_stat(octetframes65t127);
> +	show_stat(octetframes128t255);	show_stat(octetframes256t511);
> +	show_stat(octetframes512t1023);	show_stat(octetframes1024tup);
> +	show_stat(netoctets);		show_stat(rxsofoverruns);
> +	show_stat(rxmofoverruns);	show_stat(rxdmaoverruns);
> +
> +	cpdma_chan_get_stats(priv->rxch, &dma_stats);
> +	len += snprintf(buf + len, SZ_4K - len, "\nRX DMA Statistics:\n");
> +	show_dma_stat(head_enqueue);	show_dma_stat(tail_enqueue);
> +	show_dma_stat(pad_enqueue);	show_dma_stat(misqueued);
> +	show_dma_stat(desc_alloc_fail);	show_dma_stat(pad_alloc_fail);
> +	show_dma_stat(runt_receive_buff); show_dma_stat(runt_transmit_buff);
> +	show_dma_stat(empty_dequeue);	show_dma_stat(busy_dequeue);
> +	show_dma_stat(good_dequeue);	show_dma_stat(teardown_dequeue);
> +
> +	cpdma_chan_get_stats(priv->txch, &dma_stats);
> +	len += snprintf(buf + len, SZ_4K - len, "\nTX DMA Statistics:\n");
> +	show_dma_stat(head_enqueue);	show_dma_stat(tail_enqueue);
> +	show_dma_stat(pad_enqueue);	show_dma_stat(misqueued);
> +	show_dma_stat(desc_alloc_fail);	show_dma_stat(pad_alloc_fail);
> +	show_dma_stat(runt_receive_buff); show_dma_stat(runt_transmit_buff);
> +	show_dma_stat(empty_dequeue);	show_dma_stat(busy_dequeue);
> +	show_dma_stat(good_dequeue);	show_dma_stat(teardown_dequeue);
> +
> +	return len;
> +}
> +
> +DEVICE_ATTR(hw_stats, S_IRUGO, cpsw_hw_stats_show, NULL);
> +

These stats belong in ethtool, not sysfs.
