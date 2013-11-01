From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Subject: [PATCH net-next] ipv6: host should probe those non-reachable router
Date: Fri, 01 Nov 2013 10:47:15 +0800
Message-ID: <52731633.2030101@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org, netdev@vger.kernel.org,
	duanj.fnst@cn.fujitsu.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:54594 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1754502Ab3KACtL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Oct 2013 22:49:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


rather than those routers that the return value of rt6_score_route()
is RT6_NUD_SUCCEED.

Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>
---
 net/ipv6/route.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 1ac0b6e..b7bf5c7 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -623,12 +623,11 @@ static struct rt6_info *find_match(struct rt6_info *rt, int oif, int strict,
 		match_do_rr = true;
 		m = 0; /* lowest valid score */
 	} else if (m < 0) {
+		if (strict & RT6_LOOKUP_F_REACHABLE)
+			rt6_probe(rt);
 		goto out;
 	}
 
-	if (strict & RT6_LOOKUP_F_REACHABLE)
-		rt6_probe(rt);
-
 	if (m > *mpri) {
 		*do_rr = match_do_rr;
 		*mpri = m;
-- 
1.8.3.1
