From: Romain Perier <romain.perier@collabora.com>
Subject: [PATCH v7 00/15] Replace PCI pool by DMA pool API
Date: Fri,  7 Apr 2017 09:25:28 +0200
Message-ID: <20170407072543.6936-1-romain.perier@collabora.com>
Cc: linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
        linux-usb@vger.kernel.org, linux-scsi@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Romain Perier <romain.perier@collabora.com>,
        Peter Senna Tschudin <peter.senna@collabora.co.uk>
To: Dan Williams <dan.j.williams@intel.com>,
        Doug Ledford <dledford@redhat.com>,
        Sean Hefty <sean.hefty@intel.com>,
        Hal Rosenstock <hal.rosenstock@gmail.com>,
        jeffrey.t.kirsher@intel.com,
        "David S. Miller" <davem@davemloft.net>, stas.yakovlev@gmail.com,
        "James E.J. Bottomley" <jejb@linux.vnet.ibm.com>,
        "Martin K. Petersen" <martin.petersen@oracle.com>,
        Felipe Balbi <balbi@kernel.org>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <linux-scsi-owner@vger.kernel.org>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The current PCI pool API are simple macro functions direct expanded to
the appropriate dma pool functions. The prototypes are almost the same
and semantically, they are very similar. I propose to use the DMA pool
API directly and get rid of the old API.

This set of patches, replaces the old API by the dma pool API
and remove the defines.

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

Romain Perier (15):
  block: DAC960: Replace PCI pool old API
  dmaengine: pch_dma: Replace PCI pool old API
  IB/mthca: Replace PCI pool old API
  net: e100: Replace PCI pool old API
  mlx4: Replace PCI pool old API
  mlx5: Replace PCI pool old API
  wireless: ipw2200: Replace PCI pool old API
  scsi: be2iscsi: Replace PCI pool old API
  scsi: csiostor: Replace PCI pool old API
  scsi: lpfc: Replace PCI pool old API
  scsi: megaraid: Replace PCI pool old API
  scsi: mpt3sas: Replace PCI pool old API
  scsi: mvsas: Replace PCI pool old API
  scsi: pmcraid: Replace PCI pool old API
  PCI: Remove PCI pool macro functions

 drivers/block/DAC960.c                        |  38 +++++----
 drivers/block/DAC960.h                        |   4 +-
 drivers/dma/pch_dma.c                         |  12 +--
 drivers/infiniband/hw/mthca/mthca_av.c        |  10 +--
 drivers/infiniband/hw/mthca/mthca_cmd.c       |   8 +-
 drivers/infiniband/hw/mthca/mthca_dev.h       |   4 +-
 drivers/net/ethernet/intel/e100.c             |  12 +--
 drivers/net/ethernet/mellanox/mlx4/cmd.c      |  10 +--
 drivers/net/ethernet/mellanox/mlx4/mlx4.h     |   2 +-
 drivers/net/ethernet/mellanox/mlx5/core/cmd.c |  11 +--
 drivers/net/wireless/intel/ipw2x00/ipw2200.c  |  13 ++--
 drivers/scsi/be2iscsi/be_iscsi.c              |   6 +-
 drivers/scsi/be2iscsi/be_main.c               |   6 +-
 drivers/scsi/be2iscsi/be_main.h               |   2 +-
 drivers/scsi/csiostor/csio_hw.h               |   2 +-
 drivers/scsi/csiostor/csio_init.c             |  11 +--
 drivers/scsi/csiostor/csio_scsi.c             |   6 +-
 drivers/scsi/lpfc/lpfc.h                      |  14 ++--
 drivers/scsi/lpfc/lpfc_init.c                 |  16 ++--
 drivers/scsi/lpfc/lpfc_mem.c                  | 106 +++++++++++++-------------
 drivers/scsi/lpfc/lpfc_nvme.c                 |   6 +-
 drivers/scsi/lpfc/lpfc_nvmet.c                |   4 +-
 drivers/scsi/lpfc/lpfc_scsi.c                 |  12 +--
 drivers/scsi/megaraid/megaraid_mbox.c         |  33 ++++----
 drivers/scsi/megaraid/megaraid_mm.c           |  32 ++++----
 drivers/scsi/megaraid/megaraid_sas_base.c     |  29 +++----
 drivers/scsi/megaraid/megaraid_sas_fusion.c   |  66 ++++++++--------
 drivers/scsi/mpt3sas/mpt3sas_base.c           |  73 +++++++++---------
 drivers/scsi/mvsas/mv_init.c                  |   6 +-
 drivers/scsi/mvsas/mv_sas.c                   |   6 +-
 drivers/scsi/pmcraid.c                        |  10 +--
 drivers/scsi/pmcraid.h                        |   2 +-
 include/linux/mlx5/driver.h                   |   2 +-
 include/linux/pci.h                           |   9 ---
 34 files changed, 280 insertions(+), 303 deletions(-)

-- 
2.9.3
