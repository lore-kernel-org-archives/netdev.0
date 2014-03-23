From: Monam Agarwal <monamagarwal123-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH] drivers/net/wireless: Use RCU_INIT_POINTER(x, NULL) in iwlwifi/mvm/sta.c
Date: Mon, 24 Mar 2014 00:05:56 +0530
Message-ID: <1395599756-7861-1-git-send-email-monamagarwal123@gmail.com>
To: johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, emmanuel.grumbach-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	ilw-VuQAYsv1563Yd54FQh9/CA@public.gmane.org, linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, eliad-Ix1uc/W3ht7QT0dZR+AlfA@public.gmane.org,
	eytan.lifshitz-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, eyal-Ix1uc/W3ht7QT0dZR+AlfA@public.gmane.org, Max.Stepanov-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch replaces rcu_assign_pointer(x, NULL) with RCU_INIT_POINTER(x, NULL)

The rcu_assign_pointer() ensures that the initialization of a structure       
is carried out before storing a pointer to that structure. 
And in the case of the NULL pointer, there is no structure to initialize. 
So, rcu_assign_pointer(p, NULL) can be safely converted to RCU_INIT_POINTER(p, NULL)

Signed-off-by: Monam Agarwal <monamagarwal123-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 drivers/net/wireless/iwlwifi/mvm/sta.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/wireless/iwlwifi/mvm/sta.c b/drivers/net/wireless/iwlwifi/mvm/sta.c
index 2677d1c..b793775 100644
--- a/drivers/net/wireless/iwlwifi/mvm/sta.c
+++ b/drivers/net/wireless/iwlwifi/mvm/sta.c
@@ -498,7 +498,7 @@ void iwl_mvm_sta_drained_wk(struct work_struct *wk)
 				sta_id);
 			continue;
 		}
-		rcu_assign_pointer(mvm->fw_id_to_mac_id[sta_id], NULL);
+		RCU_INIT_POINTER(mvm->fw_id_to_mac_id[sta_id], NULL);
 		clear_bit(sta_id, mvm->sta_drained);
 	}
 
@@ -557,7 +557,7 @@ int iwl_mvm_rm_sta(struct iwl_mvm *mvm,
 	} else {
 		spin_unlock_bh(&mvm_sta->lock);
 		ret = iwl_mvm_rm_sta_common(mvm, mvm_sta->sta_id);
-		rcu_assign_pointer(mvm->fw_id_to_mac_id[mvm_sta->sta_id], NULL);
+		RCU_INIT_POINTER(mvm->fw_id_to_mac_id[mvm_sta->sta_id], NULL);
 	}
 
 	return ret;
@@ -571,7 +571,7 @@ int iwl_mvm_rm_sta_id(struct iwl_mvm *mvm,
 
 	lockdep_assert_held(&mvm->mutex);
 
-	rcu_assign_pointer(mvm->fw_id_to_mac_id[sta_id], NULL);
+	RCU_INIT_POINTER(mvm->fw_id_to_mac_id[sta_id], NULL);
 	return ret;
 }
 
@@ -593,7 +593,7 @@ int iwl_mvm_allocate_int_sta(struct iwl_mvm *mvm, struct iwl_mvm_int_sta *sta,
 
 void iwl_mvm_dealloc_int_sta(struct iwl_mvm *mvm, struct iwl_mvm_int_sta *sta)
 {
-	rcu_assign_pointer(mvm->fw_id_to_mac_id[sta->sta_id], NULL);
+	RCU_INIT_POINTER(mvm->fw_id_to_mac_id[sta->sta_id], NULL);
 	memset(sta, 0, sizeof(struct iwl_mvm_int_sta));
 	sta->sta_id = IWL_MVM_STATION_COUNT;
 }
-- 
1.7.9.5

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
