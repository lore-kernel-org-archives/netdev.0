From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Subject: [PATCH v2] net: rxrpc: mark expected switch fall-throughs
Date: Thu, 19 Oct 2017 16:54:48 -0500
Message-ID: <20171019215448.GA20170@embeddedor.com>
References: <20171019165015.Horde.gFbCP0wQxOy_VCfPCdilo2m@gator4166.hostgator.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-afs@lists.infradead.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        "Gustavo A. R. Silva" <garsilva@embeddedor.com>
To: David Howells <dhowells@redhat.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway34.websitewelcome.com ([192.185.148.119]:19667 "EHLO
        gateway34.websitewelcome.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751855AbdJSVyv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Oct 2017 17:54:51 -0400
Received: from cm16.websitewelcome.com (cm16.websitewelcome.com [100.42.49.19])
        by gateway34.websitewelcome.com (Postfix) with ESMTP id C42262E3923
        for <netdev@vger.kernel.org>; Thu, 19 Oct 2017 16:54:50 -0500 (CDT)
Content-Disposition: inline
In-Reply-To: <20171019165015.Horde.gFbCP0wQxOy_VCfPCdilo2m@gator4166.hostgator.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In preparation to enabling -Wimplicit-fallthrough, mark switch cases
where we are expecting to fall through.

Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>
---
This code was tested by compilation only (GCC 7.2.0 was used).
Please, verify if the actual intention of the code is to fall through.

Changes in v2:
 Start every "Fall through" comment with capital 'F'.
 Put back blank lines.

 net/rxrpc/af_rxrpc.c | 2 ++
 net/rxrpc/input.c    | 1 +
 net/rxrpc/sendmsg.c  | 1 +
 3 files changed, 4 insertions(+)

diff --git a/net/rxrpc/af_rxrpc.c b/net/rxrpc/af_rxrpc.c
index fb17552..73d5665 100644
--- a/net/rxrpc/af_rxrpc.c
+++ b/net/rxrpc/af_rxrpc.c
@@ -246,6 +246,7 @@ static int rxrpc_listen(struct socket *sock, int backlog)
 			ret = 0;
 			break;
 		}
+		/* Fall through */
 	default:
 		ret = -EBUSY;
 		break;
@@ -537,6 +538,7 @@ static int rxrpc_sendmsg(struct socket *sock, struct msghdr *m, size_t len)
 			m->msg_name = &rx->connect_srx;
 			m->msg_namelen = sizeof(rx->connect_srx);
 		}
+		/* Fall through */
 	case RXRPC_SERVER_BOUND:
 	case RXRPC_SERVER_LISTENING:
 		ret = rxrpc_do_sendmsg(rx, m, len);
diff --git a/net/rxrpc/input.c b/net/rxrpc/input.c
index e56e23e..1e37eb1 100644
--- a/net/rxrpc/input.c
+++ b/net/rxrpc/input.c
@@ -1125,6 +1125,7 @@ void rxrpc_data_ready(struct sock *udp_sk)
 	case RXRPC_PACKET_TYPE_BUSY:
 		if (sp->hdr.flags & RXRPC_CLIENT_INITIATED)
 			goto discard;
+		/* Fall through */
 
 	case RXRPC_PACKET_TYPE_DATA:
 		if (sp->hdr.callNumber == 0)
diff --git a/net/rxrpc/sendmsg.c b/net/rxrpc/sendmsg.c
index 9ea6f97..dbe0c4d 100644
--- a/net/rxrpc/sendmsg.c
+++ b/net/rxrpc/sendmsg.c
@@ -166,6 +166,7 @@ static void rxrpc_queue_packet(struct rxrpc_sock *rx, struct rxrpc_call *call,
 					  ktime_get_real());
 			if (!last)
 				break;
+			/* Fall through */
 		case RXRPC_CALL_SERVER_SEND_REPLY:
 			call->state = RXRPC_CALL_SERVER_AWAIT_ACK;
 			rxrpc_notify_end_tx(rx, call, notify_end_tx);
-- 
2.7.4
