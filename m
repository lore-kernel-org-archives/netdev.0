From: Zhu Yanjun <zyjzyj2000@gmail.com>
Subject: [PATCH 3/5] e1000e: do not toggle LANPHYPC value bit when PHY reset is blocked
Date: Mon, 15 Dec 2014 16:39:12 +0800
Message-ID: <1418632754-16698-4-git-send-email-Yanjun.Zhu@windriver.com>
References: <1418632754-16698-1-git-send-email-Yanjun.Zhu@windriver.com>
Cc: Zhu Yanjun <Yanjun.Zhu@windriver.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: netdev@vger.kernel.org, w@1wt.eu, zyjzyj2000@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:34197 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751740AbaLOIjs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Dec 2014 03:39:48 -0500
Received: by mail-pd0-f181.google.com with SMTP id v10so11089933pde.26
        for <netdev@vger.kernel.org>; Mon, 15 Dec 2014 00:39:47 -0800 (PST)
In-Reply-To: <1418632754-16698-1-git-send-email-Yanjun.Zhu@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2.6.x kernels require a similar logic change as commit b7d6e335
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
