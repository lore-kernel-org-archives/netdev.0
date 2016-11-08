From: Simon Wunderlich <sw@simonwunderlich.de>
Subject: [PATCH 15/17] batman-adv: Disallow mcast src address for data frames
Date: Tue,  8 Nov 2016 17:45:24 +0100
Message-ID: <20161108164526.7518-16-sw@simonwunderlich.de>
References: <20161108164526.7518-1-sw@simonwunderlich.de>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
        Sven Eckelmann <sven@narfation.org>,
        Simon Wunderlich <sw@simonwunderlich.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from packetmixer.de ([79.140.42.25]:48896 "EHLO
        mail.mail.packetmixer.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753874AbcKHQqB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 8 Nov 2016 11:46:01 -0500
In-Reply-To: <20161108164526.7518-1-sw@simonwunderlich.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

The routing checks are validating the source mac address of the outer
ethernet header. They reject every source mac address which is a broadcast
address. But they also have to reject any multicast mac addresses.

Signed-off-by: Sven Eckelmann <sven@narfation.org>
[sw@simonwunderlich.de: fix commit message typo]
Signed-off-by: Simon Wunderlich <sw@simonwunderlich.de>
---
 net/batman-adv/routing.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index caf1866..9646623 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -368,8 +368,8 @@ int batadv_recv_icmp_packet(struct sk_buff *skb,
 	if (is_broadcast_ether_addr(ethhdr->h_dest))
 		goto free_skb;
 
-	/* packet with broadcast sender address */
-	if (is_broadcast_ether_addr(ethhdr->h_source))
+	/* packet with broadcast/multicast sender address */
+	if (is_multicast_ether_addr(ethhdr->h_source))
 		goto free_skb;
 
 	/* not for me */
@@ -466,8 +466,8 @@ static int batadv_check_unicast_packet(struct batadv_priv *bat_priv,
 	if (is_broadcast_ether_addr(ethhdr->h_dest))
 		return -EBADR;
 
-	/* packet with broadcast sender address */
-	if (is_broadcast_ether_addr(ethhdr->h_source))
+	/* packet with broadcast/multicast sender address */
+	if (is_multicast_ether_addr(ethhdr->h_source))
 		return -EBADR;
 
 	/* not for me */
@@ -1159,8 +1159,8 @@ int batadv_recv_bcast_packet(struct sk_buff *skb,
 	if (!is_broadcast_ether_addr(ethhdr->h_dest))
 		goto free_skb;
 
-	/* packet with broadcast sender address */
-	if (is_broadcast_ether_addr(ethhdr->h_source))
+	/* packet with broadcast/multicast sender address */
+	if (is_multicast_ether_addr(ethhdr->h_source))
 		goto free_skb;
 
 	/* ignore broadcasts sent by myself */
-- 
2.10.1
