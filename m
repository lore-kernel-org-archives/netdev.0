From: Andy Zhou <azhou@nicira.com>
Subject: [net-next] fm10k: Add CONFIG_FM10K_VXLAN configuration option
Date: Fri,  3 Oct 2014 14:05:52 -0700
Message-ID: <1412370352-17680-1-git-send-email-azhou@nicira.com>
Cc: alexander.h.duyck@intel.com, netdev@vger.kernel.org,
	Andy Zhou <azhou@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog135.obsmtp.com ([74.125.149.84]:60525 "HELO
	na3sys009aog135.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750780AbaJCUbK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Oct 2014 16:31:10 -0400
Received: by mail-pd0-f178.google.com with SMTP id y10so171008pdj.9
        for <netdev@vger.kernel.org>; Fri, 03 Oct 2014 13:31:10 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Compiling with CONFIG_FM10K=y and VXLAN=m resulting in linking error:

   drivers/built-in.o: In function `fm10k_open':
   (.text+0x1f9d7a): undefined reference to `vxlan_get_rx_port'
   make: *** [vmlinux] Error 1

The fix follows the same strategy as I40E.

Signed-off-by: Andy Zhou <azhou@nicira.com>
---
 drivers/net/ethernet/intel/Kconfig              | 11 +++++++++++
 drivers/net/ethernet/intel/fm10k/fm10k_netdev.c |  6 +++---
 2 files changed, 14 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/Kconfig b/drivers/net/ethernet/intel/Kconfig
index 6a6d5ee..3308881 100644
--- a/drivers/net/ethernet/intel/Kconfig
+++ b/drivers/net/ethernet/intel/Kconfig
@@ -319,4 +319,15 @@ config FM10K
 	  To compile this driver as a module, choose M here. The module
 	  will be called fm10k.  MSI-X interrupt support is required
 
+config FM10K_VXLAN
+	bool "Virtual eXtensible Local Area Network Support"
+	default n
+	depends on FM10K && VXLAN && !(FM10K=y && VXLAN=m)
+	---help---
+	  This allows one to create VXLAN virtual interfaces that provide
+	  Layer 2 Networks over Layer 3 Networks. VXLAN is often used
+	  to tunnel virtual network infrastructure in virtualized environments.
+	  Say Y here if you want to use Virtual eXtensible Local Area Network
+	  (VXLAN) in the driver.
+
 endif # NET_VENDOR_INTEL
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
index dcec000..9d46333 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
@@ -20,9 +20,9 @@
 
 #include "fm10k.h"
 #include <linux/vmalloc.h>
-#if IS_ENABLED(CONFIG_VXLAN)
+#if IS_ENABLED(CONFIG_FM10K_VXLAN)
 #include <net/vxlan.h>
-#endif /* CONFIG_VXLAN */
+#endif /* CONFIG_FM10K_VXLAN */
 
 /**
  * fm10k_setup_tx_resources - allocate Tx resources (Descriptors)
@@ -552,7 +552,7 @@ int fm10k_open(struct net_device *netdev)
 	if (err)
 		goto err_set_queues;
 
-#if IS_ENABLED(CONFIG_VXLAN)
+#if IS_ENABLED(CONFIG_FM10K_VXLAN)
 	/* update VXLAN port configuration */
 	vxlan_get_rx_port(netdev);
 
-- 
1.9.1
