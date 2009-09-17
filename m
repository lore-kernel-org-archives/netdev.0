From: Dan Williams <dcbw@redhat.com>
Subject: [PATCH] i2400m: minimal ethtool support
Date: Thu, 17 Sep 2009 13:06:14 -0700
Message-ID: <1253217974.11454.12.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "wimax@linuxwimax.org" <wimax@linuxwimax.org>,
	netdev@vger.kernel.org
To: Inaky Perez-Gonzalez <inaky.perez-gonzalez@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60322 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752735AbZIQUF2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Sep 2009 16:05:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add minimal ethtool support for carrier detection.

Signed-off-by: Dan Williams <dcbw@redhat.com>


diff --git a/drivers/net/wimax/i2400m/netdev.c b/drivers/net/wimax/i2400m/netdev.c
index 9653f47..c915775 100644
--- a/drivers/net/wimax/i2400m/netdev.c
+++ b/drivers/net/wimax/i2400m/netdev.c
@@ -74,6 +74,7 @@
  */
 #include <linux/if_arp.h>
 #include <linux/netdevice.h>
+#include <linux/ethtool.h>
 #include "i2400m.h"
 
 
@@ -559,6 +560,22 @@ static const struct net_device_ops i2400m_netdev_ops = {
 	.ndo_change_mtu = i2400m_change_mtu,
 };
 
+static void i2400m_get_drvinfo(struct net_device *net_dev,
+			       struct ethtool_drvinfo *info)
+{
+	struct i2400m *i2400m = net_dev_to_i2400m(net_dev);
+
+	strncpy(info->driver, KBUILD_MODNAME, sizeof(info->driver) - 1);
+	strncpy(info->fw_version, i2400m->fw_name, sizeof(info->fw_version) - 1);
+	if (net_dev->dev.parent)
+		strncpy(info->bus_info, dev_name(net_dev->dev.parent),
+			sizeof(info->bus_info) - 1);
+}
+
+static const struct ethtool_ops i2400m_ethtool_ops = {
+	.get_drvinfo = i2400m_get_drvinfo,
+	.get_link = ethtool_op_get_link,
+};
 
 /**
  * i2400m_netdev_setup - Setup setup @net_dev's i2400m private data
@@ -580,6 +597,7 @@ void i2400m_netdev_setup(struct net_device *net_dev)
 		   & ~IFF_MULTICAST);
 	net_dev->watchdog_timeo = I2400M_TX_TIMEOUT;
 	net_dev->netdev_ops = &i2400m_netdev_ops;
+	net_dev->ethtool_ops = &i2400m_ethtool_ops;
 	d_fnend(3, NULL, "(net_dev %p) = void\n", net_dev);
 }
 EXPORT_SYMBOL_GPL(i2400m_netdev_setup);

