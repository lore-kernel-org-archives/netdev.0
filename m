From: Andrew Hendry <andrew.hendry@gmail.com>
Subject: [PATCH 2/2] X25: Dont let x25_bind use addresses containing
 characters
Date: Sun, 14 Feb 2010 23:00:45 +1100
Message-ID: <1266148845.4731.45.camel@ibex>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f197.google.com ([209.85.222.197]:47912 "EHLO
	mail-pz0-f197.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754372Ab0BNMGw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Feb 2010 07:06:52 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Addresses should be all digits.
Stops x25_bind using addresses containing characters.

Signed-off-by: Andrew Hendry <andrew.hendry@gmail.com>

---
diff --git a/net/x25/af_x25.c b/net/x25/af_x25.c
index 6c7104e..8cc7583 100644
--- a/net/x25/af_x25.c
+++ b/net/x25/af_x25.c
@@ -55,6 +55,7 @@
 #include <linux/notifier.h>
 #include <linux/init.h>
 #include <linux/compat.h>
+#include <linux/ctype.h>
 
 #include <net/x25.h>
 #include <net/compat.h>
@@ -648,7 +649,7 @@ static int x25_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 {
 	struct sock *sk = sock->sk;
 	struct sockaddr_x25 *addr = (struct sockaddr_x25 *)uaddr;
-	int rc = 0;
+	int len, i, rc = 0;
 
 	lock_kernel();
 	if (!sock_flag(sk, SOCK_ZAPPED) ||
@@ -658,6 +659,14 @@ static int x25_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 		goto out;
 	}
 
+	len = strlen(addr->sx25_addr.x25_addr);
+	for (i = 0; i < len; i++) {
+		if (!isdigit(addr->sx25_addr.x25_addr[i])) {
+			rc = -EINVAL;
+			goto out;
+		}
+	}
+
 	x25_sk(sk)->source_addr = addr->sx25_addr;
 	x25_insert_socket(sk);
 	sock_reset_flag(sk, SOCK_ZAPPED);
-- 
1.6.3.3



