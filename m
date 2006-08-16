From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 01/13] e100: Fix MDIO/MDIO-X
Date: Wed, 16 Aug 2006 14:56:17 -0700
Message-ID: <20060816215617.27080.97599.stgit@gitlost.site>
References: <20060816215336.27080.56147.stgit@gitlost.site>
Cc: netdev@vger.kernel.org, akpm@osdl.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:52233 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S932251AbWHPVs3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2006 17:48:29 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20060816215336.27080.56147.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


MDIO/MDIO-X was broken due to a wrong errata. Removing the workaround
code fixes for affected NICs.

Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e100.c |   14 +++++---------
 1 files changed, 5 insertions(+), 9 deletions(-)

diff --git a/drivers/net/e100.c b/drivers/net/e100.c
index 91ef5f2..5de9843 100644
--- a/drivers/net/e100.c
+++ b/drivers/net/e100.c
@@ -1391,15 +1391,11 @@ static int e100_phy_init(struct nic *nic
 	}
 
 	if((nic->mac >= mac_82550_D102) || ((nic->flags & ich) &&
-	   (mdio_read(netdev, nic->mii.phy_id, MII_TPISTATUS) & 0x8000))) {
-		/* enable/disable MDI/MDI-X auto-switching.
-		   MDI/MDI-X auto-switching is disabled for 82551ER/QM chips */
-		if((nic->mac == mac_82551_E) || (nic->mac == mac_82551_F) ||
-		   (nic->mac == mac_82551_10) || (nic->mii.force_media) ||
-		   !(nic->eeprom[eeprom_cnfg_mdix] & eeprom_mdix_enabled))
-			mdio_write(netdev, nic->mii.phy_id, MII_NCONFIG, 0);
-		else
-			mdio_write(netdev, nic->mii.phy_id, MII_NCONFIG, NCONFIG_AUTO_SWITCH);
+	   (mdio_read(netdev, nic->mii.phy_id, MII_TPISTATUS) & 0x8000) &&
+		!(nic->eeprom[eeprom_cnfg_mdix] & eeprom_mdix_enabled))) {
+		/* enable/disable MDI/MDI-X auto-switching. */
+		mdio_write(netdev, nic->mii.phy_id, MII_NCONFIG,
+				nic->mii.force_media ? 0 : NCONFIG_AUTO_SWITCH);
 	}
 
 	return 0;



--
Auke Kok <auke-jan.h.kok@intel.com>
