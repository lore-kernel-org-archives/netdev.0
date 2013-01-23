From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next] af_key: remove a duplicated skb_orphan()
Date: Wed, 23 Jan 2013 22:52:27 +0800
Message-ID: <1358952747-3772-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:62292 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755364Ab3AWOwo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2013 09:52:44 -0500
Received: by mail-pa0-f51.google.com with SMTP id fb11so4810858pad.24
        for <netdev@vger.kernel.org>; Wed, 23 Jan 2013 06:52:44 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>

skb_set_owner_r() will call skb_orphan(), I don't
see any reason to call it twice.

Cc: Steffen Klassert <steffen.klassert@secunet.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>
Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

---
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
