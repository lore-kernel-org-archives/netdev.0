From: David Miller <davem@davemloft.net>
Subject: [PATCH]: Kill SOCK_SLEEP_{PRE,POST}
Date: Tue, 17 Jun 2008 01:15:33 -0700 (PDT)
Message-ID: <20080617.011533.52296497.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49528
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753138AbYFQIPd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jun 2008 04:15:33 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id EF964C8C18B
	for <netdev@vger.kernel.org>; Tue, 17 Jun 2008 01:15:33 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


These are now unused, so we can blow them away finally.

Applied and pushed to net-next-2.6

net: Kill SOCK_SLEEP_PRE and SOCK_SLEEP_POST, no users.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/sock.h |   24 ------------------------
 1 files changed, 0 insertions(+), 24 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 0a80961..83f74b1 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1331,30 +1331,6 @@ extern int net_msg_warn;
 #define LIMIT_NETDEBUG(fmt, args...) \
 	do { if (net_msg_warn && net_ratelimit()) printk(fmt,##args); } while(0)
 
-/*
- * Macros for sleeping on a socket. Use them like this:
- *
- * SOCK_SLEEP_PRE(sk)
- * if (condition)
- * 	schedule();
- * SOCK_SLEEP_POST(sk)
- *
- * N.B. These are now obsolete and were, afaik, only ever used in DECnet
- * and when the last use of them in DECnet has gone, I'm intending to
- * remove them.
- */
-
-#define SOCK_SLEEP_PRE(sk) 	{ struct task_struct *tsk = current; \
-				DECLARE_WAITQUEUE(wait, tsk); \
-				tsk->state = TASK_INTERRUPTIBLE; \
-				add_wait_queue((sk)->sk_sleep, &wait); \
-				release_sock(sk);
-
-#define SOCK_SLEEP_POST(sk)	tsk->state = TASK_RUNNING; \
-				remove_wait_queue((sk)->sk_sleep, &wait); \
-				lock_sock(sk); \
-				}
-
 extern __u32 sysctl_wmem_max;
 extern __u32 sysctl_rmem_max;
 
-- 
1.5.5.1.308.g1fbb5

