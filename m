From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Subject: [PATCH] rxrpc: call_accept: use BUG_ON instead of if condition
 followed by BUG
Date: Tue, 24 Oct 2017 11:23:08 -0500
Message-ID: <20171024162308.GA29436@embeddedor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        "Gustavo A. R. Silva" <garsilva@embeddedor.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use BUG_ON instead of if condition followed by BUG.

This issue was detected with the help of Coccinelle.

Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>
---
 net/rxrpc/call_accept.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/net/rxrpc/call_accept.c b/net/rxrpc/call_accept.c
index cbd1701..1fd270f 100644
--- a/net/rxrpc/call_accept.c
+++ b/net/rxrpc/call_accept.c
@@ -387,8 +387,7 @@ struct rxrpc_call *rxrpc_new_incoming_call(struct rxrpc_local *local,
 	 * event and userspace is prevented from doing so until the state is
 	 * appropriate.
 	 */
-	if (!mutex_trylock(&call->user_mutex))
-		BUG();
+	BUG_ON(!mutex_trylock(&call->user_mutex));
 
 	/* Make the call live. */
 	rxrpc_incoming_call(rx, call, skb);
@@ -543,8 +542,7 @@ struct rxrpc_call *rxrpc_accept_call(struct rxrpc_sock *rx,
 	rxrpc_get_call(call, rxrpc_call_got_userid);
 	rb_link_node(&call->sock_node, parent, pp);
 	rb_insert_color(&call->sock_node, &rx->calls);
-	if (test_and_set_bit(RXRPC_CALL_HAS_USERID, &call->flags))
-		BUG();
+	BUG_ON(test_and_set_bit(RXRPC_CALL_HAS_USERID, &call->flags));
 
 	write_unlock_bh(&call->state_lock);
 	write_unlock(&rx->call_lock);
-- 
2.7.4
