From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH net 4/5] bnx2x: properly clean indirect addresses
Date: Tue, 9 Aug 2011 16:10:29 +0300
Message-ID: <1312895429.21856.3.camel@lb-tlvb-dmitry>
Reply-To: dmitry@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "Vladislav Zolotarov" <vladz@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2861 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751943Ab1HINOY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Aug 2011 09:14:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_main.c |   15 +++++++++++----
 drivers/net/bnx2x/bnx2x_reg.h  |   26 +++++++++++++++++++++-----
 2 files changed, 32 insertions(+), 9 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_main.c b/drivers/net/bnx2x/bnx2x_main.c
index 1f5467f..f74582a 100644
--- a/drivers/net/bnx2x/bnx2x_main.c
+++ b/drivers/net/bnx2x/bnx2x_main.c
@@ -10259,10 +10259,17 @@ static int __devinit bnx2x_init_dev(struct pci_dev *pdev,
 	/* clean indirect addresses */
 	pci_write_config_dword(bp->pdev, PCICFG_GRC_ADDRESS,
 			       PCICFG_VENDOR_ID_OFFSET);
-	REG_WR(bp, PXP2_REG_PGL_ADDR_88_F0 + BP_PORT(bp)*16, 0);
-	REG_WR(bp, PXP2_REG_PGL_ADDR_8C_F0 + BP_PORT(bp)*16, 0);
-	REG_WR(bp, PXP2_REG_PGL_ADDR_90_F0 + BP_PORT(bp)*16, 0);
-	REG_WR(bp, PXP2_REG_PGL_ADDR_94_F0 + BP_PORT(bp)*16, 0);
+	/* Clean the following indirect addresses for all functions since it
+	 * is not used by the driver.
+	 */
+	REG_WR(bp, PXP2_REG_PGL_ADDR_88_F0, 0);
+	REG_WR(bp, PXP2_REG_PGL_ADDR_8C_F0, 0);
+	REG_WR(bp, PXP2_REG_PGL_ADDR_90_F0, 0);
+	REG_WR(bp, PXP2_REG_PGL_ADDR_94_F0, 0);
+	REG_WR(bp, PXP2_REG_PGL_ADDR_88_F1, 0);
+	REG_WR(bp, PXP2_REG_PGL_ADDR_8C_F1, 0);
+	REG_WR(bp, PXP2_REG_PGL_ADDR_90_F1, 0);
+	REG_WR(bp, PXP2_REG_PGL_ADDR_94_F1, 0);
 
 	/*
 	 * Enable internal target-read (in case we are probed after PF FLR).
diff --git a/drivers/net/bnx2x/bnx2x_reg.h b/drivers/net/bnx2x/bnx2x_reg.h
index 27b5ecb..40266c1 100644
--- a/drivers/net/bnx2x/bnx2x_reg.h
+++ b/drivers/net/bnx2x/bnx2x_reg.h
@@ -3007,11 +3007,27 @@
 /* [R 6] Debug only: Number of used entries in the data FIFO */
 #define PXP2_REG_HST_DATA_FIFO_STATUS				 0x12047c
 /* [R 7] Debug only: Number of used entries in the header FIFO */
-#define PXP2_REG_HST_HEADER_FIFO_STATUS 			 0x120478
-#define PXP2_REG_PGL_ADDR_88_F0 				 0x120534
-#define PXP2_REG_PGL_ADDR_8C_F0 				 0x120538
-#define PXP2_REG_PGL_ADDR_90_F0 				 0x12053c
-#define PXP2_REG_PGL_ADDR_94_F0 				 0x120540
+#define PXP2_REG_HST_HEADER_FIFO_STATUS				 0x120478
+#define PXP2_REG_PGL_ADDR_88_F0					 0x120534
+/* [R 32] GRC address for configuration access to PCIE config address 0x88.
+ * any write to this PCIE address will cause a GRC write access to the
+ * address that's in t this register */
+#define PXP2_REG_PGL_ADDR_88_F1					 0x120544
+#define PXP2_REG_PGL_ADDR_8C_F0					 0x120538
+/* [R 32] GRC address for configuration access to PCIE config address 0x8c.
+ * any write to this PCIE address will cause a GRC write access to the
+ * address that's in t this register */
+#define PXP2_REG_PGL_ADDR_8C_F1					 0x120548
+#define PXP2_REG_PGL_ADDR_90_F0					 0x12053c
+/* [R 32] GRC address for configuration access to PCIE config address 0x90.
+ * any write to this PCIE address will cause a GRC write access to the
+ * address that's in t this register */
+#define PXP2_REG_PGL_ADDR_90_F1					 0x12054c
+#define PXP2_REG_PGL_ADDR_94_F0					 0x120540
+/* [R 32] GRC address for configuration access to PCIE config address 0x94.
+ * any write to this PCIE address will cause a GRC write access to the
+ * address that's in t this register */
+#define PXP2_REG_PGL_ADDR_94_F1					 0x120550
 #define PXP2_REG_PGL_CONTROL0					 0x120490
 #define PXP2_REG_PGL_CONTROL1					 0x120514
 #define PXP2_REG_PGL_DEBUG					 0x120520
-- 
1.7.2.2




