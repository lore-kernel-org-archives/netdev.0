From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: Re: [net-next PATCH 1/1] drivers: net: cpsw: fix kernel warn on cpsw
 irq enable
Date: Fri, 26 Apr 2013 14:03:24 +0200
Message-ID: <517A6D0C.6020702@linutronix.de>
References: <1366975848-31503-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Mugunthan V N <mugunthanvnm@ti.com>, netdev@vger.kernel.org,
	linux-omap@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.linutronix.de ([62.245.132.108]:48587 "EHLO
	Galois.linutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750709Ab3DZMD2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Apr 2013 08:03:28 -0400
In-Reply-To: <1366975848-31503-1-git-send-email-mugunthanvnm@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/26/2013 01:30 PM, Mugunthan V N wrote:
> diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
> index 4e2d224..59c4391 100644
> --- a/drivers/net/ethernet/ti/cpsw.c
> +++ b/drivers/net/ethernet/ti/cpsw.c
> @@ -1633,7 +1633,6 @@ static int cpsw_probe_dual_emac(struct platform_device *pdev,
>  		priv_sl2->irqs_table[i] = priv->irqs_table[i];
>  		priv_sl2->num_irqs = priv->num_irqs;
>  	}
> -	priv->irq_enabled = true;
>  	ndev->features |= NETIF_F_HW_VLAN_CTAG_FILTER;
>  
>  	ndev->netdev_ops = &cpsw_netdev_ops;
> @@ -1679,6 +1678,7 @@ static int cpsw_probe(struct platform_device *pdev)
>  	priv->msg_enable = netif_msg_init(debug_level, CPSW_DEBUG);
>  	priv->rx_packet_max = max(rx_packet_max, 128);
>  	priv->cpts = devm_kzalloc(&pdev->dev, sizeof(struct cpts), GFP_KERNEL);
> +	priv->irq_enabled = true;
>  	if (!ndev) {
>  		pr_err("error allocating cpts\n");
>  		goto clean_ndev_ret;


David, how did this happen? The patch I've sent

   http://www.spinics.net/lists/netdev/msg234240.html

adds this to the probe function, according to the net-next tree it was
added to cpsw_probe_dual_emac(). The context is similar but not exact
the same.

Sebastian
