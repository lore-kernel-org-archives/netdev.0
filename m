From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 1/5] xfrm: fix set but not used warning in xfrm_policy_queue_process()
Date: Wed, 3 Dec 2014 11:04:57 +0100
Message-ID: <1417601101-18625-2-git-send-email-steffen.klassert@secunet.com>
References: <1417601101-18625-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:33466 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751717AbaLCKFg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Dec 2014 05:05:36 -0500
In-Reply-To: <1417601101-18625-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabian Frederick <fabf@skynet.be>

err was set but unused.

Signed-off-by: Fabian Frederick <fabf@skynet.be>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/xfrm/xfrm_policy.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 4c4e457..dc65324 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1878,7 +1878,6 @@ xfrm_resolve_and_create_bundle(struct xfrm_policy **pols, int num_pols,
 
 static void xfrm_policy_queue_process(unsigned long arg)
 {
-	int err = 0;
 	struct sk_buff *skb;
 	struct sock *sk;
 	struct dst_entry *dst;
@@ -1941,7 +1940,7 @@ static void xfrm_policy_queue_process(unsigned long arg)
 		skb_dst_drop(skb);
 		skb_dst_set(skb, dst);
 
-		err = dst_output(skb);
+		dst_output(skb);
 	}
 
 out:
-- 
1.9.1
