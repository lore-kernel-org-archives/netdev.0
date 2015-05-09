From: roy.qing.li@gmail.com
Subject: [PATCH][next] xfrm: optimise xfrm_policy_lookup_bytype
Date: Sat,  9 May 2015 19:17:37 +0800
Message-ID: <1431170257-18242-1-git-send-email-roy.qing.li@gmail.com>
Cc: steffen.klassert@secunet.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:57575 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753017AbbEILRn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 May 2015 07:17:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com>

It is unnecessary to continue to loop the policy if the priority
of current looped police is larger than priority which is from
the policy_bydst list.

Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
---
 net/xfrm/xfrm_policy.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 66450c3..4adee12 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1116,6 +1116,8 @@ static struct xfrm_policy *xfrm_policy_lookup_bytype(struct net *net, u8 type,
 	}
 	chain = &net->xfrm.policy_inexact[dir];
 	hlist_for_each_entry(pol, chain, bydst) {
+		if (pol->priority >= priority)
+			break;
 		err = xfrm_policy_match(pol, fl, type, family, dir);
 		if (err) {
 			if (err == -ESRCH)
@@ -1124,7 +1126,7 @@ static struct xfrm_policy *xfrm_policy_lookup_bytype(struct net *net, u8 type,
 				ret = ERR_PTR(err);
 				goto fail;
 			}
-		} else if (pol->priority < priority) {
+		} else {
 			ret = pol;
 			break;
 		}
-- 
2.1.0
