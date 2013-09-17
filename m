From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 3/7] netfilter: ipset: Skip really non-first fragments for IPv6 when getting port/protocol
Date: Wed, 18 Sep 2013 00:07:30 +0200
Message-ID: <1379455654-3905-4-git-send-email-pablo@netfilter.org>
References: <1379455654-3905-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1379455654-3905-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>

Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
---
 net/netfilter/ipset/ip_set_getport.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/ipset/ip_set_getport.c b/net/netfilter/ipset/ip_set_getport.c
index 6fdf88a..dac156f 100644
--- a/net/netfilter/ipset/ip_set_getport.c
+++ b/net/netfilter/ipset/ip_set_getport.c
@@ -116,12 +116,12 @@ ip_set_get_ip6_port(const struct sk_buff *skb, bool src,
 {
 	int protoff;
 	u8 nexthdr;
-	__be16 frag_off;
+	__be16 frag_off = 0;
 
 	nexthdr = ipv6_hdr(skb)->nexthdr;
 	protoff = ipv6_skip_exthdr(skb, sizeof(struct ipv6hdr), &nexthdr,
 				   &frag_off);
-	if (protoff < 0)
+	if (protoff < 0 || (frag_off & htons(~0x7)) != 0)
 		return false;
 
 	return get_port(skb, nexthdr, protoff, src, port, proto);
-- 
1.7.10.4

