From: Dmitry Baryshkov <dbaryshkov@gmail.com>
Subject: [PATCH] SMC911x: unbreak PXA builds
Date: Tue, 21 Oct 2008 04:36:29 +0400
Message-ID: <1224549389-13840-1-git-send-email-dbaryshkov@gmail.com>
Cc: jgarzik@pobox.com, Eric Miao <eric.miao@marvell.com>,
	Dmitry Baryshkov <dbaryshkov@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.24]:45960 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753309AbYJUAhE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Oct 2008 20:37:04 -0400
Received: by ey-out-2122.google.com with SMTP id 6so683739eyi.37
        for <netdev@vger.kernel.org>; Mon, 20 Oct 2008 17:37:02 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently SMC911x driver is broken on ARM/PXA builds.
Unbreak such configurations.

Signed-off-by: Dmitry Baryshkov <dbaryshkov@gmail.com>
---
 drivers/net/smc911x.c |    2 +-
 drivers/net/smc911x.h |    6 ++++--
 2 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/smc911x.c b/drivers/net/smc911x.c
index ddcefde..402fd06 100644
--- a/drivers/net/smc911x.c
+++ b/drivers/net/smc911x.c
@@ -1241,7 +1241,7 @@ smc911x_rx_dma_irq(int dma, void *data)
 	netif_rx(skb);
 
 	spin_lock_irqsave(&lp->lock, flags);
-	pkts = (SMC_GET_RX_FIFO_INF() & RX_FIFO_INF_RXSUSED_) >> 16;
+	pkts = (SMC_GET_RX_FIFO_INF(lp) & RX_FIFO_INF_RXSUSED_) >> 16;
 	if (pkts != 0) {
 		smc911x_rcv(dev);
 	}else {
diff --git a/drivers/net/smc911x.h b/drivers/net/smc911x.h
index bf6240f..cc7d85b 100644
--- a/drivers/net/smc911x.h
+++ b/drivers/net/smc911x.h
@@ -50,6 +50,10 @@
 #define SMC_DYNAMIC_BUS_CONFIG
 #endif
 
+#ifdef SMC_USE_PXA_DMA
+#define SMC_USE_DMA
+#endif
+
 /* store this information for the driver.. */
 struct smc911x_local {
 	/*
@@ -196,8 +200,6 @@ static inline void SMC_outsl(struct smc911x_local *lp, int reg,
 
 
 #ifdef SMC_USE_PXA_DMA
-#define SMC_USE_DMA
-
 /*
  * Define the request and free functions
  * These are unfortunately architecture specific as no generic allocation
-- 
1.5.6.5

