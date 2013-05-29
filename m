From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 06/21] batman-adv: don't check the source address twice
Date: Wed, 29 May 2013 10:10:36 +0200
Message-ID: <1369815051-708-7-git-send-email-ordex@autistici.org>
References: <1369815051-708-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <antonio@open-mesh.com>,
	Marek Lindner <lindner_marek@yahoo.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from latitanza.investici.org ([82.94.249.234]:39890 "EHLO
	latitanza.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965032Ab3E2IM5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 May 2013 04:12:57 -0400
In-Reply-To: <1369815051-708-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <antonio@open-mesh.com>

The source address has already been checked in
batadv_check_management_packet() upon packet reception and
therefore it does not need to be checked again in
ogm_process()

Signed-off-by: Antonio Quartulli <antonio@open-mesh.com>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
---
 net/batman-adv/bat_iv_ogm.c | 12 +-----------
 1 file changed, 1 insertion(+), 11 deletions(-)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index da239c5..6d62e29 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -988,7 +988,7 @@ static void batadv_iv_ogm_process(const struct ethhdr *ethhdr,
 	struct batadv_neigh_node *orig_neigh_router = NULL;
 	int has_directlink_flag;
 	int is_my_addr = 0, is_my_orig = 0, is_my_oldorig = 0;
-	int is_broadcast = 0, is_bidirect;
+	int is_bidirect;
 	bool is_single_hop_neigh = false;
 	bool is_from_best_next_hop = false;
 	int is_duplicate, sameseq, simlar_ttl;
@@ -1051,9 +1051,6 @@ static void batadv_iv_ogm_process(const struct ethhdr *ethhdr,
 		if (batadv_compare_eth(batadv_ogm_packet->prev_sender,
 				       hard_iface->net_dev->dev_addr))
 			is_my_oldorig = 1;
-
-		if (is_broadcast_ether_addr(ethhdr->h_source))
-			is_broadcast = 1;
 	}
 	rcu_read_unlock();
 
@@ -1071,13 +1068,6 @@ static void batadv_iv_ogm_process(const struct ethhdr *ethhdr,
 		return;
 	}
 
-	if (is_broadcast) {
-		batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
-			   "Drop packet: ignoring all packets with broadcast source addr (sender: %pM)\n",
-			   ethhdr->h_source);
-		return;
-	}
-
 	if (is_my_orig) {
 		unsigned long *word;
 		int offset;
-- 
1.8.1.5
