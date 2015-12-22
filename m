From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/10] fm10k: IS_ENABLED() is not appropriate for boolean kconfig option
Date: Tue, 22 Dec 2015 06:02:12 -0800
Message-ID: <1450792932-96015-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1450792932-96015-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:17834 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753704AbbLVODP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Dec 2015 09:03:15 -0500
In-Reply-To: <1450792932-96015-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Tri-states need 'if IS_ENABLED()', booleans should use 'ifdef'.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Krishneil Singh <Krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_netdev.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
index 6fdb782..662569d 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
@@ -20,7 +20,7 @@
 
 #include "fm10k.h"
 #include <linux/vmalloc.h>
-#if IS_ENABLED(CONFIG_FM10K_VXLAN)
+#ifdef CONFIG_FM10K_VXLAN
 #include <net/vxlan.h>
 #endif /* CONFIG_FM10K_VXLAN */
 
@@ -556,11 +556,11 @@ int fm10k_open(struct net_device *netdev)
 	if (err)
 		goto err_set_queues;
 
-#if IS_ENABLED(CONFIG_FM10K_VXLAN)
+#ifdef CONFIG_FM10K_VXLAN
 	/* update VXLAN port configuration */
 	vxlan_get_rx_port(netdev);
-
 #endif
+
 	fm10k_up(interface);
 
 	return 0;
-- 
2.5.0
