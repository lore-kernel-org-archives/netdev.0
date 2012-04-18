From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 12/13] batman-adv: print OGM seq numbers as unsigned int
Date: Wed, 18 Apr 2012 12:00:09 +0200
Message-ID: <1334743210-12338-13-git-send-email-ordex@autistici.org>
References: <1334743210-12338-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from investici.nine.ch ([217.150.252.179]:25057 "EHLO
	confino.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753048Ab2DRJ7m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Apr 2012 05:59:42 -0400
In-Reply-To: <1334743210-12338-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

OGM sequence numbers are declared as uint32_t and so they have to printed
using %u instead of %d in order to avoid wrong representations.

Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/bat_iv_ogm.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index d7fa8af..1014210 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -152,7 +152,7 @@ static void bat_iv_ogm_send_to_if(struct forw_packet *forw_packet,
 							    "Sending own" :
 							    "Forwarding"));
 		bat_dbg(DBG_BATMAN, bat_priv,
-			"%s %spacket (originator %pM, seqno %d, TQ %d, TTL %d, IDF %s, ttvn %d) on interface %s [%pM]\n",
+			"%s %spacket (originator %pM, seqno %u, TQ %d, TTL %d, IDF %s, ttvn %d) on interface %s [%pM]\n",
 			fwd_str, (packet_num > 0 ? "aggregated " : ""),
 			batman_ogm_packet->orig,
 			ntohl(batman_ogm_packet->seqno),
@@ -211,7 +211,7 @@ static void bat_iv_ogm_emit(struct forw_packet *forw_packet)
 
 		/* FIXME: what about aggregated packets ? */
 		bat_dbg(DBG_BATMAN, bat_priv,
-			"%s packet (originator %pM, seqno %d, TTL %d) on interface %s [%pM]\n",
+			"%s packet (originator %pM, seqno %u, TTL %d) on interface %s [%pM]\n",
 			(forw_packet->own ? "Sending own" : "Forwarding"),
 			batman_ogm_packet->orig,
 			ntohl(batman_ogm_packet->seqno),
@@ -892,7 +892,7 @@ static int bat_iv_ogm_update_seqnos(const struct ethhdr *ethhdr,
 
 	if (need_update) {
 		bat_dbg(DBG_BATMAN, bat_priv,
-			"updating last_seqno: old %d, new %d\n",
+			"updating last_seqno: old %u, new %u\n",
 			orig_node->last_real_seqno, batman_ogm_packet->seqno);
 		orig_node->last_real_seqno = batman_ogm_packet->seqno;
 	}
@@ -945,7 +945,7 @@ static void bat_iv_ogm_process(const struct ethhdr *ethhdr,
 					   batman_ogm_packet->orig) ? 1 : 0);
 
 	bat_dbg(DBG_BATMAN, bat_priv,
-		"Received BATMAN packet via NB: %pM, IF: %s [%pM] (from OG: %pM, via prev OG: %pM, seqno %d, ttvn %u, crc %u, changes %u, td %d, TTL %d, V %d, IDF %d)\n",
+		"Received BATMAN packet via NB: %pM, IF: %s [%pM] (from OG: %pM, via prev OG: %pM, seqno %u, ttvn %u, crc %u, changes %u, td %d, TTL %d, V %d, IDF %d)\n",
 		ethhdr->h_source, if_incoming->net_dev->name,
 		if_incoming->net_dev->dev_addr, batman_ogm_packet->orig,
 		batman_ogm_packet->prev_sender, batman_ogm_packet->seqno,
-- 
1.7.9.4
