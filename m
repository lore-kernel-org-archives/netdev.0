From: kan.liang@intel.com
Subject: [PATCH 2/5] ethtool: move cmdline_coalesce out of do_scoalesce
Date: Sun, 15 May 2016 00:14:33 -0700
Message-ID: <1463296476-32493-2-git-send-email-kan.liang@intel.com>
References: <1463296476-32493-1-git-send-email-kan.liang@intel.com>
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	nicolas.dichtel@6wind.com, ben@decadent.org.uk,
	jesse.brandeburg@intel.com, andi@firstfloor.org,
	Kan Liang <kan.liang@intel.com>
To: bwh@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:59591 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751995AbcEOOkk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 15 May 2016 10:40:40 -0400
In-Reply-To: <1463296476-32493-1-git-send-email-kan.liang@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kan Liang <kan.liang@intel.com>

Moving cmdline_coalesce out of do_scoalesce, so it can be shared with
other functions.
No behavior change.

Signed-off-by: Kan Liang <kan.liang@intel.com>
---
 ethtool.c | 147 +++++++++++++++++++++++++++++++-------------------------------
 1 file changed, 74 insertions(+), 73 deletions(-)

diff --git a/ethtool.c b/ethtool.c
index bd0583c..86724a2 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -1883,85 +1883,86 @@ static int do_gcoalesce(struct cmd_context *ctx)
 	return 0;
 }
 
+static struct ethtool_coalesce s_ecoal;
+static s32 coal_stats_wanted = -1;
+static int coal_adaptive_rx_wanted = -1;
+static int coal_adaptive_tx_wanted = -1;
+static s32 coal_sample_rate_wanted = -1;
+static s32 coal_pkt_rate_low_wanted = -1;
+static s32 coal_pkt_rate_high_wanted = -1;
+static s32 coal_rx_usec_wanted = -1;
+static s32 coal_rx_frames_wanted = -1;
+static s32 coal_rx_usec_irq_wanted = -1;
+static s32 coal_rx_frames_irq_wanted = -1;
+static s32 coal_tx_usec_wanted = -1;
+static s32 coal_tx_frames_wanted = -1;
+static s32 coal_tx_usec_irq_wanted = -1;
+static s32 coal_tx_frames_irq_wanted = -1;
+static s32 coal_rx_usec_low_wanted = -1;
+static s32 coal_rx_frames_low_wanted = -1;
+static s32 coal_tx_usec_low_wanted = -1;
+static s32 coal_tx_frames_low_wanted = -1;
+static s32 coal_rx_usec_high_wanted = -1;
+static s32 coal_rx_frames_high_wanted = -1;
+static s32 coal_tx_usec_high_wanted = -1;
+static s32 coal_tx_frames_high_wanted = -1;
+
+static struct cmdline_info cmdline_coalesce[] = {
+	{ "adaptive-rx", CMDL_BOOL, &coal_adaptive_rx_wanted,
+	  &s_ecoal.use_adaptive_rx_coalesce },
+	{ "adaptive-tx", CMDL_BOOL, &coal_adaptive_tx_wanted,
+	  &s_ecoal.use_adaptive_tx_coalesce },
+	{ "sample-interval", CMDL_S32, &coal_sample_rate_wanted,
+	  &s_ecoal.rate_sample_interval },
+	{ "stats-block-usecs", CMDL_S32, &coal_stats_wanted,
+	  &s_ecoal.stats_block_coalesce_usecs },
+	{ "pkt-rate-low", CMDL_S32, &coal_pkt_rate_low_wanted,
+	  &s_ecoal.pkt_rate_low },
+	{ "pkt-rate-high", CMDL_S32, &coal_pkt_rate_high_wanted,
+	  &s_ecoal.pkt_rate_high },
+	{ "rx-usecs", CMDL_S32, &coal_rx_usec_wanted,
+	  &s_ecoal.rx_coalesce_usecs },
+	{ "rx-frames", CMDL_S32, &coal_rx_frames_wanted,
+	  &s_ecoal.rx_max_coalesced_frames },
+	{ "rx-usecs-irq", CMDL_S32, &coal_rx_usec_irq_wanted,
+	  &s_ecoal.rx_coalesce_usecs_irq },
+	{ "rx-frames-irq", CMDL_S32, &coal_rx_frames_irq_wanted,
+	  &s_ecoal.rx_max_coalesced_frames_irq },
+	{ "tx-usecs", CMDL_S32, &coal_tx_usec_wanted,
+	  &s_ecoal.tx_coalesce_usecs },
+	{ "tx-frames", CMDL_S32, &coal_tx_frames_wanted,
+	  &s_ecoal.tx_max_coalesced_frames },
+	{ "tx-usecs-irq", CMDL_S32, &coal_tx_usec_irq_wanted,
+	  &s_ecoal.tx_coalesce_usecs_irq },
+	{ "tx-frames-irq", CMDL_S32, &coal_tx_frames_irq_wanted,
+	  &s_ecoal.tx_max_coalesced_frames_irq },
+	{ "rx-usecs-low", CMDL_S32, &coal_rx_usec_low_wanted,
+	  &s_ecoal.rx_coalesce_usecs_low },
+	{ "rx-frames-low", CMDL_S32, &coal_rx_frames_low_wanted,
+	  &s_ecoal.rx_max_coalesced_frames_low },
+	{ "tx-usecs-low", CMDL_S32, &coal_tx_usec_low_wanted,
+	  &s_ecoal.tx_coalesce_usecs_low },
+	{ "tx-frames-low", CMDL_S32, &coal_tx_frames_low_wanted,
+	  &s_ecoal.tx_max_coalesced_frames_low },
+	{ "rx-usecs-high", CMDL_S32, &coal_rx_usec_high_wanted,
+	  &s_ecoal.rx_coalesce_usecs_high },
+	{ "rx-frames-high", CMDL_S32, &coal_rx_frames_high_wanted,
+	  &s_ecoal.rx_max_coalesced_frames_high },
+	{ "tx-usecs-high", CMDL_S32, &coal_tx_usec_high_wanted,
+	  &s_ecoal.tx_coalesce_usecs_high },
+	{ "tx-frames-high", CMDL_S32, &coal_tx_frames_high_wanted,
+	  &s_ecoal.tx_max_coalesced_frames_high },
+};
 static int do_scoalesce(struct cmd_context *ctx)
 {
-	struct ethtool_coalesce ecoal;
 	int gcoalesce_changed = 0;
-	s32 coal_stats_wanted = -1;
-	int coal_adaptive_rx_wanted = -1;
-	int coal_adaptive_tx_wanted = -1;
-	s32 coal_sample_rate_wanted = -1;
-	s32 coal_pkt_rate_low_wanted = -1;
-	s32 coal_pkt_rate_high_wanted = -1;
-	s32 coal_rx_usec_wanted = -1;
-	s32 coal_rx_frames_wanted = -1;
-	s32 coal_rx_usec_irq_wanted = -1;
-	s32 coal_rx_frames_irq_wanted = -1;
-	s32 coal_tx_usec_wanted = -1;
-	s32 coal_tx_frames_wanted = -1;
-	s32 coal_tx_usec_irq_wanted = -1;
-	s32 coal_tx_frames_irq_wanted = -1;
-	s32 coal_rx_usec_low_wanted = -1;
-	s32 coal_rx_frames_low_wanted = -1;
-	s32 coal_tx_usec_low_wanted = -1;
-	s32 coal_tx_frames_low_wanted = -1;
-	s32 coal_rx_usec_high_wanted = -1;
-	s32 coal_rx_frames_high_wanted = -1;
-	s32 coal_tx_usec_high_wanted = -1;
-	s32 coal_tx_frames_high_wanted = -1;
-	struct cmdline_info cmdline_coalesce[] = {
-		{ "adaptive-rx", CMDL_BOOL, &coal_adaptive_rx_wanted,
-		  &ecoal.use_adaptive_rx_coalesce },
-		{ "adaptive-tx", CMDL_BOOL, &coal_adaptive_tx_wanted,
-		  &ecoal.use_adaptive_tx_coalesce },
-		{ "sample-interval", CMDL_S32, &coal_sample_rate_wanted,
-		  &ecoal.rate_sample_interval },
-		{ "stats-block-usecs", CMDL_S32, &coal_stats_wanted,
-		  &ecoal.stats_block_coalesce_usecs },
-		{ "pkt-rate-low", CMDL_S32, &coal_pkt_rate_low_wanted,
-		  &ecoal.pkt_rate_low },
-		{ "pkt-rate-high", CMDL_S32, &coal_pkt_rate_high_wanted,
-		  &ecoal.pkt_rate_high },
-		{ "rx-usecs", CMDL_S32, &coal_rx_usec_wanted,
-		  &ecoal.rx_coalesce_usecs },
-		{ "rx-frames", CMDL_S32, &coal_rx_frames_wanted,
-		  &ecoal.rx_max_coalesced_frames },
-		{ "rx-usecs-irq", CMDL_S32, &coal_rx_usec_irq_wanted,
-		  &ecoal.rx_coalesce_usecs_irq },
-		{ "rx-frames-irq", CMDL_S32, &coal_rx_frames_irq_wanted,
-		  &ecoal.rx_max_coalesced_frames_irq },
-		{ "tx-usecs", CMDL_S32, &coal_tx_usec_wanted,
-		  &ecoal.tx_coalesce_usecs },
-		{ "tx-frames", CMDL_S32, &coal_tx_frames_wanted,
-		  &ecoal.tx_max_coalesced_frames },
-		{ "tx-usecs-irq", CMDL_S32, &coal_tx_usec_irq_wanted,
-		  &ecoal.tx_coalesce_usecs_irq },
-		{ "tx-frames-irq", CMDL_S32, &coal_tx_frames_irq_wanted,
-		  &ecoal.tx_max_coalesced_frames_irq },
-		{ "rx-usecs-low", CMDL_S32, &coal_rx_usec_low_wanted,
-		  &ecoal.rx_coalesce_usecs_low },
-		{ "rx-frames-low", CMDL_S32, &coal_rx_frames_low_wanted,
-		  &ecoal.rx_max_coalesced_frames_low },
-		{ "tx-usecs-low", CMDL_S32, &coal_tx_usec_low_wanted,
-		  &ecoal.tx_coalesce_usecs_low },
-		{ "tx-frames-low", CMDL_S32, &coal_tx_frames_low_wanted,
-		  &ecoal.tx_max_coalesced_frames_low },
-		{ "rx-usecs-high", CMDL_S32, &coal_rx_usec_high_wanted,
-		  &ecoal.rx_coalesce_usecs_high },
-		{ "rx-frames-high", CMDL_S32, &coal_rx_frames_high_wanted,
-		  &ecoal.rx_max_coalesced_frames_high },
-		{ "tx-usecs-high", CMDL_S32, &coal_tx_usec_high_wanted,
-		  &ecoal.tx_coalesce_usecs_high },
-		{ "tx-frames-high", CMDL_S32, &coal_tx_frames_high_wanted,
-		  &ecoal.tx_max_coalesced_frames_high },
-	};
 	int err, changed = 0;
 
 	parse_generic_cmdline(ctx, &gcoalesce_changed,
 			      cmdline_coalesce, ARRAY_SIZE(cmdline_coalesce));
 
-	ecoal.cmd = ETHTOOL_GCOALESCE;
-	err = send_ioctl(ctx, &ecoal);
+	s_ecoal.cmd = ETHTOOL_GCOALESCE;
+	err = send_ioctl(ctx, &s_ecoal);
 	if (err) {
 		perror("Cannot get device coalesce settings");
 		return 76;
@@ -1975,8 +1976,8 @@ static int do_scoalesce(struct cmd_context *ctx)
 		return 80;
 	}
 
-	ecoal.cmd = ETHTOOL_SCOALESCE;
-	err = send_ioctl(ctx, &ecoal);
+	s_ecoal.cmd = ETHTOOL_SCOALESCE;
+	err = send_ioctl(ctx, &s_ecoal);
 	if (err) {
 		perror("Cannot set device coalesce parameters");
 		return 81;
-- 
2.5.0
