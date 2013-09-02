From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 1/5] net: emac: use platform_{get,set}_drvdata()
Date: Mon, 02 Sep 2013 17:06:52 +0900
Message-ID: <000f01cea7b3$6226fd30$2674f790$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Petri Gynther' <pgynther@google.com>,
	'Jingoo Han' <jg1.han@samsung.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout2.samsung.com ([203.254.224.25]:44403 "EHLO
	mailout2.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752789Ab3IBIGz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Sep 2013 04:06:55 -0400
Received: from epcpsbgr5.samsung.com
 (u145.gpu120.samsung.co.kr [203.254.230.145])
 by mailout2.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MSH008ARNUXHTN0@mailout2.samsung.com> for
 netdev@vger.kernel.org; Mon, 02 Sep 2013 17:06:53 +0900 (KST)
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the wrapper functions for getting and setting the driver data
using platform_device instead of using dev_{get,set}_drvdata()
with &pdev->dev, so we can directly pass a struct platform_device.
This is a purely cosmetic change.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/ibm/emac/core.c |   10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/ibm/emac/core.c b/drivers/net/ethernet/ibm/emac/core.c
index 2d3b064..6b5c722 100644
--- a/drivers/net/ethernet/ibm/emac/core.c
+++ b/drivers/net/ethernet/ibm/emac/core.c
@@ -2312,7 +2312,7 @@ static int emac_check_deps(struct emac_instance *dev,
 		if (deps[i].ofdev == NULL)
 			continue;
 		if (deps[i].drvdata == NULL)
-			deps[i].drvdata = dev_get_drvdata(&deps[i].ofdev->dev);
+			deps[i].drvdata = platform_get_drvdata(deps[i].ofdev);
 		if (deps[i].drvdata != NULL)
 			there++;
 	}
@@ -2799,9 +2799,9 @@ static int emac_probe(struct platform_device *ofdev)
 		/*  display more info about what's missing ? */
 		goto err_reg_unmap;
 	}
-	dev->mal = dev_get_drvdata(&dev->mal_dev->dev);
+	dev->mal = platform_get_drvdata(dev->mal_dev);
 	if (dev->mdio_dev != NULL)
-		dev->mdio_instance = dev_get_drvdata(&dev->mdio_dev->dev);
+		dev->mdio_instance = platform_get_drvdata(dev->mdio_dev);
 
 	/* Register with MAL */
 	dev->commac.ops = &emac_commac_ops;
@@ -2892,7 +2892,7 @@ static int emac_probe(struct platform_device *ofdev)
 	 * fully initialized
 	 */
 	wmb();
-	dev_set_drvdata(&ofdev->dev, dev);
+	platform_set_drvdata(ofdev, dev);
 
 	/* There's a new kid in town ! Let's tell everybody */
 	wake_up_all(&emac_probe_wait);
@@ -2951,7 +2951,7 @@ static int emac_probe(struct platform_device *ofdev)
 
 static int emac_remove(struct platform_device *ofdev)
 {
-	struct emac_instance *dev = dev_get_drvdata(&ofdev->dev);
+	struct emac_instance *dev = platform_get_drvdata(ofdev);
 
 	DBG(dev, "remove" NL);
 
-- 
1.7.10.4
