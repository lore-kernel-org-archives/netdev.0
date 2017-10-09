From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 1/4] xfrm: Fix deletion of offloaded SAs on failure.
Date: Mon, 9 Oct 2017 09:16:36 +0200
Message-ID: <1507533399-29399-2-git-send-email-steffen.klassert@secunet.com>
References: <1507533399-29399-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:49526 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753694AbdJIHQr (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 9 Oct 2017 03:16:47 -0400
In-Reply-To: <1507533399-29399-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When we off load a SA, it gets pushed to the NIC before we can
add it. In case of a failure, we don't delete this SA from the
NIC. Fix this by calling xfrm_dev_state_delete on failure.

Fixes: d77e38e612a0 ("xfrm: Add an IPsec hardware offloading API")
Reported-by: Shannon Nelson <shannon.nelson@oracle.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/xfrm/xfrm_user.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 2bfbd91..b997f13 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -657,6 +657,7 @@ static int xfrm_add_sa(struct sk_buff *skb, struct nlmsghdr *nlh,
 
 	if (err < 0) {
 		x->km.state = XFRM_STATE_DEAD;
+		xfrm_dev_state_delete(x);
 		__xfrm_state_put(x);
 		goto out;
 	}
-- 
2.7.4
