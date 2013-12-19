From: Hauke Mehrtens <hauke@hauke-m.de>
Subject: [PATCH v2 8/9] b44: do not set PHY address to 30 for every ext PHY
Date: Thu, 19 Dec 2013 02:28:45 +0100
Message-ID: <1387416526-7394-9-git-send-email-hauke@hauke-m.de>
References: <1387416526-7394-1-git-send-email-hauke@hauke-m.de>
Cc: zambrano@broadcom.com, netdev@vger.kernel.org,
	f.fainelli@gmail.com, Hauke Mehrtens <hauke@hauke-m.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from server19320154104.serverpool.info ([193.201.54.104]:44370 "EHLO
	hauke-m.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752515Ab3LSBaY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Dec 2013 20:30:24 -0500
In-Reply-To: <1387416526-7394-1-git-send-email-hauke@hauke-m.de>
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
index d17561b..839dd90 100644
--- a/drivers/net/ethernet/broadcom/b44.c
+++ b/drivers/net/ethernet/broadcom/b44.c
@@ -2412,8 +2412,11 @@ static int b44_init_one(struct ssb_device *sdev,
 	b44_chip_reset(bp, B44_CHIP_RESET_FULL);
 
 	/* do a phy reset to test if there is an active phy */
-	if (b44_phy_reset(bp) < 0)
-		bp->phy_addr = B44_PHY_ADDR_NO_LOCAL_PHY;
+	err = b44_phy_reset(bp);
+	if (err < 0) {
+		dev_err(sdev->dev, "phy reset failed\n");
+		goto err_out_unregister_netdev;
+	}
 
 	if (bp->flags & B44_FLAG_EXTERNAL_PHY) {
 		err = b44_register_phy_one(bp);
-- 
1.7.10.4
