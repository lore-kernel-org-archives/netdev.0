From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 4/4] e1000e: disable gig speed when in S0->Sx
	transition
Date: Thu, 17 Jun 2010 21:59:48 -0700
Message-ID: <20100618045946.6728.12416.stgit@localhost.localdomain>
References: <20100618045804.6728.37945.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta14.emeryville.ca.mail.comcast.net ([76.96.27.212]:57062
	"EHLO qmta14.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752408Ab0FRFAI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jun 2010 01:00:08 -0400
In-Reply-To: <20100618045804.6728.37945.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Most of this workaround is necessary for all ICHx/PCH parts so one of
the two MAC-type checks can be removed.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/ich8lan.c |   19 +++++--------------
 1 files changed, 5 insertions(+), 14 deletions(-)

diff --git a/drivers/net/e1000e/ich8lan.c b/drivers/net/e1000e/ich8lan.c
index c7292a1..6b5e108 100644
--- a/drivers/net/e1000e/ich8lan.c
+++ b/drivers/net/e1000e/ich8lan.c
@@ -3457,21 +3457,12 @@ void e1000e_disable_gig_wol_ich8lan(struct e1000_hw *hw)
 {
 	u32 phy_ctrl;
 
-	switch (hw->mac.type) {
-	case e1000_ich8lan:
-	case e1000_ich9lan:
-	case e1000_ich10lan:
-	case e1000_pchlan:
-		phy_ctrl = er32(PHY_CTRL);
-		phy_ctrl |= E1000_PHY_CTRL_D0A_LPLU |
-		            E1000_PHY_CTRL_GBE_DISABLE;
-		ew32(PHY_CTRL, phy_ctrl);
+	phy_ctrl = er32(PHY_CTRL);
+	phy_ctrl |= E1000_PHY_CTRL_D0A_LPLU | E1000_PHY_CTRL_GBE_DISABLE;
+	ew32(PHY_CTRL, phy_ctrl);
 
-		if (hw->mac.type == e1000_pchlan)
-			e1000_phy_hw_reset_ich8lan(hw);
-	default:
-		break;
-	}
+	if (hw->mac.type >= e1000_pchlan)
+		e1000_phy_hw_reset_ich8lan(hw);
 }
 
 /**

