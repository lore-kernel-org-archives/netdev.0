From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH 09/27] Intel Wired LAN drivers: Use static const
Date: Fri, 10 Dec 2010 22:17:03 -0800
Message-ID: <1292048241-22026-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1292048241-22026-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta11.emeryville.ca.mail.comcast.net ([76.96.27.211]:49712
	"EHLO qmta11.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751345Ab0LKGSG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Dec 2010 01:18:06 -0500
To: davem@davemloft.net
In-Reply-To: <1292048241-22026-1-git-send-email-jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Based on work by Joe Perches <joe@perches.com>

Using static const to decrease data and overall object size.

CC: Joe Perches <joe@perches.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Tested-by: Emil Tantilov <emil.s.tantilov@intel.com>
---
 drivers/net/e1000/e1000_hw.c      |   20 ++++++++++----------
 drivers/net/e1000/e1000_param.c   |   13 +++++++------
 drivers/net/e1000e/phy.c          |   11 ++++++-----
 drivers/net/igb/e1000_phy.c       |   11 ++++++-----
 drivers/net/ixgb/ixgb_param.c     |   21 +++++++++++----------
 drivers/net/ixgbe/ixgbe_ethtool.c |   24 ++++++++++++++----------
 drivers/net/ixgbevf/ethtool.c     |   18 +++++++++++-------
 7 files changed, 65 insertions(+), 53 deletions(-)

diff --git a/drivers/net/e1000/e1000_hw.c b/drivers/net/e1000/e1000_hw.c
index c7e242b6..77d08e6 100644
--- a/drivers/net/e1000/e1000_hw.c
+++ b/drivers/net/e1000/e1000_hw.c
@@ -4892,11 +4892,11 @@ static s32 e1000_get_cable_length(struct e1000_hw *hw, u16 *min_length,
 	} else if (hw->phy_type == e1000_phy_igp) {	/* For IGP PHY */
 		u16 cur_agc_value;
 		u16 min_agc_value = IGP01E1000_AGC_LENGTH_TABLE_SIZE;
-		u16 agc_reg_array[IGP01E1000_PHY_CHANNEL_NUM] =
-		    { IGP01E1000_PHY_AGC_A,
-			IGP01E1000_PHY_AGC_B,
-			IGP01E1000_PHY_AGC_C,
-			IGP01E1000_PHY_AGC_D
+		static const u16 agc_reg_array[IGP01E1000_PHY_CHANNEL_NUM] = {
+		       IGP01E1000_PHY_AGC_A,
+		       IGP01E1000_PHY_AGC_B,
+		       IGP01E1000_PHY_AGC_C,
+		       IGP01E1000_PHY_AGC_D
 		};
 		/* Read the AGC registers for all channels */
 		for (i = 0; i < IGP01E1000_PHY_CHANNEL_NUM; i++) {
@@ -5071,11 +5071,11 @@ static s32 e1000_config_dsp_after_link_change(struct e1000_hw *hw, bool link_up)
 {
 	s32 ret_val;
 	u16 phy_data, phy_saved_data, speed, duplex, i;
-	u16 dsp_reg_array[IGP01E1000_PHY_CHANNEL_NUM] =
-	    { IGP01E1000_PHY_AGC_PARAM_A,
-		IGP01E1000_PHY_AGC_PARAM_B,
-		IGP01E1000_PHY_AGC_PARAM_C,
-		IGP01E1000_PHY_AGC_PARAM_D
+	static const u16 dsp_reg_array[IGP01E1000_PHY_CHANNEL_NUM] = {
+	       IGP01E1000_PHY_AGC_PARAM_A,
+	       IGP01E1000_PHY_AGC_PARAM_B,
+	       IGP01E1000_PHY_AGC_PARAM_C,
+	       IGP01E1000_PHY_AGC_PARAM_D
 	};
 	u16 min_length, max_length;
 
diff --git a/drivers/net/e1000/e1000_param.c b/drivers/net/e1000/e1000_param.c
index 10d8d98..1301eba 100644
--- a/drivers/net/e1000/e1000_param.c
+++ b/drivers/net/e1000/e1000_param.c
@@ -352,12 +352,13 @@ void __devinit e1000_check_options(struct e1000_adapter *adapter)
 	}
 	{ /* Flow Control */
 
-		struct e1000_opt_list fc_list[] =
-			{{ E1000_FC_NONE,    "Flow Control Disabled" },
-			 { E1000_FC_RX_PAUSE,"Flow Control Receive Only" },
-			 { E1000_FC_TX_PAUSE,"Flow Control Transmit Only" },
-			 { E1000_FC_FULL,    "Flow Control Enabled" },
-			 { E1000_FC_DEFAULT, "Flow Control Hardware Default" }};
+		static const struct e1000_opt_list fc_list[] = {
+		       { E1000_FC_NONE, "Flow Control Disabled" },
+		       { E1000_FC_RX_PAUSE, "Flow Control Receive Only" },
+		       { E1000_FC_TX_PAUSE, "Flow Control Transmit Only" },
+		       { E1000_FC_FULL, "Flow Control Enabled" },
+		       { E1000_FC_DEFAULT, "Flow Control Hardware Default" }
+		};
 
 		opt = (struct e1000_option) {
 			.type = list_option,
diff --git a/drivers/net/e1000e/phy.c b/drivers/net/e1000e/phy.c
index 3d3dc0c..6ad90cc 100644
--- a/drivers/net/e1000e/phy.c
+++ b/drivers/net/e1000e/phy.c
@@ -1840,11 +1840,12 @@ s32 e1000e_get_cable_length_igp_2(struct e1000_hw *hw)
 	u16 phy_data, i, agc_value = 0;
 	u16 cur_agc_index, max_agc_index = 0;
 	u16 min_agc_index = IGP02E1000_CABLE_LENGTH_TABLE_SIZE - 1;
-	u16 agc_reg_array[IGP02E1000_PHY_CHANNEL_NUM] =
-							 {IGP02E1000_PHY_AGC_A,
-							  IGP02E1000_PHY_AGC_B,
-							  IGP02E1000_PHY_AGC_C,
-							  IGP02E1000_PHY_AGC_D};
+	static const u16 agc_reg_array[IGP02E1000_PHY_CHANNEL_NUM] = {
+	       IGP02E1000_PHY_AGC_A,
+	       IGP02E1000_PHY_AGC_B,
+	       IGP02E1000_PHY_AGC_C,
+	       IGP02E1000_PHY_AGC_D
+	};
 
 	/* Read the AGC registers for all channels */
 	for (i = 0; i < IGP02E1000_PHY_CHANNEL_NUM; i++) {
diff --git a/drivers/net/igb/e1000_phy.c b/drivers/net/igb/e1000_phy.c
index ddd036a..6694bf3 100644
--- a/drivers/net/igb/e1000_phy.c
+++ b/drivers/net/igb/e1000_phy.c
@@ -1757,11 +1757,12 @@ s32 igb_get_cable_length_igp_2(struct e1000_hw *hw)
 	u16 phy_data, i, agc_value = 0;
 	u16 cur_agc_index, max_agc_index = 0;
 	u16 min_agc_index = IGP02E1000_CABLE_LENGTH_TABLE_SIZE - 1;
-	u16 agc_reg_array[IGP02E1000_PHY_CHANNEL_NUM] =
-							 {IGP02E1000_PHY_AGC_A,
-							  IGP02E1000_PHY_AGC_B,
-							  IGP02E1000_PHY_AGC_C,
-							  IGP02E1000_PHY_AGC_D};
+	static const u16 agc_reg_array[IGP02E1000_PHY_CHANNEL_NUM] = {
+	       IGP02E1000_PHY_AGC_A,
+	       IGP02E1000_PHY_AGC_B,
+	       IGP02E1000_PHY_AGC_C,
+	       IGP02E1000_PHY_AGC_D
+	};
 
 	/* Read the AGC registers for all channels */
 	for (i = 0; i < IGP02E1000_PHY_CHANNEL_NUM; i++) {
diff --git a/drivers/net/ixgb/ixgb_param.c b/drivers/net/ixgb/ixgb_param.c
index 88a08f0..dd7fbeb 100644
--- a/drivers/net/ixgb/ixgb_param.c
+++ b/drivers/net/ixgb/ixgb_param.c
@@ -191,9 +191,9 @@ struct ixgb_option {
 		} r;
 		struct {	/* list_option info */
 			int nr;
-			struct ixgb_opt_list {
+			const struct ixgb_opt_list {
 				int i;
-				char *str;
+				const char *str;
 			} *p;
 		} l;
 	} arg;
@@ -226,7 +226,7 @@ ixgb_validate_option(unsigned int *value, const struct ixgb_option *opt)
 		break;
 	case list_option: {
 		int i;
-		struct ixgb_opt_list *ent;
+		const struct ixgb_opt_list *ent;
 
 		for (i = 0; i < opt->arg.l.nr; i++) {
 			ent = &opt->arg.l.p[i];
@@ -322,14 +322,15 @@ ixgb_check_options(struct ixgb_adapter *adapter)
 	}
 	{ /* Flow Control */
 
-		struct ixgb_opt_list fc_list[] =
-			{{ ixgb_fc_none,	"Flow Control Disabled" },
-			 { ixgb_fc_rx_pause,"Flow Control Receive Only" },
-			 { ixgb_fc_tx_pause,"Flow Control Transmit Only" },
-			 { ixgb_fc_full,	"Flow Control Enabled" },
-			 { ixgb_fc_default, "Flow Control Hardware Default" }};
+		static const struct ixgb_opt_list fc_list[] = {
+		       { ixgb_fc_none, "Flow Control Disabled" },
+		       { ixgb_fc_rx_pause, "Flow Control Receive Only" },
+		       { ixgb_fc_tx_pause, "Flow Control Transmit Only" },
+		       { ixgb_fc_full, "Flow Control Enabled" },
+		       { ixgb_fc_default, "Flow Control Hardware Default" }
+		};
 
-		const struct ixgb_option opt = {
+		static const struct ixgb_option opt = {
 			.type = list_option,
 			.name = "Flow Control",
 			.err  = "reading default settings from EEPROM",
diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index ef3f910..90a740d 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -1157,7 +1157,7 @@ struct ixgbe_reg_test {
 #define TABLE64_TEST_HI	6
 
 /* default 82599 register test */
-static struct ixgbe_reg_test reg_test_82599[] = {
+static const struct ixgbe_reg_test reg_test_82599[] = {
 	{ IXGBE_FCRTL_82599(0), 1, PATTERN_TEST, 0x8007FFF0, 0x8007FFF0 },
 	{ IXGBE_FCRTH_82599(0), 1, PATTERN_TEST, 0x8007FFF0, 0x8007FFF0 },
 	{ IXGBE_PFCTOP, 1, PATTERN_TEST, 0xFFFFFFFF, 0xFFFFFFFF },
@@ -1181,7 +1181,7 @@ static struct ixgbe_reg_test reg_test_82599[] = {
 };
 
 /* default 82598 register test */
-static struct ixgbe_reg_test reg_test_82598[] = {
+static const struct ixgbe_reg_test reg_test_82598[] = {
 	{ IXGBE_FCRTL(0), 1, PATTERN_TEST, 0x8007FFF0, 0x8007FFF0 },
 	{ IXGBE_FCRTH(0), 1, PATTERN_TEST, 0x8007FFF0, 0x8007FFF0 },
 	{ IXGBE_PFCTOP, 1, PATTERN_TEST, 0xFFFFFFFF, 0xFFFFFFFF },
@@ -1208,18 +1208,22 @@ static struct ixgbe_reg_test reg_test_82598[] = {
 	{ 0, 0, 0, 0 }
 };
 
+static const u32 register_test_patterns[] = {
+	0x5A5A5A5A, 0xA5A5A5A5, 0x00000000, 0xFFFFFFFF
+};
+
 #define REG_PATTERN_TEST(R, M, W)                                             \
 {                                                                             \
 	u32 pat, val, before;                                                 \
-	const u32 _test[] = {0x5A5A5A5A, 0xA5A5A5A5, 0x00000000, 0xFFFFFFFF}; \
-	for (pat = 0; pat < ARRAY_SIZE(_test); pat++) {                       \
+	for (pat = 0; pat < ARRAY_SIZE(register_test_patterns); pat++) {      \
 		before = readl(adapter->hw.hw_addr + R);                      \
-		writel((_test[pat] & W), (adapter->hw.hw_addr + R));          \
+		writel((register_test_patterns[pat] & W),                     \
+		       (adapter->hw.hw_addr + R));                            \
 		val = readl(adapter->hw.hw_addr + R);                         \
-		if (val != (_test[pat] & W & M)) {                            \
-			e_err(drv, "pattern test reg %04X failed: got "   \
-			      "0x%08X expected 0x%08X\n",		      \
-			      R, val, (_test[pat] & W & M));                \
+		if (val != (register_test_patterns[pat] & W & M)) {           \
+			e_err(drv, "pattern test reg %04X failed: got "       \
+			      "0x%08X expected 0x%08X\n",                     \
+			      R, val, (register_test_patterns[pat] & W & M)); \
 			*data = R;                                            \
 			writel(before, adapter->hw.hw_addr + R);              \
 			return 1;                                             \
@@ -1246,7 +1250,7 @@ static struct ixgbe_reg_test reg_test_82598[] = {
 
 static int ixgbe_reg_test(struct ixgbe_adapter *adapter, u64 *data)
 {
-	struct ixgbe_reg_test *test;
+	const struct ixgbe_reg_test *test;
 	u32 value, before, after;
 	u32 i, toggle;
 
diff --git a/drivers/net/ixgbevf/ethtool.c b/drivers/net/ixgbevf/ethtool.c
index 4cc817a..fa29b3c 100644
--- a/drivers/net/ixgbevf/ethtool.c
+++ b/drivers/net/ixgbevf/ethtool.c
@@ -544,7 +544,7 @@ struct ixgbevf_reg_test {
 #define TABLE64_TEST_HI	6
 
 /* default VF register test */
-static struct ixgbevf_reg_test reg_test_vf[] = {
+static const struct ixgbevf_reg_test reg_test_vf[] = {
 	{ IXGBE_VFRDBAL(0), 2, PATTERN_TEST, 0xFFFFFF80, 0xFFFFFF80 },
 	{ IXGBE_VFRDBAH(0), 2, PATTERN_TEST, 0xFFFFFFFF, 0xFFFFFFFF },
 	{ IXGBE_VFRDLEN(0), 2, PATTERN_TEST, 0x000FFF80, 0x000FFFFF },
@@ -557,19 +557,23 @@ static struct ixgbevf_reg_test reg_test_vf[] = {
 	{ 0, 0, 0, 0 }
 };
 
+static const u32 register_test_patterns[] = {
+	0x5A5A5A5A, 0xA5A5A5A5, 0x00000000, 0xFFFFFFFF
+};
+
 #define REG_PATTERN_TEST(R, M, W)                                             \
 {                                                                             \
 	u32 pat, val, before;                                                 \
-	const u32 _test[] = {0x5A5A5A5A, 0xA5A5A5A5, 0x00000000, 0xFFFFFFFF}; \
-	for (pat = 0; pat < ARRAY_SIZE(_test); pat++) {                       \
+	for (pat = 0; pat < ARRAY_SIZE(register_test_patterns); pat++) {      \
 		before = readl(adapter->hw.hw_addr + R);                      \
-		writel((_test[pat] & W), (adapter->hw.hw_addr + R));          \
+		writel((register_test_patterns[pat] & W),                     \
+		       (adapter->hw.hw_addr + R));                            \
 		val = readl(adapter->hw.hw_addr + R);                         \
-		if (val != (_test[pat] & W & M)) {                            \
+		if (val != (register_test_patterns[pat] & W & M)) {           \
 			hw_dbg(&adapter->hw,                                  \
 			"pattern test reg %04X failed: got "                  \
 			"0x%08X expected 0x%08X\n",                           \
-			R, val, (_test[pat] & W & M));                        \
+			R, val, (register_test_patterns[pat] & W & M));       \
 			*data = R;                                            \
 			writel(before, adapter->hw.hw_addr + R);              \
 			return 1;                                             \
@@ -596,7 +600,7 @@ static struct ixgbevf_reg_test reg_test_vf[] = {
 
 static int ixgbevf_reg_test(struct ixgbevf_adapter *adapter, u64 *data)
 {
-	struct ixgbevf_reg_test *test;
+	const struct ixgbevf_reg_test *test;
 	u32 i;
 
 	test = reg_test_vf;
-- 
1.7.3.2

