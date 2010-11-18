From: Andrew Hendry <andrew.hendry@gmail.com>
Subject: [PATCH 3/4] X25: remove bkl in inq and outq ioctls
Date: Fri, 19 Nov 2010 10:21:28 +1100
Message-ID: <1290122488.20070.62.camel@jaunty>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:56454 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760805Ab0KRXVd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Nov 2010 18:21:33 -0500
Received: by mail-vw0-f46.google.com with SMTP id 13so2163943vws.19
        for <netdev@vger.kernel.org>; Thu, 18 Nov 2010 15:21:33 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Andrew Hendry <andrew.hendry@gmail.com>

---
 net/x25/af_x25.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/net/x25/af_x25.c b/net/x25/af_x25.c
index 2259783..2f235a6 100644
--- a/net/x25/af_x25.c
+++ b/net/x25/af_x25.c
@@ -1361,12 +1361,10 @@ static int x25_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 		case TIOCOUTQ: {
 			int amount;
 
-			lock_kernel();
 			amount = sk->sk_sndbuf - sk_wmem_alloc_get(sk);
 			if (amount < 0)
 				amount = 0;
 			rc = put_user(amount, (unsigned int __user *)argp);
-			unlock_kernel();
 			break;
 		}
 
@@ -1377,11 +1375,11 @@ static int x25_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 			 * These two are safe on a single CPU system as
 			 * only user tasks fiddle here
 			 */
-			lock_kernel();
+			lock_sock(sk);
 			if ((skb = skb_peek(&sk->sk_receive_queue)) != NULL)
 				amount = skb->len;
+			release_sock(sk);
 			rc = put_user(amount, (unsigned int __user *)argp);
-			unlock_kernel();
 			break;
 		}
 
-- 
1.7.1



