From: Fabio Estevam <festevam@gmail.com>
Subject: [PATCH 5/6] fec: Remove unneeded check in platform_get_resource()
Date: Sun, 21 Jul 2013 13:25:03 -0300
Message-ID: <1374423904-2668-6-git-send-email-festevam@gmail.com>
References: <1374423904-2668-1-git-send-email-festevam@gmail.com>
Cc: kernel@pengutronix.de, Frank.Li@freescale.com,
	shawn.guo@linaro.org, netdev@vger.kernel.org,
	Fabio Estevam <fabio.estevam@freescale.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gg0-f181.google.com ([209.85.161.181]:41081 "EHLO
	mail-gg0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755722Ab3GUQZm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Jul 2013 12:25:42 -0400
Received: by mail-gg0-f181.google.com with SMTP id r4so1824868ggn.40
        for <netdev@vger.kernel.org>; Sun, 21 Jul 2013 09:25:41 -0700 (PDT)
In-Reply-To: <1374423904-2668-1-git-send-email-festevam@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabio Estevam <fabio.estevam@freescale.com>

As devm_ioremap_resource() is used, there is no need to explicitely check the
return value from platform_get_resource(), as this is something that
devm_ioremap_resource() takes care by itself.

Also, place platform_get_resource() prior to devm_ioremap_resource() for
better code readability.

Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>
---
 drivers/net/ethernet/freescale/fec_main.c | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index acc1850..03028c4 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -2033,10 +2033,6 @@ fec_probe(struct platform_device *pdev)
 	if (of_id)
 		pdev->id_entry = of_id->data;
 
-	r = platform_get_resource(pdev, IORESOURCE_MEM, 0);
-	if (!r)
-		return -ENXIO;
-
 	/* Init network device */
 	ndev = alloc_etherdev(sizeof(struct fec_enet_private));
 	if (!ndev)
@@ -2054,6 +2050,7 @@ fec_probe(struct platform_device *pdev)
 		fep->pause_flag |= FEC_PAUSE_FLAG_AUTONEG;
 #endif
 
+	r = platform_get_resource(pdev, IORESOURCE_MEM, 0);
 	fep->hwp = devm_ioremap_resource(&pdev->dev, r);
 	if (IS_ERR(fep->hwp)) {
 		ret = PTR_ERR(fep->hwp);
-- 
1.8.1.2
