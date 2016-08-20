From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/15] i40e: use alloc_workqueue instead of create_singlethread_workqueue
Date: Fri, 19 Aug 2016 23:19:40 -0700
Message-ID: <1471673991-117115-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1471673991-117115-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:6494 "EHLO mga04.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751968AbcHTGTz (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 20 Aug 2016 02:19:55 -0400
In-Reply-To: <1471673991-117115-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

Replace calls to create_singlethread_workqueue instead with alloc_workqueue
as is style with other Intel drivers. This provides more control over
workqueue creation, and allows explicit setting of the desired mode of
operation. It also makes it more obvious that driver name constant is
passed to a format "%s".

Change-ID: I6192b44caf5140336cd54c5b350d51c73b541fdb
Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c     | 3 ++-
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 3 ++-
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 4ec9565..f355c04 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -11605,7 +11605,8 @@ static int __init i40e_init_module(void)
 	 * it can't be any worse than using the system workqueue which
 	 * was already single threaded
 	 */
-	i40e_wq = create_singlethread_workqueue(i40e_driver_name);
+	i40e_wq = alloc_workqueue("%s", WQ_UNBOUND | WQ_MEM_RECLAIM, 1,
+				  i40e_driver_name);
 	if (!i40e_wq) {
 		pr_err("%s: Failed to create workqueue\n", i40e_driver_name);
 		return -ENOMEM;
diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index ba046d1..24f88ec 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -2833,7 +2833,8 @@ static int __init i40evf_init_module(void)
 
 	pr_info("%s\n", i40evf_copyright);
 
-	i40evf_wq = create_singlethread_workqueue(i40evf_driver_name);
+	i40evf_wq = alloc_workqueue("%s", WQ_UNBOUND | WQ_MEM_RECLAIM, 1,
+				    i40evf_driver_name);
 	if (!i40evf_wq) {
 		pr_err("%s: Failed to create workqueue\n", i40evf_driver_name);
 		return -ENOMEM;
-- 
2.7.4
