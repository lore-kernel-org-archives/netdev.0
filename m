From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH net-next 1/8] net: move netdev_upper to netdevice.h
Date: Mon, 26 Aug 2013 18:28:46 +0200
Message-ID: <1377534533-6944-2-git-send-email-vfalico@redhat.com>
References: <1377534533-6944-1-git-send-email-vfalico@redhat.com>
Cc: Veaceslav Falico <vfalico@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:64927 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757066Ab3HZQ2v (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Aug 2013 12:28:51 -0400
In-Reply-To: <1377534533-6944-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

So that any device can work with it to see its upper/master devices. It is
rcu'd and rtnl_lock protected, so one should either hold the rtnl_lock() or
to use the _rcu() functions for it.

CC: "David S. Miller" <davem@davemloft.net>
CC: Eric Dumazet <edumazet@google.com>
CC: Jiri Pirko <jiri@resnulli.us>
CC: Alexander Duyck <alexander.h.duyck@intel.com>
CC: Cong Wang <amwang@redhat.com>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---
 include/linux/netdevice.h |    8 ++++++++
 net/core/dev.c            |    8 --------
 2 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 077363d..8cc7f43 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2764,6 +2764,14 @@ extern int		netdev_tstamp_prequeue;
 extern int		weight_p;
 extern int		bpf_jit_enable;
 
+struct netdev_upper {
+	struct net_device *dev;
+	bool master;
+	struct list_head list;
+	struct rcu_head rcu;
+	struct list_head search_list;
+};
+
 extern bool netdev_has_upper_dev(struct net_device *dev,
 				 struct net_device *upper_dev);
 extern bool netdev_has_any_upper_dev(struct net_device *dev);
diff --git a/net/core/dev.c b/net/core/dev.c
index 1ed2b66..f58e82a 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4367,14 +4367,6 @@ softnet_break:
 	goto out;
 }
 
-struct netdev_upper {
-	struct net_device *dev;
-	bool master;
-	struct list_head list;
-	struct rcu_head rcu;
-	struct list_head search_list;
-};
-
 static void __append_search_uppers(struct list_head *search_list,
 				   struct net_device *dev)
 {
-- 
1.7.1
