From: Joe Perches <joe@perches.com>
Subject: [PATCH] net: core: Remove unnecessary alloc/OOM messages
Date: Mon, 04 Feb 2013 18:48:16 -0800
Message-ID: <1360032496.4849.2.camel@joe-AO722>
References: <cover.1359939012.git.joe@perches.com>
	 <20130204.132335.1757403310770538446.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:35064 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753882Ab3BECsS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Feb 2013 21:48:18 -0500
In-Reply-To: <20130204.132335.1757403310770538446.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

alloc failures already get standardized OOM
messages and a dump_stack.

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/core/dev.c            | 14 +++++---------
 net/core/netprio_cgroup.c |  4 +---
 2 files changed, 6 insertions(+), 12 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index a87bc74..e04bfdc 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5958,10 +5958,9 @@ static int netif_alloc_rx_queues(struct net_device *dev)
 	BUG_ON(count < 1);
 
 	rx = kcalloc(count, sizeof(struct netdev_rx_queue), GFP_KERNEL);
-	if (!rx) {
-		pr_err("netdev: Unable to allocate %u rx queues\n", count);
+	if (!rx)
 		return -ENOMEM;
-	}
+
 	dev->_rx = rx;
 
 	for (i = 0; i < count; i++)
@@ -5992,10 +5991,9 @@ static int netif_alloc_netdev_queues(struct net_device *dev)
 	BUG_ON(count < 1);
 
 	tx = kcalloc(count, sizeof(struct netdev_queue), GFP_KERNEL);
-	if (!tx) {
-		pr_err("netdev: Unable to allocate %u tx queues\n", count);
+	if (!tx)
 		return -ENOMEM;
-	}
+
 	dev->_tx = tx;
 
 	netdev_for_each_tx_queue(dev, netdev_init_one_queue, NULL);
@@ -6482,10 +6480,8 @@ struct net_device *alloc_netdev_mqs(int sizeof_priv, const char *name,
 	alloc_size += NETDEV_ALIGN - 1;
 
 	p = kzalloc(alloc_size, GFP_KERNEL);
-	if (!p) {
-		pr_err("alloc_netdev: Unable to allocate device\n");
+	if (!p)
 		return NULL;
-	}
 
 	dev = PTR_ALIGN(p, NETDEV_ALIGN);
 	dev->padded = (char *)dev - (char *)p;
diff --git a/net/core/netprio_cgroup.c b/net/core/netprio_cgroup.c
index 5e67def..0777d0a 100644
--- a/net/core/netprio_cgroup.c
+++ b/net/core/netprio_cgroup.c
@@ -69,10 +69,8 @@ static int extend_netdev_table(struct net_device *dev, u32 target_idx)
 
 	/* allocate & copy */
 	new = kzalloc(new_sz, GFP_KERNEL);
-	if (!new) {
-		pr_warn("Unable to alloc new priomap!\n");
+	if (!new)
 		return -ENOMEM;
-	}
 
 	if (old)
 		memcpy(new->priomap, old->priomap,
