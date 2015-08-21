From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH V4 net-next 1/2] net: introduce socket family constants
Date: Fri, 21 Aug 2015 13:30:28 +0200
Message-ID: <1440156629-35691-2-git-send-email-ubraun@linux.vnet.ibm.com>
References: <20150726.161530.2192841818929026804.davem@davemloft.net>
 <1440156629-35691-1-git-send-email-ubraun@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: utz.bacher@de.ibm.com, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org, schwidefsky@de.ibm.com,
	heiko.carstens@de.ibm.com, ursula.braun@de.ibm.com,
	ubraun@linux.vnet.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp14.uk.ibm.com ([195.75.94.110]:36903 "EHLO
	e06smtp14.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752671AbbHULap (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Aug 2015 07:30:45 -0400
Received: from /spool/local
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
	Fri, 21 Aug 2015 12:30:43 +0100
In-Reply-To: <1440156629-35691-1-git-send-email-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ursula.braun@de.ibm.com>

The new socket family is assigned the next available address / protocol
family constant 41.
Implementing SO_KEEPALIVE for SMC-R requires an extra hook in net/ipv4/timer.c.

Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
---
 include/linux/socket.h |  4 +++-
 include/net/smc.h      | 13 +++++++++++++
 net/ipv4/tcp_timer.c   |  2 +-
 3 files changed, 17 insertions(+), 2 deletions(-)
 create mode 100644 include/net/smc.h

diff --git a/include/linux/socket.h b/include/linux/socket.h
index 5bf59c8..1adcbcc 100644
--- a/include/linux/socket.h
+++ b/include/linux/socket.h
@@ -200,7 +200,8 @@ struct ucred {
 #define AF_ALG		38	/* Algorithm sockets		*/
 #define AF_NFC		39	/* NFC sockets			*/
 #define AF_VSOCK	40	/* vSockets			*/
-#define AF_MAX		41	/* For now.. */
+#define AF_SMC		41	/* smc sockets			*/
+#define AF_MAX		42	/* For now.. */
 
 /* Protocol families, same as address families. */
 #define PF_UNSPEC	AF_UNSPEC
@@ -246,6 +247,7 @@ struct ucred {
 #define PF_ALG		AF_ALG
 #define PF_NFC		AF_NFC
 #define PF_VSOCK	AF_VSOCK
+#define PF_SMC		AF_SMC
 #define PF_MAX		AF_MAX
 
 /* Maximum queue length specifiable by listen.  */
diff --git a/include/net/smc.h b/include/net/smc.h
new file mode 100644
index 0000000..cd513ee
--- /dev/null
+++ b/include/net/smc.h
@@ -0,0 +1,13 @@
+/*
+ * SMC		Definitions for the SMC protocol.
+ *
+ * Author:	Ursula Braun <ursula.braun@de.ibm.com>
+ */
+#ifndef _SMC_H
+#define _SMC_H
+
+/* SMC socket options - disjunct with TCP socket options */
+#define SMC_KEEPALIVE		99	/* start/stop keepalives */
+
+#endif /* _SMC_H */
+
diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
index 7149ebc..070bfc7 100644
--- a/net/ipv4/tcp_timer.c
+++ b/net/ipv4/tcp_timer.c
@@ -557,7 +557,7 @@ void tcp_set_keepalive(struct sock *sk, int val)
 	else if (!val)
 		inet_csk_delete_keepalive_timer(sk);
 }
-
+EXPORT_SYMBOL(tcp_set_keepalive);
 
 static void tcp_keepalive_timer (unsigned long data)
 {
-- 
2.3.8
