From: Jianjun Kong <jianjun@zeuux.org>
Subject: [PATCH] net: cleanup for net/core/dev.c
Date: Mon, 8 Dec 2008 22:52:14 +0800
Message-ID: <20081208145214.GA6830@ubuntu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.zeuux.org ([210.51.160.52]:60847 "EHLO z.billxu.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752050AbYLHOwU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Dec 2008 09:52:20 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


net/core/dev.c:
netdev_priv() do the same thing like

dev->priv = ((char *)dev +
	((sizeof(struct net_device) + NETDEV_ALIGN_CONST)
	& ~NETDEV_ALIGN_CONST));

Signed-off-by: Jianjun Kong <jianjun@zeuux.org>
---
 net/core/dev.c |    9 +++------
 1 files changed, 3 insertions(+), 6 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 9174c77..f6d9af5 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4305,7 +4305,7 @@ struct net_device *alloc_netdev_mq(int sizeof_priv, const char *name,
 	size_t alloc_size;
 	void *p;
 
-	BUG_ON(strlen(name) >= sizeof(dev->name));
+	BUG_ON(strlen(name) >= IFNAMSIZ);
 
 	alloc_size = sizeof(struct net_device);
 	if (sizeof_priv) {
@@ -4339,11 +4339,8 @@ struct net_device *alloc_netdev_mq(int sizeof_priv, const char *name,
 	dev->num_tx_queues = queue_count;
 	dev->real_num_tx_queues = queue_count;
 
-	if (sizeof_priv) {
-		dev->priv = ((char *)dev +
-			     ((sizeof(struct net_device) + NETDEV_ALIGN_CONST)
-			      & ~NETDEV_ALIGN_CONST));
-	}
+	if (sizeof_priv)
+		dev->priv = netdev_priv(dev);
 
 	dev->gso_max_size = GSO_MAX_SIZE;
 
-- 
1.5.6.3

-- 
Jianjun Kong |Happy Hacking
Homepage: http://kongove.cn
Gtalk:kongjianjun@gmail.com
