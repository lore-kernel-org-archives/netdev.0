From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 2/6] xfrm: get rid of incorrect WARN
Date: Thu, 8 Sep 2016 08:29:11 +0200
Message-ID: <1473316155-12186-3-git-send-email-steffen.klassert@secunet.com>
References: <1473316155-12186-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:35797 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751427AbcIHG30 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 8 Sep 2016 02:29:26 -0400
In-Reply-To: <1473316155-12186-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vegard Nossum <vegard.nossum@oracle.com>

AFAICT this message is just printed whenever input validation fails.
This is a normal failure and we shouldn't be dumping the stack over it.

Looks like it was originally a printk that was maybe incorrectly
upgraded to a WARN:

commit 62db5cfd70b1ef53aa21f144a806fe3b78c84fab
Author: stephen hemminger <shemminger@vyatta.com>
Date:   Wed May 12 06:37:06 2010 +0000

    xfrm: add severity to printk

Cc: Stephen Hemminger <stephen@networkplumber.org>
Cc: Steffen Klassert <steffen.klassert@secunet.com>
Signed-off-by: Vegard Nossum <vegard.nossum@oracle.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/xfrm/xfrm_user.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 4fb04ce..1a4f142 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -2117,7 +2117,7 @@ static int xfrm_add_acquire(struct sk_buff *skb, struct nlmsghdr *nlh,
 
 	err = verify_newpolicy_info(&ua->policy);
 	if (err)
-		goto bad_policy;
+		goto free_state;
 
 	/*   build an XP */
 	xp = xfrm_policy_construct(net, &ua->policy, attrs, &err);
@@ -2149,8 +2149,6 @@ static int xfrm_add_acquire(struct sk_buff *skb, struct nlmsghdr *nlh,
 
 	return 0;
 
-bad_policy:
-	WARN(1, "BAD policy passed\n");
 free_state:
 	kfree(x);
 nomem:
-- 
1.9.1
