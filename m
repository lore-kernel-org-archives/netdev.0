From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 30/33] netfilter: nfnetlink_queue: use proper net namespace to allocate skb
Date: Fri,  4 Oct 2013 10:33:15 +0200
Message-ID: <1380875598-5250-31-git-send-email-pablo@netfilter.org>
References: <1380875598-5250-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1380875598-5250-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Gao feng <gaofeng@cn.fujitsu.com>

Use proper net struct to allocate skb, otherwise netlink mmap
will have no effect.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nfnetlink_queue_core.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/netfilter/nfnetlink_queue_core.c b/net/netfilter/nfnetlink_queue_core.c
index ae2e5c1..21258cf 100644
--- a/net/netfilter/nfnetlink_queue_core.c
+++ b/net/netfilter/nfnetlink_queue_core.c
@@ -298,7 +298,7 @@ nfqnl_put_packet_info(struct sk_buff *nlskb, struct sk_buff *packet,
 }
 
 static struct sk_buff *
-nfqnl_build_packet_message(struct nfqnl_instance *queue,
+nfqnl_build_packet_message(struct net *net, struct nfqnl_instance *queue,
 			   struct nf_queue_entry *entry,
 			   __be32 **packet_id_ptr)
 {
@@ -372,7 +372,7 @@ nfqnl_build_packet_message(struct nfqnl_instance *queue,
 	if (queue->flags & NFQA_CFG_F_CONNTRACK)
 		ct = nfqnl_ct_get(entskb, &size, &ctinfo);
 
-	skb = nfnetlink_alloc_skb(&init_net, size, queue->peer_portid,
+	skb = nfnetlink_alloc_skb(net, size, queue->peer_portid,
 				  GFP_ATOMIC);
 	if (!skb)
 		return NULL;
@@ -525,7 +525,7 @@ __nfqnl_enqueue_packet(struct net *net, struct nfqnl_instance *queue,
 	__be32 *packet_id_ptr;
 	int failopen = 0;
 
-	nskb = nfqnl_build_packet_message(queue, entry, &packet_id_ptr);
+	nskb = nfqnl_build_packet_message(net, queue, entry, &packet_id_ptr);
 	if (nskb == NULL) {
 		err = -ENOMEM;
 		goto err_out;
-- 
1.7.10.4

