From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH 1/1 net-next] net: rds: use for_each_sg() for scatterlist parsing
Date: Mon, 15 Jun 2015 19:13:05 +0200
Message-ID: <1434388385-29246-1-git-send-email-fabf@skynet.be>
Cc: Fabian Frederick <fabf@skynet.be>,
	Chien Yen <chien.yen@oracle.com>,
	"David S. Miller" <davem@davemloft.net>, rds-devel@oss.oracle.com,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch also renames sg to sglist and aligns function parameters.
See Documentation/DMA-API.txt - Part Id for scatterlist details

Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
This is untested.

 net/rds/ib.h | 22 ++++++++++++++--------
 1 file changed, 14 insertions(+), 8 deletions(-)

diff --git a/net/rds/ib.h b/net/rds/ib.h
index c36d713..01d8072 100644
--- a/net/rds/ib.h
+++ b/net/rds/ib.h
@@ -235,28 +235,34 @@ extern struct workqueue_struct *rds_ib_wq;
  * doesn't define it.
  */
 static inline void rds_ib_dma_sync_sg_for_cpu(struct ib_device *dev,
-		struct scatterlist *sg, unsigned int sg_dma_len, int direction)
+					      struct scatterlist *sglist,
+					      unsigned int sg_dma_len,
+					      int direction)
 {
 	unsigned int i;
+	struct scatterlist *sg;
 
-	for (i = 0; i < sg_dma_len; ++i) {
+	for_each_sg(sglist, sg, sg_dma_len, i) {
 		ib_dma_sync_single_for_cpu(dev,
-				ib_sg_dma_address(dev, &sg[i]),
-				ib_sg_dma_len(dev, &sg[i]),
+				ib_sg_dma_address(dev, sg),
+				ib_sg_dma_len(dev, sg),
 				direction);
 	}
 }
 #define ib_dma_sync_sg_for_cpu	rds_ib_dma_sync_sg_for_cpu
 
 static inline void rds_ib_dma_sync_sg_for_device(struct ib_device *dev,
-		struct scatterlist *sg, unsigned int sg_dma_len, int direction)
+						 struct scatterlist *sglist,
+						 unsigned int sg_dma_len,
+						 int direction)
 {
 	unsigned int i;
+	struct scatterlist *sg;
 
-	for (i = 0; i < sg_dma_len; ++i) {
+	for_each_sg(sglist, sg, sg_dma_len, i) {
 		ib_dma_sync_single_for_device(dev,
-				ib_sg_dma_address(dev, &sg[i]),
-				ib_sg_dma_len(dev, &sg[i]),
+				ib_sg_dma_address(dev, sg),
+				ib_sg_dma_len(dev, sg),
 				direction);
 	}
 }
-- 
2.4.2
