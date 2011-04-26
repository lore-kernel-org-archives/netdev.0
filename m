From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH net-2.6 3/4] xfrm: Check for the new replay implementation
 if an esn state is inserted
Date: Tue, 26 Apr 2011 07:41:21 +0200
Message-ID: <20110426054121.GH5495@secunet.com>
References: <20110426053923.GF5495@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:49163 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752986Ab1DZFku (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Apr 2011 01:40:50 -0400
Content-Disposition: inline
In-Reply-To: <20110426053923.GF5495@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IPsec extended sequence numbers can be used only with the new
anti-replay window implementation. So check if the new implementation
is used if an esn state is inserted and return an error if it is not.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/xfrm/xfrm_user.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 5d1d60d..c658cb3 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -124,6 +124,9 @@ static inline int verify_replay(struct xfrm_usersa_info *p,
 {
 	struct nlattr *rt = attrs[XFRMA_REPLAY_ESN_VAL];
 
+	if ((p->flags & XFRM_STATE_ESN) && !rt)
+		return -EINVAL;
+
 	if (!rt)
 		return 0;
 
-- 
1.7.0.4

