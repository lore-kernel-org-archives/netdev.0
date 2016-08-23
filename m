From: sthemmin@exchange.microsoft.com
Subject: [PATCH 13/14] hv_netvsc: report vmbus name in ethtool
Date: Tue, 23 Aug 2016 12:17:56 -0700
Message-ID: <1471979877-17802-13-git-send-email-sthemmin@exchange.microsoft.com>
References: <1471979877-17802-1-git-send-email-sthemmin@exchange.microsoft.com>
Reply-To: sthemmin@microsoft.com
Cc: netdev@vger.kernel.org, Stephen Hemminger <sthemmin@microsoft.com>
To: "K. Y. Srinivasan" <kys@microsoft.com>,
        Haiyang Zhang <haiyangz@microsoft.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from p3plsmtps2ded03.prod.phx3.secureserver.net ([208.109.80.60]:36674
        "EHLO p3plsmtps2ded03.prod.phx3.secureserver.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754312AbcHWSJC (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 23 Aug 2016 14:09:02 -0400
In-Reply-To: <1471979877-17802-1-git-send-email-sthemmin@exchange.microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <sthemmin@microsoft.com>

Make netvsc on vmbus behave more like PCI.

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 drivers/net/hyperv/netvsc_drv.c | 4 ++++
 include/linux/hyperv.h          | 7 +++++++
 2 files changed, 11 insertions(+)

diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index 7ed9f13..b874ab1 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -734,8 +734,12 @@ vf_injection_done:
 static void netvsc_get_drvinfo(struct net_device *net,
 			       struct ethtool_drvinfo *info)
 {
+	struct net_device_context *net_device_ctx = netdev_priv(net);
+	struct hv_device *dev = net_device_ctx->device_ctx;
+
 	strlcpy(info->driver, KBUILD_MODNAME, sizeof(info->driver));
 	strlcpy(info->fw_version, "N/A", sizeof(info->fw_version));
+	strlcpy(info->bus_info, vmbus_dev_name(dev), sizeof(info->bus_info));
 }
 
 static void netvsc_get_channels(struct net_device *net,
diff --git a/include/linux/hyperv.h b/include/linux/hyperv.h
index a6bc974..b01c8c3 100644
--- a/include/linux/hyperv.h
+++ b/include/linux/hyperv.h
@@ -1114,6 +1114,13 @@ int __must_check __vmbus_driver_register(struct hv_driver *hv_driver,
 					 const char *mod_name);
 void vmbus_driver_unregister(struct hv_driver *hv_driver);
 
+static inline const char *vmbus_dev_name(const struct hv_device *device_obj)
+{
+	const struct kobject *kobj = &device_obj->device.kobj;
+
+	return kobj->name;
+}
+
 void vmbus_hvsock_device_unregister(struct vmbus_channel *channel);
 
 int vmbus_allocate_mmio(struct resource **new, struct hv_device *device_obj,
-- 
2.9.3
