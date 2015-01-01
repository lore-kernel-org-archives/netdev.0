From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 1/3] e100: fix typo in MDI/MDI-X eeprom check in e100_phy_init
Date: Wed, 31 Dec 2014 16:04:13 -0800
Message-ID: <1420070655-28453-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1420070655-28453-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: "John W. Linville" <linville@tuxdriver.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:8966 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751681AbbAAAES (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Dec 2014 19:04:18 -0500
In-Reply-To: <1420070655-28453-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "John W. Linville" <linville@tuxdriver.com>

Although it doesn't explicitly say so, commit 60ffa478759f39a2 ("e100:
Fix MDIO/MDIO-X") appears to be intended to revert the earlier commit
648951451e6d2d53 ("e100: fixed e100 MDI/MDI-X issues").  However,
careful examination reveals that the attempted revert actually
_inverted_ the test for eeprom_mdix_enabled.  That is bound to program
a few PHYs incorrectly...

https://bugzilla.redhat.com/show_bug.cgi?id=1156417

Signed-off-by: "John W. Linville" <linville@tuxdriver.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e100.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/e100.c b/drivers/net/ethernet/intel/e100.c
index 781065e..e9c3a87 100644
--- a/drivers/net/ethernet/intel/e100.c
+++ b/drivers/net/ethernet/intel/e100.c
@@ -1543,7 +1543,7 @@ static int e100_phy_init(struct nic *nic)
 		mdio_write(netdev, nic->mii.phy_id, MII_BMCR, bmcr);
 	} else if ((nic->mac >= mac_82550_D102) || ((nic->flags & ich) &&
 	   (mdio_read(netdev, nic->mii.phy_id, MII_TPISTATUS) & 0x8000) &&
-		!(nic->eeprom[eeprom_cnfg_mdix] & eeprom_mdix_enabled))) {
+		(nic->eeprom[eeprom_cnfg_mdix] & eeprom_mdix_enabled))) {
 		/* enable/disable MDI/MDI-X auto-switching. */
 		mdio_write(netdev, nic->mii.phy_id, MII_NCONFIG,
 				nic->mii.force_media ? 0 : NCONFIG_AUTO_SWITCH);
-- 
1.9.3
