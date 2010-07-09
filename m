From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6 2/2] net: Document that dev_get_stats()
 returns the given pointer
Date: Fri, 09 Jul 2010 20:12:41 +0100
Message-ID: <1278702761.2078.14.camel@achroite.uk.solarflarecom.com>
References: <1278702713.2078.13.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com,
	Eric Dumazet <eric.dumazet@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:23591 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751108Ab0GITMp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jul 2010 15:12:45 -0400
In-Reply-To: <1278702713.2078.13.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Document that dev_get_stats() returns the same stats pointer it was
given.  Remove const qualification from the returned pointer since the
caller may do what it likes with that structure.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 include/linux/netdevice.h |    4 ++--
 net/core/dev.c            |   12 ++++++------
 2 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 17e95e3..c4fedf0 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2130,8 +2130,8 @@ extern void		netdev_features_change(struct net_device *dev);
 /* Load a device via the kmod */
 extern void		dev_load(struct net *net, const char *name);
 extern void		dev_mcast_init(void);
-extern const struct rtnl_link_stats64 *dev_get_stats(struct net_device *dev,
-						     struct rtnl_link_stats64 *storage);
+extern struct rtnl_link_stats64 *dev_get_stats(struct net_device *dev,
+					       struct rtnl_link_stats64 *storage);
 extern void		dev_txq_stats_fold(const struct net_device *dev,
 					   struct rtnl_link_stats64 *stats);
 
diff --git a/net/core/dev.c b/net/core/dev.c
index 79ee26e..e2b9fa2 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5323,13 +5323,13 @@ static void netdev_stats_to_stats64(struct rtnl_link_stats64 *stats64,
  *	@dev: device to get statistics from
  *	@storage: place to store stats
  *
- *	Get network statistics from device. The device driver may provide
- *	its own method by setting dev->netdev_ops->get_stats64 or
- *	dev->netdev_ops->get_stats; otherwise the internal statistics
- *	structure is used.
+ *	Get network statistics from device. Return @storage.
+ *	The device driver may provide its own method by setting
+ *	dev->netdev_ops->get_stats64 or dev->netdev_ops->get_stats;
+ *	otherwise the internal statistics structure is used.
  */
-const struct rtnl_link_stats64 *dev_get_stats(struct net_device *dev,
-					      struct rtnl_link_stats64 *storage)
+struct rtnl_link_stats64 *dev_get_stats(struct net_device *dev,
+					struct rtnl_link_stats64 *storage)
 {
 	const struct net_device_ops *ops = dev->netdev_ops;
 
-- 
1.6.2.5

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

