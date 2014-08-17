From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next 3/9] bnx2x: Code cleanup
Date: Sun, 17 Aug 2014 16:47:45 +0300
Message-ID: <1408283271-16176-4-git-send-email-Yuval.Mintz@qlogic.com>
References: <1408283271-16176-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Ariel.Elior@qlogic.com>, Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:44120 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751282AbaHQNsJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Aug 2014 09:48:09 -0400
In-Reply-To: <1408283271-16176-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch does several semantic things:
  - Fixing typos.
  - Removing unnecessary prints.
  - Removing unused functions and definitions.
  - Change 'strange' usage of boolean variables.

Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
Signed-off-by: Ariel Elior <Ariel.Elior@qlogic.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h       |   15 ++++-------
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c   |    5 +---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c  |   16 +++++-------
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c |   27 +-------------------
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c |    5 +--
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c  |    9 -------
 6 files changed, 17 insertions(+), 60 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
index a0b06a0..79b2919 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
@@ -1592,12 +1592,11 @@ struct bnx2x {
 #define USING_SINGLE_MSIX_FLAG		(1 << 20)
 #define BC_SUPPORTS_DCBX_MSG_NON_PMF	(1 << 21)
 #define IS_VF_FLAG			(1 << 22)
-#define INTERRUPTS_ENABLED_FLAG		(1 << 23)
-#define BC_SUPPORTS_RMMOD_CMD		(1 << 24)
-#define HAS_PHYS_PORT_ID		(1 << 25)
-#define AER_ENABLED			(1 << 26)
-#define PTP_SUPPORTED			(1 << 27)
-#define TX_TIMESTAMPING_EN		(1 << 28)
+#define BC_SUPPORTS_RMMOD_CMD		(1 << 23)
+#define HAS_PHYS_PORT_ID		(1 << 24)
+#define AER_ENABLED			(1 << 25)
+#define PTP_SUPPORTED			(1 << 26)
+#define TX_TIMESTAMPING_EN		(1 << 27)
 
 #define BP_NOMCP(bp)			((bp)->flags & NO_MCP_FLAG)
 
@@ -1691,13 +1690,9 @@ struct bnx2x {
 #define BNX2X_STATE_ERROR		0xf000
 
 #define BNX2X_MAX_PRIORITY		8
-#define BNX2X_MAX_ENTRIES_PER_PRI	16
-#define BNX2X_MAX_COS			3
-#define BNX2X_MAX_TX_COS		2
 	int			num_queues;
 	uint			num_ethernet_queues;
 	uint			num_cnic_queues;
-	int			num_napi_queues;
 	int			disable_tpa;
 
 	u32			rx_mode;
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c
index fb26bc4..6e4294e 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c
@@ -2092,7 +2092,6 @@ static void bnx2x_dcbnl_get_pfc_cfg(struct net_device *netdev, int prio,
 static u8 bnx2x_dcbnl_set_all(struct net_device *netdev)
 {
 	struct bnx2x *bp = netdev_priv(netdev);
-	int rc = 0;
 
 	DP(BNX2X_MSG_DCB, "SET-ALL\n");
 
@@ -2110,9 +2109,7 @@ static u8 bnx2x_dcbnl_set_all(struct net_device *netdev)
 				       1);
 		bnx2x_dcbx_init(bp, true);
 	}
-	DP(BNX2X_MSG_DCB, "set_dcbx_params done (%d)\n", rc);
-	if (rc)
-		return 1;
+	DP(BNX2X_MSG_DCB, "set_dcbx_params done\n");
 
 	return 0;
 }
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 423e4b8..17c629a 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -2075,8 +2075,6 @@ int bnx2x_get_gpio(struct bnx2x *bp, int gpio_num, u8 port)
 	else
 		value = 0;
 
-	DP(NETIF_MSG_LINK, "pin %d  value 0x%x\n", gpio_num, value);
-
 	return value;
 }
 
@@ -4682,7 +4680,7 @@ static bool bnx2x_check_blocks_with_parity2(struct bnx2x *bp, u32 sig,
 	for (i = 0; sig; i++) {
 		cur_bit = (0x1UL << i);
 		if (sig & cur_bit) {
-			res |= true; /* Each bit is real error! */
+			res = true; /* Each bit is real error! */
 			if (print) {
 				switch (cur_bit) {
 				case AEU_INPUTS_ATTN_BITS_CSEMI_PARITY_ERROR:
@@ -4761,21 +4759,21 @@ static bool bnx2x_check_blocks_with_parity3(struct bnx2x *bp, u32 sig,
 					_print_next_block((*par_num)++,
 							  "MCP ROM");
 				*global = true;
-				res |= true;
+				res = true;
 				break;
 			case AEU_INPUTS_ATTN_BITS_MCP_LATCHED_UMP_RX_PARITY:
 				if (print)
 					_print_next_block((*par_num)++,
 							  "MCP UMP RX");
 				*global = true;
-				res |= true;
+				res = true;
 				break;
 			case AEU_INPUTS_ATTN_BITS_MCP_LATCHED_UMP_TX_PARITY:
 				if (print)
 					_print_next_block((*par_num)++,
 							  "MCP UMP TX");
 				*global = true;
-				res |= true;
+				res = true;
 				break;
 			case AEU_INPUTS_ATTN_BITS_MCP_LATCHED_SCPAD_PARITY:
 				if (print)
@@ -4807,7 +4805,7 @@ static bool bnx2x_check_blocks_with_parity4(struct bnx2x *bp, u32 sig,
 	for (i = 0; sig; i++) {
 		cur_bit = (0x1UL << i);
 		if (sig & cur_bit) {
-			res |= true; /* Each bit is real error! */
+			res = true; /* Each bit is real error! */
 			if (print) {
 				switch (cur_bit) {
 				case AEU_INPUTS_ATTN_BITS_PGLUE_PARITY_ERROR:
@@ -6114,7 +6112,7 @@ static int bnx2x_fill_accept_flags(struct bnx2x *bp, u32 rx_mode,
 	}
 
 	/* Set ACCEPT_ANY_VLAN as we do not enable filtering by VLAN */
-	if (bp->rx_mode != BNX2X_RX_MODE_NONE) {
+	if (rx_mode != BNX2X_RX_MODE_NONE) {
 		__set_bit(BNX2X_ACCEPT_ANY_VLAN, rx_accept_flags);
 		__set_bit(BNX2X_ACCEPT_ANY_VLAN, tx_accept_flags);
 	}
@@ -9026,7 +9024,7 @@ static int bnx2x_func_wait_started(struct bnx2x *bp)
 		struct bnx2x_func_state_params func_params = {NULL};
 
 		DP(NETIF_MSG_IFDOWN,
-		   "Hmmm... Unexpected function state! Forcing STARTED-->TX_ST0PPED-->STARTED\n");
+		   "Hmmm... Unexpected function state! Forcing STARTED-->TX_STOPPED-->STARTED\n");
 
 		func_params.f_obj = &bp->func_obj;
 		__set_bit(RAMROD_DRV_CLR_ONLY,
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
index 662310c..5a88788 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
@@ -1321,8 +1321,6 @@ int bnx2x_iov_init_one(struct bnx2x *bp, int int_mode_param,
 		BNX2X_MAX_NUM_VF_QUEUES * sizeof(struct bnx2x_vf_queue),
 		GFP_KERNEL);
 
-	DP(BNX2X_MSG_IOV, "bp->vfdb->vfqs was %p\n", bp->vfdb->vfqs);
-
 	if (!bp->vfdb->vfqs) {
 		BNX2X_ERR("failed to allocate vf queue array\n");
 		err = -ENOMEM;
@@ -1985,21 +1983,6 @@ void bnx2x_iov_adjust_stats_req(struct bnx2x *bp)
 	bp->fw_stats_req->hdr.cmd_num = bp->fw_stats_num + stats_count;
 }
 
-static inline
-struct bnx2x_virtf *__vf_from_stat_id(struct bnx2x *bp, u8 stat_id)
-{
-	int i;
-	struct bnx2x_virtf *vf = NULL;
-
-	for_each_vf(bp, i) {
-		vf = BP_VF(bp, i);
-		if (stat_id >= vf->igu_base_id &&
-		    stat_id < vf->igu_base_id + vf_sb_count(vf))
-			break;
-	}
-	return vf;
-}
-
 /* VF API helpers */
 static void bnx2x_vf_qtbl_set_q(struct bnx2x *bp, u8 abs_vfid, u8 qid,
 				u8 enable)
@@ -2362,12 +2345,6 @@ int bnx2x_vf_release(struct bnx2x *bp, struct bnx2x_virtf *vf)
 	return rc;
 }
 
-static inline void bnx2x_vf_get_sbdf(struct bnx2x *bp,
-			      struct bnx2x_virtf *vf, u32 *sbdf)
-{
-	*sbdf = vf->devfn | (vf->bus << 8);
-}
-
 void bnx2x_lock_vf_pf_channel(struct bnx2x *bp, struct bnx2x_virtf *vf,
 			      enum channel_tlvs tlv)
 {
@@ -2416,7 +2393,7 @@ void bnx2x_unlock_vf_pf_channel(struct bnx2x *bp, struct bnx2x_virtf *vf,
 
 	/* log the unlock */
 	DP(BNX2X_MSG_IOV, "VF[%d]: vf pf channel unlocked by %d\n",
-	   vf->abs_vfid, vf->op_current);
+	   vf->abs_vfid, current_tlv);
 }
 
 static int bnx2x_set_pf_tx_switching(struct bnx2x *bp, bool enable)
@@ -2628,7 +2605,7 @@ static int bnx2x_vf_op_prep(struct bnx2x *bp, int vfidx,
 	}
 
 	if (!IS_SRIOV(bp)) {
-		BNX2X_ERR("sriov is disabled - can't utilize iov-realted functionality\n");
+		BNX2X_ERR("sriov is disabled - can't utilize iov-related functionality\n");
 		return -EINVAL;
 	}
 
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c
index ca47665..e1c8193 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c
@@ -137,7 +137,7 @@ static void bnx2x_storm_stats_post(struct bnx2x *bp)
 			cpu_to_le16(bp->stats_counter++);
 
 		DP(BNX2X_MSG_STATS, "Sending statistics ramrod %d\n",
-			bp->fw_stats_req->hdr.drv_stats_counter);
+		   le16_to_cpu(bp->fw_stats_req->hdr.drv_stats_counter));
 
 		/* adjust the ramrod to include VF queues statistics */
 		bnx2x_iov_adjust_stats_req(bp);
@@ -200,7 +200,7 @@ static void bnx2x_hw_stats_post(struct bnx2x *bp)
 	}
 }
 
-static int bnx2x_stats_comp(struct bnx2x *bp)
+static void bnx2x_stats_comp(struct bnx2x *bp)
 {
 	u32 *stats_comp = bnx2x_sp(bp, stats_comp);
 	int cnt = 10;
@@ -214,7 +214,6 @@ static int bnx2x_stats_comp(struct bnx2x *bp)
 		cnt--;
 		usleep_range(1000, 2000);
 	}
-	return 1;
 }
 
 /*
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c
index 54e0427..b1d9c44 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c
@@ -583,7 +583,6 @@ int bnx2x_vfpf_setup_q(struct bnx2x *bp, struct bnx2x_fastpath *fp,
 	flags |= VFPF_QUEUE_FLG_STATS;
 	flags |= VFPF_QUEUE_FLG_CACHE_ALIGN;
 	flags |= VFPF_QUEUE_FLG_VLAN;
-	DP(NETIF_MSG_IFUP, "vlan removal enabled\n");
 
 	/* Common */
 	req->vf_qid = fp_idx;
@@ -952,14 +951,6 @@ static void storm_memset_vf_mbx_valid(struct bnx2x *bp, u16 abs_fid)
 	REG_WR8(bp, addr, 1);
 }
 
-static inline void bnx2x_set_vf_mbxs_valid(struct bnx2x *bp)
-{
-	int i;
-
-	for_each_vf(bp, i)
-		storm_memset_vf_mbx_valid(bp, bnx2x_vf(bp, i, abs_vfid));
-}
-
 /* enable vf_pf mailbox (aka vf-pf-channel) */
 void bnx2x_vf_enable_mbx(struct bnx2x *bp, u8 abs_vfid)
 {
-- 
1.7.1
