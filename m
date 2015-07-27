From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [net-next PATCH 2/2] drivers: net: cpsw: add separate napi for
 tx packet handling for performance improvment
Date: Mon, 27 Jul 2015 23:22:07 +0200
Message-ID: <20150727212206.GA8912@electric-eye.fr.zoreil.com>
References: <1437995941-5857-1-git-send-email-mugunthanvnm@ti.com>
 <1437995941-5857-3-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:44602 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754132AbbG0VW1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2015 17:22:27 -0400
Content-Disposition: inline
In-Reply-To: <1437995941-5857-3-git-send-email-mugunthanvnm@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mugunthan V N <mugunthanvnm@ti.com> :
[...]
> diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
> index d68d759..4f98537 100644
> --- a/drivers/net/ethernet/ti/cpsw.c
> +++ b/drivers/net/ethernet/ti/cpsw.c
> @@ -752,13 +753,22 @@ static irqreturn_t cpsw_tx_interrupt(int irq, void *dev_id)
>  	struct cpsw_priv *priv = dev_id;
>  
>  	cpdma_ctlr_eoi(priv->dma, CPDMA_EOI_TX);
> -	cpdma_chan_process(priv->txch, 128);
> +	writel(0, &priv->wr_regs->tx_en);
> +
> +	if (netif_running(priv->ndev)) {
> +		napi_schedule(&priv->napi_tx);
> +		return IRQ_HANDLED;
> +	}


cpsw_ndo_stop calls napi_disable: you can remove netif_running.

-- 
Ueimor
