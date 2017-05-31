From: thor.thayer@linux.intel.com
Subject: [PATCH] net: ethernet: stmmac: Fix altr_tse_pcs SGMII Initialization
Date: Wed, 31 May 2017 14:28:47 -0500
Message-ID: <1496258927-5493-1-git-send-email-thor.thayer@linux.intel.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        thor.thayer@linux.intel.com
To: peppe.cavallaro@st.com, alexandre.torgue@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.31]:34344 "EHLO mga06.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750898AbdEaTZz (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 31 May 2017 15:25:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thor Thayer <thor.thayer@linux.intel.com>

Fix NETDEV WATCHDOG timeout on startup by adding missing register
writes that properly setup SGMII.

Signed-off-by: Thor Thayer <thor.thayer@linux.intel.com>
---
 drivers/net/ethernet/stmicro/stmmac/altr_tse_pcs.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/altr_tse_pcs.c b/drivers/net/ethernet/stmicro/stmmac/altr_tse_pcs.c
index 489ef14..6a9c954 100644
--- a/drivers/net/ethernet/stmicro/stmmac/altr_tse_pcs.c
+++ b/drivers/net/ethernet/stmicro/stmmac/altr_tse_pcs.c
@@ -37,6 +37,7 @@
 #define TSE_PCS_CONTROL_AN_EN_MASK			BIT(12)
 #define TSE_PCS_CONTROL_REG				0x00
 #define TSE_PCS_CONTROL_RESTART_AN_MASK			BIT(9)
+#define TSE_PCS_CTRL_AUTONEG_SGMII			0x1140
 #define TSE_PCS_IF_MODE_REG				0x28
 #define TSE_PCS_LINK_TIMER_0_REG			0x24
 #define TSE_PCS_LINK_TIMER_1_REG			0x26
@@ -65,6 +66,7 @@
 #define TSE_PCS_SW_RESET_TIMEOUT			100
 #define TSE_PCS_USE_SGMII_AN_MASK			BIT(1)
 #define TSE_PCS_USE_SGMII_ENA				BIT(0)
+#define TSE_PCS_IF_USE_SGMII				0x03
 
 #define SGMII_ADAPTER_CTRL_REG				0x00
 #define SGMII_ADAPTER_DISABLE				0x0001
@@ -101,7 +103,9 @@ int tse_pcs_init(void __iomem *base, struct tse_pcs *pcs)
 {
 	int ret = 0;
 
-	writew(TSE_PCS_USE_SGMII_ENA, base + TSE_PCS_IF_MODE_REG);
+	writew(TSE_PCS_IF_USE_SGMII, base + TSE_PCS_IF_MODE_REG);
+
+	writew(TSE_PCS_CTRL_AUTONEG_SGMII, base + TSE_PCS_CONTROL_REG);
 
 	writew(TSE_PCS_SGMII_LINK_TIMER_0, base + TSE_PCS_LINK_TIMER_0_REG);
 	writew(TSE_PCS_SGMII_LINK_TIMER_1, base + TSE_PCS_LINK_TIMER_1_REG);
-- 
2.7.4
