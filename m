From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH] xfrm: Access the replay notify functions via the
 registered callbacks
Date: Thu, 22 Mar 2012 10:36:13 +0100
Message-ID: <20120322093613.GU29891@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:47653 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753956Ab2CVJgX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Mar 2012 05:36:23 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We call the wrong replay notify function when we use ESN replay
handling. This leads to the fact that we don't send notifications
if we use ESN. Fix this by calling the registered callbacks instead
of xfrm_replay_notify().

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/xfrm/xfrm_replay.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/xfrm/xfrm_replay.c b/net/xfrm/xfrm_replay.c
index 39e02c5..2f6d11d 100644
--- a/net/xfrm/xfrm_replay.c
+++ b/net/xfrm/xfrm_replay.c
@@ -167,7 +167,7 @@ static void xfrm_replay_advance(struct xfrm_state *x, __be32 net_seq)
 	}
 
 	if (xfrm_aevent_is_on(xs_net(x)))
-		xfrm_replay_notify(x, XFRM_REPLAY_UPDATE);
+		x->repl->notify(x, XFRM_REPLAY_UPDATE);
 }
 
 static int xfrm_replay_overflow_bmp(struct xfrm_state *x, struct sk_buff *skb)
@@ -279,7 +279,7 @@ static void xfrm_replay_advance_bmp(struct xfrm_state *x, __be32 net_seq)
 	replay_esn->bmp[nr] |= (1U << bitnr);
 
 	if (xfrm_aevent_is_on(xs_net(x)))
-		xfrm_replay_notify(x, XFRM_REPLAY_UPDATE);
+		x->repl->notify(x, XFRM_REPLAY_UPDATE);
 }
 
 static void xfrm_replay_notify_bmp(struct xfrm_state *x, int event)
@@ -473,7 +473,7 @@ static void xfrm_replay_advance_esn(struct xfrm_state *x, __be32 net_seq)
 	replay_esn->bmp[nr] |= (1U << bitnr);
 
 	if (xfrm_aevent_is_on(xs_net(x)))
-		xfrm_replay_notify(x, XFRM_REPLAY_UPDATE);
+		x->repl->notify(x, XFRM_REPLAY_UPDATE);
 }
 
 static struct xfrm_replay xfrm_replay_legacy = {
-- 
1.7.0.4
