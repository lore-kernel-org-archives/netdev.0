From: ganesh.venkatesan@intel.com
Subject: [PATCH 5/6 2.5] e100 - Auto MDI/MDI-X support
Date: Thu, 29 Jul 2004 08:27:04 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0407290656460.21929-100000@westville2.jf.intel.com>
Reply-To: ganesh.venkatesan@intel.com
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, <ganesh.venkatesan@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--- linux-2.5/drivers/net/e100.c	2004-07-29 00:28:31.783768664 -0700
+++ linux-2.5/drivers/net/e100.c.mod	2004-07-29 00:28:57.405873512 -0700
@@ -333,11 +333,16 @@ enum eeprom_op {
 };
 
 enum eeprom_offsets {
+	eeprom_cnfg_mdix  = 0x03,
 	eeprom_id         = 0x0A,
 	eeprom_config_asf = 0x0D,
 	eeprom_smbus_addr = 0x90,
 };
 
+enum eeprom_cnfg_mdix {
+	eeprom_mdix_enabled = 0x0080,
+};
+
 enum eeprom_id {
 	eeprom_id_wol = 0x0020,
 };
@@ -1074,7 +1079,9 @@ static int e100_phy_init(struct nic *nic
 		mdio_write(netdev, nic->mii.phy_id, MII_NSC_CONG, cong);
 	}
 
-	if(nic->mac >= mac_82550_D102)
+	if((nic->mac >= mac_82550_D102) || ((nic->flags & ich) && 
+		(mdio_read(netdev, nic->mii.phy_id, MII_TPISTATUS) & 0x8000) && 
+		(nic->eeprom[eeprom_cnfg_mdix] & eeprom_mdix_enabled)))
 		/* enable/disable MDI/MDI-X auto-switching */
 		mdio_write(netdev, nic->mii.phy_id, MII_NCONFIG,
 			nic->mii.force_media ? 0 : NCONFIG_AUTO_SWITCH);
