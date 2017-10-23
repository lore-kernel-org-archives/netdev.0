From: Romain Perier <romain.perier@gmail.com>
Subject: [PATCH v14 0/5] Replace PCI pool by DMA pool API
Date: Mon, 23 Oct 2017 19:59:53 +0200
Message-ID: <20171023175958.8327-1-romain.perier@gmail.com>
Cc: dmaengine@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Romain Perier <romain.perier@gmail.com>
To: Jens Axboe <axboe@kernel.dk>,
        Andrew Morton <akpm@linux-foundation.org>,
        Dan Williams <dan.j.williams@intel.com>,
        Vinod Koul <vinod.koul@intel.com>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        Aviad Krawczyk <aviad.krawczyk@huawei.com>,
        Bjorn Helgaas <bhelgaas@google.com>, linux-pci@vger.kernel.org
Return-path: <linux-pci-owner@vger.kernel.org>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The current PCI pool API are simple macro functions direct expanded to
the appropriate dma pool functions. The prototypes are almost the same
and semantically, they are very similar. I propose to use the DMA pool
API directly and get rid of the old API.

This set of patches, replaces the old API by the dma pool API
and remove the defines.

Changes in v14:
- Rebased series onto next-20171018
- Rebased patch 03/05 on latest driver

Changes in v13:
- Rebased series onto next-20170906
- Added a new commit for the hinic ethernet driver
- Remove previously merged patches

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

Romain Perier (5):
  block: DAC960: Replace PCI pool old API
  dmaengine: pch_dma: Replace PCI pool old API
  net: e100: Replace PCI pool old API
  hinic: Replace PCI pool old API
  PCI: Remove PCI pool macro functions

 drivers/block/DAC960.c                            | 38 +++++++++++------------
 drivers/block/DAC960.h                            |  4 +--
 drivers/dma/pch_dma.c                             | 12 +++----
 drivers/net/ethernet/huawei/hinic/hinic_hw_cmdq.c | 10 +++---
 drivers/net/ethernet/huawei/hinic/hinic_hw_cmdq.h |  2 +-
 drivers/net/ethernet/intel/e100.c                 | 12 +++----
 include/linux/pci.h                               |  9 ------
 7 files changed, 38 insertions(+), 49 deletions(-)

-- 
2.14.1
