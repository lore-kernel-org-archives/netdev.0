From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [PATCH] ipv4: Minor logic clean-up in ipv4_mtu
Date: Mon, 27 Aug 2012 09:30:01 -0700
Message-ID: <20120827162930.2969.96733.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jeffrey.t.kirsher@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:45021 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751727Ab2H0Q3m (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Aug 2012 12:29:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In ipv4_mtu there is some logic where we are testing for a non-zero value
and a timer expiration, then setting the value to zero, and then testing if
the value is zero we set it to a value based on the dst.  Instead of
bothering with the extra steps it is easier to just cleanup the logic so
that we set it to the dst based value if it is zero or if the timer has
expired.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---

 net/ipv4/route.c |    5 +----
 1 files changed, 1 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 50f6d3a..5162824 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1132,10 +1132,7 @@ static unsigned int ipv4_mtu(const struct dst_entry *dst)
 	const struct rtable *rt = (const struct rtable *) dst;
 	unsigned int mtu = rt->rt_pmtu;
 
-	if (mtu && time_after_eq(jiffies, rt->dst.expires))
-		mtu = 0;
-
-	if (!mtu)
+	if (!mtu || time_after_eq(jiffies, rt->dst.expires))
 		mtu = dst_metric_raw(dst, RTAX_MTU);
 
 	if (mtu && rt_is_output_route(rt))
