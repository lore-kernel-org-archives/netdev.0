From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net 2/2] net: ethernet: cpmac: Call SET_NETDEV_DEV()
Date: Thu,  8 Dec 2016 11:41:25 -0800
Message-ID: <20161208194125.13264-3-f.fainelli@gmail.com>
References: <20161208194125.13264-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, madalin.bucur@nxp.com, johan@kernel.org,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:35837 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752259AbcLHTl4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Dec 2016 14:41:56 -0500
Received: by mail-pf0-f193.google.com with SMTP id i88so13334807pfk.2
        for <netdev@vger.kernel.org>; Thu, 08 Dec 2016 11:41:56 -0800 (PST)
In-Reply-To: <20161208194125.13264-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The TI CPMAC driver calls into PHYLIB which now checks for
net_device->dev.parent, so make sure we do set it before calling into
any MDIO/PHYLIB related function.

Fixes: ec988ad78ed6 ("phy: Don't increment MDIO bus refcount unless it's a different owner")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/ti/cpmac.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/ti/cpmac.c b/drivers/net/ethernet/ti/cpmac.c
index fa0cfda24fd9..28097be2ff28 100644
--- a/drivers/net/ethernet/ti/cpmac.c
+++ b/drivers/net/ethernet/ti/cpmac.c
@@ -1113,6 +1113,7 @@ static int cpmac_probe(struct platform_device *pdev)
 	if (!dev)
 		return -ENOMEM;
 
+	SET_NETDEV_DEV(dev, &pdev->dev);
 	platform_set_drvdata(pdev, dev);
 	priv = netdev_priv(dev);
 
-- 
2.9.3
