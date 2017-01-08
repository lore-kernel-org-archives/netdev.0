From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 2/8] fm10k: remove extraneous variable definition in fm10k_ethtool.c
Date: Sun,  8 Jan 2017 02:10:28 -0800
Message-ID: <20170108101034.119851-3-jeffrey.t.kirsher@intel.com>
References: <20170108101034.119851-1-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:60633 "EHLO mga11.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1162108AbdAHKKq (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 8 Jan 2017 05:10:46 -0500
In-Reply-To: <20170108101034.119851-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

We don't need to typecast a u8 * into a char *, so just remove the extra
variable.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Krishneil Singh <krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c | 21 +++++++++------------
 1 file changed, 9 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c b/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c
index 5241e08..0c84fef 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c
@@ -148,7 +148,7 @@ enum {
 static const char fm10k_prv_flags[FM10K_PRV_FLAG_LEN][ETH_GSTRING_LEN] = {
 };
 
-static void fm10k_add_stat_strings(char **p, const char *prefix,
+static void fm10k_add_stat_strings(u8 **p, const char *prefix,
 				   const struct fm10k_stats stats[],
 				   const unsigned int size)
 {
@@ -164,32 +164,31 @@ static void fm10k_add_stat_strings(char **p, const char *prefix,
 static void fm10k_get_stat_strings(struct net_device *dev, u8 *data)
 {
 	struct fm10k_intfc *interface = netdev_priv(dev);
-	char *p = (char *)data;
 	unsigned int i;
 
-	fm10k_add_stat_strings(&p, "", fm10k_gstrings_net_stats,
+	fm10k_add_stat_strings(&data, "", fm10k_gstrings_net_stats,
 			       FM10K_NETDEV_STATS_LEN);
 
-	fm10k_add_stat_strings(&p, "", fm10k_gstrings_global_stats,
+	fm10k_add_stat_strings(&data, "", fm10k_gstrings_global_stats,
 			       FM10K_GLOBAL_STATS_LEN);
 
-	fm10k_add_stat_strings(&p, "", fm10k_gstrings_mbx_stats,
+	fm10k_add_stat_strings(&data, "", fm10k_gstrings_mbx_stats,
 			       FM10K_MBX_STATS_LEN);
 
 	if (interface->hw.mac.type != fm10k_mac_vf)
-		fm10k_add_stat_strings(&p, "", fm10k_gstrings_pf_stats,
+		fm10k_add_stat_strings(&data, "", fm10k_gstrings_pf_stats,
 				       FM10K_PF_STATS_LEN);
 
 	for (i = 0; i < interface->hw.mac.max_queues; i++) {
 		char prefix[ETH_GSTRING_LEN];
 
 		snprintf(prefix, ETH_GSTRING_LEN, "tx_queue_%u_", i);
-		fm10k_add_stat_strings(&p, prefix,
+		fm10k_add_stat_strings(&data, prefix,
 				       fm10k_gstrings_queue_stats,
 				       FM10K_QUEUE_STATS_LEN);
 
 		snprintf(prefix, ETH_GSTRING_LEN, "rx_queue_%u_", i);
-		fm10k_add_stat_strings(&p, prefix,
+		fm10k_add_stat_strings(&data, prefix,
 				       fm10k_gstrings_queue_stats,
 				       FM10K_QUEUE_STATS_LEN);
 	}
@@ -198,18 +197,16 @@ static void fm10k_get_stat_strings(struct net_device *dev, u8 *data)
 static void fm10k_get_strings(struct net_device *dev,
 			      u32 stringset, u8 *data)
 {
-	char *p = (char *)data;
-
 	switch (stringset) {
 	case ETH_SS_TEST:
-		memcpy(data, *fm10k_gstrings_test,
+		memcpy(data, fm10k_gstrings_test,
 		       FM10K_TEST_LEN * ETH_GSTRING_LEN);
 		break;
 	case ETH_SS_STATS:
 		fm10k_get_stat_strings(dev, data);
 		break;
 	case ETH_SS_PRIV_FLAGS:
-		memcpy(p, fm10k_prv_flags,
+		memcpy(data, fm10k_prv_flags,
 		       FM10K_PRV_FLAG_LEN * ETH_GSTRING_LEN);
 		break;
 	}
-- 
2.9.3
