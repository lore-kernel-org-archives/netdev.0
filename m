From: David Miller <davem@davemloft.net>
Subject: [PATCH 1/3] inetpeer: Add metrics storage to inetpeer entries.
Date: Thu, 27 Jan 2011 15:01:32 -0800 (PST)
Message-ID: <20110127.150132.245393569.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36916
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753803Ab1A0XA5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Jan 2011 18:00:57 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 8D30024C089
	for <netdev@vger.kernel.org>; Thu, 27 Jan 2011 15:01:32 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/inetpeer.h |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/include/net/inetpeer.h b/include/net/inetpeer.h
index 599d96e..2af0c63 100644
--- a/include/net/inetpeer.h
+++ b/include/net/inetpeer.h
@@ -11,6 +11,7 @@
 #include <linux/init.h>
 #include <linux/jiffies.h>
 #include <linux/spinlock.h>
+#include <linux/rtnetlink.h>
 #include <net/ipv6.h>
 #include <asm/atomic.h>
 
@@ -33,8 +34,8 @@ struct inet_peer {
 	atomic_t		refcnt;
 	/*
 	 * Once inet_peer is queued for deletion (refcnt == -1), following fields
-	 * are not available: rid, ip_id_count, tcp_ts, tcp_ts_stamp
-	 * We can share memory with rcu_head to keep inet_peer small
+	 * are not available: rid, ip_id_count, tcp_ts, tcp_ts_stamp, metrics
+	 * We can share memory with rcu_head to help keep inet_peer small.
 	 */
 	union {
 		struct {
@@ -42,6 +43,7 @@ struct inet_peer {
 			atomic_t	ip_id_count;	/* IP ID for the next packet */
 			__u32		tcp_ts;
 			__u32		tcp_ts_stamp;
+			u32		metrics[RTAX_MAX];
 		};
 		struct rcu_head         rcu;
 	};
-- 
1.7.3.4

