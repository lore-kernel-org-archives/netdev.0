From: <Woojung.Huh@microchip.com>
Subject: [PATCH net-next 2/3] lan78xx: setting phy features in phy driver
Date: Wed, 10 Feb 2016 21:13:38 +0000
Message-ID: <9235D6609DB808459E95D78E17F2E43D404AB9F9@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exsmtp01.microchip.com ([198.175.253.37]:15541 "EHLO
	email.microchip.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750759AbcBJVNj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Feb 2016 16:13:39 -0500
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Update to set default phy supported & advertising features from phy device
structure and remove unnecessary code in the nic driver.

Signed-off-by: Woojung Huh <woojung.huh@microchip.com>
---
 drivers/net/phy/microchip.c | 10 +++++++++-
 drivers/net/usb/lan78xx.c   |  7 +------
 2 files changed, 10 insertions(+), 7 deletions(-)

diff --git a/drivers/net/phy/microchip.c b/drivers/net/phy/microchip.c
index 15f8206..7a457a4 100644
--- a/drivers/net/phy/microchip.c
+++ b/drivers/net/phy/microchip.c
@@ -106,6 +106,14 @@ static int lan88xx_set_wol(struct phy_device *phydev,
 	return 0;
 }
 
+static int lan88xx_config_init(struct phy_device *phydev)
+{
+	phydev->supported &= phydev->drv->features;
+	phydev->advertising &= phydev->drv->features;
+
+	return 0;
+}
+
 static struct phy_driver microchip_phy_driver[] = {
 {
 	.phy_id		= 0x0007c130,
@@ -119,7 +127,7 @@ static struct phy_driver microchip_phy_driver[] = {
 	.probe		= lan88xx_probe,
 	.remove		= lan88xx_remove,
 
-	.config_init	= genphy_config_init,
+	.config_init	= lan88xx_config_init,
 	.config_aneg	= genphy_config_aneg,
 	.read_status	= genphy_read_status,
 
diff --git a/drivers/net/usb/lan78xx.c b/drivers/net/usb/lan78xx.c
index b14b22d..1fd8072 100644
--- a/drivers/net/usb/lan78xx.c
+++ b/drivers/net/usb/lan78xx.c
@@ -1623,12 +1623,7 @@ static int lan78xx_phy_init(struct lan78xx_net *dev)
 
 	/* MAC doesn't support 1000T Half */
 	phydev->supported &= ~SUPPORTED_1000baseT_Half;
-	phydev->supported |= (SUPPORTED_10baseT_Half |
-			      SUPPORTED_10baseT_Full |
-			      SUPPORTED_100baseT_Half |
-			      SUPPORTED_100baseT_Full |
-			      SUPPORTED_1000baseT_Full |
-			      SUPPORTED_Pause | SUPPORTED_Asym_Pause);
+
 	genphy_config_aneg(phydev);
 
 	phy_start(phydev);
-- 
2.7.0
