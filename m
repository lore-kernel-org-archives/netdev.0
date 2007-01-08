From: "Michael Chan" <mchan@broadcom.com>
Subject: [BNX2 1/4]: Don't apply CRC PHY workaround to 5709.
Date: Mon, 08 Jan 2007 15:56:21 -0800
Message-ID: <1168300581.4430.7.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3466 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161149AbXAHXJb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Jan 2007 18:09:31 -0500
To: davem@davemloft.net, netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[BNX2]: Don't apply CRC PHY workaround to 5709.

The workaround is only needed on 5706/5708 and cannot be applied on
5709.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index ada5e9b..8d682fc 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -1345,8 +1345,6 @@ bnx2_init_copper_phy(struct bnx2 *bp)
 {
 	u32 val;
 
-	bp->phy_flags |= PHY_CRC_FIX_FLAG;
-
 	if (bp->phy_flags & PHY_CRC_FIX_FLAG) {
 		bnx2_write_phy(bp, 0x18, 0x0c00);
 		bnx2_write_phy(bp, 0x17, 0x000a);
@@ -5880,7 +5878,9 @@ bnx2_init_board(struct pci_dev *pdev, st
 			if (reg & BNX2_SHARED_HW_CFG_PHY_2_5G)
 				bp->phy_flags |= PHY_2_5G_CAPABLE_FLAG;
 		}
-	}
+	} else if (CHIP_NUM(bp) == CHIP_NUM_5706 ||
+		   CHIP_NUM(bp) == CHIP_NUM_5708)
+		bp->phy_flags |= PHY_CRC_FIX_FLAG;
 
 	if ((CHIP_ID(bp) == CHIP_ID_5708_A0) ||
 	    (CHIP_ID(bp) == CHIP_ID_5708_B0) ||


