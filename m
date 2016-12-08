From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net 1/2] net: ethernet: lantiq_etop: Call SET_NETDEV_DEV()
Date: Thu,  8 Dec 2016 11:41:24 -0800
Message-ID: <20161208194125.13264-2-f.fainelli@gmail.com>
References: <20161208194125.13264-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, madalin.bucur@nxp.com, johan@kernel.org,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:36818 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752259AbcLHTlz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Dec 2016 14:41:55 -0500
Received: by mail-pg0-f65.google.com with SMTP id x23so27700968pgx.3
        for <netdev@vger.kernel.org>; Thu, 08 Dec 2016 11:41:54 -0800 (PST)
In-Reply-To: <20161208194125.13264-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Lantiq Etop driver calls into PHYLIB which now checks for
net_device->dev.parent, so make sure we do set it before calling into
any MDIO/PHYLIB related function.

Fixes: ec988ad78ed6 ("phy: Don't increment MDIO bus refcount unless it's a different owner")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/lantiq_etop.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/lantiq_etop.c b/drivers/net/ethernet/lantiq_etop.c
index 91e09d68b7e2..a167fd7ee13e 100644
--- a/drivers/net/ethernet/lantiq_etop.c
+++ b/drivers/net/ethernet/lantiq_etop.c
@@ -704,6 +704,7 @@ ltq_etop_probe(struct platform_device *pdev)
 	priv->pldata = dev_get_platdata(&pdev->dev);
 	priv->netdev = dev;
 	spin_lock_init(&priv->lock);
+	SET_NETDEV_DEV(dev, &pdev->dev);
 
 	for (i = 0; i < MAX_DMA_CHAN; i++) {
 		if (IS_TX(i))
-- 
2.9.3
