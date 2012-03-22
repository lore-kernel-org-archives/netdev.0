From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH] xfrm: Remove unused xfrm_state from xfrm_state_check_space
Date: Thu, 22 Mar 2012 10:32:39 +0100
Message-ID: <20120322093239.GT29891@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:47523 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964956Ab2CVJcp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Mar 2012 05:32:45 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The xfrm_state argument is unused in this function, so remove it.
Also the name xfrm_state_check_space does not really match what this
function does. It actually checks if we have enough head and tailroom
on the skb. So we rename the function to xfrm_skb_check_space.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/xfrm/xfrm_output.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/xfrm/xfrm_output.c b/net/xfrm/xfrm_output.c
index 47bacd8..95a338c 100644
--- a/net/xfrm/xfrm_output.c
+++ b/net/xfrm/xfrm_output.c
@@ -21,7 +21,7 @@
 
 static int xfrm_output2(struct sk_buff *skb);
 
-static int xfrm_state_check_space(struct xfrm_state *x, struct sk_buff *skb)
+static int xfrm_skb_check_space(struct sk_buff *skb)
 {
 	struct dst_entry *dst = skb_dst(skb);
 	int nhead = dst->header_len + LL_RESERVED_SPACE(dst->dev)
@@ -48,7 +48,7 @@ static int xfrm_output_one(struct sk_buff *skb, int err)
 		goto resume;
 
 	do {
-		err = xfrm_state_check_space(x, skb);
+		err = xfrm_skb_check_space(skb);
 		if (err) {
 			XFRM_INC_STATS(net, LINUX_MIB_XFRMOUTERROR);
 			goto error_nolock;
-- 
1.7.0.4
