From: David Miller <davem@davemloft.net>
Subject: [PATCH 15/25] netfilter: Use flowi4 in nf_nat_standalone.c
Date: Sat, 12 Mar 2011 15:28:41 -0800 (PST)
Message-ID: <20110312.152841.229750799.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55959
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756176Ab1CLX2D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Mar 2011 18:28:03 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 9F97124C088
	for <netdev@vger.kernel.org>; Sat, 12 Mar 2011 15:28:41 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/netfilter/nf_nat_standalone.c |    9 +++++----
 1 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/netfilter/nf_nat_standalone.c b/net/ipv4/netfilter/nf_nat_standalone.c
index 1f3c695..963320b 100644
--- a/net/ipv4/netfilter/nf_nat_standalone.c
+++ b/net/ipv4/netfilter/nf_nat_standalone.c
@@ -31,6 +31,7 @@
 #ifdef CONFIG_XFRM
 static void nat_decode_session(struct sk_buff *skb, struct flowi *fl)
 {
+	struct flowi4 *fl4 = &fl->u.ip4;
 	const struct nf_conn *ct;
 	const struct nf_conntrack_tuple *t;
 	enum ip_conntrack_info ctinfo;
@@ -49,25 +50,25 @@ static void nat_decode_session(struct sk_buff *skb, struct flowi *fl)
 		statusbit = IPS_SRC_NAT;
 
 	if (ct->status & statusbit) {
-		fl->fl4_dst = t->dst.u3.ip;
+		fl4->daddr = t->dst.u3.ip;
 		if (t->dst.protonum == IPPROTO_TCP ||
 		    t->dst.protonum == IPPROTO_UDP ||
 		    t->dst.protonum == IPPROTO_UDPLITE ||
 		    t->dst.protonum == IPPROTO_DCCP ||
 		    t->dst.protonum == IPPROTO_SCTP)
-			fl->fl4_dport = t->dst.u.tcp.port;
+			fl4->uli.ports.dport = t->dst.u.tcp.port;
 	}
 
 	statusbit ^= IPS_NAT_MASK;
 
 	if (ct->status & statusbit) {
-		fl->fl4_src = t->src.u3.ip;
+		fl4->saddr = t->src.u3.ip;
 		if (t->dst.protonum == IPPROTO_TCP ||
 		    t->dst.protonum == IPPROTO_UDP ||
 		    t->dst.protonum == IPPROTO_UDPLITE ||
 		    t->dst.protonum == IPPROTO_DCCP ||
 		    t->dst.protonum == IPPROTO_SCTP)
-			fl->fl4_sport = t->src.u.tcp.port;
+			fl4->uli.ports.sport = t->src.u.tcp.port;
 	}
 }
 #endif
-- 
1.7.4.1

