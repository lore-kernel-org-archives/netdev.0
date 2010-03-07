From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 2/3] cpmac: fallback to switch mode if no PHY chip found
Date: Sun, 7 Mar 2010 11:55:47 +0100
Message-ID: <201003071155.48462.florian@openwrt.org>
Reply-To: Florian Fainelli <florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f222.google.com ([209.85.218.222]:63171 "EHLO
	mail-bw0-f222.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751078Ab0CGKzv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Mar 2010 05:55:51 -0500
Received: by mail-bw0-f222.google.com with SMTP id 22so2144929bwz.28
        for <netdev@vger.kernel.org>; Sun, 07 Mar 2010 02:55:50 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If we were unable to detect a PHY on any of the MDIO bus id we tried instead of
bailing out with -ENODEV, assume the MAC is connected to a switch and use MDIO
bus 0. This unbreaks quite a lot of devices out there whose switch cannot be
detected.

Signed-off-by: Florian Fainelli <florian@openwrt.org>
---
diff --git a/drivers/net/cpmac.c b/drivers/net/cpmac.c
index 722a196..4051e81 100644
--- a/drivers/net/cpmac.c
+++ b/drivers/net/cpmac.c
@@ -1137,8 +1137,9 @@ static int __devinit cpmac_probe(struct platform_device *pdev)
 	}
 
 	if (phy_id == PHY_MAX_ADDR) {
-		dev_err(&pdev->dev, "no PHY present\n");
-		return -ENODEV;
+		dev_err(&pdev->dev, "no PHY present, falling back to switch on MDIO bus 0\n");
+		strncpy(mdio_bus_id, "0", MII_BUS_ID_SIZE); /* fixed phys bus */
+		phy_id = pdev->id;
 	}
 
 	dev = alloc_etherdev_mq(sizeof(*priv), CPMAC_QUEUES);

