From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 6/6 net-2.6.25] [NETNS] Pass correct namespace in ip_rt_get_source.
Date: Mon, 21 Jan 2008 17:50:46 +0300
Message-ID: <1200927046-11354-6-git-send-email-den@openvz.org>
References: <4794B10E.7010703@sw.ru>
Cc: netdev@vger.kernel.org, devel@openvz.org,
	containers@lists.osdl.org, "Denis V. Lunev" <den@openvz.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from swsoft-msk-nat.sw.ru ([195.214.232.10]:57167 "EHLO iris.sw.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754770AbYAUOuq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Jan 2008 09:50:46 -0500
In-Reply-To: <4794B10E.7010703@sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ip_rt_get_source is the infamous place for which dst_ifdown kludges have
been implemented. This means that rt->u.dst.dev can be safely dereferrenced
obtain nd_net.

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 net/ipv4/route.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index b3c6122..ede0571 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1559,7 +1559,7 @@ void ip_rt_get_source(u8 *addr, struct rtable *rt)
 
 	if (rt->fl.iif == 0)
 		src = rt->rt_src;
-	else if (fib_lookup(&init_net, &rt->fl, &res) == 0) {
+	else if (fib_lookup(rt->u.dst.dev->nd_net, &rt->fl, &res) == 0) {
 		src = FIB_RES_PREFSRC(res);
 		fib_res_put(&res);
 	} else
-- 
1.5.3.rc5

