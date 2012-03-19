From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 05/10] ixgbe: drop err_eeprom tag which is at same location as err_sw_init
Date: Mon, 19 Mar 2012 14:22:33 -0700
Message-ID: <1332192158-14771-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1332192158-14771-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:5166 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754502Ab2CSVWn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Mar 2012 17:22:43 -0400
In-Reply-To: <1332192158-14771-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

The err_eeprom and err_sw_init tags both go to the same location.  So
instead of maintaining two tags this patch combines them so we only use
err_sw_init.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Stephen Ko <stephen.s.ko@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 73bba8b4..6259619 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -7891,7 +7891,7 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 	if (hw->eeprom.ops.validate_checksum(hw, NULL) < 0) {
 		e_dev_err("The EEPROM Checksum Is Not Valid\n");
 		err = -EIO;
-		goto err_eeprom;
+		goto err_sw_init;
 	}
 
 	memcpy(netdev->dev_addr, hw->mac.perm_addr, netdev->addr_len);
@@ -7900,7 +7900,7 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 	if (ixgbe_validate_mac_addr(netdev->perm_addr)) {
 		e_dev_err("invalid MAC address\n");
 		err = -EIO;
-		goto err_eeprom;
+		goto err_sw_init;
 	}
 
 	setup_timer(&adapter->service_timer, &ixgbe_service_timer,
@@ -8047,7 +8047,6 @@ err_register:
 	ixgbe_release_hw_control(adapter);
 	ixgbe_clear_interrupt_scheme(adapter);
 err_sw_init:
-err_eeprom:
 	if (adapter->flags & IXGBE_FLAG_SRIOV_ENABLED)
 		ixgbe_disable_sriov(adapter);
 	adapter->flags2 &= ~IXGBE_FLAG2_SEARCH_FOR_SFP;
-- 
1.7.7.6
