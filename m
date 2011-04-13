From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 3/5] tg3: Automatically size stat/test string
 arrays
Date: Wed, 13 Apr 2011 14:05:06 -0700
Message-ID: <1302728708-1797-4-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com,
	"Benjamin Li" <benli@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1671 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932851Ab1DMU4k (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Apr 2011 16:56:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch reimplements the size preprocessor constants of the stats and
ethtool test string arrays.  The size is calculated at compile time
rather than using static constants.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Benjamin Li <benli@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |   15 ++++++++-------
 1 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index b61b52f..9975cdb 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -165,11 +165,6 @@
 
 #define TG3_RAW_IP_ALIGN 2
 
-/* number of ETHTOOL_GSTATS u64's */
-#define TG3_NUM_STATS		(sizeof(struct tg3_ethtool_stats)/sizeof(u64))
-
-#define TG3_NUM_TEST		6
-
 #define TG3_FW_UPDATE_TIMEOUT_SEC	5
 
 #define FIRMWARE_TG3		"tigon/tg3.bin"
@@ -279,7 +274,7 @@ MODULE_DEVICE_TABLE(pci, tg3_pci_tbl);
 
 static const struct {
 	const char string[ETH_GSTRING_LEN];
-} ethtool_stats_keys[TG3_NUM_STATS] = {
+} ethtool_stats_keys[] = {
 	{ "rx_octets" },
 	{ "rx_fragments" },
 	{ "rx_ucast_packets" },
@@ -358,9 +353,12 @@ static const struct {
 	{ "nic_tx_threshold_hit" }
 };
 
+#define TG3_NUM_STATS	ARRAY_SIZE(ethtool_stats_keys)
+
+
 static const struct {
 	const char string[ETH_GSTRING_LEN];
-} ethtool_test_keys[TG3_NUM_TEST] = {
+} ethtool_test_keys[] = {
 	{ "nvram test     (online) " },
 	{ "link test      (online) " },
 	{ "register test  (offline)" },
@@ -369,6 +367,9 @@ static const struct {
 	{ "interrupt test (offline)" },
 };
 
+#define TG3_NUM_TEST	ARRAY_SIZE(ethtool_test_keys)
+
+
 static void tg3_write32(struct tg3 *tp, u32 off, u32 val)
 {
 	writel(val, tp->regs + off);
-- 
1.7.3.4


