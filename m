From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 05/15] i40e: use new add_veb calling with VEB stats control
Date: Wed, 17 Feb 2016 19:38:47 -0800
Message-ID: <1455766737-11911-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1455766737-11911-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:14529 "EHLO mga04.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1424829AbcBRDjE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Feb 2016 22:39:04 -0500
In-Reply-To: <1455766737-11911-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

The new parameters for add_veb allow us to enable and disable VEB stats,
so let's use them.

Update copyright year.

Change-ID: Ie6e68c68e2d1d459e42168eda661051b56bf0a65
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 11 ++++++++---
 drivers/net/ethernet/intel/i40e/i40e_main.c    |  4 ++--
 2 files changed, 10 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index 89ad2f7..230fa40 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
  *
  * Intel Ethernet Controller XL710 Family Linux Driver
- * Copyright(c) 2013 - 2015 Intel Corporation.
+ * Copyright(c) 2013 - 2016 Intel Corporation.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms and conditions of the GNU General Public License,
@@ -2785,10 +2785,15 @@ static int i40e_set_priv_flags(struct net_device *dev, u32 flags)
 		pf->auto_disable_flags |= I40E_FLAG_FD_ATR_ENABLED;
 	}
 
-	if (flags & I40E_PRIV_FLAGS_VEB_STATS)
+	if ((flags & I40E_PRIV_FLAGS_VEB_STATS) &&
+	    !(pf->flags & I40E_FLAG_VEB_STATS_ENABLED)) {
 		pf->flags |= I40E_FLAG_VEB_STATS_ENABLED;
-	else
+		reset_required = true;
+	} else if (!(flags & I40E_PRIV_FLAGS_VEB_STATS) &&
+		   (pf->flags & I40E_FLAG_VEB_STATS_ENABLED)) {
 		pf->flags &= ~I40E_FLAG_VEB_STATS_ENABLED;
+		reset_required = true;
+	}
 
 	if ((flags & I40E_PRIV_FLAGS_HW_ATR_EVICT) &&
 	    (pf->flags & I40E_FLAG_HW_ATR_EVICT_CAPABLE))
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 95fb342..0acec51 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -10069,13 +10069,13 @@ static int i40e_add_veb(struct i40e_veb *veb, struct i40e_vsi *vsi)
 {
 	struct i40e_pf *pf = veb->pf;
 	bool is_default = veb->pf->cur_promisc;
-	bool is_cloud = false;
+	bool enable_stats = !!(pf->flags & I40E_FLAG_VEB_STATS_ENABLED);
 	int ret;
 
 	/* get a VEB from the hardware */
 	ret = i40e_aq_add_veb(&pf->hw, veb->uplink_seid, vsi->seid,
 			      veb->enabled_tc, is_default,
-			      &veb->seid, is_cloud, NULL);
+			      &veb->seid, enable_stats, NULL);
 	if (ret) {
 		dev_info(&pf->pdev->dev,
 			 "couldn't add VEB, err %s aq_err %s\n",
-- 
2.5.0
