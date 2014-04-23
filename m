From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 12/14] igb: Cleanups to fix braces location warnings
Date: Wed, 23 Apr 2014 04:15:24 -0700
Message-ID: <1398251726-13638-13-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1398251726-13638-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:55687 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753163AbaDWLPi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Apr 2014 07:15:38 -0400
In-Reply-To: <1398251726-13638-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carolyn Wyborny <carolyn.wyborny@intel.com>

This patch fixes WARNING:BRACES and ERROR:OPEN_BRACE from
checkpatch file check.

Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/e1000_82575.c |  8 +++-----
 drivers/net/ethernet/intel/igb/igb_ethtool.c |  4 ++--
 drivers/net/ethernet/intel/igb/igb_main.c    | 10 ++++------
 3 files changed, 9 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/e1000_82575.c b/drivers/net/ethernet/intel/igb/e1000_82575.c
index 7b7d08c..b1a759c 100644
--- a/drivers/net/ethernet/intel/igb/e1000_82575.c
+++ b/drivers/net/ethernet/intel/igb/e1000_82575.c
@@ -73,9 +73,8 @@ static s32  igb_validate_nvm_checksum_82580(struct e1000_hw *hw);
 static s32  igb_update_nvm_checksum_82580(struct e1000_hw *hw);
 static s32 igb_validate_nvm_checksum_i350(struct e1000_hw *hw);
 static s32 igb_update_nvm_checksum_i350(struct e1000_hw *hw);
-static const u16 e1000_82580_rxpbs_table[] =
-	{ 36, 72, 144, 1, 2, 4, 8, 16,
-	  35, 70, 140 };
+static const u16 e1000_82580_rxpbs_table[] = {
+	36, 72, 144, 1, 2, 4, 8, 16, 35, 70, 140 };
 
 /**
  *  igb_sgmii_uses_mdio_82575 - Determine if I2C pins are for external MDIO
@@ -1436,9 +1435,8 @@ static s32 igb_reset_hw_82575(struct e1000_hw *hw)
 
 	/* set the completion timeout for interface */
 	ret_val = igb_set_pcie_completion_timeout(hw);
-	if (ret_val) {
+	if (ret_val)
 		hw_dbg("PCI-E Set completion timeout has failed.\n");
-	}
 
 	hw_dbg("Masking off all interrupts\n");
 	wr32(E1000_IMC, 0xffffffff);
diff --git a/drivers/net/ethernet/intel/igb/igb_ethtool.c b/drivers/net/ethernet/intel/igb/igb_ethtool.c
index e5570ac..1615226 100644
--- a/drivers/net/ethernet/intel/igb/igb_ethtool.c
+++ b/drivers/net/ethernet/intel/igb/igb_ethtool.c
@@ -1196,8 +1196,8 @@ static bool reg_pattern_test(struct igb_adapter *adapter, u64 *data,
 {
 	struct e1000_hw *hw = &adapter->hw;
 	u32 pat, val;
-	static const u32 _test[] =
-		{0x5A5A5A5A, 0xA5A5A5A5, 0x00000000, 0xFFFFFFFF};
+	static const u32 _test[] = {
+		0x5A5A5A5A, 0xA5A5A5A5, 0x00000000, 0xFFFFFFFF};
 	for (pat = 0; pat < ARRAY_SIZE(_test); pat++) {
 		wr32(reg, (_test[pat] & write));
 		val = rd32(reg) & mask;
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 13edca9..e6e4f4b 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -4235,9 +4235,8 @@ static void igb_watchdog_task(struct work_struct *work)
 
 			/* check for thermal sensor event */
 			if (igb_thermal_sensor_event(hw,
-			    E1000_THSTAT_LINK_THROTTLE)) {
+			    E1000_THSTAT_LINK_THROTTLE))
 				netdev_info(netdev, "The network adapter link speed was downshifted because it overheated\n");
-			}
 
 			/* adjust timeout factor according to speed/duplex */
 			adapter->tx_timeout_factor = 1;
@@ -4473,13 +4472,12 @@ static void igb_update_itr(struct igb_q_vector *q_vector,
 	case low_latency:  /* 50 usec aka 20000 ints/s */
 		if (bytes > 10000) {
 			/* this if handles the TSO accounting */
-			if (bytes/packets > 8000) {
+			if (bytes/packets > 8000)
 				itrval = bulk_latency;
-			} else if ((packets < 10) || ((bytes/packets) > 1200)) {
+			else if ((packets < 10) || ((bytes/packets) > 1200))
 				itrval = bulk_latency;
-			} else if ((packets > 35)) {
+			else if ((packets > 35))
 				itrval = lowest_latency;
-			}
 		} else if (bytes/packets > 2000) {
 			itrval = bulk_latency;
 		} else if (packets <= 2 && bytes < 512) {
-- 
1.9.0
