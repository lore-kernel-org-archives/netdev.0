From: Phil Sutter <phil@nwl.cc>
Subject: [net-next PATCH 1/4] net: fix IFF_NO_QUEUE for drivers using alloc_netdev
Date: Thu, 27 Aug 2015 21:21:36 +0200
Message-ID: <1440703299-21243-2-git-send-email-phil@nwl.cc>
References: <1440703299-21243-1-git-send-email-phil@nwl.cc>
Cc: davem@davemloft.net, eric.dumazet@gmail.com, brouer@redhat.com,
	geert@linux-m68k.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:50984 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751754AbbH0TVl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Aug 2015 15:21:41 -0400
In-Reply-To: <1440703299-21243-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Printing a warning in alloc_netdev_mqs() if tx_queue_len is zero and
IFF_NO_QUEUE not set is not appropriate since drivers may use one of the
alloc_netdev* macros instead of alloc_etherdev*, thereby not
intentionally leaving tx_queue_len uninitialized. Instead check here if
tx_queue_len is zero and set IFF_NO_QUEUE, so the value of tx_queue_len
can be ignored in net/sched_generic.c.

Fixes: 906470c ("net: warn if drivers set tx_queue_len = 0")
Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 net/core/dev.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index b1f3f48..68156ef 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -6998,7 +6998,7 @@ struct net_device *alloc_netdev_mqs(int sizeof_priv, const char *name,
 	setup(dev);
 
 	if (!dev->tx_queue_len)
-		printk(KERN_WARNING "%s uses DEPRECATED zero tx_queue_len - convert driver to use IFF_NO_QUEUE instead.\n", name);
+		dev->priv_flags |= IFF_NO_QUEUE;
 
 	dev->num_tx_queues = txqs;
 	dev->real_num_tx_queues = txqs;
-- 
2.1.2
