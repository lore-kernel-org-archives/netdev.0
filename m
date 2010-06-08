From: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
Subject: [RFC PATCH 3/5] netdev: add tracepoints to netdev layer
Date: Tue, 08 Jun 2010 14:30:08 +0900
Message-ID: <4C0DD560.9040802@jp.fujitsu.com>
References: <4C0DD43F.9090902@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, kaneshige.kenji@jp.fujitsu.com,
	izumi.taku@jp.fujitsu.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fgwmail7.fujitsu.co.jp ([192.51.44.37]:57734 "EHLO
	fgwmail7.fujitsu.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751611Ab0FHF37 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jun 2010 01:29:59 -0400
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o585Tvf5018533
	for <netdev@vger.kernel.org> (envelope-from sanagi.koki@jp.fujitsu.com);
	Tue, 8 Jun 2010 14:29:58 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 7B33B45DE4F
	for <netdev@vger.kernel.org>; Tue,  8 Jun 2010 14:29:57 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 543DC45DE4C
	for <netdev@vger.kernel.org>; Tue,  8 Jun 2010 14:29:57 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 3B5ED1DB8013
	for <netdev@vger.kernel.org>; Tue,  8 Jun 2010 14:29:57 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id E5E2A1DB8012
	for <netdev@vger.kernel.org>; Tue,  8 Jun 2010 14:29:56 +0900 (JST)
In-Reply-To: <4C0DD43F.9090902@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds tracepoint to dev_queue_xmit, dev_hard_start_xmit and
netif_receive_skb.

Signed-off-by: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
---
 include/trace/events/net.h |   84 ++++++++++++++++++++++++++++++++++++++++++++
 net/core/dev.c             |    5 +++
 net/core/net-traces.c      |    1 +
 3 files changed, 90 insertions(+), 0 deletions(-)

diff --git a/include/trace/events/net.h b/include/trace/events/net.h
new file mode 100644
index 0000000..4f82fb5
--- /dev/null
+++ b/include/trace/events/net.h
@@ -0,0 +1,84 @@
+#undef TRACE_SYSTEM
+#define TRACE_SYSTEM net
+
+#if !defined(_TRACE_NET_H) || defined(TRACE_HEADER_MULTI_READ)
+#define _TRACE_NET_H
+
+#include <linux/skbuff.h>
+#include <linux/netdevice.h>
+#include <linux/tracepoint.h>
+
+#define NO_DEV "(no_device)"
+
+TRACE_EVENT(net_dev_xmit,
+
+	TP_PROTO(struct sk_buff *skb,
+		 int rc),
+
+	TP_ARGS(skb, rc),
+
+	TP_STRUCT__entry(
+		__field(	void *,		skbaddr		)
+		__field(	unsigned int,	len		)
+		__field(	int,		rc		)
+		__string(	name,		skb->dev->name	)
+	),
+
+	TP_fast_assign(
+		__entry->skbaddr = skb;
+		__entry->len = skb->len;
+		__entry->rc = rc;
+		__assign_str(name, skb->dev->name);
+	),
+
+	TP_printk("dev=%s skbaddr=%p len=%u rc=%d",
+		__get_str(name), __entry->skbaddr, __entry->len, __entry->rc)
+);
+
+TRACE_EVENT(net_dev_queue,
+
+	TP_PROTO(struct sk_buff *skb),
+
+	TP_ARGS(skb),
+
+	TP_STRUCT__entry(
+		__field(	void *,		skbaddr		)
+		__field(	unsigned int,	len		)
+		__string(	name,		skb->dev->name	)
+	),
+
+	TP_fast_assign(
+		__entry->skbaddr = skb;
+		__entry->len = skb->len;
+		__assign_str(name, skb->dev->name);
+	),
+
+	TP_printk("dev=%s skbaddr=%p len=%u",
+		__get_str(name), __entry->skbaddr, __entry->len)
+);
+
+TRACE_EVENT(net_dev_receive,
+
+	TP_PROTO(struct sk_buff *skb),
+
+	TP_ARGS(skb),
+
+	TP_STRUCT__entry(
+		__field(	void *,		skbaddr		)
+		__field(	unsigned int,	len		)
+		__string(	name,		skb->dev->name	)
+	),
+
+	TP_fast_assign(
+		__entry->skbaddr = skb;
+		__entry->len = skb->len;
+		__assign_str(name, skb->dev->name);
+	),
+
+	TP_printk("dev=%s skbaddr=%p len=%u",
+		__get_str(name), __entry->skbaddr, __entry->len)
+);
+#endif /* _TRACE_NET_H */
+
+/* This part must be outside protection */
+#include <trace/define_trace.h>
diff --git a/net/core/dev.c b/net/core/dev.c
index ec01a59..f7c731b 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -130,6 +130,7 @@
 #include <linux/jhash.h>
 #include <linux/random.h>
 #include <trace/events/napi.h>
+#include <trace/events/net.h>
 #include <linux/pci.h>
 
 #include "net-sysfs.h"
@@ -1926,6 +1927,7 @@ int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
 		}
 
 		rc = ops->ndo_start_xmit(skb, dev);
+		trace_net_dev_xmit(skb, rc);
 		if (rc == NETDEV_TX_OK)
 			txq_trans_update(txq);
 		return rc;
@@ -1946,6 +1948,7 @@ gso:
 			skb_dst_drop(nskb);
 
 		rc = ops->ndo_start_xmit(nskb, dev);
+		trace_net_dev_xmit(nskb, rc);
 		if (unlikely(rc != NETDEV_TX_OK)) {
 			if (rc & ~NETDEV_TX_MASK)
 				goto out_kfree_gso_skb;
@@ -2159,6 +2162,7 @@ int dev_queue_xmit(struct sk_buff *skb)
 	}
 
 gso:
+	trace_net_dev_queue(skb);
 	/* Disable soft irqs for various locks below. Also
 	 * stops preemption for RCU.
 	 */
@@ -2934,6 +2938,7 @@ int netif_receive_skb(struct sk_buff *skb)
 	if (netdev_tstamp_prequeue)
 		net_timestamp_check(skb);
 
+	trace_net_dev_receive(skb);
 #ifdef CONFIG_RPS
 	{
 		struct rps_dev_flow voidflow, *rflow = &voidflow;
diff --git a/net/core/net-traces.c b/net/core/net-traces.c
index afa6380..7f1bb2a 100644
--- a/net/core/net-traces.c
+++ b/net/core/net-traces.c
@@ -26,6 +26,7 @@
 
 #define CREATE_TRACE_POINTS
 #include <trace/events/skb.h>
+#include <trace/events/net.h>
 #include <trace/events/napi.h>
 
 EXPORT_TRACEPOINT_SYMBOL_GPL(kfree_skb);

