From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 7/7] net: bcmgenet: Utilize bcmgenet_mii_exit() for error path
Date: Mon, 31 Jul 2017 12:04:28 -0700
Message-ID: <20170731190429.24204-8-f.fainelli@gmail.com>
References: <20170731190429.24204-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, opendmb@gmail.com, jaedon.shin@gmail.com,
        pgynther@google.com, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:35356 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751537AbdGaTEx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Jul 2017 15:04:53 -0400
Received: by mail-wm0-f68.google.com with SMTP id r77so24028914wmd.2
        for <netdev@vger.kernel.org>; Mon, 31 Jul 2017 12:04:53 -0700 (PDT)
In-Reply-To: <20170731190429.24204-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

bcmgenet_mii_init() has an error path which is strictly identical to the
unwinding that bcmgenet_mii_exit() does, so have bcmgenet_mii_init()
utilize bcmgenet_mii_exit() for that.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/genet/bcmmii.c | 7 +------
 1 file changed, 1 insertion(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmmii.c b/drivers/net/ethernet/broadcom/genet/bcmmii.c
index 7fdc352628f9..33d3f60ac74b 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmmii.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmmii.c
@@ -563,7 +563,6 @@ static int bcmgenet_mii_bus_init(struct bcmgenet_priv *priv)
 int bcmgenet_mii_init(struct net_device *dev)
 {
 	struct bcmgenet_priv *priv = netdev_priv(dev);
-	struct device_node *dn = priv->pdev->dev.of_node;
 	int ret;
 
 	ret = bcmgenet_mii_register(priv);
@@ -577,11 +576,7 @@ int bcmgenet_mii_init(struct net_device *dev)
 	return 0;
 
 out:
-	if (of_phy_is_fixed_link(dn))
-		of_phy_deregister_fixed_link(dn);
-	of_node_put(priv->phy_dn);
-	platform_device_unregister(priv->mii_pdev);
-	platform_device_put(priv->mii_pdev);
+	bcmgenet_mii_exit(dev);
 	return ret;
 }
 
-- 
2.9.3
