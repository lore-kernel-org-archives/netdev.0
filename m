From: Bart Van Assche <bvanassche@acm.org>
Subject: [PATCH] net: Silence a W=1 compiler warning
Date: Fri, 13 Jun 2014 16:12:49 +0200
Message-ID: <539B06E1.4050005@acm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Vlad Yasevich <vyasevic@redhat.com>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from michel.telenet-ops.be ([195.130.137.88]:55221 "EHLO
	michel.telenet-ops.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751339AbaFMOMv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jun 2014 10:12:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Avoid that the following compiler warning is reported when building
with W=1:

include/linux/netdevice.h: In function 'netif_addr_lock_nested':
include/linux/netdevice.h:2865:6: warning: variable 'subclass' set but not used [-Wunused-but-set-variable]
  int subclass = SINGLE_DEPTH_NESTING;
      ^

This patch does not change any functionality.

Signed-off-by: Bart Van Assche <bvanassche@acm.org>
Cc: Vlad Yasevich <vyasevic@redhat.com>
Cc: David S. Miller <davem@davemloft.net>
---
 include/linux/netdevice.h | 10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index abe3de1..3c0a2e7 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2951,12 +2951,10 @@ static inline void netif_addr_lock(struct net_device *dev)
 
 static inline void netif_addr_lock_nested(struct net_device *dev)
 {
-	int subclass = SINGLE_DEPTH_NESTING;
-
-	if (dev->netdev_ops->ndo_get_lock_subclass)
-		subclass = dev->netdev_ops->ndo_get_lock_subclass(dev);
-
-	spin_lock_nested(&dev->addr_list_lock, subclass);
+	spin_lock_nested(&dev->addr_list_lock,
+			 dev->netdev_ops->ndo_get_lock_subclass ?
+			 dev->netdev_ops->ndo_get_lock_subclass(dev) :
+			 SINGLE_DEPTH_NESTING);
 }
 
 static inline void netif_addr_lock_bh(struct net_device *dev)
-- 
1.8.4.5
