From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next] net: phy: properly report internal PHYs through sysfs
Date: Wed, 27 Aug 2014 11:44:33 -0700
Message-ID: <1409165073-26983-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f172.google.com ([209.85.214.172]:65405 "EHLO
	mail-ob0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933812AbaH0SpI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2014 14:45:08 -0400
Received: by mail-ob0-f172.google.com with SMTP id wn1so519523obc.17
        for <netdev@vger.kernel.org>; Wed, 27 Aug 2014 11:45:07 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Internal PHYs may not have a valid PHY interface defined, which will
show up in sysfs as "". Add an explicit check of internal PHYs to report
their interface correctly.

Fixes: 3d055d8d1c24 ("net: phy: expose PHY device interface mode")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/mdio_bus.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/drivers/net/phy/mdio_bus.c b/drivers/net/phy/mdio_bus.c
index 4eaadcfcb0fe..50051f271b10 100644
--- a/drivers/net/phy/mdio_bus.c
+++ b/drivers/net/phy/mdio_bus.c
@@ -553,8 +553,14 @@ static ssize_t
 phy_interface_show(struct device *dev, struct device_attribute *attr, char *buf)
 {
 	struct phy_device *phydev = to_phy_device(dev);
+	const char *mode = NULL;
 
-	return sprintf(buf, "%s\n", phy_modes(phydev->interface));
+	if (phy_is_internal(phydev))
+		mode = "internal";
+	else
+		mode = phy_modes(phydev->interface);
+
+	return sprintf(buf, "%s\n", mode);
 }
 static DEVICE_ATTR_RO(phy_interface);
 
-- 
1.9.1
