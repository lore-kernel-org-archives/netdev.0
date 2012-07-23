From: David Miller <davem@davemloft.net>
Subject: [PATCH 2/2] ipv4: Remove all RTCF_DIRECTSRC handliing.
Date: Mon, 23 Jul 2012 13:23:51 -0700 (PDT)
Message-ID: <20120723.132351.248613135410003247.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49154 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754612Ab2GWUXw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jul 2012 16:23:52 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id E3BDC58426C
	for <netdev@vger.kernel.org>; Mon, 23 Jul 2012 13:23:53 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The last and final kernel user, ICMP address replies,
has been removed.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/route.c |   11 ++---------
 1 file changed, 2 insertions(+), 9 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 9add088..34017be 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1391,9 +1391,6 @@ static int __mkroute_input(struct sk_buff *skb,
 		goto cleanup;
 	}
 
-	if (err)
-		flags |= RTCF_DIRECTSRC;
-
 	if (out_dev == in_dev && err &&
 	    (IN_DEV_SHARED_MEDIA(out_dev) ||
 	     inet_addr_onlink(out_dev, saddr, FIB_RES_GW(*res))))
@@ -1416,7 +1413,7 @@ static int __mkroute_input(struct sk_buff *skb,
 
 	do_cache = false;
 	if (res->fi) {
-		if (!(flags & RTCF_DIRECTSRC) && !itag) {
+		if (!itag) {
 			rth = FIB_RES_NH(*res).nh_rth_input;
 			if (rt_cache_valid(rth)) {
 				dst_hold(&rth->dst);
@@ -1558,8 +1555,6 @@ static int ip_route_input_slow(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 					  dev, in_dev, &itag);
 		if (err < 0)
 			goto martian_source_keep_err;
-		if (err)
-			flags |= RTCF_DIRECTSRC;
 		goto local_input;
 	}
 
@@ -1580,8 +1575,6 @@ brd_input:
 					  in_dev, &itag);
 		if (err < 0)
 			goto martian_source_keep_err;
-		if (err)
-			flags |= RTCF_DIRECTSRC;
 	}
 	flags |= RTCF_BROADCAST;
 	res.type = RTN_BROADCAST;
@@ -1590,7 +1583,7 @@ brd_input:
 local_input:
 	do_cache = false;
 	if (res.fi) {
-		if (!(flags & RTCF_DIRECTSRC) && !itag) {
+		if (!itag) {
 			rth = FIB_RES_NH(res).nh_rth_input;
 			if (rt_cache_valid(rth)) {
 				dst_hold(&rth->dst);
-- 
1.7.10.4
