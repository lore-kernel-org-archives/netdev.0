From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH] return the right retcode when add a unreachable route
Date: Sun,  6 Jul 2014 19:01:51 +0800
Message-ID: <1404644511-22112-1-git-send-email-lucien.xin@gmail.com>
Cc: Xin Long <lucien.xin@gmail.com>
To: network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:59962 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750897AbaGFLCI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Jul 2014 07:02:08 -0400
Received: by mail-pa0-f46.google.com with SMTP id eu11so3925825pac.19
        for <netdev@vger.kernel.org>; Sun, 06 Jul 2014 04:02:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

when add a route like this:
ip route add 74.125.31.199 dev eth0 via 1.2.3.4 ,
1.2.3.4 is a unreachable ip, it return -ENETUNREACH, it is ok.
but before that I add a rule:
ip rule add fwmark 1 lookup 101 ,
then add that route , it will return -ESRCH.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/net/ip_fib.h | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
index 9922093..cfc2293 100644
--- a/include/net/ip_fib.h
+++ b/include/net/ip_fib.h
@@ -261,7 +261,9 @@ static inline int fib_lookup(struct net *net, struct flowi4 *flp,
 			return 0;
 		return -ENETUNREACH;
 	}
-	return __fib_lookup(net, flp, res);
+	if(__fib_lookup(net, flp, res))
+		return -ENETUNREACH;
+	return 0;
 }
 
 #endif /* CONFIG_IP_MULTIPLE_TABLES */
-- 
1.8.3.1
