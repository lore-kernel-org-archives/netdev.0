From: David Miller <davem@davemloft.net>
Subject: [PATCH 04/16] net: Don't report route RTT metric value in cache
 dumps.
Date: Tue, 10 Jul 2012 08:07:17 -0700 (PDT)
Message-ID: <20120710.080717.626099199155863613.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38408 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754238Ab2GJPHR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jul 2012 11:07:17 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id ABC5F58662D
	for <netdev@vger.kernel.org>; Tue, 10 Jul 2012 08:07:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


We don't maintain it dynamically any longer, so reporting it would
be extremely misleading.  Report zero instead.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/decnet/dn_route.c |   11 +++++------
 net/ipv4/route.c      |   22 ++++++++++------------
 2 files changed, 15 insertions(+), 18 deletions(-)

diff --git a/net/decnet/dn_route.c b/net/decnet/dn_route.c
index 6e74b3f..707027f 100644
--- a/net/decnet/dn_route.c
+++ b/net/decnet/dn_route.c
@@ -1812,12 +1812,11 @@ static int dn_rt_cache_seq_show(struct seq_file *seq, void *v)
 	char buf1[DN_ASCBUF_LEN], buf2[DN_ASCBUF_LEN];
 
 	seq_printf(seq, "%-8s %-7s %-7s %04d %04d %04d\n",
-			rt->dst.dev ? rt->dst.dev->name : "*",
-			dn_addr2asc(le16_to_cpu(rt->rt_daddr), buf1),
-			dn_addr2asc(le16_to_cpu(rt->rt_saddr), buf2),
-			atomic_read(&rt->dst.__refcnt),
-			rt->dst.__use,
-			(int) dst_metric(&rt->dst, RTAX_RTT));
+		   rt->dst.dev ? rt->dst.dev->name : "*",
+		   dn_addr2asc(le16_to_cpu(rt->rt_daddr), buf1),
+		   dn_addr2asc(le16_to_cpu(rt->rt_saddr), buf2),
+		   atomic_read(&rt->dst.__refcnt),
+		   rt->dst.__use, 0);
 	return 0;
 }
 
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 72e88c2..d02c911 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -423,18 +423,16 @@ static int rt_cache_seq_show(struct seq_file *seq, void *v)
 		int len;
 
 		seq_printf(seq, "%s\t%08X\t%08X\t%8X\t%d\t%u\t%d\t"
-			      "%08X\t%d\t%u\t%u\t%02X\t%d\t%1d\t%08X%n",
-			r->dst.dev ? r->dst.dev->name : "*",
-			(__force u32)r->rt_dst,
-			(__force u32)r->rt_gateway,
-			r->rt_flags, atomic_read(&r->dst.__refcnt),
-			r->dst.__use, 0, (__force u32)r->rt_src,
-			dst_metric_advmss(&r->dst) + 40,
-			dst_metric(&r->dst, RTAX_WINDOW),
-			(int)((dst_metric(&r->dst, RTAX_RTT) >> 3) +
-			      dst_metric(&r->dst, RTAX_RTTVAR)),
-			r->rt_key_tos,
-			-1, 0, 0, &len);
+			   "%08X\t%d\t%u\t%u\t%02X\t%d\t%1d\t%08X%n",
+			   r->dst.dev ? r->dst.dev->name : "*",
+			   (__force u32)r->rt_dst,
+			   (__force u32)r->rt_gateway,
+			   r->rt_flags, atomic_read(&r->dst.__refcnt),
+			   r->dst.__use, 0, (__force u32)r->rt_src,
+			   dst_metric_advmss(&r->dst) + 40,
+			   dst_metric(&r->dst, RTAX_WINDOW), 0,
+			   r->rt_key_tos,
+			   -1, 0, 0, &len);
 
 		seq_printf(seq, "%*s\n", 127 - len, "");
 	}
-- 
1.7.10.4
