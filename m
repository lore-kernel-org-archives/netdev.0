From: David Howells <dhowells@redhat.com>
Subject: [PATCH] RxRPC: Error handling for rxrpc_alloc_connection()
Date: Thu, 21 May 2009 14:20:27 +0100
Message-ID: <20090521132027.12364.63780.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Dan Carpenter <error27@gmail.com>,
	David Howells <dhowells@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:58302 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750946AbZEUNUb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 May 2009 09:20:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <error27@gmail.com>

rxrpc_alloc_connection() doesn't return an error code on failure, it just
returns NULL.  IS_ERR(NULL) is false.

Signed-off-by: Dan Carpenter <error27@gmail.com>
Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/ar-connection.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)


diff --git a/net/rxrpc/ar-connection.c b/net/rxrpc/ar-connection.c
index 0f1218b..67e38a0 100644
--- a/net/rxrpc/ar-connection.c
+++ b/net/rxrpc/ar-connection.c
@@ -343,9 +343,9 @@ static int rxrpc_connect_exclusive(struct rxrpc_sock *rx,
 		/* not yet present - create a candidate for a new connection
 		 * and then redo the check */
 		conn = rxrpc_alloc_connection(gfp);
-		if (IS_ERR(conn)) {
-			_leave(" = %ld", PTR_ERR(conn));
-			return PTR_ERR(conn);
+		if (!conn) {
+			_leave(" = -ENOMEM");
+			return -ENOMEM;
 		}
 
 		conn->trans = trans;
@@ -508,9 +508,9 @@ int rxrpc_connect_call(struct rxrpc_sock *rx,
 		/* not yet present - create a candidate for a new connection and then
 		 * redo the check */
 		candidate = rxrpc_alloc_connection(gfp);
-		if (IS_ERR(candidate)) {
-			_leave(" = %ld", PTR_ERR(candidate));
-			return PTR_ERR(candidate);
+		if (!candidate) {
+			_leave(" = -ENOMEM");
+			return -ENOMEM;
 		}
 
 		candidate->trans = trans;

