From: Andrew Hendry <andrew.hendry@gmail.com>
Subject: [PATCH 4/4] X25: remove bkl in routing ioctls
Date: Fri, 19 Nov 2010 10:21:35 +1100
Message-ID: <1290122495.20070.63.camel@jaunty>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:56454 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760816Ab0KRXVk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Nov 2010 18:21:40 -0500
Received: by mail-vw0-f46.google.com with SMTP id 13so2163943vws.19
        for <netdev@vger.kernel.org>; Thu, 18 Nov 2010 15:21:39 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Routing doesn't use the socket data and is protected by x25_route_list_lock

Signed-off-by: Andrew Hendry <andrew.hendry@gmail.com>

---
 net/x25/af_x25.c |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/net/x25/af_x25.c b/net/x25/af_x25.c
index 2f235a6..2351ace 100644
--- a/net/x25/af_x25.c
+++ b/net/x25/af_x25.c
@@ -1412,9 +1412,7 @@ static int x25_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 			rc = -EPERM;
 			if (!capable(CAP_NET_ADMIN))
 				break;
-			lock_kernel();
 			rc = x25_route_ioctl(cmd, argp);
-			unlock_kernel();
 			break;
 		case SIOCX25GSUBSCRIP:
 			lock_kernel();
@@ -1710,9 +1708,7 @@ static int compat_x25_ioctl(struct socket *sock, unsigned int cmd,
 		rc = -EPERM;
 		if (!capable(CAP_NET_ADMIN))
 			break;
-		lock_kernel();
 		rc = x25_route_ioctl(cmd, argp);
-		unlock_kernel();
 		break;
 	case SIOCX25GSUBSCRIP:
 		lock_kernel();
-- 
1.7.1



