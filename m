From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [net-next 02/11] bnx2x: half duplex support added for several
 boards
Date: Wed, 15 Feb 2012 07:10:23 -0500
Message-ID: <1329307832-32454-3-git-send-email-yuvalmin@broadcom.com>
References: <1329307832-32454-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, "Mintz Yuval" <yuvalmin@broadcom.com>,
	"Yaniv Rosner" <yaniv.rosner@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3823 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752544Ab2BOFQQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Feb 2012 00:16:16 -0500
In-Reply-To: <1329307832-32454-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mintz Yuval <yuvalmin@broadcom.com>

From: Yaniv Rosner <yaniv.rosner@broadcom.com>

Several boards require an additional HW bit written in-order to enable
half duplex.

Signed-off-by: Yaniv Rosner <yaniv.rosner@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c |    3 +++
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h  |    1 +
 2 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
index 2102ad5..e7b0baf 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
@@ -1612,6 +1612,9 @@ static void bnx2x_umac_enable(struct link_params *params,
 	if (!(vars->flow_ctrl & BNX2X_FLOW_CTRL_RX))
 		val |= UMAC_COMMAND_CONFIG_REG_PAUSE_IGNORE;
 
+	if (vars->duplex == DUPLEX_HALF)
+		val |= UMAC_COMMAND_CONFIG_REG_HD_ENA;
+
 	REG_WR(bp, umac_base + UMAC_REG_COMMAND_CONFIG, val);
 	udelay(50);
 
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h
index c95d9dc..2feaca5 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h
@@ -4812,6 +4812,7 @@
    The fields are: [4:0] - tail pointer; 10:5] - Link List size; 15:11] -
    header pointer. */
 #define UCM_REG_XX_TABLE					 0xe0300
+#define UMAC_COMMAND_CONFIG_REG_HD_ENA				 (0x1<<10)
 #define UMAC_COMMAND_CONFIG_REG_IGNORE_TX_PAUSE			 (0x1<<28)
 #define UMAC_COMMAND_CONFIG_REG_LOOP_ENA			 (0x1<<15)
 #define UMAC_COMMAND_CONFIG_REG_NO_LGTH_CHECK			 (0x1<<24)
-- 
1.7.9.rc2
