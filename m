From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 6/8] igb: reset PHY after recovering from PHY power down
Date: Wed,  4 Jan 2012 22:23:38 -0800
Message-ID: <1325744620-5067-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1325744620-5067-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Koki Sanagi <sanagi.koki@jp.fujitsu.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:37346 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752180Ab2AEGXr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Jan 2012 01:23:47 -0500
In-Reply-To: <1325744620-5067-1-git-send-email-jeffrey.t.kirsher@intel.com>
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
1.7.7.5
