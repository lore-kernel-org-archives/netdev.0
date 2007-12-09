From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 1/3][BNX2]: Add PHY_DIS_EARLY_DAC workaround.
Date: Sun, 09 Dec 2007 13:16:48 -0800
Message-ID: <1197235008.20251.9.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3703 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750861AbXLIUcb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 9 Dec 2007 15:32:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[BNX2]: Add PHY_DIS_EARLY_DAC workaround.

5709 Ax and Bx chips all need this workaround.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index da767d3..a4f3832 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -6685,8 +6685,9 @@ bnx2_init_board(struct pci_dev *pdev, struct net_device *dev)
 	} else if (CHIP_NUM(bp) == CHIP_NUM_5706 ||
 		   CHIP_NUM(bp) == CHIP_NUM_5708)
 		bp->phy_flags |= PHY_CRC_FIX_FLAG;
-	else if (CHIP_ID(bp) == CHIP_ID_5709_A0 ||
-		 CHIP_ID(bp) == CHIP_ID_5709_A1)
+	else if (CHIP_NUM(bp) == CHIP_NUM_5709 &&
+		 (CHIP_REV(bp) == CHIP_REV_Ax ||
+		  CHIP_REV(bp) == CHIP_REV_Bx))
 		bp->phy_flags |= PHY_DIS_EARLY_DAC_FLAG;
 
 	if ((CHIP_ID(bp) == CHIP_ID_5708_A0) ||


