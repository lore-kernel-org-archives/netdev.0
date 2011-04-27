From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 11/12] ixgbe: fix X540 ethtool loopback test.
Date: Wed, 27 Apr 2011 02:34:50 -0700
Message-ID: <1303896891-16006-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1303896891-16006-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Don Skidmore <donald.c.skidmore@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:38651 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755983Ab1D0JfB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Apr 2011 05:35:01 -0400
In-Reply-To: <1303896891-16006-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

On X540 we need to set the MACC.FLU bit to 1 in order to force the link
up before entering MAC loopback.  This is only used in the ethtool loopback
test, which was failing.  This patch corrects it.

Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Tested-by: Evan Swanson <evan.swanson@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe_ethtool.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index 6cf1c71..bd7524e 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -1595,6 +1595,13 @@ static int ixgbe_setup_loopback_test(struct ixgbe_adapter *adapter)
 	struct ixgbe_hw *hw = &adapter->hw;
 	u32 reg_data;
 
+	/* X540 needs to set the MACC.FLU bit to force link up */
+	if (adapter->hw.mac.type == ixgbe_mac_X540) {
+		reg_data = IXGBE_READ_REG(&adapter->hw, IXGBE_MACC);
+		reg_data |= IXGBE_MACC_FLU;
+		IXGBE_WRITE_REG(&adapter->hw, IXGBE_MACC, reg_data);
+	}
+
 	/* right now we only support MAC loopback in the driver */
 	reg_data = IXGBE_READ_REG(&adapter->hw, IXGBE_HLREG0);
 	/* Setup MAC loopback */
-- 
1.7.4.4

