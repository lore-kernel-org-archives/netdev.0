From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 11/11] batman-adv: use seq_puts instead of seq_printf when the format is constant
Date: Thu, 28 Mar 2013 08:50:31 +0100
Message-ID: <1364457031-3194-12-git-send-email-ordex@autistici.org>
References: <1364457031-3194-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <ordex@autistici.org>,
	Marek Lindner <lindner_marek@yahoo.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from diserzione.investici.org ([82.221.99.153]:33493 "EHLO
	diserzione.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756685Ab3C1HwQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Mar 2013 03:52:16 -0400
In-Reply-To: <1364457031-3194-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As reported by checkpatch, seq_puts has to be preferred with
respect to seq_printf when the format is a constant string
(no va_args)

Signed-off-by: Antonio Quartulli <ordex@autistici.org>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
---
 net/batman-adv/gateway_client.c | 2 +-
 net/batman-adv/main.c           | 2 +-
 net/batman-adv/network-coding.c | 8 ++++----
 net/batman-adv/originator.c     | 4 ++--
 net/batman-adv/vis.c            | 4 ++--
 5 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/net/batman-adv/gateway_client.c b/net/batman-adv/gateway_client.c
index 34f99a4..f105219 100644
--- a/net/batman-adv/gateway_client.c
+++ b/net/batman-adv/gateway_client.c
@@ -500,7 +500,7 @@ int batadv_gw_client_seq_print_text(struct seq_file *seq, void *offset)
 	rcu_read_unlock();
 
 	if (gw_count == 0)
-		seq_printf(seq, "No gateways in range ...\n");
+		seq_puts(seq, "No gateways in range ...\n");
 
 out:
 	if (primary_if)
diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index 62b1f89..6277735 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -419,7 +419,7 @@ int batadv_algo_seq_print_text(struct seq_file *seq, void *offset)
 {
 	struct batadv_algo_ops *bat_algo_ops;
 
-	seq_printf(seq, "Available routing algorithms:\n");
+	seq_puts(seq, "Available routing algorithms:\n");
 
 	hlist_for_each_entry(bat_algo_ops, &batadv_algo_list, list) {
 		seq_printf(seq, "%s\n", bat_algo_ops->name);
diff --git a/net/batman-adv/network-coding.c b/net/batman-adv/network-coding.c
index 086c107..6b9a544 100644
--- a/net/batman-adv/network-coding.c
+++ b/net/batman-adv/network-coding.c
@@ -1760,23 +1760,23 @@ int batadv_nc_nodes_seq_print_text(struct seq_file *seq, void *offset)
 		hlist_for_each_entry_rcu(orig_node, head, hash_entry) {
 			seq_printf(seq, "Node:      %pM\n", orig_node->orig);
 
-			seq_printf(seq, " Ingoing:  ");
+			seq_puts(seq, " Ingoing:  ");
 			/* For each in_nc_node to this orig_node */
 			list_for_each_entry_rcu(nc_node,
 						&orig_node->in_coding_list,
 						list)
 				seq_printf(seq, "%pM ",
 					   nc_node->addr);
-			seq_printf(seq, "\n");
+			seq_puts(seq, "\n");
 
-			seq_printf(seq, " Outgoing: ");
+			seq_puts(seq, " Outgoing: ");
 			/* For out_nc_node to this orig_node */
 			list_for_each_entry_rcu(nc_node,
 						&orig_node->out_coding_list,
 						list)
 				seq_printf(seq, "%pM ",
 					   nc_node->addr);
-			seq_printf(seq, "\n\n");
+			seq_puts(seq, "\n\n");
 		}
 		rcu_read_unlock();
 	}
diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
index 585e684..2f34525 100644
--- a/net/batman-adv/originator.c
+++ b/net/batman-adv/originator.c
@@ -465,7 +465,7 @@ int batadv_orig_seq_print_text(struct seq_file *seq, void *offset)
 					   neigh_node_tmp->tq_avg);
 			}
 
-			seq_printf(seq, "\n");
+			seq_puts(seq, "\n");
 			batman_count++;
 
 next:
@@ -475,7 +475,7 @@ next:
 	}
 
 	if (batman_count == 0)
-		seq_printf(seq, "No batman nodes in range ...\n");
+		seq_puts(seq, "No batman nodes in range ...\n");
 
 out:
 	if (primary_if)
diff --git a/net/batman-adv/vis.c b/net/batman-adv/vis.c
index c053244..962ccf3 100644
--- a/net/batman-adv/vis.c
+++ b/net/batman-adv/vis.c
@@ -149,7 +149,7 @@ static void batadv_vis_data_read_prim_sec(struct seq_file *seq,
 
 	hlist_for_each_entry(entry, if_list, list) {
 		if (entry->primary)
-			seq_printf(seq, "PRIMARY, ");
+			seq_puts(seq, "PRIMARY, ");
 		else
 			seq_printf(seq,  "SEC %pM, ", entry->addr);
 	}
@@ -207,7 +207,7 @@ static void batadv_vis_data_read_entries(struct seq_file *seq,
 		if (batadv_compare_eth(entry->addr, packet->vis_orig))
 			batadv_vis_data_read_prim_sec(seq, list);
 
-		seq_printf(seq, "\n");
+		seq_puts(seq, "\n");
 	}
 }
 
-- 
1.8.1.5
