From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next] net: ipv4: Remove flow arg from ip_mkroute_input
Date: Fri,  6 Jan 2017 17:39:58 -0800
Message-ID: <1483753198-16222-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f54.google.com ([74.125.83.54]:35034 "EHLO
        mail-pg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S940540AbdAGBkE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Jan 2017 20:40:04 -0500
Received: by mail-pg0-f54.google.com with SMTP id i5so192237749pgh.2
        for <netdev@vger.kernel.org>; Fri, 06 Jan 2017 17:40:04 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

fl4 arg is not used; remove it.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 net/ipv4/route.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 7b52ac20145b..b9bff78274bf 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1758,7 +1758,6 @@ static int ip_multipath_icmp_hash(struct sk_buff *skb)
 
 static int ip_mkroute_input(struct sk_buff *skb,
 			    struct fib_result *res,
-			    const struct flowi4 *fl4,
 			    struct in_device *in_dev,
 			    __be32 daddr, __be32 saddr, u32 tos)
 {
@@ -1883,7 +1882,7 @@ static int ip_route_input_slow(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 	if (res.type != RTN_UNICAST)
 		goto martian_destination;
 
-	err = ip_mkroute_input(skb, &res, &fl4, in_dev, daddr, saddr, tos);
+	err = ip_mkroute_input(skb, &res, in_dev, daddr, saddr, tos);
 out:	return err;
 
 brd_input:
-- 
2.1.4
