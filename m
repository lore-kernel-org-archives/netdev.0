From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net] net: of_mdio: fix of_set_phy_supported after driver probing
Date: Thu, 13 Feb 2014 13:14:48 -0800
Message-ID: <1392326088-3990-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, Florian Fainelli <f.fainelli@gmail.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw3-out.broadcom.com ([216.31.210.64]:38938 "EHLO
	mail-gw3-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751460AbaBMVPV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Feb 2014 16:15:21 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 8fdade4 ("net: of_mdio: parse "max-speed" property to set PHY
supported features") introduced a typo in of_set_phy_supported for the
first assignment of phydev->supported which will not effectively limit
the PHY device supported features bits if the PHY driver contains
"higher" features (e.g: max-speed = <100> and PHY driver has
PHY_GBIT_FEATURES set).

Fix this by making sure that the very first thing is to reset to sane
defaults (PHY_BASIC_FEATURES) and then progressively add speed features
as we parse them.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/of/of_mdio.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/drivers/of/of_mdio.c b/drivers/of/of_mdio.c
index 875b7b6..495facc 100644
--- a/drivers/of/of_mdio.c
+++ b/drivers/of/of_mdio.c
@@ -24,7 +24,11 @@ MODULE_LICENSE("GPL");
 
 static void of_set_phy_supported(struct phy_device *phydev, u32 max_speed)
 {
-	phydev->supported |= PHY_DEFAULT_FEATURES;
+	/* The default values for phydev->supported are provided by the PHY
+	 * driver "features" member, we want to reset to sane defaults fist
+	 * before supporting higher speeds.
+	 */
+	phydev->supported &= PHY_DEFAULT_FEATURES;
 
 	switch (max_speed) {
 	default:
-- 
1.8.3.2
