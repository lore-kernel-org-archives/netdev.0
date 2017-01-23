From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] phy: marvell: remove conflicting initializer
Date: Mon, 23 Jan 2017 13:18:41 +0100
Message-ID: <20170123121905.3245589-1-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>,
        Charles-Antoine Couret <charles-antoine.couret@nexvision.fr>,
        Clemens Gruber <clemens.gruber@pqgruber.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.135]:62894 "EHLO
        mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751016AbdAWMT2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Jan 2017 07:19:28 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

One line was apparently pasted incorrectly during a new feature patch:

drivers/net/phy/marvell.c:2090:15: error: initialized field overwritten [-Werror=override-init]
   .features = PHY_GBIT_FEATURES,

I'm removing the extraneous line here to avoid the W=1 warning and restore
the previous flags value, and I'm slightly reordering the lines for consistency
to make it less likely to happen again in the future. The ordering in the
array is still not the same as in the structure definition, instead I picked
the order that is most common in this file and that seems to make more sense
here.

Fixes: 0b04680fdae4 ("phy: marvell: Add support for temperature sensor")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/net/phy/marvell.c | 13 ++++++-------
 1 file changed, 6 insertions(+), 7 deletions(-)

diff --git a/drivers/net/phy/marvell.c b/drivers/net/phy/marvell.c
index 64229976ace1..b5b73ff4329a 100644
--- a/drivers/net/phy/marvell.c
+++ b/drivers/net/phy/marvell.c
@@ -1900,8 +1900,8 @@ static struct phy_driver marvell_drivers[] = {
 		.phy_id_mask = MARVELL_PHY_ID_MASK,
 		.name = "Marvell 88E1101",
 		.features = PHY_GBIT_FEATURES,
-		.probe = marvell_probe,
 		.flags = PHY_HAS_INTERRUPT,
+		.probe = marvell_probe,
 		.config_init = &marvell_config_init,
 		.config_aneg = &marvell_config_aneg,
 		.read_status = &genphy_read_status,
@@ -1971,10 +1971,10 @@ static struct phy_driver marvell_drivers[] = {
 		.phy_id = MARVELL_PHY_ID_88E1121R,
 		.phy_id_mask = MARVELL_PHY_ID_MASK,
 		.name = "Marvell 88E1121R",
-		.probe = &m88e1121_probe,
-		.remove = &marvell_remove,
 		.features = PHY_GBIT_FEATURES,
 		.flags = PHY_HAS_INTERRUPT,
+		.probe = &m88e1121_probe,
+		.remove = &marvell_remove,
 		.config_init = &m88e1121_config_init,
 		.config_aneg = &m88e1121_config_aneg,
 		.read_status = &marvell_read_status,
@@ -2085,10 +2085,9 @@ static struct phy_driver marvell_drivers[] = {
 		.phy_id_mask = MARVELL_PHY_ID_MASK,
 		.name = "Marvell 88E1510",
 		.features = PHY_GBIT_FEATURES | SUPPORTED_FIBRE,
+		.flags = PHY_HAS_INTERRUPT,
 		.probe = &m88e1510_probe,
 		.remove = &marvell_remove,
-		.features = PHY_GBIT_FEATURES,
-		.flags = PHY_HAS_INTERRUPT,
 		.config_init = &m88e1510_config_init,
 		.config_aneg = &m88e1510_config_aneg,
 		.read_status = &marvell_read_status,
@@ -2105,10 +2104,10 @@ static struct phy_driver marvell_drivers[] = {
 		.phy_id = MARVELL_PHY_ID_88E1540,
 		.phy_id_mask = MARVELL_PHY_ID_MASK,
 		.name = "Marvell 88E1540",
-		.probe = m88e1510_probe,
-		.remove = &marvell_remove,
 		.features = PHY_GBIT_FEATURES,
 		.flags = PHY_HAS_INTERRUPT,
+		.probe = m88e1510_probe,
+		.remove = &marvell_remove,
 		.config_init = &marvell_config_init,
 		.config_aneg = &m88e1510_config_aneg,
 		.read_status = &marvell_read_status,
-- 
2.9.0
