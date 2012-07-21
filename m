From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 13/13] igb: reset PHY in the link_up process to recover PHY setting after power down.
Date: Sat, 21 Jul 2012 16:09:02 -0700
Message-ID: <1342912142-11130-14-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1342912142-11130-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: "Akeem G. Abodunrin" <akeem.g.abodunrin@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:53992 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752043Ab2GUXJO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Jul 2012 19:09:14 -0400
In-Reply-To: <1342912142-11130-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Akeem G. Abodunrin" <akeem.g.abodunrin@intel.com>

There was a previous patch to resolve issue with 82576 losing PHY setting
after PHY power down. However that previous implementation triggered speed
mismatch and occasional link lost. Now, this patch resolves both initial
PHY setting and speed mismatch issues.

Signed-off-by: Akeem G. Abodunrin <akeem.g.abodunrin@intel.com>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 8adeca9..1050411 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -1500,11 +1500,12 @@ static void igb_configure(struct igb_adapter *adapter)
  **/
 void igb_power_up_link(struct igb_adapter *adapter)
 {
+	igb_reset_phy(&adapter->hw);
+
 	if (adapter->hw.phy.media_type == e1000_media_type_copper)
 		igb_power_up_phy_copper(&adapter->hw);
 	else
 		igb_power_up_serdes_link_82575(&adapter->hw);
-	igb_reset_phy(&adapter->hw);
 }
 
 /**
-- 
1.7.10.4
