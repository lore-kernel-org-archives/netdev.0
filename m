From: Yunsheng Lin <linyunsheng@huawei.com>
Subject: [PATCH net-next 4/7] net: hns3: Consistently using GENMASK in hns3 driver
Date: Mon, 9 Oct 2017 15:43:58 +0800
Message-ID: <1507535041-204956-5-git-send-email-linyunsheng@huawei.com>
References: <1507535041-204956-1-git-send-email-linyunsheng@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <huangdaode@hisilicon.com>, <xuwei5@hisilicon.com>,
        <liguozhu@hisilicon.com>, <Yisen.Zhuang@huawei.com>,
        <gabriele.paoloni@huawei.com>, <john.garry@huawei.com>,
        <linuxarm@huawei.com>, <yisen.zhuang@huawei.com>,
        <salil.mehta@huawei.com>, <lipeng321@huawei.com>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1507535041-204956-1-git-send-email-linyunsheng@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch uses GENMASK to generate bit mask whenever
possible in hns3 driver.

Signed-off-by: Yunsheng Lin <linyunsheng@huawei.com>
---
 .../net/ethernet/hisilicon/hns3/hns3pf/hclge_cmd.h | 48 +++++++++++-----------
 .../ethernet/hisilicon/hns3/hns3pf/hclge_main.h    |  4 +-
 2 files changed, 26 insertions(+), 26 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_cmd.h b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_cmd.h
index 6b6d28e..9cff7db 100644
--- a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_cmd.h
+++ b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_cmd.h
@@ -250,11 +250,11 @@ struct hclge_ctrl_vector_chain {
 	u8 int_vector_id;
 	u8 int_cause_num;
 #define HCLGE_INT_TYPE_S	0
-#define HCLGE_INT_TYPE_M	0x3
+#define HCLGE_INT_TYPE_M	GENMASK(1, 0)
 #define HCLGE_TQP_ID_S		2
-#define HCLGE_TQP_ID_M		(0x7ff << HCLGE_TQP_ID_S)
+#define HCLGE_TQP_ID_M		GENMASK(12, 2)
 #define HCLGE_INT_GL_IDX_S	13
-#define HCLGE_INT_GL_IDX_M	(0x3 << HCLGE_INT_GL_IDX_S)
+#define HCLGE_INT_GL_IDX_M	GENMASK(14, 13)
 	__le16 tqp_type_and_id[HCLGE_VECTOR_ELEMENTS_PER_CMD];
 	u8 vfid;
 	u8 rsv;
@@ -372,28 +372,28 @@ struct hclge_pf_res {
 };
 
 #define HCLGE_CFG_OFFSET_S	0
-#define HCLGE_CFG_OFFSET_M	0xfffff /* Byte (8-10.3) */
+#define HCLGE_CFG_OFFSET_M	GENMASK(19, 0)
 #define HCLGE_CFG_RD_LEN_S	24
-#define HCLGE_CFG_RD_LEN_M	(0xf << HCLGE_CFG_RD_LEN_S)
+#define HCLGE_CFG_RD_LEN_M	GENMASK(27, 24)
 #define HCLGE_CFG_RD_LEN_BYTES	16
 #define HCLGE_CFG_RD_LEN_UNIT	4
 
 #define HCLGE_CFG_VMDQ_S	0
-#define HCLGE_CFG_VMDQ_M	(0xff << HCLGE_CFG_VMDQ_S)
+#define HCLGE_CFG_VMDQ_M	GENMASK(7, 0)
 #define HCLGE_CFG_TC_NUM_S	8
-#define HCLGE_CFG_TC_NUM_M	(0xff << HCLGE_CFG_TC_NUM_S)
+#define HCLGE_CFG_TC_NUM_M	GENMASK(15, 8)
 #define HCLGE_CFG_TQP_DESC_N_S	16
-#define HCLGE_CFG_TQP_DESC_N_M	(0xffff << HCLGE_CFG_TQP_DESC_N_S)
+#define HCLGE_CFG_TQP_DESC_N_M	GENMASK(31, 16)
 #define HCLGE_CFG_PHY_ADDR_S	0
-#define HCLGE_CFG_PHY_ADDR_M	(0x1f << HCLGE_CFG_PHY_ADDR_S)
+#define HCLGE_CFG_PHY_ADDR_M	GENMASK(4, 0)
 #define HCLGE_CFG_MEDIA_TP_S	8
-#define HCLGE_CFG_MEDIA_TP_M	(0xff << HCLGE_CFG_MEDIA_TP_S)
+#define HCLGE_CFG_MEDIA_TP_M	GENMASK(15, 8)
 #define HCLGE_CFG_RX_BUF_LEN_S	16
-#define HCLGE_CFG_RX_BUF_LEN_M	(0xffff << HCLGE_CFG_RX_BUF_LEN_S)
+#define HCLGE_CFG_RX_BUF_LEN_M	GENMASK(31, 16)
 #define HCLGE_CFG_MAC_ADDR_H_S	0
-#define HCLGE_CFG_MAC_ADDR_H_M	(0xffff << HCLGE_CFG_MAC_ADDR_H_S)
+#define HCLGE_CFG_MAC_ADDR_H_M	GENMASK(15, 0)
 #define HCLGE_CFG_DEFAULT_SPEED_S	16
-#define HCLGE_CFG_DEFAULT_SPEED_M	(0xff << HCLGE_CFG_DEFAULT_SPEED_S)
+#define HCLGE_CFG_DEFAULT_SPEED_M	GENMASK(23, 16)
 
 struct hclge_cfg_param {
 	__le32 offset;
@@ -441,9 +441,9 @@ struct hclge_rss_indirection_table {
 };
 
 #define HCLGE_RSS_TC_OFFSET_S		0
-#define HCLGE_RSS_TC_OFFSET_M		(0x3ff << HCLGE_RSS_TC_OFFSET_S)
+#define HCLGE_RSS_TC_OFFSET_M		GENMASK(9, 0)
 #define HCLGE_RSS_TC_SIZE_S		12
-#define HCLGE_RSS_TC_SIZE_M		(0x7 << HCLGE_RSS_TC_SIZE_S)
+#define HCLGE_RSS_TC_SIZE_M		GENMASK(14, 12)
 #define HCLGE_RSS_TC_VALID_B		15
 struct hclge_rss_tc_mode {
 	u16 rss_tc_mode[HCLGE_MAX_TC_NUM];
@@ -501,7 +501,7 @@ struct hclge_config_mac_mode {
 };
 
 #define HCLGE_CFG_SPEED_S		0
-#define HCLGE_CFG_SPEED_M		(0x3f << HCLGE_CFG_SPEED_S)
+#define HCLGE_CFG_SPEED_M		GENMASK(5, 0)
 
 #define HCLGE_CFG_DUPLEX_B		7
 #define HCLGE_CFG_DUPLEX_M		BIT(HCLGE_CFG_DUPLEX_B)
@@ -518,7 +518,7 @@ struct hclge_config_mac_speed_dup {
 #define HCLGE_QUERY_AN_B		0
 #define HCLGE_QUERY_DUPLEX_B		2
 
-#define HCLGE_QUERY_SPEED_M		(0x1f << HCLGE_QUERY_SPEED_S)
+#define HCLGE_QUERY_SPEED_M		GENMASK(4, 0)
 #define HCLGE_QUERY_AN_M		BIT(HCLGE_QUERY_AN_B)
 #define HCLGE_QUERY_DUPLEX_M		BIT(HCLGE_QUERY_DUPLEX_B)
 
@@ -528,7 +528,7 @@ struct hclge_query_an_speed_dup {
 	u8 rsv[23];
 };
 
-#define HCLGE_RING_ID_MASK		0x3ff
+#define HCLGE_RING_ID_MASK		GENMASK(9, 0)
 #define HCLGE_TQP_ENABLE_B		0
 
 #define HCLGE_MAC_CFG_AN_EN_B		0
@@ -565,9 +565,9 @@ enum hclge_mac_vlan_tbl_opcode {
 #define HCLGE_MAC_EPORT_SW_EN_B		0xc
 #define HCLGE_MAC_EPORT_TYPE_B		0xb
 #define HCLGE_MAC_EPORT_VFID_S		0x3
-#define HCLGE_MAC_EPORT_VFID_M		(0xff << HCLGE_MAC_EPORT_VFID_S)
+#define HCLGE_MAC_EPORT_VFID_M		GENMASK(10, 3)
 #define HCLGE_MAC_EPORT_PFID_S		0x0
-#define HCLGE_MAC_EPORT_PFID_M		(0x7 << HCLGE_MAC_EPORT_PFID_S)
+#define HCLGE_MAC_EPORT_PFID_M		GENMASK(2, 0)
 struct hclge_mac_vlan_tbl_entry {
 	u8	flags;
 	u8      resp_code;
@@ -583,7 +583,7 @@ struct hclge_mac_vlan_tbl_entry {
 };
 
 #define HCLGE_CFG_MTA_MAC_SEL_S		0x0
-#define HCLGE_CFG_MTA_MAC_SEL_M		(0x3 << HCLGE_CFG_MTA_MAC_SEL_S)
+#define HCLGE_CFG_MTA_MAC_SEL_M		GENMASK(1, 0)
 #define HCLGE_CFG_MTA_MAC_EN_B		0x7
 struct hclge_mta_filter_mode {
 	u8	dmac_sel_en; /* Use lowest 2 bit as sel_mode, bit 7 as enable */
@@ -599,7 +599,7 @@ struct hclge_cfg_func_mta_filter {
 
 #define HCLGE_CFG_MTA_ITEM_ACCEPT_B	0x0
 #define HCLGE_CFG_MTA_ITEM_IDX_S	0x0
-#define HCLGE_CFG_MTA_ITEM_IDX_M	(0xfff << HCLGE_CFG_MTA_ITEM_IDX_S)
+#define HCLGE_CFG_MTA_ITEM_IDX_M	GENMASK(11, 0)
 struct hclge_cfg_func_mta_item {
 	u16	item_idx; /* Only used lowest 12 bit */
 	u8      accept;   /* Only used lowest 1 bit */
@@ -670,10 +670,10 @@ struct hclge_cfg_tx_queue_pointer {
 };
 
 #define HCLGE_TSO_MSS_MIN_S	0
-#define HCLGE_TSO_MSS_MIN_M	(0x3FFF << HCLGE_TSO_MSS_MIN_S)
+#define HCLGE_TSO_MSS_MIN_M	GENMASK(13, 0)
 
 #define HCLGE_TSO_MSS_MAX_S	16
-#define HCLGE_TSO_MSS_MAX_M	(0x3FFF << HCLGE_TSO_MSS_MAX_S)
+#define HCLGE_TSO_MSS_MAX_M	GENMASK(29, 16)
 
 struct hclge_cfg_tso_status {
 	__le16 tso_mss_min;
diff --git a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.h b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.h
index 7c66c00..79c1a06 100644
--- a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.h
+++ b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.h
@@ -32,7 +32,7 @@
 #define HCLGE_VECTOR_VF_OFFSET		0x100000
 
 #define HCLGE_RSS_IND_TBL_SIZE		512
-#define HCLGE_RSS_SET_BITMAP_MSK	0xffff
+#define HCLGE_RSS_SET_BITMAP_MSK	GENMASK(15, 0)
 #define HCLGE_RSS_KEY_SIZE		40
 #define HCLGE_RSS_HASH_ALGO_TOEPLITZ	0
 #define HCLGE_RSS_HASH_ALGO_SIMPLE	1
@@ -65,7 +65,7 @@
 #define HCLGE_PHY_CSS_REG		17
 
 #define HCLGE_PHY_MDIX_CTRL_S		(5)
-#define HCLGE_PHY_MDIX_CTRL_M		(3 << HCLGE_PHY_MDIX_CTRL_S)
+#define HCLGE_PHY_MDIX_CTRL_M		GENMASK(6, 5)
 
 #define HCLGE_PHY_MDIX_STATUS_B	(6)
 #define HCLGE_PHY_SPEED_DUP_RESOLVE_B	(11)
-- 
1.9.1
