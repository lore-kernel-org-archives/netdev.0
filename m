From: Dave Jiang <dave.jiang@intel.com>
Subject: [PATCH 1/3] ioat: ring size variables need to be 32bit to avoid
 overflow
Date: Wed, 04 Apr 2012 16:10:35 -0700
Message-ID: <20120404231035.20605.53015.stgit@djiang5-linux.ch.intel.com>
References: <20120404230749.20605.7000.stgit@djiang5-linux.ch.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Dave Jiang <dave.jiang@intel.com>
To: dan.j.williams@intel.com, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:22702 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757211Ab2DDXJi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Apr 2012 19:09:38 -0400
In-Reply-To: <20120404230749.20605.7000.stgit@djiang5-linux.ch.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The alloc order can be up to 16 and 1 << 16 will over flow the 16bit
integer. Change the appropriate variables to 16bit to avoid overflow.

Reported-by: Jim Harris <james.r.harris@intel.com>
Signed-off-by: Dave Jiang <dave.jiang@intel.com>
---

 drivers/dma/ioat/dma_v2.c |    4 ++--
 drivers/dma/ioat/dma_v2.h |    4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/dma/ioat/dma_v2.c b/drivers/dma/ioat/dma_v2.c
index cb8864d..143cb1b 100644
--- a/drivers/dma/ioat/dma_v2.c
+++ b/drivers/dma/ioat/dma_v2.c
@@ -575,9 +575,9 @@ bool reshape_ring(struct ioat2_dma_chan *ioat, int order)
 	 */
 	struct ioat_chan_common *chan = &ioat->base;
 	struct dma_chan *c = &chan->common;
-	const u16 curr_size = ioat2_ring_size(ioat);
+	const u32 curr_size = ioat2_ring_size(ioat);
 	const u16 active = ioat2_ring_active(ioat);
-	const u16 new_size = 1 << order;
+	const u32 new_size = 1 << order;
 	struct ioat_ring_ent **ring;
 	u16 i;
 
diff --git a/drivers/dma/ioat/dma_v2.h b/drivers/dma/ioat/dma_v2.h
index a2c413b..be2a55b 100644
--- a/drivers/dma/ioat/dma_v2.h
+++ b/drivers/dma/ioat/dma_v2.h
@@ -74,7 +74,7 @@ static inline struct ioat2_dma_chan *to_ioat2_chan(struct dma_chan *c)
 	return container_of(chan, struct ioat2_dma_chan, base);
 }
 
-static inline u16 ioat2_ring_size(struct ioat2_dma_chan *ioat)
+static inline u32 ioat2_ring_size(struct ioat2_dma_chan *ioat)
 {
 	return 1 << ioat->alloc_order;
 }
@@ -91,7 +91,7 @@ static inline u16 ioat2_ring_pending(struct ioat2_dma_chan *ioat)
 	return CIRC_CNT(ioat->head, ioat->issued, ioat2_ring_size(ioat));
 }
 
-static inline u16 ioat2_ring_space(struct ioat2_dma_chan *ioat)
+static inline u32 ioat2_ring_space(struct ioat2_dma_chan *ioat)
 {
 	return ioat2_ring_size(ioat) - ioat2_ring_active(ioat);
 }
