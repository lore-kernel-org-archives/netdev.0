From: Malli Chilakala <mallikarjuna.chilakala@intel.com>
Subject: [PATCH net-drivers-2.6 5/10] e1000: Fix WOL settings in 82544 based
 adapters
Date: Tue, 15 Feb 2005 13:28:17 -0800 (PST)
Message-ID: <Pine.LNX.4.44.0502151114480.30336-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev <netdev@oss.sgi.com>
To: "jgarzik@pobox.com" <jgarzik@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

5 Fix WOL settings in 82544 based adapters
Signed-off-by: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>
Signed-off-by: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Signed-off-by: John Ronciak <john.ronciak@intel.com>
diff -up net-drivers-2.6/drivers/net/e1000/e1000.h net-drivers-2.6/drivers/net/e1000.new/e1000.h
--- net-drivers-2.6/drivers/net/e1000/e1000.h	2005-02-01 23:10:24.986106336 -0800
+++ net-drivers-2.6/drivers/net/e1000.new/e1000.h	2005-02-01 23:10:26.474880008 -0800
@@ -138,6 +138,7 @@ struct e1000_adapter;
 #define E1000_RX_BUFFER_WRITE	16	/* Must be power of 2 */
 
 #define AUTO_ALL_MODES       0
+#define E1000_EEPROM_82544_APM 0x0004
 #define E1000_EEPROM_APME    0x0400
 
 #ifndef E1000_MASTER_SLAVE
diff -up net-drivers-2.6/drivers/net/e1000/e1000_main.c net-drivers-2.6/drivers/net/e1000.new/e1000_main.c
--- net-drivers-2.6/drivers/net/e1000/e1000_main.c	2005-02-01 23:10:24.989105880 -0800
+++ net-drivers-2.6/drivers/net/e1000.new/e1000_main.c	2005-02-01 23:10:26.709844288 -0800
@@ -421,6 +421,7 @@ e1000_probe(struct pci_dev *pdev,
 	int i;
 	int err;
 	uint16_t eeprom_data;
+	uint16_t eeprom_apme_mask = E1000_EEPROM_APME;
 
 	if((err = pci_enable_device(pdev)))
 		return err;
@@ -591,6 +591,11 @@ e1000_probe(struct pci_dev *pdev,
 	case e1000_82542_rev2_1:
 	case e1000_82543:
 		break;
+	case e1000_82544:
+		e1000_read_eeprom(&adapter->hw,
+			EEPROM_INIT_CONTROL2_REG, 1, &eeprom_data);
+		eeprom_apme_mask = E1000_EEPROM_82544_APM;
+		break;
 	case e1000_82546:
 	case e1000_82546_rev_3:
 		if((E1000_READ_REG(&adapter->hw, STATUS) & E1000_STATUS_FUNC_1)
@@ -605,7 +611,7 @@ e1000_probe(struct pci_dev *pdev,
 			EEPROM_INIT_CONTROL3_PORT_A, 1, &eeprom_data);
 		break;
 	}
-	if(eeprom_data & E1000_EEPROM_APME)
+	if(eeprom_data & eeprom_apme_mask)
 		adapter->wol |= E1000_WUFC_MAG;
 
 	/* reset the hardware with the new settings */
	
