From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: [PATCH] net/macb: GEM DMA configuration register update
Date: Fri, 23 Nov 2012 14:49:01 +0100
Message-ID: <1353678541-26839-1-git-send-email-nicolas.ferre@atmel.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-arm-kernel@lists.infradead.org>,
	<linux-kernel@vger.kernel.org>,
	Joachim Eastwood <manabian@gmail.com>,
	Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>,
	Nicolas Ferre <nicolas.ferre@atmel.com>
To: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add information to the DMA Configuration Register to
maximize system performance:
- rx/tx packet buffer full memory size
- allow possibility to use INCR16 if supported

Signed-off-by: Nicolas Ferre <nicolas.ferre@atmel.com>
---
 drivers/net/ethernet/cadence/macb.c | 10 ++++++++--
 drivers/net/ethernet/cadence/macb.h | 11 +++++++++++
 2 files changed, 19 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index cc6e593..6a59bce 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -1033,8 +1033,12 @@ static u32 macb_dbw(struct macb *bp)
 }
 
 /*
- * Configure the receive DMA engine to use the correct receive buffer size.
- * This is a configurable parameter for GEM.
+ * Configure the receive DMA engine
+ * - use the correct receive buffer size
+ * - set the possibility to use INCR16 bursts
+ *   (if not supported by FIFO, it will fallback to default)
+ * - set both rx/tx packet buffers to full memory size
+ * These are configurable parameters for GEM.
  */
 static void macb_configure_dma(struct macb *bp)
 {
@@ -1043,6 +1047,8 @@ static void macb_configure_dma(struct macb *bp)
 	if (macb_is_gem(bp)) {
 		dmacfg = gem_readl(bp, DMACFG) & ~GEM_BF(RXBS, -1L);
 		dmacfg |= GEM_BF(RXBS, RX_BUFFER_SIZE / 64);
+		dmacfg |= GEM_BF(FBLDO, 16);
+		dmacfg |= GEM_BIT(TXPBMS) | GEM_BF(RXBMS, -1L);
 		gem_writel(bp, DMACFG, dmacfg);
 	}
 }
diff --git a/drivers/net/ethernet/cadence/macb.h b/drivers/net/ethernet/cadence/macb.h
index 4414421..570908b 100644
--- a/drivers/net/ethernet/cadence/macb.h
+++ b/drivers/net/ethernet/cadence/macb.h
@@ -171,8 +171,19 @@
 #define GEM_DBW128				2
 
 /* Bitfields in DMACFG. */
+#define GEM_FBLDO_OFFSET			0
+#define GEM_FBLDO_SIZE				5
+#define GEM_RXBMS_OFFSET			8
+#define GEM_RXBMS_SIZE				2
+#define GEM_TXPBMS_OFFSET			10
+#define GEM_TXPBMS_SIZE				1
+#define GEM_TXCOEN_OFFSET			11
+#define GEM_TXCOEN_SIZE				1
 #define GEM_RXBS_OFFSET				16
 #define GEM_RXBS_SIZE				8
+#define GEM_DDRP_OFFSET				24
+#define GEM_DDRP_SIZE				1
+
 
 /* Bitfields in NSR */
 #define MACB_NSR_LINK_OFFSET			0
-- 
1.8.0
