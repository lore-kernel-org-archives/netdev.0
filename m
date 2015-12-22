From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/10] fm10k: don't initialize fm10k_workqueue at global level
Date: Tue, 22 Dec 2015 06:02:03 -0800
Message-ID: <1450792932-96015-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1450792932-96015-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jacob Keller <jacob.e.keller@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:29757 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753387AbbLVODN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Dec 2015 09:03:13 -0500
In-Reply-To: <1450792932-96015-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Cleans up checkpatch GLOBAL_INITIALIZERS error

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Krishneil Singh <Krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_main.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_main.c b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
index 75ff109..b243c3c 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_main.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
@@ -42,7 +42,7 @@ MODULE_LICENSE("GPL");
 MODULE_VERSION(DRV_VERSION);
 
 /* single workqueue for entire fm10k driver */
-struct workqueue_struct *fm10k_workqueue = NULL;
+struct workqueue_struct *fm10k_workqueue;
 
 /**
  * fm10k_init_module - Driver Registration Routine
@@ -56,8 +56,7 @@ static int __init fm10k_init_module(void)
 	pr_info("%s\n", fm10k_copyright);
 
 	/* create driver workqueue */
-	if (!fm10k_workqueue)
-		fm10k_workqueue = create_workqueue("fm10k");
+	fm10k_workqueue = create_workqueue("fm10k");
 
 	fm10k_dbg_init();
 
@@ -80,7 +79,6 @@ static void __exit fm10k_exit_module(void)
 	/* destroy driver workqueue */
 	flush_workqueue(fm10k_workqueue);
 	destroy_workqueue(fm10k_workqueue);
-	fm10k_workqueue = NULL;
 }
 module_exit(fm10k_exit_module);
 
-- 
2.5.0
