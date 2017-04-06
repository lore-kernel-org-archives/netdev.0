From: Bjorn Helgaas <helgaas@kernel.org>
Subject: Re: [PATCH 4/4] PCI: remove pci_enable_msix
Date: Thu, 6 Apr 2017 16:29:49 -0500
Message-ID: <20170406212949.GA18836@bhelgaas-glaptop.roam.corp.google.com>
References: <20170406122448.31854-1-hch@lst.de>
 <20170406122448.31854-5-hch@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bhelgaas@google.com, davem@davemloft.net,
        netanel@annapurnalabs.com, jcliburn@gmail.com,
        chris.snook@gmail.com, sgoutham@cavium.com, rric@kernel.org,
        netdev@vger.kernel.org, linux-pci@vger.kernel.org
To: Christoph Hellwig <hch@lst.de>
Return-path: <linux-pci-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170406122448.31854-5-hch@lst.de>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 06, 2017 at 02:24:48PM +0200, Christoph Hellwig wrote:
> Unused now that all callers switched to pci_alloc_irq_vectors.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>

I already acked this, but I can do it again :)
(https://lkml.kernel.org/r/20170330230913.GA3912@bhelgaas-glaptop.roam.corp.google.com)

Acked-by: Bjorn Helgaas <bhelgaas@google.com>

> ---
>  drivers/pci/msi.c   | 21 ---------------------
>  include/linux/pci.h |  4 ----
>  2 files changed, 25 deletions(-)
> 
> diff --git a/drivers/pci/msi.c b/drivers/pci/msi.c
> index d571bc330686..0042c365b29b 100644
> --- a/drivers/pci/msi.c
> +++ b/drivers/pci/msi.c
> @@ -973,27 +973,6 @@ static int __pci_enable_msix(struct pci_dev *dev, struct msix_entry *entries,
>  	return msix_capability_init(dev, entries, nvec, affd);
>  }
>  
> -/**
> - * pci_enable_msix - configure device's MSI-X capability structure
> - * @dev: pointer to the pci_dev data structure of MSI-X device function
> - * @entries: pointer to an array of MSI-X entries (optional)
> - * @nvec: number of MSI-X irqs requested for allocation by device driver
> - *
> - * Setup the MSI-X capability structure of device function with the number
> - * of requested irqs upon its software driver call to request for
> - * MSI-X mode enabled on its hardware device function. A return of zero
> - * indicates the successful configuration of MSI-X capability structure
> - * with new allocated MSI-X irqs. A return of < 0 indicates a failure.
> - * Or a return of > 0 indicates that driver request is exceeding the number
> - * of irqs or MSI-X vectors available. Driver should use the returned value to
> - * re-send its request.
> - **/
> -int pci_enable_msix(struct pci_dev *dev, struct msix_entry *entries, int nvec)
> -{
> -	return __pci_enable_msix(dev, entries, nvec, NULL);
> -}
> -EXPORT_SYMBOL(pci_enable_msix);
> -
>  void pci_msix_shutdown(struct pci_dev *dev)
>  {
>  	struct msi_desc *entry;
> diff --git a/include/linux/pci.h b/include/linux/pci.h
> index eb3da1a04e6c..82dec36845e6 100644
> --- a/include/linux/pci.h
> +++ b/include/linux/pci.h
> @@ -1300,7 +1300,6 @@ int pci_msi_vec_count(struct pci_dev *dev);
>  void pci_msi_shutdown(struct pci_dev *dev);
>  void pci_disable_msi(struct pci_dev *dev);
>  int pci_msix_vec_count(struct pci_dev *dev);
> -int pci_enable_msix(struct pci_dev *dev, struct msix_entry *entries, int nvec);
>  void pci_msix_shutdown(struct pci_dev *dev);
>  void pci_disable_msix(struct pci_dev *dev);
>  void pci_restore_msi_state(struct pci_dev *dev);
> @@ -1330,9 +1329,6 @@ static inline int pci_msi_vec_count(struct pci_dev *dev) { return -ENOSYS; }
>  static inline void pci_msi_shutdown(struct pci_dev *dev) { }
>  static inline void pci_disable_msi(struct pci_dev *dev) { }
>  static inline int pci_msix_vec_count(struct pci_dev *dev) { return -ENOSYS; }
> -static inline int pci_enable_msix(struct pci_dev *dev,
> -				  struct msix_entry *entries, int nvec)
> -{ return -ENOSYS; }
>  static inline void pci_msix_shutdown(struct pci_dev *dev) { }
>  static inline void pci_disable_msix(struct pci_dev *dev) { }
>  static inline void pci_restore_msi_state(struct pci_dev *dev) { }
> -- 
> 2.11.0
> 
