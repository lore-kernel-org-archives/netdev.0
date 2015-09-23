From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH] net: phy: Use IS_ERR_OR_NULL instead of open coding it
Date: Wed, 23 Sep 2015 14:42:30 +0200
Message-ID: <1443012150-29136-1-git-send-email-tklauser@distanz.ch>
Cc: netdev@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.zhinst.com ([212.126.164.98]:35986 "EHLO mail.zhinst.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754612AbbIWMmg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Sep 2015 08:42:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replace the pattern (!phy | IS_ERR(phy)) by the equivalent macro
IS_ERR_OR_NULL()

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 drivers/net/phy/fixed_phy.c | 2 +-
 drivers/net/phy/mdio_bus.c  | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/phy/fixed_phy.c b/drivers/net/phy/fixed_phy.c
index fb1299c..bde4378 100644
--- a/drivers/net/phy/fixed_phy.c
+++ b/drivers/net/phy/fixed_phy.c
@@ -330,7 +330,7 @@ struct phy_device *fixed_phy_register(unsigned int irq,
 		return ERR_PTR(ret);
 
 	phy = get_phy_device(fmb->mii_bus, phy_addr, false);
-	if (!phy || IS_ERR(phy)) {
+	if (IS_ERR_OR_NULL(phy)) {
 		fixed_phy_del(phy_addr);
 		return ERR_PTR(-EINVAL);
 	}
diff --git a/drivers/net/phy/mdio_bus.c b/drivers/net/phy/mdio_bus.c
index 02a4615..4a48d6a 100644
--- a/drivers/net/phy/mdio_bus.c
+++ b/drivers/net/phy/mdio_bus.c
@@ -341,7 +341,7 @@ struct phy_device *mdiobus_scan(struct mii_bus *bus, int addr)
 	int err;
 
 	phydev = get_phy_device(bus, addr, false);
-	if (IS_ERR(phydev) || phydev == NULL)
+	if (IS_ERR_OR_NULL(phydev))
 		return phydev;
 
 	/*
-- 
2.5.0
