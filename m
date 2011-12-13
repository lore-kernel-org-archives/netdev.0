From: David Miller <davem@davemloft.net>
Subject: [PATCH] ipv6: Check dest prefix length on original route not
 copied one in rt6_alloc_cow().
Date: Tue, 13 Dec 2011 17:35:51 -0500 (EST)
Message-ID: <20111213.173551.163815101446083653.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: zheng.z.yan@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:51324 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754895Ab1LMWf4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Dec 2011 17:35:56 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


After commit 8e2ec639173f325977818c45011ee176ef2b11f6 ("ipv6: don't
use inetpeer to store metrics for routes.") the test in rt6_alloc_cow()
for setting the ANYCAST flag is now wrong.

'rt' will always now have a plen of 128, because it is set explicitly
to 128 by ip6_rt_copy.

So to restore the semantics of the test, check the destination prefix
length of 'ort'.

Signed-off-by: David S. Miller <davem@davemloft.net>
---

Committed to 'net'.

 net/ipv6/route.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 3399dd3..b582a0a 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -728,7 +728,7 @@ static struct rt6_info *rt6_alloc_cow(const struct rt6_info *ort,
 		int attempts = !in_softirq();
 
 		if (!(rt->rt6i_flags&RTF_GATEWAY)) {
-			if (rt->rt6i_dst.plen != 128 &&
+			if (ort->rt6i_dst.plen != 128 &&
 			    ipv6_addr_equal(&ort->rt6i_dst.addr, daddr))
 				rt->rt6i_flags |= RTF_ANYCAST;
 			ipv6_addr_copy(&rt->rt6i_gateway, daddr);
-- 
1.7.7.4
