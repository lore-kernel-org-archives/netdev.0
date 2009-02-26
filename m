From: Maciej Sosnowski <maciej.sosnowski@intel.com>
Subject: [PATCH 2/7] I/OAT: do not set DCACTRL_CMPL_WRITE_ENABLE for I/OAT
	ver.3
Date: Thu, 26 Feb 2009 11:04:38 +0100
Message-ID: <20090226100431.3615.8093.stgit@linux.site>
References: <20090226100327.3615.21419.stgit@linux.site>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: snakebyte@gmx.de, shannon.nelson@intel.com,
	jeffrey.t.krisher@intel.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: dan.j.williams@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:37880 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755869AbZBZKNV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Feb 2009 05:13:21 -0500
In-Reply-To: <20090226100327.3615.21419.stgit@linux.site>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Flag DCACTRL_CMPL_WRITE_ENABLE is valid only for I/OAT ver.2
so it should not be set for I/OAT ver.3.

Signed-off-by: Maciej Sosnowski <maciej.sosnowski@intel.com>
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Acked-by: Jeff Kirsher <jeffrey.t.krisher@intel.com>
---

 drivers/dma/ioat_dma.c |   12 +++++++-----
 1 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/drivers/dma/ioat_dma.c b/drivers/dma/ioat_dma.c
index b3759c4..879f4a0 100644
--- a/drivers/dma/ioat_dma.c
+++ b/drivers/dma/ioat_dma.c
@@ -189,11 +189,13 @@ #endif
 		ioat_chan->xfercap = xfercap;
 		ioat_chan->desccount = 0;
 		INIT_DELAYED_WORK(&ioat_chan->work, ioat_dma_chan_reset_part2);
-		if (ioat_chan->device->version != IOAT_VER_1_2) {
-			writel(IOAT_DCACTRL_CMPL_WRITE_ENABLE
-					| IOAT_DMA_DCA_ANY_CPU,
-				ioat_chan->reg_base + IOAT_DCACTRL_OFFSET);
-		}
+		if (ioat_chan->device->version == IOAT_VER_2_0)
+			writel(IOAT_DCACTRL_CMPL_WRITE_ENABLE |
+			       IOAT_DMA_DCA_ANY_CPU,
+			       ioat_chan->reg_base + IOAT_DCACTRL_OFFSET);
+		else if (ioat_chan->device->version == IOAT_VER_3_0)
+			writel(IOAT_DMA_DCA_ANY_CPU,
+			       ioat_chan->reg_base + IOAT_DCACTRL_OFFSET);
 		spin_lock_init(&ioat_chan->cleanup_lock);
 		spin_lock_init(&ioat_chan->desc_lock);
 		INIT_LIST_HEAD(&ioat_chan->free_desc);

