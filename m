From: Domen Puncer <domen.puncer@telargo.com>
Subject: [PATCH] phy layer: fix genphy_setup_forced (don't reset)
Date: Fri, 17 Aug 2007 08:54:45 +0200
Message-ID: <20070817065445.GH13994@moe.telargo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out002.atlarge.net ([129.41.63.60]:17136 "EHLO
	out002.atlarge.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752549AbXHQGyt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Aug 2007 02:54:49 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Writing BMCR_RESET bit will reset MII_BMCR to default values. This is
clearly not what we want.


Signed-off-by: Domen Puncer <domen.puncer@telargo.com>

---
 drivers/net/phy/phy_device.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: work-powerpc.git/drivers/net/phy/phy_device.c
===================================================================
--- work-powerpc.git.orig/drivers/net/phy/phy_device.c
+++ work-powerpc.git/drivers/net/phy/phy_device.c
@@ -364,7 +364,7 @@ EXPORT_SYMBOL(genphy_config_advert);
  */
 int genphy_setup_forced(struct phy_device *phydev)
 {
-	int ctl = BMCR_RESET;
+	int ctl = 0;
 
 	phydev->pause = phydev->asym_pause = 0;
 
