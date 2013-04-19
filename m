From: Simon Horman <horms@verge.net.au>
Subject: [PATCH] GRE: Use IS_ERR_OR_NULL in gre_gso_segment
Date: Fri, 19 Apr 2013 15:48:40 +0900
Message-ID: <1366354120-11230-1-git-send-email-horms@verge.net.au>
Cc: Dmitry Kozlov <xeb@mail.ru>, Simon Horman <horms@verge.net.au>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:43817 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756479Ab3DSGsu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Apr 2013 02:48:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/ipv4/gre.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/gre.c b/net/ipv4/gre.c
index d2d5a99..0ae998b 100644
--- a/net/ipv4/gre.c
+++ b/net/ipv4/gre.c
@@ -168,7 +168,7 @@ static struct sk_buff *gre_gso_segment(struct sk_buff *skb,
 	/* segment inner packet. */
 	enc_features = skb->dev->hw_enc_features & netif_skb_features(skb);
 	segs = skb_mac_gso_segment(skb, enc_features);
-	if (!segs || IS_ERR(segs))
+	if (IS_ERR_OR_NULL(segs))
 		goto out;
 
 	skb = segs;
-- 
1.7.10.4
