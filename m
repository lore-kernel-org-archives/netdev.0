From: Roel Kluin <roel.kluin@gmail.com>
Subject: [PATCH] s6gmac: Read buffer overflow
Date: Sun, 02 Aug 2009 08:20:13 +0200
Message-ID: <4A75301D.5070802@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f214.google.com ([209.85.219.214]:64364 "EHLO
	mail-ew0-f214.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751479AbZHBGRG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Aug 2009 02:17:06 -0400
Received: by ewy10 with SMTP id 10so2352309ewy.37
        for <netdev@vger.kernel.org>; Sat, 01 Aug 2009 23:17:04 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Check whether index is within bounds before testing the element.
In the last iteration i is PHY_MAX_ADDR. the condition
`!(p = pd->mii.bus->phy_map[PHY_MAX_ADDR])' is undefined and may
evaluate to false, which leads to a dereference of this invalid
phy_map in the phy_connect() below.

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
diff --git a/drivers/net/s6gmac.c b/drivers/net/s6gmac.c
index 5345e47..4525cbe 100644
--- a/drivers/net/s6gmac.c
+++ b/drivers/net/s6gmac.c
@@ -793,7 +793,7 @@ static inline int s6gmac_phy_start(struct net_device *dev)
 	struct s6gmac *pd = netdev_priv(dev);
 	int i = 0;
 	struct phy_device *p = NULL;
-	while ((!(p = pd->mii.bus->phy_map[i])) && (i < PHY_MAX_ADDR))
+	while ((i < PHY_MAX_ADDR) && (!(p = pd->mii.bus->phy_map[i])))
 		i++;
 	p = phy_connect(dev, dev_name(&p->dev), &s6gmac_adjust_link, 0,
 			PHY_INTERFACE_MODE_RGMII);
