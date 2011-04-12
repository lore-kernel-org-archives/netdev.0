From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] MIPS: lantiq: add ethernet driver
Date: Tue, 12 Apr 2011 15:46:42 -0700 (PDT)
Message-ID: <20110412.154642.200375628.davem@davemloft.net>
References: <1302624675-18652-1-git-send-email-blogic@openwrt.org>
	<1302624675-18652-3-git-send-email-blogic@openwrt.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ralf@linux-mips.org, ralph.hempel@lantiq.com,
	linux-mips@linux-mips.org, netdev@vger.kernel.org
To: blogic@openwrt.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47915
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750901Ab1DLWrS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Apr 2011 18:47:18 -0400
In-Reply-To: <1302624675-18652-3-git-send-email-blogic@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Crispin <blogic@openwrt.org>
Date: Tue, 12 Apr 2011 18:11:14 +0200

> This patch adds the driver for the ETOP Packet Processing Engine (PPE32) found
> inside the XWAY family of Lantiq MIPS SoCs. This driver makes 100MBit ethernet
> work. Support for all 8 dma channels, gbit and the embedded switch found on
> the ar9/vr9 still needs to be implemented.
> 
> Signed-off-by: John Crispin <blogic@openwrt.org>
> Signed-off-by: Ralph Hempel <ralph.hempel@lantiq.com>

This driver needs some work.

> +
> +	skb_put(skb, len);
> +	skb->dev = dev;
> +	skb->protocol = eth_type_trans(skb, dev);
> +	netif_rx(skb);
> +	priv->stats.rx_packets++;
> +	priv->stats.rx_bytes += len;

Please convert this driver to use NAPI for packet reception.

> +	local_irq_save(flags);
> +	priv->rx_tasklet_running = 0;
> +	if (priv->rx_channel_mask) {
> +		priv->rx_tasklet_running = 1;
> +		tasklet_schedule(&priv->rx_tasklet);
> +	}
> +	local_irq_restore(flags);

This doesn't protect anything, use proper locking.
