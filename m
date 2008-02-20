From: Adrian Bunk <bunk@kernel.org>
Subject: [2.6 patch] net/phy/mdio_bus.c: fix a check-after-use
Date: Wed, 20 Feb 2008 02:13:53 +0200
Message-ID: <20080220001353.GV31955@cs181133002.pp.htv.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4.pp.htv.fi ([213.243.153.38]:36211 "EHLO smtp4.pp.htv.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758742AbYBTAOa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Feb 2008 19:14:30 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes a check-after-use spotted by the Coverity checker.

Signed-off-by: Adrian Bunk <bunk@kernel.org>

---
6beeb3ac577d74d72b2f91bd654eecb904c3c17e diff --git a/drivers/net/phy/mdio_bus.c b/drivers/net/phy/mdio_bus.c
index 6e9f619..963630c 100644
--- a/drivers/net/phy/mdio_bus.c
+++ b/drivers/net/phy/mdio_bus.c
@@ -49,13 +49,13 @@ int mdiobus_register(struct mii_bus *bus)
 	int i;
 	int err = 0;
 
-	mutex_init(&bus->mdio_lock);
-
 	if (NULL == bus || NULL == bus->name ||
 			NULL == bus->read ||
 			NULL == bus->write)
 		return -EINVAL;
 
+	mutex_init(&bus->mdio_lock);
+
 	if (bus->reset)
 		bus->reset(bus);
 

