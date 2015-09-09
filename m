From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH] net: ethoc: Remove unnecessary #ifdef CONFIG_OF
Date: Wed,  9 Sep 2015 11:24:29 +0200
Message-ID: <1441790669-18623-1-git-send-email-tklauser@distanz.ch>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.zhinst.com ([212.126.164.98]:50614 "EHLO mail.zhinst.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752187AbbIIJYe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Sep 2015 05:24:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For !CONFIG_OF of_get_property() is defined to always return NULL. Thus
there's no need to protect the call to of_get_property() with #ifdef
CONFIG_OF.

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 drivers/net/ethernet/ethoc.c | 7 +------
 1 file changed, 1 insertion(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/ethoc.c b/drivers/net/ethernet/ethoc.c
index 442410c..a2c96fd 100644
--- a/drivers/net/ethernet/ethoc.c
+++ b/drivers/net/ethernet/ethoc.c
@@ -1132,10 +1132,6 @@ static int ethoc_probe(struct platform_device *pdev)
 		memcpy(netdev->dev_addr, pdata->hwaddr, IFHWADDRLEN);
 		priv->phy_id = pdata->phy_id;
 	} else {
-		priv->phy_id = -1;
-
-#ifdef CONFIG_OF
-		{
 		const uint8_t *mac;
 
 		mac = of_get_property(pdev->dev.of_node,
@@ -1143,8 +1139,7 @@ static int ethoc_probe(struct platform_device *pdev)
 				      NULL);
 		if (mac)
 			memcpy(netdev->dev_addr, mac, IFHWADDRLEN);
-		}
-#endif
+		priv->phy_id = -1;
 	}
 
 	/* Check that the given MAC address is valid. If it isn't, read the
-- 
2.5.0
