From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 3/7] igb: Use a 32-bit mask when calculating the flow control watermarks
Date: Wed, 28 Nov 2012 05:06:14 -0800
Message-ID: <1354107978-24731-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1354107978-24731-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Matthew Vick <matthew.vick@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:63966 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932092Ab2K1NGY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Nov 2012 08:06:24 -0500
In-Reply-To: <1354107978-24731-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matthew Vick <matthew.vick@intel.com>

For some devices, the result of the flow control high watermark gets
truncated when programming it into the registers because of the mask used.
Switch the mask to 32-bit to prevent this from happening.

Signed-off-by: Matthew Vick <matthew.vick@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 0ce145e..b85b15a 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -1589,8 +1589,7 @@ void igb_reset(struct igb_adapter *adapter)
 	struct e1000_hw *hw = &adapter->hw;
 	struct e1000_mac_info *mac = &hw->mac;
 	struct e1000_fc_info *fc = &hw->fc;
-	u32 pba = 0, tx_space, min_tx_space, min_rx_space;
-	u16 hwm;
+	u32 pba = 0, tx_space, min_tx_space, min_rx_space, hwm;
 
 	/* Repartition Pba for greater than 9k mtu
 	 * To take effect CTRL.RST is required.
@@ -1665,7 +1664,7 @@ void igb_reset(struct igb_adapter *adapter)
 	hwm = min(((pba << 10) * 9 / 10),
 			((pba << 10) - 2 * adapter->max_frame_size));
 
-	fc->high_water = hwm & 0xFFF0;	/* 16-byte granularity */
+	fc->high_water = hwm & 0xFFFFFFF0;	/* 16-byte granularity */
 	fc->low_water = fc->high_water - 16;
 	fc->pause_time = 0xFFFF;
 	fc->send_xon = 1;
-- 
1.7.11.7
