From: Nishant Kamat <nskamat@ti.com>
Subject: [PATCH 2/3] NET: SMC911X: Fix timeout handling
Date: Fri,  2 May 2008 07:52:14 -0500
Message-ID: <1209732735-24443-3-git-send-email-nskamat@ti.com>
References: <1209732735-24443-1-git-send-email-nskamat@ti.com>
 <1209732735-24443-2-git-send-email-nskamat@ti.com>
Cc: Nishant Kamat <nskamat@ti.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from calf.ext.ti.com ([198.47.26.144]:33787 "EHLO calf.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754343AbYEBMwW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 May 2008 08:52:22 -0400
Received: from dlep35.itg.ti.com ([157.170.170.118])
	by calf.ext.ti.com (8.13.7/8.13.7) with ESMTP id m42CqHpV019574
	for <netdev@vger.kernel.org>; Fri, 2 May 2008 07:52:22 -0500
In-Reply-To: <1209732735-24443-2-git-send-email-nskamat@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Due to incorrect decrement operation in the loop, the timeout
value would never be zero in case of hardware error. This patch
fixes the decrement operation.

Signed-off-by: Nishant Kamat <nskamat@ti.com>
---
 drivers/net/smc911x.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/smc911x.c b/drivers/net/smc911x.c
index 14a0e3a..e5afcf2 100644
--- a/drivers/net/smc911x.c
+++ b/drivers/net/smc911x.c
@@ -243,7 +243,7 @@ static void smc911x_reset(struct net_device *dev)
 		do {
 			udelay(10);
 			reg = SMC_GET_PMT_CTRL() & PMT_CTRL_READY_;
-		} while ( timeout-- && !reg);
+		} while (--timeout && !reg);
 		if (timeout == 0) {
 			PRINTK("%s: smc911x_reset timeout waiting for PM restore\n", dev->name);
 			return;
@@ -267,7 +267,7 @@ static void smc911x_reset(struct net_device *dev)
 				resets++;
 				break;
 			}
-		} while ( timeout-- && (reg & HW_CFG_SRST_));
+		} while (--timeout && (reg & HW_CFG_SRST_));
 	}
 	if (timeout == 0) {
 		PRINTK("%s: smc911x_reset timeout waiting for reset\n", dev->name);
@@ -276,7 +276,7 @@ static void smc911x_reset(struct net_device *dev)
 
 	/* make sure EEPROM has finished loading before setting GPIO_CFG */
 	timeout=1000;
-	while ( timeout-- && (SMC_GET_E2P_CMD() & E2P_CMD_EPC_BUSY_)) {
+	while (--timeout && (SMC_GET_E2P_CMD() & E2P_CMD_EPC_BUSY_)) {
 		udelay(10);
 	}
 	if (timeout == 0){
@@ -413,7 +413,7 @@ static inline void smc911x_drop_pkt(struct net_device *dev)
 		do {
 			udelay(10);
 			reg = SMC_GET_RX_DP_CTRL() & RX_DP_CTRL_FFWD_BUSY_;
-		} while ( timeout-- && reg);
+		} while (--timeout && reg);
 		if (timeout == 0) {
 			PRINTK("%s: timeout waiting for RX fast forward\n", dev->name);
 		}
-- 
1.5.3.2

