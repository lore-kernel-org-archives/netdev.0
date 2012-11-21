From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 2/9] batman-adv: fix bla compare function
Date: Wed, 21 Nov 2012 13:11:52 +0100
Message-ID: <1353499919-28596-3-git-send-email-ordex@autistici.org>
References: <1353499919-28596-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Simon Wunderlich <simon.wunderlich@s2003.tu-chemnitz.de>,
	Simon Wunderlich <siwu@hrz.tu-chemnitz.de>,
	Marek Lindner <lindner_marek@yahoo.de>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from contumacia.investici.org ([178.255.144.35]:50467 "EHLO
	contumacia.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752847Ab2KUMM4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Nov 2012 07:12:56 -0500
In-Reply-To: <1353499919-28596-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Wunderlich <simon.wunderlich@s2003.tu-chemnitz.de>

The address and the VLAN VID may not be packed in the respective
structs. Fix this by comparing the elements individually.

Reported-by: Marek Lindner <lindner_marek@yahoo.de>
Reported-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Simon Wunderlich <siwu@hrz.tu-chemnitz.de>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/bridge_loop_avoidance.c | 18 ++++++++++++++++--
 1 file changed, 16 insertions(+), 2 deletions(-)

diff --git a/net/batman-adv/bridge_loop_avoidance.c b/net/batman-adv/bridge_loop_avoidance.c
index bda8b17..7ffef8b 100644
--- a/net/batman-adv/bridge_loop_avoidance.c
+++ b/net/batman-adv/bridge_loop_avoidance.c
@@ -77,8 +77,15 @@ static int batadv_compare_backbone_gw(const struct hlist_node *node,
 {
 	const void *data1 = container_of(node, struct batadv_backbone_gw,
 					 hash_entry);
+	const struct batadv_backbone_gw *gw1 = data1, *gw2 = data2;
 
-	return (memcmp(data1, data2, ETH_ALEN + sizeof(short)) == 0 ? 1 : 0);
+	if (!batadv_compare_eth(gw1->orig, gw2->orig))
+		return 0;
+
+	if (gw1->vid != gw2->vid)
+		return 0;
+
+	return 1;
 }
 
 /* compares address and vid of two claims */
@@ -87,8 +94,15 @@ static int batadv_compare_claim(const struct hlist_node *node,
 {
 	const void *data1 = container_of(node, struct batadv_claim,
 					 hash_entry);
+	const struct batadv_claim *cl1 = data1, *cl2 = data2;
 
-	return (memcmp(data1, data2, ETH_ALEN + sizeof(short)) == 0 ? 1 : 0);
+	if (!batadv_compare_eth(cl1->addr, cl2->addr))
+		return 0;
+
+	if (cl1->vid != cl2->vid)
+		return 0;
+
+	return 1;
 }
 
 /* free a backbone gw */
-- 
1.8.0
