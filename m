From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 02/12] batman-adv: Mark correctly aligned headers not as __packed
Date: Wed,  7 Nov 2012 20:11:32 +0100
Message-ID: <1352315502-20324-3-git-send-email-ordex@autistici.org>
References: <1352315502-20324-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Marek Lindner <lindner_marek@yahoo.de>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from contumacia.investici.org ([178.255.144.35]:44613 "EHLO
	contumacia.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754187Ab2KGTMc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Nov 2012 14:12:32 -0500
In-Reply-To: <1352315502-20324-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

Headers which are already perfectly aligned and create a 4 byte boundary
non-ethernet header payload can have the __packed attribute removed. The
__packed attribute doesn't change the appeareance of the packet for these
headers because no extra padding is necessary to align the data members. The
compiler will also create slightly faster code for loads of multi-byte members.

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/packet.h | 21 +++++++++++++++------
 1 file changed, 15 insertions(+), 6 deletions(-)

diff --git a/net/batman-adv/packet.h b/net/batman-adv/packet.h
index 2d23a14..b5f67a2 100644
--- a/net/batman-adv/packet.h
+++ b/net/batman-adv/packet.h
@@ -106,13 +106,16 @@ struct batadv_bla_claim_dst {
 	uint8_t magic[3];	/* FF:43:05 */
 	uint8_t type;		/* bla_claimframe */
 	__be16 group;		/* group id */
-} __packed;
+};
 
 struct batadv_header {
 	uint8_t  packet_type;
 	uint8_t  version;  /* batman version field */
 	uint8_t  ttl;
-} __packed;
+	/* the parent struct has to add a byte after the header to make
+	 * everything 4 bytes aligned again
+	 */
+};
 
 struct batadv_ogm_packet {
 	struct batadv_header header;
@@ -137,7 +140,7 @@ struct batadv_icmp_packet {
 	__be16   seqno;
 	uint8_t  uid;
 	uint8_t  reserved;
-} __packed;
+};
 
 #define BATADV_RR_LEN 16
 
@@ -153,13 +156,16 @@ struct batadv_icmp_packet_rr {
 	uint8_t  uid;
 	uint8_t  rr_cur;
 	uint8_t  rr[BATADV_RR_LEN][ETH_ALEN];
-} __packed;
+};
 
 struct batadv_unicast_packet {
 	struct batadv_header header;
 	uint8_t  ttvn; /* destination translation table version number */
 	uint8_t  dest[ETH_ALEN];
-} __packed;
+	/* "4 bytes boundary + 2 bytes" long to make the payload after the
+	 * following ethernet header again 4 bytes boundary aligned
+	 */
+};
 
 struct batadv_unicast_frag_packet {
 	struct batadv_header header;
@@ -176,6 +182,9 @@ struct batadv_bcast_packet {
 	uint8_t  reserved;
 	__be32   seqno;
 	uint8_t  orig[ETH_ALEN];
+	/* "4 bytes boundary + 2 bytes" long to make the payload after the
+	 * following ethernet header again 4 bytes boundary aligned
+	 */
 } __packed;
 
 struct batadv_vis_packet {
@@ -187,7 +196,7 @@ struct batadv_vis_packet {
 	uint8_t  vis_orig[ETH_ALEN];	/* originator reporting its neighbors */
 	uint8_t  target_orig[ETH_ALEN]; /* who should receive this packet */
 	uint8_t  sender_orig[ETH_ALEN]; /* who sent or forwarded this packet */
-} __packed;
+};
 
 struct batadv_tt_query_packet {
 	struct batadv_header header;
-- 
1.8.0
