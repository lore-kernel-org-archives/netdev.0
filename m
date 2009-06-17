From: Chaithrika U S <chaithrika@ti.com>
Subject: [PATCH] TI DaVinci EMAC : Fix rmmod error
Date: Wed, 17 Jun 2009 07:28:54 -0400
Message-ID: <1245238134-23512-1-git-send-email-chaithrika@ti.com>
Cc: davinci-linux-open-source@linux.davincidsp.com,
	Chaithrika U S <chaithrika@ti.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from arroyo.ext.ti.com ([192.94.94.40]:39263 "EHLO arroyo.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758274AbZFQMKo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Jun 2009 08:10:44 -0400
Received: from dflp53.itg.ti.com ([128.247.5.6])
	by arroyo.ext.ti.com (8.13.7/8.13.7) with ESMTP id n5HCAgKk009862
	for <netdev@vger.kernel.org>; Wed, 17 Jun 2009 07:10:47 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

clk_disable was called twice in the remove function.
Correct this so that the driver module unloads without error.

Signed-off-by: Chaithrika U S <chaithrika@ti.com>
---
Applies to Linus' kernel tree

 drivers/net/davinci_emac.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/davinci_emac.c b/drivers/net/davinci_emac.c
index 0e9b9f9..2df8fb0 100644
--- a/drivers/net/davinci_emac.c
+++ b/drivers/net/davinci_emac.c
@@ -2767,7 +2767,6 @@ static int __devexit davinci_emac_remove(struct platform_device *pdev)
 
 	dev_notice(&ndev->dev, "DaVinci EMAC: davinci_emac_remove()\n");
 
-	clk_disable(emac_clk);
 	platform_set_drvdata(pdev, NULL);
 	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
 	mdiobus_unregister(priv->mii_bus);
-- 
1.5.6

