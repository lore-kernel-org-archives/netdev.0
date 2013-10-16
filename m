From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] ipv4: shrink rt_cache_stat
Date: Wed, 16 Oct 2013 02:49:04 -0700
Message-ID: <1381916944.2045.124.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f48.google.com ([209.85.160.48]:56422 "EHLO
	mail-pb0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760173Ab3JPJtG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Oct 2013 05:49:06 -0400
Received: by mail-pb0-f48.google.com with SMTP id ma3so595914pbc.35
        for <netdev@vger.kernel.org>; Wed, 16 Oct 2013 02:49:05 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Half of the rt_cache_stat fields are no longer used after IP
route cache removal, lets shrink this per cpu area.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/route.h |    8 --------
 net/ipv4/route.c    |   16 ++++++++--------
 2 files changed, 8 insertions(+), 16 deletions(-)

diff --git a/include/net/route.h b/include/net/route.h
index 0ad8e01..dd4ae00 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -88,22 +88,14 @@ struct ip_rt_acct {
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
index 6011615..d2d3253 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -295,7 +295,7 @@ static int rt_cpu_seq_show(struct seq_file *seq, void *v)
 	seq_printf(seq,"%08x  %08x %08x %08x %08x %08x %08x %08x "
 		   " %08x %08x %08x %08x %08x %08x %08x %08x %08x \n",
 		   dst_entries_get_slow(&ipv4_dst_ops),
-		   st->in_hit,
+		   0, /* st->in_hit */
 		   st->in_slow_tot,
 		   st->in_slow_mc,
 		   st->in_no_route,
@@ -303,16 +303,16 @@ static int rt_cpu_seq_show(struct seq_file *seq, void *v)
 		   st->in_martian_dst,
 		   st->in_martian_src,
 
-		   st->out_hit,
+		   0, /* st->out_hit */
 		   st->out_slow_tot,
 		   st->out_slow_mc,
 
-		   st->gc_total,
-		   st->gc_ignored,
-		   st->gc_goal_miss,
-		   st->gc_dst_overflow,
-		   st->in_hlist_search,
-		   st->out_hlist_search
+		   0, /* st->gc_total */
+		   0, /* st->gc_ignored */
+		   0, /* st->gc_goal_miss */
+		   0, /* st->gc_dst_overflow */
+		   0, /* st->in_hlist_search */
+		   0  /* st->out_hlist_search */
 		);
 	return 0;
 }
