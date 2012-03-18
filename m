From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [net-next 3/9] bnx2x: reduced sparse warnings
Date: Sun, 18 Mar 2012 16:33:39 -0400
Message-ID: <1332102825-7838-4-git-send-email-yuvalmin@broadcom.com>
References: <1332102825-7838-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, "Yuval Mintz" <yuvalmin@broadcom.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4951 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753822Ab2CRNsd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 18 Mar 2012 09:48:33 -0400
In-Reply-To: <1332102825-7838-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch reduces sparse warnings in the bnx2x code,
mostly by changing functions into static and changing
initialization of structures.

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c    |    6 +++---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h    |    5 +++--
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c    |    6 +++---
 .../net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c    |    2 +-
 .../net/ethernet/broadcom/bnx2x/bnx2x_fw_defs.h    |   12 ------------
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c   |   16 ++++++++--------
 6 files changed, 18 insertions(+), 29 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index e499dc8..8865b92 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -1574,7 +1574,7 @@ static inline int bnx2x_init_rss_pf(struct bnx2x *bp)
 
 int bnx2x_config_rss_pf(struct bnx2x *bp, u8 *ind_table, bool config_hash)
 {
-	struct bnx2x_config_rss_params params = {0};
+	struct bnx2x_config_rss_params params = {NULL};
 	int i;
 
 	/* Although RSS is meaningless when there is a single HW queue we
@@ -1637,7 +1637,7 @@ int bnx2x_config_rss_pf(struct bnx2x *bp, u8 *ind_table, bool config_hash)
 
 static inline int bnx2x_init_hw(struct bnx2x *bp, u32 load_code)
 {
-	struct bnx2x_func_state_params func_params = {0};
+	struct bnx2x_func_state_params func_params = {NULL};
 
 	/* Prepare parameters for function state transitions */
 	__set_bit(RAMROD_COMP_WAIT, &func_params.ramrod_flags);
@@ -1658,7 +1658,7 @@ static void bnx2x_squeeze_objects(struct bnx2x *bp)
 {
 	int rc;
 	unsigned long ramrod_flags = 0, vlan_mac_flags = 0;
-	struct bnx2x_mcast_ramrod_params rparam = {0};
+	struct bnx2x_mcast_ramrod_params rparam = {NULL};
 	struct bnx2x_vlan_mac_obj *mac_obj = &bp->fp->mac_obj;
 
 	/***************** Cleanup MACs' object first *************************/
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
index fbd4982..e15fdc9 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
@@ -970,7 +970,7 @@ static inline void bnx2x_reuse_rx_data(struct bnx2x_fastpath *fp,
  */
 static inline int bnx2x_func_start(struct bnx2x *bp)
 {
-	struct bnx2x_func_state_params func_params = {0};
+	struct bnx2x_func_state_params func_params = {NULL};
 	struct bnx2x_func_start_params *start_params =
 		&func_params.params.start;
 
@@ -1590,6 +1590,7 @@ static inline void bnx2x_bz_fp(struct bnx2x *bp, int index)
 #endif
 }
 
+#ifdef BCM_CNIC
 /**
  * bnx2x_get_iscsi_info - update iSCSI params according to licensing info.
  *
@@ -1597,7 +1598,7 @@ static inline void bnx2x_bz_fp(struct bnx2x *bp, int index)
  *
  */
 void bnx2x_get_iscsi_info(struct bnx2x *bp);
-
+#endif
 /* returns func by VN for current port */
 static inline int func_by_vn(struct bnx2x *bp, int vn)
 {
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c
index 21ae063..a2850fa 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c
@@ -443,7 +443,7 @@ static void bnx2x_pfc_set_pfc(struct bnx2x *bp)
 
 static int bnx2x_dcbx_stop_hw_tx(struct bnx2x *bp)
 {
-	struct bnx2x_func_state_params func_params = {0};
+	struct bnx2x_func_state_params func_params = {NULL};
 
 	func_params.f_obj = &bp->func_obj;
 	func_params.cmd = BNX2X_F_CMD_TX_STOP;
@@ -454,7 +454,7 @@ static int bnx2x_dcbx_stop_hw_tx(struct bnx2x *bp)
 
 static int bnx2x_dcbx_resume_hw_tx(struct bnx2x *bp)
 {
-	struct bnx2x_func_state_params func_params = {0};
+	struct bnx2x_func_state_params func_params = {NULL};
 	struct bnx2x_func_tx_start_params *tx_params =
 		&func_params.params.tx_start;
 
@@ -529,7 +529,7 @@ static void bnx2x_dcbx_2cos_limit_update_ets_config(struct bnx2x *bp)
 /*
  * In E3B0 the configuration may have more than 2 COS.
  */
-void bnx2x_dcbx_update_ets_config(struct bnx2x *bp)
+static void bnx2x_dcbx_update_ets_config(struct bnx2x *bp)
 {
 	struct bnx2x_dcbx_pg_params *ets = &(bp->dcbx_port_params.ets);
 	struct bnx2x_ets_params ets_params = { 0 };
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
index 3618a00..2cc0a17 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
@@ -2107,7 +2107,7 @@ test_nvram_exit:
 /* Send an EMPTY ramrod on the first queue */
 static int bnx2x_test_intr(struct bnx2x *bp)
 {
-	struct bnx2x_queue_state_params params = {0};
+	struct bnx2x_queue_state_params params = {NULL};
 
 	if (!netif_running(bp->dev)) {
 		DP(BNX2X_MSG_ETHTOOL | BNX2X_MSG_NVM,
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_fw_defs.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_fw_defs.h
index e5c5982..cd6dfa9 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_fw_defs.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_fw_defs.h
@@ -243,18 +243,6 @@
 	(IRO[48].base + ((funcId) * IRO[48].m1))
 #define COMMON_ASM_INVALID_ASSERT_OPCODE 0x0
 
-/**
-* This file defines HSI constants for the ETH flow
-*/
-#ifdef _EVEREST_MICROCODE
-#include "Microcode\Generated\DataTypes\eth_rx_bd.h"
-#include "Microcode\Generated\DataTypes\eth_tx_bd.h"
-#include "Microcode\Generated\DataTypes\eth_rx_cqe.h"
-#include "Microcode\Generated\DataTypes\eth_rx_sge.h"
-#include "Microcode\Generated\DataTypes\eth_rx_cqe_next_page.h"
-#endif
-
-
 /* Ethernet Ring parameters */
 #define X_ETH_LOCAL_RING_SIZE 13
 #define FIRST_BD_IN_PKT	0
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 84f92aa..d969738 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -7446,7 +7446,7 @@ int bnx2x_setup_tx_only(struct bnx2x *bp, struct bnx2x_fastpath *fp,
 int bnx2x_setup_queue(struct bnx2x *bp, struct bnx2x_fastpath *fp,
 		       bool leading)
 {
-	struct bnx2x_queue_state_params q_params = {0};
+	struct bnx2x_queue_state_params q_params = {NULL};
 	struct bnx2x_queue_setup_params *setup_params =
 						&q_params.params.setup;
 	struct bnx2x_queue_setup_tx_only_params *tx_only_params =
@@ -7529,7 +7529,7 @@ static int bnx2x_stop_queue(struct bnx2x *bp, int index)
 {
 	struct bnx2x_fastpath *fp = &bp->fp[index];
 	struct bnx2x_fp_txdata *txdata;
-	struct bnx2x_queue_state_params q_params = {0};
+	struct bnx2x_queue_state_params q_params = {NULL};
 	int rc, tx_index;
 
 	DP(NETIF_MSG_IFDOWN, "stopping queue %d cid %d\n", index, fp->cid);
@@ -7705,7 +7705,7 @@ static void bnx2x_reset_port(struct bnx2x *bp)
 
 static inline int bnx2x_reset_hw(struct bnx2x *bp, u32 load_code)
 {
-	struct bnx2x_func_state_params func_params = {0};
+	struct bnx2x_func_state_params func_params = {NULL};
 
 	/* Prepare parameters for function state transitions */
 	__set_bit(RAMROD_COMP_WAIT, &func_params.ramrod_flags);
@@ -7720,7 +7720,7 @@ static inline int bnx2x_reset_hw(struct bnx2x *bp, u32 load_code)
 
 static inline int bnx2x_func_stop(struct bnx2x *bp)
 {
-	struct bnx2x_func_state_params func_params = {0};
+	struct bnx2x_func_state_params func_params = {NULL};
 	int rc;
 
 	/* Prepare parameters for function state transitions */
@@ -7877,7 +7877,7 @@ static inline int bnx2x_func_wait_started(struct bnx2x *bp)
 		 * Failed to complete the transaction in a "good way"
 		 * Force both transactions with CLR bit
 		 */
-		struct bnx2x_func_state_params func_params = {0};
+		struct bnx2x_func_state_params func_params = {NULL};
 
 		DP(NETIF_MSG_IFDOWN,
 		   "Hmmm... unexpected function state! Forcing STARTED-->TX_ST0PPED-->STARTED\n");
@@ -7904,7 +7904,7 @@ void bnx2x_chip_cleanup(struct bnx2x *bp, int unload_mode)
 	int port = BP_PORT(bp);
 	int i, rc = 0;
 	u8 cos;
-	struct bnx2x_mcast_ramrod_params rparam = {0};
+	struct bnx2x_mcast_ramrod_params rparam = {NULL};
 	u32 reset_code;
 
 	/* Wait until tx fastpath tasks complete */
@@ -10309,7 +10309,7 @@ static inline int bnx2x_set_uc_list(struct bnx2x *bp)
 static inline int bnx2x_set_mc_list(struct bnx2x *bp)
 {
 	struct net_device *dev = bp->dev;
-	struct bnx2x_mcast_ramrod_params rparam = {0};
+	struct bnx2x_mcast_ramrod_params rparam = {NULL};
 	int rc = 0;
 
 	rparam.mcast_obj = &bp->mcast_obj;
@@ -10830,7 +10830,7 @@ do {									\
 	     (u8 *)bp->arr, len);					\
 } while (0)
 
-int bnx2x_init_firmware(struct bnx2x *bp)
+static int bnx2x_init_firmware(struct bnx2x *bp)
 {
 	struct bnx2x_fw_file_hdr *fw_hdr;
 	int rc;
-- 
1.7.9.rc2
