From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Subject: [PATCH] net: mac80211: mark expected switch fall-throughs
Date: Tue, 17 Oct 2017 18:14:50 -0500
Message-ID: <20171017231450.GA29464@embeddedor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        "Gustavo A. R. Silva" <garsilva@embeddedor.com>
To: Johannes Berg <johannes@sipsolutions.net>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway23.websitewelcome.com ([192.185.49.219]:44572 "EHLO
        gateway23.websitewelcome.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S933132AbdJQXOx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2017 19:14:53 -0400
Received: from cm15.websitewelcome.com (cm15.websitewelcome.com [100.42.49.9])
        by gateway23.websitewelcome.com (Postfix) with ESMTP id 36FD5B50C
        for <netdev@vger.kernel.org>; Tue, 17 Oct 2017 18:14:53 -0500 (CDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In preparation to enabling -Wimplicit-fallthrough, mark switch cases
where we are expecting to fall through.

Notice that in some cases I replaced "fall through on else" and
"otherwise fall through" comments with just a "fall through" comment,
which is what GCC is expecting to find.

Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>
---
This code was tested by compilation only (GCC 7.2.0 was used).
Please, verify that the actual intention of the code is to fall through.

 net/mac80211/cfg.c        | 3 +++
 net/mac80211/ht.c         | 1 +
 net/mac80211/iface.c      | 2 +-
 net/mac80211/mesh.c       | 2 ++
 net/mac80211/mesh_hwmp.c  | 1 +
 net/mac80211/mesh_plink.c | 2 +-
 net/mac80211/mlme.c       | 1 +
 net/mac80211/offchannel.c | 4 ++--
 net/mac80211/tdls.c       | 1 +
 net/mac80211/wme.c        | 1 +
 10 files changed, 14 insertions(+), 4 deletions(-)

diff --git a/net/mac80211/cfg.c b/net/mac80211/cfg.c
index a354f19..9bd8bef 100644
--- a/net/mac80211/cfg.c
+++ b/net/mac80211/cfg.c
@@ -573,10 +573,12 @@ static int ieee80211_get_key(struct wiphy *wiphy, struct net_device *dev,
 	case WLAN_CIPHER_SUITE_BIP_CMAC_256:
 		BUILD_BUG_ON(offsetof(typeof(kseq), ccmp) !=
 			     offsetof(typeof(kseq), aes_cmac));
+		/* fall through */
 	case WLAN_CIPHER_SUITE_BIP_GMAC_128:
 	case WLAN_CIPHER_SUITE_BIP_GMAC_256:
 		BUILD_BUG_ON(offsetof(typeof(kseq), ccmp) !=
 			     offsetof(typeof(kseq), aes_gmac));
+		/* fall through */
 	case WLAN_CIPHER_SUITE_GCMP:
 	case WLAN_CIPHER_SUITE_GCMP_256:
 		BUILD_BUG_ON(offsetof(typeof(kseq), ccmp) !=
@@ -2205,6 +2207,7 @@ static int ieee80211_scan(struct wiphy *wiphy,
 		 * for now fall through to allow scanning only when
 		 * beaconing hasn't been configured yet
 		 */
+		/* fall through */
 	case NL80211_IFTYPE_AP:
 		/*
 		 * If the scan has been forced (and the driver supports
diff --git a/net/mac80211/ht.c b/net/mac80211/ht.c
index 41f5e48..e55dabf 100644
--- a/net/mac80211/ht.c
+++ b/net/mac80211/ht.c
@@ -491,6 +491,7 @@ int ieee80211_send_smps_action(struct ieee80211_sub_if_data *sdata,
 	case IEEE80211_SMPS_AUTOMATIC:
 	case IEEE80211_SMPS_NUM_MODES:
 		WARN_ON(1);
+		/* fall through */
 	case IEEE80211_SMPS_OFF:
 		action_frame->u.action.u.ht_smps.smps_control =
 				WLAN_HT_SMPS_CONTROL_DISABLED;
diff --git a/net/mac80211/iface.c b/net/mac80211/iface.c
index 13b16f9..435e735 100644
--- a/net/mac80211/iface.c
+++ b/net/mac80211/iface.c
@@ -1633,7 +1633,7 @@ static void ieee80211_assign_perm_addr(struct ieee80211_local *local,
 				goto out_unlock;
 			}
 		}
-		/* otherwise fall through */
+		/* fall through */
 	default:
 		/* assign a new address if possible -- try n_addresses first */
 		for (i = 0; i < local->hw.wiphy->n_addresses; i++) {
diff --git a/net/mac80211/mesh.c b/net/mac80211/mesh.c
index 7a76c4a..d29a545 100644
--- a/net/mac80211/mesh.c
+++ b/net/mac80211/mesh.c
@@ -988,8 +988,10 @@ ieee80211_mesh_process_chnswitch(struct ieee80211_sub_if_data *sdata,
 	switch (sdata->vif.bss_conf.chandef.width) {
 	case NL80211_CHAN_WIDTH_20_NOHT:
 		sta_flags |= IEEE80211_STA_DISABLE_HT;
+		/* fall through */
 	case NL80211_CHAN_WIDTH_20:
 		sta_flags |= IEEE80211_STA_DISABLE_40MHZ;
+		/* fall through */
 	case NL80211_CHAN_WIDTH_40:
 		sta_flags |= IEEE80211_STA_DISABLE_VHT;
 		break;
diff --git a/net/mac80211/mesh_hwmp.c b/net/mac80211/mesh_hwmp.c
index 146ec6c..0e75abf 100644
--- a/net/mac80211/mesh_hwmp.c
+++ b/net/mac80211/mesh_hwmp.c
@@ -1247,6 +1247,7 @@ void mesh_path_tx_root_frame(struct ieee80211_sub_if_data *sdata)
 		break;
 	case IEEE80211_PROACTIVE_PREQ_WITH_PREP:
 		flags |= IEEE80211_PREQ_PROACTIVE_PREP_FLAG;
+		/* fall through */
 	case IEEE80211_PROACTIVE_PREQ_NO_PREP:
 		interval = ifmsh->mshcfg.dot11MeshHWMPactivePathToRootTimeout;
 		target_flags |= IEEE80211_PREQ_TO_FLAG |
diff --git a/net/mac80211/mesh_plink.c b/net/mac80211/mesh_plink.c
index e2d00cc..0f6c9ca 100644
--- a/net/mac80211/mesh_plink.c
+++ b/net/mac80211/mesh_plink.c
@@ -672,7 +672,7 @@ void mesh_plink_timer(struct timer_list *t)
 			break;
 		}
 		reason = WLAN_REASON_MESH_MAX_RETRIES;
-		/* fall through on else */
+		/* fall through */
 	case NL80211_PLINK_CNF_RCVD:
 		/* confirm timer */
 		if (!reason)
diff --git a/net/mac80211/mlme.c b/net/mac80211/mlme.c
index e4ededa..f5f300fc4 100644
--- a/net/mac80211/mlme.c
+++ b/net/mac80211/mlme.c
@@ -473,6 +473,7 @@ static void ieee80211_add_ht_ie(struct ieee80211_sub_if_data *sdata,
 	case IEEE80211_SMPS_AUTOMATIC:
 	case IEEE80211_SMPS_NUM_MODES:
 		WARN_ON(1);
+		/* fall through */
 	case IEEE80211_SMPS_OFF:
 		cap |= WLAN_HT_CAP_SM_PS_DISABLED <<
 			IEEE80211_HT_CAP_SM_PS_SHIFT;
diff --git a/net/mac80211/offchannel.c b/net/mac80211/offchannel.c
index faf4f60..f1d40b6 100644
--- a/net/mac80211/offchannel.c
+++ b/net/mac80211/offchannel.c
@@ -801,14 +801,14 @@ int ieee80211_mgmt_tx(struct wiphy *wiphy, struct wireless_dev *wdev,
 	case NL80211_IFTYPE_ADHOC:
 		if (!sdata->vif.bss_conf.ibss_joined)
 			need_offchan = true;
-		/* fall through */
 #ifdef CONFIG_MAC80211_MESH
+		/* fall through */
 	case NL80211_IFTYPE_MESH_POINT:
 		if (ieee80211_vif_is_mesh(&sdata->vif) &&
 		    !sdata->u.mesh.mesh_id_len)
 			need_offchan = true;
-		/* fall through */
 #endif
+		/* fall through */
 	case NL80211_IFTYPE_AP:
 	case NL80211_IFTYPE_AP_VLAN:
 	case NL80211_IFTYPE_P2P_GO:
diff --git a/net/mac80211/tdls.c b/net/mac80211/tdls.c
index 91093d4..96d4fb9 100644
--- a/net/mac80211/tdls.c
+++ b/net/mac80211/tdls.c
@@ -236,6 +236,7 @@ static enum ieee80211_ac_numbers ieee80211_ac_from_wmm(int ac)
 	switch (ac) {
 	default:
 		WARN_ON_ONCE(1);
+		/* fall through */
 	case 0:
 		return IEEE80211_AC_BE;
 	case 1:
diff --git a/net/mac80211/wme.c b/net/mac80211/wme.c
index 3e3d301..5f7c963 100644
--- a/net/mac80211/wme.c
+++ b/net/mac80211/wme.c
@@ -165,6 +165,7 @@ u16 ieee80211_select_queue(struct ieee80211_sub_if_data *sdata,
 			qos = sta->sta.wme;
 			break;
 		}
+		/* fall through */
 	case NL80211_IFTYPE_AP:
 		ra = skb->data;
 		break;
-- 
2.7.4
