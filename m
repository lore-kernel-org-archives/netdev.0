From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH net] ipv6: Fix addrconf_dst_alloc() failure check.
Date: Fri, 18 Jan 2013 20:56:41 +0900
Message-ID: <50F93879.6010201@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:45578 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751015Ab3ARL4o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jan 2013 06:56:44 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The function returns NULL on error and it never return error code
embedded in pointer.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/ipv6/addrconf.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 420e563..d0a2df2b 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -783,8 +783,8 @@ ipv6_add_addr(struct inet6_dev *idev, const struct in6_addr *addr, int pfxlen,
 	}
 
 	rt = addrconf_dst_alloc(idev, addr, false);
-	if (IS_ERR(rt)) {
-		err = PTR_ERR(rt);
+	if (!rt) {
+		err = -ENOMEM;
 		goto out;
 	}
 
-- 
1.7.9.5
