From: Neil Horman <nhorman@tuxdriver.com>
Subject: [Patch 2/5] Network Drop Monitor: Add trace declaration for skb
	frees
Date: Tue, 3 Mar 2009 12:01:46 -0500
Message-ID: <20090303170146.GC1480@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nhorman@tuxdriver.com, davem@davemloft.net, kuznet@ms2.inr.ac.ru,
	pekkas@netcore.fi, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:52396 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752020AbZCCRBz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Mar 2009 12:01:55 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Network Drop Monitor: Add trace declaration for skb frees
Signed-off-by: Neil Horman <nhorman@tuxdriver.com>


 include/trace/skb.h   |    8 ++++++++
 net/core/Makefile     |    1 +
 net/core/net-traces.c |   29 +++++++++++++++++++++++++++++
 3 files changed, 38 insertions(+)

diff --git a/include/trace/skb.h b/include/trace/skb.h
new file mode 100644
index 0000000..3aa8646
--- /dev/null
+++ b/include/trace/skb.h
@@ -0,0 +1,8 @@
+#ifndef _TRACE_SKB_H_
+#define _TRACE_SKB_H_
+
+DECLARE_TRACE(kfree_skb,
+	TPPROTO(struct sk_buff *skb, void *location),
+	TPARGS(skb, location));
+
+#endif
diff --git a/net/core/Makefile b/net/core/Makefile
index 26a37cb..9187054 100644
--- a/net/core/Makefile
+++ b/net/core/Makefile
@@ -17,3 +17,4 @@ obj-$(CONFIG_NET_PKTGEN) += pktgen.o
 obj-$(CONFIG_NETPOLL) += netpoll.o
 obj-$(CONFIG_NET_DMA) += user_dma.o
 obj-$(CONFIG_FIB_RULES) += fib_rules.o
+obj-$(CONFIG_TRACEPOINTS) += net-traces.o
diff --git a/net/core/net-traces.c b/net/core/net-traces.c
new file mode 100644
index 0000000..abb165b
--- /dev/null
+++ b/net/core/net-traces.c
@@ -0,0 +1,29 @@
+/*
+ * consolidates trace point definitions 
+ *
+ * Copyright (C) 2009 Neil Horman <nhorman@tuxdriver.com> 
+ */
+
+#include <linux/netdevice.h>
+#include <linux/etherdevice.h>
+#include <linux/string.h>
+#include <linux/if_arp.h>
+#include <linux/inetdevice.h>
+#include <linux/inet.h>
+#include <linux/interrupt.h>
+#include <linux/netpoll.h>
+#include <linux/sched.h>
+#include <linux/delay.h>
+#include <linux/rcupdate.h>
+#include <linux/types.h>
+#include <linux/workqueue.h>
+#include <linux/netlink.h>
+#include <linux/net_dropmon.h>
+#include <trace/skb.h>
+
+#include <asm/unaligned.h>
+#include <asm/bitops.h>
+
+
+DEFINE_TRACE(kfree_skb);
+EXPORT_TRACEPOINT_SYMBOL_GPL(kfree_skb);
