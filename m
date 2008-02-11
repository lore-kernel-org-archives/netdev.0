From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH] [IPV4]: Remove warning in node_set_parent.
Date: Mon, 11 Feb 2008 11:47:17 +0300
Message-ID: <1202719637-4925-1-git-send-email-den@openvz.org>
Cc: netdev@vger.kernel.org, devel@openvz.org,
	shemminger@linux-foundation.org, "Denis V. Lunev" <den@openvz.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from swsoft-msk-nat.sw.ru ([195.214.232.10]:61454 "EHLO iris.sw.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750893AbYBKIrU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Feb 2008 03:47:20 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

net/ipv4/fib_trie.c: In function 'node_set_parent':
net/ipv4/fib_trie.c:184: warning: assignment makes integer from pointer
without a cast

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 net/ipv4/fib_trie.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index f5fba3f..1753cd4 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -177,10 +177,11 @@ static inline struct tnode *node_parent_rcu(struct node *node)
 	return rcu_dereference(ret);
 }
 
-static inline void node_set_parent(struct node *node, struct tnode *ptr)
+static inline void node_set_parent(struct node *node, struct tnode *__ptr)
 {
-	rcu_assign_pointer(node->parent,
-			   (unsigned long)ptr | NODE_TYPE(node));
+	struct node *ptr;
+	ptr = (struct node *)((unsigned long)__ptr | NODE_TYPE(node));
+	rcu_assign_pointer(node->parent, ptr);
 }
 
 static inline struct node *tnode_get_child(struct tnode *tn, unsigned int i)
-- 
1.5.3.rc5

