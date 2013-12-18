From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 4/5] e1000e: Fix a compile flag mis-match for suspend/resume
Date: Tue, 17 Dec 2013 23:19:45 -0800
Message-ID: <1387351186-23389-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1387351186-23389-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: David Ertman <davidx.m.ertman@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:58137 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750956Ab3LRHTu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Dec 2013 02:19:50 -0500
In-Reply-To: <1387351186-23389-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ertman <davidx.m.ertman@intel.com>

This patch addresses a mis-match between the declaration and usage of
the e1000_suspend and e1000_resume functions.  Previously, these
functions were declared in a CONFIG_PM_SLEEP wrapper, and then utilized
within a CONFIG_PM wrapper.  Both the declaration and usage will now be
contained within CONFIG_PM wrappers.

Signed-off-by: Dave Ertman <davidx.m.ertman@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/netdev.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 8d3945a..c30d41d 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -6174,7 +6174,7 @@ static int __e1000_resume(struct pci_dev *pdev)
 	return 0;
 }
 
-#ifdef CONFIG_PM_SLEEP
+#ifdef CONFIG_PM
 static int e1000_suspend(struct device *dev)
 {
 	struct pci_dev *pdev = to_pci_dev(dev);
@@ -6193,7 +6193,7 @@ static int e1000_resume(struct device *dev)
 
 	return __e1000_resume(pdev);
 }
-#endif /* CONFIG_PM_SLEEP */
+#endif /* CONFIG_PM */
 
 #ifdef CONFIG_PM_RUNTIME
 static int e1000_runtime_suspend(struct device *dev)
-- 
1.8.3.1
