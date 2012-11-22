From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 1/4] xfrm: remove redundant replay_esn check
Date: Thu, 22 Nov 2012 09:02:39 +0100
Message-ID: <1353571362-6774-2-git-send-email-steffen.klassert@secunet.com>
References: <1353571362-6774-1-git-send-email-steffen.klassert@secunet.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:36102 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932389Ab2KVTBS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Nov 2012 14:01:18 -0500
In-Reply-To: <1353571362-6774-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ulrich Weber <ulrich.weber@sophos.com>

x->replay_esn is already checked in if clause,
so remove check and ident properly

Signed-off-by: Ulrich Weber <ulrich.weber@sophos.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/xfrm/xfrm_replay.c |   13 ++++++-------
 1 file changed, 6 insertions(+), 7 deletions(-)

diff --git a/net/xfrm/xfrm_replay.c b/net/xfrm/xfrm_replay.c
index 3efb07d..765f6fe 100644
--- a/net/xfrm/xfrm_replay.c
+++ b/net/xfrm/xfrm_replay.c
@@ -521,13 +521,12 @@ int xfrm_init_replay(struct xfrm_state *x)
 		    replay_esn->bmp_len * sizeof(__u32) * 8)
 			return -EINVAL;
 
-	if ((x->props.flags & XFRM_STATE_ESN) && replay_esn->replay_window == 0)
-		return -EINVAL;
-
-	if ((x->props.flags & XFRM_STATE_ESN) && x->replay_esn)
-		x->repl = &xfrm_replay_esn;
-	else
-		x->repl = &xfrm_replay_bmp;
+		if (x->props.flags & XFRM_STATE_ESN) {
+			if (replay_esn->replay_window == 0)
+				return -EINVAL;
+			x->repl = &xfrm_replay_esn;
+		} else
+			x->repl = &xfrm_replay_bmp;
 	} else
 		x->repl = &xfrm_replay_legacy;
 
-- 
1.7.9.5
