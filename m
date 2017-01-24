From: =?UTF-8?q?Amadeusz=20S=C5=82awi=C5=84ski?=
        <amadeusz.slawinski@tieto.com>
Subject: [PATCH 1/2] mac80211: use helper function to access ieee802_1d_to_ac[]
Date: Tue, 24 Jan 2017 16:42:10 +0100
Message-ID: <1485272531-11587-1-git-send-email-amadeusz.slawinski@tieto.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        =?UTF-8?q?Amadeusz=20S=C5=82awi=C5=84ski?=
        <amadeusz.slawinski@tieto.com>
To: linux-wireless@vger.kernel.org,
        Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

cleanup patch to make use of ieee80211_ac_from_tid() to retrieve ac from
ieee802_1d_to_ac[]

Signed-off-by: Amadeusz Sławiński <amadeusz.slawinski@tieto.com>
---
 net/mac80211/rx.c     | 2 +-
 net/mac80211/status.c | 2 +-
 net/mac80211/tx.c     | 4 ++--
 3 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/mac80211/rx.c b/net/mac80211/rx.c
index 3e289a6..cf8ed1c 100644
--- a/net/mac80211/rx.c
+++ b/net/mac80211/rx.c
@@ -1391,7 +1391,7 @@ void ieee80211_sta_pspoll(struct ieee80211_sta *pubsta)
 void ieee80211_sta_uapsd_trigger(struct ieee80211_sta *pubsta, u8 tid)
 {
 	struct sta_info *sta = container_of(pubsta, struct sta_info, sta);
-	u8 ac = ieee802_1d_to_ac[tid & 7];
+	int ac = ieee80211_ac_from_tid(tid);
 
 	/*
 	 * If this AC is not trigger-enabled do nothing unless the
diff --git a/net/mac80211/status.c b/net/mac80211/status.c
index ddf71c6..dd48de0 100644
--- a/net/mac80211/status.c
+++ b/net/mac80211/status.c
@@ -95,7 +95,7 @@ static void ieee80211_handle_filtered_frame(struct ieee80211_local *local,
 		 */
 		if (*p & IEEE80211_QOS_CTL_EOSP)
 			*p &= ~IEEE80211_QOS_CTL_EOSP;
-		ac = ieee802_1d_to_ac[tid & 7];
+		ac = ieee80211_ac_from_tid(tid);
 	} else {
 		ac = IEEE80211_AC_BE;
 	}
diff --git a/net/mac80211/tx.c b/net/mac80211/tx.c
index 0d8b716..009eb36 100644
--- a/net/mac80211/tx.c
+++ b/net/mac80211/tx.c
@@ -1410,7 +1410,7 @@ void ieee80211_txq_init(struct ieee80211_sub_if_data *sdata,
 		txqi->txq.sta = &sta->sta;
 		sta->sta.txq[tid] = &txqi->txq;
 		txqi->txq.tid = tid;
-		txqi->txq.ac = ieee802_1d_to_ac[tid & 7];
+		txqi->txq.ac = ieee80211_ac_from_tid(tid);
 	} else {
 		sdata->vif.txq = &txqi->txq;
 		txqi->txq.tid = 0;
@@ -4542,7 +4542,7 @@ void __ieee80211_tx_skb_tid_band(struct ieee80211_sub_if_data *sdata,
 				 struct sk_buff *skb, int tid,
 				 enum nl80211_band band)
 {
-	int ac = ieee802_1d_to_ac[tid & 7];
+	int ac = ieee80211_ac_from_tid(tid);
 
 	skb_reset_mac_header(skb);
 	skb_set_queue_mapping(skb, ac);
-- 
1.9.1
