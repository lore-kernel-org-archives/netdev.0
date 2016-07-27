From: Zhu Yanjun <zyjzyj2000@gmail.com>
Subject: [PATCH 1/1] ixgbevf: replace integer number with bool value
Date: Wed, 27 Jul 2016 21:28:37 +0800
Message-ID: <1469626117-3669-1-git-send-email-zyjzyj2000@gmail.com>
Cc: Zhu Yanjun <zyjzyj2000@gmail.com>
To: jeffrey.t.kirsher@intel.com, intel-wired-lan@lists.osuosl.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [123.119.172.174] ([123.119.172.174]:48680 "EHLO mail.rain.com"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753024AbcG1OYl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Jul 2016 10:24:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The variable get_mac_status is a bool variable. So a bool value is
better than an integer number.

Signed-off-by: Zhu Yanjun <zyjzyj2000@gmail.com>
---
 drivers/net/ethernet/intel/ixgbevf/ethtool.c      | 2 +-
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ethtool.c b/drivers/net/ethernet/intel/ixgbevf/ethtool.c
index 508e72c..ce221d1 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ethtool.c
@@ -104,7 +104,7 @@ static int ixgbevf_get_settings(struct net_device *netdev,
 	ecmd->transceiver = XCVR_DUMMY1;
 	ecmd->port = -1;
 
-	hw->mac.get_link_status = 1;
+	hw->mac.get_link_status = true;
 	hw->mac.ops.check_link(hw, &link_speed, &link_up, false);
 
 	if (link_up) {
diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index acc2401..a98e7c2 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -1285,7 +1285,7 @@ static irqreturn_t ixgbevf_msix_other(int irq, void *data)
 	struct ixgbevf_adapter *adapter = data;
 	struct ixgbe_hw *hw = &adapter->hw;
 
-	hw->mac.get_link_status = 1;
+	hw->mac.get_link_status = true;
 
 	ixgbevf_service_event_schedule(adapter);
 
@@ -2109,7 +2109,7 @@ static void ixgbevf_up_complete(struct ixgbevf_adapter *adapter)
 	ixgbevf_save_reset_stats(adapter);
 	ixgbevf_init_last_counter_stats(adapter);
 
-	hw->mac.get_link_status = 1;
+	hw->mac.get_link_status = true;
 	mod_timer(&adapter->service_timer, jiffies);
 }
 
-- 
2.7.4
