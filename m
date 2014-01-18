From: Fan Du <fan.du@windriver.com>
Subject: [PATCHv5 net-next 6/6] xfrm: Don't prohibit AH from using ESN feature
Date: Sat, 18 Jan 2014 09:54:28 +0800
Message-ID: <1390010068-15715-7-git-send-email-fan.du@windriver.com>
References: <1390010068-15715-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:63089 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753035AbaARByn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jan 2014 20:54:43 -0500
In-Reply-To: <1390010068-15715-1-git-send-email-fan.du@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Clear checking when user try to use ESN through netlink keymgr for AH.
As only ESP and AH support ESN feature according to RFC.

Signed-off-by: Fan Du <fan.du@windriver.com>
---
 net/xfrm/xfrm_user.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 3348566..9a80aa9 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -142,7 +142,8 @@ static inline int verify_replay(struct xfrm_usersa_info *p,
 	if (!rt)
 		return 0;
 
-	if (p->id.proto != IPPROTO_ESP)
+	/* As only ESP and AH support ESN feature. */
+	if ((p->id.proto != IPPROTO_ESP) && (p->id.proto != IPPROTO_AH))
 		return -EINVAL;
 
 	if (p->replay_window != 0)
-- 
1.7.9.5
