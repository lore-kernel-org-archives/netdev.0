From: Andrew Hendry <andrew.hendry@gmail.com>
Subject: [PATCH 2/4] X25: remove bkl in timestamp ioctls
Date: Fri, 19 Nov 2010 10:21:20 +1100
Message-ID: <1290122480.20070.61.camel@jaunty>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:56454 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758388Ab0KRXV0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Nov 2010 18:21:26 -0500
Received: by mail-vw0-f46.google.com with SMTP id 13so2163943vws.19
        for <netdev@vger.kernel.org>; Thu, 18 Nov 2010 15:21:26 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Andrew Hendry <andrew.hendry@gmail.com>

---
 net/x25/af_x25.c |    8 --------
 1 files changed, 0 insertions(+), 8 deletions(-)

diff --git a/net/x25/af_x25.c b/net/x25/af_x25.c
index c99029b..2259783 100644
--- a/net/x25/af_x25.c
+++ b/net/x25/af_x25.c
@@ -1387,19 +1387,15 @@ static int x25_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 
 		case SIOCGSTAMP:
 			rc = -EINVAL;
-			lock_kernel();
 			if (sk)
 				rc = sock_get_timestamp(sk,
 						(struct timeval __user *)argp);
-			unlock_kernel();
 			break;
 		case SIOCGSTAMPNS:
 			rc = -EINVAL;
-			lock_kernel();
 			if (sk)
 				rc = sock_get_timestampns(sk,
 						(struct timespec __user *)argp);
-			unlock_kernel();
 			break;
 		case SIOCGIFADDR:
 		case SIOCSIFADDR:
@@ -1689,19 +1685,15 @@ static int compat_x25_ioctl(struct socket *sock, unsigned int cmd,
 		break;
 	case SIOCGSTAMP:
 		rc = -EINVAL;
-		lock_kernel();
 		if (sk)
 			rc = compat_sock_get_timestamp(sk,
 					(struct timeval __user*)argp);
-		unlock_kernel();
 		break;
 	case SIOCGSTAMPNS:
 		rc = -EINVAL;
-		lock_kernel();
 		if (sk)
 			rc = compat_sock_get_timestampns(sk,
 					(struct timespec __user*)argp);
-		unlock_kernel();
 		break;
 	case SIOCGIFADDR:
 	case SIOCSIFADDR:
-- 
1.7.1



