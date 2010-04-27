From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH] ixgbe: Properly display 1 gig downshift warning
	for backplane
Date: Tue, 27 Apr 2010 14:31:25 -0700
Message-ID: <20100427213124.25913.82475.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Anjali Singhai <anjali.singhai@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta06.emeryville.ca.mail.comcast.net ([76.96.30.56]:47370 "EHLO
	qmta06.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757159Ab0D0Vbn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Apr 2010 17:31:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anjali Singhai <anjali.singhai@intel.com>

Description: When using Intel smartspeed, the patch displays a
warning when the link down shifts to 1 Gig.

Signed-off-by: Anjali Singhai <anjali.singhai@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_82599.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_82599.c b/drivers/net/ixgbe/ixgbe_82599.c
index d189ba7..38c3840 100644
--- a/drivers/net/ixgbe/ixgbe_82599.c
+++ b/drivers/net/ixgbe/ixgbe_82599.c
@@ -642,6 +642,7 @@ static s32 ixgbe_setup_mac_link_smartspeed(struct ixgbe_hw *hw,
 	s32 i, j;
 	bool link_up = false;
 	u32 autoc_reg = IXGBE_READ_REG(hw, IXGBE_AUTOC);
+	struct ixgbe_adapter *adapter = hw->back;
 
 	hw_dbg(hw, "ixgbe_setup_mac_link_smartspeed.\n");
 
@@ -726,6 +727,10 @@ static s32 ixgbe_setup_mac_link_smartspeed(struct ixgbe_hw *hw,
 					    autoneg_wait_to_complete);
 
 out:
+	if (link_up && (link_speed == IXGBE_LINK_SPEED_1GB_FULL))
+		netif_info(adapter, hw, adapter->netdev, "Smartspeed has"
+			" downgraded the link speed from the maximum"
+			" advertised\n");
 	return status;
 }
 

