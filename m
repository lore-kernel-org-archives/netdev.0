From: Punnaiah Choudary Kalluri <punnaiah.choudary.kalluri@xilinx.com>
Subject: [PATCH] net: macb: Add support for sgmii phy interface
Date: Wed, 18 Nov 2015 09:03:50 +0530
Message-ID: <1447817630-4336-1-git-send-email-punnaia@xilinx.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<michals@xilinx.com>, <harinik@xilinx.com>,
	<kalluripunnaiahchoudary@gmail.com>, <kpc528@gmail.com>,
	"Punnaiah Choudary Kalluri" <punnaia@xilinx.com>
To: <nicolas.ferre@atmel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2nam02on0064.outbound.protection.outlook.com ([104.47.38.64]:5548
	"EHLO NAM02-BL2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752944AbbKRDtF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Nov 2015 22:49:05 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for the sgmii phy interface.

Signed-off-by: Punnaiah Choudary Kalluri <punnaia@xilinx.com>
---
 drivers/net/ethernet/cadence/macb.c | 4 ++++
 drivers/net/ethernet/cadence/macb.h | 5 +++++
 2 files changed, 9 insertions(+)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 88c1e1a..169059c 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -1682,6 +1682,8 @@ static void macb_init_hw(struct macb *bp)
 	macb_set_hwaddr(bp);
 
 	config = macb_mdc_clk_div(bp);
+	if (bp->phy_interface == PHY_INTERFACE_MODE_SGMII)
+		config |= GEM_BIT(SGMIIEN) | GEM_BIT(PCSSEL);
 	config |= MACB_BF(RBOF, NET_IP_ALIGN);	/* Make eth data aligned */
 	config |= MACB_BIT(PAE);		/* PAuse Enable */
 	config |= MACB_BIT(DRFCS);		/* Discard Rx FCS */
@@ -2416,6 +2418,8 @@ static int macb_init(struct platform_device *pdev)
 	/* Set MII management clock divider */
 	val = macb_mdc_clk_div(bp);
 	val |= macb_dbw(bp);
+	if (bp->phy_interface == PHY_INTERFACE_MODE_SGMII)
+		val |= GEM_BIT(SGMIIEN) | GEM_BIT(PCSSEL);
 	macb_writel(bp, NCFGR, val);
 
 	return 0;
diff --git a/drivers/net/ethernet/cadence/macb.h b/drivers/net/ethernet/cadence/macb.h
index 6e1faea..d83b0db 100644
--- a/drivers/net/ethernet/cadence/macb.h
+++ b/drivers/net/ethernet/cadence/macb.h
@@ -215,12 +215,17 @@
 /* GEM specific NCFGR bitfields. */
 #define GEM_GBE_OFFSET		10 /* Gigabit mode enable */
 #define GEM_GBE_SIZE		1
+#define GEM_PCSSEL_OFFSET	11
+#define GEM_PCSSEL_SIZE		1
 #define GEM_CLK_OFFSET		18 /* MDC clock division */
 #define GEM_CLK_SIZE		3
 #define GEM_DBW_OFFSET		21 /* Data bus width */
 #define GEM_DBW_SIZE		2
 #define GEM_RXCOEN_OFFSET	24
 #define GEM_RXCOEN_SIZE		1
+#define GEM_SGMIIEN_OFFSET	27
+#define GEM_SGMIIEN_SIZE	1
+
 
 /* Constants for data bus width. */
 #define GEM_DBW32		0 /* 32 bit AMBA AHB data bus width */
-- 
2.1.2
