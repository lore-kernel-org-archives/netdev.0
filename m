From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 11/14] batman-adv: add build checks for packet sizes
Date: Mon, 13 Jan 2014 23:31:35 +0100
Message-ID: <1389652298-472-12-git-send-email-antonio@meshcoding.com>
References: <1389652298-472-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Simon Wunderlich <sw@simonwunderlich.de>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <antonio@meshcoding.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:39555 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751388AbaAMWxo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jan 2014 17:53:44 -0500
In-Reply-To: <1389652298-472-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Wunderlich <sw@simonwunderlich.de>

With unrolling the batadv_header into the respective structures, the
offsetof checks are now useless. Instead, add build checks for all
packet types which go over the wire to avoid problems with wrong sizes
or compatibility issues on some architectures which don't use every day.

Signed-off-by: Simon Wunderlich <sw@simonwunderlich.de>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
---
 net/batman-adv/main.c | 24 +++++++++++++++++-------
 1 file changed, 17 insertions(+), 7 deletions(-)

diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index 945e441..ad6aeed 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -419,13 +419,23 @@ static void batadv_recv_handler_init(void)
 	for (i = BATADV_UNICAST_MIN; i <= BATADV_UNICAST_MAX; i++)
 		batadv_rx_handler[i] = batadv_recv_unhandled_unicast_packet;
 
-	/* compile time checks for struct member offsets */
-	BUILD_BUG_ON(offsetof(struct batadv_unicast_4addr_packet, src) != 10);
-	BUILD_BUG_ON(offsetof(struct batadv_unicast_packet, dest) != 4);
-	BUILD_BUG_ON(offsetof(struct batadv_unicast_tvlv_packet, dst) != 4);
-	BUILD_BUG_ON(offsetof(struct batadv_frag_packet, dest) != 4);
-	BUILD_BUG_ON(offsetof(struct batadv_icmp_packet, dst) != 4);
-	BUILD_BUG_ON(offsetof(struct batadv_icmp_packet_rr, dst) != 4);
+	/* compile time checks for sizes */
+	BUILD_BUG_ON(sizeof(struct batadv_bla_claim_dst) != 6);
+	BUILD_BUG_ON(sizeof(struct batadv_ogm_packet) != 24);
+	BUILD_BUG_ON(sizeof(struct batadv_icmp_header) != 20);
+	BUILD_BUG_ON(sizeof(struct batadv_icmp_packet) != 20);
+	BUILD_BUG_ON(sizeof(struct batadv_icmp_packet_rr) != 116);
+	BUILD_BUG_ON(sizeof(struct batadv_unicast_packet) != 10);
+	BUILD_BUG_ON(sizeof(struct batadv_unicast_4addr_packet) != 18);
+	BUILD_BUG_ON(sizeof(struct batadv_frag_packet) != 20);
+	BUILD_BUG_ON(sizeof(struct batadv_bcast_packet) != 14);
+	BUILD_BUG_ON(sizeof(struct batadv_coded_packet) != 46);
+	BUILD_BUG_ON(sizeof(struct batadv_unicast_tvlv_packet) != 20);
+	BUILD_BUG_ON(sizeof(struct batadv_tvlv_hdr) != 4);
+	BUILD_BUG_ON(sizeof(struct batadv_tvlv_gateway_data) != 8);
+	BUILD_BUG_ON(sizeof(struct batadv_tvlv_tt_vlan_data) != 8);
+	BUILD_BUG_ON(sizeof(struct batadv_tvlv_tt_change) != 12);
+	BUILD_BUG_ON(sizeof(struct batadv_tvlv_roam_adv) != 8);
 
 	/* broadcast packet */
 	batadv_rx_handler[BATADV_BCAST] = batadv_recv_bcast_packet;
-- 
1.8.5.2
