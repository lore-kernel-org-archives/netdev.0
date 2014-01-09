From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 10/13] batman-adv: print the new BATADV_TT_CLIENT_ISOLA flag
Date: Thu,  9 Jan 2014 15:52:59 +0100
Message-ID: <1389279182-3256-11-git-send-email-antonio@meshcoding.com>
References: <1389279182-3256-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <antonio@open-mesh.com>,
	Marek Lindner <mareklindner@neomailbox.ch>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:39029 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752580AbaAIO4u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jan 2014 09:56:50 -0500
In-Reply-To: <1389279182-3256-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <antonio@open-mesh.com>

Print the new BATADV_TT_CLIENT_ISOLA flag properly in the
Local and Global Translation Table output.

The character 'I' is used in the flags column to indicate
that the entry is marked as isolated.

Signed-off-by: Antonio Quartulli <antonio@open-mesh.com>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
---
 net/batman-adv/translation-table.c | 12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index 669b8b6..eeceb13 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -887,7 +887,7 @@ int batadv_tt_local_seq_print_text(struct seq_file *seq, void *offset)
 	seq_printf(seq,
 		   "Locally retrieved addresses (from %s) announced via TT (TTVN: %u):\n",
 		   net_dev->name, (uint8_t)atomic_read(&bat_priv->tt.vn));
-	seq_printf(seq, "       %-13s  %s %-7s %-9s (%-10s)\n", "Client", "VID",
+	seq_printf(seq, "       %-13s  %s %-8s %-9s (%-10s)\n", "Client", "VID",
 		   "Flags", "Last seen", "CRC");
 
 	for (i = 0; i < hash->size; i++) {
@@ -915,7 +915,7 @@ int batadv_tt_local_seq_print_text(struct seq_file *seq, void *offset)
 			}
 
 			seq_printf(seq,
-				   " * %pM %4i [%c%c%c%c%c] %3u.%03u   (%#.8x)\n",
+				   " * %pM %4i [%c%c%c%c%c%c] %3u.%03u   (%#.8x)\n",
 				   tt_common_entry->addr,
 				   BATADV_PRINT_VID(tt_common_entry->vid),
 				   (tt_common_entry->flags &
@@ -927,6 +927,8 @@ int batadv_tt_local_seq_print_text(struct seq_file *seq, void *offset)
 				    BATADV_TT_CLIENT_PENDING ? 'X' : '.'),
 				   (tt_common_entry->flags &
 				    BATADV_TT_CLIENT_WIFI ? 'W' : '.'),
+				   (tt_common_entry->flags &
+				    BATADV_TT_CLIENT_ISOLA ? 'I' : '.'),
 				   no_purge ? 0 : last_seen_secs,
 				   no_purge ? 0 : last_seen_msecs,
 				   vlan->tt.crc);
@@ -1459,13 +1461,14 @@ batadv_tt_global_print_entry(struct batadv_priv *bat_priv,
 
 		last_ttvn = atomic_read(&best_entry->orig_node->last_ttvn);
 		seq_printf(seq,
-			   " %c %pM %4i   (%3u) via %pM     (%3u)   (%#.8x) [%c%c%c]\n",
+			   " %c %pM %4i   (%3u) via %pM     (%3u)   (%#.8x) [%c%c%c%c]\n",
 			   '*', tt_global_entry->common.addr,
 			   BATADV_PRINT_VID(tt_global_entry->common.vid),
 			   best_entry->ttvn, best_entry->orig_node->orig,
 			   last_ttvn, vlan->tt.crc,
 			   (flags & BATADV_TT_CLIENT_ROAM ? 'R' : '.'),
 			   (flags & BATADV_TT_CLIENT_WIFI ? 'W' : '.'),
+			   (flags & BATADV_TT_CLIENT_ISOLA ? 'I' : '.'),
 			   (flags & BATADV_TT_CLIENT_TEMP ? 'T' : '.'));
 
 		batadv_orig_node_vlan_free_ref(vlan);
@@ -1490,13 +1493,14 @@ print_list:
 
 		last_ttvn = atomic_read(&orig_entry->orig_node->last_ttvn);
 		seq_printf(seq,
-			   " %c %pM %4d   (%3u) via %pM     (%3u)   (%#.8x) [%c%c%c]\n",
+			   " %c %pM %4d   (%3u) via %pM     (%3u)   (%#.8x) [%c%c%c%c]\n",
 			   '+', tt_global_entry->common.addr,
 			   BATADV_PRINT_VID(tt_global_entry->common.vid),
 			   orig_entry->ttvn, orig_entry->orig_node->orig,
 			   last_ttvn, vlan->tt.crc,
 			   (flags & BATADV_TT_CLIENT_ROAM ? 'R' : '.'),
 			   (flags & BATADV_TT_CLIENT_WIFI ? 'W' : '.'),
+			   (flags & BATADV_TT_CLIENT_ISOLA ? 'I' : '.'),
 			   (flags & BATADV_TT_CLIENT_TEMP ? 'T' : '.'));
 
 		batadv_orig_node_vlan_free_ref(vlan);
-- 
1.8.5.2
