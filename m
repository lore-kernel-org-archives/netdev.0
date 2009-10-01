From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 2/4] tehuti: Convert ethtool get_stats_count() ops to
	get_sset_count()
Date: Thu, 01 Oct 2009 22:27:59 +0100
Message-ID: <1254432479.2735.24.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Andy Gospodarek <andy@greyhouse.net>,
	Alexander Indenbaum <baum@tehutinetworks.net>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:3285 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751480AbZJAVih (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Oct 2009 17:38:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This string query operation was supposed to be replaced by the
generic get_sset_count() starting in 2007.  Convert tehuti's
implementation.

Also remove the dummy self-test name which was not used since tehuti
does not advertise any self-tests.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
Compile-tested only.

Ben.

 drivers/net/tehuti.c |   27 ++++++++++++---------------
 1 files changed, 12 insertions(+), 15 deletions(-)

diff --git a/drivers/net/tehuti.c b/drivers/net/tehuti.c
index ec9dfb2..79d4868 100644
--- a/drivers/net/tehuti.c
+++ b/drivers/net/tehuti.c
@@ -2105,12 +2105,6 @@ err_pci:
 }
 
 /****************** Ethtool interface *********************/
-/* get strings for tests */
-static const char
- bdx_test_names[][ETH_GSTRING_LEN] = {
-	"No tests defined"
-};
-
 /* get strings for statistics counters */
 static const char
  bdx_stat_names[][ETH_GSTRING_LEN] = {
@@ -2380,9 +2374,6 @@ bdx_set_ringparam(struct net_device *netdev, struct ethtool_ringparam *ring)
 static void bdx_get_strings(struct net_device *netdev, u32 stringset, u8 *data)
 {
 	switch (stringset) {
-	case ETH_SS_TEST:
-		memcpy(data, *bdx_test_names, sizeof(bdx_test_names));
-		break;
 	case ETH_SS_STATS:
 		memcpy(data, *bdx_stat_names, sizeof(bdx_stat_names));
 		break;
@@ -2390,15 +2381,21 @@ static void bdx_get_strings(struct net_device *netdev, u32 stringset, u8 *data)
 }
 
 /*
- * bdx_get_stats_count - return number of 64bit statistics counters
+ * bdx_get_sset_count - return number of statistics or tests
  * @netdev
  */
-static int bdx_get_stats_count(struct net_device *netdev)
+static int bdx_get_sset_count(struct net_device *netdev, int stringset)
 {
 	struct bdx_priv *priv = netdev_priv(netdev);
-	BDX_ASSERT(ARRAY_SIZE(bdx_stat_names)
-		   != sizeof(struct bdx_stats) / sizeof(u64));
-	return ((priv->stats_flag) ? ARRAY_SIZE(bdx_stat_names)	: 0);
+
+	switch (stringset) {
+	case ETH_SS_STATS:
+		BDX_ASSERT(ARRAY_SIZE(bdx_stat_names)
+			   != sizeof(struct bdx_stats) / sizeof(u64));
+		return ((priv->stats_flag) ? ARRAY_SIZE(bdx_stat_names)	: 0);
+	default:
+		return -EINVAL;
+	}
 }
 
 /*
@@ -2441,7 +2438,7 @@ static void bdx_ethtool_ops(struct net_device *netdev)
 		.get_sg = ethtool_op_get_sg,
 		.get_tso = ethtool_op_get_tso,
 		.get_strings = bdx_get_strings,
-		.get_stats_count = bdx_get_stats_count,
+		.get_sset_count = bdx_get_sset_count,
 		.get_ethtool_stats = bdx_get_ethtool_stats,
 	};
 

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

