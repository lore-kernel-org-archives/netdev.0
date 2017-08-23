From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [V2 PATCH net-next 5/5] xdp: get tracepoints xdp_exception and
 xdp_redirect in sync
Date: Wed, 23 Aug 2017 12:15:40 +0200
Message-ID: <150348334039.23476.16866879022276856834.stgit@firesoul>
References: <150348327373.23476.14851572406177222309.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <borkmann@iogearbox.net>,
        John Fastabend <john.fastabend@gmail.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60342 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753651AbdHWKPl (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 23 Aug 2017 06:15:41 -0400
In-Reply-To: <150348327373.23476.14851572406177222309.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove the net_device string name from the xdp_exception tracepoint,
like the xdp_redirect tracepoint.

Align the TP_STRUCT to have common entries between these two
tracepoint.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---
 include/trace/events/xdp.h |   12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/include/trace/events/xdp.h b/include/trace/events/xdp.h
index cd37706c6f55..27cf2ef35f5f 100644
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
