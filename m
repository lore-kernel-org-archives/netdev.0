From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH] iptables: use skb->len for accounting
Date: Fri, 23 Jul 2010 11:34:48 +0800
Message-ID: <1279856088-9004-1-git-send-email-xiaosuo@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

iptables: use skb->len for accounting

use skb->len for accounting as xt_quota does.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
----
 net/ipv4/netfilter/ip_tables.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)
diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index b38c118..3c584a6 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -364,7 +364,7 @@ ipt_do_table(struct sk_buff *skb,
 				goto no_match;
 		}
 
-		ADD_COUNTER(e->counters, ntohs(ip->tot_len), 1);
+		ADD_COUNTER(e->counters, skb->len, 1);
 
 		t = ipt_get_target(e);
 		IP_NF_ASSERT(t->u.kernel.target);
