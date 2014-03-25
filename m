From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH 06/54] sun4i-emac: Call dev_consume_skb_any instead of dev_kfree_skb.
Date: Mon, 24 Mar 2014 23:04:52 -0700
Message-ID: <1395727540-12148-6-git-send-email-ebiederm@xmission.com>
References: <87y4zyhlar.fsf_-_@x220.int.ebiederm.org>
 <1395727540-12148-1-git-send-email-ebiederm@xmission.com>
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	xiyou.wangcong@gmail.com, mpm@selenic.com, satyam.sharma@gmail.com,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:58477 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751295AbaCYGGQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2014 02:06:16 -0400
In-Reply-To: <1395727540-12148-1-git-send-email-ebiederm@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eric W. Biederman" <ebiederm@xmission.com>

Replace dev_kfree_skb with dev_consume_skb_any in emacs_start_xmit
which can be called in hard irq and other contexts.

emac_start_xmit always transmits the packet making dev_consume_skb
the appropriate function to call.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 drivers/net/ethernet/allwinner/sun4i-emac.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/allwinner/sun4i-emac.c b/drivers/net/ethernet/allwinner/sun4i-emac.c
index 511f6eecd58b..fcaeeb8a4929 100644
--- a/drivers/net/ethernet/allwinner/sun4i-emac.c
+++ b/drivers/net/ethernet/allwinner/sun4i-emac.c
@@ -476,7 +476,7 @@ static int emac_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	spin_unlock_irqrestore(&db->lock, flags);
 
 	/* free this SKB */
-	dev_kfree_skb(skb);
+	dev_consume_skb_any(skb);
 
 	return NETDEV_TX_OK;
 }
-- 
1.7.10.4
