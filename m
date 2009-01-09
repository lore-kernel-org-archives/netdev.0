From: Joerg Roedel <joerg.roedel@amd.com>
Subject: [PATCH 14/16] dma-debug: add checks for sync_single_sg_*
Date: Fri, 9 Jan 2009 17:19:28 +0100
Message-ID: <1231517970-20288-15-git-send-email-joerg.roedel@amd.com>
References: <1231517970-20288-1-git-send-email-joerg.roedel@amd.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: mingo@redhat.com, dwmw2@infradead.org,
	fujita.tomonori@lab.ntt.co.jp, netdev@vger.kernel.org,
	iommu@lists.linux-foundation.org,
	Joerg Roedel <joerg.roedel@amd.com>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from tx2ehsobe004.messaging.microsoft.com ([65.55.88.14]:33624 "EHLO
	TX2EHSOBE008.bigfish.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753358AbZAIQe7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2009 11:34:59 -0500
In-Reply-To: <1231517970-20288-1-git-send-email-joerg.roedel@amd.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Impact: add debug callbacks for dma_sync_sg_* functions

Signed-off-by: Joerg Roedel <joerg.roedel@amd.com>
---
 include/linux/dma-debug.h |   19 +++++++++++++++++++
 lib/dma-debug.c           |   32 ++++++++++++++++++++++++++++++++
 2 files changed, 51 insertions(+), 0 deletions(-)

diff --git a/include/linux/dma-debug.h b/include/linux/dma-debug.h
index b9c221a..bdba8c8 100644
--- a/include/linux/dma-debug.h
+++ b/include/linux/dma-debug.h
@@ -64,6 +64,13 @@ extern void debug_sync_single_range_for_device(struct device *dev,
 					       unsigned long offset,
 					       size_t size, int direction);
 
+extern void debug_sync_sg_for_cpu(struct device *dev, struct scatterlist *sg,
+				  int nelems, int direction);
+
+extern void debug_sync_sg_for_device(struct device *dev,
+				     struct scatterlist *sg,
+				     int nelems, int direction);
+
 #else /* CONFIG_DMA_API_DEBUG */
 
 static inline void dma_debug_init(u32 num_entries)
@@ -130,6 +137,18 @@ static inline void debug_sync_single_range_for_device(struct device *dev,
 {
 }
 
+static inline void debug_sync_sg_for_cpu(struct device *dev,
+					 struct scatterlist *sg,
+					 int nelems, int direction)
+{
+}
+
+static inline void debug_sync_sg_for_device(struct device *dev,
+					    struct scatterlist *sg,
+					    int nelems, int direction)
+{
+}
+
 #endif /* CONFIG_DMA_API_DEBUG */
 
 #endif /* __DMA_DEBUG_H */
diff --git a/lib/dma-debug.c b/lib/dma-debug.c
index 6f73bed..e40c88c 100644
--- a/lib/dma-debug.c
+++ b/lib/dma-debug.c
@@ -692,3 +692,35 @@ void debug_sync_single_range_for_device(struct device *dev,
 }
 EXPORT_SYMBOL(debug_sync_single_range_for_device);
 
+void debug_sync_sg_for_cpu(struct device *dev, struct scatterlist *sg,
+			   int nelems, int direction)
+{
+	struct scatterlist *s;
+	int i;
+
+	if (global_disable)
+		return;
+
+	for_each_sg(sg, s, nelems, i) {
+		check_sync(dev, s->dma_address, s->dma_length, 0,
+				direction, true);
+	}
+}
+EXPORT_SYMBOL(debug_sync_sg_for_cpu);
+
+void debug_sync_sg_for_device(struct device *dev, struct scatterlist *sg,
+			      int nelems, int direction)
+{
+	struct scatterlist *s;
+	int i;
+
+	if (global_disable)
+		return;
+
+	for_each_sg(sg, s, nelems, i) {
+		check_sync(dev, s->dma_address, s->dma_length, 0,
+				direction, false);
+	}
+}
+EXPORT_SYMBOL(debug_sync_sg_for_device);
+
-- 
1.5.6.4


