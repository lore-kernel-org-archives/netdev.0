From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 1/3] au1000_eth: use write accessors
Date: Tue, 28 Jul 2009 23:06:27 +0200
Message-ID: <200907282306.27738.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Manuel Lauss <manuel.lauss@googlemail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f226.google.com ([209.85.219.226]:65134 "EHLO
	mail-ew0-f226.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754518AbZG1VGh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jul 2009 17:06:37 -0400
Received: by ewy26 with SMTP id 26so363258ewy.37
        for <netdev@vger.kernel.org>; Tue, 28 Jul 2009 14:06:37 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

The next 3 patches apply to on top of the patch series that I
sent earlier converting au1000_eth to become a platform_driver.
Thanks !
--
From: Florian Fainelli <florian@openwrt.org>
This patch replaces all occurences of *aup->enable = val
by writel(val, &aup->enable)

Signed-off-by: Florian Fainelli <florian@openwrt.org>
---
diff --git a/drivers/net/au1000_eth.c b/drivers/net/au1000_eth.c
index 57cc4f6..1f724da 100644
--- a/drivers/net/au1000_eth.c
+++ b/drivers/net/au1000_eth.c
@@ -155,10 +155,10 @@ static void enable_mac(struct net_device *dev, int force_reset)
 	spin_lock_irqsave(&aup->lock, flags);
 
 	if(force_reset || (!aup->mac_enabled)) {
-		*aup->enable = MAC_EN_CLOCK_ENABLE;
+		writel(MAC_EN_CLOCK_ENABLE, &aup->enable);
 		au_sync_delay(2);
-		*aup->enable = (MAC_EN_RESET0 | MAC_EN_RESET1 | MAC_EN_RESET2
-				| MAC_EN_CLOCK_ENABLE);
+		writel((MAC_EN_RESET0 | MAC_EN_RESET1 | MAC_EN_RESET2
+			| MAC_EN_CLOCK_ENABLE), &aup->enable);
 		au_sync_delay(2);
 
 		aup->mac_enabled = 1;
@@ -486,9 +486,9 @@ static void reset_mac_unlocked(struct net_device *dev)
 
 	hard_stop(dev);
 
-	*aup->enable = MAC_EN_CLOCK_ENABLE;
+	writel(MAC_EN_CLOCK_ENABLE, &aup->enable);
 	au_sync_delay(2);
-	*aup->enable = 0;
+	writel(0, &aup->enable);
 	au_sync_delay(2);
 
 	aup->tx_full = 0;
@@ -1103,7 +1103,7 @@ static int __devinit au1000_probe(struct platform_device *pdev)
 	memcpy(dev->dev_addr, au1000_mac_addr, sizeof(au1000_mac_addr));
 	dev->dev_addr[5] += pdev->id;
 
-	*aup->enable = 0;
+	writel(0, &aup->enable);
 	aup->mac_enabled = 0;
 
 	pd = pdev->dev.platform_data;
