From: Michal Kubecek <mkubecek@suse.cz>
Subject: [PATCH net v2 1/2] macvlan: introduce macvlan_dev_real_dev() helper
 function
Date: Thu, 14 Nov 2013 15:00:16 +0100 (CET)
Message-ID: <b4ca4f2204f0ffb0bd7f959192462944a8d846a4.1384436410.git.mkubecek@suse.cz>
References: <cover.1384436410.git.mkubecek@suse.cz>
Cc: "David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	John Fastabend <john.r.fastabend@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:53411 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753634Ab3KNOAR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Nov 2013 09:00:17 -0500
In-Reply-To: <cover.1384436410.git.mkubecek@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Introduce helper function macvlan_dev_real_dev which returns the
underlying device of a macvlan device, similar to vlan_dev_real_dev()
for 802.1q VLAN devices.

v2: IFF_MACVLAN flag and equivalent of is_macvlan_dev() were
introduced in the meantime

Signed-off-by: Michal Kubecek <mkubecek@suse.cz>
---
 include/linux/if_macvlan.h | 16 ++++++++++++++++
 1 file changed, 16 insertions(+)

diff --git a/include/linux/if_macvlan.h b/include/linux/if_macvlan.h
index c270285..ac9aab2 100644
--- a/include/linux/if_macvlan.h
+++ b/include/linux/if_macvlan.h
@@ -119,4 +119,20 @@ extern int macvlan_link_register(struct rtnl_link_ops *ops);
 extern netdev_tx_t macvlan_start_xmit(struct sk_buff *skb,
 				      struct net_device *dev);
 
+#if IS_ENABLED(CONFIG_MACVLAN)
+static inline struct net_device *
+macvlan_dev_real_dev(const struct net_device *dev)
+{
+	struct macvlan_dev *macvlan = netdev_priv(dev);
+
+	return macvlan->lowerdev;
+}
+#else
+static inline struct net_device *
+macvlan_dev_real_dev(const struct net_device *dev)
+{
+	return NULL;
+}
+#endif
+
 #endif /* _LINUX_IF_MACVLAN_H */
-- 
1.8.1.4
