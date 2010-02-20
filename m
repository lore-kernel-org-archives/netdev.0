From: Hauke Mehrtens <hauke@hauke-m.de>
Subject: [PATCH 1/2] b44: Set PHY address to NO_PHY if reset fails.
Date: Sat, 20 Feb 2010 21:55:25 +0100
Message-ID: <1266699326-1541-1-git-send-email-hauke@hauke-m.de>
Cc: zambrano@broadcom.com, netdev@vger.kernel.org,
	Hauke Mehrtens <hauke@hauke-m.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from server19320154104.serverpool.info ([193.201.54.104]:59688 "EHLO
	hauke-m.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756241Ab0BTVEx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 20 Feb 2010 16:04:53 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Do a PHY reset to test if there is an active phy and set the PHY address
to B44_PHY_ADDR_NO_PHY in case of an not active phy. This is needed for
the Linksys WRTSL54GS and Asus WL-500W.
This patch was used in OpenWRT for a long time.

Signed-off-by: Hauke Mehrtens <hauke@hauke-m.de>
---
 drivers/net/b44.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/drivers/net/b44.c b/drivers/net/b44.c
index 180510e..71fa0be 100644
--- a/drivers/net/b44.c
+++ b/drivers/net/b44.c
@@ -338,7 +338,7 @@ static int b44_phy_reset(struct b44 *bp)
 		}
 	}
 
-	return 0;
+	return err;
 }
 
 static void __b44_set_flow_ctrl(struct b44 *bp, u32 pause_flags)
@@ -2215,6 +2215,10 @@ static int __devinit b44_init_one(struct ssb_device *sdev,
 	 */
 	b44_chip_reset(bp, B44_CHIP_RESET_FULL);
 
+	/* do a phy reset to test if there is an active phy */
+	if (b44_phy_reset(bp) < 0)
+		bp->phy_addr = B44_PHY_ADDR_NO_PHY;
+
 	netdev_info(dev, "Broadcom 44xx/47xx 10/100BaseT Ethernet %pM\n",
 		    dev->dev_addr);
 
-- 
1.6.3.3

