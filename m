From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 10/19] batman-adv: trivial endianness annotations
Date: Mon, 18 Jun 2012 22:39:14 +0200
Message-ID: <1340051963-14836-11-git-send-email-ordex@autistici.org>
References: <1340051963-14836-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Al Viro <viro@ZenIV.linux.org.uk>,
	Al Viro <viro@zeniv.linux.org.uk>,
	Sven Eckelmann <sven@narfation.org>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from latitanza.investici.org ([82.94.249.234]:41512 "EHLO
	latitanza.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753362Ab2FRUjM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jun 2012 16:39:12 -0400
In-Reply-To: <1340051963-14836-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Al Viro <viro@ZenIV.linux.org.uk>

Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/bridge_loop_avoidance.c |    6 +++---
 net/batman-adv/packet.h                |   12 ++++++------
 2 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/net/batman-adv/bridge_loop_avoidance.c b/net/batman-adv/bridge_loop_avoidance.c
index 89e2b1c..0355c48 100644
--- a/net/batman-adv/bridge_loop_avoidance.c
+++ b/net/batman-adv/bridge_loop_avoidance.c
@@ -258,7 +258,7 @@ static void bla_send_claim(struct bat_priv *bat_priv, uint8_t *mac,
 	struct net_device *soft_iface;
 	uint8_t *hw_src;
 	struct bla_claim_dst local_claim_dest;
-	uint32_t zeroip = 0;
+	__be32 zeroip = 0;
 
 	primary_if = primary_if_get_selected(bat_priv);
 	if (!primary_if)
@@ -506,7 +506,7 @@ static void bla_send_announce(struct bat_priv *bat_priv,
 			      struct backbone_gw *backbone_gw)
 {
 	uint8_t mac[ETH_ALEN];
-	uint16_t crc;
+	__be16 crc;
 
 	memcpy(mac, announce_mac, 4);
 	crc = htons(backbone_gw->crc);
@@ -627,7 +627,7 @@ static int handle_announce(struct bat_priv *bat_priv,
 
 	/* handle as ANNOUNCE frame */
 	backbone_gw->lasttime = jiffies;
-	crc = ntohs(*((uint16_t *)(&an_addr[4])));
+	crc = ntohs(*((__be16 *)(&an_addr[4])));
 
 	bat_dbg(DBG_BLA, bat_priv,
 		"handle_announce(): ANNOUNCE vid %d (sent by %pM)... CRC = %04x\n",
diff --git a/net/batman-adv/packet.h b/net/batman-adv/packet.h
index 0ee1af7..eaa6028 100644
--- a/net/batman-adv/packet.h
+++ b/net/batman-adv/packet.h
@@ -105,7 +105,7 @@ enum bla_claimframe {
 struct bla_claim_dst {
 	uint8_t magic[3];	/* FF:43:05 */
 	uint8_t type;		/* bla_claimframe */
-	uint16_t group;		/* group id */
+	__be16 group;		/* group id */
 } __packed;
 
 struct batman_header {
@@ -134,7 +134,7 @@ struct icmp_packet {
 	uint8_t  msg_type; /* see ICMP message types above */
 	uint8_t  dst[ETH_ALEN];
 	uint8_t  orig[ETH_ALEN];
-	uint16_t seqno;
+	__be16   seqno;
 	uint8_t  uid;
 	uint8_t  reserved;
 } __packed;
@@ -148,7 +148,7 @@ struct icmp_packet_rr {
 	uint8_t  msg_type; /* see ICMP message types above */
 	uint8_t  dst[ETH_ALEN];
 	uint8_t  orig[ETH_ALEN];
-	uint16_t seqno;
+	__be16   seqno;
 	uint8_t  uid;
 	uint8_t  rr_cur;
 	uint8_t  rr[BAT_RR_LEN][ETH_ALEN];
@@ -167,20 +167,20 @@ struct unicast_frag_packet {
 	uint8_t  flags;
 	uint8_t  align;
 	uint8_t  orig[ETH_ALEN];
-	uint16_t seqno;
+	__be16   seqno;
 } __packed;
 
 struct bcast_packet {
 	struct batman_header header;
 	uint8_t  reserved;
-	uint32_t seqno;
+	__be32   seqno;
 	uint8_t  orig[ETH_ALEN];
 } __packed;
 
 struct vis_packet {
 	struct batman_header header;
 	uint8_t  vis_type;	 /* which type of vis-participant sent this? */
-	uint32_t seqno;		 /* sequence number */
+	__be32   seqno;		 /* sequence number */
 	uint8_t  entries;	 /* number of entries behind this struct */
 	uint8_t  reserved;
 	uint8_t  vis_orig[ETH_ALEN];	/* originator reporting its neighbors */
-- 
1.7.9.4
