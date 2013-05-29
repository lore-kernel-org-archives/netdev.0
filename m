From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 19/21] batman-adv: print the VID properly
Date: Wed, 29 May 2013 10:12:30 +0200
Message-ID: <1369815152-2750-2-git-send-email-ordex@autistici.org>
References: <1369815051-708-1-git-send-email-ordex@autistici.org>
 <1369815152-2750-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <antonio@open-mesh.com>,
	Marek Lindner <lindner_marek@yahoo.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from diserzione.investici.org ([82.221.99.153]:50553 "EHLO
	diserzione.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965078Ab3E2IOa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 May 2013 04:14:30 -0400
In-Reply-To: <1369815152-2750-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <antonio@open-mesh.com>

Since the MSB bits of any vid variable are now used for
storing flags, print the vid properly by taking the flags
away and printing -1 in case of VID representing no real
VLAN.

Signed-off-by: Antonio Quartulli <antonio@open-mesh.com>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
---
 net/batman-adv/bridge_loop_avoidance.c | 37 +++++++++++++++++++---------------
 1 file changed, 21 insertions(+), 16 deletions(-)

diff --git a/net/batman-adv/bridge_loop_avoidance.c b/net/batman-adv/bridge_loop_avoidance.c
index 7354063..e9d8e0b 100644
--- a/net/batman-adv/bridge_loop_avoidance.c
+++ b/net/batman-adv/bridge_loop_avoidance.c
@@ -307,7 +307,8 @@ static void batadv_bla_send_claim(struct batadv_priv *bat_priv, uint8_t *mac,
 		 */
 		memcpy(ethhdr->h_source, mac, ETH_ALEN);
 		batadv_dbg(BATADV_DBG_BLA, bat_priv,
-			   "bla_send_claim(): CLAIM %pM on vid %d\n", mac, vid);
+			   "bla_send_claim(): CLAIM %pM on vid %d\n", mac,
+			   BATADV_PRINT_VID(vid));
 		break;
 	case BATADV_CLAIM_TYPE_UNCLAIM:
 		/* unclaim frame
@@ -316,7 +317,7 @@ static void batadv_bla_send_claim(struct batadv_priv *bat_priv, uint8_t *mac,
 		memcpy(hw_src, mac, ETH_ALEN);
 		batadv_dbg(BATADV_DBG_BLA, bat_priv,
 			   "bla_send_claim(): UNCLAIM %pM on vid %d\n", mac,
-			   vid);
+			   BATADV_PRINT_VID(vid));
 		break;
 	case BATADV_CLAIM_TYPE_ANNOUNCE:
 		/* announcement frame
@@ -325,7 +326,7 @@ static void batadv_bla_send_claim(struct batadv_priv *bat_priv, uint8_t *mac,
 		memcpy(hw_src, mac, ETH_ALEN);
 		batadv_dbg(BATADV_DBG_BLA, bat_priv,
 			   "bla_send_claim(): ANNOUNCE of %pM on vid %d\n",
-			   ethhdr->h_source, vid);
+			   ethhdr->h_source, BATADV_PRINT_VID(vid));
 		break;
 	case BATADV_CLAIM_TYPE_REQUEST:
 		/* request frame
@@ -336,7 +337,8 @@ static void batadv_bla_send_claim(struct batadv_priv *bat_priv, uint8_t *mac,
 		memcpy(ethhdr->h_dest, mac, ETH_ALEN);
 		batadv_dbg(BATADV_DBG_BLA, bat_priv,
 			   "bla_send_claim(): REQUEST of %pM to %pM on vid %d\n",
-			   ethhdr->h_source, ethhdr->h_dest, vid);
+			   ethhdr->h_source, ethhdr->h_dest,
+			   BATADV_PRINT_VID(vid));
 		break;
 	}
 
@@ -381,7 +383,7 @@ batadv_bla_get_backbone_gw(struct batadv_priv *bat_priv, uint8_t *orig,
 
 	batadv_dbg(BATADV_DBG_BLA, bat_priv,
 		   "bla_get_backbone_gw(): not found (%pM, %d), creating new entry\n",
-		   orig, vid);
+		   orig, BATADV_PRINT_VID(vid));
 
 	entry = kzalloc(sizeof(*entry), GFP_ATOMIC);
 	if (!entry)
@@ -573,7 +575,7 @@ static void batadv_bla_add_claim(struct batadv_priv *bat_priv,
 		atomic_set(&claim->refcount, 2);
 		batadv_dbg(BATADV_DBG_BLA, bat_priv,
 			   "bla_add_claim(): adding new entry %pM, vid %d to hash ...\n",
-			   mac, vid);
+			   mac, BATADV_PRINT_VID(vid));
 		hash_added = batadv_hash_add(bat_priv->bla.claim_hash,
 					     batadv_compare_claim,
 					     batadv_choose_claim, claim,
@@ -592,7 +594,7 @@ static void batadv_bla_add_claim(struct batadv_priv *bat_priv,
 
 		batadv_dbg(BATADV_DBG_BLA, bat_priv,
 			   "bla_add_claim(): changing ownership for %pM, vid %d\n",
-			   mac, vid);
+			   mac, BATADV_PRINT_VID(vid));
 
 		claim->backbone_gw->crc ^= crc16(0, claim->addr, ETH_ALEN);
 		batadv_backbone_gw_free_ref(claim->backbone_gw);
@@ -623,7 +625,7 @@ static void batadv_bla_del_claim(struct batadv_priv *bat_priv,
 		return;
 
 	batadv_dbg(BATADV_DBG_BLA, bat_priv, "bla_del_claim(): %pM, vid %d\n",
-		   mac, vid);
+		   mac, BATADV_PRINT_VID(vid));
 
 	batadv_hash_remove(bat_priv->bla.claim_hash, batadv_compare_claim,
 			   batadv_choose_claim, claim);
@@ -659,12 +661,13 @@ static int batadv_handle_announce(struct batadv_priv *bat_priv,
 
 	batadv_dbg(BATADV_DBG_BLA, bat_priv,
 		   "handle_announce(): ANNOUNCE vid %d (sent by %pM)... CRC = %#.4x\n",
-		   vid, backbone_gw->orig, crc);
+		   BATADV_PRINT_VID(vid), backbone_gw->orig, crc);
 
 	if (backbone_gw->crc != crc) {
 		batadv_dbg(BATADV_DBG_BLA, backbone_gw->bat_priv,
 			   "handle_announce(): CRC FAILED for %pM/%d (my = %#.4x, sent = %#.4x)\n",
-			   backbone_gw->orig, backbone_gw->vid,
+			   backbone_gw->orig,
+			   BATADV_PRINT_VID(backbone_gw->vid),
 			   backbone_gw->crc, crc);
 
 		batadv_bla_send_request(backbone_gw);
@@ -700,7 +703,7 @@ static int batadv_handle_request(struct batadv_priv *bat_priv,
 
 	batadv_dbg(BATADV_DBG_BLA, bat_priv,
 		   "handle_request(): REQUEST vid %d (sent by %pM)...\n",
-		   vid, ethhdr->h_source);
+		   BATADV_PRINT_VID(vid), ethhdr->h_source);
 
 	batadv_bla_answer_request(bat_priv, primary_if, vid);
 	return 1;
@@ -728,7 +731,7 @@ static int batadv_handle_unclaim(struct batadv_priv *bat_priv,
 	/* this must be an UNCLAIM frame */
 	batadv_dbg(BATADV_DBG_BLA, bat_priv,
 		   "handle_unclaim(): UNCLAIM %pM on vid %d (sent by %pM)...\n",
-		   claim_addr, vid, backbone_gw->orig);
+		   claim_addr, BATADV_PRINT_VID(vid), backbone_gw->orig);
 
 	batadv_bla_del_claim(bat_priv, claim_addr, vid);
 	batadv_backbone_gw_free_ref(backbone_gw);
@@ -912,7 +915,8 @@ static int batadv_bla_process_claim(struct batadv_priv *bat_priv,
 	if (ret == 1)
 		batadv_dbg(BATADV_DBG_BLA, bat_priv,
 			   "bla_process_claim(): received a claim frame from another group. From: %pM on vid %d ...(hw_src %pM, hw_dst %pM)\n",
-			   ethhdr->h_source, vid, hw_src, hw_dst);
+			   ethhdr->h_source, BATADV_PRINT_VID(vid), hw_src,
+			   hw_dst);
 
 	if (ret < 2)
 		return ret;
@@ -947,7 +951,7 @@ static int batadv_bla_process_claim(struct batadv_priv *bat_priv,
 
 	batadv_dbg(BATADV_DBG_BLA, bat_priv,
 		   "bla_process_claim(): ERROR - this looks like a claim frame, but is useless. eth src %pM on vid %d ...(hw_src %pM, hw_dst %pM)\n",
-		   ethhdr->h_source, vid, hw_src, hw_dst);
+		   ethhdr->h_source, BATADV_PRINT_VID(vid), hw_src, hw_dst);
 	return 1;
 }
 
@@ -1628,7 +1632,7 @@ int batadv_bla_claim_table_seq_print_text(struct seq_file *seq, void *offset)
 			is_own = batadv_compare_eth(claim->backbone_gw->orig,
 						    primary_addr);
 			seq_printf(seq, " * %pM on %5d by %pM [%c] (%#.4x)\n",
-				   claim->addr, claim->vid,
+				   claim->addr, BATADV_PRINT_VID(claim->vid),
 				   claim->backbone_gw->orig,
 				   (is_own ? 'x' : ' '),
 				   claim->backbone_gw->crc);
@@ -1681,7 +1685,8 @@ int batadv_bla_backbone_table_seq_print_text(struct seq_file *seq, void *offset)
 				continue;
 
 			seq_printf(seq, " * %pM on %5d %4i.%03is (%#.4x)\n",
-				   backbone_gw->orig, backbone_gw->vid, secs,
+				   backbone_gw->orig,
+				   BATADV_PRINT_VID(backbone_gw->vid), secs,
 				   msecs, backbone_gw->crc);
 		}
 		rcu_read_unlock();
-- 
1.8.1.5
