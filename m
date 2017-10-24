From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Subject: [PATCH] rxrpc: recvmsg: use BUG_ON instead of if condition followed
 by BUG
Date: Tue, 24 Oct 2017 11:20:04 -0500
Message-ID: <20171024162004.GA29376@embeddedor.com>
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
 net/rxrpc/recvmsg.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/net/rxrpc/recvmsg.c b/net/rxrpc/recvmsg.c
index bdece21..9598b92 100644
--- a/net/rxrpc/recvmsg.c
+++ b/net/rxrpc/recvmsg.c
@@ -243,8 +243,7 @@ static int rxrpc_verify_packet(struct rxrpc_call *call, struct sk_buff *skb,
 	 */
 	if ((annotation & RXRPC_RX_ANNO_JUMBO) > 1) {
 		__be16 tmp;
-		if (skb_copy_bits(skb, offset - 2, &tmp, 2) < 0)
-			BUG();
+		BUG_ON(skb_copy_bits(skb, offset - 2, &tmp, 2) < 0);
 		cksum = ntohs(tmp);
 		seq += (annotation & RXRPC_RX_ANNO_JUMBO) - 1;
 	}
@@ -503,8 +502,7 @@ int rxrpc_recvmsg(struct socket *sock, struct msghdr *msg, size_t len,
 
 	release_sock(&rx->sk);
 
-	if (test_bit(RXRPC_CALL_RELEASED, &call->flags))
-		BUG();
+	BUG_ON(test_bit(RXRPC_CALL_RELEASED, &call->flags));
 
 	if (test_bit(RXRPC_CALL_HAS_USERID, &call->flags)) {
 		if (flags & MSG_CMSG_COMPAT) {
-- 
2.7.4
