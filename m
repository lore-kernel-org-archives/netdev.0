From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next] net: ipv6: remove skb_reserve in getroute
Date: Thu, 26 Jan 2017 14:08:36 -0800
Message-ID: <1485468516-4750-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f48.google.com ([74.125.83.48]:35739 "EHLO
        mail-pg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753569AbdAZWJ0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Jan 2017 17:09:26 -0500
Received: by mail-pg0-f48.google.com with SMTP id 194so75560177pgd.2
        for <netdev@vger.kernel.org>; Thu, 26 Jan 2017 14:08:41 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove skb_reserve and skb_reset_mac_header from inet6_rtm_getroute. The
allocated skb is not passed through the routing engine (like it is for
IPv4) and has not since the beginning of git time.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 net/ipv6/route.c | 6 ------
 1 file changed, 6 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 47499ed429da..5046d2b24004 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -3420,12 +3420,6 @@ static int inet6_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh)
 		goto errout;
 	}
 
-	/* Reserve room for dummy headers, this skb can pass
-	   through good chunk of routing engine.
-	 */
-	skb_reset_mac_header(skb);
-	skb_reserve(skb, MAX_HEADER + sizeof(struct ipv6hdr));
-
 	skb_dst_set(skb, &rt->dst);
 
 	err = rt6_fill_node(net, skb, rt, &fl6.daddr, &fl6.saddr, iif,
-- 
2.1.4
