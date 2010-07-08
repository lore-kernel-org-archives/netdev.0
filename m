From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6 2/2] net: Document that dev_get_stats()
 returns the given pointer
Date: Fri, 09 Jul 2010 00:30:18 +0100
Message-ID: <1278631818.16013.308.camel@achroite.uk.solarflarecom.com>
References: <1278631762.16013.307.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com,
	Eric Dumazet <eric.dumazet@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:25657 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753383Ab0GHXaV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jul 2010 19:30:21 -0400
In-Reply-To: <1278631762.16013.307.camel@achroite.uk.solarflarecom.com>
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
index 5ec2eec..2605a68 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5302,13 +5302,13 @@ EXPORT_SYMBOL(dev_txq_stats_fold);
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
 	size_t i, n = sizeof(*storage) / sizeof(u64);
-- 
1.6.2.5

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

