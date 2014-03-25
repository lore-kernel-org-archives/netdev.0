From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH 02/54] 3c509: Call dev_consume_skb_any instead of dev_kfree_skb.
Date: Mon, 24 Mar 2014 23:04:48 -0700
Message-ID: <1395727540-12148-2-git-send-email-ebiederm@xmission.com>
References: <87y4zyhlar.fsf_-_@x220.int.ebiederm.org>
 <1395727540-12148-1-git-send-email-ebiederm@xmission.com>
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	xiyou.wangcong@gmail.com, mpm@selenic.com, satyam.sharma@gmail.com,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:58429 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751067AbaCYGGA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2014 02:06:00 -0400
In-Reply-To: <1395727540-12148-1-git-send-email-ebiederm@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eric W. Biederman" <ebiederm@xmission.com>

Replace dev_kfree_skb with dev_consume_skb_any in el3_start_xmit
as it can be called in hard irq and other contexts.

dev_consume_skb_any is used as on this simple hardware the
skb is consumed directly by the start_xmit function.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 drivers/net/ethernet/3com/3c509.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/3com/3c509.c b/drivers/net/ethernet/3com/3c509.c
index c53384d41c96..35df0b9e6848 100644
--- a/drivers/net/ethernet/3com/3c509.c
+++ b/drivers/net/ethernet/3com/3c509.c
@@ -749,7 +749,7 @@ el3_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	spin_unlock_irqrestore(&lp->lock, flags);
 
-	dev_kfree_skb (skb);
+	dev_consume_skb_any (skb);
 
 	/* Clear the Tx status stack. */
 	{
-- 
1.7.10.4
