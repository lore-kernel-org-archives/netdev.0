From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 03/14] i40e: Collect PFC XOFF RX stats even in single TC case
Date: Thu, 28 May 2015 04:25:28 -0700
Message-ID: <1432812339-17129-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1432812339-17129-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Neerav Parikh <neerav.parikh@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:4939 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753970AbbE1LZn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 May 2015 07:25:43 -0400
In-Reply-To: <1432812339-17129-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neerav Parikh <neerav.parikh@intel.com>

When PFC is enabled for any UP in single TC configuration the driver didn't
collect the PFC XOFF RX stats. Though a single TC with PFC enabled is not a
common scenario do not prevent the driver from collecting stats if firmware
indicates that PFC is enabled.

Change-ID: Ie20bd58b07608b528f3c6d95894c9ae56b00077a
Signed-off-by: Neerav Parikh <neerav.parikh@intel.com>
Tested-by: Jim Young <james.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index a54c144..f1a8c4c 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -772,9 +772,8 @@ static void i40e_update_prio_xoff_rx(struct i40e_pf *pf)
 
 	dcb_cfg = &hw->local_dcbx_config;
 
-	/* See if DCB enabled with PFC TC */
-	if (!(pf->flags & I40E_FLAG_DCB_ENABLED) ||
-	    !(dcb_cfg->pfc.pfcenable)) {
+	/* Collect Link XOFF stats when PFC is disabled */
+	if (!dcb_cfg->pfc.pfcenable) {
 		i40e_update_link_xoff_rx(pf);
 		return;
 	}
-- 
2.1.0
