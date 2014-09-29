From: roy.qing.li@gmail.com
Subject: [PATCH][net-next] ipv4: unnecessary to set err on no_route path
Date: Mon, 29 Sep 2014 17:16:38 +0800
Message-ID: <1411982198-17416-1-git-send-email-roy.qing.li@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:38812 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750970AbaI2JQk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2014 05:16:40 -0400
Received: by mail-pd0-f177.google.com with SMTP id v10so14846133pde.8
        for <netdev@vger.kernel.org>; Mon, 29 Sep 2014 02:16:40 -0700 (PDT)
Received: from localhost ([106.120.101.38])
        by mx.google.com with ESMTPSA id qy10sm11724495pbb.47.2014.09.29.02.16.38
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Mon, 29 Sep 2014 02:16:39 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com>

When the code skips to no_route label, it will skip to local_input at last,
then err will be reset on the local_input path before exit function.

Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
---
 net/ipv4/route.c |   11 ++++-------
 1 file changed, 4 insertions(+), 7 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index d4bd68d..403914b 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1704,11 +1704,9 @@ static int ip_route_input_slow(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 	fl4.daddr = daddr;
 	fl4.saddr = saddr;
 	err = fib_lookup(net, &fl4, &res);
-	if (err != 0) {
-		if (!IN_DEV_FORWARD(in_dev))
-			err = -EHOSTUNREACH;
+	if (err != 0)
 		goto no_route;
-	}
+
 
 	if (res.type == RTN_BROADCAST)
 		goto brd_input;
@@ -1721,10 +1719,9 @@ static int ip_route_input_slow(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 		goto local_input;
 	}
 
-	if (!IN_DEV_FORWARD(in_dev)) {
-		err = -EHOSTUNREACH;
+	if (!IN_DEV_FORWARD(in_dev))
 		goto no_route;
-	}
+
 	if (res.type != RTN_UNICAST)
 		goto martian_destination;
 
-- 
1.7.10.4
