From: David Miller <davem@davemloft.net>
Subject: [PATCH 13/16] ipv4: Dirty less cache lines in route caching paths.
Date: Fri, 20 Jul 2012 14:26:42 -0700 (PDT)
Message-ID: <20120720.142642.1246300362126064129.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55708 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752498Ab2GTV0n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jul 2012 17:26:43 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id 5DD25583619
	for <netdev@vger.kernel.org>; Fri, 20 Jul 2012 14:26:45 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Don't bother incrementing dst->__use and setting dst->lastuse,
they are completely pointless and just slow things down.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/route.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 7e1c0ed..b870777 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1443,7 +1443,7 @@ static int __mkroute_input(struct sk_buff *skb,
 		if (!(flags & RTCF_DIRECTSRC) && !itag) {
 			rth = FIB_RES_NH(*res).nh_rth_input;
 			if (rt_cache_valid(rth)) {
-				dst_use(&rth->dst, jiffies);
+				dst_hold(&rth->dst);
 				goto out;
 			}
 			do_cache = true;
@@ -1619,7 +1619,7 @@ local_input:
 		if (!(flags & RTCF_DIRECTSRC) && !itag) {
 			rth = FIB_RES_NH(res).nh_rth_input;
 			if (rt_cache_valid(rth)) {
-				dst_use(&rth->dst, jiffies);
+				dst_hold(&rth->dst);
 				goto set_and_out;
 			}
 			do_cache = true;
@@ -1789,7 +1789,7 @@ static struct rtable *__mkroute_output(const struct fib_result *res,
 		if (!fnhe) {
 			rth = FIB_RES_NH(*res).nh_rth_output;
 			if (rt_cache_valid(rth)) {
-				dst_use(&rth->dst, jiffies);
+				dst_hold(&rth->dst);
 				return rth;
 			}
 		}
-- 
1.7.10.4
