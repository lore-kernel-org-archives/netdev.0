From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 5/17][BNX2]: Remove udelay() in copper PHY code.
Date: Thu, 16 Nov 2006 18:59:57 -0800
Message-ID: <1163732397.6658.27.camel@rh4>
References: <1163731443.6658.8.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:16906 "EHLO
	mms1.broadcom.com") by vger.kernel.org with ESMTP id S1424914AbWKQCHg
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Nov 2006 21:07:36 -0500
To: davem@davemloft.net
In-Reply-To: <1163731443.6658.8.camel@rh4>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[BNX2]: Remove udelay() in copper PHY code.

Change a long udelay() in bnx2_setup_copper_phy() to msleep().

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index ea5daf6..0a46b45 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -1159,7 +1159,6 @@ bnx2_setup_copper_phy(struct bnx2 *bp)
 	}
 	if (new_bmcr != bmcr) {
 		u32 bmsr;
-		int i = 0;
 
 		bnx2_read_phy(bp, MII_BMSR, &bmsr);
 		bnx2_read_phy(bp, MII_BMSR, &bmsr);
@@ -1167,12 +1166,12 @@ bnx2_setup_copper_phy(struct bnx2 *bp)
 		if (bmsr & BMSR_LSTATUS) {
 			/* Force link down */
 			bnx2_write_phy(bp, MII_BMCR, BMCR_LOOPBACK);
-			do {
-				udelay(100);
-				bnx2_read_phy(bp, MII_BMSR, &bmsr);
-				bnx2_read_phy(bp, MII_BMSR, &bmsr);
-				i++;
-			} while ((bmsr & BMSR_LSTATUS) && (i < 620));
+			spin_unlock_bh(&bp->phy_lock);
+			msleep(50);
+			spin_lock_bh(&bp->phy_lock);
+
+			bnx2_read_phy(bp, MII_BMSR, &bmsr);
+			bnx2_read_phy(bp, MII_BMSR, &bmsr);
 		}
 
 		bnx2_write_phy(bp, MII_BMCR, new_bmcr);


