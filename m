From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net] Revert "hv_netvsc: report vmbus name in ethtool"
Date: Wed, 26 Oct 2016 09:27:53 -0700
Message-ID: <20161026092753.1555a5ac@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
        KY Srinivasan <kys@microsoft.com>,
        Vitaly Kuznetsov <vkuznets@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:34604 "EHLO
        mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934301AbcJZQ1h (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Oct 2016 12:27:37 -0400
Received: by mail-pf0-f178.google.com with SMTP id n85so25766399pfi.1
        for <netdev@vger.kernel.org>; Wed, 26 Oct 2016 09:27:36 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <sthemmin@microsoft.com>

This reverts commit e3f74b841d48
("hv_netvsc: report vmbus name in ethtool")'
because of problem introduced by commit f9a56e5d6a0ba
("Drivers: hv: make VMBus bus ids persistent").
This changed the format of the vmbus name and this new format is too
long to fit in the bus_info field of ethtool.

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>

---
 drivers/net/hyperv/netvsc_drv.c | 4 ----
 include/linux/hyperv.h          | 7 -------
 2 files changed, 11 deletions(-)

diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index c71d966..f638215 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -699,12 +699,8 @@ int netvsc_recv_callback(struct hv_device *device_obj,
 static void netvsc_get_drvinfo(struct net_device *net,
 			       struct ethtool_drvinfo *info)
 {
-	struct net_device_context *net_device_ctx = netdev_priv(net);
-	struct hv_device *dev = net_device_ctx->device_ctx;
-
 	strlcpy(info->driver, KBUILD_MODNAME, sizeof(info->driver));
 	strlcpy(info->fw_version, "N/A", sizeof(info->fw_version));
-	strlcpy(info->bus_info, vmbus_dev_name(dev), sizeof(info->bus_info));
 }
 
 static void netvsc_get_channels(struct net_device *net,
diff --git a/include/linux/hyperv.h b/include/linux/hyperv.h
index 6824556..cd184bd 100644
--- a/include/linux/hyperv.h
+++ b/include/linux/hyperv.h
@@ -1169,13 +1169,6 @@ int __must_check __vmbus_driver_register(struct hv_driver *hv_driver,
 					 const char *mod_name);
 void vmbus_driver_unregister(struct hv_driver *hv_driver);
 
-static inline const char *vmbus_dev_name(const struct hv_device *device_obj)
-{
-	const struct kobject *kobj = &device_obj->device.kobj;
-
-	return kobj->name;
-}
-
 void vmbus_hvsock_device_unregister(struct vmbus_channel *channel);
 
 int vmbus_allocate_mmio(struct resource **new, struct hv_device *device_obj,
-- 
2.9.3
