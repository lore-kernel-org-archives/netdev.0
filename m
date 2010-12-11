From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH 14/27] ixgbe: cleanup string function calls to use bound checking versions.
Date: Fri, 10 Dec 2010 22:19:01 -0800
Message-ID: <1292048354-22076-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1292048354-22076-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Don Skidmore <donald.c.skidmore@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta05.emeryville.ca.mail.comcast.net ([76.96.30.48]:36917 "EHLO
	qmta05.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751576Ab0LKGTX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Dec 2010 01:19:23 -0500
To: davem@davemloft.net
In-Reply-To: <1292048354-22076-1-git-send-email-jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

Some minor cleanup to use string calls that use bound checks just to
be extra safe.

Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Tested-by: Stephen Ko <stephen.s.ko@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe_ethtool.c |    5 +++--
 drivers/net/ixgbe/ixgbe_main.c    |   16 ++++++++--------
 2 files changed, 11 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index f2245ac..23ff23e 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -839,9 +839,10 @@ static void ixgbe_get_drvinfo(struct net_device *netdev,
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 	char firmware_version[32];
 
-	strncpy(drvinfo->driver, ixgbe_driver_name, sizeof(drvinfo->driver));
+	strncpy(drvinfo->driver, ixgbe_driver_name,
+	        sizeof(drvinfo->driver) - 1);
 	strncpy(drvinfo->version, ixgbe_driver_version,
-	        sizeof(drvinfo->version));
+	        sizeof(drvinfo->version) - 1);
 
 	snprintf(firmware_version, sizeof(firmware_version), "%d.%d-%d",
 	         (adapter->eeprom_version & 0xF000) >> 12,
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index f2694f2..8af0fc0 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -2338,14 +2338,14 @@ static int ixgbe_request_msix_irqs(struct ixgbe_adapter *adapter)
 		handler = SET_HANDLER(q_vector);
 
 		if (handler == &ixgbe_msix_clean_rx) {
-			sprintf(q_vector->name, "%s-%s-%d",
-				netdev->name, "rx", ri++);
+			snprintf(q_vector->name, sizeof(q_vector->name) - 1,
+			         "%s-%s-%d", netdev->name, "rx", ri++);
 		} else if (handler == &ixgbe_msix_clean_tx) {
-			sprintf(q_vector->name, "%s-%s-%d",
-				netdev->name, "tx", ti++);
+			snprintf(q_vector->name, sizeof(q_vector->name) - 1,
+			         "%s-%s-%d", netdev->name, "tx", ti++);
 		} else if (handler == &ixgbe_msix_clean_many) {
-			sprintf(q_vector->name, "%s-%s-%d",
-				netdev->name, "TxRx", ri++);
+			snprintf(q_vector->name, sizeof(q_vector->name) - 1,
+			         "%s-%s-%d", netdev->name, "TxRx", ri++);
 			ti++;
 		} else {
 			/* skip this unused q_vector */
@@ -7047,7 +7047,7 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 	netdev->netdev_ops = &ixgbe_netdev_ops;
 	ixgbe_set_ethtool_ops(netdev);
 	netdev->watchdog_timeo = 5 * HZ;
-	strcpy(netdev->name, pci_name(pdev));
+	strncpy(netdev->name, pci_name(pdev), sizeof(netdev->name) - 1);
 
 	adapter->bd_number = cards_found;
 
@@ -7269,7 +7269,7 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 
 	err = ixgbe_read_pba_string_generic(hw, part_str, IXGBE_PBANUM_LENGTH);
 	if (err)
-		strcpy(part_str, "Unknown");
+		strncpy(part_str, "Unknown", IXGBE_PBANUM_LENGTH);
 	if (ixgbe_is_sfp(hw) && hw->phy.sfp_type != ixgbe_sfp_type_not_present)
 		e_dev_info("MAC: %d, PHY: %d, SFP+: %d, PBA No: %s\n",
 			   hw->mac.type, hw->phy.type, hw->phy.sfp_type,
-- 
1.7.3.2

