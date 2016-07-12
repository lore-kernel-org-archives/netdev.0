From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 07/10] net/switchdev: Export the same parent ID service function
Date: Wed, 13 Jul 2016 00:29:03 +0300
Message-ID: <1468358946-28709-8-git-send-email-saeedm@mellanox.com>
References: <1468358946-28709-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Hadar Hen-Zion <hadarh@mellanox.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Amir Vadai <amir@vadai.me>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:51245 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751084AbcGLVbA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Jul 2016 17:31:00 -0400
In-Reply-To: <1468358946-28709-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>

This helper serves to know if two switchdev port netdevices belong to the
same HW ASIC, e.g to figure out if forwarding offload is possible between them.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 include/net/switchdev.h   | 8 ++++++++
 net/switchdev/switchdev.c | 5 +++--
 2 files changed, 11 insertions(+), 2 deletions(-)

diff --git a/include/net/switchdev.h b/include/net/switchdev.h
index 985619a..9023e3e 100644
--- a/include/net/switchdev.h
+++ b/include/net/switchdev.h
@@ -227,6 +227,8 @@ void switchdev_port_fwd_mark_set(struct net_device *dev,
 				 struct net_device *group_dev,
 				 bool joining);
 
+bool switchdev_port_same_parent_id(struct net_device *a,
+				   struct net_device *b);
 #else
 
 static inline void switchdev_deferred_process(void)
@@ -351,6 +353,12 @@ static inline void switchdev_port_fwd_mark_set(struct net_device *dev,
 {
 }
 
+static inline bool switchdev_port_same_parent_id(struct net_device *a,
+						 struct net_device *b)
+{
+	return false;
+}
+
 #endif
 
 #endif /* _LINUX_SWITCHDEV_H_ */
diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index 59658b2..a5fc9dd 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -1286,8 +1286,8 @@ void switchdev_fib_ipv4_abort(struct fib_info *fi)
 }
 EXPORT_SYMBOL_GPL(switchdev_fib_ipv4_abort);
 
-static bool switchdev_port_same_parent_id(struct net_device *a,
-					  struct net_device *b)
+bool switchdev_port_same_parent_id(struct net_device *a,
+				   struct net_device *b)
 {
 	struct switchdev_attr a_attr = {
 		.orig_dev = a,
@@ -1323,6 +1323,7 @@ static u32 switchdev_port_fwd_mark_get(struct net_device *dev,
 
 	return dev->ifindex;
 }
+EXPORT_SYMBOL_GPL(switchdev_port_same_parent_id);
 
 static void switchdev_port_fwd_mark_reset(struct net_device *group_dev,
 					  u32 old_mark, u32 *reset_mark)
-- 
2.8.0
