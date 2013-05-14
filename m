From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCHv2] mv643xx_eth: fix NAPI weight being > 64
Date: Tue, 14 May 2013 06:10:08 -0700
Message-ID: <1368537008.4519.5.camel@edumazet-glaptop>
References: <1368525260-17556-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Jason Cooper <jason@lakedaemon.net>,
	buytenh@wantstofly.org,
	linux ARM <linux-arm-kernel@lists.infradead.org>,
	netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f47.google.com ([209.85.210.47]:33409 "EHLO
	mail-da0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751846Ab3ENNKN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 May 2013 09:10:13 -0400
Received: by mail-da0-f47.google.com with SMTP id k13so303629dae.34
        for <netdev@vger.kernel.org>; Tue, 14 May 2013 06:10:13 -0700 (PDT)
In-Reply-To: <1368525260-17556-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-05-14 at 11:54 +0200, Andrew Lunn wrote:
> 3.10-rc1 issues the following warning:
> 
> netif_napi_add() called with weight 128 on device eth%d
> 
> This patch reduce the weight to 64, using NAPI_POLL_WEIGHT.
> 
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>
> ---
> v1->v2: Use NAPI_POLL_WEIGHT.
> 
>  drivers/net/ethernet/marvell/mv643xx_eth.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/marvell/mv643xx_eth.c b/drivers/net/ethernet/marvell/mv643xx_eth.c
> index d0afeea..8f63c36 100644
> --- a/drivers/net/ethernet/marvell/mv643xx_eth.c
> +++ b/drivers/net/ethernet/marvell/mv643xx_eth.c
> @@ -2745,7 +2745,7 @@ static int mv643xx_eth_probe(struct platform_device *pdev)
>  
>  	INIT_WORK(&mp->tx_timeout_task, tx_timeout_task);
>  
> -	netif_napi_add(dev, &mp->napi, mv643xx_eth_poll, 128);
> +	netif_napi_add(dev, &mp->napi, mv643xx_eth_poll, NAPI_POLL_WEIGHT);
>  
>  	init_timer(&mp->rx_oom);
>  	mp->rx_oom.data = (unsigned long)mp;

Thanks Andrew.

Note that some other drivers need same change, would you mind sending a
patch for them as well ?

Acked-by: Eric Dumazet <edumazet@google.com>

drivers/s390/net/qeth_core.h:741:#define QETH_NAPI_WEIGHT 128
drivers/infiniband/hw/nes/nes_nic.c:1682:       netif_napi_add(netdev, &nesvnic->napi, nes_netdev_poll, 128);
drivers/infiniband/ulp/ipoib/ipoib_main.c:1356: netif_napi_add(dev, &priv->napi, ipoib_poll, 100);
drivers/net/can/janz-ican3.c:1794:      netif_napi_add(ndev, &mod->napi, ican3_napi, ICAN3_RX_BUFFERS);
