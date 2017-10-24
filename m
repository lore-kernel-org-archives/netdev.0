From: Bjorn Helgaas <helgaas@kernel.org>
Subject: Re: [PATCH v14 5/5] PCI: Remove PCI pool macro functions
Date: Tue, 24 Oct 2017 15:18:13 -0500
Message-ID: <20171024201813.GH21840@bhelgaas-glaptop.roam.corp.google.com>
References: <20171023175958.8327-1-romain.perier@gmail.com>
 <20171023175958.8327-6-romain.perier@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jens Axboe <axboe@kernel.dk>,
        Andrew Morton <akpm@linux-foundation.org>,
        Dan Williams <dan.j.williams@intel.com>,
        Vinod Koul <vinod.koul@intel.com>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        Aviad Krawczyk <aviad.krawczyk@huawei.com>,
        Bjorn Helgaas <bhelgaas@google.com>, linux-pci@vger.kernel.org,
        dmaengine@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Romain Perier <romain.perier@collabora.com>
To: Romain Perier <romain.perier@gmail.com>
Return-path: <linux-pci-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20171023175958.8327-6-romain.perier@gmail.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 23, 2017 at 07:59:58PM +0200, Romain Perier wrote:
> From: Romain Perier <romain.perier@collabora.com>
> 
> Now that all the drivers use dma pool API, we can remove the macro
> functions for PCI pool.
> 
> Signed-off-by: Romain Perier <romain.perier@collabora.com>
> Reviewed-by: Peter Senna Tschudin <peter.senna@collabora.com>

Acked-by: Bjorn Helgaas <bhelgaas@google.com>

Since this barely touches drivers/pci and linux-pci wasn't copied
until v14, I assume you're planning to merge this via some other tree.
Let me know if you need anything else from me.

> ---
>  include/linux/pci.h | 9 ---------
>  1 file changed, 9 deletions(-)
> 
> diff --git a/include/linux/pci.h b/include/linux/pci.h
> index 80eaa2dbe3e9..a827f6eb54db 100644
> --- a/include/linux/pci.h
> +++ b/include/linux/pci.h
> @@ -1325,15 +1325,6 @@ int pci_set_vga_state(struct pci_dev *pdev, bool decode,
>  #include <linux/pci-dma.h>
>  #include <linux/dmapool.h>
>  
> -#define	pci_pool dma_pool
> -#define pci_pool_create(name, pdev, size, align, allocation) \
> -		dma_pool_create(name, &pdev->dev, size, align, allocation)
> -#define	pci_pool_destroy(pool) dma_pool_destroy(pool)
> -#define	pci_pool_alloc(pool, flags, handle) dma_pool_alloc(pool, flags, handle)
> -#define	pci_pool_zalloc(pool, flags, handle) \
> -		dma_pool_zalloc(pool, flags, handle)
> -#define	pci_pool_free(pool, vaddr, addr) dma_pool_free(pool, vaddr, addr)
> -
>  struct msix_entry {
>  	u32	vector;	/* kernel uses to write allocated vector */
>  	u16	entry;	/* driver uses to specify entry, OS writes */
> -- 
> 2.14.1
> 
