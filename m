From: David Miller <davem@davemloft.net>
Subject: [PATCH 02/19] ipv4: Don't report neigh uptodate state in rtcache
 procfs.
Date: Tue, 03 Jul 2012 02:45:56 -0700 (PDT)
Message-ID: <20120703.024556.1263303670033509628.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36815 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932250Ab2GCJp4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jul 2012 05:45:56 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id 5EAE058411D
	for <netdev@vger.kernel.org>; Tue,  3 Jul 2012 02:45:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Soon routes will not have a cached neigh attached, nor will we
be able to necessarily go directly to a neigh from an arbitrary
route.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/route.c |   12 ++----------
 1 file changed, 2 insertions(+), 10 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 2f40363..bae3638 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -418,13 +418,7 @@ static int rt_cache_seq_show(struct seq_file *seq, void *v)
 			   "HHUptod\tSpecDst");
 	else {
 		struct rtable *r = v;
-		struct neighbour *n;
-		int len, HHUptod;
-
-		rcu_read_lock();
-		n = dst_get_neighbour_noref(&r->dst);
-		HHUptod = (n && (n->nud_state & NUD_CONNECTED)) ? 1 : 0;
-		rcu_read_unlock();
+		int len;
 
 		seq_printf(seq, "%s\t%08X\t%08X\t%8X\t%d\t%u\t%d\t"
 			      "%08X\t%d\t%u\t%u\t%02X\t%d\t%1d\t%08X%n",
@@ -438,9 +432,7 @@ static int rt_cache_seq_show(struct seq_file *seq, void *v)
 			(int)((dst_metric(&r->dst, RTAX_RTT) >> 3) +
 			      dst_metric(&r->dst, RTAX_RTTVAR)),
 			r->rt_key_tos,
-			-1,
-			HHUptod,
-			0, &len);
+			-1, 0, 0, &len);
 
 		seq_printf(seq, "%*s\n", 127 - len, "");
 	}
-- 
1.7.10
