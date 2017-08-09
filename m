From: Romain Perier <romain.perier@collabora.com>
Subject: [PATCH v11 0/8] Replace PCI pool by DMA pool API
Date: Wed,  9 Aug 2017 10:28:17 +0200
Message-ID: <20170809082825.9226-1-romain.perier@collabora.com>
Cc: linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Romain Perier <romain.perier@collabora.com>
To: Dan Williams <dan.j.williams@intel.com>,
        Doug Ledford <dledford@redhat.com>,
        Sean Hefty <sean.hefty@intel.com>,
        Hal Rosenstock <hal.rosenstock@gmail.com>,
        jeffrey.t.kirsher@intel.com,
        "David S. Miller" <davem@davemloft.net>, stas.yakovlev@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from bhuna.collabora.co.uk ([46.235.227.227]:42182 "EHLO
        bhuna.collabora.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752436AbdHII2v (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2017 04:28:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The current PCI pool API are simple macro functions direct expanded to
the appropriate dma pool functions. The prototypes are almost the same
and semantically, they are very similar. I propose to use the DMA pool
API directly and get rid of the old API.

This set of patches, replaces the old API by the dma pool API
and remove the defines.

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
