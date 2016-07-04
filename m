From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 1/9] net: r6040: Utilize phy_print_status
Date: Mon,  4 Jul 2016 14:36:01 -0700
Message-ID: <1467668169-31547-2-git-send-email-f.fainelli@gmail.com>
References: <1467668169-31547-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f68.google.com ([209.85.218.68]:34047 "EHLO
	mail-oi0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753803AbcGDVgP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jul 2016 17:36:15 -0400
Received: by mail-oi0-f68.google.com with SMTP id s17so24991401oih.1
        for <netdev@vger.kernel.org>; Mon, 04 Jul 2016 14:36:14 -0700 (PDT)
In-Reply-To: <1467668169-31547-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of open coding our own version utilize the library provided
function.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/rdc/r6040.c | 10 ++--------
 1 file changed, 2 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/rdc/r6040.c b/drivers/net/ethernet/rdc/r6040.c
index 7a7a395d0512..12fc7cd67fa7 100644
--- a/drivers/net/ethernet/rdc/r6040.c
+++ b/drivers/net/ethernet/rdc/r6040.c
@@ -1001,14 +1001,8 @@ static void r6040_adjust_link(struct net_device *dev)
 		lp->old_duplex = phydev->duplex;
 	}
 
-	if (status_changed) {
-		pr_info("%s: link %s", dev->name, phydev->link ?
-			"UP" : "DOWN");
-		if (phydev->link)
-			pr_cont(" - %d/%s", phydev->speed,
-			DUPLEX_FULL == phydev->duplex ? "full" : "half");
-		pr_cont("\n");
-	}
+	if (status_changed)
+		phy_print_status(phydev);
 }
 
 static int r6040_mii_probe(struct net_device *dev)
-- 
2.7.4
