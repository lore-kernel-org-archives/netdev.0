From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/17] fm10k: remove comment about rtnl_lock around mbx operations
Date: Tue, 22 Sep 2015 16:54:20 -0700
Message-ID: <1442966076-14359-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1442966076-14359-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:8434 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934146AbbIVXyi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Sep 2015 19:54:38 -0400
In-Reply-To: <1442966076-14359-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

This comment is no longer true due to a couple of mailbox locking
refactors, and we now don't actually do any rtnl protected operations
directly in the mailbox path. Remove this comment as it is factually
incorrect and confusing.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Krishneil Singh <krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_pci.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
index 3d71c52..dfefd06 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
@@ -274,8 +274,6 @@ static void fm10k_watchdog_update_host_state(struct fm10k_intfc *interface)
  * @interface: board private structure
  *
  * This function will process both the upstream and downstream mailboxes.
- * It is necessary for us to hold the rtnl_lock while doing this as the
- * mailbox accesses are protected by this lock.
  **/
 static void fm10k_mbx_subtask(struct fm10k_intfc *interface)
 {
@@ -498,7 +496,7 @@ static void fm10k_service_task(struct work_struct *work)
 
 	interface = container_of(work, struct fm10k_intfc, service_task);
 
-	/* tasks always capable of running, but must be rtnl protected */
+	/* tasks run even when interface is down */
 	fm10k_mbx_subtask(interface);
 	fm10k_detach_subtask(interface);
 	fm10k_reset_subtask(interface);
-- 
2.4.3
