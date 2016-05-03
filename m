From: Antonio Quartulli <a@unstable.cc>
Subject: [PATCH 04/15] batman-adv: use static string for table headers
Date: Wed,  4 May 2016 06:23:39 +0800
Message-ID: <1462314230-16257-5-git-send-email-a@unstable.cc>
References: <1462314230-16257-1-git-send-email-a@unstable.cc>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <a@unstable.cc>,
	Sven Eckelmann <sven@narfation.org>,
	Marek Lindner <mareklindner@neomailbox.ch>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s2.neomailbox.net ([5.148.176.60]:43372 "EHLO s2.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756773AbcECWYb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 May 2016 18:24:31 -0400
In-Reply-To: <1462314230-16257-1-git-send-email-a@unstable.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use a static string when showing table headers rather then
a nonsense parametric one with fixed arguments.

It is easier to grep and it does not need to be recomputed
at runtime each time.

Reported-by: Joe Perches <joe@perches.com>
Signed-off-by: Antonio Quartulli <a@unstable.cc>
[sven@narfation.org: fix conflicts with current version]
Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
---
 net/batman-adv/bat_iv_ogm.c            | 8 +++-----
 net/batman-adv/bat_v.c                 | 9 ++++-----
 net/batman-adv/bridge_loop_avoidance.c | 7 +++----
 net/batman-adv/distributed-arp-table.c | 4 ++--
 net/batman-adv/translation-table.c     | 9 ++++-----
 5 files changed, 16 insertions(+), 21 deletions(-)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index cb2d1b9b0340..682fcaec56e6 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -1829,9 +1829,8 @@ static void batadv_iv_ogm_orig_print(struct batadv_priv *bat_priv,
 	int batman_count = 0;
 	u32 i;
 
-	seq_printf(seq, "  %-15s %s (%s/%i) %17s [%10s]: %20s ...\n",
-		   "Originator", "last-seen", "#", BATADV_TQ_MAX_VALUE,
-		   "Nexthop", "outgoingIF", "Potential nexthops");
+	seq_puts(seq,
+		 "  Originator      last-seen (#/255)           Nexthop [outgoingIF]:   Potential nexthops ...\n");
 
 	for (i = 0; i < hash->size; i++) {
 		head = &hash->table[i];
@@ -1911,8 +1910,7 @@ static void batadv_iv_neigh_print(struct batadv_priv *bat_priv,
 	struct batadv_hard_iface *hard_iface;
 	int batman_count = 0;
 
-	seq_printf(seq, "   %10s        %-13s %s\n",
-		   "IF", "Neighbor", "last-seen");
+	seq_puts(seq, "           IF        Neighbor      last-seen\n");
 
 	rcu_read_lock();
 	list_for_each_entry_rcu(hard_iface, &batadv_hardif_list, list) {
diff --git a/net/batman-adv/bat_v.c b/net/batman-adv/bat_v.c
index 3315b9a598af..246f9e959849 100644
--- a/net/batman-adv/bat_v.c
+++ b/net/batman-adv/bat_v.c
@@ -151,8 +151,8 @@ static void batadv_v_neigh_print(struct batadv_priv *bat_priv,
 	struct batadv_hard_iface *hard_iface;
 	int batman_count = 0;
 
-	seq_printf(seq, "  %-15s %s (%11s) [%10s]\n", "Neighbor",
-		   "last-seen", "throughput", "IF");
+	seq_puts(seq,
+		 "  Neighbor        last-seen ( throughput) [        IF]\n");
 
 	rcu_read_lock();
 	list_for_each_entry_rcu(hard_iface, &batadv_hardif_list, list) {
@@ -191,9 +191,8 @@ static void batadv_v_orig_print(struct batadv_priv *bat_priv,
 	int batman_count = 0;
 	u32 i;
 
-	seq_printf(seq, "  %-15s %s (%11s) %17s [%10s]: %20s ...\n",
-		   "Originator", "last-seen", "throughput", "Nexthop",
-		   "outgoingIF", "Potential nexthops");
+	seq_puts(seq,
+		 "  Originator      last-seen ( throughput)           Nexthop [outgoingIF]:   Potential nexthops ...\n");
 
 	for (i = 0; i < hash->size; i++) {
 		head = &hash->table[i];
diff --git a/net/batman-adv/bridge_loop_avoidance.c b/net/batman-adv/bridge_loop_avoidance.c
index 0a6c8b824a00..56bc971e404b 100644
--- a/net/batman-adv/bridge_loop_avoidance.c
+++ b/net/batman-adv/bridge_loop_avoidance.c
@@ -1815,8 +1815,8 @@ int batadv_bla_claim_table_seq_print_text(struct seq_file *seq, void *offset)
 		   "Claims announced for the mesh %s (orig %pM, group id %#.4x)\n",
 		   net_dev->name, primary_addr,
 		   ntohs(bat_priv->bla.claim_dest.group));
-	seq_printf(seq, "   %-17s    %-5s    %-17s [o] (%-6s)\n",
-		   "Client", "VID", "Originator", "CRC");
+	seq_puts(seq,
+		 "   Client               VID      Originator        [o] (CRC   )\n");
 	for (i = 0; i < hash->size; i++) {
 		head = &hash->table[i];
 
@@ -1873,8 +1873,7 @@ int batadv_bla_backbone_table_seq_print_text(struct seq_file *seq, void *offset)
 		   "Backbones announced for the mesh %s (orig %pM, group id %#.4x)\n",
 		   net_dev->name, primary_addr,
 		   ntohs(bat_priv->bla.claim_dest.group));
-	seq_printf(seq, "   %-17s    %-5s %-9s (%-6s)\n",
-		   "Originator", "VID", "last seen", "CRC");
+	seq_puts(seq, "   Originator           VID   last seen (CRC   )\n");
 	for (i = 0; i < hash->size; i++) {
 		head = &hash->table[i];
 
diff --git a/net/batman-adv/distributed-arp-table.c b/net/batman-adv/distributed-arp-table.c
index e96d7c745b4a..ce574e9cef3b 100644
--- a/net/batman-adv/distributed-arp-table.c
+++ b/net/batman-adv/distributed-arp-table.c
@@ -814,8 +814,8 @@ int batadv_dat_cache_seq_print_text(struct seq_file *seq, void *offset)
 		goto out;
 
 	seq_printf(seq, "Distributed ARP Table (%s):\n", net_dev->name);
-	seq_printf(seq, "          %-7s          %-9s %4s %11s\n", "IPv4",
-		   "MAC", "VID", "last-seen");
+	seq_puts(seq,
+		 "          IPv4             MAC        VID   last-seen\n");
 
 	for (i = 0; i < hash->size; i++) {
 		head = &hash->table[i];
diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index 0b43e86328a5..29fd62839fac 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -1008,8 +1008,8 @@ int batadv_tt_local_seq_print_text(struct seq_file *seq, void *offset)
 	seq_printf(seq,
 		   "Locally retrieved addresses (from %s) announced via TT (TTVN: %u):\n",
 		   net_dev->name, (u8)atomic_read(&bat_priv->tt.vn));
-	seq_printf(seq, "       %-13s  %s %-8s %-9s (%-10s)\n", "Client", "VID",
-		   "Flags", "Last seen", "CRC");
+	seq_puts(seq,
+		 "       Client         VID Flags    Last seen (CRC       )\n");
 
 	for (i = 0; i < hash->size; i++) {
 		head = &hash->table[i];
@@ -1706,9 +1706,8 @@ int batadv_tt_global_seq_print_text(struct seq_file *seq, void *offset)
 	seq_printf(seq,
 		   "Globally announced TT entries received via the mesh %s\n",
 		   net_dev->name);
-	seq_printf(seq, "       %-13s  %s  %s       %-15s %s (%-10s) %s\n",
-		   "Client", "VID", "(TTVN)", "Originator", "(Curr TTVN)",
-		   "CRC", "Flags");
+	seq_puts(seq,
+		 "       Client         VID  (TTVN)       Originator      (Curr TTVN) (CRC       ) Flags\n");
 
 	for (i = 0; i < hash->size; i++) {
 		head = &hash->table[i];
-- 
2.8.2
