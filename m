From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 5/9] igb: Explicitly label self-test result indices
Date: Mon, 14 Dec 2015 21:38:40 -0800
Message-ID: <1450157924-58901-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1450157924-58901-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Joe Schultz <jschultz@xes-inc.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Aaron Sierra <asierra@xes-inc.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:59684 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751061AbbLOFit (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Dec 2015 00:38:49 -0500
In-Reply-To: <1450157924-58901-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Schultz <jschultz@xes-inc.com>

Previously, the ethtool self-test gstrings/data arrays were accessed via
hardcoded indices, which made the code difficult to follow. This patch
replaces the hardcoded values with enum-based labels.

Signed-off-by: Joe Schultz <jschultz@xes-inc.com>
Signed-off-by: Aaron Sierra <asierra@xes-inc.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_ethtool.c | 38 ++++++++++++++++++----------
 1 file changed, 24 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_ethtool.c b/drivers/net/ethernet/intel/igb/igb_ethtool.c
index 2529bc6..1d329f1 100644
--- a/drivers/net/ethernet/intel/igb/igb_ethtool.c
+++ b/drivers/net/ethernet/intel/igb/igb_ethtool.c
@@ -127,10 +127,20 @@ static const struct igb_stats igb_gstrings_net_stats[] = {
 #define IGB_STATS_LEN \
 	(IGB_GLOBAL_STATS_LEN + IGB_NETDEV_STATS_LEN + IGB_QUEUE_STATS_LEN)
 
+enum igb_diagnostics_results {
+	TEST_REG = 0,
+	TEST_EEP,
+	TEST_IRQ,
+	TEST_LOOP,
+	TEST_LINK
+};
+
 static const char igb_gstrings_test[][ETH_GSTRING_LEN] = {
-	"Register test  (offline)", "Eeprom test    (offline)",
-	"Interrupt test (offline)", "Loopback test  (offline)",
-	"Link test   (on/offline)"
+	[TEST_REG]  = "Register test  (offline)",
+	[TEST_EEP]  = "Eeprom test    (offline)",
+	[TEST_IRQ]  = "Interrupt test (offline)",
+	[TEST_LOOP] = "Loopback test  (offline)",
+	[TEST_LINK] = "Link test   (on/offline)"
 };
 #define IGB_TEST_LEN (sizeof(igb_gstrings_test) / ETH_GSTRING_LEN)
 
@@ -2002,7 +2012,7 @@ static void igb_diag_test(struct net_device *netdev,
 		/* Link test performed before hardware reset so autoneg doesn't
 		 * interfere with test result
 		 */
-		if (igb_link_test(adapter, &data[4]))
+		if (igb_link_test(adapter, &data[TEST_LINK]))
 			eth_test->flags |= ETH_TEST_FL_FAILED;
 
 		if (if_running)
@@ -2011,21 +2021,21 @@ static void igb_diag_test(struct net_device *netdev,
 		else
 			igb_reset(adapter);
 
-		if (igb_reg_test(adapter, &data[0]))
+		if (igb_reg_test(adapter, &data[TEST_REG]))
 			eth_test->flags |= ETH_TEST_FL_FAILED;
 
 		igb_reset(adapter);
-		if (igb_eeprom_test(adapter, &data[1]))
+		if (igb_eeprom_test(adapter, &data[TEST_EEP]))
 			eth_test->flags |= ETH_TEST_FL_FAILED;
 
 		igb_reset(adapter);
-		if (igb_intr_test(adapter, &data[2]))
+		if (igb_intr_test(adapter, &data[TEST_IRQ]))
 			eth_test->flags |= ETH_TEST_FL_FAILED;
 
 		igb_reset(adapter);
 		/* power up link for loopback test */
 		igb_power_up_link(adapter);
-		if (igb_loopback_test(adapter, &data[3]))
+		if (igb_loopback_test(adapter, &data[TEST_LOOP]))
 			eth_test->flags |= ETH_TEST_FL_FAILED;
 
 		/* restore speed, duplex, autoneg settings */
@@ -2045,16 +2055,16 @@ static void igb_diag_test(struct net_device *netdev,
 		dev_info(&adapter->pdev->dev, "online testing starting\n");
 
 		/* PHY is powered down when interface is down */
-		if (if_running && igb_link_test(adapter, &data[4]))
+		if (if_running && igb_link_test(adapter, &data[TEST_LINK]))
 			eth_test->flags |= ETH_TEST_FL_FAILED;
 		else
-			data[4] = 0;
+			data[TEST_LINK] = 0;
 
 		/* Online tests aren't run; pass by default */
-		data[0] = 0;
-		data[1] = 0;
-		data[2] = 0;
-		data[3] = 0;
+		data[TEST_REG] = 0;
+		data[TEST_EEP] = 0;
+		data[TEST_IRQ] = 0;
+		data[TEST_LOOP] = 0;
 
 		clear_bit(__IGB_TESTING, &adapter->state);
 	}
-- 
2.5.0
