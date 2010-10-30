From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH 37/39] net/mac80211: Update WARN uses
Date: Sat, 30 Oct 2010 14:08:54 -0700
Message-ID: <de75963e04701e309b86dfee54c36e11873048c2.1288471898.git.joe@perches.com>
References: <cover.1288471897.git.joe@perches.com>
Cc: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Jiri Kosina <trivial-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <cover.1288471897.git.joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Coalesce long formats.
Add missing newlines.

Signed-off-by: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
---
 net/mac80211/agg-tx.c |    5 +++--
 net/mac80211/iface.c  |    4 ++--
 net/mac80211/mlme.c   |    2 +-
 net/mac80211/rx.c     |    4 +---
 net/mac80211/tx.c     |    4 +---
 net/mac80211/util.c   |    4 +---
 net/mac80211/work.c   |    4 ++--
 7 files changed, 11 insertions(+), 16 deletions(-)

diff --git a/net/mac80211/agg-tx.c b/net/mac80211/agg-tx.c
index d4679b2..9f2c3f6 100644
--- a/net/mac80211/agg-tx.c
+++ b/net/mac80211/agg-tx.c
@@ -454,8 +454,9 @@ ieee80211_agg_splice_packets(struct ieee80211_local *local,
 
 	ieee80211_stop_queue_agg(local, tid);
 
-	if (WARN(!tid_tx, "TID %d gone but expected when splicing aggregates"
-			  " from the pending queue\n", tid))
+	if (WARN(!tid_tx,
+		 "TID %d gone but expected when splicing aggregates from the pending queue\n",
+		 tid))
 		return;
 
 	if (!skb_queue_empty(&tid_tx->pending)) {
diff --git a/net/mac80211/iface.c b/net/mac80211/iface.c
index f9163b1..328e637 100644
--- a/net/mac80211/iface.c
+++ b/net/mac80211/iface.c
@@ -820,7 +820,7 @@ static void ieee80211_iface_work(struct work_struct *work)
 			ieee80211_mesh_rx_queued_mgmt(sdata, skb);
 			break;
 		default:
-			WARN(1, "frame for unexpected interface type");
+			WARN(1, "frame for unexpected interface type\n");
 			break;
 		}
 
@@ -979,7 +979,7 @@ static int ieee80211_runtime_change_iftype(struct ieee80211_sub_if_data *sdata,
 	ieee80211_setup_sdata(sdata, type);
 
 	err = ieee80211_do_open(sdata->dev, false);
-	WARN(err, "type change: do_open returned %d", err);
+	WARN(err, "type change: do_open returned %d\n", err);
 
 	return ret;
 }
diff --git a/net/mac80211/mlme.c b/net/mac80211/mlme.c
index a3a9421..22f054a 100644
--- a/net/mac80211/mlme.c
+++ b/net/mac80211/mlme.c
@@ -1780,7 +1780,7 @@ void ieee80211_sta_rx_queued_mgmt(struct ieee80211_sub_if_data *sdata,
 			cfg80211_send_disassoc(sdata->dev, (u8 *)mgmt, skb->len);
 			break;
 		default:
-			WARN(1, "unexpected: %d", rma);
+			WARN(1, "unexpected: %d\n", rma);
 		}
 		return;
 	}
diff --git a/net/mac80211/rx.c b/net/mac80211/rx.c
index 902b03e..7775375 100644
--- a/net/mac80211/rx.c
+++ b/net/mac80211/rx.c
@@ -2840,9 +2840,7 @@ void ieee80211_rx(struct ieee80211_hw *hw, struct sk_buff *skb)
 			 */
 			if (WARN((status->rate_idx < 0 ||
 				 status->rate_idx > 76),
-				 "Rate marked as an HT rate but passed "
-				 "status->rate_idx is not "
-				 "an MCS index [0-76]: %d (0x%02x)\n",
+				 "Rate marked as an HT rate but passed status->rate_idx is not an MCS index [0-76]: %d (0x%02x)\n",
 				 status->rate_idx,
 				 status->rate_idx))
 				goto drop;
diff --git a/net/mac80211/tx.c b/net/mac80211/tx.c
index 96c5943..a511d69 100644
--- a/net/mac80211/tx.c
+++ b/net/mac80211/tx.c
@@ -649,9 +649,7 @@ ieee80211_tx_h_rate_ctrl(struct ieee80211_tx_data *tx)
 	if (WARN(test_bit(SCAN_SW_SCANNING, &tx->local->scanning) &&
 		 (sta_flags & WLAN_STA_ASSOC) &&
 		 !rate_usable_index_exists(sband, &tx->sta->sta),
-		 "%s: Dropped data frame as no usable bitrate found while "
-		 "scanning and associated. Target station: "
-		 "%pM on %d GHz band\n",
+		 "%s: Dropped data frame as no usable bitrate found while scanning and associated. Target station: %pM on %d GHz band\n",
 		 tx->sdata->name, hdr->addr1,
 		 tx->channel->band ? 5 : 2))
 		return TX_DROP;
diff --git a/net/mac80211/util.c b/net/mac80211/util.c
index 0b6fc92..2a14723 100644
--- a/net/mac80211/util.c
+++ b/net/mac80211/util.c
@@ -1120,9 +1120,7 @@ int ieee80211_reconfig(struct ieee80211_local *local)
 		 */
 		res = drv_start(local);
 		if (res) {
-			WARN(local->suspended, "Hardware became unavailable "
-			     "upon resume. This could be a software issue "
-			     "prior to suspend or a hardware issue.\n");
+			WARN(local->suspended, "Hardware became unavailable upon resume. This could be a software issue prior to suspend or a hardware issue.\n");
 			return res;
 		}
 
diff --git a/net/mac80211/work.c b/net/mac80211/work.c
index ae344d1..8583206 100644
--- a/net/mac80211/work.c
+++ b/net/mac80211/work.c
@@ -830,7 +830,7 @@ static void ieee80211_work_rx_queued_mgmt(struct ieee80211_local *local,
 		list_del_rcu(&wk->list);
 		break;
 	default:
-		WARN(1, "unexpected: %d", rma);
+		WARN(1, "unexpected: %d\n", rma);
 	}
 
 	mutex_unlock(&local->mtx);
@@ -973,7 +973,7 @@ static void ieee80211_work_work(struct work_struct *work)
 			list_add(&wk->list, &free_work);
 			break;
 		default:
-			WARN(1, "unexpected: %d", rma);
+			WARN(1, "unexpected: %d\n", rma);
 		}
 	}
 
-- 
1.7.3.1.g432b3.dirty

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
