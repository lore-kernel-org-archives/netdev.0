From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 5/6] igb: Force flow control off during reset when forcing speed.
Date: Fri, 27 Apr 2012 02:36:52 -0700
Message-ID: <1335519413-1892-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1335519413-1892-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Matthew Vick <matthew.vick@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:58063 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759151Ab2D0Jg5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Apr 2012 05:36:57 -0400
In-Reply-To: <1335519413-1892-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matthew Vick <matthew.vick@intel.com>

During igb_reset(), we initiate a hardware reset which will clear our
flow control settings. For auto-negotiation, we re-negotiate them when
linking up again, but we need to force them off properly for the forced
speed case.

Signed-off-by: Matthew Vick <matthew.vick@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 28a37bb..f40f388 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -1715,6 +1715,13 @@ void igb_reset(struct igb_adapter *adapter)
 	if (hw->mac.ops.init_hw(hw))
 		dev_err(&pdev->dev, "Hardware Error\n");
 
+	/*
+	 * Flow control settings reset on hardware reset, so guarantee flow
+	 * control is off when forcing speed.
+	 */
+	if (!hw->mac.autoneg)
+		igb_force_mac_fc(hw);
+
 	igb_init_dmac(adapter, pba);
 	if (!netif_running(adapter->netdev))
 		igb_power_down_link(adapter);
-- 
1.7.7.6
