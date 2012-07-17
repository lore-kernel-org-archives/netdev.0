From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 2/8] ixgbevf: Drop netdev_registered value since that is already stored in netdev
Date: Tue, 17 Jul 2012 03:09:13 -0700
Message-ID: <1342519759-25137-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1342519759-25137-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:49016 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755116Ab2GQKJX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Jul 2012 06:09:23 -0400
In-Reply-To: <1342519759-25137-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

There is no need to keep a separate netdev_registered value since that is
already stored in the netdev itself.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Acked-by: Greg Rose <gregory.v.rose@intel.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf.h      |    1 -
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |    6 +-----
 2 files changed, 1 insertion(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
index 0cbce49..ed19f7e 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
@@ -231,7 +231,6 @@ struct ixgbevf_adapter {
 	bool link_up;
 
 	struct work_struct watchdog_task;
-	bool netdev_registered;
 };
 
 enum ixbgevf_state_t {
diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index 3132771..3cd8651 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -3297,8 +3297,6 @@ static int __devinit ixgbevf_probe(struct pci_dev *pdev,
 	if (err)
 		goto err_register;
 
-	adapter->netdev_registered = true;
-
 	netif_carrier_off(netdev);
 
 	ixgbevf_init_last_counter_stats(adapter);
@@ -3347,10 +3345,8 @@ static void __devexit ixgbevf_remove(struct pci_dev *pdev)
 	cancel_work_sync(&adapter->reset_task);
 	cancel_work_sync(&adapter->watchdog_task);
 
-	if (adapter->netdev_registered) {
+	if (netdev->reg_state == NETREG_REGISTERED)
 		unregister_netdev(netdev);
-		adapter->netdev_registered = false;
-	}
 
 	ixgbevf_reset_interrupt_capability(adapter);
 
-- 
1.7.10.4
