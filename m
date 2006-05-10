From: Herbert Valerio Riedel <hvr@gnu.org>
Subject: [PATCH] phy: mdiobus_register(): initialize all phy_map entries
Date: Wed, 10 May 2006 12:12:57 -0400
Message-ID: <E1FdrJ3-00030d-LS@fencepost.gnu.org>
Cc: Andy Fleming <afleming@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fencepost.gnu.org ([199.232.76.164]:56043 "EHLO
	fencepost.gnu.org") by vger.kernel.org with ESMTP id S965003AbWEJQM7
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 May 2006 12:12:59 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


make sure phy_map entries whose PHY address is masked are initialized
to NULL, given that other code (such as mdiobus_unregister for
instance) assumes that non-NULL phy_map entries are allocated
phy_devices

Signed-off-by: Herbert Valerio Riedel <hvr@gnu.org>
---

 drivers/net/phy/mdio_bus.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

Index: b/drivers/net/phy/mdio_bus.c
===================================================================
--- a/drivers/net/phy/mdio_bus.c	2006-05-10 17:02:12.000000000 +0200
+++ b/drivers/net/phy/mdio_bus.c	2006-05-10 17:05:27.000000000 +0200
@@ -60,8 +60,10 @@
 	for (i = 0; i < PHY_MAX_ADDR; i++) {
 		struct phy_device *phydev;
 
-		if (bus->phy_mask & (1 << i))
+		if (bus->phy_mask & (1 << i)) {
+			bus->phy_map[i] = NULL;
 			continue;
+		}
 
 		phydev = get_phy_device(bus, i);
 
-- 
