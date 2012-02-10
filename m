From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 7/7] igb: fix warning about unused function
Date: Fri, 10 Feb 2012 00:08:57 -0800
Message-ID: <1328861337-12810-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1328861337-12810-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:39150 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755169Ab2BJIJD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Feb 2012 03:09:03 -0500
In-Reply-To: <1328861337-12810-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

This patch fixes a warning about unused function when CONFIG_PM_SLEEP
is not selected in the kernel config:

igb_main.c: warning: `igb_suspend` defined but not used [W-unused-function]

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index e91d73c..fd911ca 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -173,7 +173,9 @@ static int igb_check_vf_assignment(struct igb_adapter *adapter);
 #endif
 
 #ifdef CONFIG_PM
+#ifdef CONFIG_PM_SLEEP
 static int igb_suspend(struct device *);
+#endif
 static int igb_resume(struct device *);
 #ifdef CONFIG_PM_RUNTIME
 static int igb_runtime_suspend(struct device *dev);
@@ -6709,6 +6711,7 @@ static int __igb_shutdown(struct pci_dev *pdev, bool *enable_wake,
 }
 
 #ifdef CONFIG_PM
+#ifdef CONFIG_PM_SLEEP
 static int igb_suspend(struct device *dev)
 {
 	int retval;
@@ -6728,6 +6731,7 @@ static int igb_suspend(struct device *dev)
 
 	return 0;
 }
+#endif /* CONFIG_PM_SLEEP */
 
 static int igb_resume(struct device *dev)
 {
-- 
1.7.7.6
