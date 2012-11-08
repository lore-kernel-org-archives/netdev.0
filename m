From: Ulrich Weber <ulrich.weber@sophos.com>
Subject: [PATCH] xfrm: remove redundant replay_esn check
Date: Thu, 8 Nov 2012 11:15:44 +0100
Message-ID: <20121108101544.GA30309@uweber-WS>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>
To: <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.sophos.com ([145.253.124.137]:60216 "EHLO mx1.sophos.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751126Ab2KHKYk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Nov 2012 05:24:40 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

x->replay_esn is already checked in if clause,
so remove check and ident properly

Signed-off-by: Ulrich Weber <ulrich.weber@sophos.com>
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
