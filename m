From: David Miller <davem@davemloft.net>
Subject: [PATCH 12/15] ipv4: Dirty less cache lines in route caching paths.
Date: Wed, 18 Jul 2012 11:24:28 -0700 (PDT)
Message-ID: <20120718.112428.2022910631217950355.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36952 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755422Ab2GRSY3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2012 14:24:29 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id 6010B583FCF
	for <netdev@vger.kernel.org>; Wed, 18 Jul 2012 11:24:31 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Don't bother incrementing dst->__use and setting dst->lastuse,
they are completely pointless and just slow things down.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/route.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index d4a3c6e..2190fc4 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1409,7 +1409,7 @@ static int __mkroute_input(struct sk_buff *skb,
 		if (!(flags & RTCF_DIRECTSRC) && !itag) {
 			rth = FIB_RES_NH(*res).nh_rth_input;
 			if (rth) {
-				dst_use(&rth->dst, jiffies);
+				dst_hold(&rth->dst);
 				goto out;
 			}
 			do_cache = true;
@@ -1585,7 +1585,7 @@ local_input:
 		if (!(flags & RTCF_DIRECTSRC) && !itag) {
 			rth = FIB_RES_NH(res).nh_rth_input;
 			if (rth) {
-				dst_use(&rth->dst, jiffies);
+				dst_hold(&rth->dst);
 				goto set_and_out;
 			}
 			do_cache = true;
@@ -1755,7 +1755,7 @@ static struct rtable *__mkroute_output(const struct fib_result *res,
 		if (!fnhe) {
 			rth = FIB_RES_NH(*res).nh_rth_output;
 			if (rth) {
-				dst_use(&rth->dst, jiffies);
+				dst_hold(&rth->dst);
 				return rth;
 			}
 		}
-- 
1.7.10.4
