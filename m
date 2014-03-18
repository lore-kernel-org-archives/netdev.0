From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next] e1000e: fix the build error when PM is disabled
Date: Tue, 18 Mar 2014 00:26:49 -0700
Message-ID: <1395127610-3290-2-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Kevin Hao <haokexin@gmail.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:43006 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753013AbaCRH07 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Mar 2014 03:26:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kevin Hao <haokexin@gmail.com>

The commit 2800209994f8 (e1000e: Refactor PM flows) changed the
SET_SYSTEM_SLEEP_PM_OPS to open-coded assignment, but forgot to
protect them with CONFIG_PM_SLEEP. Then cause the following build
error when PM is disabled:
drivers/net/ethernet/intel/e1000e/netdev.c:7079:13:
error: 'e1000e_pm_suspend' undeclared here (not in a function)
  .suspend = e1000e_pm_suspend,
             ^
drivers/net/ethernet/intel/e1000e/netdev.c:7080:13:
error: 'e1000e_pm_resume' undeclared here (not in a function)
  .resume  = e1000e_pm_resume,
             ^
drivers/net/ethernet/intel/e1000e/netdev.c:7082:11:
error: 'e1000e_pm_thaw' undeclared here (not in a function)
  .thaw  = e1000e_pm_thaw,
           ^
Signed-off-by: Kevin Hao <haokexin@gmail.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/netdev.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 3f044e7..eafad41 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -7076,12 +7076,14 @@ static DEFINE_PCI_DEVICE_TABLE(e1000_pci_tbl) = {
 MODULE_DEVICE_TABLE(pci, e1000_pci_tbl);
 
 static const struct dev_pm_ops e1000_pm_ops = {
+#ifdef CONFIG_PM_SLEEP
 	.suspend	= e1000e_pm_suspend,
 	.resume		= e1000e_pm_resume,
 	.freeze		= e1000e_pm_freeze,
 	.thaw		= e1000e_pm_thaw,
 	.poweroff	= e1000e_pm_suspend,
 	.restore	= e1000e_pm_resume,
+#endif
 	SET_RUNTIME_PM_OPS(e1000e_pm_runtime_suspend, e1000e_pm_runtime_resume,
 			   e1000e_pm_runtime_idle)
 };
-- 
1.8.3.1
