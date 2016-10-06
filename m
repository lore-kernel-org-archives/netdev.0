From: David Howells <dhowells@redhat.com>
Subject: [PATCH net 04/13] rxrpc: Only ping for lost reply in client call
Date: Thu, 06 Oct 2016 11:04:24 +0100
Message-ID: <147574826441.30350.14627463660241831415.stgit@warthog.procyon.org.uk>
References: <147574823645.30350.16131031458272035074.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35322 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751711AbcJFKE0 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 6 Oct 2016 06:04:26 -0400
In-Reply-To: <147574823645.30350.16131031458272035074.stgit@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When a reply is deemed lost, we send a ping to find out the other end
received all the request data packets we sent.  This should be limited to
client calls and we shouldn't do this on service calls.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/input.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/rxrpc/input.c b/net/rxrpc/input.c
index 3ad9f75031e3..103d2b0d4690 100644
--- a/net/rxrpc/input.c
+++ b/net/rxrpc/input.c
@@ -847,7 +847,8 @@ static void rxrpc_input_ack(struct rxrpc_call *call, struct sk_buff *skb,
 
 	if (call->rxtx_annotations[call->tx_top & RXRPC_RXTX_BUFF_MASK] &
 	    RXRPC_TX_ANNO_LAST &&
-	    summary.nr_acks == call->tx_top - hard_ack)
+	    summary.nr_acks == call->tx_top - hard_ack &&
+	    rxrpc_is_client_call(call))
 		rxrpc_propose_ACK(call, RXRPC_ACK_PING, skew, sp->hdr.serial,
 				  false, true,
 				  rxrpc_propose_ack_ping_for_lost_reply);
