From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/11] e1000e: use true/false for boolean send_xon, do not assume always true
Date: Fri, 24 Feb 2012 21:49:58 -0800
Message-ID: <1330149000-25907-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1330149000-25907-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:1113 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753279Ab2BYFuG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Feb 2012 00:50:06 -0500
In-Reply-To: <1330149000-25907-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/mac.c    |    4 +++-
 drivers/net/ethernet/intel/e1000e/netdev.c |    2 +-
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/mac.c b/drivers/net/ethernet/intel/e1000e/mac.c
index 4130134..d55f588 100644
--- a/drivers/net/ethernet/intel/e1000e/mac.c
+++ b/drivers/net/ethernet/intel/e1000e/mac.c
@@ -969,7 +969,9 @@ s32 e1000e_set_fc_watermarks(struct e1000_hw *hw)
 		 * XON frames.
 		 */
 		fcrtl = hw->fc.low_water;
-		fcrtl |= E1000_FCRTL_XONE;
+		if (hw->fc.send_xon)
+			fcrtl |= E1000_FCRTL_XONE;
+
 		fcrth = hw->fc.high_water;
 	}
 	ew32(FCRTL, fcrtl);
diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 56c1aec..8b62870 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -3464,7 +3464,7 @@ void e1000e_reset(struct e1000_adapter *adapter)
 		fc->pause_time = 0xFFFF;
 	else
 		fc->pause_time = E1000_FC_PAUSE_TIME;
-	fc->send_xon = 1;
+	fc->send_xon = true;
 	fc->current_mode = fc->requested_mode;
 
 	switch (hw->mac.type) {
-- 
1.7.7.6
