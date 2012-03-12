From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [net-next 1/8] bnx2x: move LLH_CAM to header, apply naming
 conventions
Date: Mon, 12 Mar 2012 14:53:07 -0400
Message-ID: <1331578394-1153-2-git-send-email-yuvalmin@broadcom.com>
References: <1331578394-1153-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Yuval Mintz" <yuvalmin@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1169 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754647Ab2CLL71 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Mar 2012 07:59:27 -0400
In-Reply-To: <1331578394-1153-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These definitions are united into the header.

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c |   13 ++++---------
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.h |    7 +++++++
 2 files changed, 11 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
index adfae6b..f7896c2 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
@@ -611,12 +611,6 @@ static inline u8 bnx2x_vlan_mac_get_rx_tx_flag(struct bnx2x_vlan_mac_obj *o)
 	return rx_tx_flag;
 }
 
-/* LLH CAM line allocations */
-enum {
-	LLH_CAM_ISCSI_ETH_LINE = 0,
-	LLH_CAM_ETH_LINE,
-	LLH_CAM_MAX_PF_LINE = NIG_REG_LLH1_FUNC_MEM_SIZE / 2
-};
 
 static inline void bnx2x_set_mac_in_nig(struct bnx2x *bp,
 				 bool add, unsigned char *dev_addr, int index)
@@ -625,7 +619,7 @@ static inline void bnx2x_set_mac_in_nig(struct bnx2x *bp,
 	u32 reg_offset = BP_PORT(bp) ? NIG_REG_LLH1_FUNC_MEM :
 			 NIG_REG_LLH0_FUNC_MEM;
 
-	if (!IS_MF_SI(bp) || index > LLH_CAM_MAX_PF_LINE)
+	if (!IS_MF_SI(bp) || index > BNX2X_LLH_CAM_MAX_PF_LINE)
 		return;
 
 	DP(BNX2X_MSG_SP, "Going to %s LLH configuration at entry %d\n",
@@ -731,9 +725,10 @@ static void bnx2x_set_one_mac_e2(struct bnx2x *bp,
 	if (cmd != BNX2X_VLAN_MAC_MOVE) {
 		if (test_bit(BNX2X_ISCSI_ETH_MAC, vlan_mac_flags))
 			bnx2x_set_mac_in_nig(bp, add, mac,
-					     LLH_CAM_ISCSI_ETH_LINE);
+					     BNX2X_LLH_CAM_ISCSI_ETH_LINE);
 		else if (test_bit(BNX2X_ETH_MAC, vlan_mac_flags))
-			bnx2x_set_mac_in_nig(bp, add, mac, LLH_CAM_ETH_LINE);
+			bnx2x_set_mac_in_nig(bp, add, mac,
+					     BNX2X_LLH_CAM_ETH_LINE);
 	}
 
 	/* Reset the ramrod data buffer for the first rule */
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.h
index 685d42e..0be63e7 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.h
@@ -423,6 +423,13 @@ struct bnx2x_vlan_mac_obj {
 	int (*wait)(struct bnx2x *bp, struct bnx2x_vlan_mac_obj *o);
 };
 
+enum {
+	BNX2X_LLH_CAM_ISCSI_ETH_LINE = 0,
+	BNX2X_LLH_CAM_ETH_LINE,
+	BNX2X_LLH_CAM_MAX_PF_LINE = NIG_REG_LLH1_FUNC_MEM_SIZE / 2
+};
+
+
 /** RX_MODE verbs:DROP_ALL/ACCEPT_ALL/ACCEPT_ALL_MULTI/ACCEPT_ALL_VLAN/NORMAL */
 
 /* RX_MODE ramrod spesial flags: set in rx_mode_flags field in
-- 
1.7.9.rc2
