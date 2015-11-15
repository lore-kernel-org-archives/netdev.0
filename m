From: Dave Young <dyoung@redhat.com>
Subject: [PATCH] wireless: change cfg80211 regulatory domain info as debug
 messages
Date: Sun, 15 Nov 2015 15:31:05 +0800
Message-ID: <20151115073105.GA18846@dhcp-128-65.nay.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net, johannes@sipsolutions.net
To: linux-wireless@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

cfg80211 module prints a lot of messages like below. Actually printing
once is acceptable but sometimes it will print again and again, it looks
very annoying. It is better to change these detail messages to debugging
only.

cfg80211: World regulatory domain updated:
cfg80211:  DFS Master region: unset
cfg80211:   (start_freq - end_freq @ bandwidth), (max_antenna_gain, max_eirp), (dfs_cac_time)
cfg80211:   (2402000 KHz - 2472000 KHz @ 40000 KHz), (N/A, 2000 mBm), (N/A)
cfg80211:   (2457000 KHz - 2482000 KHz @ 40000 KHz), (N/A, 2000 mBm), (N/A)
cfg80211:   (2474000 KHz - 2494000 KHz @ 20000 KHz), (N/A, 2000 mBm), (N/A)
cfg80211:   (5170000 KHz - 5250000 KHz @ 80000 KHz, 160000 KHz AUTO), (N/A, 2000 mBm), (N/A)
cfg80211:   (5250000 KHz - 5330000 KHz @ 80000 KHz, 160000 KHz AUTO), (N/A, 2000 mBm), (0 s)
cfg80211:   (5490000 KHz - 5730000 KHz @ 160000 KHz), (N/A, 2000 mBm), (0 s)
cfg80211:   (5735000 KHz - 5835000 KHz @ 80000 KHz), (N/A, 2000 mBm), (N/A)
cfg80211:   (57240000 KHz - 63720000 KHz @ 2160000 KHz), (N/A, 0 mBm), (N/A)

The changes in this patch is to replace pr_info with pr_debug in function
print_rd_rules and print_regdomain_info

Signed-off-by: Dave Young <dyoung@redhat.com>
---
 net/wireless/reg.c |   24 ++++++++++++------------
 1 file changed, 12 insertions(+), 12 deletions(-)

--- linux.orig/net/wireless/reg.c
+++ linux/net/wireless/reg.c
@@ -2763,7 +2763,7 @@ static void print_rd_rules(const struct
 	const struct ieee80211_power_rule *power_rule = NULL;
 	char bw[32], cac_time[32];
 
-	pr_info("  (start_freq - end_freq @ bandwidth), (max_antenna_gain, max_eirp), (dfs_cac_time)\n");
+	pr_debug("  (start_freq - end_freq @ bandwidth), (max_antenna_gain, max_eirp), (dfs_cac_time)\n");
 
 	for (i = 0; i < rd->n_reg_rules; i++) {
 		reg_rule = &rd->reg_rules[i];
@@ -2790,7 +2790,7 @@ static void print_rd_rules(const struct
 		 * in certain regions
 		 */
 		if (power_rule->max_antenna_gain)
-			pr_info("  (%d KHz - %d KHz @ %s), (%d mBi, %d mBm), (%s)\n",
+			pr_debug("  (%d KHz - %d KHz @ %s), (%d mBi, %d mBm), (%s)\n",
 				freq_range->start_freq_khz,
 				freq_range->end_freq_khz,
 				bw,
@@ -2798,7 +2798,7 @@ static void print_rd_rules(const struct
 				power_rule->max_eirp,
 				cac_time);
 		else
-			pr_info("  (%d KHz - %d KHz @ %s), (N/A, %d mBm), (%s)\n",
+			pr_debug("  (%d KHz - %d KHz @ %s), (N/A, %d mBm), (%s)\n",
 				freq_range->start_freq_khz,
 				freq_range->end_freq_khz,
 				bw,
@@ -2831,35 +2831,35 @@ static void print_regdomain(const struct
 			struct cfg80211_registered_device *rdev;
 			rdev = cfg80211_rdev_by_wiphy_idx(lr->wiphy_idx);
 			if (rdev) {
-				pr_info("Current regulatory domain updated by AP to: %c%c\n",
+				pr_debug("Current regulatory domain updated by AP to: %c%c\n",
 					rdev->country_ie_alpha2[0],
 					rdev->country_ie_alpha2[1]);
 			} else
-				pr_info("Current regulatory domain intersected:\n");
+				pr_debug("Current regulatory domain intersected:\n");
 		} else
-			pr_info("Current regulatory domain intersected:\n");
+			pr_debug("Current regulatory domain intersected:\n");
 	} else if (is_world_regdom(rd->alpha2)) {
-		pr_info("World regulatory domain updated:\n");
+		pr_debug("World regulatory domain updated:\n");
 	} else {
 		if (is_unknown_alpha2(rd->alpha2))
-			pr_info("Regulatory domain changed to driver built-in settings (unknown country)\n");
+			pr_debug("Regulatory domain changed to driver built-in settings (unknown country)\n");
 		else {
 			if (reg_request_cell_base(lr))
-				pr_info("Regulatory domain changed to country: %c%c by Cell Station\n",
+				pr_debug("Regulatory domain changed to country: %c%c by Cell Station\n",
 					rd->alpha2[0], rd->alpha2[1]);
 			else
-				pr_info("Regulatory domain changed to country: %c%c\n",
+				pr_debug("Regulatory domain changed to country: %c%c\n",
 					rd->alpha2[0], rd->alpha2[1]);
 		}
 	}
 
-	pr_info(" DFS Master region: %s", reg_dfs_region_str(rd->dfs_region));
+	pr_debug(" DFS Master region: %s", reg_dfs_region_str(rd->dfs_region));
 	print_rd_rules(rd);
 }
 
 static void print_regdomain_info(const struct ieee80211_regdomain *rd)
 {
-	pr_info("Regulatory domain: %c%c\n", rd->alpha2[0], rd->alpha2[1]);
+	pr_debug("Regulatory domain: %c%c\n", rd->alpha2[0], rd->alpha2[1]);
 	print_rd_rules(rd);
 }
 
