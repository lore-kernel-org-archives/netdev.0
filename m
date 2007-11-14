From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 5/7] CAN: Add virtual CAN netdevice driver
Date: Wed, 14 Nov 2007 13:51:59 +0100
Message-ID: <473AEF6F.1070808@trash.net>
References: <20071114121339.25823.0@janus.isnogud.escape.de> <20071114121426.25823.5@janus.isnogud.escape.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Urs Thuermann <urs.thuermann@volkswagen.de>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>
To: Urs Thuermann <urs.thuermann@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:43880 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750718AbXKNMwM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2007 07:52:12 -0500
In-Reply-To: <20071114121426.25823.5@janus.isnogud.escape.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Urs Thuermann wrote:
> +static int vcan_open(struct net_device *dev)
> +{
> +	DBG("%s: interface up\n", dev->name);
> +
> +	netif_start_queue(dev);
> +	return 0;
> +}
> +
> +static int vcan_stop(struct net_device *dev)
> +{
> +	DBG("%s: interface down\n", dev->name);
> +
> +	netif_stop_queue(dev);
> +	return 0;
> +}


These two functions look unnecessary, there's no need to manage
the queue for pure software devices.

> +static int vcan_tx(struct sk_buff *skb, struct net_device *dev)
> +{
> +	struct net_device_stats *stats = &dev->stats;
> +	int loop;
> +
> +	DBG("sending skbuff on interface %s\n", dev->name);
> +
> +	stats->tx_packets++;
> +	stats->tx_bytes += skb->len;
> +
> +	/* set flag whether this packet has to be looped back */
> +	loop = skb->pkt_type == PACKET_LOOPBACK;
> +
> +	if (!echo) {
> +		/* no echo handling available inside this driver */
> +
> +		if (loop) {
> +			/*
> +			 * only count the packets here, because the
> +			 * CAN core already did the echo for us
> +			 */
> +			stats->rx_packets++;
> +			stats->rx_bytes += skb->len;
> +		}
> +		kfree_skb(skb);
> +		return 0;

Please use the NETDEV_TX codes.

Besides these minor issues, looks fine.

