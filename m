From: akepner@sgi.com
Subject: [PATCH] don't put multicasts with mc_ttl=0 on the wire
Date: Tue, 15 May 2007 12:56:02 -0700
Message-ID: <20070515195602.GK19036@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: arenaud@sgi.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from netops-testserver-3-out.sgi.com ([192.48.171.28]:40317 "EHLO
	relay.sgi.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754550AbXEOT4J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 May 2007 15:56:09 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



A colleague of mine found that multicasts with a ttl of 0
can be sent on the wire. This happens if the sender doesn't
belong to the destination multicast group.

With the following the multicast ttl is respected whether
or not the sender belongs to the destination multicast group.

Signed-off-by: Arthur Kepner <akepner@sgi.com>

---

 net/ipv4/route.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index cb76e3c..bf25cf5 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2249,8 +2249,7 @@ static inline int __mkroute_output(struct rtable **result,
 	}
 	if (flags & (RTCF_BROADCAST | RTCF_MULTICAST)) {
 		rth->rt_spec_dst = fl->fl4_src;
-		if (flags & RTCF_LOCAL &&
-		    !(dev_out->flags & IFF_LOOPBACK)) {
+		if (!(dev_out->flags & IFF_LOOPBACK)) {
 			rth->u.dst.output = ip_mc_output;
 			RT_CACHE_STAT_INC(out_slow_mc);
 		}

-- 
Arthur

