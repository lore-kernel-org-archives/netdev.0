From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 09/11] rxrpc: Remove printks from
 rxrpc_recvmsg_data() to fix uninit var
Date: Sun, 18 Sep 2016 00:22:32 +0100
Message-ID: <147415455289.18436.89490438612580520.stgit@warthog.procyon.org.uk>
References: <147415448967.18436.14900942726390485534.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41740 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933894AbcIQXWs (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 17 Sep 2016 19:22:48 -0400
In-Reply-To: <147415448967.18436.14900942726390485534.stgit@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove _enter/_debug/_leave calls from rxrpc_recvmsg_data() of which one
uses an uninitialised variable.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/recvmsg.c |    8 --------
 1 file changed, 8 deletions(-)

diff --git a/net/rxrpc/recvmsg.c b/net/rxrpc/recvmsg.c
index b62a08151895..79e65668bc58 100644
--- a/net/rxrpc/recvmsg.c
+++ b/net/rxrpc/recvmsg.c
@@ -296,8 +296,6 @@ static int rxrpc_recvmsg_data(struct socket *sock, struct rxrpc_call *call,
 	unsigned int rx_pkt_offset, rx_pkt_len;
 	int ix, copy, ret = -EAGAIN, ret2;
 
-	_enter("");
-
 	rx_pkt_offset = call->rx_pkt_offset;
 	rx_pkt_len = call->rx_pkt_len;
 
@@ -343,8 +341,6 @@ static int rxrpc_recvmsg_data(struct socket *sock, struct rxrpc_call *call,
 			trace_rxrpc_recvmsg(call, rxrpc_recvmsg_cont, seq,
 					    rx_pkt_offset, rx_pkt_len, 0);
 		}
-		_debug("recvmsg %x DATA #%u { %d, %d }",
-		       sp->hdr.callNumber, seq, rx_pkt_offset, rx_pkt_len);
 
 		/* We have to handle short, empty and used-up DATA packets. */
 		remain = len - *_offset;
@@ -360,8 +356,6 @@ static int rxrpc_recvmsg_data(struct socket *sock, struct rxrpc_call *call,
 			}
 
 			/* handle piecemeal consumption of data packets */
-			_debug("copied %d @%zu", copy, *_offset);
-
 			rx_pkt_offset += copy;
 			rx_pkt_len -= copy;
 			*_offset += copy;
@@ -370,7 +364,6 @@ static int rxrpc_recvmsg_data(struct socket *sock, struct rxrpc_call *call,
 		if (rx_pkt_len > 0) {
 			trace_rxrpc_recvmsg(call, rxrpc_recvmsg_full, seq,
 					    rx_pkt_offset, rx_pkt_len, 0);
-			_debug("buffer full");
 			ASSERTCMP(*_offset, ==, len);
 			ret = 0;
 			break;
@@ -398,7 +391,6 @@ out:
 done:
 	trace_rxrpc_recvmsg(call, rxrpc_recvmsg_data_return, seq,
 			    rx_pkt_offset, rx_pkt_len, ret);
-	_leave(" = %d [%u/%u]", ret, seq, top);
 	return ret;
 }
 
