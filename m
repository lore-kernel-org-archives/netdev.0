From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT PATCH 02/14] e1000e: commit speed/duplex changes for m88 PHY
Date: Fri, 21 Nov 2008 10:59:22 -0800
Message-ID: <20081121185922.32313.24916.stgit@gitlost.lost>
References: <20081121185859.32313.42332.stgit@gitlost.lost>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta03.emeryville.ca.mail.comcast.net ([76.96.30.32]:34726 "EHLO
	QMTA03.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752115AbYKUS7q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2008 13:59:46 -0500
In-Reply-To: <20081121185859.32313.42332.stgit@gitlost.lost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Follow the convention used elsewhere in e1000e to 'commit' PHY changes
instead of directly writing to the PHY CTRL register to reset it.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/phy.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/e1000e/phy.c b/drivers/net/e1000e/phy.c
index 6cd333a..cb7d71e 100644
--- a/drivers/net/e1000e/phy.c
+++ b/drivers/net/e1000e/phy.c
@@ -1030,14 +1030,14 @@ s32 e1000e_phy_force_speed_duplex_m88(struct e1000_hw *hw)
 
 	e1000e_phy_force_speed_duplex_setup(hw, &phy_data);
 
-	/* Reset the phy to commit changes. */
-	phy_data |= MII_CR_RESET;
-
 	ret_val = e1e_wphy(hw, PHY_CONTROL, phy_data);
 	if (ret_val)
 		return ret_val;
 
-	udelay(1);
+	/* Reset the phy to commit changes. */
+	ret_val = e1000e_commit_phy(hw);
+	if (ret_val)
+		return ret_val;
 
 	if (phy->autoneg_wait_to_complete) {
 		hw_dbg(hw, "Waiting for forced speed/duplex link on M88 phy.\n");

