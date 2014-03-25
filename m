From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH 50/54] xen-netfront: Call dev_kfree_skb_any instead of dev_kfree_skb.
Date: Mon, 24 Mar 2014 23:05:36 -0700
Message-ID: <1395727540-12148-50-git-send-email-ebiederm@xmission.com>
References: <87y4zyhlar.fsf_-_@x220.int.ebiederm.org>
 <1395727540-12148-1-git-send-email-ebiederm@xmission.com>
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	xiyou.wangcong@gmail.com, mpm@selenic.com, satyam.sharma@gmail.com,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:34610 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751411AbaCYGLa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2014 02:11:30 -0400
In-Reply-To: <1395727540-12148-1-git-send-email-ebiederm@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eric W. Biederman" <ebiederm@xmission.com>

Replace dev_kfree_skb with dev_kfree_skb_any in xennet_start_xmit
which can be called in hard irq and other contexts.  xennet_start_xmit
only fress skbs which it drops.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 drivers/net/xen-netfront.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index 49f3b3dbbed8..057b05700f8b 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -658,7 +658,7 @@ static int xennet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
  drop:
 	dev->stats.tx_dropped++;
-	dev_kfree_skb(skb);
+	dev_kfree_skb_any(skb);
 	return NETDEV_TX_OK;
 }
 
-- 
1.7.10.4
