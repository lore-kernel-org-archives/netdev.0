From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 06/15] batman-adv: unify and properly print hex values
Date: Mon, 14 Jan 2013 09:41:11 +1000
Message-ID: <1358120480-25960-7-git-send-email-ordex@autistici.org>
References: <1358120480-25960-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <ordex@autistici.org>,
	Marek Lindner <lindner_marek@yahoo.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from diserzione.investici.org ([82.221.99.153]:49610 "EHLO
	diserzione.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755648Ab3AMXmu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Jan 2013 18:42:50 -0500
In-Reply-To: <1358120480-25960-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Values are printed in hexadecimal format in several points in the
code, but they are not printed using the same format string.

This patches unifies the format used for such numbers so that they
look the same everywhere.

Given the fact that all the variables printed as hexadecimal are 16
bit long, this is the chosen printing format: %#.4x

Signed-off-by: Antonio Quartulli <ordex@autistici.org>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
---
 net/batman-adv/bat_iv_ogm.c            |  2 +-
 net/batman-adv/bridge_loop_avoidance.c | 18 +++++++++---------
 net/batman-adv/translation-table.c     |  2 +-
 3 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index 7d02ebd..f2a3649 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -1033,7 +1033,7 @@ static void batadv_iv_ogm_process(const struct ethhdr *ethhdr,
 		is_single_hop_neigh = true;
 
 	batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
-		   "Received BATMAN packet via NB: %pM, IF: %s [%pM] (from OG: %pM, via prev OG: %pM, seqno %u, ttvn %u, crc %u, changes %u, td %d, TTL %d, V %d, IDF %d)\n",
+		   "Received BATMAN packet via NB: %pM, IF: %s [%pM] (from OG: %pM, via prev OG: %pM, seqno %u, ttvn %u, crc %#.4x, changes %u, td %d, TTL %d, V %d, IDF %d)\n",
 		   ethhdr->h_source, if_incoming->net_dev->name,
 		   if_incoming->net_dev->dev_addr, batadv_ogm_packet->orig,
 		   batadv_ogm_packet->prev_sender,
diff --git a/net/batman-adv/bridge_loop_avoidance.c b/net/batman-adv/bridge_loop_avoidance.c
index 5aebe93..ec12c79 100644
--- a/net/batman-adv/bridge_loop_avoidance.c
+++ b/net/batman-adv/bridge_loop_avoidance.c
@@ -661,12 +661,12 @@ static int batadv_handle_announce(struct batadv_priv *bat_priv,
 	crc = ntohs(*((__be16 *)(&an_addr[4])));
 
 	batadv_dbg(BATADV_DBG_BLA, bat_priv,
-		   "handle_announce(): ANNOUNCE vid %d (sent by %pM)... CRC = %04x\n",
+		   "handle_announce(): ANNOUNCE vid %d (sent by %pM)... CRC = %#.4x\n",
 		   vid, backbone_gw->orig, crc);
 
 	if (backbone_gw->crc != crc) {
 		batadv_dbg(BATADV_DBG_BLA, backbone_gw->bat_priv,
-			   "handle_announce(): CRC FAILED for %pM/%d (my = %04x, sent = %04x)\n",
+			   "handle_announce(): CRC FAILED for %pM/%d (my = %#.4x, sent = %#.4x)\n",
 			   backbone_gw->orig, backbone_gw->vid,
 			   backbone_gw->crc, crc);
 
@@ -835,7 +835,7 @@ static int batadv_check_claim_group(struct batadv_priv *bat_priv,
 	/* if our mesh friends mac is bigger, use it for ourselves. */
 	if (ntohs(bla_dst->group) > ntohs(bla_dst_own->group)) {
 		batadv_dbg(BATADV_DBG_BLA, bat_priv,
-			   "taking other backbones claim group: %04x\n",
+			   "taking other backbones claim group: %#.4x\n",
 			   ntohs(bla_dst->group));
 		bla_dst_own->group = bla_dst->group;
 	}
@@ -1626,10 +1626,10 @@ int batadv_bla_claim_table_seq_print_text(struct seq_file *seq, void *offset)
 
 	primary_addr = primary_if->net_dev->dev_addr;
 	seq_printf(seq,
-		   "Claims announced for the mesh %s (orig %pM, group id %04x)\n",
+		   "Claims announced for the mesh %s (orig %pM, group id %#.4x)\n",
 		   net_dev->name, primary_addr,
 		   ntohs(bat_priv->bla.claim_dest.group));
-	seq_printf(seq, "   %-17s    %-5s    %-17s [o] (%-4s)\n",
+	seq_printf(seq, "   %-17s    %-5s    %-17s [o] (%-6s)\n",
 		   "Client", "VID", "Originator", "CRC");
 	for (i = 0; i < hash->size; i++) {
 		head = &hash->table[i];
@@ -1638,7 +1638,7 @@ int batadv_bla_claim_table_seq_print_text(struct seq_file *seq, void *offset)
 		hlist_for_each_entry_rcu(claim, node, head, hash_entry) {
 			is_own = batadv_compare_eth(claim->backbone_gw->orig,
 						    primary_addr);
-			seq_printf(seq,	" * %pM on % 5d by %pM [%c] (%04x)\n",
+			seq_printf(seq,	" * %pM on % 5d by %pM [%c] (%#.4x)\n",
 				   claim->addr, claim->vid,
 				   claim->backbone_gw->orig,
 				   (is_own ? 'x' : ' '),
@@ -1672,10 +1672,10 @@ int batadv_bla_backbone_table_seq_print_text(struct seq_file *seq, void *offset)
 
 	primary_addr = primary_if->net_dev->dev_addr;
 	seq_printf(seq,
-		   "Backbones announced for the mesh %s (orig %pM, group id %04x)\n",
+		   "Backbones announced for the mesh %s (orig %pM, group id %#.4x)\n",
 		   net_dev->name, primary_addr,
 		   ntohs(bat_priv->bla.claim_dest.group));
-	seq_printf(seq, "   %-17s    %-5s %-9s (%-4s)\n",
+	seq_printf(seq, "   %-17s    %-5s %-9s (%-6s)\n",
 		   "Originator", "VID", "last seen", "CRC");
 	for (i = 0; i < hash->size; i++) {
 		head = &hash->table[i];
@@ -1693,7 +1693,7 @@ int batadv_bla_backbone_table_seq_print_text(struct seq_file *seq, void *offset)
 				continue;
 
 			seq_printf(seq,
-				   " * %pM on % 5d % 4i.%03is (%04x)\n",
+				   " * %pM on % 5d % 4i.%03is (%#.4x)\n",
 				   backbone_gw->orig, backbone_gw->vid,
 				   secs, msecs, backbone_gw->crc);
 		}
diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index 408807e..40ef955 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -2518,7 +2518,7 @@ void batadv_tt_update_orig(struct batadv_priv *bat_priv,
 		    orig_node->tt_crc != tt_crc) {
 request_table:
 			batadv_dbg(BATADV_DBG_TT, bat_priv,
-				   "TT inconsistency for %pM. Need to retrieve the correct information (ttvn: %u last_ttvn: %u crc: %u last_crc: %u num_changes: %u)\n",
+				   "TT inconsistency for %pM. Need to retrieve the correct information (ttvn: %u last_ttvn: %u crc: %#.4x last_crc: %#.4x num_changes: %u)\n",
 				   orig_node->orig, ttvn, orig_ttvn, tt_crc,
 				   orig_node->tt_crc, tt_num_changes);
 			batadv_send_tt_request(bat_priv, orig_node, ttvn,
-- 
1.8.0.2
