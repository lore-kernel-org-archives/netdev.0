From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next] ixgbe: Remove unnecessary #ifdef CONFIG_DEBUG_FS
 tests
Date: Sun, 07 Apr 2013 18:27:33 -0700
Message-ID: <1365384453.8922.20.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:58865 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S934567Ab3DHB1e (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 7 Apr 2013 21:27:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add some empty static inlines instead to make
the code more readable.

Signed-off-by: Joe Perches <joe@perches.com>
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
index 1339932..06cd8cd 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -7575,9 +7575,7 @@ skip_sriov:
 		e_err(probe, "failed to allocate sysfs resources\n");
 #endif /* CONFIG_IXGBE_HWMON */
 
-#ifdef CONFIG_DEBUG_FS
 	ixgbe_dbg_adapter_init(adapter);
-#endif /* CONFIG_DEBUG_FS */
 
 	return 0;
 
@@ -7613,9 +7611,7 @@ static void ixgbe_remove(struct pci_dev *pdev)
 	struct ixgbe_adapter *adapter = pci_get_drvdata(pdev);
 	struct net_device *netdev = adapter->netdev;
 
-#ifdef CONFIG_DEBUG_FS
 	ixgbe_dbg_adapter_exit(adapter);
-#endif /*CONFIG_DEBUG_FS */
 
 	set_bit(__IXGBE_DOWN, &adapter->state);
 	cancel_work_sync(&adapter->service_task);
@@ -7878,15 +7874,11 @@ static int __init ixgbe_init_module(void)
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
 
@@ -7912,9 +7904,7 @@ static void __exit ixgbe_exit_module(void)
 #endif
 	pci_unregister_driver(&ixgbe_driver);
 
-#ifdef CONFIG_DEBUG_FS
 	ixgbe_dbg_exit();
-#endif /* CONFIG_DEBUG_FS */
 
 	rcu_barrier(); /* Wait for completion of call_rcu()'s */
 }
