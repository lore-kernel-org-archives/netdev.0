From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH v3 7/9] bgmac: simplify dma init/cleanup
Date: Mon, 13 Apr 2015 00:53:16 +0200
Message-ID: <20150412225316.GA5195@electric-eye.fr.zoreil.com>
References: <1428874711-23950-1-git-send-email-nbd@openwrt.org>
 <1428874711-23950-7-git-send-email-nbd@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, zajec5@gmail.com, hauke@hauke-m.de,
	eric.dumazet@gmail.com
To: Felix Fietkau <nbd@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:38883 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752921AbbDLWxY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Apr 2015 18:53:24 -0400
Content-Disposition: inline
In-Reply-To: <1428874711-23950-7-git-send-email-nbd@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Felix Fietkau <nbd@openwrt.org> :
[...]
> diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/ethernet/broadcom/bgmac.c
> index 3ac8d9a..417415c 100644
> --- a/drivers/net/ethernet/broadcom/bgmac.c
> +++ b/drivers/net/ethernet/broadcom/bgmac.c
[...]
> @@ -1261,8 +1253,15 @@ static int bgmac_open(struct net_device *net_dev)
>  	int err = 0;
>  
>  	bgmac_chip_reset(bgmac);
> +
> +	err = bgmac_dma_init(bgmac);
> +	if (err) {
> +		bgmac_dma_cleanup(bgmac);
> +		return err;
> +	}
> +
>  	/* Specs say about reclaiming rings here, but we do that in DMA init */
> -	bgmac_chip_init(bgmac, true);
> +	bgmac_chip_init(bgmac);
>  
>  	err = request_irq(bgmac->core->irq, bgmac_interrupt, IRQF_SHARED,
>  			  KBUILD_MODNAME, net_dev);
> @@ -1293,6 +1292,7 @@ static int bgmac_stop(struct net_device *net_dev)
>  	free_irq(bgmac->core->irq, net_dev);
>  
>  	bgmac_chip_reset(bgmac);
> +	bgmac_dma_cleanup(bgmac);
>  
>  	return 0;
>  }

Looks like missing bgmac_dma_cleanup if request_irq fails.

-- 
Ueimor
