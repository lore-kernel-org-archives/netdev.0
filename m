From: Hauke Mehrtens <hauke@hauke-m.de>
Subject: [PATCH 7/8] b44: do not set PHY address to 30 for every ext PHY
Date: Sun, 15 Dec 2013 19:42:04 +0100
Message-ID: <1387132925-18651-8-git-send-email-hauke@hauke-m.de>
References: <1387132925-18651-1-git-send-email-hauke@hauke-m.de>
Cc: zambrano@broadcom.com, netdev@vger.kernel.org,
	Hauke Mehrtens <hauke@hauke-m.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from server19320154104.serverpool.info ([193.201.54.104]:50627 "EHLO
	hauke-m.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751898Ab3LOSmc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 15 Dec 2013 13:42:32 -0500
In-Reply-To: <1387132925-18651-1-git-send-email-hauke@hauke-m.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

b44_phy_reset() will fail for an external PHY and only work with the
internal PHY, this was an old workaround when the detection of an
external switch based on the PHY address failed and it is not needed
any more.

Signed-off-by: Hauke Mehrtens <hauke@hauke-m.de>
---
 drivers/net/ethernet/broadcom/b44.c |    7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/b44.c b/drivers/net/ethernet/broadcom/b44.c
index 7f243aa..b65a463 100644
--- a/drivers/net/ethernet/broadcom/b44.c
+++ b/drivers/net/ethernet/broadcom/b44.c
@@ -2415,8 +2415,11 @@ static int b44_init_one(struct ssb_device *sdev,
 	b44_chip_reset(bp, B44_CHIP_RESET_FULL);
 
 	/* do a phy reset to test if there is an active phy */
-	if (b44_phy_reset(bp) < 0)
-		bp->phy_addr = B44_PHY_ADDR_NO_LOACL_PHY;
+	err = b44_phy_reset(bp);
+	if (err < 0) {
+		dev_err(sdev->dev, "phy reset failed\n");
+		goto err_out_unregister_netdev;
+	}
 
 	if (bp->flags & B44_FLAG_EXTERNAL_PHY) {
 		err = b44_register_phy_one(bp);
-- 
1.7.10.4
