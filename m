From: kaber@trash.net
Subject: [PATCH 76/79] netfilter: ipt_CLUSTERIP: remove "no conntrack!"
Date: Wed, 19 Jan 2011 20:15:16 +0100
Message-ID: <1295464519-21763-77-git-send-email-kaber@trash.net>
References: <1295464519-21763-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1295464519-21763-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>

When a packet is meant to be handled by another node of the cluster,
silently drop it instead of flooding kernel log.

Note : INVALID packets are also dropped without notice.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Acked-by: Pablo Neira Ayuso <pablo@netfilter.org>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/ipv4/netfilter/ipt_CLUSTERIP.c |    7 +------
 1 files changed, 1 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/netfilter/ipt_CLUSTERIP.c b/net/ipv4/netfilter/ipt_CLUSTERIP.c
index 1e26a48..403ca57 100644
--- a/net/ipv4/netfilter/ipt_CLUSTERIP.c
+++ b/net/ipv4/netfilter/ipt_CLUSTERIP.c
@@ -300,13 +300,8 @@ clusterip_tg(struct sk_buff *skb, const struct xt_action_param *par)
 	 * that the ->target() function isn't called after ->destroy() */
 
 	ct = nf_ct_get(skb, &ctinfo);
-	if (ct == NULL) {
-		pr_info("no conntrack!\n");
-			/* FIXME: need to drop invalid ones, since replies
-			 * to outgoing connections of other nodes will be
-			 * marked as INVALID */
+	if (ct == NULL)
 		return NF_DROP;
-	}
 
 	/* special case: ICMP error handling. conntrack distinguishes between
 	 * error messages (RELATED) and information requests (see below) */
-- 
1.7.2.3

