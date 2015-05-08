From: roy.qing.li@gmail.com
Subject: [PATCH] xfrm: fix a possible policy leak
Date: Fri,  8 May 2015 17:39:39 +0800
Message-ID: <1431077979-1606-1-git-send-email-roy.qing.li@gmail.com>
Cc: steffen.klassert@secunet.com, eparis@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:44788 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750907AbbEHJjr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 May 2015 05:39:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com>

policy should be put if exit xfrm_policy_bysel_ctx() due to the
failure of calling security_xfrm_policy_delete. since policy has
been hold before

Fixes: ef41aaa0b7 [IPSEC]: xfrm_policy delete security check misplaced
Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
Cc: Eric Paris <eparis@redhat.com>
---
 net/xfrm/xfrm_policy.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 3d264e5..66450c3 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -824,6 +824,7 @@ struct xfrm_policy *xfrm_policy_bysel_ctx(struct net *net, u32 mark, u8 type,
 				*err = security_xfrm_policy_delete(
 								pol->security);
 				if (*err) {
+					xfrm_pol_put(pol);
 					write_unlock_bh(&net->xfrm.xfrm_policy_lock);
 					return pol;
 				}
@@ -863,6 +864,7 @@ struct xfrm_policy *xfrm_policy_byid(struct net *net, u32 mark, u8 type,
 				*err = security_xfrm_policy_delete(
 								pol->security);
 				if (*err) {
+					xfrm_pol_put(pol);
 					write_unlock_bh(&net->xfrm.xfrm_policy_lock);
 					return pol;
 				}
-- 
2.1.0
