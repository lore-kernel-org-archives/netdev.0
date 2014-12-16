From: Zhu Yanjun <zyjzyj2000@gmail.com>
Subject: [PATCH 5/5] e1000e: cleanup use of check_reset_block function pointer
Date: Tue, 16 Dec 2014 18:28:20 +0800
Message-ID: <1418725700-31465-6-git-send-email-Yanjun.Zhu@windriver.com>
References: <1418725700-31465-1-git-send-email-Yanjun.Zhu@windriver.com>
Cc: Zhu Yanjun <Yanjun.Zhu@windriver.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: netdev@vger.kernel.org, w@1wt.eu, zyjzyj2000@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:51393 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751116AbaLPK25 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Dec 2014 05:28:57 -0500
Received: by mail-pa0-f49.google.com with SMTP id eu11so13764726pac.22
        for <netdev@vger.kernel.org>; Tue, 16 Dec 2014 02:28:57 -0800 (PST)
In-Reply-To: <1418725700-31465-1-git-send-email-Yanjun.Zhu@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2.6.x kernels require a similar logic change as commit 44abd5c 
[e1000e: cleanup use of check_reset_block function pointer] introduces
for newer kernels.

Replace e1000_check_reset_block() inline function with calls to the PHY ops
check_reset_block function pointer.

[yanjun.zhu: only modifications in function e1000_init_phy_params_pchlan will
be backported. Others remain unchanged]

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Signed-off-by: Zhu Yanjun <Yanjun.Zhu@windriver.com>
---
 drivers/net/e1000e/ich8lan.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/e1000e/ich8lan.c b/drivers/net/e1000e/ich8lan.c
index 0da2c2c..732cd48 100644
--- a/drivers/net/e1000e/ich8lan.c
+++ b/drivers/net/e1000e/ich8lan.c
@@ -280,7 +280,7 @@ static s32 e1000_init_phy_params_pchlan(struct e1000_hw *hw)
 	phy->ops.write_phy_reg_locked = e1000_write_phy_reg_hv_locked;
 	phy->autoneg_mask             = AUTONEG_ADVERTISE_SPEED_DEFAULT;
 
-	if (!e1000_check_reset_block(hw)) {
+	if (!hw->phy.ops.check_reset_block(hw)) {
 		/*Set Phy Config Counter to 50msec */
 		ctrl = er32(FEXTNVM3);
 		ctrl &= ~E1000_FEXTNVM3_PHY_CFG_COUNTER_MASK;
-- 
1.9.1
