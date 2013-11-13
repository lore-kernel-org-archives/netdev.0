From: Daniel Mack <zonque@gmail.com>
Subject: [PATCH 1/2] net: phylib: add adjust_state callback to phy device
Date: Wed, 13 Nov 2013 22:07:49 +0100
Message-ID: <1384376870-7810-1-git-send-email-zonque@gmail.com>
Cc: davem@davemloft.net, marek.belisko@gmail.com, ujhelyi.m@gmail.com,
	Daniel Mack <zonque@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f48.google.com ([209.85.214.48]:35666 "EHLO
	mail-bk0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750895Ab3KMVH5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Nov 2013 16:07:57 -0500
Received: by mail-bk0-f48.google.com with SMTP id v10so84325bkz.7
        for <netdev@vger.kernel.org>; Wed, 13 Nov 2013 13:07:56 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow phy drivers to take action when the core does its link adjustment.
No change for drivers that do not implement this callback.

Signed-off-by: Daniel Mack <zonque@gmail.com>
---
 drivers/net/phy/phy.c | 3 +++
 include/linux/phy.h   | 2 ++
 2 files changed, 5 insertions(+)

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index 36c6994..240e33f 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -748,6 +748,9 @@ void phy_state_machine(struct work_struct *work)
 	if (phydev->adjust_state)
 		phydev->adjust_state(phydev->attached_dev);
 
+	if (phydev->drv->adjust_state)
+		phydev->drv->adjust_state(phydev);
+
 	switch(phydev->state) {
 		case PHY_DOWN:
 		case PHY_STARTING:
diff --git a/include/linux/phy.h b/include/linux/phy.h
index 64ab823..85826eb 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -467,6 +467,8 @@ struct phy_driver {
 	/* See set_wol, but for checking whether Wake on LAN is enabled. */
 	void (*get_wol)(struct phy_device *dev, struct ethtool_wolinfo *wol);
 
+	void (*adjust_state)(struct phy_device *dev);
+
 	struct device_driver driver;
 };
 #define to_phy_driver(d) container_of(d, struct phy_driver, driver)
-- 
1.8.4.2
