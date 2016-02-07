From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH v2] net: ethernet: davicom: fix devicetree irq resource
Date: Sun, 7 Feb 2016 11:23:03 +0100
Message-ID: <20160207102303.GA4976@electric-eye.fr.zoreil.com>
References: <1454796693-4446-1-git-send-email-robert.jarzmik@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
To: Robert Jarzmik <robert.jarzmik@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:35827 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753674AbcBGKXJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Feb 2016 05:23:09 -0500
Content-Disposition: inline
In-Reply-To: <1454796693-4446-1-git-send-email-robert.jarzmik@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Robert Jarzmik <robert.jarzmik@free.fr> :
[...]
> diff --git a/drivers/net/ethernet/davicom/dm9000.c b/drivers/net/ethernet/davicom/dm9000.c
> index cf94b72dbacd..2bae5c8c1f85 100644
> --- a/drivers/net/ethernet/davicom/dm9000.c
> +++ b/drivers/net/ethernet/davicom/dm9000.c
[...]
> @@ -1500,15 +1496,21 @@ dm9000_probe(struct platform_device *pdev)
>  
>  	db->addr_res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
>  	db->data_res = platform_get_resource(pdev, IORESOURCE_MEM, 1);
> -	db->irq_res  = platform_get_resource(pdev, IORESOURCE_IRQ, 0);
>  
> -	if (db->addr_res == NULL || db->data_res == NULL ||
> -	    db->irq_res == NULL) {
> -		dev_err(db->dev, "insufficient resources\n");
> +	if (!db->addr_res || !db->data_res) {
> +		dev_err(db->dev, "insufficient resources addr=%p data=%p\n",
> +			db->addr_res, db->data_res);
>  		ret = -ENOENT;
>  		goto out;
>  	}
>  
> +	ndev->irq = platform_get_irq(pdev, 0);
> +	if (ndev->irq < 0) {
> +		dev_err(db->dev, "interrupt resource unavailable: %d\n",
> +			ndev->irq);
> +		return ndev->irq;
> +	}
> +

Leak: please set 'ret = ndev->irq;' and proceed to the 'out' label.

If you have some spare time, it would be nice to avoid db->irq_wake leak
on probe failure or driver removal.

-- 
Ueimor
