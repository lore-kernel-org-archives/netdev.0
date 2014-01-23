From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2 2/4] net: phy: update phy_print_status to show pause settings
Date: Thu, 23 Jan 2014 12:17:47 -0800
Message-ID: <1390508269-28769-3-git-send-email-f.fainelli@gmail.com>
References: <1390508269-28769-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <joe@perches.com>,
	Florian Fainelli <f.fainelli@gmail.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw3-out.broadcom.com ([216.31.210.64]:41025 "EHLO
	mail-gw3-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753190AbaAWUSL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jan 2014 15:18:11 -0500
In-Reply-To: <1390508269-28769-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update phy_print_status() to also display the PHY device pause settings
(rx/tx or off).

Suggested-by: Joe Perches <joe@perches.com>
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/phy.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index c35b2e7..8ae2260 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -45,9 +45,11 @@
 void phy_print_status(struct phy_device *phydev)
 {
 	if (phydev->link) {
-		netdev_info(phydev->attached_dev, "Link is Up - %d/%s\n",
+		netdev_info(phydev->attached_dev,
+			"Link is Up - %d/%s - flow control %s\n",
 			phydev->speed,
-			DUPLEX_FULL == phydev->duplex ? "Full" : "Half");
+			DUPLEX_FULL == phydev->duplex ? "Full" : "Half",
+			phydev->pause ? "rx/tx" : "off");
 	} else	{
 		netdev_info(phydev->attached_dev, "Link is Down\n");
 	}
-- 
1.8.3.2
