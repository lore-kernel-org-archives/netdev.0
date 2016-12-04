From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 2/3] net: ethoc: Utilize of_get_mac_address()
Date: Sun,  4 Dec 2016 12:40:29 -0800
Message-ID: <20161204204030.9853-3-f.fainelli@gmail.com>
References: <20161204204030.9853-1-f.fainelli@gmail.com>
Cc: tremyfr@gmail.com, tklauser@distanz.ch, davem@davemloft.net,
        thierry.reding@gmail.com, andrew@lunn.ch,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f67.google.com ([209.85.218.67]:35089 "EHLO
        mail-oi0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750917AbcLDUki (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 4 Dec 2016 15:40:38 -0500
Received: by mail-oi0-f67.google.com with SMTP id v84so33924101oie.2
        for <netdev@vger.kernel.org>; Sun, 04 Dec 2016 12:40:37 -0800 (PST)
In-Reply-To: <20161204204030.9853-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Do not open code getting the MAC address exclusively from the
"local-mac-address" property, but instead use of_get_mac_address() which
looks up the MAC address using the 3 typical property names.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/ethoc.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/ethoc.c b/drivers/net/ethernet/ethoc.c
index 877c02a36c85..8d0cb5ce87ee 100644
--- a/drivers/net/ethernet/ethoc.c
+++ b/drivers/net/ethernet/ethoc.c
@@ -23,6 +23,7 @@
 #include <linux/sched.h>
 #include <linux/slab.h>
 #include <linux/of.h>
+#include <linux/of_net.h>
 #include <linux/module.h>
 #include <net/ethoc.h>
 
@@ -1158,11 +1159,9 @@ static int ethoc_probe(struct platform_device *pdev)
 		memcpy(netdev->dev_addr, pdata->hwaddr, IFHWADDRLEN);
 		priv->phy_id = pdata->phy_id;
 	} else {
-		const uint8_t *mac;
+		const void *mac;
 
-		mac = of_get_property(pdev->dev.of_node,
-				      "local-mac-address",
-				      NULL);
+		mac = of_get_mac_address(pdev->dev.of_node);
 		if (mac)
 			memcpy(netdev->dev_addr, mac, IFHWADDRLEN);
 		priv->phy_id = -1;
-- 
2.9.3
