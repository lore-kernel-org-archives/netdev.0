From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH 7/8] bnx2x: don't access removed registers on 57712 and
 above
Date: Tue, 30 Aug 2011 13:08:45 +0300
Message-ID: <1314698926-24525-8-git-send-email-dmitry@broadcom.com>
References: <1314698926-24525-1-git-send-email-dmitry@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Dmitry Kravkov" <dmitry@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4435 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752880Ab1H3KIv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Aug 2011 06:08:51 -0400
In-Reply-To: <1314698926-24525-1-git-send-email-dmitry@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_main.c |   14 +++++++++-----
 1 files changed, 9 insertions(+), 5 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_main.c b/drivers/net/bnx2x/bnx2x_main.c
index 94382a7..0b68d02 100644
--- a/drivers/net/bnx2x/bnx2x_main.c
+++ b/drivers/net/bnx2x/bnx2x_main.c
@@ -10290,17 +10290,21 @@ static int __devinit bnx2x_init_dev(struct pci_dev *pdev,
 	/* clean indirect addresses */
 	pci_write_config_dword(bp->pdev, PCICFG_GRC_ADDRESS,
 			       PCICFG_VENDOR_ID_OFFSET);
-	/* Clean the following indirect addresses for all functions since it
+	/*
+	 * Clean the following indirect addresses for all functions since it
 	 * is not used by the driver.
 	 */
 	REG_WR(bp, PXP2_REG_PGL_ADDR_88_F0, 0);
 	REG_WR(bp, PXP2_REG_PGL_ADDR_8C_F0, 0);
 	REG_WR(bp, PXP2_REG_PGL_ADDR_90_F0, 0);
 	REG_WR(bp, PXP2_REG_PGL_ADDR_94_F0, 0);
-	REG_WR(bp, PXP2_REG_PGL_ADDR_88_F1, 0);
-	REG_WR(bp, PXP2_REG_PGL_ADDR_8C_F1, 0);
-	REG_WR(bp, PXP2_REG_PGL_ADDR_90_F1, 0);
-	REG_WR(bp, PXP2_REG_PGL_ADDR_94_F1, 0);
+
+	if (CHIP_IS_E1x(bp)) {
+		REG_WR(bp, PXP2_REG_PGL_ADDR_88_F1, 0);
+		REG_WR(bp, PXP2_REG_PGL_ADDR_8C_F1, 0);
+		REG_WR(bp, PXP2_REG_PGL_ADDR_90_F1, 0);
+		REG_WR(bp, PXP2_REG_PGL_ADDR_94_F1, 0);
+	}
 
 	/*
 	 * Enable internal target-read (in case we are probed after PF FLR).
-- 
1.7.2.2
