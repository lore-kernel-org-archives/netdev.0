From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 7/8] rxrpc: Use rxrpc_is_service_call() rather than
 rxrpc_conn_is_service()
Date: Wed, 07 Sep 2016 16:23:15 +0100
Message-ID: <147326179586.26593.11265361065653876053.stgit@warthog.procyon.org.uk>
References: <147326174610.26593.17043098689515647894.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <147326174610.26593.17043098689515647894.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use rxrpc_is_service_call() rather than rxrpc_conn_is_service() if the call
is available just in case call->conn is NULL.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/input.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/rxrpc/input.c b/net/rxrpc/input.c
index 52da4373131f..8267f42a7753 100644
--- a/net/rxrpc/input.c
+++ b/net/rxrpc/input.c
@@ -357,7 +357,7 @@ void rxrpc_fast_process_packet(struct rxrpc_call *call, struct sk_buff *skb)
 	case RXRPC_PACKET_TYPE_BUSY:
 		_proto("Rx BUSY %%%u", sp->hdr.serial);
 
-		if (rxrpc_conn_is_service(call->conn))
+		if (rxrpc_is_service_call(call))
 			goto protocol_error;
 
 		write_lock_bh(&call->state_lock);
@@ -525,7 +525,7 @@ static void rxrpc_post_packet_to_call(struct rxrpc_connection *conn,
 		default:
 			goto dead_call;
 		case RXRPC_CALL_SUCCEEDED:
-			if (rxrpc_conn_is_service(call->conn))
+			if (rxrpc_is_service_call(call))
 				goto dead_call;
 			goto resend_final_ack;
 		}
