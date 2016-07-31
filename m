From: Heinrich Schuchardt <xypron.glpk@gmx.de>
Subject: [PATCH 1/1] net: e1000: do not use uninitalized variable.
Date: Sun, 31 Jul 2016 11:30:58 +0200
Message-ID: <1469957458-494-1-git-send-email-xypron.glpk@gmx.de>
Cc: intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Heinrich Schuchardt <xypron.glpk@gmx.de>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.15.19]:55107 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751273AbcGaJbP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 31 Jul 2016 05:31:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

phy_data has to be set to zero to avoid undefined
behavior.

Signed-off-by: Heinrich Schuchardt <xypron.glpk@gmx.de>
---
 drivers/net/ethernet/intel/e1000/e1000_hw.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/e1000/e1000_hw.c b/drivers/net/ethernet/intel/e1000/e1000_hw.c
index 8172cf0..456bb07 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_hw.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_hw.c
@@ -5390,7 +5390,7 @@ static s32 e1000_set_phy_mode(struct e1000_hw *hw)
 static s32 e1000_set_d3_lplu_state(struct e1000_hw *hw, bool active)
 {
 	s32 ret_val;
-	u16 phy_data;
+	u16 phy_data = 0;
 
 	if (hw->phy_type != e1000_phy_igp)
 		return E1000_SUCCESS;
-- 
2.8.1
