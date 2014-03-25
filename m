From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH 04/54] 8390: Call dev_consume_skb_any instead of dev_kfree_skb.
Date: Mon, 24 Mar 2014 23:04:50 -0700
Message-ID: <1395727540-12148-4-git-send-email-ebiederm@xmission.com>
References: <87y4zyhlar.fsf_-_@x220.int.ebiederm.org>
 <1395727540-12148-1-git-send-email-ebiederm@xmission.com>
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	xiyou.wangcong@gmail.com, mpm@selenic.com, satyam.sharma@gmail.com,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:33795 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751218AbaCYGGJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2014 02:06:09 -0400
In-Reply-To: <1395727540-12148-1-git-send-email-ebiederm@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eric W. Biederman" <ebiederm@xmission.com>

Replace dev_kfree_skb with dev_consume_skb_any in __ei_start_xmit that
can be called in hard irq and other contexts.

dev_consume_skb is used as in this simple driver the skb is always
immediately consumed, there are no drops.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 drivers/net/ethernet/8390/lib8390.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/8390/lib8390.c b/drivers/net/ethernet/8390/lib8390.c
index d2cd80444ade..599311f0e05c 100644
--- a/drivers/net/ethernet/8390/lib8390.c
+++ b/drivers/net/ethernet/8390/lib8390.c
@@ -404,7 +404,7 @@ static netdev_tx_t __ei_start_xmit(struct sk_buff *skb,
 	spin_unlock(&ei_local->page_lock);
 	enable_irq_lockdep_irqrestore(dev->irq, &flags);
 	skb_tx_timestamp(skb);
-	dev_kfree_skb(skb);
+	dev_consume_skb_any(skb);
 	dev->stats.tx_bytes += send_length;
 
 	return NETDEV_TX_OK;
-- 
1.7.10.4
