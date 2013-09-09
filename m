From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH net-next 03/26] net: uninline netdev neighbour functions
Date: Mon,  9 Sep 2013 22:16:21 +0200
Message-ID: <1378757804-3159-4-git-send-email-vfalico@redhat.com>
References: <1378757804-3159-1-git-send-email-vfalico@redhat.com>
Cc: jiri@resnulli.us, Veaceslav Falico <vfalico@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:22981 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755932Ab3IIUQf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Sep 2013 16:16:35 -0400
In-Reply-To: <1378757804-3159-1-git-send-email-vfalico@redhat.com>
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
 net/core/dev.c | 18 +++++++++---------
 1 file changed, 9 insertions(+), 9 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 749ec0b..eef99de 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4689,14 +4689,14 @@ void __netdev_adjacent_dev_remove(struct net_device *dev,
 	}
 }
 
-static inline void __netdev_upper_dev_remove(struct net_device *dev,
-					     struct net_device *udev)
+static void __netdev_upper_dev_remove(struct net_device *dev,
+				      struct net_device *udev)
 {
 	return __netdev_adjacent_dev_remove(dev, udev, true);
 }
 
-static inline void __netdev_lower_dev_remove(struct net_device *dev,
-					     struct net_device *ldev)
+static void __netdev_lower_dev_remove(struct net_device *dev,
+				      struct net_device *ldev)
 {
 	return __netdev_adjacent_dev_remove(dev, ldev, false);
 }
@@ -4720,15 +4720,15 @@ int __netdev_adjacent_dev_insert_link(struct net_device *dev,
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
