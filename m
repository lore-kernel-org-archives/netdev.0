From: kaber@trash.net
Subject: [PATCH 02/79] netfilter: xt_NFQUEUE: remove modulo operations
Date: Wed, 19 Jan 2011 20:14:02 +0100
Message-ID: <1295464519-21763-3-git-send-email-kaber@trash.net>
References: <1295464519-21763-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1295464519-21763-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Changli Gao <xiaosuo@gmail.com>

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/netfilter/xt_NFQUEUE.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/xt_NFQUEUE.c b/net/netfilter/xt_NFQUEUE.c
index 039cce1..3962770 100644
--- a/net/netfilter/xt_NFQUEUE.c
+++ b/net/netfilter/xt_NFQUEUE.c
@@ -72,10 +72,12 @@ nfqueue_tg_v1(struct sk_buff *skb, const struct xt_action_param *par)
 
 	if (info->queues_total > 1) {
 		if (par->family == NFPROTO_IPV4)
-			queue = hash_v4(skb) % info->queues_total + queue;
+			queue = (((u64) hash_v4(skb) * info->queues_total) >>
+				 32) + queue;
 #if defined(CONFIG_IP6_NF_IPTABLES) || defined(CONFIG_IP6_NF_IPTABLES_MODULE)
 		else if (par->family == NFPROTO_IPV6)
-			queue = hash_v6(skb) % info->queues_total + queue;
+			queue = (((u64) hash_v6(skb) * info->queues_total) >>
+				 32) + queue;
 #endif
 	}
 	return NF_QUEUE_NR(queue);
-- 
1.7.2.3

