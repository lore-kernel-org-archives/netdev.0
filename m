From: Andrew Hendry <andrew.hendry@gmail.com>
Subject: [PATCH net-next 3/5] X25 remove bkl from calluserdata ioctls
Date: Thu, 25 Nov 2010 23:18:40 +1100
Message-ID: <1290687520.5053.41.camel@jaunty>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:62246 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752136Ab0KYMS3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Nov 2010 07:18:29 -0500
Received: by mail-gy0-f174.google.com with SMTP id 11so421210gyb.19
        for <netdev@vger.kernel.org>; Thu, 25 Nov 2010 04:18:29 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Andrew Hendry <andrew.hendry@gmail.com>

---
 net/x25/af_x25.c |   14 +++++++-------
 1 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/net/x25/af_x25.c b/net/x25/af_x25.c
index 2518efa..e2eea0a 100644
--- a/net/x25/af_x25.c
+++ b/net/x25/af_x25.c
@@ -1512,11 +1512,11 @@ out_dtefac_release:
 		}
 
 		case SIOCX25GCALLUSERDATA: {
-			struct x25_calluserdata cud = x25->calluserdata;
-			lock_kernel();
-			rc = copy_to_user(argp, &cud,
-					  sizeof(cud)) ? -EFAULT : 0;
-			unlock_kernel();
+			lock_sock(sk);
+			rc = copy_to_user(argp, &x25->calluserdata,
+					sizeof(x25->calluserdata))
+					? -EFAULT : 0;
+			release_sock(sk);
 			break;
 		}
 
@@ -1524,15 +1524,15 @@ out_dtefac_release:
 			struct x25_calluserdata calluserdata;
 
 			rc = -EFAULT;
-			lock_kernel();
 			if (copy_from_user(&calluserdata, argp,
 					   sizeof(calluserdata)))
 				break;
 			rc = -EINVAL;
 			if (calluserdata.cudlength > X25_MAX_CUD_LEN)
 				break;
+			lock_sock(sk);
 			x25->calluserdata = calluserdata;
-			unlock_kernel();
+			release_sock(sk);
 			rc = 0;
 			break;
 		}
-- 
1.7.1



