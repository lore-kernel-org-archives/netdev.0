From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 17/21] batman-adv: do not print orig nodes without nc neighbors on nc table print
Date: Wed, 29 May 2013 10:10:47 +0200
Message-ID: <1369815051-708-18-git-send-email-ordex@autistici.org>
References: <1369815051-708-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Marek Lindner <lindner_marek@yahoo.de>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from latitanza.investici.org ([82.94.249.234]:39927 "EHLO
	latitanza.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965027Ab3E2INJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 May 2013 04:13:09 -0400
In-Reply-To: <1369815051-708-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marek Lindner <lindner_marek@yahoo.de>

Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/network-coding.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/net/batman-adv/network-coding.c b/net/batman-adv/network-coding.c
index 0787a34..22cd51f 100644
--- a/net/batman-adv/network-coding.c
+++ b/net/batman-adv/network-coding.c
@@ -1763,6 +1763,13 @@ int batadv_nc_nodes_seq_print_text(struct seq_file *seq, void *offset)
 		/* For each orig_node in this bin */
 		rcu_read_lock();
 		hlist_for_each_entry_rcu(orig_node, head, hash_entry) {
+			/* no need to print the orig node if it does not have
+			 * network coding neighbors
+			 */
+			if (list_empty(&orig_node->in_coding_list) &&
+			    list_empty(&orig_node->out_coding_list))
+				continue;
+
 			seq_printf(seq, "Node:      %pM\n", orig_node->orig);
 
 			seq_puts(seq, " Ingoing:  ");
-- 
1.8.1.5
