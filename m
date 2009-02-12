From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 30/41]bnx2x: Optimize chip MPS configuration
Date: Thu, 12 Feb 2009 20:38:01 +0200
Message-ID: <1234463881.1863.162.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2663 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758567AbZBLSiU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Feb 2009 13:38:20 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Subject: [PATCH 30/41]bnx2x: Optimize chip MPS configuration

Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_init.h |   21 +++++++++++----------
 1 files changed, 11 insertions(+), 10 deletions(-)

diff --git a/drivers/net/bnx2x_init.h b/drivers/net/bnx2x_init.h
index 021438f..6fcd1dc 100644
--- a/drivers/net/bnx2x_init.h
+++ b/drivers/net/bnx2x_init.h
@@ -655,17 +655,18 @@ static void bnx2x_init_pxp(struct bnx2x *bp)
 	REG_WR(bp, PXP2_REG_WR_USDMDP_TH, (0x18 << w_order));
 
 	if (CHIP_IS_E1H(bp)) {
-		REG_WR(bp, PXP2_REG_WR_HC_MPS, w_order+1);
-		REG_WR(bp, PXP2_REG_WR_USDM_MPS, w_order+1);
-		REG_WR(bp, PXP2_REG_WR_CSDM_MPS, w_order+1);
-		REG_WR(bp, PXP2_REG_WR_TSDM_MPS, w_order+1);
-		REG_WR(bp, PXP2_REG_WR_XSDM_MPS, w_order+1);
-		REG_WR(bp, PXP2_REG_WR_QM_MPS, w_order+1);
-		REG_WR(bp, PXP2_REG_WR_TM_MPS, w_order+1);
-		REG_WR(bp, PXP2_REG_WR_SRC_MPS, w_order+1);
-		REG_WR(bp, PXP2_REG_WR_DBG_MPS, w_order+1);
+		val = ((w_order == 0) ? 2 : 3);
+		REG_WR(bp, PXP2_REG_WR_HC_MPS, val);
+		REG_WR(bp, PXP2_REG_WR_USDM_MPS, val);
+		REG_WR(bp, PXP2_REG_WR_CSDM_MPS, val);
+		REG_WR(bp, PXP2_REG_WR_TSDM_MPS, val);
+		REG_WR(bp, PXP2_REG_WR_XSDM_MPS, val);
+		REG_WR(bp, PXP2_REG_WR_QM_MPS, val);
+		REG_WR(bp, PXP2_REG_WR_TM_MPS, val);
+		REG_WR(bp, PXP2_REG_WR_SRC_MPS, val);
+		REG_WR(bp, PXP2_REG_WR_DBG_MPS, val);
 		REG_WR(bp, PXP2_REG_WR_DMAE_MPS, 2); /* DMAE is special */
-		REG_WR(bp, PXP2_REG_WR_CDU_MPS, w_order+1);
+		REG_WR(bp, PXP2_REG_WR_CDU_MPS, val);
 	}
 }
 
-- 
1.5.4.3




