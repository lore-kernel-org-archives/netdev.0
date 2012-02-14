From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 03/10] tg3: Fix copper autoneg adv checks
Date: Mon, 13 Feb 2012 17:20:10 -0800
Message-ID: <1329182417-28223-4-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com, mchan@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1654 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758655Ab2BNBVJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Feb 2012 20:21:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When checking the autoneg advertisements, the driver failed to include
the master and master enable bits for the bcm5701.  This patch fixes the
problem.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c |   11 ++++++++++-
 1 files changed, 10 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 4a0b9af..cb17885 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -4027,7 +4027,16 @@ static bool tg3_phy_copper_an_config_ok(struct tg3 *tp, u32 *lcladv)
 		if (tg3_readphy(tp, MII_CTRL1000, &tg3_ctrl))
 			return false;
 
-		tg3_ctrl &= (ADVERTISE_1000HALF | ADVERTISE_1000FULL);
+		if (tgtadv &&
+		    (tp->pci_chip_rev_id == CHIPREV_ID_5701_A0 ||
+		     tp->pci_chip_rev_id == CHIPREV_ID_5701_B0)) {
+			tgtadv |= CTL1000_AS_MASTER | CTL1000_ENABLE_MASTER;
+			tg3_ctrl &= (ADVERTISE_1000HALF | ADVERTISE_1000FULL |
+				     CTL1000_AS_MASTER | CTL1000_ENABLE_MASTER);
+		} else {
+			tg3_ctrl &= (ADVERTISE_1000HALF | ADVERTISE_1000FULL);
+		}
+
 		if (tg3_ctrl != tgtadv)
 			return false;
 	}
-- 
1.7.3.4
