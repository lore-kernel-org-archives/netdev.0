From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 3/7] xfrm: fix a unbalanced lock
Date: Thu, 14 Feb 2013 12:47:23 +0100
Message-ID: <1360842447-3344-4-git-send-email-steffen.klassert@secunet.com>
References: <1360842447-3344-1-git-send-email-steffen.klassert@secunet.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:44532 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934318Ab3BNLr5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Feb 2013 06:47:57 -0500
In-Reply-To: <1360842447-3344-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com>

Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/xfrm/xfrm_output.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/xfrm/xfrm_output.c b/net/xfrm/xfrm_output.c
index 3670526..bcfda89 100644
--- a/net/xfrm/xfrm_output.c
+++ b/net/xfrm/xfrm_output.c
@@ -64,7 +64,7 @@ static int xfrm_output_one(struct sk_buff *skb, int err)
 
 		if (unlikely(x->km.state != XFRM_STATE_VALID)) {
 			XFRM_INC_STATS(net, LINUX_MIB_XFRMOUTSTATEINVALID);
-			goto error_nolock;
+			goto error;
 		}
 
 		err = xfrm_state_check_expire(x);
-- 
1.7.9.5
