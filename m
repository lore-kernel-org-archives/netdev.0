From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH v3 net-next 03/27] net: uninline netdev neighbour functions
Date: Tue, 17 Sep 2013 02:46:28 +0200
Message-ID: <1379378812-18346-4-git-send-email-vfalico@redhat.com>
References: <1379378812-18346-1-git-send-email-vfalico@redhat.com>
Cc: jiri@resnulli.us, Veaceslav Falico <vfalico@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:11036 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751416Ab3IQAqz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Sep 2013 20:46:55 -0400
In-Reply-To: <1379378812-18346-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

They don't give almost any speed/size advantage, however it's really
useful to have them in the backtrace.

CC: "David S. Miller" <davem@davemloft.net>
CC: Eric Dumazet <edumazet@google.com>
CC: Jiri Pirko <jiri@resnulli.us>
CC: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---

Notes:
    v2  -> v3:
    No change.
    
    v1  -> v2:
    No changes.
    
    RFC -> v1:
    New patch.

 net/core/dev.c | 22 +++++++++++-----------
 1 file changed, 11 insertions(+), 11 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 75eabef..d277081 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4684,25 +4684,25 @@ void __netdev_adjacent_dev_remove(struct net_device *dev,
 	kfree_rcu(adj, rcu);
 }
 
-static inline void __netdev_upper_dev_remove(struct net_device *dev,
-					     struct net_device *udev)
+static void __netdev_upper_dev_remove(struct net_device *dev,
+				      struct net_device *udev)
 {
 	return __netdev_adjacent_dev_remove(dev, udev, true, false);
 }
 
-static inline void __netdev_upper_dev_remove_neighbour(struct net_device *dev,
+static void __netdev_upper_dev_remove_neighbour(struct net_device *dev,
 						struct net_device *udev)
 {
 	return __netdev_adjacent_dev_remove(dev, udev, true, true);
 }
 
-static inline void __netdev_lower_dev_remove(struct net_device *dev,
-					     struct net_device *ldev)
+static void __netdev_lower_dev_remove(struct net_device *dev,
+				      struct net_device *ldev)
 {
 	return __netdev_adjacent_dev_remove(dev, ldev, false, false);
 }
 
-static inline void __netdev_lower_dev_remove_neighbour(struct net_device *dev,
+static void __netdev_lower_dev_remove_neighbour(struct net_device *dev,
 						struct net_device *ldev)
 {
 	return __netdev_adjacent_dev_remove(dev, ldev, false, true);
@@ -4727,15 +4727,15 @@ int __netdev_adjacent_dev_insert_link(struct net_device *dev,
 	return 0;
 }
 
-static inline int __netdev_adjacent_dev_link(struct net_device *dev,
-					     struct net_device *udev)
+static int __netdev_adjacent_dev_link(struct net_device *dev,
+				      struct net_device *udev)
 {
 	return __netdev_adjacent_dev_insert_link(dev, udev, false, false);
 }
 
-static inline int __netdev_adjacent_dev_link_neighbour(struct net_device *dev,
-						       struct net_device *udev,
-						       bool master)
+static int __netdev_adjacent_dev_link_neighbour(struct net_device *dev,
+						struct net_device *udev,
+						bool master)
 {
 	return __netdev_adjacent_dev_insert_link(dev, udev, master, true);
 }
-- 
1.8.4
