From: Romain Perier <romain.perier-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org>
Subject: [PATCH v12 0/8] Replace PCI pool by DMA pool API
Date: Tue, 22 Aug 2017 13:46:53 +0200
Message-ID: <20170822114701.14907-1-romain.perier@collabora.com>
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
        Romain Perier <romain.perier-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org>
To: Dan Williams <dan.j.williams-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Hal Rosenstock <hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, stas.yakovlev-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The current PCI pool API are simple macro functions direct expanded to
the appropriate dma pool functions. The prototypes are almost the same
and semantically, they are very similar. I propose to use the DMA pool
API directly and get rid of the old API.

This set of patches, replaces the old API by the dma pool API
and remove the defines.

Changes in v12:
- Rebased series onto next-20170822

Changes in v11:
- Rebased series onto next-20170809
- Removed patches 08-14, these have been merged.

Changes in v10:
- Rebased series onto next-20170706
- I have fixed and improved patch "scsi: megaraid: Replace PCI pool old API"

Changes in v9:
- Rebased series onto next-20170522
- I have fixed and improved the patch for lpfc driver

Changes in v8:
- Rebased series onto next-20170428

Changes in v7:
- Rebased series onto next-20170416
- Added Acked-by, Tested-by and Reviwed-by tags

Changes in v6:
- Fixed an issue reported by kbuild test robot about changes in DAC960
- Removed patches 15/19,16/19,17/19,18/19. They have been merged by Greg
- Added Acked-by Tags

Changes in v5:
- Re-worded the cover letter (remove sentence about checkpatch.pl)
- Rebased series onto next-20170308
- Fix typos in commit message
- Added Acked-by Tags

Changes in v4:
- Rebased series onto next-20170301
- Removed patch 20/20: checks done by checkpath.pl, no longer required.
  Thanks to Peter and Joe for their feedbacks.
- Added Reviewed-by tags

Changes in v3:
- Rebased series onto next-20170224
- Fix checkpath.pl reports for patch 11/20 and patch 12/20
- Remove prefix RFC
Changes in v2:
- Introduced patch 18/20
- Fixed cosmetic changes: spaces before brace, live over 80 characters
- Removed some of the check for NULL pointers before calling dma_pool_destroy
- Improved the regexp in checkpatch for pci_pool, thanks to Joe Perches
- Added Tested-by and Acked-by tags



Romain Perier (8):
  block: DAC960: Replace PCI pool old API
  dmaengine: pch_dma: Replace PCI pool old API
  IB/mthca: Replace PCI pool old API
  net: e100: Replace PCI pool old API
  mlx4: Replace PCI pool old API
  mlx5: Replace PCI pool old API
  wireless: ipw2200: Replace PCI pool old API
  PCI: Remove PCI pool macro functions

 drivers/block/DAC960.c                        | 38 +++++++++++++--------------
 drivers/block/DAC960.h                        |  4 +--
 drivers/dma/pch_dma.c                         | 12 ++++-----
 drivers/infiniband/hw/mthca/mthca_av.c        | 10 +++----
 drivers/infiniband/hw/mthca/mthca_cmd.c       |  8 +++---
 drivers/infiniband/hw/mthca/mthca_dev.h       |  4 +--
 drivers/net/ethernet/intel/e100.c             | 12 ++++-----
 drivers/net/ethernet/mellanox/mlx4/cmd.c      | 10 +++----
 drivers/net/ethernet/mellanox/mlx4/mlx4.h     |  2 +-
 drivers/net/ethernet/mellanox/mlx5/core/cmd.c | 11 ++++----
 drivers/net/wireless/intel/ipw2x00/ipw2200.c  | 13 ++++-----
 include/linux/mlx5/driver.h                   |  2 +-
 include/linux/pci.h                           |  9 -------
 13 files changed, 63 insertions(+), 72 deletions(-)

-- 
2.11.0

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
