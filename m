From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next] net: phy: use network device in phy_print_status
Date: Wed, 22 Jan 2014 10:32:33 -0800
Message-ID: <1390415553-4961-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, Florian Fainelli <f.fainelli@gmail.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw2-out.broadcom.com ([216.31.210.63]:64762 "EHLO
	mail-gw2-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751379AbaAVSdH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jan 2014 13:33:07 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

phy_print_status() currently uses dev_name(&phydev->dev) which will
usually result in printing something along those lines for Device Tree
aware drivers:

libphy: f0b60000.etherne:0a - Link is Down
libphy: f0ba0000.etherne:00 - Link is Up - 1000/Full

This is not terribly useful for network administrators or users since we
expect a network interface name to be able to correlate link events with
interfaces. Update phy_print_status() to use netdev_info() with
phydev->attached_dev which is the backing network device for our PHY
device.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/phy.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index 19c9eca..8acf57f 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -45,12 +45,11 @@
 void phy_print_status(struct phy_device *phydev)
 {
 	if (phydev->link) {
-		pr_info("%s - Link is Up - %d/%s\n",
-			dev_name(&phydev->dev),
+		netdev_info(phydev->attached_dev, "- Link is Up - %d/%s\n",
 			phydev->speed,
 			DUPLEX_FULL == phydev->duplex ? "Full" : "Half");
 	} else	{
-		pr_info("%s - Link is Down\n", dev_name(&phydev->dev));
+		netdev_info(phydev->attached_dev, "- Link is Down\n");
 	}
 }
 EXPORT_SYMBOL(phy_print_status);
-- 
1.8.3.2
