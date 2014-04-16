From: Daniel Mack <zonque@gmail.com>
Subject: [PATCH net-next RESEND 1/2] net: phy: export genphy_config_init()
Date: Wed, 16 Apr 2014 17:19:12 +0200
Message-ID: <1397661553-22117-1-git-send-email-zonque@gmail.com>
Cc: davem@davemloft.net, mugunthanvnm@ti.com, ujhelyi.m@gmail.com,
	Daniel Mack <zonque@gmail.com>
To: netdev@vger.kernel.org, f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f52.google.com ([74.125.83.52]:39234 "EHLO
	mail-ee0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161692AbaDPPTe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Apr 2014 11:19:34 -0400
Received: by mail-ee0-f52.google.com with SMTP id e49so8960390eek.39
        for <netdev@vger.kernel.org>; Wed, 16 Apr 2014 08:19:33 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This enables other drivers to call this generic implementation, and then
only do specific details on top of it.

Signed-off-by: Daniel Mack <zonque@gmail.com>
---
Resending this after 3.15-rc1 has been released, assuming that the
net-next tree is now open again.

 drivers/net/phy/phy_device.c | 3 ++-
 include/linux/phy.h          | 1 +
 2 files changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index 2f6989b..84485ea 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -1029,7 +1029,7 @@ static int gen10g_read_status(struct phy_device *phydev)
 	return 0;
 }
 
-static int genphy_config_init(struct phy_device *phydev)
+int genphy_config_init(struct phy_device *phydev)
 {
 	int val;
 	u32 features;
@@ -1074,6 +1074,7 @@ static int genphy_config_init(struct phy_device *phydev)
 
 	return 0;
 }
+EXPORT_SYMBOL(genphy_config_init);
 
 static int gen10g_config_init(struct phy_device *phydev)
 {
diff --git a/include/linux/phy.h b/include/linux/phy.h
index 565188c..dcf7f13 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -609,6 +609,7 @@ static inline int phy_read_status(struct phy_device *phydev)
 	return phydev->drv->read_status(phydev);
 }
 
+int genphy_config_init(struct phy_device *phydev);
 int genphy_setup_forced(struct phy_device *phydev);
 int genphy_restart_aneg(struct phy_device *phydev);
 int genphy_config_aneg(struct phy_device *phydev);
-- 
1.9.0
