From: roy.qing.li@gmail.com
Subject: [PATCH] ipv6: unneccessary to get address prefix in addrconf_get_prefix_route
Date: Mon, 23 Dec 2013 09:32:38 +0800
Message-ID: <1387762358-10607-1-git-send-email-roy.qing.li@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:55000 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756665Ab3LWBcp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Dec 2013 20:32:45 -0500
Received: by mail-pa0-f43.google.com with SMTP id bj1so4762281pad.30
        for <netdev@vger.kernel.org>; Sun, 22 Dec 2013 17:32:45 -0800 (PST)
Received: from localhost ([1.202.252.122])
        by mx.google.com with ESMTPSA id bh6sm39556786pad.20.2013.12.22.17.32.42
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Sun, 22 Dec 2013 17:32:44 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com>

Since addrconf_get_prefix_route inputs the address prefix to fib6_locate,
which does not uses the data which is out of the prefix_len length,
so do not need to use ipv6_addr_prefix to get address prefix.

Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
---
 net/ipv6/addrconf.c |    5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 3c3425e..def65f6 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -988,12 +988,9 @@ static void ipv6_del_addr(struct inet6_ifaddr *ifp)
 	 * --yoshfuji
 	 */
 	if ((ifp->flags & IFA_F_PERMANENT) && onlink < 1) {
-		struct in6_addr prefix;
 		struct rt6_info *rt;
 
-		ipv6_addr_prefix(&prefix, &ifp->addr, ifp->prefix_len);
-
-		rt = addrconf_get_prefix_route(&prefix,
+		rt = addrconf_get_prefix_route(&ifp->addr,
 					       ifp->prefix_len,
 					       ifp->idev->dev,
 					       0, RTF_GATEWAY | RTF_DEFAULT);
-- 
1.7.10.4
