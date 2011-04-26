From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH net-2.6 4/4] xfrm: Fix integer underrun on zero sized
 replay windows
Date: Tue, 26 Apr 2011 07:42:32 +0200
Message-ID: <20110426054232.GI5495@secunet.com>
References: <20110426053923.GF5495@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:49190 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752986Ab1DZFmB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Apr 2011 01:42:01 -0400
Content-Disposition: inline
In-Reply-To: <20110426053923.GF5495@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The check if the replay window is contained within one subspace or
spans over two subspaces causes an unwanted integer underrun on
zero sized replay windows when we subtract minus one. We fix this by
changeing this check to avoid the subtraction.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/xfrm/xfrm_replay.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/xfrm/xfrm_replay.c b/net/xfrm/xfrm_replay.c
index e8a7814..19f94bb 100644
--- a/net/xfrm/xfrm_replay.c
+++ b/net/xfrm/xfrm_replay.c
@@ -32,7 +32,7 @@ u32 xfrm_replay_seqhi(struct xfrm_state *x, __be32 net_seq)
 	seq_hi = replay_esn->seq_hi;
 	bottom = replay_esn->seq - replay_esn->replay_window + 1;
 
-	if (likely(replay_esn->seq >= replay_esn->replay_window - 1)) {
+	if (likely(replay_esn->seq > replay_esn->replay_window)) {
 		/* A. same subspace */
 		if (unlikely(seq < bottom))
 			seq_hi++;
-- 
1.7.0.4

