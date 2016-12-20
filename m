From: Geliang Tang <geliangtang@gmail.com>
Subject: [PATCH] netfilter: xt_connlimit: use rb_entry()
Date: Tue, 20 Dec 2016 22:02:13 +0800
Message-ID: <5fab578543b7f15cb416438800e24e70af675835.1482204114.git.geliangtang@gmail.com>
References: <ddabc96c798df194791134d8e070d728e2a7b59f.1482203698.git.geliangtang@gmail.com>
Cc: Geliang Tang <geliangtang@gmail.com>,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>,
        Patrick McHardy <kaber@trash.net>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <ddabc96c798df194791134d8e070d728e2a7b59f.1482203698.git.geliangtang@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

To make the code clearer, use rb_entry() instead of container_of() to
deal with rbtree.

Signed-off-by: Geliang Tang <geliangtang@gmail.com>
---
 net/netfilter/xt_connlimit.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/xt_connlimit.c b/net/netfilter/xt_connlimit.c
index 2aff2b7..660b61d 100644
--- a/net/netfilter/xt_connlimit.c
+++ b/net/netfilter/xt_connlimit.c
@@ -218,7 +218,7 @@ count_tree(struct net *net, struct rb_root *root,
 		int diff;
 		bool addit;
 
-		rbconn = container_of(*rbnode, struct xt_connlimit_rb, node);
+		rbconn = rb_entry(*rbnode, struct xt_connlimit_rb, node);
 
 		parent = *rbnode;
 		diff = same_source_net(addr, mask, &rbconn->addr, family);
@@ -398,7 +398,7 @@ static void destroy_tree(struct rb_root *r)
 	struct rb_node *node;
 
 	while ((node = rb_first(r)) != NULL) {
-		rbconn = container_of(node, struct xt_connlimit_rb, node);
+		rbconn = rb_entry(node, struct xt_connlimit_rb, node);
 
 		rb_erase(node, r);
 
-- 
2.9.3
