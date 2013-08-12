From: Libo Chen <clbchenlibo.chen@huawei.com>
Subject: [PATCH 1/8] net: fsl_pq_mdio: use platform_{get,set}_drvdata()
Date: Mon, 12 Aug 2013 21:24:37 +0800
Message-ID: <5208E215.6030007@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>,
	Li Zefan <lizefan@huawei.com>, <timur@freescale.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:36957 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756190Ab3HLNYs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Aug 2013 09:24:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Use the wrapper functions for getting and setting the driver data using
platform_device instead of using dev_{get,set}_drvdata() with &pdev->dev,
so we can directly pass a struct platform_device.

Signed-off-by: Libo Chen <libo.chen@huawei.com>
---
 drivers/net/ethernet/freescale/fsl_pq_mdio.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fsl_pq_mdio.c b/drivers/net/ethernet/freescale/fsl_pq_mdio.c
index c93a056..995a3ab 100644
--- a/drivers/net/ethernet/freescale/fsl_pq_mdio.c
+++ b/drivers/net/ethernet/freescale/fsl_pq_mdio.c
@@ -409,7 +409,7 @@ static int fsl_pq_mdio_probe(struct platform_device *pdev)
 	priv->regs = priv->map + data->mii_offset;

 	new_bus->parent = &pdev->dev;
-	dev_set_drvdata(&pdev->dev, new_bus);
+	platform_set_drvdata(pdev, new_bus);

 	if (data->get_tbipa) {
 		for_each_child_of_node(np, tbi) {
@@ -468,7 +468,6 @@ static int fsl_pq_mdio_remove(struct platform_device *pdev)

 	mdiobus_unregister(bus);

-	dev_set_drvdata(device, NULL);

 	iounmap(priv->map);
 	mdiobus_free(bus);
-- 
1.7.1
