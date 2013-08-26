From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH net-next v1 2/9] net: add netdev_for_each_upper_dev()
Date: Mon, 26 Aug 2013 22:32:35 +0200
Message-ID: <1377549162-7522-3-git-send-email-vfalico@redhat.com>
References: <1377549162-7522-1-git-send-email-vfalico@redhat.com>
Cc: Veaceslav Falico <vfalico@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49264 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752442Ab3HZUcf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Aug 2013 16:32:35 -0400
In-Reply-To: <1377549162-7522-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The new macro netdev_for_each_upper_dev(dev, upper, iter) iterates through
the dev->upper_dev_list starting from the first element, using the
netdev_upper_get_next_dev(dev, &iter).

Must be called under RCU read lock.

v1: new patch

CC: "David S. Miller" <davem@davemloft.net>
CC: Eric Dumazet <edumazet@google.com>
CC: Jiri Pirko <jiri@resnulli.us>
CC: Alexander Duyck <alexander.h.duyck@intel.com>
CC: Cong Wang <amwang@redhat.com>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---
 include/linux/netdevice.h |   10 ++++++++++
 1 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 077363d..85590b6 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2767,6 +2767,16 @@ extern int		bpf_jit_enable;
 extern bool netdev_has_upper_dev(struct net_device *dev,
 				 struct net_device *upper_dev);
 extern bool netdev_has_any_upper_dev(struct net_device *dev);
+extern struct net_device *netdev_upper_get_next_dev(struct net_device *dev,
+						    struct list_head **iter);
+
+/* iterate through upper list, must be called under RCU read lock */
+#define netdev_for_each_upper_dev(dev, upper, iter) \
+	for (iter = &(dev)->upper_dev_list, \
+	     upper = netdev_upper_get_next_dev(dev, &(iter)); \
+	     upper; \
+	     upper = netdev_upper_get_next_dev(dev, &(iter)))
+
 extern struct net_device *netdev_master_upper_dev_get(struct net_device *dev);
 extern struct net_device *netdev_master_upper_dev_get_rcu(struct net_device *dev);
 extern int netdev_upper_dev_link(struct net_device *dev,
-- 
1.7.1
