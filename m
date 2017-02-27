From: Peter Senna Tschudin <peter.senna-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org>
Subject: Re: [PATCH v3 12/20] scsi: mpt3sas: Replace PCI pool old API
Date: Mon, 27 Feb 2017 12:18:02 +0100
Message-ID: <20170227111802.GF26544@collabora.com>
References: <20170226192425.13098-1-romain.perier@collabora.com>
 <20170226192425.13098-13-romain.perier@collabora.com>
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
In-Reply-To: <20170226192425.13098-13-romain.perier-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, Feb 26, 2017 at 08:24:17PM +0100, Romain Perier wrote:
> The PCI pool API is deprecated. This commits replaces the PCI pool old
> API by the appropriated function with the DMA pool API.
> 
Reviewed-by: Peter Senna Tschudin <peter.senna-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org>
> Signed-off-by: Romain Perier <romain.perier-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org>
> ---
>  drivers/scsi/mpt3sas/mpt3sas_base.c | 73 +++++++++++++++++--------------------
>  1 file changed, 34 insertions(+), 39 deletions(-)
> 
> diff --git a/drivers/scsi/mpt3sas/mpt3sas_base.c b/drivers/scsi/mpt3sas/mpt3sas_base.c
> index 5b7aec5..5ae1c23 100644
> --- a/drivers/scsi/mpt3sas/mpt3sas_base.c
> +++ b/drivers/scsi/mpt3sas/mpt3sas_base.c
> @@ -3200,9 +3200,8 @@ _base_release_memory_pools(struct MPT3SAS_ADAPTER *ioc)
>  	}
>  
>  	if (ioc->sense) {
> -		pci_pool_free(ioc->sense_dma_pool, ioc->sense, ioc->sense_dma);
> -		if (ioc->sense_dma_pool)
> -			pci_pool_destroy(ioc->sense_dma_pool);
> +		dma_pool_free(ioc->sense_dma_pool, ioc->sense, ioc->sense_dma);
> +		dma_pool_destroy(ioc->sense_dma_pool);
>  		dexitprintk(ioc, pr_info(MPT3SAS_FMT
>  			"sense_pool(0x%p): free\n",
>  			ioc->name, ioc->sense));
> @@ -3210,9 +3209,8 @@ _base_release_memory_pools(struct MPT3SAS_ADAPTER *ioc)
>  	}
>  
>  	if (ioc->reply) {
> -		pci_pool_free(ioc->reply_dma_pool, ioc->reply, ioc->reply_dma);
> -		if (ioc->reply_dma_pool)
> -			pci_pool_destroy(ioc->reply_dma_pool);
> +		dma_pool_free(ioc->reply_dma_pool, ioc->reply, ioc->reply_dma);
> +		dma_pool_destroy(ioc->reply_dma_pool);
>  		dexitprintk(ioc, pr_info(MPT3SAS_FMT
>  			"reply_pool(0x%p): free\n",
>  			ioc->name, ioc->reply));
> @@ -3220,10 +3218,9 @@ _base_release_memory_pools(struct MPT3SAS_ADAPTER *ioc)
>  	}
>  
>  	if (ioc->reply_free) {
> -		pci_pool_free(ioc->reply_free_dma_pool, ioc->reply_free,
> +		dma_pool_free(ioc->reply_free_dma_pool, ioc->reply_free,
>  		    ioc->reply_free_dma);
> -		if (ioc->reply_free_dma_pool)
> -			pci_pool_destroy(ioc->reply_free_dma_pool);
> +		dma_pool_destroy(ioc->reply_free_dma_pool);
>  		dexitprintk(ioc, pr_info(MPT3SAS_FMT
>  			"reply_free_pool(0x%p): free\n",
>  			ioc->name, ioc->reply_free));
> @@ -3234,7 +3231,7 @@ _base_release_memory_pools(struct MPT3SAS_ADAPTER *ioc)
>  		do {
>  			rps = &ioc->reply_post[i];
>  			if (rps->reply_post_free) {
> -				pci_pool_free(
> +				dma_pool_free(
>  				    ioc->reply_post_free_dma_pool,
>  				    rps->reply_post_free,
>  				    rps->reply_post_free_dma);
> @@ -3246,8 +3243,7 @@ _base_release_memory_pools(struct MPT3SAS_ADAPTER *ioc)
>  		} while (ioc->rdpq_array_enable &&
>  			   (++i < ioc->reply_queue_count));
>  
> -		if (ioc->reply_post_free_dma_pool)
> -			pci_pool_destroy(ioc->reply_post_free_dma_pool);
> +		dma_pool_destroy(ioc->reply_post_free_dma_pool);
>  		kfree(ioc->reply_post);
>  	}
>  
> @@ -3268,12 +3264,11 @@ _base_release_memory_pools(struct MPT3SAS_ADAPTER *ioc)
>  	if (ioc->chain_lookup) {
>  		for (i = 0; i < ioc->chain_depth; i++) {
>  			if (ioc->chain_lookup[i].chain_buffer)
> -				pci_pool_free(ioc->chain_dma_pool,
> +				dma_pool_free(ioc->chain_dma_pool,
>  				    ioc->chain_lookup[i].chain_buffer,
>  				    ioc->chain_lookup[i].chain_buffer_dma);
>  		}
> -		if (ioc->chain_dma_pool)
> -			pci_pool_destroy(ioc->chain_dma_pool);
> +		dma_pool_destroy(ioc->chain_dma_pool);
>  		free_pages((ulong)ioc->chain_lookup, ioc->chain_pages);
>  		ioc->chain_lookup = NULL;
>  	}
> @@ -3448,23 +3443,23 @@ _base_allocate_memory_pools(struct MPT3SAS_ADAPTER *ioc)
>  			ioc->name);
>  		goto out;
>  	}
> -	ioc->reply_post_free_dma_pool = pci_pool_create("reply_post_free pool",
> -	    ioc->pdev, sz, 16, 0);
> +	ioc->reply_post_free_dma_pool = dma_pool_create("reply_post_free pool",
> +	    &ioc->pdev->dev, sz, 16, 0);
>  	if (!ioc->reply_post_free_dma_pool) {
>  		pr_err(MPT3SAS_FMT
> -		 "reply_post_free pool: pci_pool_create failed\n",
> +		 "reply_post_free pool: dma_pool_create failed\n",
>  		 ioc->name);
>  		goto out;
>  	}
>  	i = 0;
>  	do {
>  		ioc->reply_post[i].reply_post_free =
> -		    pci_pool_alloc(ioc->reply_post_free_dma_pool,
> +		    dma_pool_alloc(ioc->reply_post_free_dma_pool,
>  		    GFP_KERNEL,
>  		    &ioc->reply_post[i].reply_post_free_dma);
>  		if (!ioc->reply_post[i].reply_post_free) {
>  			pr_err(MPT3SAS_FMT
> -			"reply_post_free pool: pci_pool_alloc failed\n",
> +			"reply_post_free pool: dma_pool_alloc failed\n",
>  			ioc->name);
>  			goto out;
>  		}
> @@ -3579,15 +3574,15 @@ _base_allocate_memory_pools(struct MPT3SAS_ADAPTER *ioc)
>  			ioc->name);
>  		goto out;
>  	}
> -	ioc->chain_dma_pool = pci_pool_create("chain pool", ioc->pdev,
> +	ioc->chain_dma_pool = dma_pool_create("chain pool", &ioc->pdev->dev,
>  	    ioc->chain_segment_sz, 16, 0);
>  	if (!ioc->chain_dma_pool) {
> -		pr_err(MPT3SAS_FMT "chain_dma_pool: pci_pool_create failed\n",
> +		pr_err(MPT3SAS_FMT "chain_dma_pool: dma_pool_create failed\n",
>  			ioc->name);
>  		goto out;
>  	}
>  	for (i = 0; i < ioc->chain_depth; i++) {
> -		ioc->chain_lookup[i].chain_buffer = pci_pool_alloc(
> +		ioc->chain_lookup[i].chain_buffer = dma_pool_alloc(
>  		    ioc->chain_dma_pool , GFP_KERNEL,
>  		    &ioc->chain_lookup[i].chain_buffer_dma);
>  		if (!ioc->chain_lookup[i].chain_buffer) {
> @@ -3632,17 +3627,17 @@ _base_allocate_memory_pools(struct MPT3SAS_ADAPTER *ioc)
>  
>  	/* sense buffers, 4 byte align */
>  	sz = ioc->scsiio_depth * SCSI_SENSE_BUFFERSIZE;
> -	ioc->sense_dma_pool = pci_pool_create("sense pool", ioc->pdev, sz, 4,
> -	    0);
> +	ioc->sense_dma_pool = dma_pool_create("sense pool", &ioc->pdev->dev, sz,
> +					      4, 0);
>  	if (!ioc->sense_dma_pool) {
> -		pr_err(MPT3SAS_FMT "sense pool: pci_pool_create failed\n",
> +		pr_err(MPT3SAS_FMT "sense pool: dma_pool_create failed\n",
>  		    ioc->name);
>  		goto out;
>  	}
> -	ioc->sense = pci_pool_alloc(ioc->sense_dma_pool , GFP_KERNEL,
> +	ioc->sense = dma_pool_alloc(ioc->sense_dma_pool, GFP_KERNEL,
>  	    &ioc->sense_dma);
>  	if (!ioc->sense) {
> -		pr_err(MPT3SAS_FMT "sense pool: pci_pool_alloc failed\n",
> +		pr_err(MPT3SAS_FMT "sense pool: dma_pool_alloc failed\n",
>  		    ioc->name);
>  		goto out;
>  	}
> @@ -3656,17 +3651,17 @@ _base_allocate_memory_pools(struct MPT3SAS_ADAPTER *ioc)
>  
>  	/* reply pool, 4 byte align */
>  	sz = ioc->reply_free_queue_depth * ioc->reply_sz;
> -	ioc->reply_dma_pool = pci_pool_create("reply pool", ioc->pdev, sz, 4,
> -	    0);
> +	ioc->reply_dma_pool = dma_pool_create("reply pool", &ioc->pdev->dev, sz,
> +					      4, 0);
>  	if (!ioc->reply_dma_pool) {
> -		pr_err(MPT3SAS_FMT "reply pool: pci_pool_create failed\n",
> +		pr_err(MPT3SAS_FMT "reply pool: dma_pool_create failed\n",
>  		    ioc->name);
>  		goto out;
>  	}
> -	ioc->reply = pci_pool_alloc(ioc->reply_dma_pool , GFP_KERNEL,
> +	ioc->reply = dma_pool_alloc(ioc->reply_dma_pool, GFP_KERNEL,
>  	    &ioc->reply_dma);
>  	if (!ioc->reply) {
> -		pr_err(MPT3SAS_FMT "reply pool: pci_pool_alloc failed\n",
> +		pr_err(MPT3SAS_FMT "reply pool: dma_pool_alloc failed\n",
>  		    ioc->name);
>  		goto out;
>  	}
> @@ -3682,17 +3677,17 @@ _base_allocate_memory_pools(struct MPT3SAS_ADAPTER *ioc)
>  
>  	/* reply free queue, 16 byte align */
>  	sz = ioc->reply_free_queue_depth * 4;
> -	ioc->reply_free_dma_pool = pci_pool_create("reply_free pool",
> -	    ioc->pdev, sz, 16, 0);
> +	ioc->reply_free_dma_pool = dma_pool_create("reply_free pool",
> +	    &ioc->pdev->dev, sz, 16, 0);
>  	if (!ioc->reply_free_dma_pool) {
> -		pr_err(MPT3SAS_FMT "reply_free pool: pci_pool_create failed\n",
> +		pr_err(MPT3SAS_FMT "reply_free pool: dma_pool_create failed\n",
>  			ioc->name);
>  		goto out;
>  	}
> -	ioc->reply_free = pci_pool_alloc(ioc->reply_free_dma_pool , GFP_KERNEL,
> +	ioc->reply_free = dma_pool_alloc(ioc->reply_free_dma_pool, GFP_KERNEL,
>  	    &ioc->reply_free_dma);
>  	if (!ioc->reply_free) {
> -		pr_err(MPT3SAS_FMT "reply_free pool: pci_pool_alloc failed\n",
> +		pr_err(MPT3SAS_FMT "reply_free pool: dma_pool_alloc failed\n",
>  			ioc->name);
>  		goto out;
>  	}
> @@ -3710,7 +3705,7 @@ _base_allocate_memory_pools(struct MPT3SAS_ADAPTER *ioc)
>  	    ioc->config_page_sz, &ioc->config_page_dma);
>  	if (!ioc->config_page) {
>  		pr_err(MPT3SAS_FMT
> -			"config page: pci_pool_alloc failed\n",
> +			"config page: dma_pool_alloc failed\n",
>  			ioc->name);
>  		goto out;
>  	}
> -- 
> 2.9.3
> 
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
