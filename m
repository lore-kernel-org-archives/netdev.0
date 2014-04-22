From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/16] i40e/i40evf: unhide and enable to one prefena field
Date: Tue, 22 Apr 2014 05:39:17 -0700
Message-ID: <1398170371-3333-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1398170371-3333-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:4229 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932600AbaDVMjg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Apr 2014 08:39:36 -0400
In-Reply-To: <1398170371-3333-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

The PREFENA field in the receive host memory cache (RX-HMC)
must be visible in order to be set to 1 at driver init for
best performance.

Change-ID: I16b0bcd84cf56f4b6c938201ff5e954bee5a1992
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Acked-by: Shannon Nelson <shannon.nelson@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_lan_hmc.c   | 1 +
 drivers/net/ethernet/intel/i40e/i40e_lan_hmc.h   | 1 +
 drivers/net/ethernet/intel/i40e/i40e_main.c      | 2 ++
 drivers/net/ethernet/intel/i40evf/i40e_lan_hmc.h | 1 +
 4 files changed, 5 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_lan_hmc.c b/drivers/net/ethernet/intel/i40e/i40e_lan_hmc.c
index d5d98fe..5c341ae 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_lan_hmc.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_lan_hmc.c
@@ -747,6 +747,7 @@ static struct i40e_context_ele i40e_hmc_rxq_ce_info[] = {
 	{ I40E_HMC_STORE(i40e_hmc_obj_rxq, tphdata_ena),  1,	195 },
 	{ I40E_HMC_STORE(i40e_hmc_obj_rxq, tphhead_ena),  1,	196 },
 	{ I40E_HMC_STORE(i40e_hmc_obj_rxq, lrxqthresh),   3,	198 },
+	{ I40E_HMC_STORE(i40e_hmc_obj_rxq, prefena),      1,	201 },
 	{ 0 }
 };
 
diff --git a/drivers/net/ethernet/intel/i40e/i40e_lan_hmc.h b/drivers/net/ethernet/intel/i40e/i40e_lan_hmc.h
index 341de92..eb65fe2 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_lan_hmc.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_lan_hmc.h
@@ -56,6 +56,7 @@ struct i40e_hmc_obj_rxq {
 	u8  tphdata_ena;
 	u8  tphhead_ena;
 	u8  lrxqthresh;
+	u8  prefena;	/* NOTE: normally must be set to 1 at init */
 };
 
 /* Tx queue context data */
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 10f0f41..6f1c464 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -3140,6 +3140,8 @@ static void i40e_netpoll(struct net_device *netdev)
 	pf->flags &= ~I40E_FLAG_IN_NETPOLL;
 }
 #endif
+	/* set the prefena field to 1 because the manual says to */
+	rx_ctx.prefena = 1;
 
 /**
  * i40e_vsi_control_tx - Start or stop a VSI's rings
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_lan_hmc.h b/drivers/net/ethernet/intel/i40evf/i40e_lan_hmc.h
index 17e42ca..775fcb2 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_lan_hmc.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_lan_hmc.h
@@ -53,6 +53,7 @@ struct i40e_hmc_obj_rxq {
 	u8  tphdata_ena;
 	u8  tphhead_ena;
 	u8  lrxqthresh;
+	u8  prefena;	/* NOTE: normally must be set to 1 at init */
 };
 
 /* Tx queue context data */
-- 
1.9.0
