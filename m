From: Simon Wunderlich <sw@simonwunderlich.de>
Subject: [PATCH 05/19] batman-adv: Convert BATADV_PRINT_VID macro to function
Date: Thu,  6 Apr 2017 16:07:27 +0200
Message-ID: <20170406140741.30745-6-sw@simonwunderlich.de>
References: <20170406140741.30745-1-sw@simonwunderlich.de>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
        Sven Eckelmann <sven@narfation.org>,
        Simon Wunderlich <sw@simonwunderlich.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from packetmixer.de ([79.140.42.25]:32928 "EHLO
        mail.mail.packetmixer.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934953AbdDFOHs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Apr 2017 10:07:48 -0400
In-Reply-To: <20170406140741.30745-1-sw@simonwunderlich.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

The BATADV_PRINT_VID is not free of of possible side-effects. This can be
avoided when the the macro is converted to a simple inline function.

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Simon Wunderlich <sw@simonwunderlich.de>
---
 net/batman-adv/bridge_loop_avoidance.c | 38 +++++++++++++++++-----------------
 net/batman-adv/distributed-arp-table.c |  6 +++---
 net/batman-adv/main.h                  | 16 ++++++++++++--
 net/batman-adv/translation-table.c     | 36 ++++++++++++++++----------------
 4 files changed, 54 insertions(+), 42 deletions(-)

diff --git a/net/batman-adv/bridge_loop_avoidance.c b/net/batman-adv/bridge_loop_avoidance.c
index ba8420d8a992..7332d284b0fc 100644
--- a/net/batman-adv/bridge_loop_avoidance.c
+++ b/net/batman-adv/bridge_loop_avoidance.c
@@ -395,7 +395,7 @@ static void batadv_bla_send_claim(struct batadv_priv *bat_priv, u8 *mac,
 		ether_addr_copy(ethhdr->h_source, mac);
 		batadv_dbg(BATADV_DBG_BLA, bat_priv,
 			   "bla_send_claim(): CLAIM %pM on vid %d\n", mac,
-			   BATADV_PRINT_VID(vid));
+			   batadv_print_vid(vid));
 		break;
 	case BATADV_CLAIM_TYPE_UNCLAIM:
 		/* unclaim frame
@@ -404,7 +404,7 @@ static void batadv_bla_send_claim(struct batadv_priv *bat_priv, u8 *mac,
 		ether_addr_copy(hw_src, mac);
 		batadv_dbg(BATADV_DBG_BLA, bat_priv,
 			   "bla_send_claim(): UNCLAIM %pM on vid %d\n", mac,
-			   BATADV_PRINT_VID(vid));
+			   batadv_print_vid(vid));
 		break;
 	case BATADV_CLAIM_TYPE_ANNOUNCE:
 		/* announcement frame
@@ -413,7 +413,7 @@ static void batadv_bla_send_claim(struct batadv_priv *bat_priv, u8 *mac,
 		ether_addr_copy(hw_src, mac);
 		batadv_dbg(BATADV_DBG_BLA, bat_priv,
 			   "bla_send_claim(): ANNOUNCE of %pM on vid %d\n",
-			   ethhdr->h_source, BATADV_PRINT_VID(vid));
+			   ethhdr->h_source, batadv_print_vid(vid));
 		break;
 	case BATADV_CLAIM_TYPE_REQUEST:
 		/* request frame
@@ -425,14 +425,14 @@ static void batadv_bla_send_claim(struct batadv_priv *bat_priv, u8 *mac,
 		batadv_dbg(BATADV_DBG_BLA, bat_priv,
 			   "bla_send_claim(): REQUEST of %pM to %pM on vid %d\n",
 			   ethhdr->h_source, ethhdr->h_dest,
-			   BATADV_PRINT_VID(vid));
+			   batadv_print_vid(vid));
 		break;
 	case BATADV_CLAIM_TYPE_LOOPDETECT:
 		ether_addr_copy(ethhdr->h_source, mac);
 		batadv_dbg(BATADV_DBG_BLA, bat_priv,
 			   "bla_send_claim(): LOOPDETECT of %pM to %pM on vid %d\n",
 			   ethhdr->h_source, ethhdr->h_dest,
-			   BATADV_PRINT_VID(vid));
+			   batadv_print_vid(vid));
 
 		break;
 	}
@@ -475,9 +475,9 @@ static void batadv_bla_loopdetect_report(struct work_struct *work)
 
 	batadv_info(bat_priv->soft_iface,
 		    "Possible loop on VLAN %d detected which can't be handled by BLA - please check your network setup!\n",
-		    BATADV_PRINT_VID(backbone_gw->vid));
+		    batadv_print_vid(backbone_gw->vid));
 	snprintf(vid_str, sizeof(vid_str), "%d",
-		 BATADV_PRINT_VID(backbone_gw->vid));
+		 batadv_print_vid(backbone_gw->vid));
 	vid_str[sizeof(vid_str) - 1] = 0;
 
 	batadv_throw_uevent(bat_priv, BATADV_UEV_BLA, BATADV_UEV_LOOPDETECT,
@@ -510,7 +510,7 @@ batadv_bla_get_backbone_gw(struct batadv_priv *bat_priv, u8 *orig,
 
 	batadv_dbg(BATADV_DBG_BLA, bat_priv,
 		   "bla_get_backbone_gw(): not found (%pM, %d), creating new entry\n",
-		   orig, BATADV_PRINT_VID(vid));
+		   orig, batadv_print_vid(vid));
 
 	entry = kzalloc(sizeof(*entry), GFP_ATOMIC);
 	if (!entry)
@@ -719,7 +719,7 @@ static void batadv_bla_add_claim(struct batadv_priv *bat_priv,
 
 		batadv_dbg(BATADV_DBG_BLA, bat_priv,
 			   "bla_add_claim(): adding new entry %pM, vid %d to hash ...\n",
-			   mac, BATADV_PRINT_VID(vid));
+			   mac, batadv_print_vid(vid));
 
 		kref_get(&claim->refcount);
 		hash_added = batadv_hash_add(bat_priv->bla.claim_hash,
@@ -740,7 +740,7 @@ static void batadv_bla_add_claim(struct batadv_priv *bat_priv,
 
 		batadv_dbg(BATADV_DBG_BLA, bat_priv,
 			   "bla_add_claim(): changing ownership for %pM, vid %d\n",
-			   mac, BATADV_PRINT_VID(vid));
+			   mac, batadv_print_vid(vid));
 
 		remove_crc = true;
 	}
@@ -809,7 +809,7 @@ static void batadv_bla_del_claim(struct batadv_priv *bat_priv,
 		return;
 
 	batadv_dbg(BATADV_DBG_BLA, bat_priv, "bla_del_claim(): %pM, vid %d\n",
-		   mac, BATADV_PRINT_VID(vid));
+		   mac, batadv_print_vid(vid));
 
 	batadv_hash_remove(bat_priv->bla.claim_hash, batadv_compare_claim,
 			   batadv_choose_claim, claim);
@@ -849,7 +849,7 @@ static bool batadv_handle_announce(struct batadv_priv *bat_priv, u8 *an_addr,
 
 	batadv_dbg(BATADV_DBG_BLA, bat_priv,
 		   "handle_announce(): ANNOUNCE vid %d (sent by %pM)... CRC = %#.4x\n",
-		   BATADV_PRINT_VID(vid), backbone_gw->orig, crc);
+		   batadv_print_vid(vid), backbone_gw->orig, crc);
 
 	spin_lock_bh(&backbone_gw->crc_lock);
 	backbone_crc = backbone_gw->crc;
@@ -859,7 +859,7 @@ static bool batadv_handle_announce(struct batadv_priv *bat_priv, u8 *an_addr,
 		batadv_dbg(BATADV_DBG_BLA, backbone_gw->bat_priv,
 			   "handle_announce(): CRC FAILED for %pM/%d (my = %#.4x, sent = %#.4x)\n",
 			   backbone_gw->orig,
-			   BATADV_PRINT_VID(backbone_gw->vid),
+			   batadv_print_vid(backbone_gw->vid),
 			   backbone_crc, crc);
 
 		batadv_bla_send_request(backbone_gw);
@@ -904,7 +904,7 @@ static bool batadv_handle_request(struct batadv_priv *bat_priv,
 
 	batadv_dbg(BATADV_DBG_BLA, bat_priv,
 		   "handle_request(): REQUEST vid %d (sent by %pM)...\n",
-		   BATADV_PRINT_VID(vid), ethhdr->h_source);
+		   batadv_print_vid(vid), ethhdr->h_source);
 
 	batadv_bla_answer_request(bat_priv, primary_if, vid);
 	return true;
@@ -941,7 +941,7 @@ static bool batadv_handle_unclaim(struct batadv_priv *bat_priv,
 	/* this must be an UNCLAIM frame */
 	batadv_dbg(BATADV_DBG_BLA, bat_priv,
 		   "handle_unclaim(): UNCLAIM %pM on vid %d (sent by %pM)...\n",
-		   claim_addr, BATADV_PRINT_VID(vid), backbone_gw->orig);
+		   claim_addr, batadv_print_vid(vid), backbone_gw->orig);
 
 	batadv_bla_del_claim(bat_priv, claim_addr, vid);
 	batadv_backbone_gw_put(backbone_gw);
@@ -1161,7 +1161,7 @@ static bool batadv_bla_process_claim(struct batadv_priv *bat_priv,
 	if (ret == 1)
 		batadv_dbg(BATADV_DBG_BLA, bat_priv,
 			   "bla_process_claim(): received a claim frame from another group. From: %pM on vid %d ...(hw_src %pM, hw_dst %pM)\n",
-			   ethhdr->h_source, BATADV_PRINT_VID(vid), hw_src,
+			   ethhdr->h_source, batadv_print_vid(vid), hw_src,
 			   hw_dst);
 
 	if (ret < 2)
@@ -1197,7 +1197,7 @@ static bool batadv_bla_process_claim(struct batadv_priv *bat_priv,
 
 	batadv_dbg(BATADV_DBG_BLA, bat_priv,
 		   "bla_process_claim(): ERROR - this looks like a claim frame, but is useless. eth src %pM on vid %d ...(hw_src %pM, hw_dst %pM)\n",
-		   ethhdr->h_source, BATADV_PRINT_VID(vid), hw_src, hw_dst);
+		   ethhdr->h_source, batadv_print_vid(vid), hw_src, hw_dst);
 	return true;
 }
 
@@ -2042,7 +2042,7 @@ int batadv_bla_claim_table_seq_print_text(struct seq_file *seq, void *offset)
 			backbone_crc = backbone_gw->crc;
 			spin_unlock_bh(&backbone_gw->crc_lock);
 			seq_printf(seq, " * %pM on %5d by %pM [%c] (%#.4x)\n",
-				   claim->addr, BATADV_PRINT_VID(claim->vid),
+				   claim->addr, batadv_print_vid(claim->vid),
 				   backbone_gw->orig,
 				   (is_own ? 'x' : ' '),
 				   backbone_crc);
@@ -2274,7 +2274,7 @@ int batadv_bla_backbone_table_seq_print_text(struct seq_file *seq, void *offset)
 
 			seq_printf(seq, " * %pM on %5d %4i.%03is (%#.4x)\n",
 				   backbone_gw->orig,
-				   BATADV_PRINT_VID(backbone_gw->vid), secs,
+				   batadv_print_vid(backbone_gw->vid), secs,
 				   msecs, backbone_crc);
 		}
 		rcu_read_unlock();
diff --git a/net/batman-adv/distributed-arp-table.c b/net/batman-adv/distributed-arp-table.c
index 1bfd1dbc2feb..4f643fdb5bc6 100644
--- a/net/batman-adv/distributed-arp-table.c
+++ b/net/batman-adv/distributed-arp-table.c
@@ -330,7 +330,7 @@ static void batadv_dat_entry_add(struct batadv_priv *bat_priv, __be32 ip,
 		batadv_dbg(BATADV_DBG_DAT, bat_priv,
 			   "Entry updated: %pI4 %pM (vid: %d)\n",
 			   &dat_entry->ip, dat_entry->mac_addr,
-			   BATADV_PRINT_VID(vid));
+			   batadv_print_vid(vid));
 		goto out;
 	}
 
@@ -356,7 +356,7 @@ static void batadv_dat_entry_add(struct batadv_priv *bat_priv, __be32 ip,
 	}
 
 	batadv_dbg(BATADV_DBG_DAT, bat_priv, "New entry added: %pI4 %pM (vid: %d)\n",
-		   &dat_entry->ip, dat_entry->mac_addr, BATADV_PRINT_VID(vid));
+		   &dat_entry->ip, dat_entry->mac_addr, batadv_print_vid(vid));
 
 out:
 	if (dat_entry)
@@ -835,7 +835,7 @@ int batadv_dat_cache_seq_print_text(struct seq_file *seq, void *offset)
 
 			seq_printf(seq, " * %15pI4 %14pM %4i %6i:%02i\n",
 				   &dat_entry->ip, dat_entry->mac_addr,
-				   BATADV_PRINT_VID(dat_entry->vid),
+				   batadv_print_vid(dat_entry->vid),
 				   last_seen_mins, last_seen_secs);
 		}
 		rcu_read_unlock();
diff --git a/net/batman-adv/main.h b/net/batman-adv/main.h
index f87b17c613a6..810f7d026f54 100644
--- a/net/batman-adv/main.h
+++ b/net/batman-adv/main.h
@@ -193,6 +193,7 @@ enum batadv_uev_type {
 #include <linux/percpu.h>
 #include <linux/types.h>
 
+#include "packet.h"
 #include "types.h"
 
 struct net_device;
@@ -200,8 +201,19 @@ struct packet_type;
 struct seq_file;
 struct sk_buff;
 
-#define BATADV_PRINT_VID(vid) (((vid) & BATADV_VLAN_HAS_TAG) ? \
-			       (int)((vid) & VLAN_VID_MASK) : -1)
+/**
+ * batadv_print_vid - return printable version of vid information
+ * @vid: the VLAN identifier
+ *
+ * Return: -1 when no VLAN is used, VLAN id otherwise
+ */
+static inline int batadv_print_vid(unsigned short vid)
+{
+	if (vid & BATADV_VLAN_HAS_TAG)
+		return (int)(vid & VLAN_VID_MASK);
+	else
+		return -1;
+}
 
 extern struct list_head batadv_hardif_list;
 
diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index a75f0a640bcd..e75b4937b497 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -617,7 +617,7 @@ static void batadv_tt_global_free(struct batadv_priv *bat_priv,
 	batadv_dbg(BATADV_DBG_TT, bat_priv,
 		   "Deleting global tt entry %pM (vid: %d): %s\n",
 		   tt_global->common.addr,
-		   BATADV_PRINT_VID(tt_global->common.vid), message);
+		   batadv_print_vid(tt_global->common.vid), message);
 
 	batadv_hash_remove(bat_priv->tt.global_hash, batadv_compare_tt,
 			   batadv_choose_tt, &tt_global->common);
@@ -671,7 +671,7 @@ bool batadv_tt_local_add(struct net_device *soft_iface, const u8 *addr,
 		if (tt_local->common.flags & BATADV_TT_CLIENT_PENDING) {
 			batadv_dbg(BATADV_DBG_TT, bat_priv,
 				   "Re-adding pending client %pM (vid: %d)\n",
-				   addr, BATADV_PRINT_VID(vid));
+				   addr, batadv_print_vid(vid));
 			/* whatever the reason why the PENDING flag was set,
 			 * this is a client which was enqueued to be removed in
 			 * this orig_interval. Since it popped up again, the
@@ -684,7 +684,7 @@ bool batadv_tt_local_add(struct net_device *soft_iface, const u8 *addr,
 		if (tt_local->common.flags & BATADV_TT_CLIENT_ROAM) {
 			batadv_dbg(BATADV_DBG_TT, bat_priv,
 				   "Roaming client %pM (vid: %d) came back to its original location\n",
-				   addr, BATADV_PRINT_VID(vid));
+				   addr, batadv_print_vid(vid));
 			/* the ROAM flag is set because this client roamed away
 			 * and the node got a roaming_advertisement message. Now
 			 * that the client popped up again at its original
@@ -716,7 +716,7 @@ bool batadv_tt_local_add(struct net_device *soft_iface, const u8 *addr,
 	if (!vlan) {
 		net_ratelimited_function(batadv_info, soft_iface,
 					 "adding TT local entry %pM to non-existent VLAN %d\n",
-					 addr, BATADV_PRINT_VID(vid));
+					 addr, batadv_print_vid(vid));
 		kmem_cache_free(batadv_tl_cache, tt_local);
 		tt_local = NULL;
 		goto out;
@@ -724,7 +724,7 @@ bool batadv_tt_local_add(struct net_device *soft_iface, const u8 *addr,
 
 	batadv_dbg(BATADV_DBG_TT, bat_priv,
 		   "Creating new local tt entry: %pM (vid: %d, ttvn: %d)\n",
-		   addr, BATADV_PRINT_VID(vid),
+		   addr, batadv_print_vid(vid),
 		   (u8)atomic_read(&bat_priv->tt.vn));
 
 	ether_addr_copy(tt_local->common.addr, addr);
@@ -1097,7 +1097,7 @@ int batadv_tt_local_seq_print_text(struct seq_file *seq, void *offset)
 			seq_printf(seq,
 				   " * %pM %4i [%c%c%c%c%c%c] %3u.%03u   (%#.8x)\n",
 				   tt_common_entry->addr,
-				   BATADV_PRINT_VID(tt_common_entry->vid),
+				   batadv_print_vid(tt_common_entry->vid),
 				   ((tt_common_entry->flags &
 				     BATADV_TT_CLIENT_ROAM) ? 'R' : '.'),
 				   no_purge ? 'P' : '.',
@@ -1296,7 +1296,7 @@ batadv_tt_local_set_pending(struct batadv_priv *bat_priv,
 	batadv_dbg(BATADV_DBG_TT, bat_priv,
 		   "Local tt entry (%pM, vid: %d) pending to be removed: %s\n",
 		   tt_local_entry->common.addr,
-		   BATADV_PRINT_VID(tt_local_entry->common.vid), message);
+		   batadv_print_vid(tt_local_entry->common.vid), message);
 }
 
 /**
@@ -1727,7 +1727,7 @@ static bool batadv_tt_global_add(struct batadv_priv *bat_priv,
 
 	batadv_dbg(BATADV_DBG_TT, bat_priv,
 		   "Creating new global tt entry: %pM (vid: %d, via %pM)\n",
-		   common->addr, BATADV_PRINT_VID(common->vid),
+		   common->addr, batadv_print_vid(common->vid),
 		   orig_node->orig);
 	ret = true;
 
@@ -1835,7 +1835,7 @@ batadv_tt_global_print_entry(struct batadv_priv *bat_priv,
 		if (!vlan) {
 			seq_printf(seq,
 				   " * Cannot retrieve VLAN %d for originator %pM\n",
-				   BATADV_PRINT_VID(tt_common_entry->vid),
+				   batadv_print_vid(tt_common_entry->vid),
 				   best_entry->orig_node->orig);
 			goto print_list;
 		}
@@ -1844,7 +1844,7 @@ batadv_tt_global_print_entry(struct batadv_priv *bat_priv,
 		seq_printf(seq,
 			   " %c %pM %4i   (%3u) via %pM     (%3u)   (%#.8x) [%c%c%c%c]\n",
 			   '*', tt_global_entry->common.addr,
-			   BATADV_PRINT_VID(tt_global_entry->common.vid),
+			   batadv_print_vid(tt_global_entry->common.vid),
 			   best_entry->ttvn, best_entry->orig_node->orig,
 			   last_ttvn, vlan->tt.crc,
 			   ((flags & BATADV_TT_CLIENT_ROAM) ? 'R' : '.'),
@@ -1867,7 +1867,7 @@ batadv_tt_global_print_entry(struct batadv_priv *bat_priv,
 		if (!vlan) {
 			seq_printf(seq,
 				   " + Cannot retrieve VLAN %d for originator %pM\n",
-				   BATADV_PRINT_VID(tt_common_entry->vid),
+				   batadv_print_vid(tt_common_entry->vid),
 				   orig_entry->orig_node->orig);
 			continue;
 		}
@@ -1876,7 +1876,7 @@ batadv_tt_global_print_entry(struct batadv_priv *bat_priv,
 		seq_printf(seq,
 			   " %c %pM %4d   (%3u) via %pM     (%3u)   (%#.8x) [%c%c%c%c]\n",
 			   '+', tt_global_entry->common.addr,
-			   BATADV_PRINT_VID(tt_global_entry->common.vid),
+			   batadv_print_vid(tt_global_entry->common.vid),
 			   orig_entry->ttvn, orig_entry->orig_node->orig,
 			   last_ttvn, vlan->tt.crc,
 			   ((flags & BATADV_TT_CLIENT_ROAM) ? 'R' : '.'),
@@ -2213,7 +2213,7 @@ batadv_tt_global_del_orig_node(struct batadv_priv *bat_priv,
 				   "Deleting %pM from global tt entry %pM (vid: %d): %s\n",
 				   orig_node->orig,
 				   tt_global_entry->common.addr,
-				   BATADV_PRINT_VID(vid), message);
+				   batadv_print_vid(vid), message);
 			_batadv_tt_global_del_orig_entry(tt_global_entry,
 							 orig_entry);
 		}
@@ -2377,7 +2377,7 @@ void batadv_tt_global_del_orig(struct batadv_priv *bat_priv,
 				batadv_dbg(BATADV_DBG_TT, bat_priv,
 					   "Deleting global tt entry %pM (vid: %d): %s\n",
 					   tt_global->common.addr,
-					   BATADV_PRINT_VID(vid), message);
+					   batadv_print_vid(vid), message);
 				hlist_del_rcu(&tt_common_entry->hash_entry);
 				batadv_tt_global_entry_put(tt_global);
 			}
@@ -2437,7 +2437,7 @@ static void batadv_tt_global_purge(struct batadv_priv *bat_priv)
 			batadv_dbg(BATADV_DBG_TT, bat_priv,
 				   "Deleting global tt entry %pM (vid: %d): %s\n",
 				   tt_global->common.addr,
-				   BATADV_PRINT_VID(tt_global->common.vid),
+				   batadv_print_vid(tt_global->common.vid),
 				   msg);
 
 			hlist_del_rcu(&tt_common->hash_entry);
@@ -3652,7 +3652,7 @@ static void batadv_send_roam_adv(struct batadv_priv *bat_priv, u8 *client,
 
 	batadv_dbg(BATADV_DBG_TT, bat_priv,
 		   "Sending ROAMING_ADV to %pM (client %pM, vid: %d)\n",
-		   orig_node->orig, client, BATADV_PRINT_VID(vid));
+		   orig_node->orig, client, batadv_print_vid(vid));
 
 	batadv_inc_counter(bat_priv, BATADV_CNT_TT_ROAM_ADV_TX);
 
@@ -3775,7 +3775,7 @@ static void batadv_tt_local_purge_pending_clients(struct batadv_priv *bat_priv)
 			batadv_dbg(BATADV_DBG_TT, bat_priv,
 				   "Deleting local tt entry (%pM, vid: %d): pending\n",
 				   tt_common->addr,
-				   BATADV_PRINT_VID(tt_common->vid));
+				   batadv_print_vid(tt_common->vid));
 
 			batadv_tt_local_size_dec(bat_priv, tt_common->vid);
 			hlist_del_rcu(&tt_common->hash_entry);
@@ -4019,7 +4019,7 @@ bool batadv_tt_add_temporary_global_entry(struct batadv_priv *bat_priv,
 
 	batadv_dbg(BATADV_DBG_TT, bat_priv,
 		   "Added temporary global client (addr: %pM, vid: %d, orig: %pM)\n",
-		   addr, BATADV_PRINT_VID(vid), orig_node->orig);
+		   addr, batadv_print_vid(vid), orig_node->orig);
 	ret = true;
 out:
 	return ret;
-- 
2.11.0
