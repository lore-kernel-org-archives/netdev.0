From: Kevin Hao <haokexin@gmail.com>
Subject: [PATCH net-next] e1000e: fix the build error when PM is disabled
Date: Fri, 14 Mar 2014 14:57:13 +0800
Message-ID: <1394780233-8066-1-git-send-email-haokexin@gmail.com>
To: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:63091 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755234AbaCNG5o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Mar 2014 02:57:44 -0400
Received: by mail-pd0-f179.google.com with SMTP id w10so2163301pde.10
        for <netdev@vger.kernel.org>; Thu, 13 Mar 2014 23:57:44 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
---
 drivers/net/ethernet/intel/e1000e/netdev.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 3f044e736de8..eafad410e59a 100644
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
1.8.5.3
