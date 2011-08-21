From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/10] ixgbe: Drop unnecessary adapter->hw dereference in loopback test setup
Date: Sun, 21 Aug 2011 00:29:19 -0700
Message-ID: <1313911761-11709-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1313911761-11709-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:9566 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752861Ab1HUH33 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 21 Aug 2011 03:29:29 -0400
In-Reply-To: <1313911761-11709-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This patch drops a set of unnecessary dereferences to the hardware structure
since we already have a local copy of the hardware pointer.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c |   18 +++++++++---------
 1 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
index 16835cc..6241e9a 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
@@ -1566,26 +1566,26 @@ static int ixgbe_setup_loopback_test(struct ixgbe_adapter *adapter)
 
 	/* X540 needs to set the MACC.FLU bit to force link up */
 	if (adapter->hw.mac.type == ixgbe_mac_X540) {
-		reg_data = IXGBE_READ_REG(&adapter->hw, IXGBE_MACC);
+		reg_data = IXGBE_READ_REG(hw, IXGBE_MACC);
 		reg_data |= IXGBE_MACC_FLU;
-		IXGBE_WRITE_REG(&adapter->hw, IXGBE_MACC, reg_data);
+		IXGBE_WRITE_REG(hw, IXGBE_MACC, reg_data);
 	}
 
 	/* right now we only support MAC loopback in the driver */
-	reg_data = IXGBE_READ_REG(&adapter->hw, IXGBE_HLREG0);
+	reg_data = IXGBE_READ_REG(hw, IXGBE_HLREG0);
 	/* Setup MAC loopback */
 	reg_data |= IXGBE_HLREG0_LPBK;
-	IXGBE_WRITE_REG(&adapter->hw, IXGBE_HLREG0, reg_data);
+	IXGBE_WRITE_REG(hw, IXGBE_HLREG0, reg_data);
 
-	reg_data = IXGBE_READ_REG(&adapter->hw, IXGBE_FCTRL);
+	reg_data = IXGBE_READ_REG(hw, IXGBE_FCTRL);
 	reg_data |= IXGBE_FCTRL_BAM | IXGBE_FCTRL_SBP | IXGBE_FCTRL_MPE;
-	IXGBE_WRITE_REG(&adapter->hw, IXGBE_FCTRL, reg_data);
+	IXGBE_WRITE_REG(hw, IXGBE_FCTRL, reg_data);
 
-	reg_data = IXGBE_READ_REG(&adapter->hw, IXGBE_AUTOC);
+	reg_data = IXGBE_READ_REG(hw, IXGBE_AUTOC);
 	reg_data &= ~IXGBE_AUTOC_LMS_MASK;
 	reg_data |= IXGBE_AUTOC_LMS_10G_LINK_NO_AN | IXGBE_AUTOC_FLU;
-	IXGBE_WRITE_REG(&adapter->hw, IXGBE_AUTOC, reg_data);
-	IXGBE_WRITE_FLUSH(&adapter->hw);
+	IXGBE_WRITE_REG(hw, IXGBE_AUTOC, reg_data);
+	IXGBE_WRITE_FLUSH(hw);
 	usleep_range(10000, 20000);
 
 	/* Disable Atlas Tx lanes; re-enabled in reset path */
-- 
1.7.6

