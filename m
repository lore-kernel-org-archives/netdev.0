From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: [PATCH 2/4] batman: don't bother flipping ->tt_crc
Date: Wed, 18 Apr 2012 19:10:58 +0100
Message-ID: <20120418181058.GD6589@ZenIV.linux.org.uk>
References: <1334743210-12338-1-git-send-email-ordex@autistici.org>
 <20120418180837.GB6589@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	b.a.t.m.a.n@lists.open-mesh.org
To: Antonio Quartulli <ordex@autistici.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:39565 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753097Ab2DRSK7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Apr 2012 14:10:59 -0400
Content-Disposition: inline
In-Reply-To: <20120418180837.GB6589@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Again, keep ->tt_crc in batman_ogv_packet net-endian

Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
---
 net/batman-adv/bat_iv_ogm.c |    6 ++----
 net/batman-adv/packet.h     |    2 +-
 2 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index ab2085c..5aa8861 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -544,7 +544,6 @@ static void bat_iv_ogm_forward(struct orig_node *orig_node,
 		batman_ogm_packet->tq, batman_ogm_packet->header.ttl);
 
 	batman_ogm_packet->seqno = htonl(batman_ogm_packet->seqno);
-	batman_ogm_packet->tt_crc = htons(batman_ogm_packet->tt_crc);
 
 	/* switch of primaries first hop flag when forwarding */
 	batman_ogm_packet->flags &= ~PRIMARIES_FIRST_HOP;
@@ -722,7 +721,7 @@ update_tt:
 		tt_update_orig(bat_priv, orig_node, tt_buff,
 			       batman_ogm_packet->tt_num_changes,
 			       batman_ogm_packet->ttvn,
-			       batman_ogm_packet->tt_crc);
+			       ntohs(batman_ogm_packet->tt_crc));
 
 	if (orig_node->gw_flags != batman_ogm_packet->gw_flags)
 		gw_node_update(bat_priv, orig_node,
@@ -969,7 +968,7 @@ static void bat_iv_ogm_process(const struct ethhdr *ethhdr,
 		ethhdr->h_source, if_incoming->net_dev->name,
 		if_incoming->net_dev->dev_addr, batman_ogm_packet->orig,
 		batman_ogm_packet->prev_sender, batman_ogm_packet->seqno,
-		batman_ogm_packet->ttvn, batman_ogm_packet->tt_crc,
+		batman_ogm_packet->ttvn, ntohs(batman_ogm_packet->tt_crc),
 		batman_ogm_packet->tt_num_changes, batman_ogm_packet->tq,
 		batman_ogm_packet->header.ttl,
 		batman_ogm_packet->header.version, has_directlink_flag);
@@ -1214,7 +1213,6 @@ static int bat_iv_ogm_receive(struct sk_buff *skb,
 		/* network to host order for our 32bit seqno and the
 		   orig_interval */
 		batman_ogm_packet->seqno = ntohl(batman_ogm_packet->seqno);
-		batman_ogm_packet->tt_crc = ntohs(batman_ogm_packet->tt_crc);
 
 		tt_buff = packet_buff + buff_pos + BATMAN_OGM_HLEN;
 
diff --git a/net/batman-adv/packet.h b/net/batman-adv/packet.h
index 9157f7c..61a7fe0 100644
--- a/net/batman-adv/packet.h
+++ b/net/batman-adv/packet.h
@@ -132,7 +132,7 @@ struct batman_ogm_packet {
 	uint8_t  tq;
 	uint8_t  tt_num_changes;
 	uint8_t  ttvn; /* translation table version number */
-	uint16_t tt_crc;
+	__be16   tt_crc;
 } __packed;
 
 #define BATMAN_OGM_HLEN sizeof(struct batman_ogm_packet)
-- 
1.7.2.5
