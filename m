From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 03/15] ixgbe: Remove unnecessary #ifdef CONFIG_DEBUG_FS tests
Date: Thu, 18 Apr 2013 16:30:10 -0700
Message-ID: <1366327822-10741-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1366327822-10741-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Joe Perches <joe@perches.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:59537 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S936655Ab3DRXas (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Apr 2013 19:30:48 -0400
In-Reply-To: <1366327822-10741-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>

Add some empty static inlines instead to make
the code more readable.

Signed-off-by: Joe Perches <joe@perches.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe.h      |  5 +++++
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 10 ----------
 2 files changed, 5 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index a8e10cf..ca93238 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -740,6 +740,11 @@ extern void ixgbe_dbg_adapter_init(struct ixgbe_adapter *adapter);
 extern void ixgbe_dbg_adapter_exit(struct ixgbe_adapter *adapter);
 extern void ixgbe_dbg_init(void);
 extern void ixgbe_dbg_exit(void);
+#else
+static inline void ixgbe_dbg_adapter_init(struct ixgbe_adapter *adapter) {}
+static inline void ixgbe_dbg_adapter_exit(struct ixgbe_adapter *adapter) {}
+static inline void ixgbe_dbg_init(void) {}
+static inline void ixgbe_dbg_exit(void) {}
 #endif /* CONFIG_DEBUG_FS */
 static inline struct netdev_queue *txring_txq(const struct ixgbe_ring *ring)
 {
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index aa5d7d0..c022f9c 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -7626,9 +7626,7 @@ skip_sriov:
 		e_err(probe, "failed to allocate sysfs resources\n");
 #endif /* CONFIG_IXGBE_HWMON */
 
-#ifdef CONFIG_DEBUG_FS
 	ixgbe_dbg_adapter_init(adapter);
-#endif /* CONFIG_DEBUG_FS */
 
 	/* Need link setup for MNG FW, else wait for IXGBE_UP */
 	if (hw->mng_fw_enabled && hw->mac.ops.setup_link)
@@ -7670,9 +7668,7 @@ static void ixgbe_remove(struct pci_dev *pdev)
 	struct ixgbe_adapter *adapter = pci_get_drvdata(pdev);
 	struct net_device *netdev = adapter->netdev;
 
-#ifdef CONFIG_DEBUG_FS
 	ixgbe_dbg_adapter_exit(adapter);
-#endif /*CONFIG_DEBUG_FS */
 
 	set_bit(__IXGBE_DOWN, &adapter->state);
 	cancel_work_sync(&adapter->service_task);
@@ -7935,15 +7931,11 @@ static int __init ixgbe_init_module(void)
 	pr_info("%s - version %s\n", ixgbe_driver_string, ixgbe_driver_version);
 	pr_info("%s\n", ixgbe_copyright);
 
-#ifdef CONFIG_DEBUG_FS
 	ixgbe_dbg_init();
-#endif /* CONFIG_DEBUG_FS */
 
 	ret = pci_register_driver(&ixgbe_driver);
 	if (ret) {
-#ifdef CONFIG_DEBUG_FS
 		ixgbe_dbg_exit();
-#endif /* CONFIG_DEBUG_FS */
 		return ret;
 	}
 
@@ -7969,9 +7961,7 @@ static void __exit ixgbe_exit_module(void)
 #endif
 	pci_unregister_driver(&ixgbe_driver);
 
-#ifdef CONFIG_DEBUG_FS
 	ixgbe_dbg_exit();
-#endif /* CONFIG_DEBUG_FS */
 
 	rcu_barrier(); /* Wait for completion of call_rcu()'s */
 }
-- 
1.7.11.7
