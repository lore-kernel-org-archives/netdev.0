From: Ville Nuorvala <vnuorval@tcs.hut.fi>
Subject: [PATCH] IPv6: Fix NULL dereference in ipv6_del_addr()
Date: Fri, 17 Nov 2006 15:26:28 +0200
Message-ID: <455DB884.3050203@tcs.hut.fi>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020405030805010904040203"
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from neon.tcs.hut.fi ([130.233.215.20]:29073 "EHLO mail.tcs.hut.fi")
	by vger.kernel.org with ESMTP id S933601AbWKQN03 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Nov 2006 08:26:29 -0500
To: David Miller <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------020405030805010904040203
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit


--------------020405030805010904040203
Content-Type: text/plain;
 name="0001-IPv6-Fix-NULL-dereference-in-ipv6_del_addr.txt"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="0001-IPv6-Fix-NULL-dereference-in-ipv6_del_addr.txt"

>From 07ed0369cca6ef51013a63664b09ef402e79af9e Mon Sep 17 00:00:00 2001
From: Ville Nuorvala <vnuorval@tcs.hut.fi>
Date: Fri, 17 Nov 2006 14:05:45 +0200
Subject: [PATCH] IPv6: Fix NULL dereference in ipv6_del_addr()


Signed-off-by: Ville Nuorvala <vnuorval@tcs.hut.fi>
---
 net/ipv6/addrconf.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index b312a5f..5a88378 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -749,7 +749,8 @@ static void ipv6_del_addr(struct inet6_i
 				rt->rt6i_flags |= RTF_EXPIRES;
 			}
 		}
-		dst_release(&rt->u.dst);
+		if (rt)
+			dst_release(&rt->u.dst);
 	}
 
 	in6_ifa_put(ifp);
-- 
1.4.3.5


--------------020405030805010904040203--
