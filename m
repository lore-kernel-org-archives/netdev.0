From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [net-next PATCH 4/5] bnx2x: correct & clean 10G EEE
 requirements
Date: Mon, 10 Sep 2012 18:51:07 +0300
Message-ID: <1347292268-30348-5-git-send-email-yuvalmin@broadcom.com>
References: <1347292268-30348-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, "Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3497 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758100Ab2IJQPd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Sep 2012 12:15:33 -0400
In-Reply-To: <1347292268-30348-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c |    9 ++++-----
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.h |    1 -
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h  |    1 +
 3 files changed, 5 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
index f6178a1..839ddd2 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
@@ -10203,8 +10203,9 @@ static int bnx2x_848x3_config_init(struct bnx2x_phy *phy,
 			MDIO_84833_TOP_CFG_FW_REV, &val);
 
 	/* Configure EEE support */
-	if ((val >= MDIO_84833_TOP_CFG_FW_EEE) && bnx2x_eee_has_cap(params)) {
-		phy->flags |= FLAGS_EEE_10GBT;
+	if ((val >= MDIO_84833_TOP_CFG_FW_EEE) &&
+	    (val != MDIO_84833_TOP_CFG_FW_NO_EEE) &&
+	    bnx2x_eee_has_cap(params)) {
 		rc = bnx2x_eee_initial_config(params, vars, SHMEM_EEE_10G_ADV);
 		if (rc) {
 			DP(NETIF_MSG_LINK, "Failed to configure EEE timers\n");
@@ -10224,7 +10225,6 @@ static int bnx2x_848x3_config_init(struct bnx2x_phy *phy,
 			return rc;
 		}
 	} else {
-		phy->flags &= ~FLAGS_EEE_10GBT;
 		vars->eee_status &= ~SHMEM_EEE_SUPPORTED_MASK;
 	}
 
@@ -11619,8 +11619,7 @@ static struct bnx2x_phy phy_84833 = {
 	.def_md_devad	= 0,
 	.flags		= (FLAGS_FAN_FAILURE_DET_REQ |
 			   FLAGS_REARM_LATCH_SIGNAL |
-			   FLAGS_TX_ERROR_CHECK |
-			   FLAGS_EEE_10GBT),
+			   FLAGS_TX_ERROR_CHECK),
 	.rx_preemphasis	= {0xffff, 0xffff, 0xffff, 0xffff},
 	.tx_preemphasis	= {0xffff, 0xffff, 0xffff, 0xffff},
 	.mdio_ctrl	= 0,
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.h
index 51cac81..3967aa8 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.h
@@ -155,7 +155,6 @@ struct bnx2x_phy {
 #define FLAGS_DUMMY_READ		(1<<9)
 #define FLAGS_MDC_MDIO_WA_B0		(1<<10)
 #define FLAGS_TX_ERROR_CHECK		(1<<12)
-#define FLAGS_EEE_10GBT			(1<<13)
 
 	/* preemphasis values for the rx side */
 	u16 rx_preemphasis[4];
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h
index 28a0bcf..d32293f 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h
@@ -6992,6 +6992,7 @@ Theotherbitsarereservedandshouldbezero*/
 /* BCM84833 only */
 #define MDIO_84833_TOP_CFG_FW_REV			0x400f
 #define MDIO_84833_TOP_CFG_FW_EEE		0x10b1
+#define MDIO_84833_TOP_CFG_FW_NO_EEE		0x1f81
 #define MDIO_84833_TOP_CFG_XGPHY_STRAP1			0x401a
 #define MDIO_84833_SUPER_ISOLATE		0x8000
 /* These are mailbox register set used by 84833. */
-- 
1.7.9.rc2
