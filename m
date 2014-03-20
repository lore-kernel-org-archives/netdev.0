From: Monam Agarwal <monamagarwal123@gmail.com>
Subject: [PATCH 5/9] net/wireless: Replace rcu_assign_pointer(x, NULL) with RCU_INIT_POINTER(x, NULL) in drivers/net/wireless/ath/carl9170/main.c
Date: Thu, 20 Mar 2014 20:12:54 +0530
Message-ID: <09e2af73056d815f34152f1ebfd45b52d7aa2ff9.1395324808.git.monamagarwal123@gmail.com>
References: <01911c3cccbcd3916e0c29854d289187507f7746.1395324808.git.monamagarwal123@gmail.com>
Cc: linux-kernel@vger.kernel.org, eddie.wai@broadcom.com,
	paulmck@linux.vnet.ibm.com
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <01911c3cccbcd3916e0c29854d289187507f7746.1395324808.git.monamagarwal123@gmail.com>
In-Reply-To: <cover.1395324808.git.monamagarwal123@gmail.com>
References: <cover.1395324808.git.monamagarwal123@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Monam Agarwal <monamagarwal123@gmail.com>
---
 drivers/net/wireless/ath/carl9170/main.c |   12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/wireless/ath/carl9170/main.c b/drivers/net/wireless/ath/carl9170/main.c
index f06e069..5518592 100644
--- a/drivers/net/wireless/ath/carl9170/main.c
+++ b/drivers/net/wireless/ath/carl9170/main.c
@@ -446,7 +446,7 @@ static void carl9170_op_stop(struct ieee80211_hw *hw)
 
 	mutex_lock(&ar->mutex);
 	if (IS_ACCEPTING_CMD(ar)) {
-		rcu_assign_pointer(ar->beacon_iter, NULL);
+		RCU_INIT_POINTER(ar->beacon_iter, NULL);
 
 		carl9170_led_set_state(ar, 0);
 
@@ -678,7 +678,7 @@ unlock:
 		vif_priv->active = false;
 		bitmap_release_region(&ar->vif_bitmap, vif_id, 0);
 		ar->vifs--;
-		rcu_assign_pointer(ar->vif_priv[vif_id].vif, NULL);
+		RCU_INIT_POINTER(ar->vif_priv[vif_id].vif, NULL);
 		list_del_rcu(&vif_priv->list);
 		mutex_unlock(&ar->mutex);
 		synchronize_rcu();
@@ -716,7 +716,7 @@ static void carl9170_op_remove_interface(struct ieee80211_hw *hw,
 	WARN_ON(vif_priv->enable_beacon);
 	vif_priv->enable_beacon = false;
 	list_del_rcu(&vif_priv->list);
-	rcu_assign_pointer(ar->vif_priv[id].vif, NULL);
+	RCU_INIT_POINTER(ar->vif_priv[id].vif, NULL);
 
 	if (vif == main_vif) {
 		rcu_read_unlock();
@@ -1258,7 +1258,7 @@ static int carl9170_op_sta_add(struct ieee80211_hw *hw,
 		}
 
 		for (i = 0; i < CARL9170_NUM_TID; i++)
-			rcu_assign_pointer(sta_info->agg[i], NULL);
+			RCU_INIT_POINTER(sta_info->agg[i], NULL);
 
 		sta_info->ampdu_max_len = 1 << (3 + sta->ht_cap.ampdu_factor);
 		sta_info->ht_sta = true;
@@ -1285,7 +1285,7 @@ static int carl9170_op_sta_remove(struct ieee80211_hw *hw,
 			struct carl9170_sta_tid *tid_info;
 
 			tid_info = rcu_dereference(sta_info->agg[i]);
-			rcu_assign_pointer(sta_info->agg[i], NULL);
+			RCU_INIT_POINTER(sta_info->agg[i], NULL);
 
 			if (!tid_info)
 				continue;
@@ -1398,7 +1398,7 @@ static int carl9170_op_ampdu_action(struct ieee80211_hw *hw,
 			spin_unlock_bh(&ar->tx_ampdu_list_lock);
 		}
 
-		rcu_assign_pointer(sta_info->agg[tid], NULL);
+		RCU_INIT_POINTER(sta_info->agg[tid], NULL);
 		rcu_read_unlock();
 
 		ieee80211_stop_tx_ba_cb_irqsafe(vif, sta->addr, tid);
-- 
1.7.9.5
