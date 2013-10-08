From: baker.kernel@gmail.com
Subject: [PATCH net-next] fib_trie: only calc for the un-first node
Date: Tue,  8 Oct 2013 11:36:51 +0800
Message-ID: <1381203411-12047-1-git-send-email-baker.kernel@gmail.com>
Cc: "baker.zhang" <baker.kernel@gmail.com>
To: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "baker.zhang" <baker.kernel@gmail.com>

This is a enhancement.

for the first node in fib_trie, newpos is 0, bit is 1.
Only for the leaf or node with unmatched key need calc pos.

Signed-off-by: baker.zhang <baker.kernel@gmail.com>
---
 net/ipv4/fib_trie.c |    6 +-----
 1 file changed, 1 insertion(+), 5 deletions(-)

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 45c74ba..ec9a9ef 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -1117,12 +1117,8 @@ static struct list_head *fib_insert_node(struct trie *t, u32 key, int plen)
 		 *  first tnode need some special handling
 		 */
 
-		if (tp)
-			pos = tp->pos+tp->bits;
-		else
-			pos = 0;
-
 		if (n) {
+			pos = tp ? tp->pos+tp->bits : 0;
 			newpos = tkey_mismatch(key, pos, n->key);
 			tn = tnode_new(n->key, newpos, 1);
 		} else {
-- 
1.7.9.5
