From: Eva Rachel Retuya <eraretuya@gmail.com>
Subject: [PATCH v3] iwlwifi: dvm: use alloc_ordered_workqueue()
Date: Sat, 19 Mar 2016 13:15:47 +0800
Message-ID: <1458364547-11621-1-git-send-email-eraretuya@gmail.com>
Cc: johannes.berg@intel.com, emmanuel.grumbach@intel.com,
	linuxwifi@intel.com, kvalo@codeaurora.org,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, tj@kernel.org,
	Eva Rachel Retuya <eraretuya@gmail.com>
To: outreachy-kernel@googlegroups.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:34806 "EHLO
	mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750735AbcCSFPz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Mar 2016 01:15:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use alloc_ordered_workqueue() to allocate the workqueue instead of
create_singlethread_workqueue() since the latter is deprecated and is scheduled
for removal.

There are work items doing related operations that shouldn't be swapped when
queued in a certain order hence preserve the strict execution ordering of a
single threaded (ST) workqueue by switching to alloc_ordered_workqueue().

WQ_MEM_RECLAIM flag is not needed since the worker is not depended
during memory reclaim.

Signed-off-by: Eva Rachel Retuya <eraretuya@gmail.com>
Acked-by: Tejun Heo <tj@kernel.org>
---
Changes in v3:
* revise commit message about WQ_MEM_RECLAIM
* add 'Acked-by:' from previous feedback
Changes in v2:
* switch from alloc_workqueue() to alloc_ordered_workqueue()
* remove unneeded flags: WQ_MEM_RECLAIM and WQ_HIGHPRI
* update commit message to reflect change

 drivers/net/wireless/intel/iwlwifi/dvm/main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/intel/iwlwifi/dvm/main.c b/drivers/net/wireless/intel/iwlwifi/dvm/main.c
index f62c2d7..14396d8 100644
--- a/drivers/net/wireless/intel/iwlwifi/dvm/main.c
+++ b/drivers/net/wireless/intel/iwlwifi/dvm/main.c
@@ -1071,7 +1071,7 @@ static void iwl_bg_restart(struct work_struct *data)
 
 static void iwl_setup_deferred_work(struct iwl_priv *priv)
 {
-	priv->workqueue = create_singlethread_workqueue(DRV_NAME);
+	priv->workqueue = alloc_ordered_workqueue(DRV_NAME, 0);
 
 	INIT_WORK(&priv->restart, iwl_bg_restart);
 	INIT_WORK(&priv->beacon_update, iwl_bg_beacon_update);
-- 
1.9.1
