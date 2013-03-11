From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH] batman-adv: verify tt len does not exceed packet len
Date: Mon, 11 Mar 2013 23:12:28 +0100
Message-ID: <1363039948-27190-2-git-send-email-ordex@autistici.org>
References: <1363039948-27190-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Marek Lindner <lindner_marek@yahoo.de>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from diserzione.investici.org ([82.221.99.153]:41217 "EHLO
	diserzione.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754934Ab3CKWNu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Mar 2013 18:13:50 -0400
In-Reply-To: <1363039948-27190-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marek Lindner <lindner_marek@yahoo.de>

batadv_iv_ogm_process() accesses the packet using the tt_num_changes
attribute regardless of the real packet len (assuming the length check
was done before). Therefore a length check is needed to avoid reading
random memory.

Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/bat_iv_ogm.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index a0b253e..a5bb0a7 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -1288,7 +1288,8 @@ static int batadv_iv_ogm_receive(struct sk_buff *skb,
 	batadv_ogm_packet = (struct batadv_ogm_packet *)packet_buff;
 
 	/* unpack the aggregated packets and process them one by one */
-	do {
+	while (batadv_iv_ogm_aggr_packet(buff_pos, packet_len,
+					 batadv_ogm_packet->tt_num_changes)) {
 		tt_buff = packet_buff + buff_pos + BATADV_OGM_HLEN;
 
 		batadv_iv_ogm_process(ethhdr, batadv_ogm_packet, tt_buff,
@@ -1299,8 +1300,7 @@ static int batadv_iv_ogm_receive(struct sk_buff *skb,
 
 		packet_pos = packet_buff + buff_pos;
 		batadv_ogm_packet = (struct batadv_ogm_packet *)packet_pos;
-	} while (batadv_iv_ogm_aggr_packet(buff_pos, packet_len,
-					   batadv_ogm_packet->tt_num_changes));
+	}
 
 	kfree_skb(skb);
 	return NET_RX_SUCCESS;
-- 
1.8.1.5
