From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [Patch 2/5] Network Drop Monitor: Add trace declaration for
	skb frees
Date: Wed, 11 Mar 2009 15:48:26 -0400
Message-ID: <20090311194826.GB20223@hmsreliant.think-freely.org>
References: <20090303170146.GC1480@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	nhorman@tuxdriver.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:59372 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753406AbZCKTsk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2009 15:48:40 -0400
Content-Disposition: inline
In-Reply-To: <20090303170146.GC1480@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 03, 2009 at 12:01:46PM -0500, Neil Horman wrote:
> 
As requested, respinning this patch set against latest net-next tree,

Modification notes:

None, simple respin

Neil


Network Drop Monitor: Add trace declaration for skb frees

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>


 include/trace/skb.h   |    8 ++++++++
 net/core/Makefile     |    2 ++
 net/core/net-traces.c |   29 +++++++++++++++++++++++++++++
 3 files changed, 39 insertions(+)


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
index 26a37cb..d47092b 100644
--- a/net/core/Makefile
+++ b/net/core/Makefile
@@ -17,3 +17,5 @@ obj-$(CONFIG_NET_PKTGEN) += pktgen.o
 obj-$(CONFIG_NETPOLL) += netpoll.o
 obj-$(CONFIG_NET_DMA) += user_dma.o
 obj-$(CONFIG_FIB_RULES) += fib_rules.o
+obj-$(CONFIG_TRACEPOINTS) += net-traces.o
+
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
