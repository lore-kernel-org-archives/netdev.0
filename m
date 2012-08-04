From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Subject: [net 3/3] igb: don't break user visible strings over multiple lines in igb_ethtool.c
Date: Sat,  4 Aug 2012 03:25:52 -0700
Message-ID: <1344075952-4198-4-git-send-email-peter.p.waskiewicz.jr@intel.com>
References: <1344075952-4198-1-git-send-email-peter.p.waskiewicz.jr@intel.com>
Cc: Jesper Juhl <jj@chaosbits.net>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:44124 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751796Ab2HDK0c (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 4 Aug 2012 06:26:32 -0400
In-Reply-To: <1344075952-4198-1-git-send-email-peter.p.waskiewicz.jr@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Juhl <jj@chaosbits.net>

Even when they go beyond 80 characters, user visible strings should be
on one line to make them easy to grep for.

Signed-off-by: Jesper Juhl <jj@chaosbits.net>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_ethtool.c |   23 +++++++++++------------
 1 file changed, 11 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_ethtool.c b/drivers/net/ethernet/intel/igb/igb_ethtool.c
index ad489b7..90550f5 100644
--- a/drivers/net/ethernet/intel/igb/igb_ethtool.c
+++ b/drivers/net/ethernet/intel/igb/igb_ethtool.c
@@ -209,8 +209,8 @@ static int igb_set_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 	/* When SoL/IDER sessions are active, autoneg/speed/duplex
 	 * cannot be changed */
 	if (igb_check_reset_block(hw)) {
-		dev_err(&adapter->pdev->dev, "Cannot change link "
-			"characteristics when SoL/IDER is active.\n");
+		dev_err(&adapter->pdev->dev,
+			"Cannot change link characteristics when SoL/IDER is active.\n");
 		return -EINVAL;
 	}
 
@@ -1089,8 +1089,8 @@ static bool reg_pattern_test(struct igb_adapter *adapter, u64 *data,
 		wr32(reg, (_test[pat] & write));
 		val = rd32(reg) & mask;
 		if (val != (_test[pat] & write & mask)) {
-			dev_err(&adapter->pdev->dev, "pattern test reg %04X "
-				"failed: got 0x%08X expected 0x%08X\n",
+			dev_err(&adapter->pdev->dev,
+				"pattern test reg %04X failed: got 0x%08X expected 0x%08X\n",
 				reg, val, (_test[pat] & write & mask));
 			*data = reg;
 			return 1;
@@ -1108,8 +1108,8 @@ static bool reg_set_and_check(struct igb_adapter *adapter, u64 *data,
 	wr32(reg, write & mask);
 	val = rd32(reg);
 	if ((write & mask) != (val & mask)) {
-		dev_err(&adapter->pdev->dev, "set/check reg %04X test failed:"
-			" got 0x%08X expected 0x%08X\n", reg,
+		dev_err(&adapter->pdev->dev,
+			"set/check reg %04X test failed: got 0x%08X expected 0x%08X\n", reg,
 			(val & mask), (write & mask));
 		*data = reg;
 		return 1;
@@ -1171,8 +1171,9 @@ static int igb_reg_test(struct igb_adapter *adapter, u64 *data)
 	wr32(E1000_STATUS, toggle);
 	after = rd32(E1000_STATUS) & toggle;
 	if (value != after) {
-		dev_err(&adapter->pdev->dev, "failed STATUS register test "
-			"got: 0x%08X expected: 0x%08X\n", after, value);
+		dev_err(&adapter->pdev->dev,
+			"failed STATUS register test got: 0x%08X expected: 0x%08X\n",
+			after, value);
 		*data = 1;
 		return 1;
 	}
@@ -1777,16 +1778,14 @@ static int igb_loopback_test(struct igb_adapter *adapter, u64 *data)
 	 * sessions are active */
 	if (igb_check_reset_block(&adapter->hw)) {
 		dev_err(&adapter->pdev->dev,
-			"Cannot do PHY loopback test "
-			"when SoL/IDER is active.\n");
+			"Cannot do PHY loopback test when SoL/IDER is active.\n");
 		*data = 0;
 		goto out;
 	}
 	if ((adapter->hw.mac.type == e1000_i210)
 		|| (adapter->hw.mac.type == e1000_i211)) {
 		dev_err(&adapter->pdev->dev,
-			"Loopback test not supported "
-			"on this part at this time.\n");
+			"Loopback test not supported on this part at this time.\n");
 		*data = 0;
 		goto out;
 	}
-- 
1.7.10.4
