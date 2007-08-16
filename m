From: Ben Dooks <ben-linux@fluff.org>
Subject: Re: [PATCH 2/2] [DM9000] External PHY support
Date: Thu, 16 Aug 2007 18:00:47 +0100
Message-ID: <20070816170047.GD12547@fluff.org.uk>
References: <200708161016.08180.laurentp@cse-semaphore.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Ben Dooks <ben-linux@fluff.org>
To: Laurent Pinchart <laurentp@cse-semaphore.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 87-194-8-8.bethere.co.uk ([87.194.8.8]:63248 "EHLO
	aeryn.fluff.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752632AbXHPRAs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Aug 2007 13:00:48 -0400
Content-Disposition: inline
In-Reply-To: <200708161016.08180.laurentp@cse-semaphore.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 16, 2007 at 10:16:08AM +0200, Laurent Pinchart wrote:
> This patch adds a flag to the DM9000 platform data which, when set,
> configures the device to use an external PHY.
> 
> Signed-off-by: Laurent Pinchart <laurentp@cse-semaphore.com>
Acked-by: Ben Dooks <ben-linux@fluff.org>
> ---
>  drivers/net/dm9000.c   |    6 ++++++
>  include/linux/dm9000.h |    1 +
>  2 files changed, 7 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/dm9000.c b/drivers/net/dm9000.c
> index a424810..a86984e 100644
> --- a/drivers/net/dm9000.c
> +++ b/drivers/net/dm9000.c
> @@ -136,6 +136,7 @@ typedef struct board_info {
>  	u16 dbug_cnt;
>  	u8 io_mode;		/* 0:word, 2:byte */
>  	u8 phy_addr;
> +	unsigned int flags;
>  
>  	void (*inblk)(void __iomem *port, void *data, int length);
>  	void (*outblk)(void __iomem *port, void *data, int length);
> @@ -528,6 +529,8 @@ dm9000_probe(struct platform_device *pdev)
>  
>  		if (pdata->dumpblk != NULL)
>  			db->dumpblk = pdata->dumpblk;
> +
> +		db->flags = pdata->flags;
>  	}
>  
>  	dm9000_reset(db);
> @@ -670,6 +673,9 @@ dm9000_init_dm9000(struct net_device *dev)
>  	iow(db, DM9000_GPCR, GPCR_GEP_CNTL);	/* Let GPIO0 output */
>  	iow(db, DM9000_GPR, 0);	/* Enable PHY */
>  
> +	if (db->flags & DM9000_PLATF_EXT_PHY)
> +		iow(db, DM9000_NCR, NCR_EXT_PHY);
> +
>  	/* Program operating register */
>  	iow(db, DM9000_TCR, 0);	        /* TX Polling clear */
>  	iow(db, DM9000_BPTR, 0x3f);	/* Less 3Kb, 200us */
> diff --git a/include/linux/dm9000.h b/include/linux/dm9000.h
> index 0008e2a..ea530fd 100644
> --- a/include/linux/dm9000.h
> +++ b/include/linux/dm9000.h
> @@ -19,6 +19,7 @@
>  #define DM9000_PLATF_8BITONLY	(0x0001)
>  #define DM9000_PLATF_16BITONLY	(0x0002)
>  #define DM9000_PLATF_32BITONLY	(0x0004)
> +#define DM9000_PLATF_EXT_PHY	(0x0008)
>  
>  /* platfrom data for platfrom device structure's platfrom_data field */
>  
> -- 
> 1.5.0
> 
> -- 
> Laurent Pinchart
> CSE Semaphore Belgium
> 
> Chauss?e de Bruxelles, 732A
> B-1410 Waterloo
> Belgium
> 
> T +32 (2) 387 42 59
> F +32 (2) 387 42 75
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Ben (ben@fluff.org, http://www.fluff.org/)

  'a smiley only costs 4 bytes'
