From: Jon Mason <jdmason@kudzu.us>
Subject: [PATCH] bridge: add ETH_HLEN to packet_length
Date: Thu, 14 Sep 2006 13:27:54 -0500
Message-ID: <20060914182751.GA15203@kudzu.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from proof.pobox.com ([207.106.133.28]:60824 "EHLO proof.pobox.com")
	by vger.kernel.org with ESMTP id S1750948AbWINS0q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Sep 2006 14:26:46 -0400
To: shemminger@osdl.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In br_dev_queue_push_xmit, why is the check to drop mtu oversized
packets not checking for enough room for the impending ETH_HLEN size
skb_push?  In some code currently under development, we are seeing
skb_under_panic being called from the "skb_push(skb, ETH_HLEN)" in that
code.  It seems to me it would be better to drop those skbs than panic.
Attached is a patch to do this.

Thanks,
Jon

Signed-off-by: Jon Mason <jdmason@kudzu.us>

diff -r b1d36669f98d net/bridge/br_forward.c
--- a/net/bridge/br_forward.c	Mon Sep  4 03:00:04 2006 +0000
+++ b/net/bridge/br_forward.c	Thu Sep 14 13:18:04 2006 -0500
@@ -29,7 +29,8 @@ static inline int should_deliver(const s
 
 static inline unsigned packet_length(const struct sk_buff *skb)
 {
-	return skb->len - (skb->protocol == htons(ETH_P_8021Q) ? VLAN_HLEN : 0);
+	return skb->len - ETH_HLEN - 
+		(skb->protocol == htons(ETH_P_8021Q) ? VLAN_HLEN : 0);
 }
 
 int br_dev_queue_push_xmit(struct sk_buff *skb)
