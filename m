From: Jean-Michel Hautbois <jhautbois@gmail.com>
Subject: [PATCH 2/4] net: phy: printk issues fixed
Date: Sun, 19 Dec 2010 11:58:49 +0100
Message-ID: <1292756331-3735-2-git-send-email-jhautbois@gmail.com>
References: <1292756331-3735-1-git-send-email-jhautbois@gmail.com>
Cc: richard.cochran@omicron.at, shemminger@vyatta.com, tj@kernel.org,
	randy.dunlap@oracle.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Jean-Michel Hautbois <jhautbois@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:41062 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754587Ab0LSK7E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Dec 2010 05:59:04 -0500
In-Reply-To: <1292756331-3735-1-git-send-email-jhautbois@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When calling net link change, pr_info and printk where interleaved.
Changed the way to print messages.

Signed-off-by: Jean-Michel Hautbois <jhautbois@gmail.com>
---
 drivers/net/phy/phy.c |   14 +++++++-------
 1 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index 5f23e8e..4ab48d7 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -44,14 +44,14 @@
  */
 void phy_print_status(struct phy_device *phydev)
 {
-	pr_info("PHY: %s - Link is %s", dev_name(&phydev->dev),
-			phydev->link ? "Up" : "Down");
 	if (phydev->link)
-		printk(" - %d/%s", phydev->speed,
-				DUPLEX_FULL == phydev->duplex ?
-				"Full" : "Half");
-
-	printk("\n");
+		pr_info("PHY: %s - Link is up - %d/%s\n",
+				dev_name(&phydev->dev),
+				phydev->speed,
+				phydev->duplex == DUPLEX_FULL ? "Full" : "Half");
+	else
+		pr_info("PHY: %s - Link is down\n",
+				dev_name(&phydev->dev));
 }
 EXPORT_SYMBOL(phy_print_status);
 
-- 
1.7.0.4

