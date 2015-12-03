From: Salil Mehta <salil.mehta@huawei.com>
Subject: [PATCH V7 net-next 5/5] net:hns: Add the init code to disable Hip06 "Hardware VLAN assist"
Date: Thu, 3 Dec 2015 12:17:57 +0000
Message-ID: <1449145077-9400-6-git-send-email-salil.mehta@huawei.com>
References: <1449145077-9400-1-git-send-email-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <davem@davemloft.net>, <robh+dt@kernel.org>, <pawel.moll@arm.com>,
	<mark.rutland@arm.com>, <paul.gortmaker@windriver.com>,
	<ijc+devicetree@hellion.org.uk>, <galak@codeaurora.org>,
	<catalin.marinas@arm.com>, <will.deacon@arm.com>, <arnd@arndb.de>,
	<liguozhu@hisilicon.com>, <yisen.zhuang@huawei.com>,
	<dingtianhong@huawei.com>, <zhangfei.gao@linaro.org>,
	<huangdaode@hisilicon.com>, <kenneth-lee-2012@foxmail.com>,
	<salil.mehta@huawei.com>, <mehta.salil.lnk@gmail.com>,
	<xuwei5@hisilicon.com>, <lisheng011@huawei.com>,
	<devicetree@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>, <netdev@vger.kernel.org>,
	<linuxarm@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1449145077-9400-1-git-send-email-salil.mehta@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds the initializzation code to disable the hardware
vlan support for VLAN Tag stripping by default for now.

Proper support of "hardware VLAN assitance" feature would
soon come in the next coming patches.

Signed-off-by: Salil Mehta <salil.mehta@huawei.com>
---

PATCH V7:
- This addresses the comment provided by Sergei Shtylyov
  <sergei.shtylyov@cogentembedded.com> related to the missing
  TABs and formating. Further, some more corrections related
  to missing TABs has been made in the same file.
  Link: https://lkml.org/lkml/2015/12/2/868

PATCH V6:
- No change over the earlier patch

PATCH V5:
- Minor merge/reject change resolved to application of previous patch

PATCH V4/V3/V2:
- No change over the initial floated patch

PATCH V1:
- Initial code to disable the hardware VLAN assist for now
---
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.c |    7 ++
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h |  103 +++++++++++----------
 2 files changed, 59 insertions(+), 51 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.c
index b5e4c44..f302ef9 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.c
@@ -176,6 +176,11 @@ static void hns_ppe_cnt_clr_ce(struct hns_ppe_cb *ppe_cb)
 			 PPE_CNT_CLR_CE_B, 1);
 }
 
+static void hns_ppe_set_vlan_strip(struct hns_ppe_cb *ppe_cb, int en)
+{
+	dsaf_write_dev(ppe_cb, PPEV2_VLAN_STRIP_EN_REG, en);
+}
+
 /**
  * hns_ppe_checksum_hw - set ppe checksum caculate
  * @ppe_device: ppe device
@@ -336,6 +341,8 @@ static void hns_ppe_init_hw(struct hns_ppe_cb *ppe_cb)
 	hns_ppe_cnt_clr_ce(ppe_cb);
 
 	if (!AE_IS_VER1(dsaf_dev->dsaf_ver)) {
+		hns_ppe_set_vlan_strip(ppe_cb, 0);
+
 		/* set default RSS key in h/w */
 		hns_ppe_set_rss_key(ppe_cb, ppe_cb->rss_key);
 
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h
index 98c163e..c4d7c26 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h
@@ -49,56 +49,56 @@
 #define DSAF_TCAM_SUM		512
 #define DSAF_LINE_SUM		(2048 * 14)
 
-#define DSAF_SUB_SC_NT_SRAM_CLK_SEL_REG                0x100
-#define DSAF_SUB_SC_HILINK3_CRG_CTRL0_REG              0x180
-#define DSAF_SUB_SC_HILINK3_CRG_CTRL1_REG              0x184
-#define DSAF_SUB_SC_HILINK3_CRG_CTRL2_REG              0x188
-#define DSAF_SUB_SC_HILINK3_CRG_CTRL3_REG              0x18C
-#define DSAF_SUB_SC_HILINK4_CRG_CTRL0_REG              0x190
-#define DSAF_SUB_SC_HILINK4_CRG_CTRL1_REG              0x194
-#define DSAF_SUB_SC_DSAF_CLK_EN_REG                    0x300
-#define DSAF_SUB_SC_DSAF_CLK_DIS_REG                   0x304
-#define DSAF_SUB_SC_NT_CLK_EN_REG                      0x308
-#define DSAF_SUB_SC_NT_CLK_DIS_REG                     0x30C
-#define DSAF_SUB_SC_XGE_CLK_EN_REG                     0x310
-#define DSAF_SUB_SC_XGE_CLK_DIS_REG                    0x314
-#define DSAF_SUB_SC_GE_CLK_EN_REG                      0x318
-#define DSAF_SUB_SC_GE_CLK_DIS_REG                     0x31C
-#define DSAF_SUB_SC_PPE_CLK_EN_REG                     0x320
-#define DSAF_SUB_SC_PPE_CLK_DIS_REG                    0x324
-#define DSAF_SUB_SC_RCB_PPE_COM_CLK_EN_REG             0x350
-#define DSAF_SUB_SC_RCB_PPE_COM_CLK_DIS_REG            0x354
-#define DSAF_SUB_SC_XBAR_RESET_REQ_REG                 0xA00
-#define DSAF_SUB_SC_XBAR_RESET_DREQ_REG                0xA04
-#define DSAF_SUB_SC_NT_RESET_REQ_REG                   0xA08
-#define DSAF_SUB_SC_NT_RESET_DREQ_REG                  0xA0C
-#define DSAF_SUB_SC_XGE_RESET_REQ_REG                  0xA10
-#define DSAF_SUB_SC_XGE_RESET_DREQ_REG                 0xA14
-#define DSAF_SUB_SC_GE_RESET_REQ0_REG                  0xA18
-#define DSAF_SUB_SC_GE_RESET_DREQ0_REG                 0xA1C
-#define DSAF_SUB_SC_GE_RESET_REQ1_REG                  0xA20
-#define DSAF_SUB_SC_GE_RESET_DREQ1_REG                 0xA24
-#define DSAF_SUB_SC_PPE_RESET_REQ_REG                  0xA48
-#define DSAF_SUB_SC_PPE_RESET_DREQ_REG                 0xA4C
-#define DSAF_SUB_SC_RCB_PPE_COM_RESET_REQ_REG          0xA88
-#define DSAF_SUB_SC_RCB_PPE_COM_RESET_DREQ_REG         0xA8C
-#define DSAF_SUB_SC_LIGHT_MODULE_DETECT_EN_REG         0x2060
-#define DSAF_SUB_SC_TCAM_MBIST_EN_REG                  0x2300
-#define DSAF_SUB_SC_DSAF_CLK_ST_REG                    0x5300
-#define DSAF_SUB_SC_NT_CLK_ST_REG                      0x5304
-#define DSAF_SUB_SC_XGE_CLK_ST_REG                     0x5308
-#define DSAF_SUB_SC_GE_CLK_ST_REG                      0x530C
-#define DSAF_SUB_SC_PPE_CLK_ST_REG                     0x5310
-#define DSAF_SUB_SC_ROCEE_CLK_ST_REG                   0x5314
-#define DSAF_SUB_SC_CPU_CLK_ST_REG                     0x5318
-#define DSAF_SUB_SC_RCB_PPE_COM_CLK_ST_REG             0x5328
-#define DSAF_SUB_SC_XBAR_RESET_ST_REG                  0x5A00
-#define DSAF_SUB_SC_NT_RESET_ST_REG                    0x5A04
-#define DSAF_SUB_SC_XGE_RESET_ST_REG                   0x5A08
-#define DSAF_SUB_SC_GE_RESET_ST0_REG                   0x5A0C
-#define DSAF_SUB_SC_GE_RESET_ST1_REG                   0x5A10
-#define DSAF_SUB_SC_PPE_RESET_ST_REG                   0x5A24
-#define DSAF_SUB_SC_RCB_PPE_COM_RESET_ST_REG           0x5A44
+#define DSAF_SUB_SC_NT_SRAM_CLK_SEL_REG			0x100
+#define DSAF_SUB_SC_HILINK3_CRG_CTRL0_REG		0x180
+#define DSAF_SUB_SC_HILINK3_CRG_CTRL1_REG		0x184
+#define DSAF_SUB_SC_HILINK3_CRG_CTRL2_REG		0x188
+#define DSAF_SUB_SC_HILINK3_CRG_CTRL3_REG		0x18C
+#define DSAF_SUB_SC_HILINK4_CRG_CTRL0_REG		0x190
+#define DSAF_SUB_SC_HILINK4_CRG_CTRL1_REG		0x194
+#define DSAF_SUB_SC_DSAF_CLK_EN_REG			0x300
+#define DSAF_SUB_SC_DSAF_CLK_DIS_REG			0x304
+#define DSAF_SUB_SC_NT_CLK_EN_REG			0x308
+#define DSAF_SUB_SC_NT_CLK_DIS_REG			0x30C
+#define DSAF_SUB_SC_XGE_CLK_EN_REG			0x310
+#define DSAF_SUB_SC_XGE_CLK_DIS_REG			0x314
+#define DSAF_SUB_SC_GE_CLK_EN_REG			0x318
+#define DSAF_SUB_SC_GE_CLK_DIS_REG			0x31C
+#define DSAF_SUB_SC_PPE_CLK_EN_REG			0x320
+#define DSAF_SUB_SC_PPE_CLK_DIS_REG			0x324
+#define DSAF_SUB_SC_RCB_PPE_COM_CLK_EN_REG		0x350
+#define DSAF_SUB_SC_RCB_PPE_COM_CLK_DIS_REG		0x354
+#define DSAF_SUB_SC_XBAR_RESET_REQ_REG			0xA00
+#define DSAF_SUB_SC_XBAR_RESET_DREQ_REG			0xA04
+#define DSAF_SUB_SC_NT_RESET_REQ_REG			0xA08
+#define DSAF_SUB_SC_NT_RESET_DREQ_REG			0xA0C
+#define DSAF_SUB_SC_XGE_RESET_REQ_REG			0xA10
+#define DSAF_SUB_SC_XGE_RESET_DREQ_REG			0xA14
+#define DSAF_SUB_SC_GE_RESET_REQ0_REG			0xA18
+#define DSAF_SUB_SC_GE_RESET_DREQ0_REG			0xA1C
+#define DSAF_SUB_SC_GE_RESET_REQ1_REG			0xA20
+#define DSAF_SUB_SC_GE_RESET_DREQ1_REG			0xA24
+#define DSAF_SUB_SC_PPE_RESET_REQ_REG			0xA48
+#define DSAF_SUB_SC_PPE_RESET_DREQ_REG			0xA4C
+#define DSAF_SUB_SC_RCB_PPE_COM_RESET_REQ_REG		0xA88
+#define DSAF_SUB_SC_RCB_PPE_COM_RESET_DREQ_REG		0xA8C
+#define DSAF_SUB_SC_LIGHT_MODULE_DETECT_EN_REG		0x2060
+#define DSAF_SUB_SC_TCAM_MBIST_EN_REG			0x2300
+#define DSAF_SUB_SC_DSAF_CLK_ST_REG			0x5300
+#define DSAF_SUB_SC_NT_CLK_ST_REG			0x5304
+#define DSAF_SUB_SC_XGE_CLK_ST_REG			0x5308
+#define DSAF_SUB_SC_GE_CLK_ST_REG			0x530C
+#define DSAF_SUB_SC_PPE_CLK_ST_REG			0x5310
+#define DSAF_SUB_SC_ROCEE_CLK_ST_REG			0x5314
+#define DSAF_SUB_SC_CPU_CLK_ST_REG			0x5318
+#define DSAF_SUB_SC_RCB_PPE_COM_CLK_ST_REG		0x5328
+#define DSAF_SUB_SC_XBAR_RESET_ST_REG			0x5A00
+#define DSAF_SUB_SC_NT_RESET_ST_REG			0x5A04
+#define DSAF_SUB_SC_XGE_RESET_ST_REG			0x5A08
+#define DSAF_SUB_SC_GE_RESET_ST0_REG			0x5A0C
+#define DSAF_SUB_SC_GE_RESET_ST1_REG			0x5A10
+#define DSAF_SUB_SC_PPE_RESET_ST_REG			0x5A24
+#define DSAF_SUB_SC_RCB_PPE_COM_RESET_ST_REG		0x5A44
 
 /*serdes offset**/
 #define HNS_MAC_HILINK3_REG DSAF_SUB_SC_HILINK3_CRG_CTRL0_REG
@@ -317,7 +317,8 @@
 #define PPE_CFG_TAG_GEN_REG			0x90
 #define PPE_CFG_PARSE_TAG_REG			0x94
 #define PPE_CFG_PRO_CHECK_EN_REG		0x98
-#define PPEV2_CFG_TSO_EN_REG                    0xA0
+#define PPEV2_CFG_TSO_EN_REG			0xA0
+#define PPEV2_VLAN_STRIP_EN_REG			0xAC
 #define PPE_INTEN_REG				0x100
 #define PPE_RINT_REG				0x104
 #define PPE_INTSTS_REG				0x108
-- 
1.7.9.5
