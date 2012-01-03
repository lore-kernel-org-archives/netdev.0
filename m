From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/11] igb: reset PHY after recovering from PHY power down
Date: Tue,  3 Jan 2012 11:19:09 -0800
Message-ID: <1325618356-2655-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1325618356-2655-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Koki Sanagi <sanagi.koki@jp.fujitsu.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:48412 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754640Ab2ACTTq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Jan 2012 14:19:46 -0500
In-Reply-To: <1325618356-2655-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Koki Sanagi <sanagi.koki@jp.fujitsu.com>

According to 82576_Datasheet.pdf, PHY setting is lost after PHY power down.
So resetting PHY is needed when recovering from PHY power down to set a default
setting to PHY register.
Owing to this lack, NIC doesn't link up in some rare situation.

Signed-off-by: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index fac71e2..01e5e89 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -1507,6 +1507,7 @@ void igb_power_up_link(struct igb_adapter *adapter)
 		igb_power_up_phy_copper(&adapter->hw);
 	else
 		igb_power_up_serdes_link_82575(&adapter->hw);
+	igb_reset_phy(&adapter->hw);
 }
 
 /**
-- 
1.7.7.4
