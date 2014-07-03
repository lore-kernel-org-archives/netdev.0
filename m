From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/14] i40e: disable TPH
Date: Wed,  2 Jul 2014 19:40:26 -0700
Message-ID: <1404355233-30123-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1404355233-30123-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:56274 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754771AbaGCClO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Jul 2014 22:41:14 -0400
In-Reply-To: <1404355233-30123-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

TPH is not currently enabled in this product, make sure it
isn't enabled by default.

Change-ID: Ibb1a10799c33c4c76dec06fcd53b1d6efa13c1f5
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Jim Young <jamesx.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c        | 4 ----
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 4 ----
 2 files changed, 8 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index d9dcb8c..ac90d5f 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -2401,10 +2401,6 @@ static int i40e_configure_rx_ring(struct i40e_ring *ring)
 
 	rx_ctx.rxmax = min_t(u16, vsi->max_frame,
 				  (chain_len * ring->rx_buf_len));
-	rx_ctx.tphrdesc_ena = 1;
-	rx_ctx.tphwdesc_ena = 1;
-	rx_ctx.tphdata_ena = 1;
-	rx_ctx.tphhead_ena = 1;
 	if (hw->revision_id == 0)
 		rx_ctx.lrxqthresh = 0;
 	else
diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index d2dabae..cafda0c 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -347,10 +347,6 @@ static int i40e_config_vsi_rx_queue(struct i40e_vf *vf, u16 vsi_idx,
 	rx_ctx.dsize = 1;
 
 	/* default values */
-	rx_ctx.tphrdesc_ena = 1;
-	rx_ctx.tphwdesc_ena = 1;
-	rx_ctx.tphdata_ena = 1;
-	rx_ctx.tphhead_ena = 1;
 	rx_ctx.lrxqthresh = 2;
 	rx_ctx.crcstrip = 1;
 	rx_ctx.prefena = 1;
-- 
1.9.3
