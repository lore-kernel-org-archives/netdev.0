From: David Miller <davem@davemloft.net>
Subject: [PATCH 6/8] inetpeer: Add inet_getpeer_v6()
Date: Tue, 30 Nov 2010 13:22:12 -0800 (PST)
Message-ID: <20101130.132212.70214539.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58863
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752052Ab0K3VVq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Nov 2010 16:21:46 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 0F2F324C088
	for <netdev@vger.kernel.org>; Tue, 30 Nov 2010 13:22:13 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Now that all of the infrastructure is in place, we can add
the ipv6 shorthand for peer creation.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/inetpeer.h |   10 ++++++++++
 1 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/include/net/inetpeer.h b/include/net/inetpeer.h
index 834f045..fb8aeb1 100644
--- a/include/net/inetpeer.h
+++ b/include/net/inetpeer.h
@@ -11,6 +11,7 @@
 #include <linux/init.h>
 #include <linux/jiffies.h>
 #include <linux/spinlock.h>
+#include <net/ipv6.h>
 #include <asm/atomic.h>
 
 typedef struct {
@@ -61,6 +62,15 @@ static inline struct inet_peer *inet_getpeer_v4(__be32 v4daddr, int create)
 	return inet_getpeer(&daddr, create);
 }
 
+static inline struct inet_peer *inet_getpeer_v6(struct in6_addr *v6daddr, int create)
+{
+	inet_peer_address_t daddr;
+
+	ipv6_addr_copy((struct in6_addr *)daddr.a6, v6daddr);
+	daddr.family = AF_INET6;
+	return inet_getpeer(&daddr, create);
+}
+
 /* can be called from BH context or outside */
 extern void inet_putpeer(struct inet_peer *p);
 
-- 
1.7.3.2

