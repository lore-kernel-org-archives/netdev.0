From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH ethtool 17/21] Change most static global variables into
 automatic variables
Date: Tue, 1 Nov 2011 23:21:07 +0000
Message-ID: <1320189667.2758.48.camel@bwh-desktop>
References: <1320186901.2758.30.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <linux-net-drivers@solarflare.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:38617 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932086Ab1KAXVL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Nov 2011 19:21:11 -0400
In-Reply-To: <1320186901.2758.30.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is necessary preparation for in-process testing.  It should also
reduce the risk of some classes of bug by putting declaration and use
closer together.

Add parameters to various functions as necessary.

Leave the global constants alone.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 ethtool.c |  553 ++++++++++++++++++++++++++++++++-----------------------------
 1 files changed, 293 insertions(+), 260 deletions(-)

diff --git a/ethtool.c b/ethtool.c
index d0929c7..13fb0ef 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -285,114 +285,6 @@ static int show_usage(struct cmd_context *ctx)
 	return 0;
 }
 
-static int goffload_changed = 0;
-static int off_csum_rx_wanted = -1;
-static int off_csum_tx_wanted = -1;
-static int off_sg_wanted = -1;
-static int off_tso_wanted = -1;
-static int off_ufo_wanted = -1;
-static int off_gso_wanted = -1;
-static u32 off_flags_wanted = 0;
-static u32 off_flags_mask = 0;
-static int off_gro_wanted = -1;
-
-static struct ethtool_pauseparam epause;
-static int gpause_changed = 0;
-static int pause_autoneg_wanted = -1;
-static int pause_rx_wanted = -1;
-static int pause_tx_wanted = -1;
-
-static struct ethtool_ringparam ering;
-static int gring_changed = 0;
-static s32 ring_rx_wanted = -1;
-static s32 ring_rx_mini_wanted = -1;
-static s32 ring_rx_jumbo_wanted = -1;
-static s32 ring_tx_wanted = -1;
-
-static struct ethtool_channels echannels;
-static int gchannels_changed;
-static s32 channels_rx_wanted = -1;
-static s32 channels_tx_wanted = -1;
-static s32 channels_other_wanted = -1;
-static s32 channels_combined_wanted = -1;
-
-static struct ethtool_coalesce ecoal;
-static int gcoalesce_changed = 0;
-static s32 coal_stats_wanted = -1;
-static int coal_adaptive_rx_wanted = -1;
-static int coal_adaptive_tx_wanted = -1;
-static s32 coal_sample_rate_wanted = -1;
-static s32 coal_pkt_rate_low_wanted = -1;
-static s32 coal_pkt_rate_high_wanted = -1;
-static s32 coal_rx_usec_wanted = -1;
-static s32 coal_rx_frames_wanted = -1;
-static s32 coal_rx_usec_irq_wanted = -1;
-static s32 coal_rx_frames_irq_wanted = -1;
-static s32 coal_tx_usec_wanted = -1;
-static s32 coal_tx_frames_wanted = -1;
-static s32 coal_tx_usec_irq_wanted = -1;
-static s32 coal_tx_frames_irq_wanted = -1;
-static s32 coal_rx_usec_low_wanted = -1;
-static s32 coal_rx_frames_low_wanted = -1;
-static s32 coal_tx_usec_low_wanted = -1;
-static s32 coal_tx_frames_low_wanted = -1;
-static s32 coal_rx_usec_high_wanted = -1;
-static s32 coal_rx_frames_high_wanted = -1;
-static s32 coal_tx_usec_high_wanted = -1;
-static s32 coal_tx_frames_high_wanted = -1;
-
-static int speed_wanted = -1;
-static int duplex_wanted = -1;
-static int port_wanted = -1;
-static int autoneg_wanted = -1;
-static int phyad_wanted = -1;
-static int xcvr_wanted = -1;
-static int advertising_wanted = -1;
-static int gset_changed = 0; /* did anything in GSET change? */
-static u32  wol_wanted = 0;
-static int wol_change = 0;
-static u8 sopass_wanted[SOPASS_MAX];
-static int sopass_change = 0;
-static int gwol_changed = 0; /* did anything in GWOL change? */
-static int phys_id_time = 0;
-static int gregs_changed = 0;
-static int gregs_dump_raw = 0;
-static int gregs_dump_hex = 0;
-static char *gregs_dump_file = NULL;
-static int geeprom_changed = 0;
-static int geeprom_dump_raw = 0;
-static u32 geeprom_offset = 0;
-static u32 geeprom_length = -1;
-static int seeprom_changed = 0;
-static u32 seeprom_magic = 0;
-static u32 seeprom_length = -1;
-static u32 seeprom_offset = 0;
-static u8 seeprom_value = 0;
-static int seeprom_value_seen = 0;
-static int rx_fhash_get = 0;
-static int rx_fhash_set = 0;
-static u32 rx_fhash_val = 0;
-static int rxfhindir_equal = 0;
-static char **rxfhindir_weight = NULL;
-static char *flash_file = NULL;
-static int flash_region = -1;
-
-static int msglvl_changed;
-static u32 msglvl_wanted = 0;
-static u32 msglvl_mask = 0;
-static u32 dump_flag;
-static char *dump_file = NULL;
-
-static int rx_class_rule_get = -1;
-static int rx_class_rule_del = -1;
-static struct ethtool_rx_flow_spec rx_rule_fs;
-
-static enum {
-	ONLINE=0,
-	OFFLINE,
-	EXTERNAL_LB,
-} test_type = OFFLINE;
-
 typedef enum {
 	CMDL_NONE,
 	CMDL_BOOL,
@@ -429,91 +321,6 @@ struct flag_info {
 	u32 value;
 };
 
-static struct cmdline_info cmdline_gregs[] = {
-	{ "raw", CMDL_BOOL, &gregs_dump_raw, NULL },
-	{ "hex", CMDL_BOOL, &gregs_dump_hex, NULL },
-	{ "file", CMDL_STR, &gregs_dump_file, NULL },
-};
-
-static struct cmdline_info cmdline_geeprom[] = {
-	{ "offset", CMDL_U32, &geeprom_offset, NULL },
-	{ "length", CMDL_U32, &geeprom_length, NULL },
-	{ "raw", CMDL_BOOL, &geeprom_dump_raw, NULL },
-};
-
-static struct cmdline_info cmdline_seeprom[] = {
-	{ "magic", CMDL_U32, &seeprom_magic, NULL },
-	{ "offset", CMDL_U32, &seeprom_offset, NULL },
-	{ "length", CMDL_U32, &seeprom_length, NULL },
-	{ "value", CMDL_U8, &seeprom_value, NULL,
-	  0, &seeprom_value_seen },
-};
-
-static struct cmdline_info cmdline_offload[] = {
-	{ "rx", CMDL_BOOL, &off_csum_rx_wanted, NULL },
-	{ "tx", CMDL_BOOL, &off_csum_tx_wanted, NULL },
-	{ "sg", CMDL_BOOL, &off_sg_wanted, NULL },
-	{ "tso", CMDL_BOOL, &off_tso_wanted, NULL },
-	{ "ufo", CMDL_BOOL, &off_ufo_wanted, NULL },
-	{ "gso", CMDL_BOOL, &off_gso_wanted, NULL },
-	{ "lro", CMDL_FLAG, &off_flags_wanted, NULL,
-	  ETH_FLAG_LRO, &off_flags_mask },
-	{ "gro", CMDL_BOOL, &off_gro_wanted, NULL },
-	{ "rxvlan", CMDL_FLAG, &off_flags_wanted, NULL,
-	  ETH_FLAG_RXVLAN, &off_flags_mask },
-	{ "txvlan", CMDL_FLAG, &off_flags_wanted, NULL,
-	  ETH_FLAG_TXVLAN, &off_flags_mask },
-	{ "ntuple", CMDL_FLAG, &off_flags_wanted, NULL,
-	  ETH_FLAG_NTUPLE, &off_flags_mask },
-	{ "rxhash", CMDL_FLAG, &off_flags_wanted, NULL,
-	  ETH_FLAG_RXHASH, &off_flags_mask },
-};
-
-static struct cmdline_info cmdline_pause[] = {
-	{ "autoneg", CMDL_BOOL, &pause_autoneg_wanted, &epause.autoneg },
-	{ "rx", CMDL_BOOL, &pause_rx_wanted, &epause.rx_pause },
-	{ "tx", CMDL_BOOL, &pause_tx_wanted, &epause.tx_pause },
-};
-
-static struct cmdline_info cmdline_ring[] = {
-	{ "rx", CMDL_S32, &ring_rx_wanted, &ering.rx_pending },
-	{ "rx-mini", CMDL_S32, &ring_rx_mini_wanted, &ering.rx_mini_pending },
-	{ "rx-jumbo", CMDL_S32, &ring_rx_jumbo_wanted, &ering.rx_jumbo_pending },
-	{ "tx", CMDL_S32, &ring_tx_wanted, &ering.tx_pending },
-};
-
-static struct cmdline_info cmdline_channels[] = {
-	{ "rx", CMDL_S32, &channels_rx_wanted, &echannels.rx_count },
-	{ "tx", CMDL_S32, &channels_tx_wanted, &echannels.tx_count },
-	{ "other", CMDL_S32, &channels_other_wanted, &echannels.other_count },
-	{ "combined", CMDL_S32, &channels_combined_wanted, &echannels.combined_count },
-};
-
-static struct cmdline_info cmdline_coalesce[] = {
-	{ "adaptive-rx", CMDL_BOOL, &coal_adaptive_rx_wanted, &ecoal.use_adaptive_rx_coalesce },
-	{ "adaptive-tx", CMDL_BOOL, &coal_adaptive_tx_wanted, &ecoal.use_adaptive_tx_coalesce },
-	{ "sample-interval", CMDL_S32, &coal_sample_rate_wanted, &ecoal.rate_sample_interval },
-	{ "stats-block-usecs", CMDL_S32, &coal_stats_wanted, &ecoal.stats_block_coalesce_usecs },
-	{ "pkt-rate-low", CMDL_S32, &coal_pkt_rate_low_wanted, &ecoal.pkt_rate_low },
-	{ "pkt-rate-high", CMDL_S32, &coal_pkt_rate_high_wanted, &ecoal.pkt_rate_high },
-	{ "rx-usecs", CMDL_S32, &coal_rx_usec_wanted, &ecoal.rx_coalesce_usecs },
-	{ "rx-frames", CMDL_S32, &coal_rx_frames_wanted, &ecoal.rx_max_coalesced_frames },
-	{ "rx-usecs-irq", CMDL_S32, &coal_rx_usec_irq_wanted, &ecoal.rx_coalesce_usecs_irq },
-	{ "rx-frames-irq", CMDL_S32, &coal_rx_frames_irq_wanted, &ecoal.rx_max_coalesced_frames_irq },
-	{ "tx-usecs", CMDL_S32, &coal_tx_usec_wanted, &ecoal.tx_coalesce_usecs },
-	{ "tx-frames", CMDL_S32, &coal_tx_frames_wanted, &ecoal.tx_max_coalesced_frames },
-	{ "tx-usecs-irq", CMDL_S32, &coal_tx_usec_irq_wanted, &ecoal.tx_coalesce_usecs_irq },
-	{ "tx-frames-irq", CMDL_S32, &coal_tx_frames_irq_wanted, &ecoal.tx_max_coalesced_frames_irq },
-	{ "rx-usecs-low", CMDL_S32, &coal_rx_usec_low_wanted, &ecoal.rx_coalesce_usecs_low },
-	{ "rx-frames-low", CMDL_S32, &coal_rx_frames_low_wanted, &ecoal.rx_max_coalesced_frames_low },
-	{ "tx-usecs-low", CMDL_S32, &coal_tx_usec_low_wanted, &ecoal.tx_coalesce_usecs_low },
-	{ "tx-frames-low", CMDL_S32, &coal_tx_frames_low_wanted, &ecoal.tx_max_coalesced_frames_low },
-	{ "rx-usecs-high", CMDL_S32, &coal_rx_usec_high_wanted, &ecoal.rx_coalesce_usecs_high },
-	{ "rx-frames-high", CMDL_S32, &coal_rx_frames_high_wanted, &ecoal.rx_max_coalesced_frames_high },
-	{ "tx-usecs-high", CMDL_S32, &coal_tx_usec_high_wanted, &ecoal.tx_coalesce_usecs_high },
-	{ "tx-frames-high", CMDL_S32, &coal_tx_frames_high_wanted, &ecoal.tx_max_coalesced_frames_high },
-};
-
 static const struct flag_info flags_msglvl[] = {
 	{ "drv",	NETIF_MSG_DRV },
 	{ "probe",	NETIF_MSG_PROBE },
@@ -1189,7 +996,9 @@ static struct {
 	{ "st_gmac", st_gmac_dump_regs },
 };
 
-static int dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs)
+static int dump_regs(int gregs_dump_raw, int gregs_dump_hex,
+		     const char *gregs_dump_file,
+		     struct ethtool_drvinfo *info, struct ethtool_regs *regs)
 {
 	int i;
 
@@ -1231,7 +1040,8 @@ static int dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs)
 	return 0;
 }
 
-static int dump_eeprom(struct ethtool_drvinfo *info, struct ethtool_eeprom *ee)
+static int dump_eeprom(int geeprom_dump_raw, struct ethtool_drvinfo *info,
+		       struct ethtool_eeprom *ee)
 {
 	int i;
 
@@ -1264,7 +1074,7 @@ static int dump_test(struct ethtool_drvinfo *info, struct ethtool_test *test,
 	rc = test->flags & ETH_TEST_FL_FAILED;
 	fprintf(stdout, "The test result is %s\n", rc ? "FAIL" : "PASS");
 
-	if (test_type == EXTERNAL_LB)
+	if (test->flags & ETH_TEST_FL_EXTERNAL_LB)
 		fprintf(stdout, "External loopback test was %sexecuted\n",
 			(test->flags & ETH_TEST_FL_EXTERNAL_LB_DONE) ?
 			"" : "not ");
@@ -1282,15 +1092,16 @@ static int dump_test(struct ethtool_drvinfo *info, struct ethtool_test *test,
 	return rc;
 }
 
-static int dump_pause(u32 advertising, u32 lp_advertising)
+static int dump_pause(const struct ethtool_pauseparam *epause,
+		      u32 advertising, u32 lp_advertising)
 {
 	fprintf(stdout,
 		"Autonegotiate:	%s\n"
 		"RX:		%s\n"
 		"TX:		%s\n",
-		epause.autoneg ? "on" : "off",
-		epause.rx_pause ? "on" : "off",
-		epause.tx_pause ? "on" : "off");
+		epause->autoneg ? "on" : "off",
+		epause->rx_pause ? "on" : "off",
+		epause->tx_pause ? "on" : "off");
 
 	if (lp_advertising) {
 		int an_rx = 0, an_tx = 0;
@@ -1320,7 +1131,7 @@ static int dump_pause(u32 advertising, u32 lp_advertising)
 	return 0;
 }
 
-static int dump_ring(void)
+static int dump_ring(const struct ethtool_ringparam *ering)
 {
 	fprintf(stdout,
 		"Pre-set maximums:\n"
@@ -1328,10 +1139,10 @@ static int dump_ring(void)
 		"RX Mini:	%u\n"
 		"RX Jumbo:	%u\n"
 		"TX:		%u\n",
-		ering.rx_max_pending,
-		ering.rx_mini_max_pending,
-		ering.rx_jumbo_max_pending,
-		ering.tx_max_pending);
+		ering->rx_max_pending,
+		ering->rx_mini_max_pending,
+		ering->rx_jumbo_max_pending,
+		ering->tx_max_pending);
 
 	fprintf(stdout,
 		"Current hardware settings:\n"
@@ -1339,16 +1150,16 @@ static int dump_ring(void)
 		"RX Mini:	%u\n"
 		"RX Jumbo:	%u\n"
 		"TX:		%u\n",
-		ering.rx_pending,
-		ering.rx_mini_pending,
-		ering.rx_jumbo_pending,
-		ering.tx_pending);
+		ering->rx_pending,
+		ering->rx_mini_pending,
+		ering->rx_jumbo_pending,
+		ering->tx_pending);
 
 	fprintf(stdout, "\n");
 	return 0;
 }
 
-static int dump_channels(void)
+static int dump_channels(const struct ethtool_channels *echannels)
 {
 	fprintf(stdout,
 		"Pre-set maximums:\n"
@@ -1356,9 +1167,9 @@ static int dump_channels(void)
 		"TX:		%u\n"
 		"Other:		%u\n"
 		"Combined:	%u\n",
-		echannels.max_rx, echannels.max_tx,
-		echannels.max_other,
-		echannels.max_combined);
+		echannels->max_rx, echannels->max_tx,
+		echannels->max_other,
+		echannels->max_combined);
 
 	fprintf(stdout,
 		"Current hardware settings:\n"
@@ -1366,19 +1177,19 @@ static int dump_channels(void)
 		"TX:		%u\n"
 		"Other:		%u\n"
 		"Combined:	%u\n",
-		echannels.rx_count, echannels.tx_count,
-		echannels.other_count,
-		echannels.combined_count);
+		echannels->rx_count, echannels->tx_count,
+		echannels->other_count,
+		echannels->combined_count);
 
 	fprintf(stdout, "\n");
 	return 0;
 }
 
-static int dump_coalesce(void)
+static int dump_coalesce(const struct ethtool_coalesce *ecoal)
 {
 	fprintf(stdout, "Adaptive RX: %s  TX: %s\n",
-		ecoal.use_adaptive_rx_coalesce ? "on" : "off",
-		ecoal.use_adaptive_tx_coalesce ? "on" : "off");
+		ecoal->use_adaptive_rx_coalesce ? "on" : "off",
+		ecoal->use_adaptive_tx_coalesce ? "on" : "off");
 
 	fprintf(stdout,
 		"stats-block-usecs: %u\n"
@@ -1406,30 +1217,30 @@ static int dump_coalesce(void)
 		"tx-usecs-high: %u\n"
 		"tx-frame-high: %u\n"
 		"\n",
-		ecoal.stats_block_coalesce_usecs,
-		ecoal.rate_sample_interval,
-		ecoal.pkt_rate_low,
-		ecoal.pkt_rate_high,
-
-		ecoal.rx_coalesce_usecs,
-		ecoal.rx_max_coalesced_frames,
-		ecoal.rx_coalesce_usecs_irq,
-		ecoal.rx_max_coalesced_frames_irq,
-
-		ecoal.tx_coalesce_usecs,
-		ecoal.tx_max_coalesced_frames,
-		ecoal.tx_coalesce_usecs_irq,
-		ecoal.tx_max_coalesced_frames_irq,
-
-		ecoal.rx_coalesce_usecs_low,
-		ecoal.rx_max_coalesced_frames_low,
-		ecoal.tx_coalesce_usecs_low,
-		ecoal.tx_max_coalesced_frames_low,
-
-		ecoal.rx_coalesce_usecs_high,
-		ecoal.rx_max_coalesced_frames_high,
-		ecoal.tx_coalesce_usecs_high,
-		ecoal.tx_max_coalesced_frames_high);
+		ecoal->stats_block_coalesce_usecs,
+		ecoal->rate_sample_interval,
+		ecoal->pkt_rate_low,
+		ecoal->pkt_rate_high,
+
+		ecoal->rx_coalesce_usecs,
+		ecoal->rx_max_coalesced_frames,
+		ecoal->rx_coalesce_usecs_irq,
+		ecoal->rx_max_coalesced_frames_irq,
+
+		ecoal->tx_coalesce_usecs,
+		ecoal->tx_max_coalesced_frames,
+		ecoal->tx_coalesce_usecs_irq,
+		ecoal->tx_max_coalesced_frames_irq,
+
+		ecoal->rx_coalesce_usecs_low,
+		ecoal->rx_max_coalesced_frames_low,
+		ecoal->tx_coalesce_usecs_low,
+		ecoal->tx_max_coalesced_frames_low,
+
+		ecoal->rx_coalesce_usecs_high,
+		ecoal->rx_max_coalesced_frames_high,
+		ecoal->tx_coalesce_usecs_high,
+		ecoal->tx_max_coalesced_frames_high);
 
 	return 0;
 }
@@ -1532,6 +1343,7 @@ static int do_gdrv(struct cmd_context *ctx)
 
 static int do_gpause(struct cmd_context *ctx)
 {
+	struct ethtool_pauseparam epause;
 	struct ethtool_cmd ecmd;
 	int err;
 
@@ -1554,9 +1366,9 @@ static int do_gpause(struct cmd_context *ctx)
 			perror("Cannot get device settings");
 			return 1;
 		}
-		dump_pause(ecmd.advertising, ecmd.lp_advertising);
+		dump_pause(&epause, ecmd.advertising, ecmd.lp_advertising);
 	} else {
-		dump_pause(0, 0);
+		dump_pause(&epause, 0, 0);
 	}
 
 	return 0;
@@ -1593,6 +1405,17 @@ static void do_generic_set(struct cmdline_info *info,
 
 static int do_spause(struct cmd_context *ctx)
 {
+	struct ethtool_pauseparam epause;
+	int gpause_changed = 0;
+	int pause_autoneg_wanted = -1;
+	int pause_rx_wanted = -1;
+	int pause_tx_wanted = -1;
+	struct cmdline_info cmdline_pause[] = {
+		{ "autoneg", CMDL_BOOL, &pause_autoneg_wanted,
+		  &epause.autoneg },
+		{ "rx", CMDL_BOOL, &pause_rx_wanted, &epause.rx_pause },
+		{ "tx", CMDL_BOOL, &pause_tx_wanted, &epause.tx_pause },
+	};
 	int err, changed = 0;
 
 	parse_generic_cmdline(ctx, &gpause_changed,
@@ -1624,6 +1447,20 @@ static int do_spause(struct cmd_context *ctx)
 
 static int do_sring(struct cmd_context *ctx)
 {
+	struct ethtool_ringparam ering;
+	int gring_changed = 0;
+	s32 ring_rx_wanted = -1;
+	s32 ring_rx_mini_wanted = -1;
+	s32 ring_rx_jumbo_wanted = -1;
+	s32 ring_tx_wanted = -1;
+	struct cmdline_info cmdline_ring[] = {
+		{ "rx", CMDL_S32, &ring_rx_wanted, &ering.rx_pending },
+		{ "rx-mini", CMDL_S32, &ring_rx_mini_wanted,
+		  &ering.rx_mini_pending },
+		{ "rx-jumbo", CMDL_S32, &ring_rx_jumbo_wanted,
+		  &ering.rx_jumbo_pending },
+		{ "tx", CMDL_S32, &ring_tx_wanted, &ering.tx_pending },
+	};
 	int err, changed = 0;
 
 	parse_generic_cmdline(ctx, &gring_changed,
@@ -1655,6 +1492,7 @@ static int do_sring(struct cmd_context *ctx)
 
 static int do_gring(struct cmd_context *ctx)
 {
+	struct ethtool_ringparam ering;
 	int err;
 
 	if (ctx->argc != 0)
@@ -1665,7 +1503,7 @@ static int do_gring(struct cmd_context *ctx)
 	ering.cmd = ETHTOOL_GRINGPARAM;
 	err = send_ioctl(ctx, &ering);
 	if (err == 0) {
-		err = dump_ring();
+		err = dump_ring(&ering);
 		if (err)
 			return err;
 	} else {
@@ -1678,6 +1516,20 @@ static int do_gring(struct cmd_context *ctx)
 
 static int do_schannels(struct cmd_context *ctx)
 {
+	struct ethtool_channels echannels;
+	int gchannels_changed;
+	s32 channels_rx_wanted = -1;
+	s32 channels_tx_wanted = -1;
+	s32 channels_other_wanted = -1;
+	s32 channels_combined_wanted = -1;
+	struct cmdline_info cmdline_channels[] = {
+		{ "rx", CMDL_S32, &channels_rx_wanted, &echannels.rx_count },
+		{ "tx", CMDL_S32, &channels_tx_wanted, &echannels.tx_count },
+		{ "other", CMDL_S32, &channels_other_wanted,
+		  &echannels.other_count },
+		{ "combined", CMDL_S32, &channels_combined_wanted,
+		  &echannels.combined_count },
+	};
 	int err, changed = 0;
 
 	parse_generic_cmdline(ctx, &gchannels_changed,
@@ -1714,6 +1566,7 @@ static int do_schannels(struct cmd_context *ctx)
 
 static int do_gchannels(struct cmd_context *ctx)
 {
+	struct ethtool_channels echannels;
 	int err;
 
 	if (ctx->argc != 0)
@@ -1724,7 +1577,7 @@ static int do_gchannels(struct cmd_context *ctx)
 	echannels.cmd = ETHTOOL_GCHANNELS;
 	err = send_ioctl(ctx, &echannels);
 	if (err == 0) {
-		err = dump_channels();
+		err = dump_channels(&echannels);
 		if (err)
 			return err;
 	} else {
@@ -1737,6 +1590,7 @@ static int do_gchannels(struct cmd_context *ctx)
 
 static int do_gcoalesce(struct cmd_context *ctx)
 {
+	struct ethtool_coalesce ecoal;
 	int err;
 
 	if (ctx->argc != 0)
@@ -1747,7 +1601,7 @@ static int do_gcoalesce(struct cmd_context *ctx)
 	ecoal.cmd = ETHTOOL_GCOALESCE;
 	err = send_ioctl(ctx, &ecoal);
 	if (err == 0) {
-		err = dump_coalesce();
+		err = dump_coalesce(&ecoal);
 		if (err)
 			return err;
 	} else {
@@ -1760,6 +1614,76 @@ static int do_gcoalesce(struct cmd_context *ctx)
 
 static int do_scoalesce(struct cmd_context *ctx)
 {
+	struct ethtool_coalesce ecoal;
+	int gcoalesce_changed = 0;
+	s32 coal_stats_wanted = -1;
+	int coal_adaptive_rx_wanted = -1;
+	int coal_adaptive_tx_wanted = -1;
+	s32 coal_sample_rate_wanted = -1;
+	s32 coal_pkt_rate_low_wanted = -1;
+	s32 coal_pkt_rate_high_wanted = -1;
+	s32 coal_rx_usec_wanted = -1;
+	s32 coal_rx_frames_wanted = -1;
+	s32 coal_rx_usec_irq_wanted = -1;
+	s32 coal_rx_frames_irq_wanted = -1;
+	s32 coal_tx_usec_wanted = -1;
+	s32 coal_tx_frames_wanted = -1;
+	s32 coal_tx_usec_irq_wanted = -1;
+	s32 coal_tx_frames_irq_wanted = -1;
+	s32 coal_rx_usec_low_wanted = -1;
+	s32 coal_rx_frames_low_wanted = -1;
+	s32 coal_tx_usec_low_wanted = -1;
+	s32 coal_tx_frames_low_wanted = -1;
+	s32 coal_rx_usec_high_wanted = -1;
+	s32 coal_rx_frames_high_wanted = -1;
+	s32 coal_tx_usec_high_wanted = -1;
+	s32 coal_tx_frames_high_wanted = -1;
+	struct cmdline_info cmdline_coalesce[] = {
+		{ "adaptive-rx", CMDL_BOOL, &coal_adaptive_rx_wanted,
+		  &ecoal.use_adaptive_rx_coalesce },
+		{ "adaptive-tx", CMDL_BOOL, &coal_adaptive_tx_wanted,
+		  &ecoal.use_adaptive_tx_coalesce },
+		{ "sample-interval", CMDL_S32, &coal_sample_rate_wanted,
+		  &ecoal.rate_sample_interval },
+		{ "stats-block-usecs", CMDL_S32, &coal_stats_wanted,
+		  &ecoal.stats_block_coalesce_usecs },
+		{ "pkt-rate-low", CMDL_S32, &coal_pkt_rate_low_wanted,
+		  &ecoal.pkt_rate_low },
+		{ "pkt-rate-high", CMDL_S32, &coal_pkt_rate_high_wanted,
+		  &ecoal.pkt_rate_high },
+		{ "rx-usecs", CMDL_S32, &coal_rx_usec_wanted,
+		  &ecoal.rx_coalesce_usecs },
+		{ "rx-frames", CMDL_S32, &coal_rx_frames_wanted,
+		  &ecoal.rx_max_coalesced_frames },
+		{ "rx-usecs-irq", CMDL_S32, &coal_rx_usec_irq_wanted,
+		  &ecoal.rx_coalesce_usecs_irq },
+		{ "rx-frames-irq", CMDL_S32, &coal_rx_frames_irq_wanted,
+		  &ecoal.rx_max_coalesced_frames_irq },
+		{ "tx-usecs", CMDL_S32, &coal_tx_usec_wanted,
+		  &ecoal.tx_coalesce_usecs },
+		{ "tx-frames", CMDL_S32, &coal_tx_frames_wanted,
+		  &ecoal.tx_max_coalesced_frames },
+		{ "tx-usecs-irq", CMDL_S32, &coal_tx_usec_irq_wanted,
+		  &ecoal.tx_coalesce_usecs_irq },
+		{ "tx-frames-irq", CMDL_S32, &coal_tx_frames_irq_wanted,
+		  &ecoal.tx_max_coalesced_frames_irq },
+		{ "rx-usecs-low", CMDL_S32, &coal_rx_usec_low_wanted,
+		  &ecoal.rx_coalesce_usecs_low },
+		{ "rx-frames-low", CMDL_S32, &coal_rx_frames_low_wanted,
+		  &ecoal.rx_max_coalesced_frames_low },
+		{ "tx-usecs-low", CMDL_S32, &coal_tx_usec_low_wanted,
+		  &ecoal.tx_coalesce_usecs_low },
+		{ "tx-frames-low", CMDL_S32, &coal_tx_frames_low_wanted,
+		  &ecoal.tx_max_coalesced_frames_low },
+		{ "rx-usecs-high", CMDL_S32, &coal_rx_usec_high_wanted,
+		  &ecoal.rx_coalesce_usecs_high },
+		{ "rx-frames-high", CMDL_S32, &coal_rx_frames_high_wanted,
+		  &ecoal.rx_max_coalesced_frames_high },
+		{ "tx-usecs-high", CMDL_S32, &coal_tx_usec_high_wanted,
+		  &ecoal.tx_coalesce_usecs_high },
+		{ "tx-frames-high", CMDL_S32, &coal_tx_frames_high_wanted,
+		  &ecoal.tx_max_coalesced_frames_high },
+	};
 	int err, changed = 0;
 
 	parse_generic_cmdline(ctx, &gcoalesce_changed,
@@ -1889,6 +1813,35 @@ static int do_goffload(struct cmd_context *ctx)
 
 static int do_soffload(struct cmd_context *ctx)
 {
+	int goffload_changed = 0;
+	int off_csum_rx_wanted = -1;
+	int off_csum_tx_wanted = -1;
+	int off_sg_wanted = -1;
+	int off_tso_wanted = -1;
+	int off_ufo_wanted = -1;
+	int off_gso_wanted = -1;
+	u32 off_flags_wanted = 0;
+	u32 off_flags_mask = 0;
+	int off_gro_wanted = -1;
+	struct cmdline_info cmdline_offload[] = {
+		{ "rx", CMDL_BOOL, &off_csum_rx_wanted, NULL },
+		{ "tx", CMDL_BOOL, &off_csum_tx_wanted, NULL },
+		{ "sg", CMDL_BOOL, &off_sg_wanted, NULL },
+		{ "tso", CMDL_BOOL, &off_tso_wanted, NULL },
+		{ "ufo", CMDL_BOOL, &off_ufo_wanted, NULL },
+		{ "gso", CMDL_BOOL, &off_gso_wanted, NULL },
+		{ "lro", CMDL_FLAG, &off_flags_wanted, NULL,
+		  ETH_FLAG_LRO, &off_flags_mask },
+		{ "gro", CMDL_BOOL, &off_gro_wanted, NULL },
+		{ "rxvlan", CMDL_FLAG, &off_flags_wanted, NULL,
+		  ETH_FLAG_RXVLAN, &off_flags_mask },
+		{ "txvlan", CMDL_FLAG, &off_flags_wanted, NULL,
+		  ETH_FLAG_TXVLAN, &off_flags_mask },
+		{ "ntuple", CMDL_FLAG, &off_flags_wanted, NULL,
+		  ETH_FLAG_NTUPLE, &off_flags_mask },
+		{ "rxhash", CMDL_FLAG, &off_flags_wanted, NULL,
+		  ETH_FLAG_RXHASH, &off_flags_mask },
+	};
 	struct ethtool_value eval;
 	int err, changed = 0;
 
@@ -2064,6 +2017,22 @@ static int do_gset(struct cmd_context *ctx)
 
 static int do_sset(struct cmd_context *ctx)
 {
+	int speed_wanted = -1;
+	int duplex_wanted = -1;
+	int port_wanted = -1;
+	int autoneg_wanted = -1;
+	int phyad_wanted = -1;
+	int xcvr_wanted = -1;
+	int advertising_wanted = -1;
+	int gset_changed = 0; /* did anything in GSET change? */
+	u32 wol_wanted = 0;
+	int wol_change = 0;
+	u8 sopass_wanted[SOPASS_MAX];
+	int sopass_change = 0;
+	int gwol_changed = 0; /* did anything in GWOL change? */
+	int msglvl_changed = 0;
+	u32 msglvl_wanted = 0;
+	u32 msglvl_mask = 0;
 	struct cmdline_info cmdline_msglvl[ARRAY_SIZE(flags_msglvl)];
 	int argc = ctx->argc;
 	char **argp = ctx->argp;
@@ -2349,6 +2318,15 @@ static int do_sset(struct cmd_context *ctx)
 
 static int do_gregs(struct cmd_context *ctx)
 {
+	int gregs_changed = 0;
+	int gregs_dump_raw = 0;
+	int gregs_dump_hex = 0;
+	char *gregs_dump_file = NULL;
+	struct cmdline_info cmdline_gregs[] = {
+		{ "raw", CMDL_BOOL, &gregs_dump_raw, NULL },
+		{ "hex", CMDL_BOOL, &gregs_dump_hex, NULL },
+		{ "file", CMDL_STR, &gregs_dump_file, NULL },
+	};
 	int err;
 	struct ethtool_drvinfo drvinfo;
 	struct ethtool_regs *regs;
@@ -2376,7 +2354,8 @@ static int do_gregs(struct cmd_context *ctx)
 		free(regs);
 		return 74;
 	}
-	if(dump_regs(&drvinfo, regs) < 0) {
+	if (dump_regs(gregs_dump_raw, gregs_dump_hex, gregs_dump_file,
+		      &drvinfo, regs) < 0) {
 		perror("Cannot dump registers");
 		free(regs);
 		return 75;
@@ -2404,6 +2383,15 @@ static int do_nway_rst(struct cmd_context *ctx)
 
 static int do_geeprom(struct cmd_context *ctx)
 {
+	int geeprom_changed = 0;
+	int geeprom_dump_raw = 0;
+	u32 geeprom_offset = 0;
+	u32 geeprom_length = -1;
+	struct cmdline_info cmdline_geeprom[] = {
+		{ "offset", CMDL_U32, &geeprom_offset, NULL },
+		{ "length", CMDL_U32, &geeprom_length, NULL },
+		{ "raw", CMDL_BOOL, &geeprom_dump_raw, NULL },
+	};
 	int err;
 	struct ethtool_drvinfo drvinfo;
 	struct ethtool_eeprom *eeprom;
@@ -2438,7 +2426,7 @@ static int do_geeprom(struct cmd_context *ctx)
 		free(eeprom);
 		return 74;
 	}
-	err = dump_eeprom(&drvinfo, eeprom);
+	err = dump_eeprom(geeprom_dump_raw, &drvinfo, eeprom);
 	free(eeprom);
 
 	return err;
@@ -2446,6 +2434,19 @@ static int do_geeprom(struct cmd_context *ctx)
 
 static int do_seeprom(struct cmd_context *ctx)
 {
+	int seeprom_changed = 0;
+	u32 seeprom_magic = 0;
+	u32 seeprom_length = -1;
+	u32 seeprom_offset = 0;
+	u8 seeprom_value = 0;
+	int seeprom_value_seen = 0;
+	struct cmdline_info cmdline_seeprom[] = {
+		{ "magic", CMDL_U32, &seeprom_magic, NULL },
+		{ "offset", CMDL_U32, &seeprom_offset, NULL },
+		{ "length", CMDL_U32, &seeprom_length, NULL },
+		{ "value", CMDL_U8, &seeprom_value, NULL,
+		  0, &seeprom_value_seen },
+	};
 	int err;
 	struct ethtool_drvinfo drvinfo;
 	struct ethtool_eeprom *eeprom;
@@ -2497,6 +2498,11 @@ static int do_seeprom(struct cmd_context *ctx)
 
 static int do_test(struct cmd_context *ctx)
 {
+	enum {
+		ONLINE=0,
+		OFFLINE,
+		EXTERNAL_LB,
+	} test_type;
 	int err;
 	struct ethtool_drvinfo drvinfo;
 	struct ethtool_test *test;
@@ -2514,6 +2520,8 @@ static int do_test(struct cmd_context *ctx)
 		} else {
 			exit_bad_args();
 		}
+	} else {
+		test_type = OFFLINE;
 	}
 
 	drvinfo.cmd = ETHTOOL_GDRVINFO;
@@ -2573,11 +2581,14 @@ static int do_phys_id(struct cmd_context *ctx)
 {
 	int err;
 	struct ethtool_value edata;
+	int phys_id_time;
 
 	if (ctx->argc > 1)
 		exit_bad_args();
 	if (ctx->argc == 1)
 		phys_id_time = get_int(*ctx->argp, 0);
+	else
+		phys_id_time = 0;
 
 	edata.cmd = ETHTOOL_PHYS_ID;
 	edata.data = phys_id_time;
@@ -2660,10 +2671,13 @@ static int do_gstats(struct cmd_context *ctx)
 
 static int do_srxclass(struct cmd_context *ctx)
 {
-	struct ethtool_rxnfc nfccmd;
 	int err;
 
 	if (ctx->argc == 3 && !strcmp(ctx->argp[0], "rx-flow-hash")) {
+		int rx_fhash_set;
+		u32 rx_fhash_val;
+		struct ethtool_rxnfc nfccmd;
+
 		rx_fhash_set = rxflow_str_to_type(ctx->argp[1]);
 		if (!rx_fhash_set)
 			exit_bad_args();
@@ -2690,6 +2704,8 @@ static int do_grxclass(struct cmd_context *ctx)
 	int err;
 
 	if (ctx->argc == 2 && !strcmp(ctx->argp[0], "rx-flow-hash")) {
+		int rx_fhash_get;
+
 		rx_fhash_get = rxflow_str_to_type(ctx->argp[1]);
 		if (!rx_fhash_get)
 			exit_bad_args();
@@ -2755,6 +2771,8 @@ static int do_grxfhindir(struct cmd_context *ctx)
 
 static int do_srxfhindir(struct cmd_context *ctx)
 {
+	int rxfhindir_equal = 0;
+	char **rxfhindir_weight = NULL;
 	struct ethtool_rxfh_indir indir_head;
 	struct ethtool_rxfh_indir *indir;
 	u32 i;
@@ -2831,6 +2849,8 @@ static int do_srxfhindir(struct cmd_context *ctx)
 
 static int do_flash(struct cmd_context *ctx)
 {
+	char *flash_file;
+	int flash_region;
 	struct ethtool_flash efl;
 	int err;
 
@@ -2841,6 +2861,8 @@ static int do_flash(struct cmd_context *ctx)
 		flash_region = strtol(ctx->argp[1], NULL, 0);
 		if (flash_region < 0)
 			exit_bad_args();
+	} else {
+		flash_region = -1;
 	}
 
 	if (strlen(flash_file) > ETHTOOL_FLASH_MAX_FILENAME - 1) {
@@ -2964,14 +2986,15 @@ static int flow_spec_to_ntuple(struct ethtool_rx_flow_spec *fsp,
 	return 0;
 }
 
-static int do_srxntuple(struct cmd_context *ctx)
+static int do_srxntuple(struct cmd_context *ctx,
+			struct ethtool_rx_flow_spec *rx_rule_fs)
 {
 	struct ethtool_rx_ntuple ntuplecmd;
 	struct ethtool_value eval;
 	int err;
 
 	/* attempt to convert the flow classifier to an ntuple classifier */
-	err = flow_spec_to_ntuple(&rx_rule_fs, &ntuplecmd.fs);
+	err = flow_spec_to_ntuple(rx_rule_fs, &ntuplecmd.fs);
 	if (err)
 		return -1;
 
@@ -3010,14 +3033,16 @@ static int do_srxclsrule(struct cmd_context *ctx)
 	if (ctx->argc < 2)
 		exit_bad_args();
 
-	if (!strcmp(ctx->argp[0], "flow-type")) {
+	if (!strcmp(ctx->argp[0], "flow-type")) {	
+		struct ethtool_rx_flow_spec rx_rule_fs;
+
 		ctx->argc--;
 		ctx->argp++;
 		if (rxclass_parse_ruleopts(ctx, &rx_rule_fs) < 0)
 			exit_bad_args();
 
 		/* attempt to add rule via N-tuple specifier */
-		err = do_srxntuple(ctx);
+		err = do_srxntuple(ctx, &rx_rule_fs);
 		if (!err)
 			return 0;
 
@@ -3029,7 +3054,8 @@ static int do_srxclsrule(struct cmd_context *ctx)
 			return 1;
 		}
 	} else if (!strcmp(ctx->argp[0], "delete")) {
-		rx_class_rule_del = get_uint_range(ctx->argp[1], 0, INT_MAX);
+		int rx_class_rule_del =
+			get_uint_range(ctx->argp[1], 0, INT_MAX);
 
 		err = rxclass_rule_del(ctx, rx_class_rule_del);
 
@@ -3051,7 +3077,8 @@ static int do_grxclsrule(struct cmd_context *ctx)
 	int err;
 
 	if (ctx->argc == 2 && !strcmp(ctx->argp[0], "rule")) {
-		rx_class_rule_get = get_uint_range(ctx->argp[1], 0, INT_MAX);
+		int rx_class_rule_get =
+			get_uint_range(ctx->argp[1], 0, INT_MAX);
 
 		err = rxclass_rule_get(ctx, rx_class_rule_get);
 		if (err < 0)
@@ -3077,7 +3104,7 @@ static int do_grxclsrule(struct cmd_context *ctx)
 	return err ? 1 : 0;
 }
 
-static int do_writefwdump(struct ethtool_dump *dump)
+static int do_writefwdump(struct ethtool_dump *dump, const char *dump_file)
 {
 	int err = 0;
 	FILE *f;
@@ -3105,6 +3132,8 @@ static int do_writefwdump(struct ethtool_dump *dump)
 
 static int do_getfwdump(struct cmd_context *ctx)
 {
+	u32 dump_flag;
+	char *dump_file;
 	int err;
 	struct ethtool_dump edata;
 	struct ethtool_dump *data;
@@ -3112,7 +3141,10 @@ static int do_getfwdump(struct cmd_context *ctx)
 	if (ctx->argc == 2 && !strcmp(ctx->argp[0], "data")) {
 		dump_flag = ETHTOOL_GET_DUMP_DATA;
 		dump_file = ctx->argp[1];
-	} else if (ctx->argc != 0) {
+	} else if (ctx->argc == 0) {
+		dump_flag = 0;
+		dump_file = NULL;
+	} else {
 		exit_bad_args();
 	}
 
@@ -3141,7 +3173,7 @@ static int do_getfwdump(struct cmd_context *ctx)
 		err = 1;
 		goto free;
 	}
-	err = do_writefwdump(data);
+	err = do_writefwdump(data, dump_file);
 free:
 	free(data);
 	return err;
@@ -3149,6 +3181,7 @@ free:
 
 static int do_setfwdump(struct cmd_context *ctx)
 {
+	u32 dump_flag;
 	int err;
 	struct ethtool_dump dump;
 
-- 
1.7.4.4



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
