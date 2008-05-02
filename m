From: Andy Fleming <afleming@freescale.com>
Subject: [PATCH v2.6.26] phylib: Fix some sparse warnings
Date: Fri,  2 May 2008 13:00:51 -0500
Message-ID: <1209751251-25508-1-git-send-email-afleming@freescale.com>
Cc: netdev@vger.kernel.org, Andy Fleming <afleming@freescale.com>
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw01.freescale.net ([192.88.158.102]:46396 "EHLO
	az33egw01.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758045AbYEBSAy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 May 2008 14:00:54 -0400
Received: from az33smr02.freescale.net (az33smr02.freescale.net [10.64.34.200])
	by az33egw01.freescale.net (8.12.11/az33egw01) with ESMTP id m42I0qsn008389
	for <netdev@vger.kernel.org>; Fri, 2 May 2008 11:00:52 -0700 (MST)
Received: from ld0175-tx32.am.freescale.net (ld0175-tx32.am.freescale.net [10.82.19.125])
	by az33smr02.freescale.net (8.13.1/8.13.0) with ESMTP id m42I0p3j013352
	for <netdev@vger.kernel.org>; Fri, 2 May 2008 13:00:51 -0500 (CDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Declared some things static, declared some things in the header.

Signed-off-by: Andy Fleming <afleming@freescale.com>
---
 drivers/net/phy/phy.c |    2 +-
 include/linux/phy.h   |    5 +++++
 2 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index 3c18bb5..45cc291 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -547,7 +547,7 @@ static void phy_force_reduction(struct phy_device *phydev)
  * Must not be called from interrupt context, or while the
  * phydev->lock is held.
  */
-void phy_error(struct phy_device *phydev)
+static void phy_error(struct phy_device *phydev)
 {
 	mutex_lock(&phydev->lock);
 	phydev->state = PHY_HALTED;
diff --git a/include/linux/phy.h b/include/linux/phy.h
index 02df20f..7224c40 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -412,6 +412,8 @@ int mdiobus_register(struct mii_bus *bus);
 void mdiobus_unregister(struct mii_bus *bus);
 void phy_sanitize_settings(struct phy_device *phydev);
 int phy_stop_interrupts(struct phy_device *phydev);
+int phy_enable_interrupts(struct phy_device *phydev);
+int phy_disable_interrupts(struct phy_device *phydev);
 
 static inline int phy_read_status(struct phy_device *phydev) {
 	return phydev->drv->read_status(phydev);
@@ -447,5 +449,8 @@ int phy_register_fixup_for_uid(u32 phy_uid, u32 phy_uid_mask,
 		int (*run)(struct phy_device *));
 int phy_scan_fixups(struct phy_device *phydev);
 
+int __init mdio_bus_init(void);
+void mdio_bus_exit(void);
+
 extern struct bus_type mdio_bus_type;
 #endif /* __PHY_H */
-- 
1.5.4.GIT

