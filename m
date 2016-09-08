From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 3/6] xfrm: get rid of another incorrect WARN
Date: Thu, 8 Sep 2016 08:29:12 +0200
Message-ID: <1473316155-12186-4-git-send-email-steffen.klassert@secunet.com>
References: <1473316155-12186-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:35808 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751420AbcIHG32 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 8 Sep 2016 02:29:28 -0400
In-Reply-To: <1473316155-12186-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vegard Nossum <vegard.nossum@oracle.com>

During fuzzing I regularly run into this WARN(). According to Herbert Xu,
this "certainly shouldn't be a WARN, it probably shouldn't print anything
either".

Cc: Stephen Hemminger <stephen@networkplumber.org>
Cc: Steffen Klassert <steffen.klassert@secunet.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>
Signed-off-by: Vegard Nossum <vegard.nossum@oracle.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/xfrm/xfrm_user.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 1a4f142..cb65d91 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -2051,9 +2051,6 @@ static int xfrm_add_pol_expire(struct sk_buff *skb, struct nlmsghdr *nlh,
 	if (up->hard) {
 		xfrm_policy_delete(xp, p->dir);
 		xfrm_audit_policy_delete(xp, 1, true);
-	} else {
-		// reset the timers here?
-		WARN(1, "Don't know what to do with soft policy expire\n");
 	}
 	km_policy_expired(xp, p->dir, up->hard, nlh->nlmsg_pid);
 
-- 
1.9.1
