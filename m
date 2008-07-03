From: David Miller <davem@davemloft.net>
Subject: [PATCH 15/39]: pkt_sched: Add qdisc_tx_is_noop() helper and use in
 IPV6.
Date: Thu, 03 Jul 2008 00:03:54 -0700 (PDT)
Message-ID: <20080703.000354.07929431.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vinay@linux.vnet.ibm.com, krkumar2@in.ibm.com, mchan@broadcom.com,
	Matheos.Worku@Sun.COM, linux-wireless@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47545
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757483AbYGCHDz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jul 2008 03:03:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This indicates if the NOOP scheduler is what is active
for TX on a given device.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/sch_generic.h |    8 ++++++++
 net/ipv6/addrconf.c       |    5 ++---
 2 files changed, 10 insertions(+), 3 deletions(-)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 9f5e644..bfb05a7 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -212,6 +212,14 @@ static inline bool qdisc_tx_changing(struct net_device *dev)
 	return (txq->qdisc != txq->qdisc_sleeping);
 }
 
+/* Is the device using the noop qdisc?  */
+static inline bool qdisc_tx_is_noop(struct net_device *dev)
+{
+	struct netdev_queue *txq = &dev->tx_queue;
+
+	return (txq->qdisc == &noop_qdisc);
+}
+
 static inline int __qdisc_enqueue_tail(struct sk_buff *skb, struct Qdisc *sch,
 				       struct sk_buff_head *list)
 {
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index e6acb89..6dd8c63 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -224,10 +224,9 @@ const struct in6_addr in6addr_linklocal_allnodes = IN6ADDR_LINKLOCAL_ALLNODES_IN
 const struct in6_addr in6addr_linklocal_allrouters = IN6ADDR_LINKLOCAL_ALLROUTERS_INIT;
 
 /* Check if a valid qdisc is available */
-static inline int addrconf_qdisc_ok(struct net_device *dev)
+static inline bool addrconf_qdisc_ok(struct net_device *dev)
 {
-	struct netdev_queue *txq = &dev->tx_queue;
-	return (txq->qdisc != &noop_qdisc);
+	return !qdisc_tx_is_noop(dev);
 }
 
 /* Check if a route is valid prefix route */
-- 
1.5.6

