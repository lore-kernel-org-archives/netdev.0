From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH] e1000e: do not initiate autonegotiation during OEM
	configuration
Date: Thu, 19 Nov 2009 16:17:30 -0800
Message-ID: <20091120001722.29775.22407.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta13.westchester.pa.mail.comcast.net ([76.96.59.243]:56569
	"EHLO QMTA13.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757772AbZKTARm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2009 19:17:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

When configuring the OEM bits in the PHY on 82577/82578, do not restart
autonegotiation if the firmware is blocking it (e.g. when an IDE-R session
is active) because the link must not go down.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/ich8lan.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/e1000e/ich8lan.c b/drivers/net/e1000e/ich8lan.c
index 92cf103..eff3f47 100644
--- a/drivers/net/e1000e/ich8lan.c
+++ b/drivers/net/e1000e/ich8lan.c
@@ -1118,7 +1118,8 @@ static s32 e1000_oem_bits_config_ich8lan(struct e1000_hw *hw, bool d0_state)
 			oem_reg |= HV_OEM_BITS_LPLU;
 	}
 	/* Restart auto-neg to activate the bits */
-	oem_reg |= HV_OEM_BITS_RESTART_AN;
+	if (!e1000_check_reset_block(hw))
+		oem_reg |= HV_OEM_BITS_RESTART_AN;
 	ret_val = hw->phy.ops.write_phy_reg_locked(hw, HV_OEM_BITS, oem_reg);
 
 out:

