From: Zhu Yanjun <zyjzyj2000@gmail.com>
Subject: [PATCH 3/5] e1000e: do not toggle LANPHYPC value bit when PHY reset is blocked
Date: Tue, 16 Dec 2014 18:28:18 +0800
Message-ID: <1418725700-31465-4-git-send-email-Yanjun.Zhu@windriver.com>
References: <1418725700-31465-1-git-send-email-Yanjun.Zhu@windriver.com>
Cc: Zhu Yanjun <Yanjun.Zhu@windriver.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: netdev@vger.kernel.org, w@1wt.eu, zyjzyj2000@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:47841 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751116AbaLPK2s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Dec 2014 05:28:48 -0500
Received: by mail-pa0-f49.google.com with SMTP id eu11so13764504pac.22
        for <netdev@vger.kernel.org>; Tue, 16 Dec 2014 02:28:48 -0800 (PST)
In-Reply-To: <1418725700-31465-1-git-send-email-Yanjun.Zhu@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2.6.x kernels require a similar logic change as commit 6cc7aae 
[e1000e: do not toggle LANPHYPC value bit when PHY reset is blocked]
introduces for newer kernels.

When PHY reset is intentionally blocked on 82577/8/9, do not toggle the
LANPHYPC value bit (essentially performing a hard power reset of the
device) otherwise the PHY can be put into an unknown state.

Cleanup whitespace in the same function.

[yanjun.zhu: whitespace remains unchanged]

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Signed-off-by: Zhu Yanjun <Yanjun.Zhu@windriver.com>
---
 drivers/net/e1000e/ich8lan.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/e1000e/ich8lan.c b/drivers/net/e1000e/ich8lan.c
index c4b2d15..8c7e4aa 100644
--- a/drivers/net/e1000e/ich8lan.c
+++ b/drivers/net/e1000e/ich8lan.c
@@ -280,7 +280,8 @@ static s32 e1000_init_phy_params_pchlan(struct e1000_hw *hw)
 	phy->ops.write_phy_reg_locked = e1000_write_phy_reg_hv_locked;
 	phy->autoneg_mask             = AUTONEG_ADVERTISE_SPEED_DEFAULT;
 
-	if (!(er32(FWSM) & E1000_ICH_FWSM_FW_VALID)) {
+	if (!(er32(FWSM) & E1000_ICH_FWSM_FW_VALID) && 
+		!e1000_check_reset_block(hw)) {
 		/*Set Phy Config Counter to 50msec */
 		ctrl = er32(FEXTNVM3);
 		ctrl &= ~E1000_FEXTNVM3_PHY_CFG_COUNTER_MASK;
-- 
1.9.1
