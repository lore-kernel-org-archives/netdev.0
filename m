From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 01/11] rxrpc: Print the packet type name in the Rx
 packet trace
Date: Sun, 18 Sep 2016 00:21:36 +0100
Message-ID: <147415449680.18436.117429481882450572.stgit@warthog.procyon.org.uk>
References: <147415448967.18436.14900942726390485534.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44278 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754787AbcIQXVi (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 17 Sep 2016 19:21:38 -0400
In-Reply-To: <147415448967.18436.14900942726390485534.stgit@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Print a symbolic packet type name for each valid received packet in the
trace output, not just a number.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 include/trace/events/rxrpc.h |    5 +++--
 net/rxrpc/ar-internal.h      |    6 +++---
 2 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/include/trace/events/rxrpc.h b/include/trace/events/rxrpc.h
index ea3b10ed91a8..0a30c673509c 100644
--- a/include/trace/events/rxrpc.h
+++ b/include/trace/events/rxrpc.h
@@ -93,11 +93,12 @@ TRACE_EVENT(rxrpc_rx_packet,
 		    memcpy(&__entry->hdr, &sp->hdr, sizeof(__entry->hdr));
 			   ),
 
-	    TP_printk("%08x:%08x:%08x:%04x %08x %08x %02x %02x",
+	    TP_printk("%08x:%08x:%08x:%04x %08x %08x %02x %02x %s",
 		      __entry->hdr.epoch, __entry->hdr.cid,
 		      __entry->hdr.callNumber, __entry->hdr.serviceId,
 		      __entry->hdr.serial, __entry->hdr.seq,
-		      __entry->hdr.type, __entry->hdr.flags)
+		      __entry->hdr.type, __entry->hdr.flags,
+		      __entry->hdr.type <= 15 ? rxrpc_pkts[__entry->hdr.type] : "?UNK")
 	    );
 
 TRACE_EVENT(rxrpc_rx_done,
diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index e78c40b37db5..0f6fafa2c271 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -551,6 +551,9 @@ enum rxrpc_call_trace {
 
 extern const char rxrpc_call_traces[rxrpc_call__nr_trace][4];
 
+extern const char *const rxrpc_pkts[];
+extern const char *rxrpc_acks(u8 reason);
+
 #include <trace/events/rxrpc.h>
 
 /*
@@ -851,11 +854,8 @@ extern unsigned int rxrpc_rx_mtu;
 extern unsigned int rxrpc_rx_jumbo_max;
 extern unsigned int rxrpc_resend_timeout;
 
-extern const char *const rxrpc_pkts[];
 extern const s8 rxrpc_ack_priority[];
 
-extern const char *rxrpc_acks(u8 reason);
-
 /*
  * output.c
  */
