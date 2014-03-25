From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH 08/54] lance: Call dev_consume_skb_any instead of dev_kfree_skb.
Date: Mon, 24 Mar 2014 23:04:54 -0700
Message-ID: <1395727540-12148-8-git-send-email-ebiederm@xmission.com>
References: <87y4zyhlar.fsf_-_@x220.int.ebiederm.org>
 <1395727540-12148-1-git-send-email-ebiederm@xmission.com>
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	xiyou.wangcong@gmail.com, mpm@selenic.com, satyam.sharma@gmail.com,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:58511 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751411AbaCYGGY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2014 02:06:24 -0400
In-Reply-To: <1395727540-12148-1-git-send-email-ebiederm@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eric W. Biederman" <ebiederm@xmission.com>

Replace dev_kfree_skb with dev_consume_skb_any in lance_start_xmit
that can be called in hard irq and other contexts.

dev_consume_skb_any is used as lance_start_xmit always immediately
consumes the skb.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 drivers/net/ethernet/amd/7990.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/amd/7990.c b/drivers/net/ethernet/amd/7990.c
index 18e542f7853d..98a10d555b79 100644
--- a/drivers/net/ethernet/amd/7990.c
+++ b/drivers/net/ethernet/amd/7990.c
@@ -578,7 +578,7 @@ int lance_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	outs++;
 	/* Kick the lance: transmit now */
 	WRITERDP(lp, LE_C0_INEA | LE_C0_TDMD);
-	dev_kfree_skb(skb);
+	dev_consume_skb_any(skb);
 
 	spin_lock_irqsave(&lp->devlock, flags);
 	if (TX_BUFFS_AVAIL)
-- 
1.7.10.4
