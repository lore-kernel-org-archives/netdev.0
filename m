From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/11] igb: mark PM functions as __maybe_unused
Date: Tue,  6 Jun 2017 01:58:00 -0700
Message-ID: <20170606085809.78571-3-jeffrey.t.kirsher@intel.com>
References: <20170606085809.78571-1-jeffrey.t.kirsher@intel.com>
Cc: Arnd Bergmann <arnd@arndb.de>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:30962 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751415AbdFFI6P (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 6 Jun 2017 04:58:15 -0400
In-Reply-To: <20170606085809.78571-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnd Bergmann <arnd@arndb.de>

The new wake function is only used by the suspend/resume handlers that
are defined in inside of an #ifdef, which can cause this harmless
warning:

drivers/net/ethernet/intel/igb/igb_main.c:7988:13: warning: 'igb_deliver_wake_packet' defined but not used [-Wunused-function]

Removing the #ifdef, instead using a __maybe_unused annotation
simplifies the code and avoids the warning.

Fixes: b90fa8763560 ("igb: Enable reading of wake up packet")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c | 18 +++++-------------
 1 file changed, 5 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 1cf74aa4ebd9..2d5bdb1fd37d 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -191,10 +191,7 @@ static int igb_disable_sriov(struct pci_dev *dev);
 static int igb_pci_disable_sriov(struct pci_dev *dev);
 #endif
 
-#ifdef CONFIG_PM
-#ifdef CONFIG_PM_SLEEP
 static int igb_suspend(struct device *);
-#endif
 static int igb_resume(struct device *);
 static int igb_runtime_suspend(struct device *dev);
 static int igb_runtime_resume(struct device *dev);
@@ -204,7 +201,6 @@ static const struct dev_pm_ops igb_pm_ops = {
 	SET_RUNTIME_PM_OPS(igb_runtime_suspend, igb_runtime_resume,
 			igb_runtime_idle)
 };
-#endif
 static void igb_shutdown(struct pci_dev *);
 static int igb_pci_sriov_configure(struct pci_dev *dev, int num_vfs);
 #ifdef CONFIG_IGB_DCA
@@ -8015,9 +8011,7 @@ static void igb_deliver_wake_packet(struct net_device *netdev)
 	netif_rx(skb);
 }
 
-#ifdef CONFIG_PM
-#ifdef CONFIG_PM_SLEEP
-static int igb_suspend(struct device *dev)
+static int __maybe_unused igb_suspend(struct device *dev)
 {
 	int retval;
 	bool wake;
@@ -8036,9 +8030,8 @@ static int igb_suspend(struct device *dev)
 
 	return 0;
 }
-#endif /* CONFIG_PM_SLEEP */
 
-static int igb_resume(struct device *dev)
+static int __maybe_unused igb_resume(struct device *dev)
 {
 	struct pci_dev *pdev = to_pci_dev(dev);
 	struct net_device *netdev = pci_get_drvdata(pdev);
@@ -8092,7 +8085,7 @@ static int igb_resume(struct device *dev)
 	return err;
 }
 
-static int igb_runtime_idle(struct device *dev)
+static int __maybe_unused igb_runtime_idle(struct device *dev)
 {
 	struct pci_dev *pdev = to_pci_dev(dev);
 	struct net_device *netdev = pci_get_drvdata(pdev);
@@ -8104,7 +8097,7 @@ static int igb_runtime_idle(struct device *dev)
 	return -EBUSY;
 }
 
-static int igb_runtime_suspend(struct device *dev)
+static int __maybe_unused igb_runtime_suspend(struct device *dev)
 {
 	struct pci_dev *pdev = to_pci_dev(dev);
 	int retval;
@@ -8124,11 +8117,10 @@ static int igb_runtime_suspend(struct device *dev)
 	return 0;
 }
 
-static int igb_runtime_resume(struct device *dev)
+static int __maybe_unused igb_runtime_resume(struct device *dev)
 {
 	return igb_resume(dev);
 }
-#endif /* CONFIG_PM */
 
 static void igb_shutdown(struct pci_dev *pdev)
 {
-- 
2.12.2
