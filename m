From: Benjamin Poirier <bpoirier@suse.com>
Subject: [PATCH 3/5] e1000e: Fix return value test
Date: Fri, 21 Jul 2017 11:36:25 -0700
Message-ID: <20170721183627.13373-3-bpoirier@suse.com>
References: <20170721160937.GA22632@csclub.uwaterloo.ca>
 <20170721183627.13373-1-bpoirier@suse.com>
Cc: Lennart Sorensen <lsorense@csclub.uwaterloo.ca>,
        intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170721183627.13373-1-bpoirier@suse.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

All the helpers return -E1000_ERR_PHY.

Signed-off-by: Benjamin Poirier <bpoirier@suse.com>
---
 drivers/net/ethernet/intel/e1000e/netdev.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 58a87134d2e5..fc6a1d9999b2 100644
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
2.13.2
