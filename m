From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [PATCH net-next 5/5] xdp: get tracepoints xdp_exception and
 xdp_redirect in sync
Date: Tue, 22 Aug 2017 22:47:40 +0200
Message-ID: <150343485998.31091.4036615069956176401.stgit@firesoul>
References: <150343479290.31091.8019008896152616977.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.fastabend@gmail.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41090 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752974AbdHVUrl (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 22 Aug 2017 16:47:41 -0400
In-Reply-To: <150343479290.31091.8019008896152616977.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove the net_device string name from the xdp_exception tracepoint,
like the xdp_redirect tracepoint.

Align the TP_STRUCT to have common entries between these two
tracepoint.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---
 include/trace/events/xdp.h |   24 ++++++++++++------------
 1 file changed, 12 insertions(+), 12 deletions(-)

diff --git a/include/trace/events/xdp.h b/include/trace/events/xdp.h
index 7511bed80558..6495b0d9d5c7 100644
--- a/include/trace/events/xdp.h
+++ b/include/trace/events/xdp.h
@@ -31,22 +31,22 @@ TRACE_EVENT(xdp_exception,
 	TP_ARGS(dev, xdp, act),
 
 	TP_STRUCT__entry(
-		__string(name, dev->name)
 		__array(u8, prog_tag, 8)
 		__field(u32, act)
+		__field(int, ifindex)
 	),
 
 	TP_fast_assign(
 		BUILD_BUG_ON(sizeof(__entry->prog_tag) != sizeof(xdp->tag));
 		memcpy(__entry->prog_tag, xdp->tag, sizeof(xdp->tag));
-		__assign_str(name, dev->name);
-		__entry->act = act;
+		__entry->act		= act;
+		__entry->ifindex	= dev->ifindex;
 	),
 
-	TP_printk("prog=%s device=%s action=%s",
+	TP_printk("prog=%s action=%s ifindex=%d",
 		  __print_hex_str(__entry->prog_tag, 8),
-		  __get_str(name),
-		  __print_symbolic(__entry->act, __XDP_ACT_SYM_TAB))
+		  __print_symbolic(__entry->act, __XDP_ACT_SYM_TAB),
+		  __entry->ifindex)
 );
 
 TRACE_EVENT(xdp_redirect,
@@ -57,26 +57,26 @@ TRACE_EVENT(xdp_redirect,
 	TP_ARGS(from_index, to_index, xdp, act, err),
 
 	TP_STRUCT__entry(
-		__field(int, from_index)
-		__field(int, to_index)
 		__array(u8, prog_tag, 8)
 		__field(u32, act)
+		__field(int, from_index)
+		__field(int, to_index)
 		__field(int, err)
 	),
 
 	TP_fast_assign(
 		BUILD_BUG_ON(sizeof(__entry->prog_tag) != sizeof(xdp->tag));
 		memcpy(__entry->prog_tag, xdp->tag, sizeof(xdp->tag));
+		__entry->act		= act;
 		__entry->from_index	= from_index;
 		__entry->to_index	= to_index;
-		__entry->act = act;
-		__entry->err = err;
+		__entry->err		= err;
 	),
 
-	TP_printk("prog=%s from=%d to=%d action=%s err=%d",
+	TP_printk("prog=%s action=%s from=%d to=%d err=%d",
 		  __print_hex_str(__entry->prog_tag, 8),
-		  __entry->from_index, __entry->to_index,
 		  __print_symbolic(__entry->act, __XDP_ACT_SYM_TAB),
+		  __entry->from_index, __entry->to_index,
 		  __entry->err)
 );
 #endif /* _TRACE_XDP_H */
