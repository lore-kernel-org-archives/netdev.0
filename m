From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 6/6] xfrm: remove irrelevant comment in xfrm_input().
Date: Thu, 22 Aug 2013 13:12:10 +0200
Message-ID: <1377169931-7302-7-git-send-email-steffen.klassert@secunet.com>
References: <1377169931-7302-1-git-send-email-steffen.klassert@secunet.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:51128 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753297Ab3HVLMh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Aug 2013 07:12:37 -0400
In-Reply-To: <1377169931-7302-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rami Rosen <ramirose@gmail.com>

This patch removes a comment in xfrm_input() which became irrelevant
due to commit 2774c13, "xfrm: Handle blackhole route creation via afinfo".
That commit removed returning -EREMOTE in the xfrm_lookup() method when the
packet should be discarded  and also removed the correspoinding -EREMOTE
handlers. This was replaced by calling the make_blackhole() method. Therefore
the comment about -EREMOTE is not relevant anymore.

Signed-off-by: Rami Rosen <ramirose@gmail.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/xfrm/xfrm_policy.c |    2 --
 1 file changed, 2 deletions(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index f7078eb..ad8cc7b 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -2132,8 +2132,6 @@ restart:
 		 * have the xfrm_state's. We need to wait for KM to
 		 * negotiate new SA's or bail out with error.*/
 		if (net->xfrm.sysctl_larval_drop) {
-			/* EREMOTE tells the caller to generate
-			 * a one-shot blackhole route. */
 			dst_release(dst);
 			xfrm_pols_put(pols, drop_pols);
 			XFRM_INC_STATS(net, LINUX_MIB_XFRMOUTNOSTATES);
-- 
1.7.9.5
