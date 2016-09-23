From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 02/15] rxrpc: Don't send an ACK at the end of
 service call response transmission
Date: Fri, 23 Sep 2016 16:15:31 +0100
Message-ID: <147464373148.5090.3988082503120309276.stgit@warthog.procyon.org.uk>
References: <147464371753.5090.1634919599283321856.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <147464371753.5090.1634919599283321856.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Don't send an IDLE ACK at the end of the transmission of the response to a
service call.  The service end resends DATA packets until the client sends an
ACK that hard-acks all the send data.  At that point, the call is complete.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/recvmsg.c |    2 --
 1 file changed, 2 deletions(-)

diff --git a/net/rxrpc/recvmsg.c b/net/rxrpc/recvmsg.c
index 6ba4af5a8d95..99e4c0ae30f1 100644
--- a/net/rxrpc/recvmsg.c
+++ b/net/rxrpc/recvmsg.c
@@ -143,8 +143,6 @@ static void rxrpc_end_rx_phase(struct rxrpc_call *call)
 	if (call->state == RXRPC_CALL_CLIENT_RECV_REPLY) {
 		rxrpc_propose_ACK(call, RXRPC_ACK_IDLE, 0, 0, true, false);
 		rxrpc_send_call_packet(call, RXRPC_PACKET_TYPE_ACK);
-	} else {
-		rxrpc_propose_ACK(call, RXRPC_ACK_IDLE, 0, 0, false, false);
 	}
 
 	write_lock_bh(&call->state_lock);
