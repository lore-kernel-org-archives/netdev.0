From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [PATCH net-next 3/7] xdp: make xdp tracepoints report bpf prog id
 instead of prog_tag
Date: Tue, 29 Aug 2017 16:37:51 +0200
Message-ID: <150401747100.16384.15817946207152599341.stgit@firesoul>
References: <150401743083.16384.15778781741742858567.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.fastabend@gmail.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57306 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752746AbdH2Ohz (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 29 Aug 2017 10:37:55 -0400
In-Reply-To: <150401743083.16384.15778781741742858567.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Given previous patch expose the map_id, it seems natural to also
report the bpf prog id.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---
 include/trace/events/xdp.h |   18 ++++++++----------
 1 file changed, 8 insertions(+), 10 deletions(-)

diff --git a/include/trace/events/xdp.h b/include/trace/events/xdp.h
index 573dcfa1aeaa..89eba564e199 100644
--- a/include/trace/events/xdp.h
+++ b/include/trace/events/xdp.h
@@ -31,20 +31,19 @@ TRACE_EVENT(xdp_exception,
 	TP_ARGS(dev, xdp, act),
 
 	TP_STRUCT__entry(
-		__array(u8, prog_tag, 8)
+		__field(int, prog_id)
 		__field(u32, act)
 		__field(int, ifindex)
 	),
 
 	TP_fast_assign(
-		BUILD_BUG_ON(sizeof(__entry->prog_tag) != sizeof(xdp->tag));
-		memcpy(__entry->prog_tag, xdp->tag, sizeof(xdp->tag));
+		__entry->prog_id	= xdp->aux->id;
 		__entry->act		= act;
 		__entry->ifindex	= dev->ifindex;
 	),
 
-	TP_printk("prog=%s action=%s ifindex=%d",
-		  __print_hex_str(__entry->prog_tag, 8),
+	TP_printk("prog_id=%d action=%s ifindex=%d",
+		  __entry->prog_id,
 		  __print_symbolic(__entry->act, __XDP_ACT_SYM_TAB),
 		  __entry->ifindex)
 );
@@ -59,7 +58,7 @@ DECLARE_EVENT_CLASS(xdp_redirect_template,
 	TP_ARGS(dev, xdp, to_ifindex, err, map, map_index),
 
 	TP_STRUCT__entry(
-		__array(u8, prog_tag, 8)
+		__field(int, prog_id)
 		__field(u32, act)
 		__field(int, ifindex)
 		__field(int, err)
@@ -69,8 +68,7 @@ DECLARE_EVENT_CLASS(xdp_redirect_template,
 	),
 
 	TP_fast_assign(
-		BUILD_BUG_ON(sizeof(__entry->prog_tag) != sizeof(xdp->tag));
-		memcpy(__entry->prog_tag, xdp->tag, sizeof(xdp->tag));
+		__entry->prog_id	= xdp->aux->id;
 		__entry->act		= XDP_REDIRECT;
 		__entry->ifindex	= dev->ifindex;
 		__entry->err		= err;
@@ -79,9 +77,9 @@ DECLARE_EVENT_CLASS(xdp_redirect_template,
 		__entry->map_index	= map_index;
 	),
 
-	TP_printk("prog=%s action=%s ifindex=%d to_ifindex=%d err=%d"
+	TP_printk("prog_id=%d action=%s ifindex=%d to_ifindex=%d err=%d"
 		  " map_id=%d map_index=%d",
-		  __print_hex_str(__entry->prog_tag, 8),
+		  __entry->prog_id,
 		  __print_symbolic(__entry->act, __XDP_ACT_SYM_TAB),
 		  __entry->ifindex, __entry->to_ifindex,
 		  __entry->err,
