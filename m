From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/25] fm10k: Remove redundant rx_errors in ethtool
Date: Tue, 14 Apr 2015 16:50:48 -0700
Message-ID: <1429055471-401-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1429055471-401-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:51346 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751633AbbDNXvO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Apr 2015 19:51:14 -0400
In-Reply-To: <1429055471-401-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Output of ethtool was reporting 2 rx_errors entries. This change
removes one of the redundant entries.

Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Acked-by: Matthew Vick <matthew.vick@intel.com>
Tested-by: Krishneil Singh <krishneil.k.singh@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k.h         | 3 +--
 drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c | 3 +--
 drivers/net/ethernet/intel/fm10k/fm10k_pci.c     | 5 ++---
 3 files changed, 4 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k.h b/drivers/net/ethernet/intel/fm10k/fm10k.h
index 59edfd4..65e7001 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k.h
+++ b/drivers/net/ethernet/intel/fm10k/fm10k.h
@@ -1,5 +1,5 @@
 /* Intel Ethernet Switch Host Interface Driver
- * Copyright(c) 2013 - 2014 Intel Corporation.
+ * Copyright(c) 2013 - 2015 Intel Corporation.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms and conditions of the GNU General Public License,
@@ -266,7 +266,6 @@ struct fm10k_intfc {
 	u64 tx_csum_errors;
 	u64 alloc_failed;
 	u64 rx_csum_errors;
-	u64 rx_errors;
 
 	u64 tx_bytes_nic;
 	u64 tx_packets_nic;
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c b/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c
index 33b6106..7dd3c9d 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c
@@ -1,5 +1,5 @@
 /* Intel Ethernet Switch Host Interface Driver
- * Copyright(c) 2013 - 2014 Intel Corporation.
+ * Copyright(c) 2013 - 2015 Intel Corporation.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms and conditions of the GNU General Public License,
@@ -63,7 +63,6 @@ static const struct fm10k_stats fm10k_gstrings_stats[] = {
 	FM10K_STAT("tx_csum_errors", tx_csum_errors),
 	FM10K_STAT("rx_alloc_failed", alloc_failed),
 	FM10K_STAT("rx_csum_errors", rx_csum_errors),
-	FM10K_STAT("rx_errors", rx_errors),
 
 	FM10K_STAT("tx_packets_nic", tx_packets_nic),
 	FM10K_STAT("tx_bytes_nic", tx_bytes_nic),
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
index 8978d55..6fc9965 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
@@ -1,5 +1,5 @@
 /* Intel Ethernet Switch Host Interface Driver
- * Copyright(c) 2013 - 2014 Intel Corporation.
+ * Copyright(c) 2013 - 2015 Intel Corporation.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms and conditions of the GNU General Public License,
@@ -357,7 +357,6 @@ void fm10k_update_stats(struct fm10k_intfc *interface)
 	net_stats->rx_packets = pkts;
 	interface->alloc_failed = alloc_failed;
 	interface->rx_csum_errors = rx_csum_errors;
-	interface->rx_errors = rx_errors;
 
 	hw->mac.ops.update_hw_stats(hw, &interface->stats);
 
@@ -378,7 +377,7 @@ void fm10k_update_stats(struct fm10k_intfc *interface)
 	interface->rx_drops_nic = rx_drops_nic;
 
 	/* Fill out the OS statistics structure */
-	net_stats->rx_errors = interface->stats.xec.count;
+	net_stats->rx_errors = rx_errors;
 	net_stats->rx_dropped = interface->stats.nodesc_drop.count;
 }
 
-- 
1.9.3
