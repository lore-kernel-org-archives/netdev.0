From: David Howells <dhowells@redhat.com>
Subject: [PATCH 7/9] rxrpc: Don't assume transport address family and size
 when using it
Date: Thu, 07 Apr 2016 17:23:44 +0100
Message-ID: <20160407162344.21283.13396.stgit@warthog.procyon.org.uk>
References: <20160407162256.21283.47849.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linux-afs@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50956 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932233AbcDGQXq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Apr 2016 12:23:46 -0400
In-Reply-To: <20160407162256.21283.47849.stgit@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Don't assume transport address family and size when using the peer address
to send a packet.  Instead, use the start of the transport address rather
than any particular element of the union and use the transport address
length noted inside the sockaddr_rxrpc struct.

This will be necessary when IPv6 support is introduced.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/ar-ack.c       |    4 ++--
 net/rxrpc/ar-connevent.c |    4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/rxrpc/ar-ack.c b/net/rxrpc/ar-ack.c
index d0eb98e1391c..3cd9264806a4 100644
--- a/net/rxrpc/ar-ack.c
+++ b/net/rxrpc/ar-ack.c
@@ -833,8 +833,8 @@ void rxrpc_process_call(struct work_struct *work)
 
 	/* there's a good chance we're going to have to send a message, so set
 	 * one up in advance */
-	msg.msg_name	= &call->conn->trans->peer->srx.transport.sin;
-	msg.msg_namelen	= sizeof(call->conn->trans->peer->srx.transport.sin);
+	msg.msg_name	= &call->conn->trans->peer->srx.transport;
+	msg.msg_namelen	= call->conn->trans->peer->srx.transport_len;
 	msg.msg_control	= NULL;
 	msg.msg_controllen = 0;
 	msg.msg_flags	= 0;
diff --git a/net/rxrpc/ar-connevent.c b/net/rxrpc/ar-connevent.c
index 4dc6ab81fd2f..291522392ac7 100644
--- a/net/rxrpc/ar-connevent.c
+++ b/net/rxrpc/ar-connevent.c
@@ -86,8 +86,8 @@ static int rxrpc_abort_connection(struct rxrpc_connection *conn,
 
 	rxrpc_abort_calls(conn, RXRPC_CALL_LOCALLY_ABORTED, abort_code);
 
-	msg.msg_name	= &conn->trans->peer->srx.transport.sin;
-	msg.msg_namelen	= sizeof(conn->trans->peer->srx.transport.sin);
+	msg.msg_name	= &conn->trans->peer->srx.transport;
+	msg.msg_namelen	= conn->trans->peer->srx.transport_len;
 	msg.msg_control	= NULL;
 	msg.msg_controllen = 0;
 	msg.msg_flags	= 0;
