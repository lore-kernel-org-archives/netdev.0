From: Fan Du <fan.du@windriver.com>
Subject: [PATCH net] xfrm: Delete hold_timer when destroy policy
Date: Thu, 1 Aug 2013 18:08:36 +0800
Message-ID: <1375351716-3265-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:63830 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751418Ab3HAKGf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Aug 2013 06:06:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Both policy timer and hold_timer need to be deleted when destroy policy
Bad mood today, maybe I'm wrong about this...

Signed-off-by: Fan Du <fan.du@windriver.com>
---
 net/xfrm/xfrm_policy.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index d8da6b8..f7078eb 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -308,7 +308,7 @@ void xfrm_policy_destroy(struct xfrm_policy *policy)
 {
 	BUG_ON(!policy->walk.dead);
 
-	if (del_timer(&policy->timer))
+	if (del_timer(&policy->timer) || del_timer(&policy->polq.hold_timer))
 		BUG();
 
 	security_xfrm_policy_free(policy->security);
-- 
1.7.1
