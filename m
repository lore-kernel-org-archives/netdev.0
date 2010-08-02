From: kaber@trash.net
Subject: [PATCH 19/28] netfilter: ip6tables: use skb->len for accounting
Date: Mon,  2 Aug 2010 21:57:36 +0200
Message-ID: <1280779065-9333-20-git-send-email-kaber@trash.net>
References: <1280779065-9333-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1280779065-9333-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Changli Gao <xiaosuo@gmail.com>

ipv6_hdr(skb)->payload_len is ZERO and can't be used for accounting, if
the payload is a Jumbo Payload specified in RFC2675.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/ipv6/netfilter/ip6_tables.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index dc41d6d..33113c1 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -387,9 +387,7 @@ ip6t_do_table(struct sk_buff *skb,
 				goto no_match;
 		}
 
-		ADD_COUNTER(e->counters,
-			    ntohs(ipv6_hdr(skb)->payload_len) +
-			    sizeof(struct ipv6hdr), 1);
+		ADD_COUNTER(e->counters, skb->len, 1);
 
 		t = ip6t_get_target_c(e);
 		IP_NF_ASSERT(t->u.kernel.target);
-- 
1.7.1

