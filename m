From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 20/27] e1000e: 82577/8/9 mis-configured OEM bits during S0->Sx
Date: Fri, 10 Dec 2010 02:03:27 -0800
Message-ID: <1291975414-30487-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1291975414-30487-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta08.emeryville.ca.mail.comcast.net ([76.96.30.80]:44991 "EHLO
	qmta08.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753561Ab0LJKEQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Dec 2010 05:04:16 -0500
To: davem@davemloft.net
In-Reply-To: <1291975414-30487-1-git-send-email-jeffrey.t.kirsher@intel.com>
To: davem@davemleft.org
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

The LPLU (Low Power Link Up) and Gigabit Disable bits (a.k.a. OEM bits)
were being configured incorrectly when device goes to D3 state.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/e1000e/ich8lan.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/e1000e/ich8lan.c b/drivers/net/e1000e/ich8lan.c
index e3374d9..d7fc930 100644
--- a/drivers/net/e1000e/ich8lan.c
+++ b/drivers/net/e1000e/ich8lan.c
@@ -3591,7 +3591,7 @@ void e1000e_disable_gig_wol_ich8lan(struct e1000_hw *hw)
 	ew32(PHY_CTRL, phy_ctrl);
 
 	if (hw->mac.type >= e1000_pchlan) {
-		e1000_oem_bits_config_ich8lan(hw, true);
+		e1000_oem_bits_config_ich8lan(hw, false);
 		ret_val = hw->phy.ops.acquire(hw);
 		if (ret_val)
 			return;
-- 
1.7.3.2

