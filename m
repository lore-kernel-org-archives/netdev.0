From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net: bcmgenet: fix increase rx_read_ptr
Date: Mon, 06 Oct 2014 09:45:50 -0700
Message-ID: <5432C73E.90805@gmail.com>
References: <1412564726-40192-1-git-send-email-jaedon.shin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jaedon Shin <jaedon.shin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:49563 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752223AbaJFQp5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2014 12:45:57 -0400
Received: by mail-pd0-f178.google.com with SMTP id y10so3496395pdj.23
        for <netdev@vger.kernel.org>; Mon, 06 Oct 2014 09:45:56 -0700 (PDT)
In-Reply-To: <1412564726-40192-1-git-send-email-jaedon.shin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/05/2014 08:05 PM, Jaedon Shin wrote:
> The rx_read_ptr must increase after using it.

Your commit message is too terse, you need to explain why you think the
current code is bad, and how your patch is fixing it.

One possible thing that I see is that we might be off by one in how we
use the enet_cb versus how we read the HW packet descriptor.

> 
> Signed-off-by: Jaedon Shin <jaedon.shin@gmail.com>
> ---
>  drivers/net/ethernet/broadcom/genet/bcmgenet.c | 6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
> index 5cc9cae..b47db5e 100644
> --- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
> +++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
> @@ -1282,9 +1282,6 @@ static unsigned int bcmgenet_desc_rx(struct bcmgenet_priv *priv,
>  
>  		rxpktprocessed++;
>  
> -		priv->rx_read_ptr++;
> -		priv->rx_read_ptr &= (priv->num_rx_bds - 1);
> -
>  		/* We do not have a backing SKB, so we do not have a
>  		 * corresponding DMA mapping for this incoming packet since
>  		 * bcmgenet_rx_refill always either has both skb and mapping or
> @@ -1399,6 +1396,9 @@ refill:
>  		err = bcmgenet_rx_refill(priv, cb);
>  		if (err)
>  			netif_err(priv, rx_err, dev, "Rx refill failed\n");
> +
> +		priv->rx_read_ptr++;
> +		priv->rx_read_ptr &= (priv->num_rx_bds - 1);
>  	}
>  
>  	return rxpktprocessed;
> 
