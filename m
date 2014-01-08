From: Fan Du <fan.du@windriver.com>
Subject: [PATCH net-next 3/3] xfrm: Don't prohibit AH from using ESN feature
Date: Wed, 8 Jan 2014 16:53:12 +0800
Message-ID: <1389171192-28091-4-git-send-email-fan.du@windriver.com>
References: <1389171192-28091-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:42451 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755595AbaAHIxU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jan 2014 03:53:20 -0500
In-Reply-To: <1389171192-28091-1-git-send-email-fan.du@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Clear checking when user try to use ESN through netlink keymgr for AH.

Signed-off-by: Fan Du <fan.du@windriver.com>
---
 net/xfrm/xfrm_user.c |    4 ----
 1 file changed, 4 deletions(-)

diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 97681a3..f362a78 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -141,10 +141,6 @@ static inline int verify_replay(struct xfrm_usersa_info *p,
 
 	if (!rt)
 		return 0;
-
-	if (p->id.proto != IPPROTO_ESP)
-		return -EINVAL;
-
 	if (p->replay_window != 0)
 		return -EINVAL;
 
-- 
1.7.9.5
