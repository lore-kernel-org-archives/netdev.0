From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Subject: [PATCH] net: rxrpc: call_object: use BUG_ON instead of if condition
 followed by BUG
Date: Mon, 23 Oct 2017 13:13:39 -0500
Message-ID: <20171023181339.GA25304@embeddedor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        "Gustavo A. R. Silva" <garsilva@embeddedor.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use BUG_ON instead of if condition followed by BUG in rxrpc_release_call.

This issue was detected with the help of Coccinelle.

Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>
---
 net/rxrpc/call_object.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/rxrpc/call_object.c b/net/rxrpc/call_object.c
index fcdd655..b4b1a63 100644
--- a/net/rxrpc/call_object.c
+++ b/net/rxrpc/call_object.c
@@ -457,8 +457,7 @@ void rxrpc_release_call(struct rxrpc_sock *rx, struct rxrpc_call *call)
 	ASSERTCMP(call->state, ==, RXRPC_CALL_COMPLETE);
 
 	spin_lock_bh(&call->lock);
-	if (test_and_set_bit(RXRPC_CALL_RELEASED, &call->flags))
-		BUG();
+	BUG_ON(test_and_set_bit(RXRPC_CALL_RELEASED, &call->flags));
 	spin_unlock_bh(&call->lock);
 
 	del_timer_sync(&call->timer);
-- 
2.7.4
