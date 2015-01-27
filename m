From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 1/4] net: phy: utilize phy_suspend and phy_resume
Date: Mon, 26 Jan 2015 16:31:10 -0800
Message-ID: <1422318673-9418-2-git-send-email-f.fainelli@gmail.com>
References: <1422318673-9418-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, s.hauer@pengutronix.de, b38611@freescale.com,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:50901 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756391AbbA0Abk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2015 19:31:40 -0500
Received: by mail-pa0-f43.google.com with SMTP id eu11so14778895pac.2
        for <netdev@vger.kernel.org>; Mon, 26 Jan 2015 16:31:39 -0800 (PST)
In-Reply-To: <1422318673-9418-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

phy_suspend and phy_resume are an abstraction on top of the PHY device
driver suspend and resume callbacks, utilize those since they are the
proper interface to suspending and resuming a PHY device.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/mdio_bus.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/phy/mdio_bus.c b/drivers/net/phy/mdio_bus.c
index 50051f271b10..20447741893a 100644
--- a/drivers/net/phy/mdio_bus.c
+++ b/drivers/net/phy/mdio_bus.c
@@ -465,7 +465,6 @@ static bool mdio_bus_phy_may_suspend(struct phy_device *phydev)
 
 static int mdio_bus_suspend(struct device *dev)
 {
-	struct phy_driver *phydrv = to_phy_driver(dev->driver);
 	struct phy_device *phydev = to_phy_device(dev);
 
 	/* We must stop the state machine manually, otherwise it stops out of
@@ -479,19 +478,18 @@ static int mdio_bus_suspend(struct device *dev)
 	if (!mdio_bus_phy_may_suspend(phydev))
 		return 0;
 
-	return phydrv->suspend(phydev);
+	return phy_suspend(phydev);
 }
 
 static int mdio_bus_resume(struct device *dev)
 {
-	struct phy_driver *phydrv = to_phy_driver(dev->driver);
 	struct phy_device *phydev = to_phy_device(dev);
 	int ret;
 
 	if (!mdio_bus_phy_may_suspend(phydev))
 		goto no_resume;
 
-	ret = phydrv->resume(phydev);
+	ret = phy_resume(phydev);
 	if (ret < 0)
 		return ret;
 
-- 
2.1.0
