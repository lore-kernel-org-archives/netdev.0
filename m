From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: [PATCH 9/9] net_device: dont include wext bits if not required
Date: Tue, 24 Apr 2007 20:07:41 +0200
Message-ID: <20070424180850.595757000@sipsolutions.net>
References: <20070424180732.371620000@sipsolutions.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	jt-sDzT885Ts8HQT0dZR+AlfA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline; filename=netdev-wext.patch
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch makes the wext bits in struct net_device depend on
CONFIG_WIRELESS_EXT.

Signed-off-by: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>

---
 include/linux/netdevice.h |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

--- net-2.6.22.orig/include/linux/netdevice.h	2007-04-24 19:36:59.248804911 +0200
+++ net-2.6.22/include/linux/netdevice.h	2007-04-24 19:37:31.608804911 +0200
@@ -352,12 +352,13 @@ struct net_device
 	struct net_device_stats* (*get_stats)(struct net_device *dev);
 	struct net_device_stats	stats;
 
+#ifdef CONFIG_WIRELESS_EXT
 	/* List of functions to handle Wireless Extensions (instead of ioctl).
 	 * See <net/iw_handler.h> for details. Jean II */
 	const struct iw_handler_def *	wireless_handlers;
 	/* Instance data managed by the core of Wireless Extensions. */
 	struct iw_public_data *	wireless_data;
-
+#endif
 	const struct ethtool_ops *ethtool_ops;
 
 	/*

--
