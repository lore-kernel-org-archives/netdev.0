From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] net/rxrpc/ar-connection.c: fix NULL dereference
Date: Fri, 15 Jun 2007 23:45:13 +0200
Message-ID: <20070615214513.GL3588@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Howells <dhowells@redhat.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout.stusta.mhn.de ([141.84.69.5]:36335 "EHLO
	mailhub.stusta.mhn.de" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751269AbXFOVo7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jun 2007 17:44:59 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fixes a NULL dereference spotted by the Coverity checker.

Signed-off-by: Adrian Bunk <bunk@stusta.de>

---

 net/rxrpc/ar-connection.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- linux-2.6.22-rc4-mm2/net/rxrpc/ar-connection.c.old	2007-06-15 23:05:26.000000000 +0200
+++ linux-2.6.22-rc4-mm2/net/rxrpc/ar-connection.c	2007-06-15 23:06:42.000000000 +0200
@@ -200,29 +200,29 @@ static struct rxrpc_connection *rxrpc_al
 	if (conn) {
 		INIT_WORK(&conn->processor, &rxrpc_process_connection);
 		INIT_LIST_HEAD(&conn->bundle_link);
 		conn->calls = RB_ROOT;
 		skb_queue_head_init(&conn->rx_queue);
 		rwlock_init(&conn->lock);
 		spin_lock_init(&conn->state_lock);
 		atomic_set(&conn->usage, 1);
 		conn->debug_id = atomic_inc_return(&rxrpc_debug_id);
 		conn->avail_calls = RXRPC_MAXCALLS;
 		conn->size_align = 4;
 		conn->header_size = sizeof(struct rxrpc_header);
 	}
 
-	_leave(" = %p{%d}", conn, conn->debug_id);
+	_leave(" = %p{%d}", conn, conn ? conn->debug_id : 0);
 	return conn;
 }
 
 /*
  * assign a connection ID to a connection and add it to the transport's
  * connection lookup tree
  * - called with transport client lock held
  */
 static void rxrpc_assign_connection_id(struct rxrpc_connection *conn)
 {
 	struct rxrpc_connection *xconn;
 	struct rb_node *parent, **p;
 	__be32 epoch;
 	u32 real_conn_id;

