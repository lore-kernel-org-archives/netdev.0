From: roy.qing.li@gmail.com
Subject: [PATCH][net-next] xfrm: remove the unnecessary checking before call xfrm_pol_hold
Date: Thu, 30 Apr 2015 17:13:41 +0800
Message-ID: <1430385221-21847-1-git-send-email-roy.qing.li@gmail.com>
Cc: steffen.klassert@secunet.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:37829 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751152AbbD3JNs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Apr 2015 05:13:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com>

xfrm_pol_hold will check its input with NULL

Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
---
 net/xfrm/xfrm_policy.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 638af06..f576217 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1133,8 +1133,8 @@ static struct xfrm_policy *xfrm_policy_lookup_bytype(struct net *net, u8 type,
 			break;
 		}
 	}
-	if (ret)
-		xfrm_pol_hold(ret);
+
+	xfrm_pol_hold(ret);
 fail:
 	read_unlock_bh(&net->xfrm.xfrm_policy_lock);
 
@@ -3217,8 +3217,7 @@ static struct xfrm_policy *xfrm_migrate_policy_find(const struct xfrm_selector *
 		}
 	}
 
-	if (ret)
-		xfrm_pol_hold(ret);
+	xfrm_pol_hold(ret);
 
 	read_unlock_bh(&net->xfrm.xfrm_policy_lock);
 
-- 
2.1.0
