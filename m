From: Chris Leech <christopher.leech@intel.com>
Subject: [PATCH 5/7] [I/OAT] Remove the use of writeq from the ioatdma driver
Date: Tue, 15 Aug 2006 17:53:46 -0700
Message-ID: <20060816005345.8634.53777.stgit@gitlost.site>
References: <20060816005337.8634.70033.stgit@gitlost.site>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:34569 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S1750758AbWHPAp7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2006 20:45:59 -0400
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
In-Reply-To: <20060816005337.8634.70033.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There's only one now anyway, and it's not in a performance path,
so make it behave the same on 32-bit and 64-bit CPUs.

Signed-off-by: Chris Leech <christopher.leech@intel.com>
---

 drivers/dma/ioatdma.c |   10 ++++------
 1 files changed, 4 insertions(+), 6 deletions(-)

diff --git a/drivers/dma/ioatdma.c b/drivers/dma/ioatdma.c
index 0be426f..d6d817c 100644
--- a/drivers/dma/ioatdma.c
+++ b/drivers/dma/ioatdma.c
@@ -608,13 +608,11 @@ static void ioat_start_null_desc(struct 
 	list_add_tail(&desc->node, &ioat_chan->used_desc);
 	spin_unlock_bh(&ioat_chan->desc_lock);
 
-#if (BITS_PER_LONG == 64)
-	writeq(desc->phys, ioat_chan->reg_base + IOAT_CHAINADDR_OFFSET);
-#else
-	writel((u32) desc->phys,
+	writel(((u64) desc->phys) & 0x00000000FFFFFFFF,
 	       ioat_chan->reg_base + IOAT_CHAINADDR_OFFSET_LOW);
-	writel(0, ioat_chan->reg_base + IOAT_CHAINADDR_OFFSET_HIGH);
-#endif
+	writel(((u64) desc->phys) >> 32,
+	       ioat_chan->reg_base + IOAT_CHAINADDR_OFFSET_HIGH);
+
 	writeb(IOAT_CHANCMD_START, ioat_chan->reg_base + IOAT_CHANCMD_OFFSET);
 }
 

