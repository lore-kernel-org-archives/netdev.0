From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Subject: [PATCH] ipv6: drop the judgement in rt6_alloc_cow()
Date: Tue, 05 Nov 2013 13:34:53 +0800
Message-ID: <5278837D.7030207@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:53394 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750704Ab3KEFgv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Nov 2013 00:36:51 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Now rt6_alloc_cow() is only called by ip6_pol_route() when
rt->rt6i_flags doesn't contain both RTF_NONEXTHOP and RTF_GATEWAY,
and rt->rt6i_flags hasn't been changed in ip6_rt_copy().
So there is no neccessary to judge whether rt->rt6i_flags contains
RTF_GATEWAY or not.

Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>
---
 net/ipv6/route.c | 8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index fd399ac..c28cdda 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -871,11 +871,9 @@ static struct rt6_info *rt6_alloc_cow(struct rt6_info *ort,
 	rt = ip6_rt_copy(ort, daddr);
 
 	if (rt) {
-		if (!(rt->rt6i_flags & RTF_GATEWAY)) {
-			if (ort->rt6i_dst.plen != 128 &&
-			    ipv6_addr_equal(&ort->rt6i_dst.addr, daddr))
-				rt->rt6i_flags |= RTF_ANYCAST;
-		}
+		if (ort->rt6i_dst.plen != 128 &&
+		    ipv6_addr_equal(&ort->rt6i_dst.addr, daddr))
+			rt->rt6i_flags |= RTF_ANYCAST;
 
 		rt->rt6i_flags |= RTF_CACHE;
 
-- 
1.8.3.1
