From: roy.qing.li@gmail.com
Subject: [PATCH] ipv4: initialise the itag variable in __mkroute_input
Date: Thu, 22 May 2014 16:36:55 +0800
Message-ID: <1400747815-3470-1-git-send-email-roy.qing.li@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:41789 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751670AbaEVIhD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 May 2014 04:37:03 -0400
Received: by mail-pa0-f49.google.com with SMTP id lj1so2258969pab.8
        for <netdev@vger.kernel.org>; Thu, 22 May 2014 01:37:01 -0700 (PDT)
Received: from localhost ([1.202.252.122])
        by mx.google.com with ESMTPSA id as12sm116846620pac.43.2014.05.22.01.36.59
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Thu, 22 May 2014 01:37:00 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com>

the value of itag is a random value from stack, and may not be initiated by
fib_validate_source, which called fib_combine_itag if CONFIG_IP_ROUTE_CLASSID
is not set

This will make the cached dst uncertainty

Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
---
 net/ipv4/route.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 50e1e0f..4154eb7 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1526,7 +1526,7 @@ static int __mkroute_input(struct sk_buff *skb,
 	struct in_device *out_dev;
 	unsigned int flags = 0;
 	bool do_cache;
-	u32 itag;
+	u32 itag = 0;
 
 	/* get a working reference to the output device */
 	out_dev = __in_dev_get_rcu(FIB_RES_DEV(*res));
-- 
1.7.10.4
