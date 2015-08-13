From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: [PATCH net-next v2 1/2] net: track link status of ipv6 nexthops
Date: Thu, 13 Aug 2015 10:39:00 -0400
Message-ID: <1439476741-952-1-git-send-email-gospo@cumulusnetworks.com>
Cc: Andy Gospodarek <gospo@cumulusnetworks.com>,
	Dinesh Dutt <ddutt@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f177.google.com ([209.85.160.177]:36494 "EHLO
	mail-yk0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751931AbbHMOjj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Aug 2015 10:39:39 -0400
Received: by ykay144 with SMTP id y144so42633540yka.3
        for <netdev@vger.kernel.org>; Thu, 13 Aug 2015 07:39:38 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support to track current link status of ipv6 nexthops to match
recent changes that added support for ipv4 nexthops.  This takes a
simple approach to track linkdown status for next-hops and simply
checks the dev for the dst entry and sets proper flags that to be used
in the netlink message.

v2: drop use of rt6i_nhflags since it is not needed right now

Signed-off-by: Andy Gospodarek <gospo@cumulusnetworks.com>
Signed-off-by: Dinesh Dutt <ddutt@cumulusnetworks.com>
---

I realize this patch might be a bit different expected based on
conversations on netdev yesterday, but I got a few off-list
communications that indicated a preference to not expand rt6_info at
this time -- despite the fact that expansion will likely be needed for
switchdev offload of ipv6 fib entries in the near future.

 net/ipv6/route.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 54fccf0..26b51e1 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -2885,6 +2885,8 @@ static int rt6_fill_node(struct net *net,
 	else
 		rtm->rtm_type = RTN_UNICAST;
 	rtm->rtm_flags = 0;
+	if (!netif_carrier_ok(rt->dst.dev))
+		rtm->rtm_flags |= RTNH_F_LINKDOWN;
 	rtm->rtm_scope = RT_SCOPE_UNIVERSE;
 	rtm->rtm_protocol = rt->rt6i_protocol;
 	if (rt->rt6i_flags & RTF_DYNAMIC)
-- 
1.9.3
