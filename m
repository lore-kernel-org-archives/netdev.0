From: Simon Wunderlich <sw@simonwunderlich.de>
Subject: [PATCH 17/17] batman-adv: Reject unicast packet with zero/mcast dst address
Date: Wed,  9 Nov 2016 23:26:06 +0100
Message-ID: <20161109222606.29039-18-sw@simonwunderlich.de>
References: <20161109222606.29039-1-sw@simonwunderlich.de>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
        Sven Eckelmann <sven@narfation.org>,
        Simon Wunderlich <sw@simonwunderlich.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from packetmixer.de ([79.140.42.25]:55527 "EHLO
        mail.mail.packetmixer.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754142AbcKIW0h (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Nov 2016 17:26:37 -0500
In-Reply-To: <20161109222606.29039-1-sw@simonwunderlich.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

An unicast batman-adv packet cannot be transmitted to a multicast or zero
mac address. So reject incoming packets which still have these classes of
addresses as destination mac address in the outer ethernet header.

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Simon Wunderlich <sw@simonwunderlich.de>
---
 net/batman-adv/routing.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index 4f034df..6713bdf 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -364,8 +364,8 @@ int batadv_recv_icmp_packet(struct sk_buff *skb,
 
 	ethhdr = eth_hdr(skb);
 
-	/* packet with unicast indication but broadcast recipient */
-	if (is_broadcast_ether_addr(ethhdr->h_dest))
+	/* packet with unicast indication but non-unicast recipient */
+	if (!is_valid_ether_addr(ethhdr->h_dest))
 		goto free_skb;
 
 	/* packet with broadcast/multicast sender address */
@@ -462,8 +462,8 @@ static int batadv_check_unicast_packet(struct batadv_priv *bat_priv,
 
 	ethhdr = eth_hdr(skb);
 
-	/* packet with unicast indication but broadcast recipient */
-	if (is_broadcast_ether_addr(ethhdr->h_dest))
+	/* packet with unicast indication but non-unicast recipient */
+	if (!is_valid_ether_addr(ethhdr->h_dest))
 		return -EBADR;
 
 	/* packet with broadcast/multicast sender address */
-- 
2.10.1
