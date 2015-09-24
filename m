From: Michal Kubecek <mkubecek@suse.cz>
Subject: [PATCH net-next] net: remove unused argument of __netdev_find_adj()
Date: Thu, 24 Sep 2015 10:59:05 +0200 (CEST)
Message-ID: <20150924085905.5ADC2A572E@unicorn.suse.cz>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The __netdev_find_adj() helper does not use its first argument, only the
device to find and list to walk through.

Signed-off-by: Michal Kubecek <mkubecek@suse.cz>
---
 net/core/dev.c | 15 +++++++--------
 1 file changed, 7 insertions(+), 8 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index ee0d6286f934..464c22b6261a 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4865,8 +4865,7 @@ struct netdev_adjacent {
 	struct rcu_head rcu;
 };
 
-static struct netdev_adjacent *__netdev_find_adj(struct net_device *dev,
-						 struct net_device *adj_dev,
+static struct netdev_adjacent *__netdev_find_adj(struct net_device *adj_dev,
 						 struct list_head *adj_list)
 {
 	struct netdev_adjacent *adj;
@@ -4892,7 +4891,7 @@ bool netdev_has_upper_dev(struct net_device *dev,
 {
 	ASSERT_RTNL();
 
-	return __netdev_find_adj(dev, upper_dev, &dev->all_adj_list.upper);
+	return __netdev_find_adj(upper_dev, &dev->all_adj_list.upper);
 }
 EXPORT_SYMBOL(netdev_has_upper_dev);
 
@@ -5154,7 +5153,7 @@ static int __netdev_adjacent_dev_insert(struct net_device *dev,
 	struct netdev_adjacent *adj;
 	int ret;
 
-	adj = __netdev_find_adj(dev, adj_dev, dev_list);
+	adj = __netdev_find_adj(adj_dev, dev_list);
 
 	if (adj) {
 		adj->ref_nr++;
@@ -5210,7 +5209,7 @@ static void __netdev_adjacent_dev_remove(struct net_device *dev,
 {
 	struct netdev_adjacent *adj;
 
-	adj = __netdev_find_adj(dev, adj_dev, dev_list);
+	adj = __netdev_find_adj(adj_dev, dev_list);
 
 	if (!adj) {
 		pr_err("tried to remove device %s from %s\n",
@@ -5331,10 +5330,10 @@ static int __netdev_upper_dev_link(struct net_device *dev,
 		return -EBUSY;
 
 	/* To prevent loops, check if dev is not upper device to upper_dev. */
-	if (__netdev_find_adj(upper_dev, dev, &upper_dev->all_adj_list.upper))
+	if (__netdev_find_adj(dev, &upper_dev->all_adj_list.upper))
 		return -EBUSY;
 
-	if (__netdev_find_adj(dev, upper_dev, &dev->adj_list.upper))
+	if (__netdev_find_adj(upper_dev, &dev->adj_list.upper))
 		return -EEXIST;
 
 	if (master && netdev_master_upper_dev_get(dev))
@@ -5612,7 +5611,7 @@ void *netdev_lower_dev_get_private(struct net_device *dev,
 
 	if (!lower_dev)
 		return NULL;
-	lower = __netdev_find_adj(dev, lower_dev, &dev->adj_list.lower);
+	lower = __netdev_find_adj(lower_dev, &dev->adj_list.lower);
 	if (!lower)
 		return NULL;
 
-- 
2.5.3
