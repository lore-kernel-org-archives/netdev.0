From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 12/14] mac80211: Use eth_<foo>_addr instead of memset
Date: Mon,  2 Mar 2015 19:54:57 -0800
Message-ID: <ed752a8f58f38dc7be7d38cda40b9c900677844c.1425354528.git.joe@perches.com>
References: <cover.1425354527.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org, Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1425354527.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use the built-in function instead of memset.

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/mac80211/cfg.c  |  2 +-
 net/mac80211/ibss.c |  2 +-
 net/mac80211/mesh.c |  2 +-
 net/mac80211/mlme.c | 10 +++++-----
 4 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/net/mac80211/cfg.c b/net/mac80211/cfg.c
index dd4ff36..74f509c 100644
--- a/net/mac80211/cfg.c
+++ b/net/mac80211/cfg.c
@@ -1488,7 +1488,7 @@ static void mpath_set_pinfo(struct mesh_path *mpath, u8 *next_hop,
 	if (next_hop_sta)
 		memcpy(next_hop, next_hop_sta->sta.addr, ETH_ALEN);
 	else
-		memset(next_hop, 0, ETH_ALEN);
+		eth_zero_addr(next_hop);
 
 	memset(pinfo, 0, sizeof(*pinfo));
 
diff --git a/net/mac80211/ibss.c b/net/mac80211/ibss.c
index b606b53..f9b0758 100644
--- a/net/mac80211/ibss.c
+++ b/net/mac80211/ibss.c
@@ -1742,7 +1742,7 @@ int ieee80211_ibss_leave(struct ieee80211_sub_if_data *sdata)
 
 	ieee80211_ibss_disconnect(sdata);
 	ifibss->ssid_len = 0;
-	memset(ifibss->bssid, 0, ETH_ALEN);
+	eth_zero_addr(ifibss->bssid);
 
 	/* remove beacon */
 	kfree(sdata->u.ibss.ie);
diff --git a/net/mac80211/mesh.c b/net/mac80211/mesh.c
index 0c8b2a7..49a44bc 100644
--- a/net/mac80211/mesh.c
+++ b/net/mac80211/mesh.c
@@ -520,7 +520,7 @@ int ieee80211_fill_mesh_addresses(struct ieee80211_hdr *hdr, __le16 *fc,
 	} else {
 		*fc |= cpu_to_le16(IEEE80211_FCTL_FROMDS | IEEE80211_FCTL_TODS);
 		/* RA TA DA SA */
-		memset(hdr->addr1, 0, ETH_ALEN);   /* RA is resolved later */
+		eth_zero_addr(hdr->addr1);   /* RA is resolved later */
 		memcpy(hdr->addr2, meshsa, ETH_ALEN);
 		memcpy(hdr->addr3, meshda, ETH_ALEN);
 		memcpy(hdr->addr4, meshsa, ETH_ALEN);
diff --git a/net/mac80211/mlme.c b/net/mac80211/mlme.c
index 10ac632..9f6f356 100644
--- a/net/mac80211/mlme.c
+++ b/net/mac80211/mlme.c
@@ -2033,7 +2033,7 @@ static void ieee80211_set_disassoc(struct ieee80211_sub_if_data *sdata,
 		ieee80211_flush_queues(local, sdata, false);
 
 	/* clear bssid only after building the needed mgmt frames */
-	memset(ifmgd->bssid, 0, ETH_ALEN);
+	eth_zero_addr(ifmgd->bssid);
 
 	/* remove AP and TDLS peers */
 	sta_info_flush(sdata);
@@ -2464,7 +2464,7 @@ static void ieee80211_destroy_auth_data(struct ieee80211_sub_if_data *sdata,
 		del_timer_sync(&sdata->u.mgd.timer);
 		sta_info_destroy_addr(sdata, auth_data->bss->bssid);
 
-		memset(sdata->u.mgd.bssid, 0, ETH_ALEN);
+		eth_zero_addr(sdata->u.mgd.bssid);
 		ieee80211_bss_info_change_notify(sdata, BSS_CHANGED_BSSID);
 		sdata->u.mgd.flags = 0;
 		mutex_lock(&sdata->local->mtx);
@@ -2777,7 +2777,7 @@ static void ieee80211_destroy_assoc_data(struct ieee80211_sub_if_data *sdata,
 		del_timer_sync(&sdata->u.mgd.timer);
 		sta_info_destroy_addr(sdata, assoc_data->bss->bssid);
 
-		memset(sdata->u.mgd.bssid, 0, ETH_ALEN);
+		eth_zero_addr(sdata->u.mgd.bssid);
 		ieee80211_bss_info_change_notify(sdata, BSS_CHANGED_BSSID);
 		sdata->u.mgd.flags = 0;
 		mutex_lock(&sdata->local->mtx);
@@ -4474,7 +4474,7 @@ int ieee80211_mgd_auth(struct ieee80211_sub_if_data *sdata,
 	return 0;
 
  err_clear:
-	memset(ifmgd->bssid, 0, ETH_ALEN);
+	eth_zero_addr(ifmgd->bssid);
 	ieee80211_bss_info_change_notify(sdata, BSS_CHANGED_BSSID);
 	ifmgd->auth_data = NULL;
  err_free:
@@ -4817,7 +4817,7 @@ int ieee80211_mgd_assoc(struct ieee80211_sub_if_data *sdata,
 
 	return 0;
  err_clear:
-	memset(ifmgd->bssid, 0, ETH_ALEN);
+	eth_zero_addr(ifmgd->bssid);
 	ieee80211_bss_info_change_notify(sdata, BSS_CHANGED_BSSID);
 	ifmgd->assoc_data = NULL;
  err_free:
-- 
2.1.2
