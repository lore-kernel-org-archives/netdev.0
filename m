From: Himangi Saraogi <himangi774@gmail.com>
Subject: [PATCH] net_sched: remove exceptional & on function name
Date: Fri, 25 Jul 2014 01:50:41 +0530
Message-ID: <20140724202040.GA16310@himangi-Dell>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Julia Lawall <julia.lawall@lip6.fr>
To: Jamal Hadi Salim <jhs@mojatatu.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In this file, function names are otherwise used as pointers without &.

A simplified version of the Coccinelle semantic patch that makes this
change is as follows: 

// <smpl>
@r@
identifier f;
@@

f(...) { ... }

@@
identifier r.f;
@@

- &f
+ f
// </smpl>

Signed-off-by: Himangi Saraogi <himangi774@gmail.com>
Acked-by: Julia Lawall <julia.lawall@lip6.fr>
---
 net/sched/cls_tcindex.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sched/cls_tcindex.c b/net/sched/cls_tcindex.c
index c721cd4..3e9f764 100644
--- a/net/sched/cls_tcindex.c
+++ b/net/sched/cls_tcindex.c
@@ -420,7 +420,7 @@ static void tcindex_destroy(struct tcf_proto *tp)
 	pr_debug("tcindex_destroy(tp %p),p %p\n", tp, p);
 	walker.count = 0;
 	walker.skip = 0;
-	walker.fn = &tcindex_destroy_element;
+	walker.fn = tcindex_destroy_element;
 	tcindex_walk(tp, &walker);
 	kfree(p->perfect);
 	kfree(p->h);
-- 
1.9.1
