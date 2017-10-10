From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 3/9] e1000e: Fix return value test
Date: Tue, 10 Oct 2017 10:21:33 -0700
Message-ID: <20171010172139.77914-4-jeffrey.t.kirsher@intel.com>
References: <20171010172139.77914-1-jeffrey.t.kirsher@intel.com>
Cc: Benjamin Poirier <bpoirier@suse.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:53638 "EHLO mga11.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932561AbdJJRWC (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 10 Oct 2017 13:22:02 -0400
In-Reply-To: <20171010172139.77914-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Benjamin Poirier <bpoirier@suse.com>

All the helpers return -E1000_ERR_PHY.

Signed-off-by: Benjamin Poirier <bpoirier@suse.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/netdev.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index ead4c112580e..a740de6a30b0 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -5099,7 +5099,7 @@ static bool e1000e_has_link(struct e1000_adapter *adapter)
 		break;
 	}
 
-	if ((ret_val == E1000_ERR_PHY) && (hw->phy.type == e1000_phy_igp_3) &&
+	if ((ret_val == -E1000_ERR_PHY) && (hw->phy.type == e1000_phy_igp_3) &&
 	    (er32(CTRL) & E1000_PHY_CTRL_GBE_DISABLE)) {
 		/* See e1000_kmrn_lock_loss_workaround_ich8lan() */
 		e_info("Gigabit has been disabled, downgrading speed\n");
-- 
2.14.2
