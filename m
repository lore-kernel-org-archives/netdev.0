From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH] cpmac: do not leak struct net_device on phy_connect errors
Date: Mon, 21 Jun 2010 10:07:48 +0200
Message-ID: <201006211007.49039.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:44316 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755360Ab0FUIKW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jun 2010 04:10:22 -0400
Received: by wyb33 with SMTP id 33so2008077wyb.19
        for <netdev@vger.kernel.org>; Mon, 21 Jun 2010 01:10:20 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the call to phy_connect fails, we will return directly instead of freeing
the previously allocated struct net_device.

Signed-off-by: Florian Fainelli <florian@openwrt.org>
CC: stable@kernel.org
---
diff --git a/drivers/net/cpmac.c b/drivers/net/cpmac.c
index 3c58db5..23786ee 100644
--- a/drivers/net/cpmac.c
+++ b/drivers/net/cpmac.c
@@ -1181,7 +1181,8 @@ static int __devinit cpmac_probe(struct platform_device *pdev)
 		if (netif_msg_drv(priv))
 			printk(KERN_ERR "%s: Could not attach to PHY\n",
 			       dev->name);
-		return PTR_ERR(priv->phy);
+		rc = PTR_ERR(priv->phy);
+		goto fail;
 	}
 
 	if ((rc = register_netdev(dev))) {
