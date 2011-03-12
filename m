From: David Miller <davem@davemloft.net>
Subject: [PATCH 18/25] netfilter: Use flowi4 and flowi6 in xt_TCPMSS
Date: Sat, 12 Mar 2011 15:29:26 -0800 (PST)
Message-ID: <20110312.152926.242132190.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55968
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755582Ab1CLX2s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Mar 2011 18:28:48 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id A526324C088
	for <netdev@vger.kernel.org>; Sat, 12 Mar 2011 15:29:26 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/netfilter/xt_TCPMSS.c |   15 ++++++++++-----
 1 files changed, 10 insertions(+), 5 deletions(-)

diff --git a/net/netfilter/xt_TCPMSS.c b/net/netfilter/xt_TCPMSS.c
index eb81c38..6e6b46c 100644
--- a/net/netfilter/xt_TCPMSS.c
+++ b/net/netfilter/xt_TCPMSS.c
@@ -148,16 +148,21 @@ tcpmss_mangle_packet(struct sk_buff *skb,
 static u_int32_t tcpmss_reverse_mtu(const struct sk_buff *skb,
 				    unsigned int family)
 {
-	struct flowi fl = {};
+	struct flowi fl;
 	const struct nf_afinfo *ai;
 	struct rtable *rt = NULL;
 	u_int32_t mtu     = ~0U;
 
-	if (family == PF_INET)
-		fl.fl4_dst = ip_hdr(skb)->saddr;
-	else
-		fl.fl6_dst = ipv6_hdr(skb)->saddr;
+	if (family == PF_INET) {
+		struct flowi4 *fl4 = &fl.u.ip4;
+		memset(fl4, 0, sizeof(*fl4));
+		fl4->daddr = ip_hdr(skb)->saddr;
+	} else {
+		struct flowi6 *fl6 = &fl.u.ip6;
 
+		memset(fl6, 0, sizeof(*fl6));
+		ipv6_addr_copy(&fl6->daddr, &ipv6_hdr(skb)->saddr);
+	}
 	rcu_read_lock();
 	ai = nf_get_afinfo(family);
 	if (ai != NULL)
-- 
1.7.4.1

