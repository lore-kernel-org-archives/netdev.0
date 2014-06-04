From: Daniel Mack <zonque@gmail.com>
Subject: [PATCH 1/3] net: phylib: add adjust_state callback to phy device
Date: Wed,  4 Jun 2014 11:00:37 +0200
Message-ID: <1401872439-30107-2-git-send-email-zonque@gmail.com>
References: <1401872439-30107-1-git-send-email-zonque@gmail.com>
Cc: davem@davemloft.net, marek.belisko@gmail.com, ujhelyi.m@gmail.com,
	Daniel Mack <zonque@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f42.google.com ([74.125.82.42]:53841 "EHLO
	mail-wg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751410AbaFDJAz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jun 2014 05:00:55 -0400
Received: by mail-wg0-f42.google.com with SMTP id y10so7921633wgg.25
        for <netdev@vger.kernel.org>; Wed, 04 Jun 2014 02:00:54 -0700 (PDT)
In-Reply-To: <1401872439-30107-1-git-send-email-zonque@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow phy drivers to take action when the core does its link adjustment.
No change for drivers that do not implement this callback.

Signed-off-by: Daniel Mack <zonque@gmail.com>
---
 drivers/net/phy/phy.c | 3 +++
 include/linux/phy.h   | 3 +++
 2 files changed, 6 insertions(+)

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index 3bc079a..f9c5577 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -720,6 +720,9 @@ void phy_state_machine(struct work_struct *work)
 
 	mutex_lock(&phydev->lock);
 
+	if (phydev->drv->adjust_state)
+		phydev->drv->adjust_state(phydev);
+
 	switch (phydev->state) {
 	case PHY_DOWN:
 	case PHY_STARTING:
diff --git a/include/linux/phy.h b/include/linux/phy.h
index 51d15f6..27cbdf4 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -529,6 +529,9 @@ struct phy_driver {
 	/* See set_wol, but for checking whether Wake on LAN is enabled. */
 	void (*get_wol)(struct phy_device *dev, struct ethtool_wolinfo *wol);
 
+	/* Called when the PHY core adjusts the link of a PHY device */
+	void (*adjust_state)(struct phy_device *dev);
+
 	struct device_driver driver;
 };
 #define to_phy_driver(d) container_of(d, struct phy_driver, driver)
-- 
1.9.3
