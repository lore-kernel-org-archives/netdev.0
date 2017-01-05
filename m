From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 3/3] rxrpc: Show a call's hard-ACK cursors in
 /proc/net/rxrpc_calls
Date: Thu, 05 Jan 2017 14:32:12 +0000
Message-ID: <148362673252.31085.12593422029171316514.stgit@warthog.procyon.org.uk>
References: <148362671062.31085.13249164388796003311.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37518 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1161608AbdAEOcO (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 5 Jan 2017 09:32:14 -0500
In-Reply-To: <148362671062.31085.13249164388796003311.stgit@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Show a call's hard-ACK cursors in /proc/net/rxrpc_calls so that a call's
progress can be more easily monitored.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/proc.c |    9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/net/rxrpc/proc.c b/net/rxrpc/proc.c
index 65cd980767fa..b9bcfbfb095c 100644
--- a/net/rxrpc/proc.c
+++ b/net/rxrpc/proc.c
@@ -52,6 +52,7 @@ static int rxrpc_call_seq_show(struct seq_file *seq, void *v)
 	struct rxrpc_sock *rx;
 	struct rxrpc_peer *peer;
 	struct rxrpc_call *call;
+	rxrpc_seq_t tx_hard_ack, rx_hard_ack;
 	char lbuff[50], rbuff[50];
 
 	if (v == &rxrpc_calls) {
@@ -82,9 +83,11 @@ static int rxrpc_call_seq_show(struct seq_file *seq, void *v)
 	else
 		strcpy(rbuff, "no_connection");
 
+	tx_hard_ack = READ_ONCE(call->tx_hard_ack);
+	rx_hard_ack = READ_ONCE(call->rx_hard_ack);
 	seq_printf(seq,
 		   "UDP   %-47.47s %-47.47s %4x %08x %08x %s %3u"
-		   " %-8.8s %08x %lx\n",
+		   " %-8.8s %08x %lx %08x %02x %08x %02x\n",
 		   lbuff,
 		   rbuff,
 		   call->service_id,
@@ -94,7 +97,9 @@ static int rxrpc_call_seq_show(struct seq_file *seq, void *v)
 		   atomic_read(&call->usage),
 		   rxrpc_call_states[call->state],
 		   call->abort_code,
-		   call->user_call_ID);
+		   call->user_call_ID,
+		   tx_hard_ack, READ_ONCE(call->tx_top) - tx_hard_ack,
+		   rx_hard_ack, READ_ONCE(call->rx_top) - rx_hard_ack);
 
 	return 0;
 }
