From: Peter Senna Tschudin <peter.senna-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org>
Subject: Re: [PATCH v3 00/20] Replace PCI pool by DMA pool API
Date: Mon, 27 Feb 2017 12:23:21 +0100
Message-ID: <20170227112321.GL26544@collabora.com>
References: <20170226192425.13098-1-romain.perier@collabora.com>
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
In-Reply-To: <20170226192425.13098-1-romain.perier-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, Feb 26, 2017 at 08:24:05PM +0100, Romain Perier wrote:
> The current PCI pool API are simple macro functions direct expanded to
> the appropriated dma pool functions. The prototypes are almost the same
> and semantically, they are very similar. I propose to use the DMA pool
> API directly and get rid of the old API.
> 
> This set of patches, replaces the old API by the dma pool API, adds
> support to warn about this old API in checkpath.pl and remove the
> defines.
> 
> Changes in v3:
> - Rebased series onto next-20170224
> - Fix checkpath.pl reports for patch 11/20 and patch 12/20
> - Remove prefix RFC
> Changes in v2:
> - Introduced patch 18/20
> - Fixed cosmetic changes: spaces before brace, live over 80 characters
> - Removed some of the check for NULL pointers before calling dma_pool_destroy
> - Improved the regexp in checkpatch for pci_pool, thanks to Joe Perches
> - Added Tested-by and Acked-by tags

Tested the series with checkpatch and compiling with allyesconfig.

> 
> Romain Perier (20):
>   block: DAC960: Replace PCI pool old API
>   dmaengine: pch_dma: Replace PCI pool old API
>   IB/mthca: Replace PCI pool old API
>   net: e100: Replace PCI pool old API
>   mlx4: Replace PCI pool old API
>   mlx5: Replace PCI pool old API
>   wireless: ipw2200: Replace PCI pool old API
>   scsi: be2iscsi: Replace PCI pool old API
>   scsi: csiostor: Replace PCI pool old API
>   scsi: lpfc: Replace PCI pool old API
>   scsi: megaraid: Replace PCI pool old API
>   scsi: mpt3sas: Replace PCI pool old API
>   scsi: mvsas: Replace PCI pool old API
>   scsi: pmcraid: Replace PCI pool old API
>   usb: gadget: amd5536udc: Replace PCI pool old API
>   usb: gadget: net2280: Replace PCI pool old API
>   usb: gadget: pch_udc: Replace PCI pool old API
>   usb: host: Remove remaining pci_pool in comments
>   PCI: Remove PCI pool macro functions
>   checkpatch: warn for use of old PCI pool API
> 
>  drivers/block/DAC960.c                        |  36 ++++-----
>  drivers/block/DAC960.h                        |   4 +-
>  drivers/dma/pch_dma.c                         |  12 +--
>  drivers/infiniband/hw/mthca/mthca_av.c        |  10 +--
>  drivers/infiniband/hw/mthca/mthca_cmd.c       |   8 +-
>  drivers/infiniband/hw/mthca/mthca_dev.h       |   4 +-
>  drivers/net/ethernet/intel/e100.c             |  12 +--
>  drivers/net/ethernet/mellanox/mlx4/cmd.c      |  10 +--
>  drivers/net/ethernet/mellanox/mlx4/mlx4.h     |   2 +-
>  drivers/net/ethernet/mellanox/mlx5/core/cmd.c |  11 +--
>  drivers/net/wireless/intel/ipw2x00/ipw2200.c  |  13 ++--
>  drivers/scsi/be2iscsi/be_iscsi.c              |   6 +-
>  drivers/scsi/be2iscsi/be_main.c               |   6 +-
>  drivers/scsi/be2iscsi/be_main.h               |   2 +-
>  drivers/scsi/csiostor/csio_hw.h               |   2 +-
>  drivers/scsi/csiostor/csio_init.c             |  11 +--
>  drivers/scsi/csiostor/csio_scsi.c             |   6 +-
>  drivers/scsi/lpfc/lpfc.h                      |  12 +--
>  drivers/scsi/lpfc/lpfc_init.c                 |  16 ++--
>  drivers/scsi/lpfc/lpfc_mem.c                  | 105 +++++++++++++-------------
>  drivers/scsi/lpfc/lpfc_nvme.c                 |   6 +-
>  drivers/scsi/lpfc/lpfc_nvmet.c                |   4 +-
>  drivers/scsi/lpfc/lpfc_scsi.c                 |  12 +--
>  drivers/scsi/megaraid/megaraid_mbox.c         |  33 ++++----
>  drivers/scsi/megaraid/megaraid_mm.c           |  32 ++++----
>  drivers/scsi/megaraid/megaraid_sas_base.c     |  29 +++----
>  drivers/scsi/megaraid/megaraid_sas_fusion.c   |  66 ++++++++--------
>  drivers/scsi/mpt3sas/mpt3sas_base.c           |  73 +++++++++---------
>  drivers/scsi/mvsas/mv_init.c                  |   6 +-
>  drivers/scsi/mvsas/mv_sas.c                   |   6 +-
>  drivers/scsi/pmcraid.c                        |  10 +--
>  drivers/scsi/pmcraid.h                        |   2 +-
>  drivers/usb/gadget/udc/amd5536udc.c           |   8 +-
>  drivers/usb/gadget/udc/amd5536udc.h           |   4 +-
>  drivers/usb/gadget/udc/net2280.c              |  12 +--
>  drivers/usb/gadget/udc/net2280.h              |   2 +-
>  drivers/usb/gadget/udc/pch_udc.c              |  31 ++++----
>  drivers/usb/host/ehci-hcd.c                   |   2 +-
>  drivers/usb/host/fotg210-hcd.c                |   2 +-
>  drivers/usb/host/oxu210hp-hcd.c               |   2 +-
>  include/linux/mlx5/driver.h                   |   2 +-
>  include/linux/pci.h                           |   9 ---
>  scripts/checkpatch.pl                         |   9 ++-
>  43 files changed, 318 insertions(+), 332 deletions(-)
> 
> -- 
> 2.9.3
> 
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
