From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 02/14] batman-adv: introduce is_single_hop_neigh variable to increase readability
Date: Wed,  9 May 2012 13:12:44 +0200
Message-ID: <1336561976-16088-3-git-send-email-ordex@autistici.org>
References: <1336561976-16088-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Marek Lindner <lindner_marek@yahoo.de>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from investici.nine.ch ([217.150.252.179]:52734 "EHLO
	confino.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751531Ab2EILMf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 May 2012 07:12:35 -0400
In-Reply-To: <1336561976-16088-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marek Lindner <lindner_marek@yahoo.de>

Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
Acked-by: Simon Wunderlich <siwu@hrz.tu-chemnitz.de>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/bat_iv_ogm.c |   16 +++++++++-------
 1 file changed, 9 insertions(+), 7 deletions(-)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index 8b2db2e..cd8f473 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -480,7 +480,8 @@ static void bat_iv_ogm_queue_add(struct bat_priv *bat_priv,
 static void bat_iv_ogm_forward(struct orig_node *orig_node,
 			       const struct ethhdr *ethhdr,
 			       struct batman_ogm_packet *batman_ogm_packet,
-			       int directlink, struct hard_iface *if_incoming)
+			       bool is_single_hop_neigh,
+			       struct hard_iface *if_incoming)
 {
 	struct bat_priv *bat_priv = netdev_priv(if_incoming->soft_iface);
 	struct neigh_node *router;
@@ -533,7 +534,7 @@ static void bat_iv_ogm_forward(struct orig_node *orig_node,
 
 	/* switch of primaries first hop flag when forwarding */
 	batman_ogm_packet->flags &= ~PRIMARIES_FIRST_HOP;
-	if (directlink)
+	if (is_single_hop_neigh)
 		batman_ogm_packet->flags |= DIRECTLINK;
 	else
 		batman_ogm_packet->flags &= ~DIRECTLINK;
@@ -918,7 +919,8 @@ static void bat_iv_ogm_process(const struct ethhdr *ethhdr,
 	struct neigh_node *orig_neigh_router = NULL;
 	int has_directlink_flag;
 	int is_my_addr = 0, is_my_orig = 0, is_my_oldorig = 0;
-	int is_broadcast = 0, is_bidirectional, is_single_hop_neigh;
+	int is_broadcast = 0, is_bidirectional;
+	bool is_single_hop_neigh = false;
 	int is_duplicate;
 	uint32_t if_incoming_seqno;
 
@@ -942,8 +944,8 @@ static void bat_iv_ogm_process(const struct ethhdr *ethhdr,
 
 	has_directlink_flag = (batman_ogm_packet->flags & DIRECTLINK ? 1 : 0);
 
-	is_single_hop_neigh = (compare_eth(ethhdr->h_source,
-					   batman_ogm_packet->orig) ? 1 : 0);
+	if (compare_eth(ethhdr->h_source, batman_ogm_packet->orig))
+		is_single_hop_neigh = true;
 
 	bat_dbg(DBG_BATMAN, bat_priv,
 		"Received BATMAN packet via NB: %pM, IF: %s [%pM] (from OG: %pM, via prev OG: %pM, seqno %u, ttvn %u, crc %u, changes %u, td %d, TTL %d, V %d, IDF %d)\n",
@@ -1114,7 +1116,7 @@ static void bat_iv_ogm_process(const struct ethhdr *ethhdr,
 
 		/* mark direct link on incoming interface */
 		bat_iv_ogm_forward(orig_node, ethhdr, batman_ogm_packet,
-				   1, if_incoming);
+				   is_single_hop_neigh, if_incoming);
 
 		bat_dbg(DBG_BATMAN, bat_priv,
 			"Forwarding packet: rebroadcast neighbor packet with direct link flag\n");
@@ -1137,7 +1139,7 @@ static void bat_iv_ogm_process(const struct ethhdr *ethhdr,
 	bat_dbg(DBG_BATMAN, bat_priv,
 		"Forwarding packet: rebroadcast originator packet\n");
 	bat_iv_ogm_forward(orig_node, ethhdr, batman_ogm_packet,
-			   0, if_incoming);
+			   is_single_hop_neigh, if_incoming);
 
 out_neigh:
 	if ((orig_neigh_node) && (!is_single_hop_neigh))
-- 
1.7.9.4
