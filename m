From: Andrew Hendry <andrew.hendry@gmail.com>
Subject: [PATCH net-next 4/5] X25 remove bkl from causediag ioctls
Date: Thu, 25 Nov 2010 23:18:43 +1100
Message-ID: <1290687523.5053.42.camel@jaunty>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:62246 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752237Ab0KYMSg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Nov 2010 07:18:36 -0500
Received: by mail-gy0-f174.google.com with SMTP id 11so421210gyb.19
        for <netdev@vger.kernel.org>; Thu, 25 Nov 2010 04:18:36 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Andrew Hendry <andrew.hendry@gmail.com>

---
 net/x25/af_x25.c |   15 +++++++--------
 1 files changed, 7 insertions(+), 8 deletions(-)

diff --git a/net/x25/af_x25.c b/net/x25/af_x25.c
index e2eea0a..8cfc419 100644
--- a/net/x25/af_x25.c
+++ b/net/x25/af_x25.c
@@ -1538,23 +1538,22 @@ out_dtefac_release:
 		}
 
 		case SIOCX25GCAUSEDIAG: {
-			struct x25_causediag causediag;
-			lock_kernel();
-			causediag = x25->causediag;
-			rc = copy_to_user(argp, &causediag,
-					  sizeof(causediag)) ? -EFAULT : 0;
-			unlock_kernel();
+			lock_sock(sk);
+			rc = copy_to_user(argp, &x25->causediag,
+					sizeof(x25->causediag))
+					? -EFAULT : 0;
+			release_sock(sk);
 			break;
 		}
 
 		case SIOCX25SCAUSEDIAG: {
 			struct x25_causediag causediag;
 			rc = -EFAULT;
-			lock_kernel();
 			if (copy_from_user(&causediag, argp, sizeof(causediag)))
 				break;
+			lock_sock(sk);
 			x25->causediag = causediag;
-			unlock_kernel();
+			release_sock(sk);
 			rc = 0;
 			break;
 
-- 
1.7.1



