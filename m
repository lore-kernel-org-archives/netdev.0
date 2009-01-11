From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH] korina: fix probing crash
Date: Sun, 11 Jan 2009 16:54:24 +0100
Message-ID: <200901111654.24651.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>, jeff@garzik.org,
	netdev@vger.kernel.org, Phil Sutter <n0-1@freewrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f21.google.com ([209.85.218.21]:35540 "EHLO
	mail-bw0-f21.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751746AbZAKPyb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Jan 2009 10:54:31 -0500
Received: by bwz14 with SMTP id 14so31067631bwz.13
        for <netdev@vger.kernel.org>; Sun, 11 Jan 2009 07:54:29 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH] korina: fix probing crash

This patch fixes the wrong retrieval of platform_data
which makes the driver crash on probe. Propagate error
if the platform_driver cannot use its data.

Signed-off-by: Florian Fainelli <florian@openwrt.org>
---
diff --git a/drivers/net/korina.c b/drivers/net/korina.c
index e185763..b2a3949 100644
--- a/drivers/net/korina.c
+++ b/drivers/net/korina.c
@@ -1078,12 +1078,18 @@ static int korina_close(struct net_device *dev)
 
 static int korina_probe(struct platform_device *pdev)
 {
-	struct korina_device *bif = platform_get_drvdata(pdev);
+	struct korina_device *bif;
 	struct korina_private *lp;
 	struct net_device *dev;
 	struct resource *r;
 	int rc;
 
+	bif = (struct korina_device *)pdev->dev.platform_data;
+	if (!bif) {
+		printk(KERN_ERR DRV_NAME ": missing platform data\n");
+		return -ENODEV;
+	}
+
 	dev = alloc_etherdev(sizeof(struct korina_private));
 	if (!dev) {
 		printk(KERN_ERR DRV_NAME ": alloc_etherdev failed\n");
