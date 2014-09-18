From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/11] ixgbe: remove useless bd_number from adapter struct
Date: Thu, 18 Sep 2014 05:26:52 -0700
Message-ID: <1411043221-7163-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1411043221-7163-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Ethan Zhao <ethan.zhao@oracle.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:56568 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751244AbaIRM1E (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Sep 2014 08:27:04 -0400
In-Reply-To: <1411043221-7163-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ethan Zhao <ethan.zhao@oracle.com>

Because bd_number is not useful anymore, so remove it from adapter struct, or
if keep it, we have to fix the boards driven counter bug in ixgbe_remove() and
ixgbe_probe() only for trivial debug purpose -- other output is enough.

Signed-off-by: Ethan Zhao <ethan.zhao@oracle.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe.h      | 2 --
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 4 ----
 2 files changed, 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index 06744f8..75a56fa 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -728,8 +728,6 @@ struct ixgbe_adapter {
 	u8 __iomem *io_addr; /* Mainly for iounmap use */
 	u32 wol;
 
-	u16 bd_number;
-
 	u16 eeprom_verh;
 	u16 eeprom_verl;
 	u16 eeprom_cap;
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 6a12bb1..bcd697c 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -7981,7 +7981,6 @@ static int ixgbe_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	struct ixgbe_adapter *adapter = NULL;
 	struct ixgbe_hw *hw;
 	const struct ixgbe_info *ii = ixgbe_info_tbl[ent->driver_data];
-	static int cards_found;
 	int i, err, pci_using_dac, expected_gts;
 	unsigned int indices = MAX_TX_QUEUES;
 	u8 part_str[IXGBE_PBANUM_LENGTH];
@@ -8067,8 +8066,6 @@ static int ixgbe_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	netdev->watchdog_timeo = 5 * HZ;
 	strlcpy(netdev->name, pci_name(pdev), sizeof(netdev->name));
 
-	adapter->bd_number = cards_found;
-
 	/* Setup hw api */
 	memcpy(&hw->mac.ops, ii->mac_ops, sizeof(hw->mac.ops));
 	hw->mac.type  = ii->mac;
@@ -8352,7 +8349,6 @@ skip_sriov:
 	ixgbe_add_sanmac_netdev(netdev);
 
 	e_dev_info("%s\n", ixgbe_default_device_descr);
-	cards_found++;
 
 #ifdef CONFIG_IXGBE_HWMON
 	if (ixgbe_sysfs_init(adapter))
-- 
1.9.3
