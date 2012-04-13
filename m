From: xiong <xiong@qca.qualcomm.com>
Subject: [PATCH 18/37] atl1c: refine reg definition of REG_MASTER_CTRL
Date: Fri, 13 Apr 2012 08:14:43 +0800
Message-ID: <1334276102-15866-19-git-send-email-xiong@qca.qualcomm.com>
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

refine/update register REG_MASTER_CTRL definition according with
hardware spec.

Signed-off-by: xiong <xiong@qca.qualcomm.com>
Tested-by: Liu David <dwliu@qca.qualcomm.com>
---
 drivers/net/ethernet/atheros/atl1c/atl1c_hw.h   |   41 +++++++++++++----------
 drivers/net/ethernet/atheros/atl1c/atl1c_main.c |    2 +-
 2 files changed, 24 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_hw.h b/drivers/net/ethernet/atheros/atl1c/atl1c_hw.h
index a4fd36e..8246c29 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_hw.h
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_hw.h
@@ -188,26 +188,31 @@ int atl1c_phy_power_saving(struct atl1c_hw *hw);
 
 #define REG_LTSSM_ID_CTRL		0x12FC
 #define LTSSM_ID_EN_WRO			0x1000
+
+
 /* Selene Master Control Register */
 #define REG_MASTER_CTRL			0x1400
-#define MASTER_CTRL_SOFT_RST            0x1
-#define MASTER_CTRL_TEST_MODE_MASK	0x3
-#define MASTER_CTRL_TEST_MODE_SHIFT	2
-#define MASTER_CTRL_BERT_START		0x10
-#define MASTER_CTRL_OOB_DIS_OFF		0x40
-#define MASTER_CTRL_SA_TIMER_EN		0x80
-#define MASTER_CTRL_MTIMER_EN           0x100
-#define MASTER_CTRL_MANUAL_INT          0x200
-#define MASTER_CTRL_TX_ITIMER_EN	0x400
-#define MASTER_CTRL_RX_ITIMER_EN	0x800
-#define MASTER_CTRL_CLK_SEL_DIS		0x1000
-#define MASTER_CTRL_CLK_SWH_MODE	0x2000
-#define MASTER_CTRL_INT_RDCLR		0x4000
-#define MASTER_CTRL_REV_NUM_SHIFT	16
-#define MASTER_CTRL_REV_NUM_MASK	0xff
-#define MASTER_CTRL_DEV_ID_SHIFT	24
-#define MASTER_CTRL_DEV_ID_MASK		0x7f
-#define MASTER_CTRL_OTP_SEL		0x80000000
+#define MASTER_CTRL_OTP_SEL		BIT(31)
+#define MASTER_DEV_NUM_MASK		0x7FUL
+#define MASTER_DEV_NUM_SHIFT		24
+#define MASTER_REV_NUM_MASK		0xFFUL
+#define MASTER_REV_NUM_SHIFT		16
+#define MASTER_CTRL_INT_RDCLR		BIT(14)
+#define MASTER_CTRL_CLK_SEL_DIS		BIT(12)	/* 1:alwys sel pclk from
+						 * serdes, not sw to 25M */
+#define MASTER_CTRL_RX_ITIMER_EN	BIT(11)	/* IRQ MODURATION FOR RX */
+#define MASTER_CTRL_TX_ITIMER_EN	BIT(10)	/* MODURATION FOR TX/RX */
+#define MASTER_CTRL_MANU_INT		BIT(9)	/* SOFT MANUAL INT */
+#define MASTER_CTRL_MANUTIMER_EN	BIT(8)
+#define MASTER_CTRL_SA_TIMER_EN		BIT(7)	/* SYS ALIVE TIMER EN */
+#define MASTER_CTRL_OOB_DIS		BIT(6)	/* OUT OF BOX DIS */
+#define MASTER_CTRL_WAKEN_25M		BIT(5)	/* WAKE WO. PCIE CLK */
+#define MASTER_CTRL_BERT_START		BIT(4)
+#define MASTER_PCIE_TSTMOD_MASK		3UL
+#define MASTER_PCIE_TSTMOD_SHIFT	2
+#define MASTER_PCIE_RST			BIT(1)
+#define MASTER_CTRL_SOFT_RST		BIT(0)	/* RST MAC & DMA */
+#define DMA_MAC_RST_TO			50
 
 /* Timer Initial Value Register */
 #define REG_MANUAL_TIMER_INIT       	0x1404
diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
index 9295aee..4fc824d 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
@@ -1177,7 +1177,7 @@ static int atl1c_reset_mac(struct atl1c_hw *hw)
 	 * clearing, and should clear within a microsecond.
 	 */
 	AT_READ_REG(hw, REG_MASTER_CTRL, &master_ctrl_data);
-	master_ctrl_data |= MASTER_CTRL_OOB_DIS_OFF;
+	master_ctrl_data |= MASTER_CTRL_OOB_DIS;
 	AT_WRITE_REGW(hw, REG_MASTER_CTRL, ((master_ctrl_data | MASTER_CTRL_SOFT_RST)
 			& 0xFFFF));
 
-- 
1.7.7
