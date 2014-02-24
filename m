From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 06/13] xfrm: Don't prohibit AH from using ESN feature
Date: Mon, 24 Feb 2014 10:59:54 +0100
Message-ID: <1393236001-2445-7-git-send-email-steffen.klassert@secunet.com>
References: <1393236001-2445-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:39095 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752039AbaBXKAN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Feb 2014 05:00:13 -0500
In-Reply-To: <1393236001-2445-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fan Du <fan.du@windriver.com>

Clear checking when user try to use ESN through netlink keymgr for AH.
As only ESP and AH support ESN feature according to RFC.

Signed-off-by: Fan Du <fan.du@windriver.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/xfrm/xfrm_user.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 1ae3ec7..ade9988 100644
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
