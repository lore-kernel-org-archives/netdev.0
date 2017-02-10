From: Saber Rezvani <irsaber@gmail.com>
Subject: [PATCH 1/1] net: ethernet: intel: e1000: msleep() is unreliable for anything <20ms
Date: Fri, 10 Feb 2017 12:12:53 +0330
Message-ID: <1486716173-10891-1-git-send-email-irsaber@gmail.com>
Cc: intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Saber Rezvani <irsaber@gmail.com>
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from sender-pp-092.zoho.com ([135.84.80.237]:25341 "EHLO
        sender-pp-092.zoho.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751949AbdBJIqm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 10 Feb 2017 03:46:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix the checkpatch.pl issue:
WARNING: msleep < 20ms can sleep for up to 20ms; see
Documentation/timers/timers-howto.txt

Signed-off-by: Saber Rezvani <irsaber@gmail.com>
---
 drivers/net/ethernet/intel/e1000/e1000_ethtool.c | 16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000/e1000_ethtool.c b/drivers/net/ethernet/intel/e1000/e1000_ethtool.c
index 975eeb8..fa47eab 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_ethtool.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_ethtool.c
@@ -207,7 +207,7 @@ static int e1000_set_settings(struct net_device *netdev,
 	}
 
 	while (test_and_set_bit(__E1000_RESETTING, &adapter->flags))
-		msleep(1);
+		usleep_range(1000, 5000);
 
 	if (ecmd->autoneg == AUTONEG_ENABLE) {
 		hw->autoneg = 1;
@@ -294,7 +294,7 @@ static int e1000_set_pauseparam(struct net_device *netdev,
 	adapter->fc_autoneg = pause->autoneg;
 
 	while (test_and_set_bit(__E1000_RESETTING, &adapter->flags))
-		msleep(1);
+		usleep_range(1000, 5000);
 
 	if (pause->rx_pause && pause->tx_pause)
 		hw->fc = E1000_FC_FULL;
@@ -592,7 +592,7 @@ static int e1000_set_ringparam(struct net_device *netdev,
 		return -EINVAL;
 
 	while (test_and_set_bit(__E1000_RESETTING, &adapter->flags))
-		msleep(1);
+		usleep_range(1000, 5000);
 
 	if (netif_running(adapter->netdev))
 		e1000_down(adapter);
@@ -869,7 +869,7 @@ static int e1000_intr_test(struct e1000_adapter *adapter, u64 *data)
 	/* Disable all the interrupts */
 	ew32(IMC, 0xFFFFFFFF);
 	E1000_WRITE_FLUSH();
-	msleep(10);
+	usleep_range(10000, 11000);
 
 	/* Test each interrupt */
 	for (; i < 10; i++) {
@@ -887,7 +887,7 @@ static int e1000_intr_test(struct e1000_adapter *adapter, u64 *data)
 			ew32(IMC, mask);
 			ew32(ICS, mask);
 			E1000_WRITE_FLUSH();
-			msleep(10);
+			usleep_range(10000, 11000);
 
 			if (adapter->test_icr & mask) {
 				*data = 3;
@@ -905,7 +905,7 @@ static int e1000_intr_test(struct e1000_adapter *adapter, u64 *data)
 		ew32(IMS, mask);
 		ew32(ICS, mask);
 		E1000_WRITE_FLUSH();
-		msleep(10);
+		usleep_range(10000, 11000);
 
 		if (!(adapter->test_icr & mask)) {
 			*data = 4;
@@ -923,7 +923,7 @@ static int e1000_intr_test(struct e1000_adapter *adapter, u64 *data)
 			ew32(IMC, ~mask & 0x00007FFF);
 			ew32(ICS, ~mask & 0x00007FFF);
 			E1000_WRITE_FLUSH();
-			msleep(10);
+			usleep_range(10000, 11000);
 
 			if (adapter->test_icr) {
 				*data = 5;
@@ -935,7 +935,7 @@ static int e1000_intr_test(struct e1000_adapter *adapter, u64 *data)
 	/* Disable all the interrupts */
 	ew32(IMC, 0xFFFFFFFF);
 	E1000_WRITE_FLUSH();
-	msleep(10);
+	usleep_range(10000, 11000);
 
 	/* Unhook test interrupt handler */
 	free_irq(irq, netdev);
-- 
2.7.4
