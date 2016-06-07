From: Bhaktipriya Shridhar <bhaktipriya96@gmail.com>
Subject: [PATCH] libertas_tf: Remove create_workqueue
Date: Wed, 8 Jun 2016 01:38:53 +0530
Message-ID: <20160607200853.GA13742@Karyakshetra>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tejun Heo <tj@kernel.org>, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Kalle Valo <kvalo@codeaurora.org>,
	Johannes Berg <johannes.berg@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

alloc_workqueue replaces deprecated create_workqueue().

A dedicated workqueue has been used since the workitem (viz
&priv->cmd_work per priv, which maps to lbtf_cmd_work) is involved in
actual command processing and may be used on a memory reclaim path.
The workitems require forward progress under memory pressure and hence,
WQ_MEM_RECLAIM has been set. Since there are only a fixed number of work
items, explicit concurrency limit is unnecessary here.

Signed-off-by: Bhaktipriya Shridhar <bhaktipriya96@gmail.com>
---
 drivers/net/wireless/marvell/libertas_tf/main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/marvell/libertas_tf/main.c b/drivers/net/wireless/marvell/libertas_tf/main.c
index 0bf8916..81463f7 100644
--- a/drivers/net/wireless/marvell/libertas_tf/main.c
+++ b/drivers/net/wireless/marvell/libertas_tf/main.c
@@ -742,7 +742,7 @@ EXPORT_SYMBOL_GPL(lbtf_bcn_sent);
 static int __init lbtf_init_module(void)
 {
 	lbtf_deb_enter(LBTF_DEB_MAIN);
-	lbtf_wq = create_workqueue("libertastf");
+	lbtf_wq = alloc_workqueue("libertastf", WQ_MEM_RECLAIM, 0);
 	if (lbtf_wq == NULL) {
 		printk(KERN_ERR "libertastf: couldn't create workqueue\n");
 		return -ENOMEM;
