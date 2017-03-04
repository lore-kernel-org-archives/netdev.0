From: fgao@ikuai8.com
Subject: [PATCH net-next 1/1] decnet: Use TCP nagle macro instead of literal number in decnet
Date: Sat,  4 Mar 2017 22:10:28 +0800
Message-ID: <1488636628-14768-1-git-send-email-fgao@ikuai8.com>
Cc: Gao Feng <fgao@ikuai8.com>
To: davem@davemloft.net, linux-decnet-user@lists.sourceforge.net,
        netdev@vger.kernel.org, gfree.wind@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpbg292.qq.com ([113.108.11.231]:51989 "EHLO smtpbg292.qq.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751814AbdCDOVY (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 4 Mar 2017 09:21:24 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao Feng <fgao@ikuai8.com>

Use existing TCP nagle macro TCP_NAGLE_OFF and TCP_NAGLE_CORK instead
of the literal number 1 and 2 in the current decnet codes.

Signed-off-by: Gao Feng <fgao@ikuai8.com>
---
 net/decnet/af_decnet.c | 13 +++++++------
 1 file changed, 7 insertions(+), 6 deletions(-)

diff --git a/net/decnet/af_decnet.c b/net/decnet/af_decnet.c
index a90ed67..15f1b65 100644
--- a/net/decnet/af_decnet.c
+++ b/net/decnet/af_decnet.c
@@ -132,6 +132,7 @@
 #include <net/neighbour.h>
 #include <net/dst.h>
 #include <net/fib_rules.h>
+#include <net/tcp.h>
 #include <net/dn.h>
 #include <net/dn_nsp.h>
 #include <net/dn_dev.h>
@@ -1468,18 +1469,18 @@ static int __dn_setsockopt(struct socket *sock, int level,int optname, char __us
 	case DSO_NODELAY:
 		if (optlen != sizeof(int))
 			return -EINVAL;
-		if (scp->nonagle == 2)
+		if (scp->nonagle == TCP_NAGLE_CORK)
 			return -EINVAL;
-		scp->nonagle = (u.val == 0) ? 0 : 1;
+		scp->nonagle = (u.val == 0) ? 0 : TCP_NAGLE_OFF;
 		/* if (scp->nonagle == 1) { Push pending frames } */
 		break;
 
 	case DSO_CORK:
 		if (optlen != sizeof(int))
 			return -EINVAL;
-		if (scp->nonagle == 1)
+		if (scp->nonagle == TCP_NAGLE_OFF)
 			return -EINVAL;
-		scp->nonagle = (u.val == 0) ? 0 : 2;
+		scp->nonagle = (u.val == 0) ? 0 : TCP_NAGLE_CORK;
 		/* if (scp->nonagle == 0) { Push pending frames } */
 		break;
 
@@ -1607,14 +1608,14 @@ static int __dn_getsockopt(struct socket *sock, int level,int optname, char __us
 	case DSO_NODELAY:
 		if (r_len > sizeof(int))
 			r_len = sizeof(int);
-		val = (scp->nonagle == 1);
+		val = (scp->nonagle == TCP_NAGLE_OFF);
 		r_data = &val;
 		break;
 
 	case DSO_CORK:
 		if (r_len > sizeof(int))
 			r_len = sizeof(int);
-		val = (scp->nonagle == 2);
+		val = (scp->nonagle == TCP_NAGLE_CORK);
 		r_data = &val;
 		break;
 
-- 
1.9.1
