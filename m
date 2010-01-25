From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 1/1 V4] net: Add Aeroflex Gaisler 10/100/1G Ethernet MAC
 driver
Date: Mon, 25 Jan 2010 08:33:22 -0800
Message-ID: <20100125083322.2100eab1@nehalam>
References: <1264417272-3800-1-git-send-email-kristoffer@gaisler.com>
	<1264417272-3800-2-git-send-email-kristoffer@gaisler.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Kristoffer Glembo <kristoffer@gaisler.com>
To: Kristoffer Glembo <kristoffer@gaisler.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:34057 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751392Ab0AYQdn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Jan 2010 11:33:43 -0500
In-Reply-To: <1264417272-3800-2-git-send-email-kristoffer@gaisler.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 25 Jan 2010 12:01:12 +0100
Kristoffer Glembo <kristoffer@gaisler.com> wrote:

> +static int greth_start_xmit(struct sk_buff *skb, struct net_device *dev)
> +{
> +	struct greth_private *greth = netdev_priv(dev);
> +	struct greth_bd *bdp;
> +	int err = NETDEV_TX_OK;
> +	u32 status, dma_addr;
> +
> +	bdp = greth->tx_bd_base + greth->tx_next;
> +
> +	if (unlikely(greth->tx_free <= 0)) {
> +		netif_stop_queue(dev);
> +		err = NETDEV_TX_BUSY;
> +		goto out;
> +	}
...
> +
> +out:
> +	dev_kfree_skb(skb);
> +	return err;
> +}
> +

Wrong, if device is busy; then skb must NOT be freed.


-- 
