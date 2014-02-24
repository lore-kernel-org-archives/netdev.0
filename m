From: Fabio Estevam <festevam@gmail.com>
Subject: [PATCH v2] net: bcmgenet: Use devm_ioremap_resource()
Date: Mon, 24 Feb 2014 00:47:24 -0300
Message-ID: <1393213644-11081-1-git-send-email-festevam@gmail.com>
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org,
	Fabio Estevam <fabio.estevam@freescale.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f51.google.com ([209.85.213.51]:34332 "EHLO
	mail-yh0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751825AbaBXDrd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Feb 2014 22:47:33 -0500
Received: by mail-yh0-f51.google.com with SMTP id t59so4641812yho.24
        for <netdev@vger.kernel.org>; Sun, 23 Feb 2014 19:47:33 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabio Estevam <fabio.estevam@freescale.com>

According to Documentation/driver-model/devres.txt, devm_request_and_ioremap()
is deprecated, so use devm_ioremap_resource() instead.

Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>
---
Changes since v1:
- Fix subject

 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index 0ebc297..844e081 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -2481,10 +2481,9 @@ static int bcmgenet_probe(struct platform_device *pdev)
 	}
 
 	r = platform_get_resource(pdev, IORESOURCE_MEM, 0);
-	priv->base = devm_request_and_ioremap(&pdev->dev, r);
-	if (!priv->base) {
-		dev_err(&pdev->dev, "can't ioremap\n");
-		err = -EINVAL;
+	priv->base = devm_ioremap_resource(&pdev->dev, r);
+	if (IS_ERR(priv->base)) {
+		err = PTR_ERR(priv->base);
 		goto err;
 	}
 
-- 
1.8.1.2
