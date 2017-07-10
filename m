From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: [PATCH 1/2] netdevice: add netdev_pub helper function
Date: Mon, 10 Jul 2017 05:19:58 +0200
Message-ID: <20170710031959.7496-1-Jason@zx2c4.com>
References: <20150612.142058.1085284048217032168.davem@davemloft.net>
Cc: "Jason A. Donenfeld" <Jason@zx2c4.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150612.142058.1085284048217032168.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Being able to utilize this makes code a lot simpler and cleaner. It's
easier in many cases for drivers to pass around their private data
structure, while occationally needing to dip into net_device, rather
than the other way around, which results in tons of calls to netdev_priv
in the top of every single function, which makes everything confusing
and less clear. Additionally, this enables a "correct" way of doing such
a thing, instead of having drivers attempt to reinvent the wheel and
screw it up.

Signed-off-by: Jason A. Donenfeld <Jason@zx2c4.com>
---
 include/linux/netdevice.h | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 779b23595596..83d58504e5c4 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2030,26 +2030,37 @@ void dev_net_set(struct net_device *dev, struct net *net)
 }
 
 /**
  *	netdev_priv - access network device private data
  *	@dev: network device
  *
  * Get network device private data
  */
 static inline void *netdev_priv(const struct net_device *dev)
 {
 	return (char *)dev + ALIGN(sizeof(struct net_device), NETDEV_ALIGN);
 }
 
+/**
+ * 	netdev_pub - access network device from private pointer
+ * 	@priv: private data pointer of network device
+ *
+ * Get network device from a network device private data pointer
+ */
+static inline struct net_device *netdev_pub(void *priv)
+{
+	return (struct net_device *)((char *)priv - ALIGN(sizeof(struct net_device), NETDEV_ALIGN));
+}
+
 /* Set the sysfs physical device reference for the network logical device
  * if set prior to registration will cause a symlink during initialization.
  */
 #define SET_NETDEV_DEV(net, pdev)	((net)->dev.parent = (pdev))
 
 /* Set the sysfs device type for the network logical device to allow
  * fine-grained identification of different network device types. For
  * example Ethernet, Wireless LAN, Bluetooth, WiMAX etc.
  */
 #define SET_NETDEV_DEVTYPE(net, devtype)	((net)->dev.type = (devtype))
 
 /* Default NAPI poll() weight
  * Device drivers are strongly advised to not use bigger value
-- 
2.13.2
