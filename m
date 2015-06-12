From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: [PATCH] netdevice: add netdev_pub helper function
Date: Fri, 12 Jun 2015 15:30:29 +0200
Message-ID: <1434115829-22804-1-git-send-email-Jason@zx2c4.com>
Cc: "Jason A. Donenfeld" <Jason@zx2c4.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Being able to utilize this makes much code a lot simpler and cleaner.
It's a nice convenience function.

Signed-off-by: Jason A. Donenfeld <Jason@zx2c4.com>
---
 include/linux/netdevice.h | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 05b9a69..f85be18 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1871,6 +1871,17 @@ static inline void *netdev_priv(const struct net_device *dev)
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
-- 
2.4.2
