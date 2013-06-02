From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net-next 5/5] bnx2x: semi-Semantic changes
Date: Sun, 2 Jun 2013 13:06:21 +0300
Message-ID: <1370167581-31597-6-git-send-email-yuvalmin@broadcom.com>
References: <1370167581-31597-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: ariele@broadcom.com, eilong@broadcom.com,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1551 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753440Ab3FBKGv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 2 Jun 2013 06:06:51 -0400
In-Reply-To: <1370167581-31597-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch includes a few changes that change the driver's flow without truly
changing anything in its functionality - use usleep_range for short sleeps
instead of msleep and initialize Tx consumer during initialization for better
information during errors.

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Ariel Elior <ariele@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c | 14 ++++++++------
 1 file changed, 8 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 60ff1aa..658b9fd 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -1954,7 +1954,7 @@ int bnx2x_acquire_hw_lock(struct bnx2x *bp, u32 resource)
 		if (lock_status & resource_bit)
 			return 0;
 
-		msleep(5);
+		usleep_range(5000, 10000);
 	}
 	BNX2X_ERR("Timeout\n");
 	return -EAGAIN;
@@ -3640,7 +3640,7 @@ static int bnx2x_acquire_alr(struct bnx2x *bp)
 		if (val & MCPR_ACCESS_LOCK_LOCK)
 			break;
 
-		msleep(5);
+		usleep_range(5000, 10000);
 	}
 	if (!(val & MCPR_ACCESS_LOCK_LOCK)) {
 		BNX2X_ERR("Cannot acquire MCP access lock register\n");
@@ -6078,6 +6078,8 @@ static void bnx2x_init_tx_ring_one(struct bnx2x_fp_txdata *txdata)
 				    BCM_PAGE_SIZE*(i % NUM_TX_RINGS)));
 	}
 
+	*txdata->tx_cons_sb = cpu_to_le16(0);
+
 	SET_FLAG(txdata->tx_db.data.header.header, DOORBELL_HDR_DB_TYPE, 1);
 	txdata->tx_db.data.zero_fill1 = 0;
 	txdata->tx_db.data.prod = 0;
@@ -6329,7 +6331,7 @@ static int bnx2x_int_mem_test(struct bnx2x *bp)
 		if (val == 0x10)
 			break;
 
-		msleep(10);
+		usleep_range(10000, 20000);
 		count--;
 	}
 	if (val != 0x10) {
@@ -6344,7 +6346,7 @@ static int bnx2x_int_mem_test(struct bnx2x *bp)
 		if (val == 1)
 			break;
 
-		msleep(10);
+		usleep_range(10000, 20000);
 		count--;
 	}
 	if (val != 0x1) {
@@ -6385,7 +6387,7 @@ static int bnx2x_int_mem_test(struct bnx2x *bp)
 		if (val == 0xb0)
 			break;
 
-		msleep(10);
+		usleep_range(10000, 20000);
 		count--;
 	}
 	if (val != 0xb0) {
@@ -8500,7 +8502,7 @@ static void bnx2x_reset_func(struct bnx2x *bp)
 		 * scan to complete
 		 */
 		for (i = 0; i < 200; i++) {
-			msleep(10);
+			usleep_range(10000, 20000);
 			if (!REG_RD(bp, TM_REG_LIN0_SCAN_ON + port*4))
 				break;
 		}
-- 
1.8.1.227.g44fe835
