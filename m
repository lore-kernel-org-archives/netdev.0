From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [PATCH 2.6.33/1 06/12] i2400m: minimal ethtool support
Date: Wed,  4 Nov 2009 13:39:42 -0800
Message-ID: <abb307338396bd58f5d9d32c4e56ef40ff668a74.1257370735.git.inaky@linux.intel.com>
References: <cover.1257370735.git.inaky@linux.intel.com>
Cc: Dan Williams <dcbw@redhat.com>
To: netdev@vger.kernel.org, wimax@linuxwimax.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.89]:28801 "EHLO
	fmsmga101.fm.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758262AbZKDVlw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2009 16:41:52 -0500
In-Reply-To: <cover.1257370735.git.inaky@linux.intel.com>
In-Reply-To: <cover.1257370735.git.inaky@linux.intel.com>
References: <cover.1257370735.git.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Williams <dcbw@redhat.com>

Add minimal ethtool support for carrier detection.

Signed-off-by: Dan Williams <dcbw@redhat.com>
Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
---
 drivers/net/wimax/i2400m/netdev.c |   18 ++++++++++++++++++
 1 files changed, 18 insertions(+), 0 deletions(-)

diff --git a/drivers/net/wimax/i2400m/netdev.c b/drivers/net/wimax/i2400m/netdev.c
index 796396c..960fb54 100644
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
-- 
1.6.2.5

