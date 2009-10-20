From: Roel Kluin <roel.kluin@gmail.com>
Subject: [PATCH] net: Fix checks on unsigned in w90p910_ether_probe()
Date: Tue, 20 Oct 2009 20:14:36 +0200
Message-ID: <4ADDFE0C.3020400@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	mcuos.com@gmail.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f207.google.com ([209.85.219.207]:50819 "EHLO
	mail-ew0-f207.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751137AbZJTSEd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Oct 2009 14:04:33 -0400
Received: by ewy3 with SMTP id 3so5100148ewy.17
        for <netdev@vger.kernel.org>; Tue, 20 Oct 2009 11:04:37 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ether->txirq and ->rxirq are unsigned

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
diff --git a/drivers/net/arm/w90p910_ether.c b/drivers/net/arm/w90p910_ether.c
index 25e2627..503c2ce 100644
--- a/drivers/net/arm/w90p910_ether.c
+++ b/drivers/net/arm/w90p910_ether.c
@@ -981,7 +981,7 @@ static int __devinit w90p910_ether_probe(struct platform_device *pdev)
 {
 	struct w90p910_ether *ether;
 	struct net_device *dev;
-	int error;
+	int error, ret;
 
 	dev = alloc_etherdev(sizeof(struct w90p910_ether));
 	if (!dev)
@@ -1010,17 +1010,19 @@ static int __devinit w90p910_ether_probe(struct platform_device *pdev)
 		goto failed_free_mem;
 	}
 
-	ether->txirq = platform_get_irq(pdev, 0);
-	if (ether->txirq < 0) {
+	ret = platform_get_irq(pdev, 0);
+	ether->txirq = ret;
+	if (ret < 0) {
 		dev_err(&pdev->dev, "failed to get ether tx irq\n");
-		error = -ENXIO;
+		error = ret;
 		goto failed_free_io;
 	}
 
-	ether->rxirq = platform_get_irq(pdev, 1);
-	if (ether->rxirq < 0) {
+	ret = platform_get_irq(pdev, 1);
+	ether->rxirq = ret;
+	if (ret < 0) {
 		dev_err(&pdev->dev, "failed to get ether rx irq\n");
-		error = -ENXIO;
+		error = ret;
 		goto failed_free_txirq;
 	}
 
