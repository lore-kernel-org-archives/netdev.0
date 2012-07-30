From: Vijay Subramanian <subramanian.vijay@gmail.com>
Subject: [PATCH net] net: Remove unused variables in rt_cache_stat
Date: Mon, 30 Jul 2012 14:45:50 -0700
Message-ID: <1343684750-2987-1-git-send-email-subramanian.vijay@gmail.com>
Cc: davem@davemloft.net,
	Vijay Subramanian <subramanian.vijay@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:58389 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754682Ab2G3Vhh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jul 2012 17:37:37 -0400
Received: by pbbrp8 with SMTP id rp8so10465903pbb.19
        for <netdev@vger.kernel.org>; Mon, 30 Jul 2012 14:37:36 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With the removal of the routing cache, some variables in rt_cache_stat are no
longer used. Remove them from rt_cache_stat and do not print them out in
/proc/net/stat/rt_cache.

Signed-off-by: Vijay Subramanian <subramanian.vijay@gmail.com>
---
checkpatch complains that the seq_printf line is over 80 chars which was already
the case. I left it as is to aid in grepping the sources. 

 include/net/route.h |    8 --------
 net/ipv4/route.c    |   16 +++-------------
 2 files changed, 3 insertions(+), 21 deletions(-)

diff --git a/include/net/route.h b/include/net/route.h
index 8c52bc6..69e54f9 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -84,22 +84,14 @@ struct ip_rt_acct {
 };
 
 struct rt_cache_stat {
-        unsigned int in_hit;
         unsigned int in_slow_tot;
         unsigned int in_slow_mc;
         unsigned int in_no_route;
         unsigned int in_brd;
         unsigned int in_martian_dst;
         unsigned int in_martian_src;
-        unsigned int out_hit;
         unsigned int out_slow_tot;
         unsigned int out_slow_mc;
-        unsigned int gc_total;
-        unsigned int gc_ignored;
-        unsigned int gc_goal_miss;
-        unsigned int gc_dst_overflow;
-        unsigned int in_hlist_search;
-        unsigned int out_hlist_search;
 };
 
 extern struct ip_rt_acct __percpu *ip_rt_acct;
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index fc1a81c..114a6c9 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -298,14 +298,12 @@ static int rt_cpu_seq_show(struct seq_file *seq, void *v)
 	struct rt_cache_stat *st = v;
 
 	if (v == SEQ_START_TOKEN) {
-		seq_printf(seq, "entries  in_hit in_slow_tot in_slow_mc in_no_route in_brd in_martian_dst in_martian_src  out_hit out_slow_tot out_slow_mc  gc_total gc_ignored gc_goal_miss gc_dst_overflow in_hlist_search out_hlist_search\n");
+		seq_printf(seq, "entries  in_slow_tot in_slow_mc in_no_route in_brd in_martian_dst in_martian_src out_slow_tot out_slow_mc\n");
 		return 0;
 	}
 
-	seq_printf(seq,"%08x  %08x %08x %08x %08x %08x %08x %08x "
-		   " %08x %08x %08x %08x %08x %08x %08x %08x %08x \n",
+	seq_printf(seq, "%08x  %08x %08x %08x %08x %08x %08x %08x %08x\n",
 		   dst_entries_get_slow(&ipv4_dst_ops),
-		   st->in_hit,
 		   st->in_slow_tot,
 		   st->in_slow_mc,
 		   st->in_no_route,
@@ -313,16 +311,8 @@ static int rt_cpu_seq_show(struct seq_file *seq, void *v)
 		   st->in_martian_dst,
 		   st->in_martian_src,
 
-		   st->out_hit,
 		   st->out_slow_tot,
-		   st->out_slow_mc,
-
-		   st->gc_total,
-		   st->gc_ignored,
-		   st->gc_goal_miss,
-		   st->gc_dst_overflow,
-		   st->in_hlist_search,
-		   st->out_hlist_search
+		   st->out_slow_mc
 		);
 	return 0;
 }
-- 
1.7.0.4
