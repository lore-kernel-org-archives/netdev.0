From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 02/11] bnxt_en: Update firmware spec. to 1.3.0.
Date: Fri,  1 Jul 2016 18:46:20 -0400
Message-ID: <1467413189-29566-3-git-send-email-michael.chan@broadcom.com>
References: <1467413189-29566-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:34388 "EHLO
	mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752418AbcGAWqp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jul 2016 18:46:45 -0400
Received: by mail-pf0-f174.google.com with SMTP id h14so43861940pfe.1
        for <netdev@vger.kernel.org>; Fri, 01 Jul 2016 15:46:45 -0700 (PDT)
In-Reply-To: <1467413189-29566-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

And update driver version to 1.3.0.

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.h     | 11 ++--
 drivers/net/ethernet/broadcom/bnxt/bnxt_hsi.h | 87 ++++++++++++++++++---------
 2 files changed, 66 insertions(+), 32 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.h b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
index 927ece9..084b3f2 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
@@ -11,10 +11,10 @@
 #define BNXT_H
 
 #define DRV_MODULE_NAME		"bnxt_en"
-#define DRV_MODULE_VERSION	"1.2.0"
+#define DRV_MODULE_VERSION	"1.3.0"
 
 #define DRV_VER_MAJ	1
-#define DRV_VER_MIN	0
+#define DRV_VER_MIN	3
 #define DRV_VER_UPD	0
 
 struct tx_bd {
@@ -359,7 +359,8 @@ struct rx_tpa_end_cmp {
 	 RX_TPA_END_CMP_FLAGS_PLACEMENT_ANY_GRO)
 
 #define TPA_END_GRO_TS(rx_tpa_end)					\
-	((rx_tpa_end)->rx_tpa_end_cmp_tsdelta & cpu_to_le32(RX_TPA_END_GRO_TS))
+	(!!((rx_tpa_end)->rx_tpa_end_cmp_tsdelta &			\
+	    cpu_to_le32(RX_TPA_END_GRO_TS)))
 
 struct rx_tpa_end_cmp_ext {
 	__le32 rx_tpa_end_cmp_dup_acks;
@@ -753,8 +754,8 @@ struct bnxt_vf_info {
 struct bnxt_pf_info {
 #define BNXT_FIRST_PF_FID	1
 #define BNXT_FIRST_VF_FID	128
-	u32	fw_fid;
-	u8	port_id;
+	u16	fw_fid;
+	u16	port_id;
 	u8	mac_addr[ETH_ALEN];
 	u16	max_rsscos_ctxs;
 	u16	max_cp_rings;
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_hsi.h b/drivers/net/ethernet/broadcom/bnxt/bnxt_hsi.h
index 05e3c49..517567f 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_hsi.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_hsi.h
@@ -105,6 +105,7 @@ struct hwrm_async_event_cmpl {
 	#define HWRM_ASYNC_EVENT_CMPL_EVENT_ID_PORT_CONN_NOT_ALLOWED (0x4UL << 0)
 	#define HWRM_ASYNC_EVENT_CMPL_EVENT_ID_LINK_SPEED_CFG_NOT_ALLOWED (0x5UL << 0)
 	#define HWRM_ASYNC_EVENT_CMPL_EVENT_ID_LINK_SPEED_CFG_CHANGE (0x6UL << 0)
+	#define HWRM_ASYNC_EVENT_CMPL_EVENT_ID_PORT_PHY_CFG_CHANGE (0x7UL << 0)
 	#define HWRM_ASYNC_EVENT_CMPL_EVENT_ID_FUNC_DRVR_UNLOAD   (0x10UL << 0)
 	#define HWRM_ASYNC_EVENT_CMPL_EVENT_ID_FUNC_DRVR_LOAD     (0x11UL << 0)
 	#define HWRM_ASYNC_EVENT_CMPL_EVENT_ID_PF_DRVR_UNLOAD     (0x20UL << 0)
@@ -484,12 +485,12 @@ struct hwrm_async_event_cmpl_hwrm_error {
 	#define HWRM_ASYNC_EVENT_CMPL_HWRM_ERROR_EVENT_DATA1_TIMESTAMP 0x1UL
 };
 
-/* HW Resource Manager Specification 1.2.2 */
+/* HW Resource Manager Specification 1.3.0 */
 #define HWRM_VERSION_MAJOR	1
-#define HWRM_VERSION_MINOR	2
-#define HWRM_VERSION_UPDATE	2
+#define HWRM_VERSION_MINOR	3
+#define HWRM_VERSION_UPDATE	0
 
-#define HWRM_VERSION_STR	"1.2.2"
+#define HWRM_VERSION_STR	"1.3.0"
 /*
  * Following is the signature for HWRM message field that indicates not
  * applicable (All F's). Need to cast it the size of the field if needed.
@@ -611,6 +612,9 @@ struct cmd_nums {
 	#define HWRM_FWD_RESP					   (0xd2UL)
 	#define HWRM_FWD_ASYNC_EVENT_CMPL			   (0xd3UL)
 	#define HWRM_TEMP_MONITOR_QUERY			   (0xe0UL)
+	#define HWRM_WOL_FILTER_ALLOC				   (0xf0UL)
+	#define HWRM_WOL_FILTER_FREE				   (0xf1UL)
+	#define HWRM_WOL_FILTER_QCFG				   (0xf2UL)
 	#define HWRM_DBG_READ_DIRECT				   (0xff10UL)
 	#define HWRM_DBG_READ_INDIRECT				   (0xff11UL)
 	#define HWRM_DBG_WRITE_DIRECT				   (0xff12UL)
@@ -1020,6 +1024,10 @@ struct hwrm_func_qcaps_output {
 	#define FUNC_QCAPS_RESP_FLAGS_PUSH_MODE_SUPPORTED	    0x1UL
 	#define FUNC_QCAPS_RESP_FLAGS_GLOBAL_MSIX_AUTOMASKING      0x2UL
 	#define FUNC_QCAPS_RESP_FLAGS_PTP_SUPPORTED		    0x4UL
+	#define FUNC_QCAPS_RESP_FLAGS_ROCE_V1_SUPPORTED	    0x8UL
+	#define FUNC_QCAPS_RESP_FLAGS_ROCE_V2_SUPPORTED	    0x10UL
+	#define FUNC_QCAPS_RESP_FLAGS_WOL_MAGICPKT_SUPPORTED       0x20UL
+	#define FUNC_QCAPS_RESP_FLAGS_WOL_BMP_SUPPORTED	    0x40UL
 	u8 mac_address[6];
 	__le16 max_rsscos_ctx;
 	__le16 max_cmpl_rings;
@@ -1066,8 +1074,9 @@ struct hwrm_func_qcfg_output {
 	__le16 fid;
 	__le16 port_id;
 	__le16 vlan;
-	u8 unused_0;
-	u8 unused_1;
+	__le16 flags;
+	#define FUNC_QCFG_RESP_FLAGS_OOB_WOL_MAGICPKT_ENABLED      0x1UL
+	#define FUNC_QCFG_RESP_FLAGS_OOB_WOL_BMP_ENABLED	    0x2UL
 	u8 mac_address[6];
 	__le16 pci_id;
 	__le16 alloc_rsscos_ctx;
@@ -1086,23 +1095,23 @@ struct hwrm_func_qcfg_output {
 	#define FUNC_QCFG_RESP_PORT_PARTITION_TYPE_NPAR1_5	   (0x3UL << 0)
 	#define FUNC_QCFG_RESP_PORT_PARTITION_TYPE_NPAR2_0	   (0x4UL << 0)
 	#define FUNC_QCFG_RESP_PORT_PARTITION_TYPE_UNKNOWN	   (0xffUL << 0)
-	u8 unused_2;
+	u8 unused_0;
 	__le16 dflt_vnic_id;
-	u8 unused_3;
-	u8 unused_4;
+	u8 unused_1;
+	u8 unused_2;
 	__le32 min_bw;
 	__le32 max_bw;
 	u8 evb_mode;
 	#define FUNC_QCFG_RESP_EVB_MODE_NO_EVB			   (0x0UL << 0)
 	#define FUNC_QCFG_RESP_EVB_MODE_VEB			   (0x1UL << 0)
 	#define FUNC_QCFG_RESP_EVB_MODE_VEPA			   (0x2UL << 0)
-	u8 unused_5;
-	__le16 unused_6;
+	u8 unused_3;
+	__le16 unused_4;
 	__le32 alloc_mcast_filters;
 	__le32 alloc_hw_ring_grps;
+	u8 unused_5;
+	u8 unused_6;
 	u8 unused_7;
-	u8 unused_8;
-	u8 unused_9;
 	u8 valid;
 };
 
@@ -1410,8 +1419,8 @@ struct hwrm_func_buf_rgtr_input {
 	#define FUNC_BUF_RGTR_REQ_REQ_BUF_PAGE_SIZE_4K		   (0xcUL << 0)
 	#define FUNC_BUF_RGTR_REQ_REQ_BUF_PAGE_SIZE_8K		   (0xdUL << 0)
 	#define FUNC_BUF_RGTR_REQ_REQ_BUF_PAGE_SIZE_64K	   (0x10UL << 0)
-	#define FUNC_BUF_RGTR_REQ_REQ_BUF_PAGE_SIZE_2M		   (0x16UL << 0)
-	#define FUNC_BUF_RGTR_REQ_REQ_BUF_PAGE_SIZE_4M		   (0x17UL << 0)
+	#define FUNC_BUF_RGTR_REQ_REQ_BUF_PAGE_SIZE_2M		   (0x15UL << 0)
+	#define FUNC_BUF_RGTR_REQ_REQ_BUF_PAGE_SIZE_4M		   (0x16UL << 0)
 	#define FUNC_BUF_RGTR_REQ_REQ_BUF_PAGE_SIZE_1G		   (0x1eUL << 0)
 	__le16 req_buf_len;
 	__le16 resp_buf_len;
@@ -1499,6 +1508,12 @@ struct hwrm_port_phy_cfg_input {
 	#define PORT_PHY_CFG_REQ_FLAGS_EEE_DISABLE		    0x20UL
 	#define PORT_PHY_CFG_REQ_FLAGS_EEE_TX_LPI_ENABLE	    0x40UL
 	#define PORT_PHY_CFG_REQ_FLAGS_EEE_TX_LPI_DISABLE	    0x80UL
+	#define PORT_PHY_CFG_REQ_FLAGS_FEC_AUTONEG_ENABLE	    0x100UL
+	#define PORT_PHY_CFG_REQ_FLAGS_FEC_AUTONEG_DISABLE	    0x200UL
+	#define PORT_PHY_CFG_REQ_FLAGS_FEC_CLAUSE74_ENABLE	    0x400UL
+	#define PORT_PHY_CFG_REQ_FLAGS_FEC_CLAUSE74_DISABLE	    0x800UL
+	#define PORT_PHY_CFG_REQ_FLAGS_FEC_CLAUSE91_ENABLE	    0x1000UL
+	#define PORT_PHY_CFG_REQ_FLAGS_FEC_CLAUSE91_DISABLE	    0x2000UL
 	__le32 enables;
 	#define PORT_PHY_CFG_REQ_ENABLES_AUTO_MODE		    0x1UL
 	#define PORT_PHY_CFG_REQ_ENABLES_AUTO_DUPLEX		    0x2UL
@@ -1815,13 +1830,22 @@ struct hwrm_port_phy_qcfg_output {
 	#define PORT_PHY_QCFG_RESP_XCVR_IDENTIFIER_TYPE_QSFP      (0xcUL << 24)
 	#define PORT_PHY_QCFG_RESP_XCVR_IDENTIFIER_TYPE_QSFPPLUS  (0xdUL << 24)
 	#define PORT_PHY_QCFG_RESP_XCVR_IDENTIFIER_TYPE_QSFP28    (0x11UL << 24)
-	__le32 unused_1;
+	__le16 fec_cfg;
+	#define PORT_PHY_QCFG_RESP_FEC_CFG_FEC_NONE_SUPPORTED      0x1UL
+	#define PORT_PHY_QCFG_RESP_FEC_CFG_FEC_AUTONEG_SUPPORTED   0x2UL
+	#define PORT_PHY_QCFG_RESP_FEC_CFG_FEC_AUTONEG_ENABLED     0x4UL
+	#define PORT_PHY_QCFG_RESP_FEC_CFG_FEC_CLAUSE74_SUPPORTED  0x8UL
+	#define PORT_PHY_QCFG_RESP_FEC_CFG_FEC_CLAUSE74_ENABLED    0x10UL
+	#define PORT_PHY_QCFG_RESP_FEC_CFG_FEC_CLAUSE91_SUPPORTED  0x20UL
+	#define PORT_PHY_QCFG_RESP_FEC_CFG_FEC_CLAUSE91_ENABLED    0x40UL
+	u8 unused_1;
+	u8 unused_2;
 	char phy_vendor_name[16];
 	char phy_vendor_partnumber[16];
-	__le32 unused_2;
-	u8 unused_3;
+	__le32 unused_3;
 	u8 unused_4;
 	u8 unused_5;
+	u8 unused_6;
 	u8 valid;
 };
 
@@ -1842,6 +1866,8 @@ struct hwrm_port_mac_cfg_input {
 	#define PORT_MAC_CFG_REQ_FLAGS_PTP_RX_TS_CAPTURE_DISABLE   0x20UL
 	#define PORT_MAC_CFG_REQ_FLAGS_PTP_TX_TS_CAPTURE_ENABLE    0x40UL
 	#define PORT_MAC_CFG_REQ_FLAGS_PTP_TX_TS_CAPTURE_DISABLE   0x80UL
+	#define PORT_MAC_CFG_REQ_FLAGS_OOB_WOL_ENABLE		    0x100UL
+	#define PORT_MAC_CFG_REQ_FLAGS_OOB_WOL_DISABLE		    0x200UL
 	__le32 enables;
 	#define PORT_MAC_CFG_REQ_ENABLES_IPG			    0x1UL
 	#define PORT_MAC_CFG_REQ_ENABLES_LPBK			    0x2UL
@@ -2127,6 +2153,7 @@ struct hwrm_port_phy_i2c_read_output {
 	u8 valid;
 };
 
+/* hwrm_queue_qportcfg */
 /* Input (24 bytes) */
 struct hwrm_queue_qportcfg_input {
 	__le16 req_type;
@@ -2382,7 +2409,7 @@ struct hwrm_queue_cos2bw_cfg_input {
 	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID0_TSA_ASSIGN_SP      (0x0UL << 0)
 	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID0_TSA_ASSIGN_ETS     (0x1UL << 0)
 	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID0_TSA_ASSIGN_RESERVED_FIRST (0x2UL << 0)
-	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID0_TSA_ASSIGN_RESERVED_LAST (0xffffUL << 0)
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID0_TSA_ASSIGN_RESERVED_LAST (0xffUL << 0)
 	u8 queue_id0_pri_lvl;
 	u8 queue_id0_bw_weight;
 	u8 queue_id1;
@@ -2392,7 +2419,7 @@ struct hwrm_queue_cos2bw_cfg_input {
 	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID1_TSA_ASSIGN_SP      (0x0UL << 0)
 	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID1_TSA_ASSIGN_ETS     (0x1UL << 0)
 	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID1_TSA_ASSIGN_RESERVED_FIRST (0x2UL << 0)
-	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID1_TSA_ASSIGN_RESERVED_LAST (0xffffUL << 0)
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID1_TSA_ASSIGN_RESERVED_LAST (0xffUL << 0)
 	u8 queue_id1_pri_lvl;
 	u8 queue_id1_bw_weight;
 	u8 queue_id2;
@@ -2402,7 +2429,7 @@ struct hwrm_queue_cos2bw_cfg_input {
 	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID2_TSA_ASSIGN_SP      (0x0UL << 0)
 	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID2_TSA_ASSIGN_ETS     (0x1UL << 0)
 	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID2_TSA_ASSIGN_RESERVED_FIRST (0x2UL << 0)
-	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID2_TSA_ASSIGN_RESERVED_LAST (0xffffUL << 0)
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID2_TSA_ASSIGN_RESERVED_LAST (0xffUL << 0)
 	u8 queue_id2_pri_lvl;
 	u8 queue_id2_bw_weight;
 	u8 queue_id3;
@@ -2412,7 +2439,7 @@ struct hwrm_queue_cos2bw_cfg_input {
 	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID3_TSA_ASSIGN_SP      (0x0UL << 0)
 	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID3_TSA_ASSIGN_ETS     (0x1UL << 0)
 	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID3_TSA_ASSIGN_RESERVED_FIRST (0x2UL << 0)
-	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID3_TSA_ASSIGN_RESERVED_LAST (0xffffUL << 0)
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID3_TSA_ASSIGN_RESERVED_LAST (0xffUL << 0)
 	u8 queue_id3_pri_lvl;
 	u8 queue_id3_bw_weight;
 	u8 queue_id4;
@@ -2422,7 +2449,7 @@ struct hwrm_queue_cos2bw_cfg_input {
 	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID4_TSA_ASSIGN_SP      (0x0UL << 0)
 	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID4_TSA_ASSIGN_ETS     (0x1UL << 0)
 	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID4_TSA_ASSIGN_RESERVED_FIRST (0x2UL << 0)
-	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID4_TSA_ASSIGN_RESERVED_LAST (0xffffUL << 0)
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID4_TSA_ASSIGN_RESERVED_LAST (0xffUL << 0)
 	u8 queue_id4_pri_lvl;
 	u8 queue_id4_bw_weight;
 	u8 queue_id5;
@@ -2432,7 +2459,7 @@ struct hwrm_queue_cos2bw_cfg_input {
 	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID5_TSA_ASSIGN_SP      (0x0UL << 0)
 	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID5_TSA_ASSIGN_ETS     (0x1UL << 0)
 	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID5_TSA_ASSIGN_RESERVED_FIRST (0x2UL << 0)
-	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID5_TSA_ASSIGN_RESERVED_LAST (0xffffUL << 0)
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID5_TSA_ASSIGN_RESERVED_LAST (0xffUL << 0)
 	u8 queue_id5_pri_lvl;
 	u8 queue_id5_bw_weight;
 	u8 queue_id6;
@@ -2442,7 +2469,7 @@ struct hwrm_queue_cos2bw_cfg_input {
 	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID6_TSA_ASSIGN_SP      (0x0UL << 0)
 	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID6_TSA_ASSIGN_ETS     (0x1UL << 0)
 	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID6_TSA_ASSIGN_RESERVED_FIRST (0x2UL << 0)
-	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID6_TSA_ASSIGN_RESERVED_LAST (0xffffUL << 0)
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID6_TSA_ASSIGN_RESERVED_LAST (0xffUL << 0)
 	u8 queue_id6_pri_lvl;
 	u8 queue_id6_bw_weight;
 	u8 queue_id7;
@@ -2452,7 +2479,7 @@ struct hwrm_queue_cos2bw_cfg_input {
 	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID7_TSA_ASSIGN_SP      (0x0UL << 0)
 	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID7_TSA_ASSIGN_ETS     (0x1UL << 0)
 	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID7_TSA_ASSIGN_RESERVED_FIRST (0x2UL << 0)
-	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID7_TSA_ASSIGN_RESERVED_LAST (0xffffUL << 0)
+	#define QUEUE_COS2BW_CFG_REQ_QUEUE_ID7_TSA_ASSIGN_RESERVED_LAST (0xffUL << 0)
 	u8 queue_id7_pri_lvl;
 	u8 queue_id7_bw_weight;
 	u8 unused_1[5];
@@ -3150,7 +3177,7 @@ struct hwrm_cfa_l2_filter_cfg_output {
 };
 
 /* hwrm_cfa_l2_set_rx_mask */
-/* Input (40 bytes) */
+/* Input (56 bytes) */
 struct hwrm_cfa_l2_set_rx_mask_input {
 	__le16 req_type;
 	__le16 cmpl_ring;
@@ -3165,9 +3192,15 @@ struct hwrm_cfa_l2_set_rx_mask_input {
 	#define CFA_L2_SET_RX_MASK_REQ_MASK_BCAST		    0x8UL
 	#define CFA_L2_SET_RX_MASK_REQ_MASK_PROMISCUOUS	    0x10UL
 	#define CFA_L2_SET_RX_MASK_REQ_MASK_OUTERMOST		    0x20UL
+	#define CFA_L2_SET_RX_MASK_REQ_MASK_VLANONLY		    0x40UL
+	#define CFA_L2_SET_RX_MASK_REQ_MASK_VLAN_NONVLAN	    0x80UL
+	#define CFA_L2_SET_RX_MASK_REQ_MASK_ANYVLAN_NONVLAN	    0x100UL
 	__le64 mc_tbl_addr;
 	__le32 num_mc_entries;
 	__le32 unused_0;
+	__le64 vlan_tag_tbl_addr;
+	__le32 num_vlan_tags;
+	__le32 unused_1;
 };
 
 /* Output (16 bytes) */
-- 
1.8.3.1
