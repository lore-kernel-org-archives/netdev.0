From: Ruslan Babayev <ruslan@babayev.com>
Subject: [PATCH] phy: check if parent device is NULL
Date: Tue, 20 Dec 2016 15:51:22 -0800 (PST)
Message-ID: <87oa06upl5.fsf@babayev.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: f.fainelli@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:35829 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752011AbcLTXvX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Dec 2016 18:51:23 -0500
Received: by mail-pg0-f65.google.com with SMTP id i5so4330606pgh.2
        for <netdev@vger.kernel.org>; Tue, 20 Dec 2016 15:51:23 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixes a crash observed on Octeon.

Signed-off-by: Ruslan Babayev <ruslan@babayev.com>
Fixes: ec988ad78ed6 ("phy: Don't increment MDIO bus refcount unless it's a
different owner")
---
 drivers/net/phy/phy_device.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index 9c06f8028f0c..043328b85643 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -905,7 +905,8 @@ EXPORT_SYMBOL(phy_attached_print);
 int phy_attach_direct(struct net_device *dev, struct phy_device *phydev,
 		      u32 flags, phy_interface_t interface)
 {
-	struct module *ndev_owner = dev->dev.parent->driver->owner;
+	struct device *parent = dev->dev.parent;
+	struct module *ndev_owner = parent ? parent->driver->owner : NULL;
 	struct mii_bus *bus = phydev->mdio.bus;
 	struct device *d = &phydev->mdio.dev;
 	int err;
-- 
2.7.4
