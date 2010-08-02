From: kaber@trash.net
Subject: [PATCH 20/28] netfilter: iptables: use skb->len for accounting
Date: Mon,  2 Aug 2010 21:57:37 +0200
Message-ID: <1280779065-9333-21-git-send-email-kaber@trash.net>
References: <1280779065-9333-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1280779065-9333-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Changli Gao <xiaosuo@gmail.com>

Use skb->len for accounting as xt_quota does.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/ipv4/netfilter/ip_tables.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

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
-- 
1.7.1

