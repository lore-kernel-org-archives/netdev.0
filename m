From: Kumar Gala <galak@kernel.crashing.org>
Subject: Please pull from 'from_linus' branch
Date: Thu, 28 Jun 2007 13:31:56 -0500 (CDT)
Message-ID: <Pine.LNX.4.64.0706281330290.32589@blarg.am.freescale.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, Andy Fleming <afleming@freescale.com>,
	Jeff Garzik <jeff@garzik.org>, linux-kernel@vger.kernel.org
To: Linus Torvalds <torvalds@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:36210 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1764281AbXF1ScJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Jun 2007 14:32:09 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Please pull from 'for_linus' branch of

	master.kernel.org:/pub/scm/linux/kernel/git/galak/powerpc.git for_linus

to receive the following updates:

 drivers/net/phy/mdio_bus.c |    3 ++-
 drivers/net/phy/vitesse.c  |    2 +-
 2 files changed, 3 insertions(+), 2 deletions(-)

Kumar Gala (1):
      phy: Fix phy_id for Vitesse 824x PHY

commit 5f708dd91d15876e26d7a57f97a255cedffca463
Author: Kumar Gala <galak@kernel.crashing.org>
Date:   Thu Jun 28 13:26:06 2007 -0500

    phy: Fix phy_id for Vitesse 824x PHY

    The phy_id specified for the Vitesse 824x PHY would never match because
    it was expecting bits to be set that would be masked by the phy_id_mask.
    Fix the phy_id so it will match properly, and changed the mdio_bus_match
    to mask both the driver and devices phy_id with the mask so we dont have
    this issue in the future.

    Signed-off-by: Kumar Gala <galak@kernel.crashing.org>

diff --git a/drivers/net/phy/mdio_bus.c b/drivers/net/phy/mdio_bus.c
index fc4aee9..fc2f0e6 100644
--- a/drivers/net/phy/mdio_bus.c
+++ b/drivers/net/phy/mdio_bus.c
@@ -131,7 +131,8 @@ static int mdio_bus_match(struct device *dev, struct device_driver *drv)
 	struct phy_device *phydev = to_phy_device(dev);
 	struct phy_driver *phydrv = to_phy_driver(drv);

-	return (phydrv->phy_id == (phydev->phy_id & phydrv->phy_id_mask));
+	return ((phydrv->phy_id & phydrv->phy_id_mask) ==
+		(phydev->phy_id & phydrv->phy_id_mask));
 }

 /* Suspend and resume.  Copied from platform_suspend and
diff --git a/drivers/net/phy/vitesse.c b/drivers/net/phy/vitesse.c
index 792716b..596222b 100644
--- a/drivers/net/phy/vitesse.c
+++ b/drivers/net/phy/vitesse.c
@@ -84,7 +84,7 @@ static int vsc824x_config_intr(struct phy_device *phydev)

 /* Vitesse 824x */
 static struct phy_driver vsc8244_driver = {
-	.phy_id		= 0x000fc6c2,
+	.phy_id		= 0x000fc6c0,
 	.name		= "Vitesse VSC8244",
 	.phy_id_mask	= 0x000fffc0,
 	.features	= PHY_GBIT_FEATURES,
