From: Monam Agarwal <monamagarwal123@gmail.com>
Subject: [PATCH 2/9] net/ethernet: Replace rcu_assign_pointer(x, NULL) with RCU_INIT_POINTER(x, NULL) in drivers/net/ethernet/chelsio/cxgb3/cxgb3_offload.c
Date: Thu, 20 Mar 2014 20:09:35 +0530
Message-ID: <23ae65fa8bad7f9092739a52e35fdf9d4e8576a3.1395324808.git.monamagarwal123@gmail.com>
References: <1965df1cea51fc4c08e563554739fb74bbcaf58e.1395324808.git.monamagarwal123@gmail.com>
Cc: linux-kernel@vger.kernel.org, eddie.wai@broadcom.com,
	paulmck@linux.vnet.ibm.com
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1965df1cea51fc4c08e563554739fb74bbcaf58e.1395324808.git.monamagarwal123@gmail.com>
In-Reply-To: <cover.1395324808.git.monamagarwal123@gmail.com>
References: <cover.1395324808.git.monamagarwal123@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Monam Agarwal <monamagarwal123@gmail.com>
---
 drivers/net/ethernet/chelsio/cxgb3/cxgb3_offload.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb3/cxgb3_offload.c b/drivers/net/ethernet/chelsio/cxgb3/cxgb3_offload.c
index da5a5d9..a7ec886 100644
--- a/drivers/net/ethernet/chelsio/cxgb3/cxgb3_offload.c
+++ b/drivers/net/ethernet/chelsio/cxgb3/cxgb3_offload.c
@@ -1300,7 +1300,7 @@ int cxgb3_offload_activate(struct adapter *adapter)
 
 out_free_l2t:
 	t3_free_l2t(L2DATA(dev));
-	rcu_assign_pointer(dev->l2opt, NULL);
+	RCU_INIT_POINTER(dev->l2opt, NULL);
 out_free:
 	kfree(t);
 	return err;
@@ -1328,7 +1328,7 @@ void cxgb3_offload_deactivate(struct adapter *adapter)
 	rcu_read_lock();
 	d = L2DATA(tdev);
 	rcu_read_unlock();
-	rcu_assign_pointer(tdev->l2opt, NULL);
+	RCU_INIT_POINTER(tdev->l2opt, NULL);
 	call_rcu(&d->rcu_head, clean_l2_data);
 	if (t->nofail_skb)
 		kfree_skb(t->nofail_skb);
-- 
1.7.9.5
