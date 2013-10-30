From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Subject: [PATCH] ipv6: remove the unnecessary statement in find_match()
Date: Wed, 30 Oct 2013 15:39:26 +0800
Message-ID: <5270B7AE.9020801@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, duanj.fnst@cn.fujitsu.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:47312 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751693Ab3J3HlU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Oct 2013 03:41:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


After reading the function rt6_check_neigh(), we can
know that the RT6_NUD_FAIL_SOFT can be returned only
when the IS_ENABLE(CONFIG_IPV6_ROUTER_PREF) is false.
so in function find_match(), there is no need to execute
the statement !IS_ENABLED(CONFIG_IPV6_ROUTER_PREF).

Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>
---
 net/ipv6/route.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index f54e3a1..708685f 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -619,7 +619,7 @@ static struct rt6_info *find_match(struct rt6_info *rt, int oif, int strict,
 		goto out;
 
 	m = rt6_score_route(rt, oif, strict);
-	if (m == RT6_NUD_FAIL_SOFT && !IS_ENABLED(CONFIG_IPV6_ROUTER_PREF)) {
+	if (m == RT6_NUD_FAIL_SOFT) {
 		match_do_rr = true;
 		m = 0; /* lowest valid score */
 	} else if (m < 0) {
-- 
1.8.3.1
