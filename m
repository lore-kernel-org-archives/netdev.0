From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH] Bring comments in loopback.c uptodate.
Date: Thu, 27 Sep 2007 16:39:53 -0600
Message-ID: <m1lkarhgw6.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:42134 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756078AbXI0WkF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Sep 2007 18:40:05 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


A hint as to why it is safe to use per cpu variables,
and note that we actually can have multiple instances
of the loopback device now.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 drivers/net/loopback.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/net/loopback.c b/drivers/net/loopback.c
index 2617320..cba5c76 100644
--- a/drivers/net/loopback.c
+++ b/drivers/net/loopback.c
@@ -154,6 +154,7 @@ static int loopback_xmit(struct sk_buff *skb, struct net_device *dev)
 #endif
 	dev->last_rx = jiffies;
 
+	/* it's OK to use per_cpu_ptr() because BHs are off */
 	pcpu_lstats = netdev_priv(dev);
 	lb_stats = per_cpu_ptr(pcpu_lstats, smp_processor_id());
 	lb_stats->bytes += skb->len;
@@ -221,7 +222,8 @@ static void loopback_dev_free(struct net_device *dev)
 }
 
 /*
- * The loopback device is special. There is only one instance.
+ * The loopback device is special. There is only one instance 
+ * per network namespace.
  */
 static void loopback_setup(struct net_device *dev)
 {
-- 
1.5.3.rc6.17.g1911

