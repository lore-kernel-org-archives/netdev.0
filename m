From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/14] e1000e: Cleanup consistency in ret_val variable usage
Date: Fri, 13 May 2016 16:43:43 -0700
Message-ID: <1463183035-31888-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1463183035-31888-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Brian Walsh <brian@walsh.ws>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:49411 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932081AbcEMXn6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 May 2016 19:43:58 -0400
In-Reply-To: <1463183035-31888-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Brian Walsh <brian@walsh.ws>

Fixed the file to use a consistent ret_val for return value checking.

Signed-off-by: Brian Walsh <brian@walsh.ws>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/netdev.c | 22 +++++++++++-----------
 1 file changed, 11 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 269087c..671256d 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -3368,12 +3368,12 @@ static int e1000e_write_uc_addr_list(struct net_device *netdev)
 		 * combining
 		 */
 		netdev_for_each_uc_addr(ha, netdev) {
-			int rval;
+			int ret_val;
 
 			if (!rar_entries)
 				break;
-			rval = hw->mac.ops.rar_set(hw, ha->addr, rar_entries--);
-			if (rval < 0)
+			ret_val = hw->mac.ops.rar_set(hw, ha->addr, rar_entries--);
+			if (ret_val < 0)
 				return -ENOMEM;
 			count++;
 		}
@@ -6965,7 +6965,7 @@ static int e1000_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	int bars, i, err, pci_using_dac;
 	u16 eeprom_data = 0;
 	u16 eeprom_apme_mask = E1000_EEPROM_APME;
-	s32 rval = 0;
+	s32 ret_val = 0;
 
 	if (ei->flags2 & FLAG2_DISABLE_ASPM_L0S)
 		aspm_disable_flag = PCIE_LINK_STATE_L0S;
@@ -7200,18 +7200,18 @@ static int e1000_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	} else if (adapter->flags & FLAG_APME_IN_CTRL3) {
 		if (adapter->flags & FLAG_APME_CHECK_PORT_B &&
 		    (adapter->hw.bus.func == 1))
-			rval = e1000_read_nvm(&adapter->hw,
+			ret_val = e1000_read_nvm(&adapter->hw,
 					      NVM_INIT_CONTROL3_PORT_B,
 					      1, &eeprom_data);
 		else
-			rval = e1000_read_nvm(&adapter->hw,
+			ret_val = e1000_read_nvm(&adapter->hw,
 					      NVM_INIT_CONTROL3_PORT_A,
 					      1, &eeprom_data);
 	}
 
 	/* fetch WoL from EEPROM */
-	if (rval)
-		e_dbg("NVM read error getting WoL initial values: %d\n", rval);
+	if (ret_val)
+		e_dbg("NVM read error getting WoL initial values: %d\n", ret_val);
 	else if (eeprom_data & eeprom_apme_mask)
 		adapter->eeprom_wol |= E1000_WUFC_MAG;
 
@@ -7231,10 +7231,10 @@ static int e1000_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		device_wakeup_enable(&pdev->dev);
 
 	/* save off EEPROM version number */
-	rval = e1000_read_nvm(&adapter->hw, 5, 1, &adapter->eeprom_vers);
+	ret_val = e1000_read_nvm(&adapter->hw, 5, 1, &adapter->eeprom_vers);
 
-	if (rval) {
-		e_dbg("NVM read error getting EEPROM version: %d\n", rval);
+	if (ret_val) {
+		e_dbg("NVM read error getting EEPROM version: %d\n", ret_val);
 		adapter->eeprom_vers = 0;
 	}
 
-- 
2.5.5
