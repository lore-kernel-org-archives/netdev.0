From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH 20/54] dm9000: Call dev_consume_skb_any instead of dev_kfree_skb.
Date: Mon, 24 Mar 2014 23:05:06 -0700
Message-ID: <1395727540-12148-20-git-send-email-ebiederm@xmission.com>
References: <87y4zyhlar.fsf_-_@x220.int.ebiederm.org>
 <1395727540-12148-1-git-send-email-ebiederm@xmission.com>
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	xiyou.wangcong@gmail.com, mpm@selenic.com, satyam.sharma@gmail.com,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:59048 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751659AbaCYGL2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2014 02:11:28 -0400
In-Reply-To: <1395727540-12148-1-git-send-email-ebiederm@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eric W. Biederman" <ebiederm@xmission.com>

Replace dev_kfree_skb with dev_consume_skb_any in dm9000_start_xmit
that can be called in hard irq and other contexts, on the path
that successfully transmits the packet.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 drivers/net/ethernet/davicom/dm9000.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/davicom/dm9000.c b/drivers/net/ethernet/davicom/dm9000.c
index a1a2b4028a5c..8c4b93be333b 100644
--- a/drivers/net/ethernet/davicom/dm9000.c
+++ b/drivers/net/ethernet/davicom/dm9000.c
@@ -1033,7 +1033,7 @@ dm9000_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	spin_unlock_irqrestore(&db->lock, flags);
 
 	/* free this SKB */
-	dev_kfree_skb(skb);
+	dev_consume_skb_any(skb);
 
 	return NETDEV_TX_OK;
 }
-- 
1.7.10.4
