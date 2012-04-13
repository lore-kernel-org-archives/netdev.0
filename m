From: xiong <xiong@qca.qualcomm.com>
Subject: [PATCH 22/37] atl1c: fix WoL(magic) issue for l2cb 1.1
Date: Fri, 13 Apr 2012 08:14:47 +0800
Message-ID: <1334276102-15866-23-git-send-email-xiong@qca.qualcomm.com>
References: <1334276102-15866-1-git-send-email-xiong@qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <qca-linux-team@qualcomm.com>, <nic-devel@qualcomm.com>,
	xiong <xiong@qca.qualcomm.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1334276102-15866-1-git-send-email-xiong@qca.qualcomm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

l2cb 1.1 hardware has a bug for magic wakeup,
the workaround is to add pattern enable.
WoL related registers are refined as well.

Signed-off-by: xiong <xiong@qca.qualcomm.com>
Tested-by: Liu David <dwliu@qca.qualcomm.com>
---
 drivers/net/ethernet/atheros/atl1c/atl1c_hw.h   |   71 ++++++++++++++--------
 drivers/net/ethernet/atheros/atl1c/atl1c_main.c |    9 ++-
 2 files changed, 52 insertions(+), 28 deletions(-)

diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_hw.h b/drivers/net/ethernet/atheros/atl1c/atl1c_hw.h
index aafe4ff..eaa1760 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_hw.h
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_hw.h
@@ -444,34 +444,53 @@ int atl1c_phy_power_saving(struct atl1c_hw *hw);
 
 /* Wake-On-Lan control register */
 #define REG_WOL_CTRL                	0x14a0
-#define WOL_PATTERN_EN              	0x00000001
-#define WOL_PATTERN_PME_EN              0x00000002
-#define WOL_MAGIC_EN                    0x00000004
-#define WOL_MAGIC_PME_EN                0x00000008
-#define WOL_LINK_CHG_EN                 0x00000010
-#define WOL_LINK_CHG_PME_EN             0x00000020
-#define WOL_PATTERN_ST                  0x00000100
-#define WOL_MAGIC_ST                    0x00000200
-#define WOL_LINKCHG_ST                  0x00000400
-#define WOL_CLK_SWITCH_EN               0x00008000
-#define WOL_PT0_EN                      0x00010000
-#define WOL_PT1_EN                      0x00020000
-#define WOL_PT2_EN                      0x00040000
-#define WOL_PT3_EN                      0x00080000
-#define WOL_PT4_EN                      0x00100000
-#define WOL_PT5_EN                      0x00200000
-#define WOL_PT6_EN                      0x00400000
+#define WOL_PT7_MATCH			BIT(31)
+#define WOL_PT6_MATCH			BIT(30)
+#define WOL_PT5_MATCH			BIT(29)
+#define WOL_PT4_MATCH			BIT(28)
+#define WOL_PT3_MATCH			BIT(27)
+#define WOL_PT2_MATCH			BIT(26)
+#define WOL_PT1_MATCH			BIT(25)
+#define WOL_PT0_MATCH			BIT(24)
+#define WOL_PT7_EN			BIT(23)
+#define WOL_PT6_EN			BIT(22)
+#define WOL_PT5_EN			BIT(21)
+#define WOL_PT4_EN			BIT(20)
+#define WOL_PT3_EN			BIT(19)
+#define WOL_PT2_EN			BIT(18)
+#define WOL_PT1_EN			BIT(17)
+#define WOL_PT0_EN			BIT(16)
+#define WOL_LNKCHG_ST			BIT(10)
+#define WOL_MAGIC_ST			BIT(9)
+#define WOL_PATTERN_ST			BIT(8)
+#define WOL_OOB_EN			BIT(6)
+#define WOL_LINK_CHG_PME_EN		BIT(5)
+#define WOL_LINK_CHG_EN			BIT(4)
+#define WOL_MAGIC_PME_EN		BIT(3)
+#define WOL_MAGIC_EN			BIT(2)
+#define WOL_PATTERN_PME_EN		BIT(1)
+#define WOL_PATTERN_EN			BIT(0)
 
 /* WOL Length ( 2 DWORD ) */
-#define REG_WOL_PATTERN_LEN         	0x14a4
-#define WOL_PT_LEN_MASK                 0x7f
-#define WOL_PT0_LEN_SHIFT               0
-#define WOL_PT1_LEN_SHIFT               8
-#define WOL_PT2_LEN_SHIFT               16
-#define WOL_PT3_LEN_SHIFT               24
-#define WOL_PT4_LEN_SHIFT               0
-#define WOL_PT5_LEN_SHIFT               8
-#define WOL_PT6_LEN_SHIFT               16
+#define REG_WOL_PTLEN1			0x14A4
+#define WOL_PTLEN1_3_MASK		0xFFUL
+#define WOL_PTLEN1_3_SHIFT		24
+#define WOL_PTLEN1_2_MASK		0xFFUL
+#define WOL_PTLEN1_2_SHIFT		16
+#define WOL_PTLEN1_1_MASK		0xFFUL
+#define WOL_PTLEN1_1_SHIFT		8
+#define WOL_PTLEN1_0_MASK		0xFFUL
+#define WOL_PTLEN1_0_SHIFT		0
+
+#define REG_WOL_PTLEN2			0x14A8
+#define WOL_PTLEN2_7_MASK		0xFFUL
+#define WOL_PTLEN2_7_SHIFT		24
+#define WOL_PTLEN2_6_MASK		0xFFUL
+#define WOL_PTLEN2_6_SHIFT		16
+#define WOL_PTLEN2_5_MASK		0xFFUL
+#define WOL_PTLEN2_5_SHIFT		8
+#define WOL_PTLEN2_4_MASK		0xFFUL
+#define WOL_PTLEN2_4_SHIFT		0
 
 /* Internal SRAM Partition Register */
 #define RFDX_HEAD_ADDR_MASK		0x03FF
diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
index 8955810..8836c84 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
@@ -2353,9 +2353,14 @@ static int atl1c_suspend(struct device *dev)
 			mac_ctrl_data |= MAC_CTRL_DUPLX;
 
 		/* turn on magic packet wol */
-		if (wufc & AT_WUFC_MAG)
+		if (wufc & AT_WUFC_MAG) {
 			wol_ctrl_data |= WOL_MAGIC_EN | WOL_MAGIC_PME_EN;
-
+			if (hw->nic_type == athr_l2c_b &&
+			    hw->revision_id == L2CB_V11) {
+				wol_ctrl_data |=
+					WOL_PATTERN_EN | WOL_PATTERN_PME_EN;
+			}
+		}
 		if (wufc & AT_WUFC_LNKC) {
 			wol_ctrl_data |=  WOL_LINK_CHG_EN | WOL_LINK_CHG_PME_EN;
 			/* only link up can wake up */
-- 
1.7.7
