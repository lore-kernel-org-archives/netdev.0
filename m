From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH net-next] datagram: Remove redundant unlikely()
Date: Tue, 26 Sep 2017 11:21:42 +0200
Message-ID: <20170926092142.21156-1-tklauser@distanz.ch>
Cc: "David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.zhinst.com ([212.126.164.98]:46270 "EHLO mail.zhinst.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S966927AbdIZJVr (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 26 Sep 2017 05:21:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IS_ERR() already implies unlikely(), so it can be omitted.

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 net/core/datagram.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/datagram.c b/net/core/datagram.c
index f7fb7e3f2acf..0b7b4c22719e 100644
--- a/net/core/datagram.c
+++ b/net/core/datagram.c
@@ -188,7 +188,7 @@ struct sk_buff *__skb_try_recv_from_queue(struct sock *sk,
 			}
 			if (!skb->len) {
 				skb = skb_set_peeked(skb);
-				if (unlikely(IS_ERR(skb))) {
+				if (IS_ERR(skb)) {
 					*err = PTR_ERR(skb);
 					return NULL;
 				}
-- 
2.13.0
