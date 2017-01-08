From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next] net: ipv4: remove disable of bottom half in inet_rtm_getroute
Date: Sat,  7 Jan 2017 20:04:23 -0800
Message-ID: <1483848263-17031-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f48.google.com ([74.125.83.48]:36234 "EHLO
        mail-pg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755558AbdAHEEb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 7 Jan 2017 23:04:31 -0500
Received: by mail-pg0-f48.google.com with SMTP id f188so264381743pgc.3
        for <netdev@vger.kernel.org>; Sat, 07 Jan 2017 20:04:31 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nothing about the route lookup requires bottom half to be disabled.
Remove the local_bh_disable ... local_bh_enable around ip_route_input.
This appears to be a vestige of days gone by as it has been there
since the beginning of git time.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 net/ipv4/route.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index f51823dc998b..7144288371cf 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2631,9 +2631,7 @@ static int inet_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh)
 		skb->protocol	= htons(ETH_P_IP);
 		skb->dev	= dev;
 		skb->mark	= mark;
-		local_bh_disable();
 		err = ip_route_input(skb, dst, src, rtm->rtm_tos, dev);
-		local_bh_enable();
 
 		rt = skb_rtable(skb);
 		if (err == 0 && rt->dst.error)
-- 
2.1.4
