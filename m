From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 45/47] netfilter: Remove NFDEBUG()
Date: Mon,  4 Sep 2017 00:42:52 +0200
Message-ID: <1504478574-13281-10-git-send-email-pablo@netfilter.org>
References: <1504478574-13281-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1504478574-13281-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Varsha Rao <rvarsha016@gmail.com>

Remove NFDEBUG and use pr_debug() instead of it.

Signed-off-by: Varsha Rao <rvarsha016@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_internals.h | 6 ------
 net/netfilter/nf_sockopt.c   | 2 +-
 2 files changed, 1 insertion(+), 7 deletions(-)

diff --git a/net/netfilter/nf_internals.h b/net/netfilter/nf_internals.h
index bacd6363946e..49f87ec093a3 100644
--- a/net/netfilter/nf_internals.h
+++ b/net/netfilter/nf_internals.h
@@ -5,12 +5,6 @@
 #include <linux/skbuff.h>
 #include <linux/netdevice.h>
 
-#ifdef CONFIG_NETFILTER_DEBUG
-#define NFDEBUG(format, args...)  printk(KERN_DEBUG format , ## args)
-#else
-#define NFDEBUG(format, args...)
-#endif
-
 /* nf_queue.c */
 int nf_queue(struct sk_buff *skb, struct nf_hook_state *state,
 	     const struct nf_hook_entries *entries, unsigned int index,
diff --git a/net/netfilter/nf_sockopt.c b/net/netfilter/nf_sockopt.c
index c68c1e58b362..d2a9e6b5d01f 100644
--- a/net/netfilter/nf_sockopt.c
+++ b/net/netfilter/nf_sockopt.c
@@ -33,7 +33,7 @@ int nf_register_sockopt(struct nf_sockopt_ops *reg)
 				reg->set_optmin, reg->set_optmax)
 			|| overlap(ops->get_optmin, ops->get_optmax,
 				   reg->get_optmin, reg->get_optmax))) {
-			NFDEBUG("nf_sock overlap: %u-%u/%u-%u v %u-%u/%u-%u\n",
+			pr_debug("nf_sock overlap: %u-%u/%u-%u v %u-%u/%u-%u\n",
 				ops->set_optmin, ops->set_optmax,
 				ops->get_optmin, ops->get_optmax,
 				reg->set_optmin, reg->set_optmax,
-- 
2.1.4


