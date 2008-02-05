From: Ben Dooks <ben-linux@fluff.org>
Subject: Re: [PATCH 02/24 for-2.6.25] DM9000: Add platform data to specify
	external phy
Date: Tue, 5 Feb 2008 00:14:09 +0000
Message-ID: <20080205001409.GC15407@fluff.org.uk>
References: <20080205000159.432081941@fluff.org.uk> <20080205000814.732404707@fluff.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jeff@garzik.org, akpm@linux-foundation.org,
	daniel@caiaq.de, laurentp@cse-semaphore.com,
	Ben Dooks <ben-linuy@fluff.org>
To: Ben Dooks <ben-linux@fluff.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 87-194-8-8.bethere.co.uk ([87.194.8.8]:58971 "EHLO
	kira.home.fluff.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756753AbYBEAOL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Feb 2008 19:14:11 -0500
Content-Disposition: inline
In-Reply-To: <20080205000814.732404707@fluff.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This should have been:

Patch from: Laurent Pinchart <laurentp@cse-semaphore.com>

This patch adds a flag to the DM9000 platform data which, when set,
configures the device to use an external PHY.

Signed-off-by: Laurent Pinchart <laurentp@cse-semaphore.com>
Signed-off-by: Ben Dooks <ben-linuy@fluff.org>

> Index: linux-2.6.24-git5-dm9k/drivers/net/dm9000.c
> ===================================================================
> --- linux-2.6.24-git5-dm9k.orig/drivers/net/dm9000.c
> +++ linux-2.6.24-git5-dm9k/drivers/net/dm9000.c
> @@ -137,6 +137,7 @@ typedef struct board_info {
>  	u16 dbug_cnt;
>  	u8 io_mode;		/* 0:word, 2:byte */
>  	u8 phy_addr;
> +	unsigned int flags;
>  
>  	void (*inblk)(void __iomem *port, void *data, int length);
>  	void (*outblk)(void __iomem *port, void *data, int length);
> @@ -525,6 +526,8 @@ dm9000_probe(struct platform_device *pde
>  
>  		if (pdata->dumpblk != NULL)
>  			db->dumpblk = pdata->dumpblk;
> +
> +		db->flags = pdata->flags;
>  	}
>  
>  	dm9000_reset(db);
> @@ -665,6 +668,9 @@ dm9000_init_dm9000(struct net_device *de
>  	iow(db, DM9000_GPCR, GPCR_GEP_CNTL);	/* Let GPIO0 output */
>  	iow(db, DM9000_GPR, 0);	/* Enable PHY */
>  
> +	if (db->flags & DM9000_PLATF_EXT_PHY)
> +		iow(db, DM9000_NCR, NCR_EXT_PHY);
> +
>  	/* Program operating register */
>  	iow(db, DM9000_TCR, 0);	        /* TX Polling clear */
>  	iow(db, DM9000_BPTR, 0x3f);	/* Less 3Kb, 200us */
> Index: linux-2.6.24-git5-dm9k/include/linux/dm9000.h
> ===================================================================
> --- linux-2.6.24-git5-dm9k.orig/include/linux/dm9000.h
> +++ linux-2.6.24-git5-dm9k/include/linux/dm9000.h
> @@ -19,6 +19,7 @@
>  #define DM9000_PLATF_8BITONLY	(0x0001)
>  #define DM9000_PLATF_16BITONLY	(0x0002)
>  #define DM9000_PLATF_32BITONLY	(0x0004)
> +#define DM9000_PLATF_EXT_PHY	(0x0008)
>  
>  /* platfrom data for platfrom device structure's platfrom_data field */
>  
> 
> -- 
> Ben (ben@fluff.org, http://www.fluff.org/)
> 
>   'a smiley only costs 4 bytes'
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Ben (ben@fluff.org, http://www.fluff.org/)

  'a smiley only costs 4 bytes'
