From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: [PATCH]&[Question] netdevice: Use netdev_priv()
Date: Fri, 01 Aug 2008 17:50:15 +0800
Message-ID: <4892DC57.2060101@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: NETDEV <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:56827 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752984AbYHAJwU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Aug 2008 05:52:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave

This mail is a question mail more than patch mail.
In your commit "netdev: netdev_priv() can now be sane again.",
you said netdev_priv() != netdev->priv, because that time,
netdev->priv = ((char *)dev +((sizeof(struct net_device) +(sizeof(struct net_device_subqueue) *
		(queue_count - 1)) + NETDEV_ALIGN_CONST) & ~NETDEV_ALIGN_CONST))
But now, after you do TX multiqueue improvement.
netdev->priv == netdev_priv() again.

That make me think, what the use of netdev->priv?
We have netdev_priv() and use it flexibly. Why don't kill netdev->priv?

---
>From be26ade29c6a3d0002492f7aab25258cb78ab597 Mon Sep 17 00:00:00 2001
From: Wang Chen <wangchen@cn.fujitsu.com>
Date: Fri, 1 Aug 2008 16:59:59 +0800
Subject: [PATCH] netdevice: Use netdev_priv()

dev->priv is now point to private data again.

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
 net/core/dev.c |    7 ++-----
 1 files changed, 2 insertions(+), 5 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 63d6bcd..9b73624 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4255,11 +4255,8 @@ struct net_device *alloc_netdev_mq(int sizeof_priv, const char *name,
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
1.5.3.4



