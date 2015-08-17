From: Vinod Koul <vinod.koul@intel.com>
Subject: Re: [patch] net: ethernet: micrel: fix an error code
Date: Mon, 17 Aug 2015 13:54:11 +0530
Message-ID: <20150817082411.GN13546@localhost>
References: <20150814085459.GC30728@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:12265 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750881AbbHQIWH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Aug 2015 04:22:07 -0400
Content-Disposition: inline
In-Reply-To: <20150814085459.GC30728@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 14, 2015 at 11:54:59AM +0300, Dan Carpenter wrote:
> The dma_mapping_error() function returns true or false.  We should
> return -ENOMEM if it there is a dma mapping error.

Looks good to me, but should be sent to net folks now me :)

-- 
~Vinod
 
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> 
> diff --git a/drivers/net/ethernet/micrel/ks8842.c b/drivers/net/ethernet/micrel/ks8842.c
> index f78909a..09d2e16 100644
> --- a/drivers/net/ethernet/micrel/ks8842.c
> +++ b/drivers/net/ethernet/micrel/ks8842.c
> @@ -952,9 +952,8 @@ static int ks8842_alloc_dma_bufs(struct net_device *netdev)
>  
>  	sg_dma_address(&tx_ctl->sg) = dma_map_single(adapter->dev,
>  		tx_ctl->buf, DMA_BUFFER_SIZE, DMA_TO_DEVICE);
> -	err = dma_mapping_error(adapter->dev,
> -		sg_dma_address(&tx_ctl->sg));
> -	if (err) {
> +	if (dma_mapping_error(adapter->dev, sg_dma_address(&tx_ctl->sg))) {
> +		err = -ENOMEM;
>  		sg_dma_address(&tx_ctl->sg) = 0;
>  		goto err;
>  	}
