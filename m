From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH 7/8] netfilter: xt_hashlimit: use proto_ports_offset() to support AH message
Date: Wed, 18 Aug 2010 13:06:39 +0800
Message-ID: <1282107999-3663-1-git-send-email-xiaosuo@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
---
 net/netfilter/xt_hashlimit.c |   15 +++++----------
 1 file changed, 5 insertions(+), 10 deletions(-)
diff --git a/net/netfilter/xt_hashlimit.c b/net/netfilter/xt_hashlimit.c
index b46a839..9228ee0 100644
--- a/net/netfilter/xt_hashlimit.c
+++ b/net/netfilter/xt_hashlimit.c
@@ -448,6 +448,7 @@ hashlimit_init_dst(const struct xt_hashlimit_htable *hinfo,
 {
 	__be16 _ports[2], *ports;
 	u8 nexthdr;
+	int poff;
 
 	memset(dst, 0, sizeof(*dst));
 
@@ -492,19 +493,13 @@ hashlimit_init_dst(const struct xt_hashlimit_htable *hinfo,
 		return 0;
 	}
 
-	switch (nexthdr) {
-	case IPPROTO_TCP:
-	case IPPROTO_UDP:
-	case IPPROTO_UDPLITE:
-	case IPPROTO_SCTP:
-	case IPPROTO_DCCP:
-		ports = skb_header_pointer(skb, protoff, sizeof(_ports),
+	poff = proto_ports_offset(nexthdr);
+	if (poff >= 0) {
+		ports = skb_header_pointer(skb, protoff + poff, sizeof(_ports),
 					   &_ports);
-		break;
-	default:
+	} else {
 		_ports[0] = _ports[1] = 0;
 		ports = _ports;
-		break;
 	}
 	if (!ports)
 		return -1;
