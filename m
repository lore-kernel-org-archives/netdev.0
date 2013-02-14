From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 1/7] af_key: remove a duplicated skb_orphan()
Date: Thu, 14 Feb 2013 12:47:21 +0100
Message-ID: <1360842447-3344-2-git-send-email-steffen.klassert@secunet.com>
References: <1360842447-3344-1-git-send-email-steffen.klassert@secunet.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:44522 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759344Ab3BNLrx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Feb 2013 06:47:53 -0500
In-Reply-To: <1360842447-3344-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>

skb_set_owner_r() will call skb_orphan(), I don't
see any reason to call it twice.

Cc: Steffen Klassert <steffen.klassert@secunet.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>
Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/key/af_key.c |    1 -
 1 file changed, 1 deletion(-)

diff --git a/net/key/af_key.c b/net/key/af_key.c
index 5b426a6..6a6e684 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -203,7 +203,6 @@ static int pfkey_broadcast_one(struct sk_buff *skb, struct sk_buff **skb2,
 	}
 	if (*skb2 != NULL) {
 		if (atomic_read(&sk->sk_rmem_alloc) <= sk->sk_rcvbuf) {
-			skb_orphan(*skb2);
 			skb_set_owner_r(*skb2, sk);
 			skb_queue_tail(&sk->sk_receive_queue, *skb2);
 			sk->sk_data_ready(sk, (*skb2)->len);
-- 
1.7.9.5
