From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 1/7][BNX2]: Fix 5706 serdes link down bug.
Date: Tue, 29 Jan 2008 16:18:45 -0800
Message-ID: <1201652325.19087.10.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2003 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754749AbYA2Xje (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Jan 2008 18:39:34 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[BNX2]: Fix 5706 serdes link down bug.

1. Correct the MII expansion serdes control register definition.
2. Check an additional RUDI_INVALID bit when determining 5706S link.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 34aebc6..353c73f 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -5315,7 +5315,7 @@ bnx2_5706_serdes_has_link(struct bnx2 *bp)
 	bnx2_read_phy(bp, MII_BNX2_MISC_SHADOW, &an_dbg);
 	bnx2_read_phy(bp, MII_BNX2_MISC_SHADOW, &an_dbg);
 
-	if (an_dbg & MISC_SHDW_AN_DBG_NOSYNC)
+	if (an_dbg & (MISC_SHDW_AN_DBG_NOSYNC | MISC_SHDW_AN_DBG_RUDI_INVALID))
 		return 0;
 
 	bnx2_write_phy(bp, MII_BNX2_DSP_ADDRESS, MII_EXPAND_REG1);
diff --git a/drivers/net/bnx2.h b/drivers/net/bnx2.h
index d8e0347..059e115 100644
--- a/drivers/net/bnx2.h
+++ b/drivers/net/bnx2.h
@@ -6346,11 +6346,12 @@ struct l2_fhdr {
 #define MII_BNX2_DSP_EXPAND_REG			 0x0f00
 #define MII_EXPAND_REG1				  (MII_BNX2_DSP_EXPAND_REG | 1)
 #define MII_EXPAND_REG1_RUDI_C			   0x20
-#define MII_EXPAND_SERDES_CTL			  (MII_BNX2_DSP_EXPAND_REG | 2)
+#define MII_EXPAND_SERDES_CTL			  (MII_BNX2_DSP_EXPAND_REG | 3)
 
 #define MII_BNX2_MISC_SHADOW			0x1c
 #define MISC_SHDW_AN_DBG			 0x6800
 #define MISC_SHDW_AN_DBG_NOSYNC			  0x0002
+#define MISC_SHDW_AN_DBG_RUDI_INVALID		  0x0100
 #define MISC_SHDW_MODE_CTL			 0x7c00
 #define MISC_SHDW_MODE_CTL_SIG_DET		  0x0010
 


