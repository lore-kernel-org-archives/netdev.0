From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH net-next v4 01/13] net: rename netdev_upper to netdev_adjacent
Date: Wed, 28 Aug 2013 23:25:04 +0200
Message-ID: <1377725116-31126-2-git-send-email-vfalico@redhat.com>
References: <1377725116-31126-1-git-send-email-vfalico@redhat.com>
Cc: Veaceslav Falico <vfalico@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:28381 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753024Ab3H1VZA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Aug 2013 17:25:00 -0400
In-Reply-To: <1377725116-31126-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rename the structure to reflect the upcoming addition of lower_dev_list.

CC: "David S. Miller" <davem@davemloft.net>
CC: Eric Dumazet <edumazet@google.com>
CC: Jiri Pirko <jiri@resnulli.us>
CC: Alexander Duyck <alexander.h.duyck@intel.com>
CC: Cong Wang <amwang@redhat.com>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---

Notes:
    v2: new patch
    v3: actually rename everything
    v4: no change

 net/core/dev.c | 24 ++++++++++++------------
 1 file changed, 12 insertions(+), 12 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 1ed2b66..5072e2c 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4367,7 +4367,7 @@ softnet_break:
 	goto out;
 }
 
-struct netdev_upper {
+struct netdev_adjacent {
 	struct net_device *dev;
 	bool master;
 	struct list_head list;
@@ -4378,7 +4378,7 @@ struct netdev_upper {
 static void __append_search_uppers(struct list_head *search_list,
 				   struct net_device *dev)
 {
-	struct netdev_upper *upper;
+	struct netdev_adjacent *upper;
 
 	list_for_each_entry(upper, &dev->upper_dev_list, list) {
 		/* check if this upper is not already in search list */
@@ -4391,8 +4391,8 @@ static bool __netdev_search_upper_dev(struct net_device *dev,
 				      struct net_device *upper_dev)
 {
 	LIST_HEAD(search_list);
-	struct netdev_upper *upper;
-	struct netdev_upper *tmp;
+	struct netdev_adjacent *upper;
+	struct netdev_adjacent *tmp;
 	bool ret = false;
 
 	__append_search_uppers(&search_list, dev);
@@ -4408,10 +4408,10 @@ static bool __netdev_search_upper_dev(struct net_device *dev,
 	return ret;
 }
 
-static struct netdev_upper *__netdev_find_upper(struct net_device *dev,
+static struct netdev_adjacent *__netdev_find_upper(struct net_device *dev,
 						struct net_device *upper_dev)
 {
-	struct netdev_upper *upper;
+	struct netdev_adjacent *upper;
 
 	list_for_each_entry(upper, &dev->upper_dev_list, list) {
 		if (upper->dev == upper_dev)
@@ -4462,7 +4462,7 @@ EXPORT_SYMBOL(netdev_has_any_upper_dev);
  */
 struct net_device *netdev_master_upper_dev_get(struct net_device *dev)
 {
-	struct netdev_upper *upper;
+	struct netdev_adjacent *upper;
 
 	ASSERT_RTNL();
 
@@ -4470,7 +4470,7 @@ struct net_device *netdev_master_upper_dev_get(struct net_device *dev)
 		return NULL;
 
 	upper = list_first_entry(&dev->upper_dev_list,
-				 struct netdev_upper, list);
+				 struct netdev_adjacent, list);
 	if (likely(upper->master))
 		return upper->dev;
 	return NULL;
@@ -4486,10 +4486,10 @@ EXPORT_SYMBOL(netdev_master_upper_dev_get);
  */
 struct net_device *netdev_master_upper_dev_get_rcu(struct net_device *dev)
 {
-	struct netdev_upper *upper;
+	struct netdev_adjacent *upper;
 
 	upper = list_first_or_null_rcu(&dev->upper_dev_list,
-				       struct netdev_upper, list);
+				       struct netdev_adjacent, list);
 	if (upper && likely(upper->master))
 		return upper->dev;
 	return NULL;
@@ -4499,7 +4499,7 @@ EXPORT_SYMBOL(netdev_master_upper_dev_get_rcu);
 static int __netdev_upper_dev_link(struct net_device *dev,
 				   struct net_device *upper_dev, bool master)
 {
-	struct netdev_upper *upper;
+	struct netdev_adjacent *upper;
 
 	ASSERT_RTNL();
 
@@ -4580,7 +4580,7 @@ EXPORT_SYMBOL(netdev_master_upper_dev_link);
 void netdev_upper_dev_unlink(struct net_device *dev,
 			     struct net_device *upper_dev)
 {
-	struct netdev_upper *upper;
+	struct netdev_adjacent *upper;
 
 	ASSERT_RTNL();
 
-- 
1.8.4
