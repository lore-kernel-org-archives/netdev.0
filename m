From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 4/8] rxrpc: Use call->peer rather than
 call->conn->params.peer
Date: Wed, 07 Sep 2016 16:22:54 +0100
Message-ID: <147326177470.26593.5236224443295221904.stgit@warthog.procyon.org.uk>
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

Use call->peer rather than call->conn->params.peer to avoid the possibility
of call->conn being NULL and, whilst we're at it, check it for NULL before we
access it.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/call_object.c |    8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/net/rxrpc/call_object.c b/net/rxrpc/call_object.c
index 3166b5222435..060ddc32a85e 100644
--- a/net/rxrpc/call_object.c
+++ b/net/rxrpc/call_object.c
@@ -514,9 +514,11 @@ void rxrpc_release_call(struct rxrpc_call *call)
 	 */
 	_debug("RELEASE CALL %p (%d CONN %p)", call, call->debug_id, conn);
 
-	spin_lock(&conn->params.peer->lock);
-	hlist_del_init(&call->error_link);
-	spin_unlock(&conn->params.peer->lock);
+	if (call->peer) {
+		spin_lock(&call->peer->lock);
+		hlist_del_init(&call->error_link);
+		spin_unlock(&call->peer->lock);
+	}
 
 	write_lock_bh(&rx->call_lock);
 	if (!list_empty(&call->accept_link)) {
