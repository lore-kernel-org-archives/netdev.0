From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH 4/6] bnx2x: enable internal target-read for 57712 and up
 only
Date: Sun, 24 Jul 2011 16:57:04 +0300
Message-ID: <1311515824.23243.7.camel@lb-tlvb-dmitry>
Reply-To: dmitry@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "Eilon Greenstein" <eilong@broadcom.com>, shmulikr@broadcom.com
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1790 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752592Ab1GXOLD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 24 Jul 2011 10:11:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shmulik Ravid <shmulikr@broadcom.com> 

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Shmulik Ravid <shmulikr@broadcom.com> 
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_main.c |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_main.c b/drivers/net/bnx2x/bnx2x_main.c
index 9c146f7..9c62092 100644
--- a/drivers/net/bnx2x/bnx2x_main.c
+++ b/drivers/net/bnx2x/bnx2x_main.c
@@ -10242,11 +10242,14 @@ static int __devinit bnx2x_init_dev(struct pci_dev *pdev,
 	REG_WR(bp, PXP2_REG_PGL_ADDR_90_F0 + BP_PORT(bp)*16, 0);
 	REG_WR(bp, PXP2_REG_PGL_ADDR_94_F0 + BP_PORT(bp)*16, 0);
 
-	/**
+	/*
 	 * Enable internal target-read (in case we are probed after PF FLR).
-	 * Must be done prior to any BAR read access
+	 * Must be done prior to any BAR read access. Only for 57712 and up
 	 */
-	REG_WR(bp, PGLUE_B_REG_INTERNAL_PFID_ENABLE_TARGET_READ, 1);
+	if (board_type != BCM57710 &&
+	    board_type != BCM57711 &&
+	    board_type != BCM57711E)
+		REG_WR(bp, PGLUE_B_REG_INTERNAL_PFID_ENABLE_TARGET_READ, 1);
 
 	/* Reset the load counter */
 	bnx2x_clear_load_cnt(bp);
-- 
1.7.2.2




