From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 13/16] i40e: add netdev info to VSI dump
Date: Tue, 16 Feb 2016 21:34:19 -0800
Message-ID: <1455687262-20453-14-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1455687262-20453-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:14537 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756429AbcBQFe2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Feb 2016 00:34:28 -0500
In-Reply-To: <1455687262-20453-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

Add a few more bits of netdev data into the debugfs output for dump VSI.
For now, we'll add the features, hw_features, vlan_features, and flags
bitflags and the state. More could be added later if needed.

Also, tweak a couple nearby output lines for output readability.

Change-ID: I9fb5a9da75c9ad7679498ce9ac3ba24d065ddd2e
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Reviewed-by: Brandeburg, Jesse <jesse.brandeburg@intel.com>
Reviewed-by: Wyborny, Carolyn <carolyn.wyborny@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c | 24 ++++++++++++++++--------
 1 file changed, 16 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
index 10744a6..7aae056 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
@@ -379,19 +379,27 @@ static void i40e_dbg_dump_vsi_seid(struct i40e_pf *pf, int seid)
 		return;
 	}
 	dev_info(&pf->pdev->dev, "vsi seid %d\n", seid);
-	if (vsi->netdev)
-		dev_info(&pf->pdev->dev,
-			 "    netdev: name = %s\n",
-			 vsi->netdev->name);
+	if (vsi->netdev) {
+		struct net_device *nd = vsi->netdev;
+
+		dev_info(&pf->pdev->dev, "    netdev: name = %s, state = %lu, flags = 0x%08x\n",
+			 nd->name, nd->state, nd->flags);
+		dev_info(&pf->pdev->dev, "        features      = 0x%08lx\n",
+			 (unsigned long int)nd->features);
+		dev_info(&pf->pdev->dev, "        hw_features   = 0x%08lx\n",
+			 (unsigned long int)nd->hw_features);
+		dev_info(&pf->pdev->dev, "        vlan_features = 0x%08lx\n",
+			 (unsigned long int)nd->vlan_features);
+	}
 	if (vsi->active_vlans)
 		dev_info(&pf->pdev->dev,
 			 "    vlgrp: & = %p\n", vsi->active_vlans);
 	dev_info(&pf->pdev->dev,
-		 "    netdev_registered = %i, current_netdev_flags = 0x%04x, state = %li flags = 0x%08lx\n",
-		 vsi->netdev_registered,
-		 vsi->current_netdev_flags, vsi->state, vsi->flags);
+		 "    state = %li flags = 0x%08lx, netdev_registered = %i, current_netdev_flags = 0x%04x\n",
+		 vsi->state, vsi->flags,
+		 vsi->netdev_registered, vsi->current_netdev_flags);
 	if (vsi == pf->vsi[pf->lan_vsi])
-		dev_info(&pf->pdev->dev, "MAC address: %pM SAN MAC: %pM Port MAC: %pM\n",
+		dev_info(&pf->pdev->dev, "    MAC address: %pM SAN MAC: %pM Port MAC: %pM\n",
 			 pf->hw.mac.addr,
 			 pf->hw.mac.san_addr,
 			 pf->hw.mac.port_addr);
-- 
2.5.0
