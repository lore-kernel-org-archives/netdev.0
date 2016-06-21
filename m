From: Yisen Zhuang <Yisen.Zhuang@huawei.com>
Subject: [PATCH net-next 17/19] net: hns: fix sbm default parameters config
 error
Date: Tue, 21 Jun 2016 11:56:37 +0800
Message-ID: <1466481399-70080-18-git-send-email-Yisen.Zhuang@huawei.com>
References: <1466481399-70080-1-git-send-email-Yisen.Zhuang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: ivecera@redhat.com, andrew@lunn.ch, fengguang.wu@intel.com,
 liguozhu@huawei.com, arnd@arndb.de, charles.chenxin@huawei.com,
 linux-kernel@vger.kernel.org, linuxarm@huawei.com, geliangtang@163.com,
 huangdaode@hisilicon.com, netdev@vger.kernel.org,
 andriy.shevchenko@linux.intel.com, linux-arm-kernel@lists.infradead.org
To: <davem@davemloft.net>, <yisen.zhuang@huawei.com>, <salil.mehta@huawei.com>,
 <yankejian@huawei.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1466481399-70080-1-git-send-email-Yisen.Zhuang@huawei.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

From: Daode Huang <huangdaode@hisilicon.com>

The default sbm config parameter leaves little buffer when there is heavy
traffic, which will cause packets drop. This patch changes them to make
enough buffers for handling packets.

Signed-off-by: Daode Huang <huangdaode@hisilicon.com>
Signed-off-by: Yisen Zhuang <Yisen.Zhuang@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c | 40 ++++++++++++++--------
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h  | 16 +++++++--
 2 files changed, 39 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
index 7f5c248..67e8e13 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
@@ -516,10 +516,10 @@ static void hns_dsafv2_sbm_bp_wl_cfg(struct dsaf_device *dsaf_dev)
 		o_sbm_bp_cfg = dsaf_read_dev(dsaf_dev, reg);
 		dsaf_set_field(o_sbm_bp_cfg,
 			       DSAFV2_SBM_CFG3_SET_BUF_NUM_NO_PFC_M,
-			       DSAFV2_SBM_CFG3_SET_BUF_NUM_NO_PFC_S, 110);
+			       DSAFV2_SBM_CFG3_SET_BUF_NUM_NO_PFC_S, 48);
 		dsaf_set_field(o_sbm_bp_cfg,
 			       DSAFV2_SBM_CFG3_RESET_BUF_NUM_NO_PFC_M,
-			       DSAFV2_SBM_CFG3_RESET_BUF_NUM_NO_PFC_S, 160);
+			       DSAFV2_SBM_CFG3_RESET_BUF_NUM_NO_PFC_S, 80);
 		dsaf_write_dev(dsaf_dev, reg, o_sbm_bp_cfg);
 
 		/* for no enable pfc mode */
@@ -527,29 +527,39 @@ static void hns_dsafv2_sbm_bp_wl_cfg(struct dsaf_device *dsaf_dev)
 		o_sbm_bp_cfg = dsaf_read_dev(dsaf_dev, reg);
 		dsaf_set_field(o_sbm_bp_cfg,
 			       DSAFV2_SBM_CFG4_SET_BUF_NUM_NO_PFC_M,
-			       DSAFV2_SBM_CFG4_SET_BUF_NUM_NO_PFC_S, 128);
+			       DSAFV2_SBM_CFG4_SET_BUF_NUM_NO_PFC_S, 192);
 		dsaf_set_field(o_sbm_bp_cfg,
 			       DSAFV2_SBM_CFG4_RESET_BUF_NUM_NO_PFC_M,
-			       DSAFV2_SBM_CFG4_RESET_BUF_NUM_NO_PFC_S, 192);
+			       DSAFV2_SBM_CFG4_RESET_BUF_NUM_NO_PFC_S, 240);
 		dsaf_write_dev(dsaf_dev, reg, o_sbm_bp_cfg);
 	}
 
 	/* PPE */
-	reg = DSAF_SBM_BP_CFG_2_PPE_REG_0_REG + 0x80 * i;
-	o_sbm_bp_cfg = dsaf_read_dev(dsaf_dev, reg);
-	dsaf_set_field(o_sbm_bp_cfg, DSAFV2_SBM_CFG2_SET_BUF_NUM_M,
-		       DSAFV2_SBM_CFG2_SET_BUF_NUM_S, 10);
-	dsaf_set_field(o_sbm_bp_cfg, DSAFV2_SBM_CFG2_RESET_BUF_NUM_M,
-		       DSAFV2_SBM_CFG2_RESET_BUF_NUM_S, 12);
-	dsaf_write_dev(dsaf_dev, reg, o_sbm_bp_cfg);
+	for (i = 0; i < DSAFV2_SBM_PPE_CHN; i++) {
+		reg = DSAF_SBM_BP_CFG_2_PPE_REG_0_REG + 0x80 * i;
+		o_sbm_bp_cfg = dsaf_read_dev(dsaf_dev, reg);
+		dsaf_set_field(o_sbm_bp_cfg,
+			       DSAFV2_SBM_CFG2_PPE_SET_BUF_NUM_M,
+			       DSAFV2_SBM_CFG2_PPE_SET_BUF_NUM_S, 2);
+		dsaf_set_field(o_sbm_bp_cfg,
+			       DSAFV2_SBM_CFG2_PPE_RESET_BUF_NUM_M,
+			       DSAFV2_SBM_CFG2_PPE_RESET_BUF_NUM_S, 3);
+		dsaf_set_field(o_sbm_bp_cfg,
+			       DSAFV2_SBM_CFG2_PPE_CFG_USEFUL_NUM_M,
+			       DSAFV2_SBM_CFG2_PPE_CFG_USEFUL_NUM_S, 52);
+		dsaf_write_dev(dsaf_dev, reg, o_sbm_bp_cfg);
+	}
+
 	/* RoCEE */
 	for (i = 0; i < DASFV2_ROCEE_CRD_NUM; i++) {
 		reg = DSAFV2_SBM_BP_CFG_2_ROCEE_REG_0_REG + 0x80 * i;
 		o_sbm_bp_cfg = dsaf_read_dev(dsaf_dev, reg);
-		dsaf_set_field(o_sbm_bp_cfg, DSAFV2_SBM_CFG2_SET_BUF_NUM_M,
-			       DSAFV2_SBM_CFG2_SET_BUF_NUM_S, 2);
-		dsaf_set_field(o_sbm_bp_cfg, DSAFV2_SBM_CFG2_RESET_BUF_NUM_M,
-			       DSAFV2_SBM_CFG2_RESET_BUF_NUM_S, 4);
+		dsaf_set_field(o_sbm_bp_cfg,
+			       DSAFV2_SBM_CFG2_ROCEE_SET_BUF_NUM_M,
+			       DSAFV2_SBM_CFG2_ROCEE_SET_BUF_NUM_S, 2);
+		dsaf_set_field(o_sbm_bp_cfg,
+			       DSAFV2_SBM_CFG2_ROCEE_RESET_BUF_NUM_M,
+			       DSAFV2_SBM_CFG2_ROCEE_RESET_BUF_NUM_S, 4);
 		dsaf_write_dev(dsaf_dev, reg, o_sbm_bp_cfg);
 	}
 }
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h
index e35d0cb..235f744 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h
@@ -32,7 +32,7 @@
 #define DSAFV2_SBM_NUM		8
 #define DSAFV2_SBM_XGE_CHN    6
 #define DSAFV2_SBM_PPE_CHN    1
-#define DASFV2_ROCEE_CRD_NUM  8
+#define DASFV2_ROCEE_CRD_NUM  1
 
 #define DSAF_VOQ_NUM		DSAF_NODE_NUM
 #define DSAF_INODE_NUM		DSAF_NODE_NUM
@@ -178,7 +178,7 @@
 #define DSAF_SBM_BP_CFG_2_XGE_REG_0_REG		0x200C
 #define DSAF_SBM_BP_CFG_2_PPE_REG_0_REG		0x230C
 #define DSAF_SBM_BP_CFG_2_ROCEE_REG_0_REG	0x260C
-#define DSAFV2_SBM_BP_CFG_2_ROCEE_REG_0_REG		 0x238C
+#define DSAFV2_SBM_BP_CFG_2_ROCEE_REG_0_REG	0x238C
 #define DSAF_SBM_FREE_CNT_0_0_REG		0x2010
 #define DSAF_SBM_FREE_CNT_1_0_REG		0x2014
 #define DSAF_SBM_BP_CNT_0_0_REG			0x2018
@@ -796,6 +796,18 @@
 #define DSAFV2_SBM_CFG4_RESET_BUF_NUM_NO_PFC_S 9
 #define DSAFV2_SBM_CFG4_RESET_BUF_NUM_NO_PFC_M (((1ULL << 9) - 1) << 9)
 
+#define DSAFV2_SBM_CFG2_ROCEE_SET_BUF_NUM_S 0
+#define DSAFV2_SBM_CFG2_ROCEE_SET_BUF_NUM_M (((1ULL << 8) - 1) << 0)
+#define DSAFV2_SBM_CFG2_ROCEE_RESET_BUF_NUM_S 8
+#define DSAFV2_SBM_CFG2_ROCEE_RESET_BUF_NUM_M (((1ULL << 8) - 1) << 8)
+
+#define DSAFV2_SBM_CFG2_PPE_SET_BUF_NUM_S (0)
+#define DSAFV2_SBM_CFG2_PPE_SET_BUF_NUM_M (((1ULL << 6) - 1) << 0)
+#define DSAFV2_SBM_CFG2_PPE_RESET_BUF_NUM_S (6)
+#define DSAFV2_SBM_CFG2_PPE_RESET_BUF_NUM_M (((1ULL << 6) - 1) << 6)
+#define DSAFV2_SBM_CFG2_PPE_CFG_USEFUL_NUM_S (12)
+#define DSAFV2_SBM_CFG2_PPE_CFG_USEFUL_NUM_M (((1ULL << 6) - 1) << 12)
+
 #define DSAF_TBL_TCAM_ADDR_S 0
 #define DSAF_TBL_TCAM_ADDR_M ((1ULL << 9) - 1)
 
-- 
1.9.1
