From: Becky Bruce <beckyb@kernel.crashing.org>
Subject: Re: [PATCH] net/fec_mpc52xx: fix BUG on missing dma_ops
Date: Mon, 30 Mar 2009 17:30:01 -0500
Message-ID: <48A51477-AF94-4E65-A224-A3D5125D22E4@kernel.crashing.org>
References: <20090330184423.31699.61150.stgit@localhost.localdomain>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org,
	David Miller <davem@davemloft.net>
To: Grant Likely <grant.likely@secretlab.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:44541 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753175AbZC3WaO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Mar 2009 18:30:14 -0400
In-Reply-To: <20090330184423.31699.61150.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Mar 30, 2009, at 1:53 PM, Grant Likely wrote:

> From: Grant Likely <grant.likely@secretlab.ca>
>
> The driver triggers a BUG_ON() when allocating DMA buffers if the
> arch/powerpc dma_ops from the of_platform device are not copied
> into net_device structure.
>
> Signed-off-by: Grant Likely <grant.likely@secretlab.ca>
> ---
> David, do you want to pick this one up right away, or should I merge  
> it
> through Ben's powerpc tree?


Grant,

I really think you need to do what Kumar did for gianfar (http://patchwork.ozlabs.org/patch/24562/ 
) - your  patch just fixes the dma_ops problem, not the problem with  
getting to the correct archdata, which contains an offset (dma_data)  
that is used to form a bus address used in the various dma  
operations.  Grep for get_dma_direct_offset in arch/powerpc and you'll  
see it used in the various dma operations.

Cheers,
B

>
>
> g.
>
> drivers/net/fec_mpc52xx.c |    3 +++
> 1 files changed, 3 insertions(+), 0 deletions(-)
>
>
> diff --git a/drivers/net/fec_mpc52xx.c b/drivers/net/fec_mpc52xx.c
> index 049b0a7..215207d 100644
> --- a/drivers/net/fec_mpc52xx.c
> +++ b/drivers/net/fec_mpc52xx.c
> @@ -928,6 +928,9 @@ mpc52xx_fec_probe(struct of_device *op, const  
> struct of_device_id *match)
> 	if (!request_mem_region(mem.start, sizeof(struct mpc52xx_fec),  
> DRIVER_NAME))
> 		return -EBUSY;
>
> +	/* Copy the PowerPC dma_ops from the of_device */
> +	set_dma_ops(&ndev->dev, get_dma_ops(&op->dev));
> +
> 	/* Init ether ndev with what we have */
> 	ndev->open		= mpc52xx_fec_open;
> 	ndev->stop		= mpc52xx_fec_close;
>
> _______________________________________________
> Linuxppc-dev mailing list
> Linuxppc-dev@ozlabs.org
> https://ozlabs.org/mailman/listinfo/linuxppc-dev

