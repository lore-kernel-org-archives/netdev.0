From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 06/17] mlx4_en: using new mlx4 interrupt scheme
Date: Mon, 07 Mar 2011 12:41:55 +0000
Message-ID: <1299501715.3134.49.camel@localhost>
References: <4D74B0AE.5070403@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, markuze@mellanox.co.il
To: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:56657 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751054Ab1CGMmO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2011 07:42:14 -0500
In-Reply-To: <4D74B0AE.5070403@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-03-07 at 12:17 +0200, Yevgeny Petrilin wrote:
> Each RX ring will have its own interrupt vector, and TX rings will share one
> (we mostly use polling for TX completions).
> The vectors are assigned first time device is opened, and its name includes
> the interface name and ring number.
[...]
> --- a/drivers/net/mlx4/en_main.c
> +++ b/drivers/net/mlx4/en_main.c
[...]
> @@ -601,10 +602,19 @@ int mlx4_en_start_port(struct net_device *dev)
>  		goto cq_err;
>  	}
>  
> +	if (mdev->dev->caps.comp_pool && !priv->tx_vector) {
> +		sprintf(name , "%s_tx", priv->dev->name);
> +		if (mlx4_assign_eq(mdev->dev , name, &priv->tx_vector)) {
> +			mlx4_warn(mdev, "Failed Assigning an EQ to "
> +					"%s_tx ,Falling back to legacy "
> +					"EQ's\n", priv->dev->name);
> +		}
> +	}
[...]

If this string is being copied to the IRQ name, it should be
"<ifname>-tx" not "<ifname>_tx" for consistency with other drivers.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

