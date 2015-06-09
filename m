From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 6/7] batman-adv: Remove unused post-VLAN ethhdr in batadv_gw_dhcp_recipient_get
Date: Tue,  9 Jun 2015 12:50:19 +0200
Message-ID: <1433847020-1427-7-git-send-email-antonio@meshcoding.com>
References: <1433847020-1427-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <antonio@meshcoding.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s1.neomailbox.net ([5.148.176.57]:49098 "EHLO s1.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932242AbbFIKwc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Jun 2015 06:52:32 -0400
In-Reply-To: <1433847020-1427-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
---
 net/batman-adv/gateway_client.c | 5 -----
 1 file changed, 5 deletions(-)

diff --git a/net/batman-adv/gateway_client.c b/net/batman-adv/gateway_client.c
index 14f0a22..bb015862 100644
--- a/net/batman-adv/gateway_client.c
+++ b/net/batman-adv/gateway_client.c
@@ -753,11 +753,6 @@ batadv_gw_dhcp_recipient_get(struct sk_buff *skb, unsigned int *header_len,
 	if (!pskb_may_pull(skb, *header_len + sizeof(*udphdr)))
 		return BATADV_DHCP_NO;
 
-	/* skb->data might have been reallocated by pskb_may_pull() */
-	ethhdr = eth_hdr(skb);
-	if (ntohs(ethhdr->h_proto) == ETH_P_8021Q)
-		ethhdr = (struct ethhdr *)(skb->data + VLAN_HLEN);
-
 	udphdr = (struct udphdr *)(skb->data + *header_len);
 	*header_len += sizeof(*udphdr);
 
-- 
2.4.2
