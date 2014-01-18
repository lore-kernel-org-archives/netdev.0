From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next] bonding: move the netdev_add_tso_features() to bonding
 module
Date: Sat, 18 Jan 2014 16:31:33 +0800
Message-ID: <52DA3BE5.5020500@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Jay Vosburgh <fubar@us.ibm.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:31049 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752625AbaARIcI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Jan 2014 03:32:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The function netdev_add_tso_features() was only be used for bonding,
so no need to export it in netdevice.h, move it to bonding module.

Cc: Eric Dumazet <edumazet@google.com>
Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/bonding/bond_main.c | 12 +++++++++++-
 include/linux/netdevice.h       | 10 ----------
 2 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index e06c445..4cfe14e 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1045,6 +1045,16 @@ static void bond_netpoll_cleanup(struct net_device *bond_dev)
 
 /*---------------------------------- IOCTL ----------------------------------*/
 
+/* Allow TSO being used on stacked device:
+ * Performing the GSO segmentation before last device
+ * is a performance improvement.
+ */
+static netdev_features_t bond_add_tso_features(netdev_features_t features,
+					       netdev_features_t mask)
+{
+	return netdev_increment_features(features, NETIF_F_ALL_TSO, mask);
+}
+
 static netdev_features_t bond_fix_features(struct net_device *dev,
 					   netdev_features_t features)
 {
@@ -1068,7 +1078,7 @@ static netdev_features_t bond_fix_features(struct net_device *dev,
 						     slave->dev->features,
 						     mask);
 	}
-	features = netdev_add_tso_features(features, mask);
+	features = bond_add_tso_features(features, mask);
 
 	return features;
 }
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index a2a70cc..1be74ea 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -3010,16 +3010,6 @@ static inline netdev_features_t netdev_get_wanted_features(
 netdev_features_t netdev_increment_features(netdev_features_t all,
 	netdev_features_t one, netdev_features_t mask);
 
-/* Allow TSO being used on stacked device :
- * Performing the GSO segmentation before last device
- * is a performance improvement.
- */
-static inline netdev_features_t netdev_add_tso_features(netdev_features_t features,
-							netdev_features_t mask)
-{
-	return netdev_increment_features(features, NETIF_F_ALL_TSO, mask);
-}
-
 int __netdev_update_features(struct net_device *dev);
 void netdev_update_features(struct net_device *dev);
 void netdev_change_features(struct net_device *dev);
-- 
1.8.0
