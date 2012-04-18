From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 09/13] batman-adv: rename BATMAN_OGM_LEN to BATMAN_OGM_HLEN
Date: Wed, 18 Apr 2012 12:00:06 +0200
Message-ID: <1334743210-12338-10-git-send-email-ordex@autistici.org>
References: <1334743210-12338-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Marek Lindner <lindner_marek@yahoo.de>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from investici.nine.ch ([217.150.252.179]:24773 "EHLO
	confino.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752992Ab2DRJ7f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Apr 2012 05:59:35 -0400
In-Reply-To: <1334743210-12338-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marek Lindner <lindner_marek@yahoo.de>

Using BATMAN_OGM_LEN leaves one with the impression that this is
the full packet size which is not the case. Therefore the variable
is renamed.

Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/bat_iv_ogm.c |   12 ++++++------
 net/batman-adv/packet.h     |    2 +-
 net/batman-adv/routing.c    |    2 +-
 net/batman-adv/send.c       |   12 ++++++------
 4 files changed, 14 insertions(+), 14 deletions(-)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index c0bdb90..a2af289 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -40,7 +40,7 @@ static int bat_iv_ogm_iface_enable(struct hard_iface *hard_iface)
 	get_random_bytes(&random_seqno, sizeof(random_seqno));
 	atomic_set(&hard_iface->seqno, random_seqno);
 
-	hard_iface->packet_len = BATMAN_OGM_LEN;
+	hard_iface->packet_len = BATMAN_OGM_HLEN;
 	hard_iface->packet_buff = kmalloc(hard_iface->packet_len, GFP_ATOMIC);
 
 	if (!hard_iface->packet_buff)
@@ -112,7 +112,7 @@ static uint8_t hop_penalty(uint8_t tq, const struct bat_priv *bat_priv)
 static int bat_iv_ogm_aggr_packet(int buff_pos, int packet_len,
 				  int tt_num_changes)
 {
-	int next_buff_pos = buff_pos + BATMAN_OGM_LEN + tt_len(tt_num_changes);
+	int next_buff_pos = buff_pos + BATMAN_OGM_HLEN + tt_len(tt_num_changes);
 
 	return (next_buff_pos <= packet_len) &&
 		(next_buff_pos <= MAX_AGGREGATION_BYTES);
@@ -162,7 +162,7 @@ static void bat_iv_ogm_send_to_if(struct forw_packet *forw_packet,
 			batman_ogm_packet->ttvn, hard_iface->net_dev->name,
 			hard_iface->net_dev->dev_addr);
 
-		buff_pos += BATMAN_OGM_LEN +
+		buff_pos += BATMAN_OGM_HLEN +
 				tt_len(batman_ogm_packet->tt_num_changes);
 		packet_num++;
 		batman_ogm_packet = (struct batman_ogm_packet *)
@@ -540,7 +540,7 @@ static void bat_iv_ogm_forward(struct orig_node *orig_node,
 		batman_ogm_packet->flags &= ~DIRECTLINK;
 
 	bat_iv_ogm_queue_add(bat_priv, (unsigned char *)batman_ogm_packet,
-			     BATMAN_OGM_LEN + tt_len(tt_num_changes),
+			     BATMAN_OGM_HLEN + tt_len(tt_num_changes),
 			     if_incoming, 0, bat_iv_ogm_fwd_send_time());
 }
 
@@ -1173,12 +1173,12 @@ static void bat_iv_ogm_receive(struct hard_iface *if_incoming,
 		batman_ogm_packet->seqno = ntohl(batman_ogm_packet->seqno);
 		batman_ogm_packet->tt_crc = ntohs(batman_ogm_packet->tt_crc);
 
-		tt_buff = packet_buff + buff_pos + BATMAN_OGM_LEN;
+		tt_buff = packet_buff + buff_pos + BATMAN_OGM_HLEN;
 
 		bat_iv_ogm_process(ethhdr, batman_ogm_packet,
 				   tt_buff, if_incoming);
 
-		buff_pos += BATMAN_OGM_LEN +
+		buff_pos += BATMAN_OGM_HLEN +
 				tt_len(batman_ogm_packet->tt_num_changes);
 
 		batman_ogm_packet = (struct batman_ogm_packet *)
diff --git a/net/batman-adv/packet.h b/net/batman-adv/packet.h
index 59800e8..59dec0a 100644
--- a/net/batman-adv/packet.h
+++ b/net/batman-adv/packet.h
@@ -126,7 +126,7 @@ struct batman_ogm_packet {
 	uint16_t tt_crc;
 } __packed;
 
-#define BATMAN_OGM_LEN sizeof(struct batman_ogm_packet)
+#define BATMAN_OGM_HLEN sizeof(struct batman_ogm_packet)
 
 struct icmp_packet {
 	struct batman_header header;
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index 78eddc9..ac13a6a 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -254,7 +254,7 @@ int recv_bat_ogm_packet(struct sk_buff *skb, struct hard_iface *hard_iface)
 	struct ethhdr *ethhdr;
 
 	/* drop packet if it has not necessary minimum size */
-	if (unlikely(!pskb_may_pull(skb, BATMAN_OGM_LEN)))
+	if (unlikely(!pskb_may_pull(skb, BATMAN_OGM_HLEN)))
 		return NET_RX_DROP;
 
 	ethhdr = (struct ethhdr *)skb_mac_header(skb);
diff --git a/net/batman-adv/send.c b/net/batman-adv/send.c
index af7a674..b5f078c 100644
--- a/net/batman-adv/send.c
+++ b/net/batman-adv/send.c
@@ -87,7 +87,7 @@ static void realloc_packet_buffer(struct hard_iface *hard_iface,
 	/* keep old buffer if kmalloc should fail */
 	if (new_buff) {
 		memcpy(new_buff, hard_iface->packet_buff,
-		       BATMAN_OGM_LEN);
+		       BATMAN_OGM_HLEN);
 
 		kfree(hard_iface->packet_buff);
 		hard_iface->packet_buff = new_buff;
@@ -101,13 +101,13 @@ static int prepare_packet_buffer(struct bat_priv *bat_priv,
 {
 	int new_len;
 
-	new_len = BATMAN_OGM_LEN +
+	new_len = BATMAN_OGM_HLEN +
 		  tt_len((uint8_t)atomic_read(&bat_priv->tt_local_changes));
 
 	/* if we have too many changes for one packet don't send any
 	 * and wait for the tt table request which will be fragmented */
 	if (new_len > hard_iface->soft_iface->mtu)
-		new_len = BATMAN_OGM_LEN;
+		new_len = BATMAN_OGM_HLEN;
 
 	realloc_packet_buffer(hard_iface, new_len);
 
@@ -117,14 +117,14 @@ static int prepare_packet_buffer(struct bat_priv *bat_priv,
 	atomic_set(&bat_priv->tt_ogm_append_cnt, TT_OGM_APPEND_MAX);
 
 	return tt_changes_fill_buffer(bat_priv,
-				      hard_iface->packet_buff + BATMAN_OGM_LEN,
-				      hard_iface->packet_len - BATMAN_OGM_LEN);
+				      hard_iface->packet_buff + BATMAN_OGM_HLEN,
+				      hard_iface->packet_len - BATMAN_OGM_HLEN);
 }
 
 static int reset_packet_buffer(struct bat_priv *bat_priv,
 				struct hard_iface *hard_iface)
 {
-	realloc_packet_buffer(hard_iface, BATMAN_OGM_LEN);
+	realloc_packet_buffer(hard_iface, BATMAN_OGM_HLEN);
 	return 0;
 }
 
-- 
1.7.9.4
