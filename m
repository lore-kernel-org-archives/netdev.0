From: Eric Miao <eric.y.miao@gmail.com>
Subject: [PATCH 3/8] smc91x: favor the use of SMC91X_USE_* instead of SMC_CAN_USE_*
Date: Thu, 19 Jun 2008 19:05:42 +0800
Message-ID: <485A3D86.60905@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Nicolas Pitre <nico@cam.org>, Magnus Damm <magnus.damm@gmail.com>
To: linux-netdev <netdev@vger.kernel.org>,
	linux-arm-kernel <linux-arm-kernel@lists.arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ti-out-0910.google.com ([209.85.142.191]:53943 "EHLO
	ti-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756389AbYFSLFs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jun 2008 07:05:48 -0400
Received: by ti-out-0910.google.com with SMTP id b6so319577tic.23
        for <netdev@vger.kernel.org>; Thu, 19 Jun 2008 04:05:46 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Let's simplify the logic and avoid confusion, the use of SMC91X_USE_*
is favored than SMC_CAN_USE_*, if platform data isn't given, convert
the hardcoded SMC_CAN_USE_* to SMC91X_USE_*.

Signed-off-by: Eric Miao <eric.miao@marvell.com>
---
 drivers/net/smc91x.c |   12 +++---------
 drivers/net/smc91x.h |   13 +++----------
 2 files changed, 6 insertions(+), 19 deletions(-)

diff --git a/drivers/net/smc91x.c b/drivers/net/smc91x.c
index 70a19ad..b57ee44 100644
--- a/drivers/net/smc91x.c
+++ b/drivers/net/smc91x.c
@@ -2136,20 +2136,14 @@ static int smc_drv_probe(struct platform_device *pdev)
 
 	lp = netdev_priv(ndev);
 
-#ifdef SMC_DYNAMIC_BUS_CONFIG
 	if (pd)
 		memcpy(&lp->cfg, pd, sizeof(lp->cfg));
 	else {
-		lp->cfg.flags = SMC91X_USE_8BIT;
-		lp->cfg.flags |= SMC91X_USE_16BIT;
-		lp->cfg.flags |= SMC91X_USE_32BIT;
+		lp->cfg.flags |= (SMC_CAN_USE_8BIT)  ? SMC91X_USE_8BIT  : 0;
+		lp->cfg.flags |= (SMC_CAN_USE_16BIT) ? SMC91X_USE_16BIT : 0;
+		lp->cfg.flags |= (SMC_CAN_USE_32BIT) ? SMC91X_USE_32BIT : 0;
 	}
 
-	lp->cfg.flags &= ~(SMC_CAN_USE_8BIT ? 0 : SMC91X_USE_8BIT);
-	lp->cfg.flags &= ~(SMC_CAN_USE_16BIT ? 0 : SMC91X_USE_16BIT);
-	lp->cfg.flags &= ~(SMC_CAN_USE_32BIT ? 0 : SMC91X_USE_32BIT);
-#endif
-
 	ndev->dma = (unsigned char)-1;
 
 	ires = platform_get_resource(pdev, IORESOURCE_IRQ, 0);
diff --git a/drivers/net/smc91x.h b/drivers/net/smc91x.h
index 97a3c52..6a90400 100644
--- a/drivers/net/smc91x.h
+++ b/drivers/net/smc91x.h
@@ -441,7 +441,6 @@ static inline void LPD7_SMC_outsw (unsigned char* a, int r,
 #define RPC_LSA_DEFAULT		RPC_LED_100_10
 #define RPC_LSB_DEFAULT		RPC_LED_TX_RX
 
-#define SMC_DYNAMIC_BUS_CONFIG
 #endif
 
 
@@ -491,15 +490,9 @@ struct smc_local {
 	struct smc91x_platdata cfg;
 };
 
-#ifdef SMC_DYNAMIC_BUS_CONFIG
-#define SMC_8BIT(p) (((p)->cfg.flags & SMC91X_USE_8BIT) && SMC_CAN_USE_8BIT)
-#define SMC_16BIT(p) (((p)->cfg.flags & SMC91X_USE_16BIT) && SMC_CAN_USE_16BIT)
-#define SMC_32BIT(p) (((p)->cfg.flags & SMC91X_USE_32BIT) && SMC_CAN_USE_32BIT)
-#else
-#define SMC_8BIT(p) SMC_CAN_USE_8BIT
-#define SMC_16BIT(p) SMC_CAN_USE_16BIT
-#define SMC_32BIT(p) SMC_CAN_USE_32BIT
-#endif
+#define SMC_8BIT(p)	((p)->cfg.flags & SMC91X_USE_8BIT)
+#define SMC_16BIT(p)	((p)->cfg.flags & SMC91X_USE_16BIT)
+#define SMC_32BIT(p)	((p)->cfg.flags & SMC91X_USE_32BIT)
 
 #ifdef SMC_USE_PXA_DMA
 /*
-- 
1.5.4.3

