From: Simon Wunderlich <sw@simonwunderlich.de>
Subject: [PATCH 4/6] batman-adv: Remove variable deprecated by skb_put_data
Date: Wed,  2 Aug 2017 16:23:20 +0200
Message-ID: <20170802142322.13376-5-sw@simonwunderlich.de>
References: <20170802142322.13376-1-sw@simonwunderlich.de>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
        Sven Eckelmann <sven@narfation.org>,
        Simon Wunderlich <sw@simonwunderlich.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from packetmixer.de ([79.140.42.25]:46890 "EHLO
        mail.mail.packetmixer.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752350AbdHBOXg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Aug 2017 10:23:36 -0400
In-Reply-To: <20170802142322.13376-1-sw@simonwunderlich.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

skb_put_data makes it unnecessary to store the skb_put return value to copy
some data to the packet. The returned pointer of skb_put_data should
therefore not stored by functions which previously only used it to copy
some data.

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Simon Wunderlich <sw@simonwunderlich.de>
---
 net/batman-adv/bat_iv_ogm.c | 4 +---
 net/batman-adv/bat_v_ogm.c  | 4 ++--
 2 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index c27001d38574..83ba5483455a 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -729,11 +729,9 @@ static void batadv_iv_ogm_aggregate(struct batadv_forw_packet *forw_packet_aggr,
 				    const unsigned char *packet_buff,
 				    int packet_len, bool direct_link)
 {
-	unsigned char *skb_buff;
 	unsigned long new_direct_link_flag;
 
-	skb_buff = skb_put_data(forw_packet_aggr->skb, packet_buff,
-				packet_len);
+	skb_put_data(forw_packet_aggr->skb, packet_buff, packet_len);
 	forw_packet_aggr->packet_len += packet_len;
 	forw_packet_aggr->num_packets++;
 
diff --git a/net/batman-adv/bat_v_ogm.c b/net/batman-adv/bat_v_ogm.c
index 1e3dc374bfde..894c96371e41 100644
--- a/net/batman-adv/bat_v_ogm.c
+++ b/net/batman-adv/bat_v_ogm.c
@@ -137,7 +137,7 @@ static void batadv_v_ogm_send(struct work_struct *work)
 	struct batadv_priv *bat_priv;
 	struct batadv_ogm2_packet *ogm_packet;
 	struct sk_buff *skb, *skb_tmp;
-	unsigned char *ogm_buff, *pkt_buff;
+	unsigned char *ogm_buff;
 	int ogm_buff_len;
 	u16 tvlv_len = 0;
 	int ret;
@@ -166,7 +166,7 @@ static void batadv_v_ogm_send(struct work_struct *work)
 		goto reschedule;
 
 	skb_reserve(skb, ETH_HLEN);
-	pkt_buff = skb_put_data(skb, ogm_buff, ogm_buff_len);
+	skb_put_data(skb, ogm_buff, ogm_buff_len);
 
 	ogm_packet = (struct batadv_ogm2_packet *)skb->data;
 	ogm_packet->seqno = htonl(atomic_read(&bat_priv->bat_v.ogm_seqno));
-- 
2.11.0
