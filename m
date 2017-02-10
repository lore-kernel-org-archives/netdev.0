From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH net-next] net: make net_device members garp_port and mrp_port conditional
Date: Fri, 10 Feb 2017 16:43:50 +0100
Message-ID: <20170210154350.11694-1-tklauser@distanz.ch>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.zhinst.com ([212.126.164.98]:52784 "EHLO mail.zhinst.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752513AbdBJPpe (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 10 Feb 2017 10:45:34 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

garp_port is only used in net/802/garp.c which is only compiled with
CONFIG_GARP enabled. Same goes for mrp_port which is only used in
net/802/mrp.c with CONFIG_MRP enabled.

Only include the two members in struct net_device if their respective
CONFIG_* is enabled. This saves a few bytes in struct net_device in case
CONFIG_GARP or CONFIG_MRP are not enabled.

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 include/linux/netdevice.h | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 58afbd1cc659..7bb38f2c65c2 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1863,8 +1863,12 @@ struct net_device {
 		struct pcpu_vstats __percpu		*vstats;
 	};
 
+#if IS_ENABLED(CONFIG_GARP)
 	struct garp_port __rcu	*garp_port;
+#endif
+#if IS_ENABLED(CONFIG_MRP)
 	struct mrp_port __rcu	*mrp_port;
+#endif
 
 	struct device		dev;
 	const struct attribute_group *sysfs_groups[4];
-- 
2.11.0
