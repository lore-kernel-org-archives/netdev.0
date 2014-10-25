From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH 1/1 net-next] xfrm: fix set but not used warning in xfrm_policy_queue_process()
Date: Sat, 25 Oct 2014 17:27:09 +0200
Message-ID: <1414250829-17908-1-git-send-email-fabf@skynet.be>
Cc: Fabian Frederick <fabf@skynet.be>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

err was set but unused.

Signed-off-by: Fabian Frederick <fabf@skynet.be>
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
1.9.3
