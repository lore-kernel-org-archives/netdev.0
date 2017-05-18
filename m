From: Eric Garver <e@erig.me>
Subject: [PATCH net-next] geneve: always fill CSUM6_RX configuration
Date: Thu, 18 May 2017 15:59:56 -0400
Message-ID: <20170518195956.12686-1-e@erig.me>
Cc: pravin shelar <pshelar@ovn.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47544 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753200AbdERT76 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 18 May 2017 15:59:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CSMU6_RX is relevant for collect_metadata as well. As such leave it
outside of the dev's IPv4/IPv6 checks.

Fixes: 9b4437a5b870 ("geneve: Unify LWT and netdev handling.")
Signed-off-by: Eric Garver <e@erig.me>
---
 drivers/net/geneve.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
index dec5d563ab19..f557d1dc3f9b 100644
--- a/drivers/net/geneve.c
+++ b/drivers/net/geneve.c
@@ -1311,13 +1311,13 @@ static int geneve_fill_info(struct sk_buff *skb, const struct net_device *dev)
 		if (nla_put_u8(skb, IFLA_GENEVE_UDP_ZERO_CSUM6_TX,
 			       !(info->key.tun_flags & TUNNEL_CSUM)))
 			goto nla_put_failure;
-
-		if (nla_put_u8(skb, IFLA_GENEVE_UDP_ZERO_CSUM6_RX,
-			       !geneve->use_udp6_rx_checksums))
-			goto nla_put_failure;
 #endif
 	}
 
+	if (nla_put_u8(skb, IFLA_GENEVE_UDP_ZERO_CSUM6_RX,
+		       !geneve->use_udp6_rx_checksums))
+		goto nla_put_failure;
+
 	if (nla_put_u8(skb, IFLA_GENEVE_TTL, info->key.ttl) ||
 	    nla_put_u8(skb, IFLA_GENEVE_TOS, info->key.tos) ||
 	    nla_put_be32(skb, IFLA_GENEVE_LABEL, info->key.label))
-- 
2.12.0
