From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 11/15] e1000e: Fix expand setting EEE link info to all affected parts
Date: Tue, 27 May 2014 02:12:27 -0700
Message-ID: <1401181951-31358-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1401181951-31358-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: David Ertman <davidx.m.ertman@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:17021 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752172AbaE0JMp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 May 2014 05:12:45 -0400
In-Reply-To: <1401181951-31358-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ertman <davidx.m.ertman@intel.com>

Previously, the update_phy_task was only calling e1000_set_eee_pchlan()
for phy.type 82579.  This patch is to cause this function to be called
for 82579 and newer phy.types.  This causes the dev_spec->eee_lp_ability
to have the correct value when going into SX states.

Signed-off-by: Dave Ertman <davidx.m.ertman@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/netdev.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 95cf482..e00144a 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -4530,7 +4530,7 @@ static void e1000e_update_phy_task(struct work_struct *work)
 	e1000_get_phy_info(hw);
 
 	/* Enable EEE on 82579 after link up */
-	if (hw->phy.type == e1000_phy_82579)
+	if (hw->phy.type >= e1000_phy_82579)
 		e1000_set_eee_pchlan(hw);
 }
 
-- 
1.9.3
