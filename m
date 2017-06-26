From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 01/11] dma-mapping: remove dmam_free_noncoherent
Date: Mon, 26 Jun 2017 00:07:15 -0700
Message-ID: <20170626070715.GA12711@infradead.org>
References: <20170616071716.17321-1-hch@lst.de>
 <20170616071716.17321-2-hch@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-scsi@vger.kernel.org, linux-serial@vger.kernel.org,
        netdev@vger.kernel.org, linux-metag@vger.kernel.org,
        nios2-dev@lists.rocketboards.org, linux-fbdev@vger.kernel.org,
        alsa-devel@alsa-project.org, linux-kernel@vger.kernel.org,
        Tejun Heo <tj@kernel.org>
To: Christoph Hellwig <hch@lst.de>
Return-path: <linux-scsi-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170616071716.17321-2-hch@lst.de>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Tejun, does this look ok to you?

On Fri, Jun 16, 2017 at 09:17:06AM +0200, Christoph Hellwig wrote:
> This function was never used since it was added.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  Documentation/driver-model/devres.txt |  1 -
>  drivers/base/dma-mapping.c            | 20 --------------------
>  include/linux/dma-mapping.h           |  2 --
>  3 files changed, 23 deletions(-)
> 
> diff --git a/Documentation/driver-model/devres.txt b/Documentation/driver-model/devres.txt
> index e72587fe477d..9070ff06b558 100644
> --- a/Documentation/driver-model/devres.txt
> +++ b/Documentation/driver-model/devres.txt
> @@ -243,7 +243,6 @@ DMA
>    dmam_alloc_noncoherent()
>    dmam_declare_coherent_memory()
>    dmam_free_coherent()
> -  dmam_free_noncoherent()
>    dmam_pool_create()
>    dmam_pool_destroy()
>  
> diff --git a/drivers/base/dma-mapping.c b/drivers/base/dma-mapping.c
> index f3deb6af42ad..5940c9dace36 100644
> --- a/drivers/base/dma-mapping.c
> +++ b/drivers/base/dma-mapping.c
> @@ -148,26 +148,6 @@ void *dmam_alloc_noncoherent(struct device *dev, size_t size,
>  }
>  EXPORT_SYMBOL(dmam_alloc_noncoherent);
>  
> -/**
> - * dmam_free_coherent - Managed dma_free_noncoherent()
> - * @dev: Device to free noncoherent memory for
> - * @size: Size of allocation
> - * @vaddr: Virtual address of the memory to free
> - * @dma_handle: DMA handle of the memory to free
> - *
> - * Managed dma_free_noncoherent().
> - */
> -void dmam_free_noncoherent(struct device *dev, size_t size, void *vaddr,
> -			   dma_addr_t dma_handle)
> -{
> -	struct dma_devres match_data = { size, vaddr, dma_handle };
> -
> -	dma_free_noncoherent(dev, size, vaddr, dma_handle);
> -	WARN_ON(!devres_destroy(dev, dmam_noncoherent_release, dmam_match,
> -				&match_data));
> -}
> -EXPORT_SYMBOL(dmam_free_noncoherent);
> -
>  #ifdef CONFIG_HAVE_GENERIC_DMA_COHERENT
>  
>  static void dmam_coherent_decl_release(struct device *dev, void *res)
> diff --git a/include/linux/dma-mapping.h b/include/linux/dma-mapping.h
> index 4f3eecedca2d..830ec5f06a4f 100644
> --- a/include/linux/dma-mapping.h
> +++ b/include/linux/dma-mapping.h
> @@ -749,8 +749,6 @@ extern void dmam_free_coherent(struct device *dev, size_t size, void *vaddr,
>  			       dma_addr_t dma_handle);
>  extern void *dmam_alloc_noncoherent(struct device *dev, size_t size,
>  				    dma_addr_t *dma_handle, gfp_t gfp);
> -extern void dmam_free_noncoherent(struct device *dev, size_t size, void *vaddr,
> -				  dma_addr_t dma_handle);
>  #ifdef CONFIG_HAVE_GENERIC_DMA_COHERENT
>  extern int dmam_declare_coherent_memory(struct device *dev,
>  					phys_addr_t phys_addr,
> -- 
> 2.11.0
> 
---end quoted text---
