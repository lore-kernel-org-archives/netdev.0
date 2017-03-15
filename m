From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net] net: bcmgenet: Do not suspend PHY if Wake-on-LAN is enabled
Date: Wed, 15 Mar 2017 12:57:21 -0700
Message-ID: <20170315195721.11507-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, opendmb@gmail.com, pgynther@google.com,
        jaedon.shin@gmail.com, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:36640 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753821AbdCOT5c (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Mar 2017 15:57:32 -0400
Received: by mail-wm0-f66.google.com with SMTP id x124so774350wmf.3
        for <netdev@vger.kernel.org>; Wed, 15 Mar 2017 12:57:31 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Suspending the PHY would be putting it in a low power state where it
may no longer allow us to do Wake-on-LAN.

Fixes: cc013fb48898 ("net: bcmgenet: correctly suspend and resume PHY device")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index 69015fa50f20..365895ed3c3e 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -3481,7 +3481,8 @@ static int bcmgenet_suspend(struct device *d)
 
 	bcmgenet_netif_stop(dev);
 
-	phy_suspend(priv->phydev);
+	if (!device_may_wakeup(d))
+		phy_suspend(priv->phydev);
 
 	netif_device_detach(dev);
 
@@ -3578,7 +3579,8 @@ static int bcmgenet_resume(struct device *d)
 
 	netif_device_attach(dev);
 
-	phy_resume(priv->phydev);
+	if (!device_may_wakeup(d))
+		phy_resume(priv->phydev);
 
 	if (priv->eee.eee_enabled)
 		bcmgenet_eee_enable_set(dev, true);
-- 
2.9.3
