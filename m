From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next] bgmac: propagate error codes in bgmac_probe()
Date: Sun, 12 Jan 2014 19:05:55 -0800
Message-ID: <1389582355-27514-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, zajec5@gmail.com, hauke@hauke-m.de,
	nlhintz@hotmail.com, sd@queasysnail.net, bhutchings@solarflare.com,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f47.google.com ([209.85.219.47]:61337 "EHLO
	mail-oa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751110AbaAMDGG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Jan 2014 22:06:06 -0500
Received: by mail-oa0-f47.google.com with SMTP id i7so7404579oag.6
        for <netdev@vger.kernel.org>; Sun, 12 Jan 2014 19:06:05 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

bgmac_mii_register() and register_netdev() both return appropriate error
codes for the failures they would encounter, propagate this error code
instead of overriding the value with -ENOTSUPP which is not the correct
error code to return.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
Sabrina, Ben, this relates to the thread on -ENOTSUPP, other places in
the driver need fixing too, but this has to be done as a separate patch
anyway.

 drivers/net/ethernet/broadcom/bgmac.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/ethernet/broadcom/bgmac.c
index 7f968a9..0297a79 100644
--- a/drivers/net/ethernet/broadcom/bgmac.c
+++ b/drivers/net/ethernet/broadcom/bgmac.c
@@ -1518,14 +1518,12 @@ static int bgmac_probe(struct bcma_device *core)
 	err = bgmac_mii_register(bgmac);
 	if (err) {
 		bgmac_err(bgmac, "Cannot register MDIO\n");
-		err = -ENOTSUPP;
 		goto err_dma_free;
 	}
 
 	err = register_netdev(bgmac->net_dev);
 	if (err) {
 		bgmac_err(bgmac, "Cannot register net device\n");
-		err = -ENOTSUPP;
 		goto err_mii_unregister;
 	}
 
-- 
1.8.3.2
