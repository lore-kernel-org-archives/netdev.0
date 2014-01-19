From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next] phy: cleanup 10g code
Date: Sun, 19 Jan 2014 11:48:20 -0800
Message-ID: <20140119114820.028fa940@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Andy Fleming <afleming@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:51485 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751727AbaASTsX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Jan 2014 14:48:23 -0500
Received: by mail-pa0-f53.google.com with SMTP id lj1so6144349pab.40
        for <netdev@vger.kernel.org>; Sun, 19 Jan 2014 11:48:23 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Code should avoid needless exports, don't export something unless it used.
Make local functions static and remove unused stubs.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>


--- a/drivers/net/phy/phy_device.c	2014-01-14 09:46:20.709651675 -0800
+++ b/drivers/net/phy/phy_device.c	2014-01-18 14:29:37.163405318 -0800
@@ -767,12 +767,6 @@ static int genphy_config_advert(struct p
 	return changed;
 }
 
-int gen10g_config_advert(struct phy_device *dev)
-{
-	return 0;
-}
-EXPORT_SYMBOL(gen10g_config_advert);
-
 /**
  * genphy_setup_forced - configures/forces speed/duplex from @phydev
  * @phydev: target phy_device struct
@@ -820,12 +814,6 @@ int genphy_restart_aneg(struct phy_devic
 }
 EXPORT_SYMBOL(genphy_restart_aneg);
 
-int gen10g_restart_aneg(struct phy_device *phydev)
-{
-	return 0;
-}
-EXPORT_SYMBOL(gen10g_restart_aneg);
-
 /**
  * genphy_config_aneg - restart auto-negotiation or write BMCR
  * @phydev: target phy_device struct
@@ -867,11 +855,10 @@ int genphy_config_aneg(struct phy_device
 }
 EXPORT_SYMBOL(genphy_config_aneg);
 
-int gen10g_config_aneg(struct phy_device *phydev)
+static int gen10g_config_aneg(struct phy_device *phydev)
 {
 	return 0;
 }
-EXPORT_SYMBOL(gen10g_config_aneg);
 
 /**
  * genphy_update_link - update link status in @phydev
@@ -1004,7 +991,7 @@ int genphy_read_status(struct phy_device
 }
 EXPORT_SYMBOL(genphy_read_status);
 
-int gen10g_read_status(struct phy_device *phydev)
+static int gen10g_read_status(struct phy_device *phydev)
 {
 	int devad, reg;
 	u32 mmd_mask = phydev->c45_ids.devices_in_package;
@@ -1030,7 +1017,6 @@ int gen10g_read_status(struct phy_device
 
 	return 0;
 }
-EXPORT_SYMBOL(gen10g_read_status);
 
 static int genphy_config_init(struct phy_device *phydev)
 {
@@ -1102,11 +1088,10 @@ int genphy_suspend(struct phy_device *ph
 }
 EXPORT_SYMBOL(genphy_suspend);
 
-int gen10g_suspend(struct phy_device *phydev)
+static int gen10g_suspend(struct phy_device *phydev)
 {
 	return 0;
 }
-EXPORT_SYMBOL(gen10g_suspend);
 
 int genphy_resume(struct phy_device *phydev)
 {
@@ -1123,11 +1108,10 @@ int genphy_resume(struct phy_device *phy
 }
 EXPORT_SYMBOL(genphy_resume);
 
-int gen10g_resume(struct phy_device *phydev)
+static int gen10g_resume(struct phy_device *phydev)
 {
 	return 0;
 }
-EXPORT_SYMBOL(gen10g_resume);
 
 /**
  * phy_probe - probe and init a PHY device
