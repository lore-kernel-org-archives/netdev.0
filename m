From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH net-2.6 1/4] xfrm: Fix replay window size calculation on
 initialization
Date: Tue, 26 Apr 2011 07:39:24 +0200
Message-ID: <20110426053923.GF5495@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:58787 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755104Ab1DZFix (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Apr 2011 01:38:53 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On replay initialization, we compute the size of the replay
buffer to see if the replay window fits into the buffer.
This computation lacks a mutliplication by 8 because we need
the size in bit, not in byte. So we might return an error
even though the replay window would fit into the buffer.
This patch fixes this issue.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/xfrm/xfrm_replay.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/xfrm/xfrm_replay.c b/net/xfrm/xfrm_replay.c
index f218385..e8a7814 100644
--- a/net/xfrm/xfrm_replay.c
+++ b/net/xfrm/xfrm_replay.c
@@ -532,7 +532,7 @@ int xfrm_init_replay(struct xfrm_state *x)
 
 	if (replay_esn) {
 		if (replay_esn->replay_window >
-		    replay_esn->bmp_len * sizeof(__u32))
+		    replay_esn->bmp_len * sizeof(__u32) * 8)
 			return -EINVAL;
 
 	if ((x->props.flags & XFRM_STATE_ESN) && x->replay_esn)
-- 
1.7.0.4

