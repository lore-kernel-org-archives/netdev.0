From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH net-next 3/4] tg3: Cleanup hardcoded ethtool test array
 indexes
Date: Wed, 14 Nov 2012 16:44:28 -0800
Message-ID: <1352940269-23821-3-git-send-email-mchan@broadcom.com>
References: <1352940269-23821-1-git-send-email-mchan@broadcom.com>
 <1352940269-23821-2-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nsujir@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4034 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755497Ab2KOAa1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Nov 2012 19:30:27 -0500
In-Reply-To: <1352940269-23821-2-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nithin Nayak Sujir <nsujir@broadcom.com>

Signed-off-by: Nithin Nayak Sujir <nsujir@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c |   70 ++++++++++++++++++++--------------
 1 files changed, 41 insertions(+), 29 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index f533e17..ffff018 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -424,19 +424,27 @@ static const struct {
 };
 
 #define TG3_NUM_STATS	ARRAY_SIZE(ethtool_stats_keys)
+#define TG3_NVRAM_TEST		0
+#define TG3_LINK_TEST		1
+#define TG3_REGISTER_TEST	2
+#define TG3_MEMORY_TEST		3
+#define TG3_MAC_LOOPB_TEST	4
+#define TG3_PHY_LOOPB_TEST	5
+#define TG3_EXT_LOOPB_TEST	6
+#define TG3_INTERRUPT_TEST	7
 
 
 static const struct {
 	const char string[ETH_GSTRING_LEN];
 } ethtool_test_keys[] = {
-	{ "nvram test        (online) " },
-	{ "link test         (online) " },
-	{ "register test     (offline)" },
-	{ "memory test       (offline)" },
-	{ "mac loopback test (offline)" },
-	{ "phy loopback test (offline)" },
-	{ "ext loopback test (offline)" },
-	{ "interrupt test    (offline)" },
+	[TG3_NVRAM_TEST]	= { "nvram test        (online) " },
+	[TG3_LINK_TEST]		= { "link test         (online) " },
+	[TG3_REGISTER_TEST]	= { "register test     (offline)" },
+	[TG3_MEMORY_TEST]	= { "memory test       (offline)" },
+	[TG3_MAC_LOOPB_TEST]	= { "mac loopback test (offline)" },
+	[TG3_PHY_LOOPB_TEST]	= { "phy loopback test (offline)" },
+	[TG3_EXT_LOOPB_TEST]	= { "ext loopback test (offline)" },
+	[TG3_INTERRUPT_TEST]	= { "interrupt test    (offline)" },
 };
 
 #define TG3_NUM_TEST	ARRAY_SIZE(ethtool_test_keys)
@@ -12364,19 +12372,19 @@ static int tg3_test_loopback(struct tg3 *tp, u64 *data, bool do_extlpbk)
 	tp->phy_flags &= ~TG3_PHYFLG_EEE_CAP;
 
 	if (!netif_running(tp->dev)) {
-		data[0] = TG3_LOOPBACK_FAILED;
-		data[1] = TG3_LOOPBACK_FAILED;
+		data[TG3_MAC_LOOPB_TEST] = TG3_LOOPBACK_FAILED;
+		data[TG3_PHY_LOOPB_TEST] = TG3_LOOPBACK_FAILED;
 		if (do_extlpbk)
-			data[2] = TG3_LOOPBACK_FAILED;
+			data[TG3_EXT_LOOPB_TEST] = TG3_LOOPBACK_FAILED;
 		goto done;
 	}
 
 	err = tg3_reset_hw(tp, 1);
 	if (err) {
-		data[0] = TG3_LOOPBACK_FAILED;
-		data[1] = TG3_LOOPBACK_FAILED;
+		data[TG3_MAC_LOOPB_TEST] = TG3_LOOPBACK_FAILED;
+		data[TG3_PHY_LOOPB_TEST] = TG3_LOOPBACK_FAILED;
 		if (do_extlpbk)
-			data[2] = TG3_LOOPBACK_FAILED;
+			data[TG3_EXT_LOOPB_TEST] = TG3_LOOPBACK_FAILED;
 		goto done;
 	}
 
@@ -12399,11 +12407,11 @@ static int tg3_test_loopback(struct tg3 *tp, u64 *data, bool do_extlpbk)
 		tg3_mac_loopback(tp, true);
 
 		if (tg3_run_loopback(tp, ETH_FRAME_LEN, false))
-			data[0] |= TG3_STD_LOOPBACK_FAILED;
+			data[TG3_MAC_LOOPB_TEST] |= TG3_STD_LOOPBACK_FAILED;
 
 		if (tg3_flag(tp, JUMBO_RING_ENABLE) &&
 		    tg3_run_loopback(tp, jmb_pkt_sz + ETH_HLEN, false))
-			data[0] |= TG3_JMB_LOOPBACK_FAILED;
+			data[TG3_MAC_LOOPB_TEST] |= TG3_JMB_LOOPBACK_FAILED;
 
 		tg3_mac_loopback(tp, false);
 	}
@@ -12422,13 +12430,13 @@ static int tg3_test_loopback(struct tg3 *tp, u64 *data, bool do_extlpbk)
 		}
 
 		if (tg3_run_loopback(tp, ETH_FRAME_LEN, false))
-			data[1] |= TG3_STD_LOOPBACK_FAILED;
+			data[TG3_PHY_LOOPB_TEST] |= TG3_STD_LOOPBACK_FAILED;
 		if (tg3_flag(tp, TSO_CAPABLE) &&
 		    tg3_run_loopback(tp, ETH_FRAME_LEN, true))
-			data[1] |= TG3_TSO_LOOPBACK_FAILED;
+			data[TG3_PHY_LOOPB_TEST] |= TG3_TSO_LOOPBACK_FAILED;
 		if (tg3_flag(tp, JUMBO_RING_ENABLE) &&
 		    tg3_run_loopback(tp, jmb_pkt_sz + ETH_HLEN, false))
-			data[1] |= TG3_JMB_LOOPBACK_FAILED;
+			data[TG3_PHY_LOOPB_TEST] |= TG3_JMB_LOOPBACK_FAILED;
 
 		if (do_extlpbk) {
 			tg3_phy_lpbk_set(tp, 0, true);
@@ -12440,13 +12448,16 @@ static int tg3_test_loopback(struct tg3 *tp, u64 *data, bool do_extlpbk)
 			mdelay(40);
 
 			if (tg3_run_loopback(tp, ETH_FRAME_LEN, false))
-				data[2] |= TG3_STD_LOOPBACK_FAILED;
+				data[TG3_EXT_LOOPB_TEST] |=
+							TG3_STD_LOOPBACK_FAILED;
 			if (tg3_flag(tp, TSO_CAPABLE) &&
 			    tg3_run_loopback(tp, ETH_FRAME_LEN, true))
-				data[2] |= TG3_TSO_LOOPBACK_FAILED;
+				data[TG3_EXT_LOOPB_TEST] |=
+							TG3_TSO_LOOPBACK_FAILED;
 			if (tg3_flag(tp, JUMBO_RING_ENABLE) &&
 			    tg3_run_loopback(tp, jmb_pkt_sz + ETH_HLEN, false))
-				data[2] |= TG3_JMB_LOOPBACK_FAILED;
+				data[TG3_EXT_LOOPB_TEST] |=
+							TG3_JMB_LOOPBACK_FAILED;
 		}
 
 		/* Re-enable gphy autopowerdown. */
@@ -12454,7 +12465,8 @@ static int tg3_test_loopback(struct tg3 *tp, u64 *data, bool do_extlpbk)
 			tg3_phy_toggle_apd(tp, true);
 	}
 
-	err = (data[0] | data[1] | data[2]) ? -EIO : 0;
+	err = (data[TG3_MAC_LOOPB_TEST] | data[TG3_PHY_LOOPB_TEST] |
+	       data[TG3_EXT_LOOPB_TEST]) ? -EIO : 0;
 
 done:
 	tp->phy_flags |= eee_cap;
@@ -12479,11 +12491,11 @@ static void tg3_self_test(struct net_device *dev, struct ethtool_test *etest,
 
 	if (tg3_test_nvram(tp) != 0) {
 		etest->flags |= ETH_TEST_FL_FAILED;
-		data[0] = 1;
+		data[TG3_NVRAM_TEST] = 1;
 	}
 	if (!doextlpbk && tg3_test_link(tp)) {
 		etest->flags |= ETH_TEST_FL_FAILED;
-		data[1] = 1;
+		data[TG3_LINK_TEST] = 1;
 	}
 	if (etest->flags & ETH_TEST_FL_OFFLINE) {
 		int err, err2 = 0, irq_sync = 0;
@@ -12509,25 +12521,25 @@ static void tg3_self_test(struct net_device *dev, struct ethtool_test *etest,
 
 		if (tg3_test_registers(tp) != 0) {
 			etest->flags |= ETH_TEST_FL_FAILED;
-			data[2] = 1;
+			data[TG3_REGISTER_TEST] = 1;
 		}
 
 		if (tg3_test_memory(tp) != 0) {
 			etest->flags |= ETH_TEST_FL_FAILED;
-			data[3] = 1;
+			data[TG3_MEMORY_TEST] = 1;
 		}
 
 		if (doextlpbk)
 			etest->flags |= ETH_TEST_FL_EXTERNAL_LB_DONE;
 
-		if (tg3_test_loopback(tp, &data[4], doextlpbk))
+		if (tg3_test_loopback(tp, data, doextlpbk))
 			etest->flags |= ETH_TEST_FL_FAILED;
 
 		tg3_full_unlock(tp);
 
 		if (tg3_test_interrupt(tp) != 0) {
 			etest->flags |= ETH_TEST_FL_FAILED;
-			data[7] = 1;
+			data[TG3_INTERRUPT_TEST] = 1;
 		}
 
 		tg3_full_lock(tp, 0);
-- 
1.7.1
