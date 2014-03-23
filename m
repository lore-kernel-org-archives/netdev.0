From: Monam Agarwal <monamagarwal123@gmail.com>
Subject: [PATCH] net/mac80211: Use RCU_INIT_POINTER(x, NULL) in mesh.c
Date: Mon, 24 Mar 2014 00:49:13 +0530
Message-ID: <1395602353-14254-1-git-send-email-monamagarwal123@gmail.com>
To: linville@tuxdriver.com, johannes@sipsolutions.net,
	davem@davemloft.net, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch replaces rcu_assign_pointer(x, NULL) with RCU_INIT_POINTER(x, NULL)

The rcu_assign_pointer() ensures that the initialization of a structure       
is carried out before storing a pointer to that structure. 
And in the case of the NULL pointer, there is no structure to initialize. 
So, rcu_assign_pointer(p, NULL) can be safely converted to RCU_INIT_POINTER(p, NULL)

Signed-off-by: Monam Agarwal <monamagarwal123@gmail.com>
---
 net/mac80211/mesh.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/mac80211/mesh.c b/net/mac80211/mesh.c
index f70e9cd..387f61c 100644
--- a/net/mac80211/mesh.c
+++ b/net/mac80211/mesh.c
@@ -829,7 +829,7 @@ void ieee80211_stop_mesh(struct ieee80211_sub_if_data *sdata)
 	ieee80211_bss_info_change_notify(sdata, BSS_CHANGED_BEACON_ENABLED);
 	bcn = rcu_dereference_protected(ifmsh->beacon,
 					lockdep_is_held(&sdata->wdev.mtx));
-	rcu_assign_pointer(ifmsh->beacon, NULL);
+	RCU_INIT_POINTER(ifmsh->beacon, NULL);
 	kfree_rcu(bcn, rcu_head);
 
 	/* flush STAs and mpaths on this iface */
@@ -1068,7 +1068,7 @@ int ieee80211_mesh_finish_csa(struct ieee80211_sub_if_data *sdata)
 
 	/* Remove the CSA and MCSP elements from the beacon */
 	tmp_csa_settings = rcu_dereference(ifmsh->csa);
-	rcu_assign_pointer(ifmsh->csa, NULL);
+	RCU_INIT_POINTER(ifmsh->csa, NULL);
 	if (tmp_csa_settings)
 		kfree_rcu(tmp_csa_settings, rcu_head);
 	ret = ieee80211_mesh_rebuild_beacon(sdata);
@@ -1102,7 +1102,7 @@ int ieee80211_mesh_csa_beacon(struct ieee80211_sub_if_data *sdata,
 	ret = ieee80211_mesh_rebuild_beacon(sdata);
 	if (ret) {
 		tmp_csa_settings = rcu_dereference(ifmsh->csa);
-		rcu_assign_pointer(ifmsh->csa, NULL);
+		RCU_INIT_POINTER(ifmsh->csa, NULL);
 		kfree_rcu(tmp_csa_settings, rcu_head);
 		return ret;
 	}
-- 
1.7.9.5
