From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v2 1/1] net: fec: Enable imx6 enet checksum
 acceleration.
Date: Tue, 16 Apr 2013 06:50:31 -0700
Message-ID: <1366120231.4459.132.camel@edumazet-glaptop>
References: <y> <1366108587-3866-1-git-send-email-jim_baxter@mentor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Frank Li <Frank.Li@freescale.com>,
	Fugang Duan <B38611@freescale.com>, netdev@vger.kernel.org
To: Jim Baxter <jim_baxter@mentor.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f44.google.com ([209.85.160.44]:59596 "EHLO
	mail-pb0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755318Ab3DPNue (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Apr 2013 09:50:34 -0400
Received: by mail-pb0-f44.google.com with SMTP id wz12so307459pbc.17
        for <netdev@vger.kernel.org>; Tue, 16 Apr 2013 06:50:33 -0700 (PDT)
In-Reply-To: <1366108587-3866-1-git-send-email-jim_baxter@mentor.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-04-16 at 11:36 +0100, Jim Baxter wrote:

> +	ndev->features |= NETIF_F_GRO;
>  	napi_enable(&fep->napi);
>  
>  	/* I should reset the ring buffers here, but I don't yet know
> @@ -1618,6 +1707,44 @@ static void fec_poll_controller(struct net_device *dev)
>  }
>  #endif

> +
>  static const struct net_device_ops fec_netdev_ops = {
>  	.ndo_open		= fec_enet_open,
>  	.ndo_stop		= fec_enet_close,
> @@ -1631,6 +1758,8 @@ static const struct net_device_ops fec_netdev_ops = {
>  #ifdef CONFIG_NET_POLL_CONTROLLER
>  	.ndo_poll_controller	= fec_poll_controller,
>  #endif
> +	.ndo_fix_features	= fec_fix_features,
> +	.ndo_set_features	= fec_set_features,
>  };
>  
>   /*
> @@ -1672,6 +1801,11 @@ static int fec_enet_init(struct net_device *ndev)
>  	writel(FEC_RX_DISABLED_IMASK, fep->hwp + FEC_IMASK);
>  	netif_napi_add(ndev, &fep->napi, fec_enet_rx_napi, FEC_NAPI_WEIGHT);
>  
> +	/* enable hw accelerator */
> +	ndev->features |= (NETIF_F_HW_CSUM | NETIF_F_GRO);
> +	ndev->hw_features |= (NETIF_F_HW_CSUM | NETIF_F_GRO);
> +	fep->csum_flags |= FLAG_RX_CSUM_ENABLED;
> +
>  	fec_restart(ndev, 0);
>  
>  	return 0;

Unless I am missing something, NETIF_F_GRO doesn't need to be set by a
driver.

Documentation/networking/netdev-features.txt lines 129-130
