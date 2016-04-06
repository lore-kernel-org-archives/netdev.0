From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/14] i40e: remove redundant check on vsi->active_vlans
Date: Tue,  5 Apr 2016 20:35:56 -0700
Message-ID: <1459913769-56510-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1459913769-56510-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Colin King <colin.king@canonical.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:48525 "EHLO mga04.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754342AbcDFDgR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Apr 2016 23:36:17 -0400
In-Reply-To: <1459913769-56510-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Colin King <colin.king@canonical.com>

active_vlans is an unsigned long array, hence a null check on this
array is superfluous and can be removed.

Detected with static analysis by smatch:

drivers/net/ethernet/intel/i40e/i40e_debugfs.c:386
  i40e_dbg_dump_vsi_seid() warn: this array is probably
  non-NULL. 'vsi->active_vlans'

Signed-off-by: Colin Ian King <colin.king@canonical.com>
Acked-by: Shannon Nelson <shannon.nelson@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
index 0c97733..83dccf1 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
@@ -147,9 +147,8 @@ static void i40e_dbg_dump_vsi_seid(struct i40e_pf *pf, int seid)
 		dev_info(&pf->pdev->dev, "        vlan_features = 0x%08lx\n",
 			 (unsigned long int)nd->vlan_features);
 	}
-	if (vsi->active_vlans)
-		dev_info(&pf->pdev->dev,
-			 "    vlgrp: & = %p\n", vsi->active_vlans);
+	dev_info(&pf->pdev->dev,
+		 "    vlgrp: & = %p\n", vsi->active_vlans);
 	dev_info(&pf->pdev->dev,
 		 "    state = %li flags = 0x%08lx, netdev_registered = %i, current_netdev_flags = 0x%04x\n",
 		 vsi->state, vsi->flags,
-- 
2.5.5
