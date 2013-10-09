From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 1/7] xfrm: Fix replay size checking on async events
Date: Wed,  9 Oct 2013 12:59:05 +0200
Message-ID: <1381316351-14418-2-git-send-email-steffen.klassert@secunet.com>
References: <1381316351-14418-1-git-send-email-steffen.klassert@secunet.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:51331 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756921Ab3JIK72 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Oct 2013 06:59:28 -0400
In-Reply-To: <1381316351-14418-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We pass the wrong netlink attribute to xfrm_replay_verify_len().
It should be XFRMA_REPLAY_ESN_VAL and not XFRMA_REPLAY_VAL as
we currently doing. This causes memory corruptions if the
replay esn attribute has incorrect length. Fix this by passing
the right attribute to xfrm_replay_verify_len().

Reported-by: Michael Rossberg <michael.rossberg@tu-ilmenau.de>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/xfrm/xfrm_user.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 3f565e4..4b26cee 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -1856,7 +1856,7 @@ static int xfrm_new_ae(struct sk_buff *skb, struct nlmsghdr *nlh,
 	if (x->km.state != XFRM_STATE_VALID)
 		goto out;
 
-	err = xfrm_replay_verify_len(x->replay_esn, rp);
+	err = xfrm_replay_verify_len(x->replay_esn, re);
 	if (err)
 		goto out;
 
-- 
1.7.9.5
