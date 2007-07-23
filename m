From: Simon Arlott <simon@fire.lp0.eu>
Subject: [PATCH [Bug 8756]] IPv6: Don't update ADVMSS on routes where the
 MTU is not also updated
Date: Mon, 23 Jul 2007 20:25:45 +0100
Message-ID: <46A500B9.3030702@simon.arlott.org.uk>
References: <bug-8756-10286@http.bugzilla.kernel.org/> <20070714214831.d9def8c6.akpm@linux-foundation.org> <4699D5C7.2090906@simon.arlott.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from proxima.lp0.eu ([85.158.45.36]:49198 "EHLO proxima.lp0.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761816AbXGWTZt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Jul 2007 15:25:49 -0400
In-Reply-To: <4699D5C7.2090906@simon.arlott.org.uk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The ADVMSS value was incorrectly updated for ALL routes when the MTU 
is updated because it's outside the effect of the if statement's 
condition.

Signed-off-by: Simon Arlott <simon@fire.lp0.eu>
---
This fixes http://bugzilla.kernel.org/show_bug.cgi?id=8756

 net/ipv6/route.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 919de68..55ea80f 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1983,9 +1983,10 @@ static int rt6_mtu_change_route(struct rt6_info *rt, void *p_arg)
 	    !dst_metric_locked(&rt->u.dst, RTAX_MTU) &&
 	    (dst_mtu(&rt->u.dst) > arg->mtu ||
 	     (dst_mtu(&rt->u.dst) < arg->mtu &&
-	      dst_mtu(&rt->u.dst) == idev->cnf.mtu6)))
+	      dst_mtu(&rt->u.dst) == idev->cnf.mtu6))) {
 		rt->u.dst.metrics[RTAX_MTU-1] = arg->mtu;
-	rt->u.dst.metrics[RTAX_ADVMSS-1] = ipv6_advmss(arg->mtu);
+		rt->u.dst.metrics[RTAX_ADVMSS-1] = ipv6_advmss(arg->mtu);
+	}
 	return 0;
 }
 
-- 
1.5.0.1

-- 
Simon Arlott


