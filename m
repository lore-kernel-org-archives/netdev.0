From: Eva Rachel Retuya <eraretuya@gmail.com>
Subject: [PATCH v2] iwlwifi: dvm: use alloc_ordered_workqueue()
Date: Fri, 18 Mar 2016 00:19:21 +0800
Message-ID: <1458231561-13184-1-git-send-email-eraretuya@gmail.com>
Cc: johannes.berg@intel.com, emmanuel.grumbach@intel.com,
	linuxwifi@intel.com, kvalo@codeaurora.org,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, tj@kernel.org,
	Eva Rachel Retuya <eraretuya@gmail.com>
To: outreachy-kernel@googlegroups.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use alloc_ordered_workqueue() to allocate the workqueue instead of
create_singlethread_workqueue() since the latter is deprecated and is scheduled
for removal.

There are work items doing related operations that shouldn't be swapped when
queued in a certain order hence preserve the strict execution ordering of a
single threaded (ST) workqueue by switching to alloc_ordered_workqueue().

WQ_MEM_RECLAIM flag is not needed since the worker is not supposed to free
memory.

Signed-off-by: Eva Rachel Retuya <eraretuya@gmail.com>
---
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
