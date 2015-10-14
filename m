From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v5 2/8] switchdev: make struct switchdev_attr parameter const for attr_set calls
Date: Wed, 14 Oct 2015 19:40:49 +0200
Message-ID: <1444844455-12508-3-git-send-email-jiri@resnulli.us>
References: <1444844455-12508-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	sfeldma@gmail.com, f.fainelli@gmail.com, linux@roeck-us.net,
	vivien.didelot@savoirfairelinux.com, andrew@lunn.ch,
	john.fastabend@gmail.com, David.Laight@ACULAB.COM,
	stephen@networkplumber.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:35200 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753680AbbJNRlB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Oct 2015 13:41:01 -0400
Received: by wicll6 with SMTP id ll6so7866909wic.0
        for <netdev@vger.kernel.org>; Wed, 14 Oct 2015 10:40:59 -0700 (PDT)
In-Reply-To: <1444844455-12508-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/rocker/rocker.c | 2 +-
 include/net/switchdev.h              | 6 +++---
 net/dsa/slave.c                      | 2 +-
 net/switchdev/switchdev.c            | 7 ++++---
 4 files changed, 9 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index eafa907..f0e820d 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -4374,7 +4374,7 @@ static int rocker_port_bridge_ageing_time(struct rocker_port *rocker_port,
 }
 
 static int rocker_port_attr_set(struct net_device *dev,
-				struct switchdev_attr *attr,
+				const struct switchdev_attr *attr,
 				struct switchdev_trans *trans)
 {
 	struct rocker_port *rocker_port = netdev_priv(dev);
diff --git a/include/net/switchdev.h b/include/net/switchdev.h
index 31b9038..d1c7f90 100644
--- a/include/net/switchdev.h
+++ b/include/net/switchdev.h
@@ -132,7 +132,7 @@ struct switchdev_ops {
 	int	(*switchdev_port_attr_get)(struct net_device *dev,
 					   struct switchdev_attr *attr);
 	int	(*switchdev_port_attr_set)(struct net_device *dev,
-					   struct switchdev_attr *attr,
+					   const struct switchdev_attr *attr,
 					   struct switchdev_trans *trans);
 	int	(*switchdev_port_obj_add)(struct net_device *dev,
 					  const struct switchdev_obj *obj,
@@ -171,7 +171,7 @@ void switchdev_deferred_process(void);
 int switchdev_port_attr_get(struct net_device *dev,
 			    struct switchdev_attr *attr);
 int switchdev_port_attr_set(struct net_device *dev,
-			    struct switchdev_attr *attr);
+			    const struct switchdev_attr *attr);
 int switchdev_port_obj_add(struct net_device *dev,
 			   const struct switchdev_obj *obj);
 int switchdev_port_obj_del(struct net_device *dev,
@@ -220,7 +220,7 @@ static inline int switchdev_port_attr_get(struct net_device *dev,
 }
 
 static inline int switchdev_port_attr_set(struct net_device *dev,
-					  struct switchdev_attr *attr)
+					  const struct switchdev_attr *attr)
 {
 	return -EOPNOTSUPP;
 }
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 43d7342..84cd863 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -453,7 +453,7 @@ static int dsa_slave_stp_update(struct net_device *dev, u8 state)
 }
 
 static int dsa_slave_port_attr_set(struct net_device *dev,
-				   struct switchdev_attr *attr,
+				   const struct switchdev_attr *attr,
 				   struct switchdev_trans *trans)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index 5e64b59..23b4e5b 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -215,7 +215,7 @@ int switchdev_port_attr_get(struct net_device *dev, struct switchdev_attr *attr)
 EXPORT_SYMBOL_GPL(switchdev_port_attr_get);
 
 static int __switchdev_port_attr_set(struct net_device *dev,
-				     struct switchdev_attr *attr,
+				     const struct switchdev_attr *attr,
 				     struct switchdev_trans *trans)
 {
 	const struct switchdev_ops *ops = dev->switchdev_ops;
@@ -274,7 +274,7 @@ static void switchdev_port_attr_set_work(struct work_struct *work)
 }
 
 static int switchdev_port_attr_set_defer(struct net_device *dev,
-					 struct switchdev_attr *attr)
+					 const struct switchdev_attr *attr)
 {
 	struct switchdev_attr_set_work *asw;
 
@@ -303,7 +303,8 @@ static int switchdev_port_attr_set_defer(struct net_device *dev,
  *	system is not left in a partially updated state due to
  *	failure from driver/device.
  */
-int switchdev_port_attr_set(struct net_device *dev, struct switchdev_attr *attr)
+int switchdev_port_attr_set(struct net_device *dev,
+			    const struct switchdev_attr *attr)
 {
 	struct switchdev_trans trans;
 	int err;
-- 
1.9.3
