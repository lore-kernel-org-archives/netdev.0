From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH net-next 1/2] sunvnet: Add support for perf LDC event tracing
Date: Tue,  2 Feb 2016 10:41:55 -0800
Message-ID: <155b14db75343d6e08596606dbcdaf459cb9efe3.1454416592.git.sowmini.varadhan@oracle.com>
References: <cover.1454416592.git.sowmini.varadhan@oracle.com>
Cc: davem@davemloft.net, sowmini.varadhan@oracle.com,
	david.stevens@oracle.com, aaron.young@oracle.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:30399 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753357AbcBBSmh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Feb 2016 13:42:37 -0500
In-Reply-To: <cover.1454416592.git.sowmini.varadhan@oracle.com>
In-Reply-To: <cover.1454416592.git.sowmini.varadhan@oracle.com>
References: <cover.1454416592.git.sowmini.varadhan@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add perf event macros for support of tracing and instrumentation
of LDC state machine

Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
---
 include/trace/events/sunvnet.h |  139 ++++++++++++++++++++++++++++++++++++++++
 1 files changed, 139 insertions(+), 0 deletions(-)
 create mode 100644 include/trace/events/sunvnet.h

diff --git a/include/trace/events/sunvnet.h b/include/trace/events/sunvnet.h
new file mode 100644
index 0000000..eb080b2
--- /dev/null
+++ b/include/trace/events/sunvnet.h
@@ -0,0 +1,139 @@
+#undef TRACE_SYSTEM
+#define TRACE_SYSTEM sunvnet
+
+#if !defined(_TRACE_SUNVNET_H) || defined(TRACE_HEADER_MULTI_READ)
+#define _TRACE_SUNVNET_H
+
+#include <linux/tracepoint.h>
+
+TRACE_EVENT(vnet_rx_one,
+
+	TP_PROTO(int lsid, int rsid, int index, int needs_ack),
+
+	TP_ARGS(lsid, rsid, index, needs_ack),
+
+	TP_STRUCT__entry(
+		__field(int, lsid)
+		__field(int, rsid)
+		__field(int, index)
+		__field(int, needs_ack)
+	),
+
+	TP_fast_assign(
+		__entry->lsid = lsid;
+		__entry->rsid = rsid;
+		__entry->index = index;
+		__entry->needs_ack = needs_ack;
+	),
+
+	TP_printk("(%x:%x) walk_rx_one index %d; needs_ack %d",
+		__entry->lsid, __entry->rsid,
+		__entry->index, __entry->needs_ack)
+);
+
+DECLARE_EVENT_CLASS(vnet_tx_stopped_ack_template,
+
+	TP_PROTO(int lsid, int rsid, int ack_end, int npkts),
+
+	TP_ARGS(lsid, rsid, ack_end, npkts),
+
+	TP_STRUCT__entry(
+		__field(int, lsid)
+		__field(int, rsid)
+		__field(int, ack_end)
+		__field(int, npkts)
+	),
+
+	TP_fast_assign(
+		__entry->lsid = lsid;
+		__entry->rsid = rsid;
+		__entry->ack_end = ack_end;
+		__entry->npkts = npkts;
+	),
+
+	TP_printk("(%x:%x) stopped ack for %d; npkts %d",
+		__entry->lsid, __entry->rsid,
+		__entry->ack_end, __entry->npkts)
+);
+DEFINE_EVENT(vnet_tx_stopped_ack_template, vnet_tx_send_stopped_ack,
+	     TP_PROTO(int lsid, int rsid, int ack_end, int npkts),
+	     TP_ARGS(lsid, rsid, ack_end, npkts));
+DEFINE_EVENT(vnet_tx_stopped_ack_template, vnet_tx_defer_stopped_ack,
+	     TP_PROTO(int lsid, int rsid, int ack_end, int npkts),
+	     TP_ARGS(lsid, rsid, ack_end, npkts));
+DEFINE_EVENT(vnet_tx_stopped_ack_template, vnet_tx_pending_stopped_ack,
+	     TP_PROTO(int lsid, int rsid, int ack_end, int npkts),
+	     TP_ARGS(lsid, rsid, ack_end, npkts));
+
+TRACE_EVENT(vnet_rx_stopped_ack,
+
+	TP_PROTO(int lsid, int rsid, int end),
+
+	TP_ARGS(lsid, rsid, end),
+
+	TP_STRUCT__entry(
+		__field(int, lsid)
+		__field(int, rsid)
+		__field(int, end)
+	),
+
+	TP_fast_assign(
+		__entry->lsid = lsid;
+		__entry->rsid = rsid;
+		__entry->end = end;
+	),
+
+	TP_printk("(%x:%x) stopped ack for index %d",
+		__entry->lsid, __entry->rsid, __entry->end)
+);
+
+TRACE_EVENT(vnet_tx_trigger,
+
+	TP_PROTO(int lsid, int rsid, int start, int err),
+
+	TP_ARGS(lsid, rsid, start, err),
+
+	TP_STRUCT__entry(
+		__field(int, lsid)
+		__field(int, rsid)
+		__field(int, start)
+		__field(int, err)
+	),
+
+	TP_fast_assign(
+		__entry->lsid = lsid;
+		__entry->rsid = rsid;
+		__entry->start = start;
+		__entry->err = err;
+	),
+
+	TP_printk("(%x:%x) Tx trigger for %d sent with err %d %s",
+		__entry->lsid, __entry->rsid, __entry->start,
+		__entry->err, __entry->err > 0 ? "(ok)" : " ")
+);
+
+TRACE_EVENT(vnet_skip_tx_trigger,
+
+	TP_PROTO(int lsid, int rsid, int last),
+
+	TP_ARGS(lsid, rsid, last),
+
+	TP_STRUCT__entry(
+		__field(int, lsid)
+		__field(int, rsid)
+		__field(int, last)
+	),
+
+	TP_fast_assign(
+		__entry->lsid = lsid;
+		__entry->rsid = rsid;
+		__entry->last = last;
+	),
+
+	TP_printk("(%x:%x) Skip Tx trigger. Last trigger sent was %d",
+		__entry->lsid, __entry->rsid, __entry->last)
+);
+#endif /* _TRACE_SOCK_H */
+
+/* This part must be outside protection */
+#include <trace/define_trace.h>
-- 
1.7.1
