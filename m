From: Aaron Brown <aaron.f.brown@intel.com>
Subject: [net-next 1/3] ixgbe: Restore hw_addr in LER recovery paths
Date: Wed, 19 Feb 2014 20:45:19 -0800
Message-ID: <1392871521-7731-2-git-send-email-aaron.f.brown@intel.com>
References: <1392871521-7731-1-git-send-email-aaron.f.brown@intel.com>
Cc: Mark Rustad <mark.d.rustad@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Aaron Brown <aaron.f.brown@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:30889 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753459AbaBTEsL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Feb 2014 23:48:11 -0500
In-Reply-To: <1392871521-7731-1-git-send-email-aaron.f.brown@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Rustad <mark.d.rustad@intel.com>

The hw_addr needs to be restored in the pcie recovery path or
else the device will be perpetually removed. Also restore the
value in the resume path.

Signed-off-by: Mark Rustad <mark.d.rustad@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Aaron Brown <aaron.f.brown@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 18076c4..b7e9f1c 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 10 Gigabit PCI Express Linux driver
-  Copyright(c) 1999 - 2013 Intel Corporation.
+  Copyright(c) 1999 - 2014 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
@@ -67,7 +67,7 @@ static char ixgbe_default_device_descr[] =
 #define DRV_VERSION "3.19.1-k"
 const char ixgbe_driver_version[] = DRV_VERSION;
 static const char ixgbe_copyright[] =
-				"Copyright (c) 1999-2013 Intel Corporation.";
+				"Copyright (c) 1999-2014 Intel Corporation.";
 
 static const struct ixgbe_info *ixgbe_info_tbl[] = {
 	[board_82598] = &ixgbe_82598_info,
@@ -5502,6 +5502,7 @@ static int ixgbe_resume(struct pci_dev *pdev)
 	struct net_device *netdev = adapter->netdev;
 	u32 err;
 
+	adapter->hw.hw_addr = adapter->io_addr;
 	pci_set_power_state(pdev, PCI_D0);
 	pci_restore_state(pdev);
 	/*
@@ -8446,6 +8447,7 @@ static pci_ers_result_t ixgbe_io_slot_reset(struct pci_dev *pdev)
 		e_err(probe, "Cannot re-enable PCI device after reset.\n");
 		result = PCI_ERS_RESULT_DISCONNECT;
 	} else {
+		adapter->hw.hw_addr = adapter->io_addr;
 		pci_set_master(pdev);
 		pci_restore_state(pdev);
 		pci_save_state(pdev);
-- 
1.8.5.GIT
