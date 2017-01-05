From: Phil Sutter <phil@nwl.cc>
Subject: [net-next PATCH v6 1/3] net: net_device_ops: Introduce ndo_get_vf_count
Date: Thu,  5 Jan 2017 20:09:11 +0100
Message-ID: <20170105190913.29986-2-phil@nwl.cc>
References: <20170105190913.29986-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:48291 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754433AbdAETJa (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 5 Jan 2017 14:09:30 -0500
In-Reply-To: <20170105190913.29986-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The idea is to allow drivers to implement this callback in order to
provide a custom way to return the number of virtual functions present
on the device.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
Changes since v5:
- Introduced this patch.
---
 include/linux/netdevice.h | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index ecd78b3c9abad..a04a693f55065 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -964,6 +964,10 @@ struct netdev_xdp {
  *      with PF and querying it may introduce a theoretical security risk.
  * int (*ndo_set_vf_rss_query_en)(struct net_device *dev, int vf, bool setting);
  * int (*ndo_get_vf_port)(struct net_device *dev, int vf, struct sk_buff *skb);
+ * int (*ndo_get_vf_count)(const struct net_device *dev);
+ *	Return the number of VFs present on this device instead of having
+ *	rtnetlink use pci_num_vf() on the PCI parent device.
+ *
  * int (*ndo_setup_tc)(struct net_device *dev, u8 tc)
  * 	Called to setup 'tc' number of traffic classes in the net device. This
  * 	is always called from the stack with the rtnl lock held and netif tx
@@ -1218,6 +1222,7 @@ struct net_device_ops {
 	int			(*ndo_set_vf_rss_query_en)(
 						   struct net_device *dev,
 						   int vf, bool setting);
+	int			(*ndo_get_vf_count)(const struct net_device *dev);
 	int			(*ndo_setup_tc)(struct net_device *dev,
 						u32 handle,
 						__be16 protocol,
-- 
2.11.0
