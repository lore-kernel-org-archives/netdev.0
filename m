From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [PATCH] ipv6: Fix dst_release of invalid pointer
Date: Wed, 27 Jan 2010 12:38:02 +0530
Message-ID: <20100127070802.26065.73104.sendpatchset@krkumar2.in.ibm.com>
Cc: netdev@vger.kernel.org, Krishna Kumar <krkumar2@in.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:37960 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754266Ab0A0HII (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Jan 2010 02:08:08 -0500
Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by e2.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id o0R6wXq4014249
	for <netdev@vger.kernel.org>; Wed, 27 Jan 2010 01:58:33 -0500
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o0R786401708136
	for <netdev@vger.kernel.org>; Wed, 27 Jan 2010 02:08:06 -0500
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o0R785Eo032016
	for <netdev@vger.kernel.org>; Wed, 27 Jan 2010 05:08:05 -0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix dst_release on a invalid region.

Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
---
 net/ipv6/addrconf.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff -ruNp org/net/ipv6/addrconf.c new/net/ipv6/addrconf.c
--- org/net/ipv6/addrconf.c	2010-01-27 10:03:28.000000000 +0530
+++ new/net/ipv6/addrconf.c	2010-01-27 10:04:00.000000000 +0530
@@ -823,7 +823,8 @@ static void ipv6_del_addr(struct inet6_i
 				rt->rt6i_flags |= RTF_EXPIRES;
 			}
 		}
-		dst_release(&rt->u.dst);
+		if (rt)
+			dst_release(&rt->u.dst);
 	}
 
 	in6_ifa_put(ifp);
