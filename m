From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 01/17] xfrm: constify xfrm_replay structures
Date: Thu, 8 Sep 2016 07:54:36 +0200
Message-ID: <1473314092-11319-2-git-send-email-steffen.klassert@secunet.com>
References: <1473314092-11319-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:36360 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756762AbcIHGv1 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 8 Sep 2016 02:51:27 -0400
In-Reply-To: <1473314092-11319-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julia Lawall <Julia.Lawall@lip6.fr>

The xfrm_replay structures are never modified, so declare them as const.

Done with the help of Coccinelle.

Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 include/net/xfrm.h     | 2 +-
 net/xfrm/xfrm_replay.c | 6 +++---
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index adfebd6..d2fdd6d 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -187,7 +187,7 @@ struct xfrm_state {
 	struct xfrm_replay_state_esn *preplay_esn;
 
 	/* The functions for replay detection. */
-	struct xfrm_replay	*repl;
+	const struct xfrm_replay *repl;
 
 	/* internal flag that only holds state for delayed aevent at the
 	 * moment
diff --git a/net/xfrm/xfrm_replay.c b/net/xfrm/xfrm_replay.c
index 4fd725a..cdc2e2e 100644
--- a/net/xfrm/xfrm_replay.c
+++ b/net/xfrm/xfrm_replay.c
@@ -558,7 +558,7 @@ static void xfrm_replay_advance_esn(struct xfrm_state *x, __be32 net_seq)
 		x->repl->notify(x, XFRM_REPLAY_UPDATE);
 }
 
-static struct xfrm_replay xfrm_replay_legacy = {
+static const struct xfrm_replay xfrm_replay_legacy = {
 	.advance	= xfrm_replay_advance,
 	.check		= xfrm_replay_check,
 	.recheck	= xfrm_replay_check,
@@ -566,7 +566,7 @@ static struct xfrm_replay xfrm_replay_legacy = {
 	.overflow	= xfrm_replay_overflow,
 };
 
-static struct xfrm_replay xfrm_replay_bmp = {
+static const struct xfrm_replay xfrm_replay_bmp = {
 	.advance	= xfrm_replay_advance_bmp,
 	.check		= xfrm_replay_check_bmp,
 	.recheck	= xfrm_replay_check_bmp,
@@ -574,7 +574,7 @@ static struct xfrm_replay xfrm_replay_bmp = {
 	.overflow	= xfrm_replay_overflow_bmp,
 };
 
-static struct xfrm_replay xfrm_replay_esn = {
+static const struct xfrm_replay xfrm_replay_esn = {
 	.advance	= xfrm_replay_advance_esn,
 	.check		= xfrm_replay_check_esn,
 	.recheck	= xfrm_replay_recheck_esn,
-- 
1.9.1
