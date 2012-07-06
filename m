From: pablo@netfilter.org
Subject: [PATCH 18/18] netfilter: nfnetlink_queue: do not allow to set unsupported flag bits
Date: Fri,  6 Jul 2012 13:17:08 +0200
Message-ID: <1341573428-3204-19-git-send-email-pablo@netfilter.org>
References: <1341573428-3204-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:43598 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933543Ab2GFLTQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Jul 2012 07:19:16 -0400
In-Reply-To: <1341573428-3204-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Krishna Kumar <krkumar2@in.ibm.com>

Allow setting of only supported flag bits in queue->flags.

Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/netfilter/nfnetlink_queue.h |    1 +
 net/netfilter/nfnetlink_queue_core.c      |    5 +++++
 2 files changed, 6 insertions(+)

diff --git a/include/linux/netfilter/nfnetlink_queue.h b/include/linux/netfilter/nfnetlink_queue.h
index e0d8fd8..3b1c136 100644
--- a/include/linux/netfilter/nfnetlink_queue.h
+++ b/include/linux/netfilter/nfnetlink_queue.h
@@ -95,5 +95,6 @@ enum nfqnl_attr_config {
 /* Flags for NFQA_CFG_FLAGS */
 #define NFQA_CFG_F_FAIL_OPEN			(1 << 0)
 #define NFQA_CFG_F_CONNTRACK			(1 << 1)
+#define NFQA_CFG_F_MAX				(1 << 2)
 
 #endif /* _NFNETLINK_QUEUE_H */
diff --git a/net/netfilter/nfnetlink_queue_core.c b/net/netfilter/nfnetlink_queue_core.c
index a0b6492..c0496a5 100644
--- a/net/netfilter/nfnetlink_queue_core.c
+++ b/net/netfilter/nfnetlink_queue_core.c
@@ -910,6 +910,11 @@ nfqnl_recv_config(struct sock *ctnl, struct sk_buff *skb,
 		flags = ntohl(nla_get_be32(nfqa[NFQA_CFG_FLAGS]));
 		mask = ntohl(nla_get_be32(nfqa[NFQA_CFG_MASK]));
 
+		if (flags >= NFQA_CFG_F_MAX) {
+			ret = -EOPNOTSUPP;
+			goto err_out_unlock;
+		}
+
 		spin_lock_bh(&queue->lock);
 		queue->flags &= ~mask;
 		queue->flags |= flags & mask;
-- 
1.7.10
