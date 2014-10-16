From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 3/4] fm10k: Add CONFIG_FM10K_VXLAN configuration option
Date: Thu, 16 Oct 2014 02:36:26 -0700
Message-ID: <1413452187-2950-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1413452187-2950-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Andy Zhou <azhou@nicira.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:44209 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751678AbaJPJgc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Oct 2014 05:36:32 -0400
In-Reply-To: <1413452187-2950-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Zhou <azhou@nicira.com>

Compiling with CONFIG_FM10K=y and VXLAN=m resulting in linking error:

   drivers/built-in.o: In function `fm10k_open':
   (.text+0x1f9d7a): undefined reference to `vxlan_get_rx_port'
   make: *** [vmlinux] Error 1

The fix follows the same strategy as I40E.

Signed-off-by: Andy Zhou <azhou@nicira.com>
Acked-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/Kconfig              | 11 +++++++++++
 drivers/net/ethernet/intel/fm10k/fm10k_netdev.c |  6 +++---
 2 files changed, 14 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/Kconfig b/drivers/net/ethernet/intel/Kconfig
index 6919adb..5b8300a 100644
--- a/drivers/net/ethernet/intel/Kconfig
+++ b/drivers/net/ethernet/intel/Kconfig
@@ -320,4 +320,15 @@ config FM10K
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
index b57ea1c..8811364 100644
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
@@ -556,7 +556,7 @@ int fm10k_open(struct net_device *netdev)
 	if (err)
 		goto err_set_queues;
 
-#if IS_ENABLED(CONFIG_VXLAN)
+#if IS_ENABLED(CONFIG_FM10K_VXLAN)
 	/* update VXLAN port configuration */
 	vxlan_get_rx_port(netdev);
 
-- 
1.9.3
