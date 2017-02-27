From: Peter Senna Tschudin <peter.senna-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org>
Subject: Re: [PATCH v3 09/20] scsi: csiostor: Replace PCI pool old API
Date: Mon, 27 Feb 2017 12:11:37 +0100
Message-ID: <20170227111137.GC26544@collabora.com>
References: <20170226192425.13098-1-romain.perier@collabora.com>
 <20170226192425.13098-10-romain.perier@collabora.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dan Williams <dan.j.williams-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Hal Rosenstock <hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, stas.yakovlev-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
        "James E.J. Bottomley" <jejb-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>,
        "Martin K. Petersen" <martin.petersen-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>,
        Felipe Balbi <balbi-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Peter Senna Tschudin <peter.senna-ZGY8ohtN/8pPYcu2f3hruQ@public.gmane.org>
To: Romain Perier <romain.perier-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170226192425.13098-10-romain.perier-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, Feb 26, 2017 at 08:24:14PM +0100, Romain Perier wrote:
> The PCI pool API is deprecated. This commits replaces the PCI pool old
> API by the appropriated function with the DMA pool API. It also updates
> the name of some variables and the content of comments, accordingly.
> 
Reviewed-by: Peter Senna Tschudin <peter.senna-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org>
> Signed-off-by: Romain Perier <romain.perier-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org>
> ---
>  drivers/scsi/csiostor/csio_hw.h   |  2 +-
>  drivers/scsi/csiostor/csio_init.c | 11 ++++++-----
>  drivers/scsi/csiostor/csio_scsi.c |  6 +++---
>  3 files changed, 10 insertions(+), 9 deletions(-)
> 
> diff --git a/drivers/scsi/csiostor/csio_hw.h b/drivers/scsi/csiostor/csio_hw.h
> index 029bef8..55b04fc 100644
> --- a/drivers/scsi/csiostor/csio_hw.h
> +++ b/drivers/scsi/csiostor/csio_hw.h
> @@ -465,7 +465,7 @@ struct csio_hw {
>  	struct csio_pport	pport[CSIO_MAX_PPORTS];	/* Ports (XGMACs) */
>  	struct csio_hw_params	params;			/* Hw parameters */
>  
> -	struct pci_pool		*scsi_pci_pool;		/* PCI pool for SCSI */
> +	struct dma_pool		*scsi_dma_pool;		/* DMA pool for SCSI */
>  	mempool_t		*mb_mempool;		/* Mailbox memory pool*/
>  	mempool_t		*rnode_mempool;		/* rnode memory pool */
>  
> diff --git a/drivers/scsi/csiostor/csio_init.c b/drivers/scsi/csiostor/csio_init.c
> index dbe416f..292964c 100644
> --- a/drivers/scsi/csiostor/csio_init.c
> +++ b/drivers/scsi/csiostor/csio_init.c
> @@ -485,9 +485,10 @@ csio_resource_alloc(struct csio_hw *hw)
>  	if (!hw->rnode_mempool)
>  		goto err_free_mb_mempool;
>  
> -	hw->scsi_pci_pool = pci_pool_create("csio_scsi_pci_pool", hw->pdev,
> -					    CSIO_SCSI_RSP_LEN, 8, 0);
> -	if (!hw->scsi_pci_pool)
> +	hw->scsi_dma_pool = dma_pool_create("csio_scsi_dma_pool",
> +					    &hw->pdev->dev, CSIO_SCSI_RSP_LEN,
> +					    8, 0);
> +	if (!hw->scsi_dma_pool)
>  		goto err_free_rn_pool;
>  
>  	return 0;
> @@ -505,8 +506,8 @@ csio_resource_alloc(struct csio_hw *hw)
>  static void
>  csio_resource_free(struct csio_hw *hw)
>  {
> -	pci_pool_destroy(hw->scsi_pci_pool);
> -	hw->scsi_pci_pool = NULL;
> +	dma_pool_destroy(hw->scsi_dma_pool);
> +	hw->scsi_dma_pool = NULL;
>  	mempool_destroy(hw->rnode_mempool);
>  	hw->rnode_mempool = NULL;
>  	mempool_destroy(hw->mb_mempool);
> diff --git a/drivers/scsi/csiostor/csio_scsi.c b/drivers/scsi/csiostor/csio_scsi.c
> index a1ff75f..dab0d3f 100644
> --- a/drivers/scsi/csiostor/csio_scsi.c
> +++ b/drivers/scsi/csiostor/csio_scsi.c
> @@ -2445,7 +2445,7 @@ csio_scsim_init(struct csio_scsim *scm, struct csio_hw *hw)
>  
>  		/* Allocate Dma buffers for Response Payload */
>  		dma_buf = &ioreq->dma_buf;
> -		dma_buf->vaddr = pci_pool_alloc(hw->scsi_pci_pool, GFP_KERNEL,
> +		dma_buf->vaddr = dma_pool_alloc(hw->scsi_dma_pool, GFP_KERNEL,
>  						&dma_buf->paddr);
>  		if (!dma_buf->vaddr) {
>  			csio_err(hw,
> @@ -2485,7 +2485,7 @@ csio_scsim_init(struct csio_scsim *scm, struct csio_hw *hw)
>  		ioreq = (struct csio_ioreq *)tmp;
>  
>  		dma_buf = &ioreq->dma_buf;
> -		pci_pool_free(hw->scsi_pci_pool, dma_buf->vaddr,
> +		dma_pool_free(hw->scsi_dma_pool, dma_buf->vaddr,
>  			      dma_buf->paddr);
>  
>  		kfree(ioreq);
> @@ -2516,7 +2516,7 @@ csio_scsim_exit(struct csio_scsim *scm)
>  		ioreq = (struct csio_ioreq *)tmp;
>  
>  		dma_buf = &ioreq->dma_buf;
> -		pci_pool_free(scm->hw->scsi_pci_pool, dma_buf->vaddr,
> +		dma_pool_free(scm->hw->scsi_dma_pool, dma_buf->vaddr,
>  			      dma_buf->paddr);
>  
>  		kfree(ioreq);
> -- 
> 2.9.3
> 
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
