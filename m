From: Fabio Estevam <festevam@gmail.com>
Subject: [PATCH] bgmac: Update fixed_phy_register()
Date: Wed,  2 Sep 2015 13:25:59 -0300
Message-ID: <1441211159-31328-1-git-send-email-festevam@gmail.com>
Cc: nbd@openwrt.org, andrew@lunn.ch, broonie@kernel.org,
	netdev@vger.kernel.org, Fabio Estevam <fabio.estevam@freescale.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f173.google.com ([209.85.160.173]:35674 "EHLO
	mail-yk0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751268AbbIBQ0Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Sep 2015 12:26:16 -0400
Received: by ykek143 with SMTP id k143so15406277yke.2
        for <netdev@vger.kernel.org>; Wed, 02 Sep 2015 09:26:15 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabio Estevam <fabio.estevam@freescale.com>

Commit a5597008dbc2 ("phy: fixed_phy: Add gpio to determine link up/down.")
added a new argument to fixed_phy_register(), but missed to update bgmac
driver, causing the following build failure:

drivers/net/ethernet/broadcom/bgmac.c:1450:2: error: too few arguments to function 'fixed_phy_register'

Add the missing argument.

Reported-by: Mark Brown <broonie@kernel.org>
Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>
---
 drivers/net/ethernet/broadcom/bgmac.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/ethernet/broadcom/bgmac.c
index d043746..28f7610 100644
--- a/drivers/net/ethernet/broadcom/bgmac.c
+++ b/drivers/net/ethernet/broadcom/bgmac.c
@@ -1447,7 +1447,7 @@ static int bgmac_fixed_phy_register(struct bgmac *bgmac)
 	struct phy_device *phy_dev;
 	int err;
 
-	phy_dev = fixed_phy_register(PHY_POLL, &fphy_status, NULL);
+	phy_dev = fixed_phy_register(PHY_POLL, &fphy_status, -1, NULL);
 	if (!phy_dev || IS_ERR(phy_dev)) {
 		bgmac_err(bgmac, "Failed to register fixed PHY device\n");
 		return -ENODEV;
-- 
1.9.1
