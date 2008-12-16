From: Andy Fleming <afleming@freescale.com>
Subject: [PATCH] phylib: Remove unnecessary "reset" fixups in genphy_setup_forced
Date: Tue, 16 Dec 2008 17:16:29 -0600
Message-ID: <1229469389-24926-1-git-send-email-afleming@freescale.com>
Cc: netdev@vger.kernel.org, Andy Fleming <afleming@freescale.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:39266 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751392AbYLPXQq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Dec 2008 18:16:46 -0500
Received: from az33smr02.freescale.net (az33smr02.freescale.net [10.64.34.200])
	by az33egw02.freescale.net (8.14.3/az33egw02) with ESMTP id mBGNGVSk012810
	for <netdev@vger.kernel.org>; Tue, 16 Dec 2008 16:16:41 -0700 (MST)
Received: from ld0175-tx32.am.freescale.net (ld0175-tx32.am.freescale.net [10.82.19.125])
	by az33smr02.freescale.net (8.13.1/8.13.0) with ESMTP id mBGNGUwk019119
	for <netdev@vger.kernel.org>; Tue, 16 Dec 2008 17:16:30 -0600 (CST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

genphy_setup_forced hasn't actually reset the PHY for a long time,
but a comment to that effect remained in the code, so code continued
to act as if it *had* reset the PHY, and called the necessary fixup
functions to respond to a PHY reset.  With no reset, those functions
are no longer needed, so we remove them.

Signed-off-by: Andy Fleming <afleming@freescale.com>
---
 drivers/net/phy/phy_device.c |   17 -----------------
 1 files changed, 0 insertions(+), 17 deletions(-)

diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index e976c1c..b312d9c 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -508,23 +508,6 @@ int genphy_setup_forced(struct phy_device *phydev)
 	
 	err = phy_write(phydev, MII_BMCR, ctl);
 
-	if (err < 0)
-		return err;
-
-	/*
-	 * Run the fixups on this PHY, just in case the
-	 * board code needs to change something after a reset
-	 */
-	err = phy_scan_fixups(phydev);
-
-	if (err < 0)
-		return err;
-
-	/* We just reset the device, so we'd better configure any
-	 * settings the PHY requires to operate */
-	if (phydev->drv->config_init)
-		err = phydev->drv->config_init(phydev);
-
 	return err;
 }
 
-- 
1.5.4.GIT

