From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Subject: [PATCH] net: rxrpc: mark expected switch fall-throughs
Date: Thu, 19 Oct 2017 13:50:16 -0500
Message-ID: <20171019185016.GA18770@embeddedor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-afs@lists.infradead.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        "Gustavo A. R. Silva" <garsilva@embeddedor.com>
To: David Howells <dhowells@redhat.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In preparation to enabling -Wimplicit-fallthrough, mark switch cases
where we are expecting to fall through.

Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>
---
This code was tested by compilation only (GCC 7.2.0 was used).
Please, verify if the actual intention of the code is to fall through.

 net/rxrpc/af_rxrpc.c | 5 +++--
 net/rxrpc/input.c    | 2 +-
 net/rxrpc/sendmsg.c  | 1 +
 3 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/net/rxrpc/af_rxrpc.c b/net/rxrpc/af_rxrpc.c
index fb17552..df4f7d5 100644
--- a/net/rxrpc/af_rxrpc.c
+++ b/net/rxrpc/af_rxrpc.c
@@ -246,6 +246,7 @@ static int rxrpc_listen(struct socket *sock, int backlog)
 			ret = 0;
 			break;
 		}
+		/* fall through */
 	default:
 		ret = -EBUSY;
 		break;
@@ -528,8 +529,7 @@ static int rxrpc_sendmsg(struct socket *sock, struct msghdr *m, size_t len)
 
 		rx->local = local;
 		rx->sk.sk_state = RXRPC_CLIENT_UNBOUND;
-		/* Fall through */
-
+		/* fall through */
 	case RXRPC_CLIENT_UNBOUND:
 	case RXRPC_CLIENT_BOUND:
 		if (!m->msg_name &&
@@ -537,6 +537,7 @@ static int rxrpc_sendmsg(struct socket *sock, struct msghdr *m, size_t len)
 			m->msg_name = &rx->connect_srx;
 			m->msg_namelen = sizeof(rx->connect_srx);
 		}
+		/* fall through */
 	case RXRPC_SERVER_BOUND:
 	case RXRPC_SERVER_LISTENING:
 		ret = rxrpc_do_sendmsg(rx, m, len);
diff --git a/net/rxrpc/input.c b/net/rxrpc/input.c
index e56e23e..8bc6daf 100644
--- a/net/rxrpc/input.c
+++ b/net/rxrpc/input.c
@@ -1125,7 +1125,7 @@ void rxrpc_data_ready(struct sock *udp_sk)
 	case RXRPC_PACKET_TYPE_BUSY:
 		if (sp->hdr.flags & RXRPC_CLIENT_INITIATED)
 			goto discard;
-
+		/* fall through */
 	case RXRPC_PACKET_TYPE_DATA:
 		if (sp->hdr.callNumber == 0)
 			goto bad_message;
diff --git a/net/rxrpc/sendmsg.c b/net/rxrpc/sendmsg.c
index 9ea6f97..d245782 100644
--- a/net/rxrpc/sendmsg.c
+++ b/net/rxrpc/sendmsg.c
@@ -166,6 +166,7 @@ static void rxrpc_queue_packet(struct rxrpc_sock *rx, struct rxrpc_call *call,
 					  ktime_get_real());
 			if (!last)
 				break;
+			/* fall through */
 		case RXRPC_CALL_SERVER_SEND_REPLY:
 			call->state = RXRPC_CALL_SERVER_AWAIT_ACK;
 			rxrpc_notify_end_tx(rx, call, notify_end_tx);
-- 
2.7.4
