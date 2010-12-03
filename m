From: Taku Izumi <izumi.taku@jp.fujitsu.com>
Subject: [PATCH 2/3] bonding: migrate some macros from bond_alb.c to bond_alb.h
Date: Fri, 03 Dec 2010 16:22:04 +0900
Message-ID: <4CF89A9C.8080603@jp.fujitsu.com>
References: <4CF89A00.8030902@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, shemminger@vyatta.com
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fgwmail5.fujitsu.co.jp ([192.51.44.35]:44131 "EHLO
	fgwmail5.fujitsu.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756050Ab0LCHWP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Dec 2010 02:22:15 -0500
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oB37MEF2023836
	for <netdev@vger.kernel.org> (envelope-from izumi.taku@jp.fujitsu.com);
	Fri, 3 Dec 2010 16:22:14 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6AEB045DE58
	for <netdev@vger.kernel.org>; Fri,  3 Dec 2010 16:22:14 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 390C245DE5A
	for <netdev@vger.kernel.org>; Fri,  3 Dec 2010 16:22:14 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 29A401DB804C
	for <netdev@vger.kernel.org>; Fri,  3 Dec 2010 16:22:14 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id DAAB91DB8040
	for <netdev@vger.kernel.org>; Fri,  3 Dec 2010 16:22:13 +0900 (JST)
In-Reply-To: <4CF89A00.8030902@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This patch simply migrates some macros from bond_alb.c to bond_alb.h.


Signed-off-by: Taku Izumi <izumi.taku@jp.fujitsu.com>

---
 drivers/net/bonding/bond_alb.c |   36 ------------------------------------
 drivers/net/bonding/bond_alb.h |   38 ++++++++++++++++++++++++++++++++++++++
 2 files changed, 38 insertions(+), 36 deletions(-)

Index: net-next/drivers/net/bonding/bond_alb.c
===================================================================
--- net-next.orig/drivers/net/bonding/bond_alb.c
+++ net-next/drivers/net/bonding/bond_alb.c
@@ -44,42 +44,6 @@
 #include "bond_alb.h"


-#define ALB_TIMER_TICKS_PER_SEC	    10	/* should be a divisor of HZ */
-#define BOND_TLB_REBALANCE_INTERVAL 10	/* In seconds, periodic re-balancing.
-					 * Used for division - never set
-					 * to zero !!!
-					 */
-#define BOND_ALB_LP_INTERVAL	    1	/* In seconds, periodic send of
-					 * learning packets to the switch
-					 */
-
-#define BOND_TLB_REBALANCE_TICKS (BOND_TLB_REBALANCE_INTERVAL \
-				  * ALB_TIMER_TICKS_PER_SEC)
-
-#define BOND_ALB_LP_TICKS (BOND_ALB_LP_INTERVAL \
-			   * ALB_TIMER_TICKS_PER_SEC)
-
-#define TLB_HASH_TABLE_SIZE 256	/* The size of the clients hash table.
-				 * Note that this value MUST NOT be smaller
-				 * because the key hash table is BYTE wide !
-				 */
-
-
-#define TLB_NULL_INDEX		0xffffffff
-#define MAX_LP_BURST		3
-
-/* rlb defs */
-#define RLB_HASH_TABLE_SIZE	256
-#define RLB_NULL_INDEX		0xffffffff
-#define RLB_UPDATE_DELAY	2*ALB_TIMER_TICKS_PER_SEC /* 2 seconds */
-#define RLB_ARP_BURST_SIZE	2
-#define RLB_UPDATE_RETRY	3	/* 3-ticks - must be smaller than the rlb
-					 * rebalance interval (5 min).
-					 */
-/* RLB_PROMISC_TIMEOUT = 10 sec equals the time that the current slave is
- * promiscuous after failover
- */
-#define RLB_PROMISC_TIMEOUT	10*ALB_TIMER_TICKS_PER_SEC

 #ifndef __long_aligned
 #define __long_aligned __attribute__((aligned((sizeof(long)))))
Index: net-next/drivers/net/bonding/bond_alb.h
===================================================================
--- net-next.orig/drivers/net/bonding/bond_alb.h
+++ net-next/drivers/net/bonding/bond_alb.h
@@ -31,6 +31,44 @@ struct slave;
 #define BOND_ALB_INFO(bond)   ((bond)->alb_info)
 #define SLAVE_TLB_INFO(slave) ((slave)->tlb_info)

+#define ALB_TIMER_TICKS_PER_SEC	    10	/* should be a divisor of HZ */
+#define BOND_TLB_REBALANCE_INTERVAL 10	/* In seconds, periodic re-balancing.
+					 * Used for division - never set
+					 * to zero !!!
+					 */
+#define BOND_ALB_LP_INTERVAL	    1	/* In seconds, periodic send of
+					 * learning packets to the switch
+					 */
+
+#define BOND_TLB_REBALANCE_TICKS (BOND_TLB_REBALANCE_INTERVAL \
+				  * ALB_TIMER_TICKS_PER_SEC)
+
+#define BOND_ALB_LP_TICKS (BOND_ALB_LP_INTERVAL \
+			   * ALB_TIMER_TICKS_PER_SEC)
+
+#define TLB_HASH_TABLE_SIZE 256	/* The size of the clients hash table.
+				 * Note that this value MUST NOT be smaller
+				 * because the key hash table is BYTE wide !
+				 */
+
+
+#define TLB_NULL_INDEX		0xffffffff
+#define MAX_LP_BURST		3
+
+/* rlb defs */
+#define RLB_HASH_TABLE_SIZE	256
+#define RLB_NULL_INDEX		0xffffffff
+#define RLB_UPDATE_DELAY	(2*ALB_TIMER_TICKS_PER_SEC) /* 2 seconds */
+#define RLB_ARP_BURST_SIZE	2
+#define RLB_UPDATE_RETRY	3 /* 3-ticks - must be smaller than the rlb
+				   * rebalance interval (5 min).
+				   */
+/* RLB_PROMISC_TIMEOUT = 10 sec equals the time that the current slave is
+ * promiscuous after failover
+ */
+#define RLB_PROMISC_TIMEOUT	(10*ALB_TIMER_TICKS_PER_SEC)
+
+
 struct tlb_client_info {
 	struct slave *tx_slave;	/* A pointer to slave used for transmiting
 				 * packets to a Client that the Hash function


