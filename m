From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/10] e1000e: use msleep instead of mdelay
Date: Fri,  2 Mar 2012 18:24:24 -0800
Message-ID: <1330741468-23900-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1330741468-23900-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:18551 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751203Ab2CCCYg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Mar 2012 21:24:36 -0500
In-Reply-To: <1330741468-23900-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

The e1000_link_stall_workaround_lv() function is always called in non-
atomic context so it should use msleep instead of mdelay.  Also, remove
unnecessary #include <linux/delay.h>.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/phy.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/phy.c b/drivers/net/ethernet/intel/e1000e/phy.c
index 6e768b1..35b4557 100644
--- a/drivers/net/ethernet/intel/e1000e/phy.c
+++ b/drivers/net/ethernet/intel/e1000e/phy.c
@@ -26,8 +26,6 @@
 
 *******************************************************************************/
 
-#include <linux/delay.h>
-
 #include "e1000.h"
 
 static s32 e1000_get_phy_cfg_done(struct e1000_hw *hw);
@@ -3153,7 +3151,7 @@ s32 e1000_link_stall_workaround_hv(struct e1000_hw *hw)
 		     BM_CS_STATUS_SPEED_1000))
 		return 0;
 
-	mdelay(200);
+	msleep(200);
 
 	/* flush the packets in the fifo buffer */
 	ret_val = e1e_wphy(hw, HV_MUX_DATA_CTRL, HV_MUX_DATA_CTRL_GEN_TO_MAC |
-- 
1.7.7.6
