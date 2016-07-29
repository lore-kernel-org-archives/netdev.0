From: Alexander Stein <alexanders83@web.de>
Subject: [PATCH 1/1] phy/micrel: Change phy_id_mask for KSZ8721
Date: Fri, 29 Jul 2016 12:12:08 +0200
Message-ID: <20160729101208.22447-1-alexanders83@web.de>
Cc: Alexander Stein <alexanders83@web.de>, netdev@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.web.de ([212.227.17.12]:64235 "EHLO mout.web.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751586AbcG2KMR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Jul 2016 06:12:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are KSZ8721 PHYs with phy_id 0x00221619. In order to detect them
as PHY_ID_KSZ8001 compatible while staying different to PHY_ID_KSZ9021
ignore the last two bits when matching PHY_ID

Signed-off-by: Alexander Stein <alexanders83@web.de>
---
 drivers/net/phy/micrel.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/phy/micrel.c b/drivers/net/phy/micrel.c
index 5a8fefc25157..469247b9bdc7 100644
--- a/drivers/net/phy/micrel.c
+++ b/drivers/net/phy/micrel.c
@@ -839,7 +839,7 @@ static struct phy_driver ksphy_driver[] = {
 }, {
 	.phy_id		= PHY_ID_KSZ8001,
 	.name		= "Micrel KSZ8001 or KS8721",
-	.phy_id_mask	= 0x00ffffff,
+	.phy_id_mask	= 0x00fffffc,
 	.features	= (PHY_BASIC_FEATURES | SUPPORTED_Pause),
 	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
 	.driver_data	= &ksz8041_type,
@@ -963,7 +963,7 @@ MODULE_LICENSE("GPL");
 static struct mdio_device_id __maybe_unused micrel_tbl[] = {
 	{ PHY_ID_KSZ9021, 0x000ffffe },
 	{ PHY_ID_KSZ9031, MICREL_PHY_ID_MASK },
-	{ PHY_ID_KSZ8001, 0x00ffffff },
+	{ PHY_ID_KSZ8001, 0x00fffffc },
 	{ PHY_ID_KS8737, MICREL_PHY_ID_MASK },
 	{ PHY_ID_KSZ8021, 0x00ffffff },
 	{ PHY_ID_KSZ8031, 0x00ffffff },
-- 
2.9.2
