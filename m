From: Andrew Hendry <andrew.hendry@gmail.com>
Subject: [PATCH net-next 5/5] X25 remove bkl in call user data length ioctl
Date: Thu, 25 Nov 2010 23:18:45 +1100
Message-ID: <1290687525.5053.43.camel@jaunty>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:41193 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752918Ab0KYMSm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Nov 2010 07:18:42 -0500
Received: by ywl5 with SMTP id 5so424671ywl.19
        for <netdev@vger.kernel.org>; Thu, 25 Nov 2010 04:18:41 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Andrew Hendry <andrew.hendry@gmail.com>

---
 net/x25/af_x25.c |   11 ++++++-----
 1 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/net/x25/af_x25.c b/net/x25/af_x25.c
index 8cfc419..ad96ee9 100644
--- a/net/x25/af_x25.c
+++ b/net/x25/af_x25.c
@@ -1562,19 +1562,20 @@ out_dtefac_release:
 		case SIOCX25SCUDMATCHLEN: {
 			struct x25_subaddr sub_addr;
 			rc = -EINVAL;
-			lock_kernel();
+			lock_sock(sk);
 			if(sk->sk_state != TCP_CLOSE)
-				break;
+				goto out_cud_release;
 			rc = -EFAULT;
 			if (copy_from_user(&sub_addr, argp,
 					sizeof(sub_addr)))
-				break;
+				goto out_cud_release;
 			rc = -EINVAL;
 			if(sub_addr.cudmatchlength > X25_MAX_CUD_LEN)
-				break;
+				goto out_cud_release;
 			x25->cudmatchlength = sub_addr.cudmatchlength;
-			unlock_kernel();
 			rc = 0;
+out_cud_release:
+			release_sock(sk);
 			break;
 		}
 
-- 
1.7.1



