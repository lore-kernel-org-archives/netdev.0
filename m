From: Ben Dooks <ben@fluff.org>
Subject: Re: [PATCH] [DM9000] External PHY support
Date: Tue, 14 Aug 2007 19:26:51 +0100
Message-ID: <20070814182651.GB12547@fluff.org.uk>
References: <200708141329.35301.laurentp@cse-semaphore.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Laurent Pinchart <laurentp@cse-semaphore.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 87-194-8-8.bethere.co.uk ([87.194.8.8]:56513 "EHLO
	aeryn.fluff.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751034AbXHNS0x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Aug 2007 14:26:53 -0400
Content-Disposition: inline
In-Reply-To: <200708141329.35301.laurentp@cse-semaphore.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 14, 2007 at 01:29:35PM +0200, Laurent Pinchart wrote:
> This patch adds a flag to the DM9000 platform data which, when set,
> configures the device to use an external PHY.

This patch applies with fuzz:

$ patch -p1 < ~/dm9000-external-phy.patch   
patching file drivers/net/dm9000.c
Hunk #1 succeeded at 136 (offset 12 lines).
Hunk #2 succeeded at 529 (offset 15 lines).
Hunk #3 succeeded at 673 (offset 15 lines).
patching file include/linux/dm9000.h

> Signed-off-by: Laurent Pinchart <laurentp@cse-semaphore.com>
> ---
>  drivers/net/dm9000.c   |    6 ++++++
>  include/linux/dm9000.h |    1 +
>  2 files changed, 7 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/dm9000.c b/drivers/net/dm9000.c
> index ee578d9..820f0d3 100644
> --- a/drivers/net/dm9000.c
> +++ b/drivers/net/dm9000.c
> @@ -124,6 +124,7 @@ typedef struct board_info {
>  	u16 dbug_cnt;
>  	u8 io_mode;		/* 0:word, 2:byte */
>  	u8 phy_addr;
> +	unsigned int flags;
>  
>  	void (*inblk)(void __iomem *port, void *data, int length);
>  	void (*outblk)(void __iomem *port, void *data, int length);
> @@ -513,6 +514,8 @@ dm9000_probe(struct platform_device *pdev)
>  
>  		if (pdata->dumpblk != NULL)
>  			db->dumpblk = pdata->dumpblk;
> +
> +		db->flags = pdata->flags;
>  	}
>  
>  	dm9000_reset(db);
> @@ -655,6 +658,9 @@ dm9000_init_dm9000(struct net_device *dev)
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

-- 
Ben (ben@fluff.org, http://www.fluff.org/)

  'a smiley only costs 4 bytes'
