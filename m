From: Aaron Brown <aaron.f.brown@intel.com>
Subject: [net-next 11/15] i40evf: clean up adapter struct
Date: Thu, 13 Feb 2014 03:48:49 -0800
Message-ID: <1392292133-32120-12-git-send-email-aaron.f.brown@intel.com>
References: <1392292133-32120-1-git-send-email-aaron.f.brown@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Aaron Brown <aaron.f.brown@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:56830 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754143AbaBMLvO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Feb 2014 06:51:14 -0500
In-Reply-To: <1392292133-32120-1-git-send-email-aaron.f.brown@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

Remove a bunch of unused structure members that are just wasting
space. Remove a completely unused info structure definition as well.

Also update copyrights.

Change-ID: I028ab92d9b7bd13a832cf3363bd1dc6610d8a535
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Aaron Brown <aaron.f.brown@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf.h | 29 +----------------------------
 1 file changed, 1 insertion(+), 28 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf.h b/drivers/net/ethernet/intel/i40evf/i40evf.h
index ff6529b..05969b3 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf.h
+++ b/drivers/net/ethernet/intel/i40evf/i40evf.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
  *
  * Intel Ethernet Controller XL710 Family Linux Virtual Function Driver
- * Copyright(c) 2013 Intel Corporation.
+ * Copyright(c) 2013 - 2014 Intel Corporation.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms and conditions of the GNU General Public License,
@@ -185,7 +185,6 @@ enum i40evf_critical_section_t {
 /* board specific private data structure */
 struct i40evf_adapter {
 	struct timer_list watchdog_timer;
-	struct vlan_group *vlgrp;
 	struct work_struct reset_task;
 	struct work_struct adminq_task;
 	struct delayed_work init_task;
@@ -193,38 +192,19 @@ struct i40evf_adapter {
 	struct list_head vlan_filter_list;
 	char name[MAX_MSIX_COUNT][IFNAMSIZ + 9];
 
-	/* Interrupt Throttle Rate */
-	u32 itr_setting;
-	u16 eitr_low;
-	u16 eitr_high;
-
 	/* TX */
 	struct i40e_ring *tx_rings[I40E_MAX_VSI_QP];
-	u64 restart_queue;
-	u64 hw_csum_tx_good;
-	u64 lsc_int;
-	u64 hw_tso_ctxt;
-	u64 hw_tso6_ctxt;
 	u32 tx_timeout_count;
 	struct list_head mac_filter_list;
-#ifdef DEBUG
-	bool detect_tx_hung;
-#endif /* DEBUG */
 
 	/* RX */
 	struct i40e_ring *rx_rings[I40E_MAX_VSI_QP];
 	int txd_count;
 	int rxd_count;
 	u64 hw_csum_rx_error;
-	u64 hw_rx_no_dma_resources;
-	u64 hw_csum_rx_good;
-	u64 non_eop_descs;
 	int num_msix_vectors;
 	struct msix_entry *msix_entries;
 
-	u64 rx_hdr_split;
-
-	u32 init_state;
 	volatile unsigned long flags;
 #define I40EVF_FLAG_RX_CSUM_ENABLED              (u32)(1)
 #define I40EVF_FLAG_RX_1BUF_CAPABLE              (u32)(1 << 1)
@@ -261,11 +241,9 @@ struct i40evf_adapter {
 
 	enum i40evf_state_t state;
 	volatile unsigned long crit_section;
-	u64 tx_busy;
 
 	struct work_struct watchdog_task;
 	bool netdev_registered;
-	bool dev_closed;
 	bool link_up;
 	enum i40e_virtchnl_ops current_op;
 	struct i40e_virtchnl_vf_resource *vf_res; /* incl. all VSIs */
@@ -276,11 +254,6 @@ struct i40evf_adapter {
 	u32 aq_wait_count;
 };
 
-struct i40evf_info {
-	enum i40e_mac_type	mac;
-	unsigned int		flags;
-};
-
 
 /* needed by i40evf_ethtool.c */
 extern char i40evf_driver_name[];
-- 
1.8.5.GIT
