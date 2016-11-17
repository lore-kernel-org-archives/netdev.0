From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net_sched: sch_fq: use hash_ptr()
Date: Thu, 17 Nov 2016 09:48:30 -0800
Message-ID: <1479404910.8455.269.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Hugh Dickins <hughd@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:34831 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754297AbcKQRsc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2016 12:48:32 -0500
Received: by mail-pf0-f194.google.com with SMTP id i88so11971625pfk.2
        for <netdev@vger.kernel.org>; Thu, 17 Nov 2016 09:48:31 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

When I wrote sch_fq.c, hash_ptr() on 64bit arches was awful,
and I chose hash_32().

Linus Torvalds and George Spelvin fixed this issue, so we can
use hash_ptr() to get more entropy on 64bit arches with Terabytes
of memory, and avoid the cast games.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Hugh Dickins <hughd@google.com>
---
 net/sched/sch_fq.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sched/sch_fq.c b/net/sched/sch_fq.c
index 18e752439f6f..86309a3156a5 100644
--- a/net/sched/sch_fq.c
+++ b/net/sched/sch_fq.c
@@ -245,7 +245,7 @@ static struct fq_flow *fq_classify(struct sk_buff *skb, struct fq_sched_data *q)
 		skb_orphan(skb);
 	}
 
-	root = &q->fq_root[hash_32((u32)(long)sk, q->fq_trees_log)];
+	root = &q->fq_root[hash_ptr(sk, q->fq_trees_log)];
 
 	if (q->flows >= (2U << q->fq_trees_log) &&
 	    q->inactive_flows > q->flows/2)
@@ -599,7 +599,7 @@ static void fq_rehash(struct fq_sched_data *q,
 				kmem_cache_free(fq_flow_cachep, of);
 				continue;
 			}
-			nroot = &new_array[hash_32((u32)(long)of->sk, new_log)];
+			nroot = &new_array[hash_ptr(of->sk, new_log)];
 
 			np = &nroot->rb_node;
 			parent = NULL;
