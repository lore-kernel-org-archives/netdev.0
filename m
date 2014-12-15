From: Zhu Yanjun <zyjzyj2000@gmail.com>
Subject: [PATCH 4/5] e1000e: update workaround for 82579 intermittently disabled during S0->Sx
Date: Mon, 15 Dec 2014 16:39:13 +0800
Message-ID: <1418632754-16698-5-git-send-email-Yanjun.Zhu@windriver.com>
References: <1418632754-16698-1-git-send-email-Yanjun.Zhu@windriver.com>
Cc: Zhu Yanjun <Yanjun.Zhu@windriver.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: netdev@vger.kernel.org, w@1wt.eu, zyjzyj2000@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:47199 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751740AbaLOIjx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Dec 2014 03:39:53 -0500
Received: by mail-pd0-f174.google.com with SMTP id fp1so11205919pdb.19
        for <netdev@vger.kernel.org>; Mon, 15 Dec 2014 00:39:52 -0800 (PST)
In-Reply-To: <1418632754-16698-1-git-send-email-Yanjun.Zhu@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2.6.x kernels require a similar logic change as commit c6f8b74f
[e1000e: update workaround for 82579 intermittently disabled during S0->Sx]
introduces for newer kernels.

The workaround which toggles the LANPHYPC (LAN PHY Power Control) value bit
to force the MAC-Phy interconnect into PCIe mode from SMBus mode during
driver load and resume should always be done except if PHY resets are
blocked by the Manageability Engine (ME).  Previously, the toggle was done
only if PHY resets are blocked and the ME was disabled.

The rest of the patch is just indentation changes as a consequence of the
updated workaround.

[yanjun.zhu: indentation changes are removed.
function e1000_init_phy_workarounds_pchlan does not exist]

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Signed-off-by: Zhu Yanjun <Yanjun.Zhu@windriver.com>
---
 drivers/net/e1000e/ich8lan.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/e1000e/ich8lan.c b/drivers/net/e1000e/ich8lan.c
index 8c7e4aa..0da2c2c 100644
--- a/drivers/net/e1000e/ich8lan.c
+++ b/drivers/net/e1000e/ich8lan.c
@@ -280,8 +280,7 @@ static s32 e1000_init_phy_params_pchlan(struct e1000_hw *hw)
 	phy->ops.write_phy_reg_locked = e1000_write_phy_reg_hv_locked;
 	phy->autoneg_mask             = AUTONEG_ADVERTISE_SPEED_DEFAULT;
 
-	if (!(er32(FWSM) & E1000_ICH_FWSM_FW_VALID) && 
-		!e1000_check_reset_block(hw)) {
+	if (!e1000_check_reset_block(hw)) {
 		/*Set Phy Config Counter to 50msec */
 		ctrl = er32(FEXTNVM3);
 		ctrl &= ~E1000_FEXTNVM3_PHY_CFG_COUNTER_MASK;
-- 
1.9.1
