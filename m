From: David Howells <dhowells@redhat.com>
Subject: [PATCH net 2/4] rxrpc: Fix checker warning by not passing
 always-zero value to ERR_PTR()
Date: Thu, 13 Oct 2016 17:12:24 +0100
Message-ID: <147637514401.17348.5521876451693174745.stgit@warthog.procyon.org.uk>
References: <147637512988.17348.9857198849984467857.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        dan.carpenter@oracle.com, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39320 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756049AbcJMQVm (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 13 Oct 2016 12:21:42 -0400
In-Reply-To: <147637512988.17348.9857198849984467857.stgit@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix the following checker warning:

	net/rxrpc/call_object.c:279 rxrpc_new_client_call()
	warn: passing zero to 'ERR_PTR'

where a value that's always zero is passed to ERR_PTR() so that it can be
passed to a tracepoint in an auxiliary pointer field.

Just pass NULL instead to the tracepoint.

Fixes: a84a46d73050 ("rxrpc: Add some additional call tracing")
Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/call_object.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/rxrpc/call_object.c b/net/rxrpc/call_object.c
index 4353a29f3b57..1ed18d8c9c9f 100644
--- a/net/rxrpc/call_object.c
+++ b/net/rxrpc/call_object.c
@@ -276,7 +276,7 @@ struct rxrpc_call *rxrpc_new_client_call(struct rxrpc_sock *rx,
 		goto error;
 
 	trace_rxrpc_call(call, rxrpc_call_connected, atomic_read(&call->usage),
-			 here, ERR_PTR(ret));
+			 here, NULL);
 
 	spin_lock_bh(&call->conn->params.peer->lock);
 	hlist_add_head(&call->error_link,
