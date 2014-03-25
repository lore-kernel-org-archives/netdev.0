From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH 01/54] uml/net_kern: Call dev_consume_skb_any instead of dev_kfree_skb.
Date: Mon, 24 Mar 2014 23:04:47 -0700
Message-ID: <1395727540-12148-1-git-send-email-ebiederm@xmission.com>
References: <87y4zyhlar.fsf_-_@x220.int.ebiederm.org>
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	xiyou.wangcong@gmail.com, mpm@selenic.com, satyam.sharma@gmail.com,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:58405 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751003AbaCYGFz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2014 02:05:55 -0400
In-Reply-To: <87y4zyhlar.fsf_-_@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eric W. Biederman" <ebiederm@xmission.com>

Replace dev_kfree_skb with dev_consume_skb_any in uml_net_start_xmit
as it can be called in hard irq and other contexts.

dev_consume_skb_any is used as uml_net_start_xmit typically
consumes (not drops) packets.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 arch/um/drivers/net_kern.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/um/drivers/net_kern.c b/arch/um/drivers/net_kern.c
index 39f186252e02..7d26d9c0b2fb 100644
--- a/arch/um/drivers/net_kern.c
+++ b/arch/um/drivers/net_kern.c
@@ -240,7 +240,7 @@ static int uml_net_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	spin_unlock_irqrestore(&lp->lock, flags);
 
-	dev_kfree_skb(skb);
+	dev_consume_skb_any(skb);
 
 	return NETDEV_TX_OK;
 }
-- 
1.7.10.4
