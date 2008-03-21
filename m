From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] socket: SOCK_DEBUG type checking
Date: Fri, 21 Mar 2008 07:51:32 -0700
Message-ID: <20080321075132.2fe4ac23@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:35665 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754353AbYCUOvi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Mar 2008 10:51:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the inline trick (same as pr_debug) to get checking
of debug statements even if no code is generated.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/include/net/sock.h	2008-03-20 20:25:04.000000000 -0700
+++ b/include/net/sock.h	2008-03-20 20:28:48.000000000 -0700
@@ -70,7 +70,11 @@
 #define SOCK_DEBUG(sk, msg...) do { if ((sk) && sock_flag((sk), SOCK_DBG)) \
 					printk(KERN_DEBUG msg); } while (0)
 #else
-#define SOCK_DEBUG(sk, msg...) do { } while (0)
+/* Validate arguments and do nothing */
+static void inline int __attribute__ ((format (printf, 2, 3)))
+SOCK_DEBUG(struct sock *sk, const char *msg, ...)
+{
+}
 #endif
 
 /* This is the per-socket lock.  The spinlock provides a synchronization
