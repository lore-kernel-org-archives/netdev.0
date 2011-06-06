From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 1/3] xfrm: Fix off by one in the replay advance functions
Date: Mon, 6 Jun 2011 08:46:03 +0200
Message-ID: <20110606064603.GB31505@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:54528 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752108Ab1FFGmn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Jun 2011 02:42:43 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We may write 4 byte too much when we reinitialize the anti replay
window in the replay advance functions. This patch fixes this by
adjusting the last index of the initialization loop.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/xfrm/xfrm_replay.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/xfrm/xfrm_replay.c b/net/xfrm/xfrm_replay.c
index 47f1b86..b11ea69 100644
--- a/net/xfrm/xfrm_replay.c
+++ b/net/xfrm/xfrm_replay.c
@@ -265,7 +265,7 @@ static void xfrm_replay_advance_bmp(struct xfrm_state *x, __be32 net_seq)
 			bitnr = bitnr & 0x1F;
 			replay_esn->bmp[nr] |= (1U << bitnr);
 		} else {
-			nr = replay_esn->replay_window >> 5;
+			nr = (replay_esn->replay_window - 1) >> 5;
 			for (i = 0; i <= nr; i++)
 				replay_esn->bmp[i] = 0;
 
@@ -471,7 +471,7 @@ static void xfrm_replay_advance_esn(struct xfrm_state *x, __be32 net_seq)
 			bitnr = bitnr & 0x1F;
 			replay_esn->bmp[nr] |= (1U << bitnr);
 		} else {
-			nr = replay_esn->replay_window >> 5;
+			nr = (replay_esn->replay_window - 1) >> 5;
 			for (i = 0; i <= nr; i++)
 				replay_esn->bmp[i] = 0;
 
-- 
1.7.0.4

