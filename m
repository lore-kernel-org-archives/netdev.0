From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 4/5 net-next] cnic: Include bnx2x.h
Date: Thu, 6 Dec 2012 12:33:11 -0800
Message-ID: <1354825992-8547-4-git-send-email-mchan@broadcom.com>
References: <1354825992-8547-1-git-send-email-mchan@broadcom.com>
 <1354825992-8547-2-git-send-email-mchan@broadcom.com>
 <1354825992-8547-3-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4806 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1422826Ab2LFUSA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Dec 2012 15:18:00 -0500
In-Reply-To: <1354825992-8547-3-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

by removing duplicate symbols and removing some redundant code.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/cnic.c |   50 +++++++++++++--------------------
 drivers/net/ethernet/broadcom/cnic.h |   16 -----------
 2 files changed, 20 insertions(+), 46 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/cnic.c b/drivers/net/ethernet/broadcom/cnic.c
index 5778098..b865093 100644
--- a/drivers/net/ethernet/broadcom/cnic.c
+++ b/drivers/net/ethernet/broadcom/cnic.c
@@ -42,6 +42,7 @@
 
 #include "cnic_if.h"
 #include "bnx2.h"
+#include "bnx2x/bnx2x.h"
 #include "bnx2x/bnx2x_reg.h"
 #include "bnx2x/bnx2x_fw_defs.h"
 #include "bnx2x/bnx2x_hsi.h"
@@ -51,10 +52,10 @@
 #include "cnic.h"
 #include "cnic_defs.h"
 
-#define DRV_MODULE_NAME		"cnic"
+#define CNIC_MODULE_NAME	"cnic"
 
 static char version[] =
-	"Broadcom NetXtreme II CNIC Driver " DRV_MODULE_NAME " v" CNIC_MODULE_VERSION " (" CNIC_MODULE_RELDATE ")\n";
+	"Broadcom NetXtreme II CNIC Driver " CNIC_MODULE_NAME " v" CNIC_MODULE_VERSION " (" CNIC_MODULE_RELDATE ")\n";
 
 MODULE_AUTHOR("Michael Chan <mchan@broadcom.com> and John(Zongxi) "
 	      "Chen (zongxi@broadcom.com");
@@ -1234,8 +1235,6 @@ static int cnic_alloc_bnx2x_resc(struct cnic_dev *dev)
 	int i, j, n, ret, pages;
 	struct cnic_dma *kwq_16_dma = &cp->kwq_16_data_info;
 
-	cp->iro_arr = ethdev->iro_arr;
-
 	cp->max_cid_space = MAX_ISCSI_TBL_SZ;
 	cp->iscsi_start_cid = start_cid;
 	cp->fcoe_start_cid = start_cid + MAX_ISCSI_TBL_SZ;
@@ -1430,6 +1429,7 @@ static void cnic_reply_bnx2x_kcqes(struct cnic_dev *dev, int ulp_type,
 static int cnic_bnx2x_iscsi_init1(struct cnic_dev *dev, struct kwqe *kwqe)
 {
 	struct cnic_local *cp = dev->cnic_priv;
+	struct bnx2x *bp = netdev_priv(dev->netdev);
 	struct iscsi_kwqe_init1 *req1 = (struct iscsi_kwqe_init1 *) kwqe;
 	int hq_bds, pages;
 	u32 pfid = cp->pfid;
@@ -1512,6 +1512,7 @@ static int cnic_bnx2x_iscsi_init2(struct cnic_dev *dev, struct kwqe *kwqe)
 {
 	struct iscsi_kwqe_init2 *req2 = (struct iscsi_kwqe_init2 *) kwqe;
 	struct cnic_local *cp = dev->cnic_priv;
+	struct bnx2x *bp = netdev_priv(dev->netdev);
 	u32 pfid = cp->pfid;
 	struct iscsi_kcqe kcqe;
 	struct kcqe *cqes[1];
@@ -2048,6 +2049,7 @@ static void cnic_init_storm_conn_bufs(struct cnic_dev *dev,
 static void cnic_init_bnx2x_mac(struct cnic_dev *dev)
 {
 	struct cnic_local *cp = dev->cnic_priv;
+	struct bnx2x *bp = netdev_priv(dev->netdev);
 	u32 pfid = cp->pfid;
 	u8 *mac = dev->mac_addr;
 
@@ -2084,6 +2086,7 @@ static void cnic_init_bnx2x_mac(struct cnic_dev *dev)
 static void cnic_bnx2x_set_tcp_timestamp(struct cnic_dev *dev, int tcp_ts)
 {
 	struct cnic_local *cp = dev->cnic_priv;
+	struct bnx2x *bp = netdev_priv(dev->netdev);
 	u8 xstorm_flags = XSTORM_L5CM_TCP_FLAGS_WND_SCL_EN;
 	u16 tstorm_flags = 0;
 
@@ -2103,6 +2106,7 @@ static int cnic_bnx2x_connect(struct cnic_dev *dev, struct kwqe *wqes[],
 			      u32 num, int *work)
 {
 	struct cnic_local *cp = dev->cnic_priv;
+	struct bnx2x *bp = netdev_priv(dev->netdev);
 	struct l4_kwq_connect_req1 *kwqe1 =
 		(struct l4_kwq_connect_req1 *) wqes[0];
 	struct l4_kwq_connect_req3 *kwqe3;
@@ -4209,6 +4213,7 @@ static void cnic_cm_stop_bnx2x_hw(struct cnic_dev *dev)
 static int cnic_cm_init_bnx2x_hw(struct cnic_dev *dev)
 {
 	struct cnic_local *cp = dev->cnic_priv;
+	struct bnx2x *bp = netdev_priv(dev->netdev);
 	u32 pfid = cp->pfid;
 	u32 port = CNIC_PORT(cp);
 
@@ -4852,6 +4857,7 @@ static inline void cnic_storm_memset_hc_disable(struct cnic_dev *dev,
 						u16 sb_id, u8 sb_index,
 						u8 disable)
 {
+	struct bnx2x *bp = netdev_priv(dev->netdev);
 
 	u32 addr = BAR_CSTRORM_INTMEM +
 			CSTORM_STATUS_BLOCK_DATA_OFFSET(sb_id) +
@@ -4869,6 +4875,7 @@ static inline void cnic_storm_memset_hc_disable(struct cnic_dev *dev,
 static void cnic_enable_bnx2x_int(struct cnic_dev *dev)
 {
 	struct cnic_local *cp = dev->cnic_priv;
+	struct bnx2x *bp = netdev_priv(dev->netdev);
 	u8 sb_id = cp->status_blk_num;
 
 	CNIC_WR8(dev, BAR_CSTRORM_INTMEM +
@@ -5018,6 +5025,7 @@ static void cnic_init_bnx2x_rx_ring(struct cnic_dev *dev,
 static void cnic_init_bnx2x_kcq(struct cnic_dev *dev)
 {
 	struct cnic_local *cp = dev->cnic_priv;
+	struct bnx2x *bp = netdev_priv(dev->netdev);
 	u32 pfid = cp->pfid;
 
 	cp->kcq1.io_addr = BAR_CSTRORM_INTMEM +
@@ -5056,37 +5064,17 @@ static void cnic_init_bnx2x_kcq(struct cnic_dev *dev)
 static int cnic_start_bnx2x_hw(struct cnic_dev *dev)
 {
 	struct cnic_local *cp = dev->cnic_priv;
+	struct bnx2x *bp = netdev_priv(dev->netdev);
 	struct cnic_eth_dev *ethdev = cp->ethdev;
-	int func = CNIC_FUNC(cp), ret;
+	int func, ret;
 	u32 pfid;
 
 	dev->stats_addr = ethdev->addr_drv_info_to_mcp;
-	cp->port_mode = CHIP_PORT_MODE_NONE;
-
-	if (BNX2X_CHIP_IS_E2_PLUS(cp->chip_id)) {
-		u32 val;
-
-		pci_read_config_dword(dev->pcidev, PCICFG_ME_REGISTER, &val);
-		cp->func = (u8) ((val & ME_REG_ABS_PF_NUM) >>
-				 ME_REG_ABS_PF_NUM_SHIFT);
-		func = CNIC_FUNC(cp);
+	cp->port_mode = bp->common.chip_port_mode;
+	cp->pfid = bp->pfid;
+	cp->func = bp->pf_num;
 
-		val = CNIC_RD(dev, MISC_REG_PORT4MODE_EN_OVWR);
-		if (!(val & 1))
-			val = CNIC_RD(dev, MISC_REG_PORT4MODE_EN);
-		else
-			val = (val >> 1) & 1;
-
-		if (val) {
-			cp->port_mode = CHIP_4_PORT_MODE;
-			cp->pfid = func >> 1;
-		} else {
-			cp->port_mode = CHIP_2_PORT_MODE;
-			cp->pfid = func & 0x6;
-		}
-	} else {
-		cp->pfid = func;
-	}
+	func = CNIC_FUNC(cp);
 	pfid = cp->pfid;
 
 	ret = cnic_init_id_tbl(&cp->cid_tbl, MAX_ISCSI_TBL_SZ,
@@ -5153,6 +5141,7 @@ static int cnic_start_bnx2x_hw(struct cnic_dev *dev)
 static void cnic_init_rings(struct cnic_dev *dev)
 {
 	struct cnic_local *cp = dev->cnic_priv;
+	struct bnx2x *bp = netdev_priv(dev->netdev);
 	struct cnic_uio_dev *udev = cp->udev;
 
 	if (test_bit(CNIC_LCL_FL_RINGS_INITED, &cp->cnic_local_flags))
@@ -5353,6 +5342,7 @@ static void cnic_stop_bnx2_hw(struct cnic_dev *dev)
 static void cnic_stop_bnx2x_hw(struct cnic_dev *dev)
 {
 	struct cnic_local *cp = dev->cnic_priv;
+	struct bnx2x *bp = netdev_priv(dev->netdev);
 	u32 hc_index = HC_INDEX_ISCSI_EQ_CONS;
 	u32 sb_id = cp->status_blk_num;
 	u32 idx_off, syn_off;
diff --git a/drivers/net/ethernet/broadcom/cnic.h b/drivers/net/ethernet/broadcom/cnic.h
index 6fa7a98..62c6706 100644
--- a/drivers/net/ethernet/broadcom/cnic.h
+++ b/drivers/net/ethernet/broadcom/cnic.h
@@ -186,14 +186,6 @@ struct kcq_info {
 	u16		(*hw_idx)(u16);
 };
 
-struct iro {
-	u32 base;
-	u16 m1;
-	u16 m2;
-	u16 m3;
-	u16 size;
-};
-
 struct cnic_uio_dev {
 	struct uio_info		cnic_uinfo;
 	u32			uio_dev;
@@ -241,9 +233,6 @@ struct cnic_local {
 	u16		rx_cons;
 	u16		tx_cons;
 
-	const struct iro	*iro_arr;
-#define IRO (((struct cnic_local *) dev->cnic_priv)->iro_arr)
-
 	struct cnic_dma		kwq_info;
 	struct kwqe		**kwq;
 
@@ -316,9 +305,6 @@ struct cnic_local {
 	int			func;
 	u32			pfid;
 	u8			port_mode;
-#define CHIP_4_PORT_MODE	0
-#define CHIP_2_PORT_MODE	1
-#define CHIP_PORT_MODE_NONE	2
 
 	u32			shmem_base;
 
@@ -420,8 +406,6 @@ struct bnx2x_bd_chain_next {
 	 BNX2X_CHIP_IS_57840(x))
 #define BNX2X_CHIP_IS_E2_PLUS(x) (BNX2X_CHIP_IS_E2(x) || BNX2X_CHIP_IS_E3(x))
 
-#define IS_E1H_OFFSET       		BNX2X_CHIP_IS_E1H(cp->chip_id)
-
 #define BNX2X_RX_DESC_CNT		(BNX2_PAGE_SIZE / \
 					 sizeof(struct eth_rx_bd))
 #define BNX2X_MAX_RX_DESC_CNT		(BNX2X_RX_DESC_CNT - 2)
-- 
1.7.1
