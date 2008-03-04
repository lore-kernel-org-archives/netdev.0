From: akpm@linux-foundation.org
Subject: [patch (for 2.6.25?) 2/2] RxRPC: fix rxrpc_recvmsg()'s returning of msg_name
Date: Tue, 04 Mar 2008 14:56:49 -0800
Message-ID: <200803042256.m24Muogl001357@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	dhowells@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:38176 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1761494AbYCDW7V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2008 17:59:21 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Howells <dhowells@redhat.com>

Fix rxrpc_recvmsg() to return msg_name correctly.  We shouldn't overwrite the
*msg struct, but should rather write into msg->msg_name (there's a '&' unary
operator that shouldn't be there).

Signed-off-by: David Howells <dhowells@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 net/rxrpc/ar-recvmsg.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff -puN net/rxrpc/ar-recvmsg.c~rxrpc-fix-rxrpc_recvmsgs-returning-of-msg_name net/rxrpc/ar-recvmsg.c
--- a/net/rxrpc/ar-recvmsg.c~rxrpc-fix-rxrpc_recvmsgs-returning-of-msg_name
+++ a/net/rxrpc/ar-recvmsg.c
@@ -143,7 +143,8 @@ int rxrpc_recvmsg(struct kiocb *iocb, st
 		/* copy the peer address and timestamp */
 		if (!continue_call) {
 			if (msg->msg_name && msg->msg_namelen > 0)
-				memcpy(&msg->msg_name, &call->conn->trans->peer->srx,
+				memcpy(msg->msg_name,
+				       &call->conn->trans->peer->srx,
 				       sizeof(call->conn->trans->peer->srx));
 			sock_recv_timestamp(msg, &rx->sk, skb);
 		}
_
