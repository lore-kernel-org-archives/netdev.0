From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH] e1000e: reset the PHY on 82577/82578 when going to Sx
Date: Thu, 22 Oct 2009 19:53:00 -0700
Message-ID: <20091023025247.6750.89717.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta12.westchester.pa.mail.comcast.net ([76.96.59.227]:33509
	"EHLO QMTA12.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750840AbZJWC4O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Oct 2009 22:56:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

The PHY on 82577/82578 parts needs a soft reset when transitioning to Sx
state in order for the PHY write which disables gigabit speed to take
effect.  Gigabit speed must be disabled in order for the PHY writes to
registers on page 800 (the wakeup control registers) to work as expected
otherwise the system might not wake via WoL.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/ich8lan.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/net/e1000e/ich8lan.c b/drivers/net/e1000e/ich8lan.c
index 99df2ab..aa0ab0e 100644
--- a/drivers/net/e1000e/ich8lan.c
+++ b/drivers/net/e1000e/ich8lan.c
@@ -2843,9 +2843,8 @@ void e1000e_disable_gig_wol_ich8lan(struct e1000_hw *hw)
 		            E1000_PHY_CTRL_GBE_DISABLE;
 		ew32(PHY_CTRL, phy_ctrl);
 
-		/* Workaround SWFLAG unexpectedly set during S0->Sx */
 		if (hw->mac.type == e1000_pchlan)
-			udelay(500);
+			e1000_phy_hw_reset_ich8lan(hw);
 	default:
 		break;
 	}

