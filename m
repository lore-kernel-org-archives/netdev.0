From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sfc: Add per-queue statistics in ethtool
Date: Wed, 16 Jul 2014 23:19:00 -0700 (PDT)
Message-ID: <20140716.231900.1257974809394608735.davem@davemloft.net>
References: <53C634D2.80801@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: sshah@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57685 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750928AbaGQGTB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2014 02:19:01 -0400
In-Reply-To: <53C634D2.80801@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shradha Shah <sshah@solarflare.com>
Date: Wed, 16 Jul 2014 09:16:18 +0100

> @@ -445,6 +480,25 @@ static void efx_ethtool_get_stats(struct net_device *net_dev,
>  
>  	spin_unlock_bh(&efx->stats_lock);
>  
> +	efx_for_each_channel(channel, efx) {
> +		if (efx_channel_has_tx_queues(channel)) {
> +			*data = 0;
> +			efx_for_each_channel_tx_queue(tx_queue, channel) {
> +				data[0] += tx_queue->tx_packets;
> +			}
> +			data++;
> +		}
> +	}
> +	efx_for_each_channel(channel, efx) {
> +		if (efx_channel_has_rx_queue(channel)) {
> +			data[0] = 0;
> +			efx_for_each_channel_rx_queue(rx_queue, channel) {
> +				data[0] += rx_queue->rx_packets;
> +			}
> +			data++;
> +		}
> +	}

Please consistently use either data[0] or *data, probably the latter is better.
