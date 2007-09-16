From: Jeff Garzik <jeff@garzik.org>
Subject: [PATCH] jumbo all-NICs ethtool count cleanup
Date: Sun, 16 Sep 2007 02:10:15 -0400
Message-ID: <20070916061015.GA11373@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: LKML <linux-kernel@vger.kernel.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:49742 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751130AbXIPGKR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 16 Sep 2007 02:10:17 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Just checked this in locally...

The hooks ->self_test_count() and ->get_stats_count() are now unused
in the main tree.

(based off of latest davem/net-2.6.24.git)

 drivers/net/3c59x.c                     |   11 +++-
 drivers/net/8139cp.c                    |   11 +++-
 drivers/net/8139too.c                   |   11 +++-
 drivers/net/atl1/atl1_ethtool.c         |   11 +++-
 drivers/net/b44.c                       |   11 +++-
 drivers/net/bnx2.c                      |   20 ++++----
 drivers/net/cassini.c                   |   11 +++-
 drivers/net/chelsio/cxgb2.c             |   11 +++-
 drivers/net/cxgb3/cxgb3_main.c          |   11 +++-
 drivers/net/e100.c                      |   19 ++++----
 drivers/net/e1000/e1000_ethtool.c       |   22 ++++-----
 drivers/net/e1000e/ethtool.c            |   21 ++++-----
 drivers/net/ehea/ehea_ethtool.c         |   13 ++++-
 drivers/net/forcedeth.c                 |   45 +++++++++-----------
 drivers/net/gianfar_ethtool.c           |   20 ++++----
 drivers/net/ibm_emac/ibm_emac_core.c    |   12 +++--
 drivers/net/ibmveth.c                   |   11 +++-
 drivers/net/ixgb/ixgb_ethtool.c         |   11 +++-
 drivers/net/ixgbe/ixgbe_ethtool.c       |   11 +++-
 drivers/net/mv643xx_eth.c               |   12 +++--
 drivers/net/myri10ge/myri10ge.c         |   11 +++-
 drivers/net/netxen/netxen_nic_ethtool.c |   21 ++++-----
 drivers/net/pcnet32.c                   |   11 +++-
 drivers/net/qla3xxx.c                   |    2 
 drivers/net/r8169.c                     |   11 +++-
 drivers/net/s2io.c                      |   47 ++++++++------------
 drivers/net/sc92031.c                   |   11 +++-
 drivers/net/skge.c                      |   11 +++-
 drivers/net/sky2.c                      |   11 +++-
 drivers/net/spider_net_ethtool.c        |   11 +++-
 drivers/net/tc35815.c                   |   12 ++++-
 drivers/net/tg3.c                       |   19 ++++----
 drivers/net/ucc_geth_ethtool.c          |   26 ++++++-----
 drivers/net/veth.c                      |   11 +++-
 drivers/net/wireless/libertas/ethtool.c |   72 ++++++++++++++------------------
 35 files changed, 346 insertions(+), 246 deletions(-)

diff --git a/drivers/net/3c59x.c b/drivers/net/3c59x.c
index ad0f6a7..6295e94 100644
--- a/drivers/net/3c59x.c
+++ b/drivers/net/3c59x.c
@@ -2834,9 +2834,14 @@ static void vortex_set_msglevel(struct net_device *dev, u32 dbg)
 	vortex_debug = dbg;
 }
 
-static int vortex_get_stats_count(struct net_device *dev)
+static int vortex_get_sset_count(struct net_device *dev, int sset)
 {
-	return VORTEX_NUM_STATS;
+	switch (sset) {
+	case ETH_SS_STATS:
+		return VORTEX_NUM_STATS;
+	default:
+		return -EOPNOTSUPP;
+	}
 }
 
 static void vortex_get_ethtool_stats(struct net_device *dev,
@@ -2893,7 +2898,7 @@ static const struct ethtool_ops vortex_ethtool_ops = {
 	.get_msglevel           = vortex_get_msglevel,
 	.set_msglevel           = vortex_set_msglevel,
 	.get_ethtool_stats      = vortex_get_ethtool_stats,
-	.get_stats_count        = vortex_get_stats_count,
+	.get_sset_count		= vortex_get_sset_count,
 	.get_settings           = vortex_get_settings,
 	.set_settings           = vortex_set_settings,
 	.get_link               = ethtool_op_get_link,
diff --git a/drivers/net/8139cp.c b/drivers/net/8139cp.c
index 58fad1b..eccaa16 100644
--- a/drivers/net/8139cp.c
+++ b/drivers/net/8139cp.c
@@ -1383,9 +1383,14 @@ static int cp_get_regs_len(struct net_device *dev)
 	return CP_REGS_SIZE;
 }
 
-static int cp_get_stats_count (struct net_device *dev)
+static int cp_get_sset_count (struct net_device *dev, int sset)
 {
-	return CP_NUM_STATS;
+	switch (sset) {
+	case ETH_SS_STATS:
+		return CP_NUM_STATS;
+	default:
+		return -EOPNOTSUPP;
+	}
 }
 
 static int cp_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
@@ -1563,7 +1568,7 @@ static void cp_get_ethtool_stats (struct net_device *dev,
 static const struct ethtool_ops cp_ethtool_ops = {
 	.get_drvinfo		= cp_get_drvinfo,
 	.get_regs_len		= cp_get_regs_len,
-	.get_stats_count	= cp_get_stats_count,
+	.get_sset_count		= cp_get_sset_count,
 	.get_settings		= cp_get_settings,
 	.set_settings		= cp_set_settings,
 	.nway_reset		= cp_nway_reset,
diff --git a/drivers/net/8139too.c b/drivers/net/8139too.c
index 16b9196..565fbdb 100644
--- a/drivers/net/8139too.c
+++ b/drivers/net/8139too.c
@@ -2400,9 +2400,14 @@ static void rtl8139_get_regs(struct net_device *dev, struct ethtool_regs *regs,
 }
 #endif /* CONFIG_8139TOO_MMIO */
 
-static int rtl8139_get_stats_count(struct net_device *dev)
+static int rtl8139_get_sset_count(struct net_device *dev, int sset)
 {
-	return RTL_NUM_STATS;
+	switch (sset) {
+	case ETH_SS_STATS:
+		return RTL_NUM_STATS;
+	default:
+		return -EOPNOTSUPP;
+	}
 }
 
 static void rtl8139_get_ethtool_stats(struct net_device *dev, struct ethtool_stats *stats, u64 *data)
@@ -2433,7 +2438,7 @@ static const struct ethtool_ops rtl8139_ethtool_ops = {
 	.get_wol		= rtl8139_get_wol,
 	.set_wol		= rtl8139_set_wol,
 	.get_strings		= rtl8139_get_strings,
-	.get_stats_count	= rtl8139_get_stats_count,
+	.get_sset_count		= rtl8139_get_sset_count,
 	.get_ethtool_stats	= rtl8139_get_ethtool_stats,
 };
 
diff --git a/drivers/net/atl1/atl1_ethtool.c b/drivers/net/atl1/atl1_ethtool.c
index 53353b6..68a83be 100644
--- a/drivers/net/atl1/atl1_ethtool.c
+++ b/drivers/net/atl1/atl1_ethtool.c
@@ -88,9 +88,14 @@ static void atl1_get_ethtool_stats(struct net_device *netdev,
 
 }
 
-static int atl1_get_stats_count(struct net_device *netdev)
+static int atl1_get_sset_count(struct net_device *netdev, int sset)
 {
-	return ARRAY_SIZE(atl1_gstrings_stats);
+	switch (sset) {
+	case ETH_SS_STATS:
+		return ARRAY_SIZE(atl1_gstrings_stats);
+	default:
+		return -EOPNOTSUPP;
+	}
 }
 
 static int atl1_get_settings(struct net_device *netdev,
@@ -495,6 +500,6 @@ const struct ethtool_ops atl1_ethtool_ops = {
 	.get_strings		= atl1_get_strings,
 	.nway_reset		= atl1_nway_reset,
 	.get_ethtool_stats	= atl1_get_ethtool_stats,
-	.get_stats_count	= atl1_get_stats_count,
+	.get_sset_count		= atl1_get_sset_count,
 	.set_tso		= ethtool_op_set_tso,
 };
diff --git a/drivers/net/b44.c b/drivers/net/b44.c
index 6d19370..e604b67 100644
--- a/drivers/net/b44.c
+++ b/drivers/net/b44.c
@@ -1957,9 +1957,14 @@ static void b44_get_strings(struct net_device *dev, u32 stringset, u8 *data)
 	}
 }
 
-static int b44_get_stats_count(struct net_device *dev)
+static int b44_get_sset_count(struct net_device *dev, int sset)
 {
-	return ARRAY_SIZE(b44_gstrings);
+	switch (sset) {
+	case ETH_SS_STATS:
+		return ARRAY_SIZE(b44_gstrings);
+	default:
+		return -EOPNOTSUPP;
+	}
 }
 
 static void b44_get_ethtool_stats(struct net_device *dev,
@@ -2020,7 +2025,7 @@ static const struct ethtool_ops b44_ethtool_ops = {
 	.get_msglevel		= b44_get_msglevel,
 	.set_msglevel		= b44_set_msglevel,
 	.get_strings		= b44_get_strings,
-	.get_stats_count	= b44_get_stats_count,
+	.get_sset_count		= b44_get_sset_count,
 	.get_ethtool_stats	= b44_get_ethtool_stats,
 };
 
diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index e39dd92..a97e7b9 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -6068,9 +6068,16 @@ static struct {
 };
 
 static int
-bnx2_self_test_count(struct net_device *dev)
+bnx2_get_sset_count(struct net_device *dev, int sset)
 {
-	return BNX2_NUM_TESTS;
+	switch (sset) {
+	case ETH_SS_TEST:
+		return BNX2_NUM_TESTS;
+	case ETH_SS_STATS:
+		return BNX2_NUM_STATS;
+	default:
+		return -EOPNOTSUPP;
+	}
 }
 
 static void
@@ -6144,12 +6151,6 @@ bnx2_get_strings(struct net_device *dev, u32 stringset, u8 *buf)
 	}
 }
 
-static int
-bnx2_get_stats_count(struct net_device *dev)
-{
-	return BNX2_NUM_STATS;
-}
-
 static void
 bnx2_get_ethtool_stats(struct net_device *dev,
 		struct ethtool_stats *stats, u64 *buf)
@@ -6260,12 +6261,11 @@ static const struct ethtool_ops bnx2_ethtool_ops = {
 	.set_tx_csum		= bnx2_set_tx_csum,
 	.set_sg			= ethtool_op_set_sg,
 	.set_tso		= bnx2_set_tso,
-	.self_test_count	= bnx2_self_test_count,
 	.self_test		= bnx2_self_test,
 	.get_strings		= bnx2_get_strings,
 	.phys_id		= bnx2_phys_id,
-	.get_stats_count	= bnx2_get_stats_count,
 	.get_ethtool_stats	= bnx2_get_ethtool_stats,
+	.get_sset_count		= bnx2_get_sset_count,
 };
 
 /* Called with rtnl_lock */
diff --git a/drivers/net/cassini.c b/drivers/net/cassini.c
index f44f3d2..7b34f67 100644
--- a/drivers/net/cassini.c
+++ b/drivers/net/cassini.c
@@ -4772,9 +4772,14 @@ static void cas_get_regs(struct net_device *dev, struct ethtool_regs *regs,
 	cas_read_regs(cp, p, regs->len / sizeof(u32));
 }
 
-static int cas_get_stats_count(struct net_device *dev)
+static int cas_get_sset_count(struct net_device *dev, int sset)
 {
-	return CAS_NUM_STAT_KEYS;
+	switch (sset) {
+	case ETH_SS_STATS:
+		return CAS_NUM_STAT_KEYS;
+	default:
+		return -EOPNOTSUPP;
+	}
 }
 
 static void cas_get_strings(struct net_device *dev, u32 stringset, u8 *data)
@@ -4818,7 +4823,7 @@ static const struct ethtool_ops cas_ethtool_ops = {
 	.set_msglevel		= cas_set_msglevel,
 	.get_regs_len		= cas_get_regs_len,
 	.get_regs		= cas_get_regs,
-	.get_stats_count	= cas_get_stats_count,
+	.get_sset_count		= cas_get_sset_count,
 	.get_strings		= cas_get_strings,
 	.get_ethtool_stats	= cas_get_ethtool_stats,
 };
diff --git a/drivers/net/chelsio/cxgb2.c b/drivers/net/chelsio/cxgb2.c
index 7029f13..2dbf8dc 100644
--- a/drivers/net/chelsio/cxgb2.c
+++ b/drivers/net/chelsio/cxgb2.c
@@ -439,9 +439,14 @@ static void get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info)
 	strcpy(info->bus_info, pci_name(adapter->pdev));
 }
 
-static int get_stats_count(struct net_device *dev)
+static int get_sset_count(struct net_device *dev, int sset)
 {
-	return ARRAY_SIZE(stats_strings);
+	switch (sset) {
+	case ETH_SS_STATS:
+		return ARRAY_SIZE(stats_strings);
+	default:
+		return -EOPNOTSUPP;
+	}
 }
 
 static void get_strings(struct net_device *dev, u32 stringset, u8 *data)
@@ -798,7 +803,7 @@ static const struct ethtool_ops t1_ethtool_ops = {
 	.set_sg            = ethtool_op_set_sg,
 	.get_link          = ethtool_op_get_link,
 	.get_strings       = get_strings,
-	.get_stats_count   = get_stats_count,
+	.get_sset_count	   = get_sset_count,
 	.get_ethtool_stats = get_stats,
 	.get_regs_len      = get_regs_len,
 	.get_regs          = get_regs,
diff --git a/drivers/net/cxgb3/cxgb3_main.c b/drivers/net/cxgb3/cxgb3_main.c
index 04633ea..e22d065 100644
--- a/drivers/net/cxgb3/cxgb3_main.c
+++ b/drivers/net/cxgb3/cxgb3_main.c
@@ -1131,9 +1131,14 @@ static char stats_strings[][ETH_GSTRING_LEN] = {
 
 };
 
-static int get_stats_count(struct net_device *dev)
+static int get_sset_count(struct net_device *dev, int sset)
 {
-	return ARRAY_SIZE(stats_strings);
+	switch (sset) {
+	case ETH_SS_STATS:
+		return ARRAY_SIZE(stats_strings);
+	default:
+		return -EOPNOTSUPP;
+	}
 }
 
 #define T3_REGMAP_SIZE (3 * 1024)
@@ -1640,7 +1645,7 @@ static const struct ethtool_ops cxgb_ethtool_ops = {
 	.get_strings = get_strings,
 	.phys_id = cxgb3_phys_id,
 	.nway_reset = restart_autoneg,
-	.get_stats_count = get_stats_count,
+	.get_sset_count = get_sset_count,
 	.get_ethtool_stats = get_stats,
 	.get_regs_len = get_regs_len,
 	.get_regs = get_regs,
diff --git a/drivers/net/e100.c b/drivers/net/e100.c
index 9912656..1c0187c 100644
--- a/drivers/net/e100.c
+++ b/drivers/net/e100.c
@@ -2374,11 +2374,6 @@ static const char e100_gstrings_test[][ETH_GSTRING_LEN] = {
 };
 #define E100_TEST_LEN	sizeof(e100_gstrings_test) / ETH_GSTRING_LEN
 
-static int e100_diag_test_count(struct net_device *netdev)
-{
-	return E100_TEST_LEN;
-}
-
 static void e100_diag_test(struct net_device *netdev,
 	struct ethtool_test *test, u64 *data)
 {
@@ -2441,9 +2436,16 @@ static const char e100_gstrings_stats[][ETH_GSTRING_LEN] = {
 #define E100_NET_STATS_LEN	21
 #define E100_STATS_LEN	sizeof(e100_gstrings_stats) / ETH_GSTRING_LEN
 
-static int e100_get_stats_count(struct net_device *netdev)
+static int e100_get_sset_count(struct net_device *netdev, int sset)
 {
-	return E100_STATS_LEN;
+	switch (sset) {
+	case ETH_SS_TEST:
+		return E100_TEST_LEN;
+	case ETH_SS_STATS:
+		return E100_STATS_LEN;
+	default:
+		return -EOPNOTSUPP;
+	}
 }
 
 static void e100_get_ethtool_stats(struct net_device *netdev,
@@ -2494,12 +2496,11 @@ static const struct ethtool_ops e100_ethtool_ops = {
 	.set_eeprom		= e100_set_eeprom,
 	.get_ringparam		= e100_get_ringparam,
 	.set_ringparam		= e100_set_ringparam,
-	.self_test_count	= e100_diag_test_count,
 	.self_test		= e100_diag_test,
 	.get_strings		= e100_get_strings,
 	.phys_id		= e100_phys_id,
-	.get_stats_count	= e100_get_stats_count,
 	.get_ethtool_stats	= e100_get_ethtool_stats,
+	.get_sset_count		= e100_get_sset_count,
 };
 
 static int e100_do_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
diff --git a/drivers/net/e1000/e1000_ethtool.c b/drivers/net/e1000/e1000_ethtool.c
index f44d0a1..954afe1 100644
--- a/drivers/net/e1000/e1000_ethtool.c
+++ b/drivers/net/e1000/e1000_ethtool.c
@@ -618,8 +618,6 @@ e1000_get_drvinfo(struct net_device *netdev,
 
 	strncpy(drvinfo->fw_version, firmware_version, 32);
 	strncpy(drvinfo->bus_info, pci_name(adapter->pdev), 32);
-	drvinfo->n_stats = E1000_STATS_LEN;
-	drvinfo->testinfo_len = E1000_TEST_LEN;
 	drvinfo->regdump_len = e1000_get_regs_len(netdev);
 	drvinfo->eedump_len = e1000_get_eeprom_len(netdev);
 }
@@ -1611,9 +1609,16 @@ e1000_link_test(struct e1000_adapter *adapter, uint64_t *data)
 }
 
 static int
-e1000_diag_test_count(struct net_device *netdev)
+e1000_get_sset_count(struct net_device *netdev, int sset)
 {
-	return E1000_TEST_LEN;
+	switch (sset) {
+	case ETH_SS_TEST:
+		return E1000_TEST_LEN;
+	case ETH_SS_STATS:
+		return E1000_STATS_LEN;
+	default:
+		return -EOPNOTSUPP;
+	}
 }
 
 extern void e1000_power_up_phy(struct e1000_adapter *);
@@ -1897,12 +1902,6 @@ e1000_nway_reset(struct net_device *netdev)
 	return 0;
 }
 
-static int
-e1000_get_stats_count(struct net_device *netdev)
-{
-	return E1000_STATS_LEN;
-}
-
 static void
 e1000_get_ethtool_stats(struct net_device *netdev,
 		struct ethtool_stats *stats, uint64_t *data)
@@ -1966,12 +1965,11 @@ static const struct ethtool_ops e1000_ethtool_ops = {
 	.set_tx_csum            = e1000_set_tx_csum,
 	.set_sg                 = ethtool_op_set_sg,
 	.set_tso                = e1000_set_tso,
-	.self_test_count        = e1000_diag_test_count,
 	.self_test              = e1000_diag_test,
 	.get_strings            = e1000_get_strings,
 	.phys_id                = e1000_phys_id,
-	.get_stats_count        = e1000_get_stats_count,
 	.get_ethtool_stats      = e1000_get_ethtool_stats,
+	.get_sset_count		= e1000_get_sset_count,
 };
 
 void e1000_set_ethtool_ops(struct net_device *netdev)
diff --git a/drivers/net/e1000e/ethtool.c b/drivers/net/e1000e/ethtool.c
index 0e80406..3423f33 100644
--- a/drivers/net/e1000e/ethtool.c
+++ b/drivers/net/e1000e/ethtool.c
@@ -577,8 +577,6 @@ static void e1000_get_drvinfo(struct net_device *netdev,
 
 	strncpy(drvinfo->fw_version, firmware_version, 32);
 	strncpy(drvinfo->bus_info, pci_name(adapter->pdev), 32);
-	drvinfo->n_stats = E1000_STATS_LEN;
-	drvinfo->testinfo_len = E1000_TEST_LEN;
 	drvinfo->regdump_len = e1000_get_regs_len(netdev);
 	drvinfo->eedump_len = e1000_get_eeprom_len(netdev);
 }
@@ -1493,9 +1491,16 @@ static int e1000_link_test(struct e1000_adapter *adapter, u64 *data)
 	return *data;
 }
 
-static int e1000_diag_test_count(struct net_device *netdev)
+static int e1000e_get_sset_count(struct net_device *netdev, int sset)
 {
-	return E1000_TEST_LEN;
+	switch (sset) {
+	case ETH_SS_TEST:
+		return E1000_TEST_LEN;
+	case ETH_SS_STATS:
+		return E1000_STATS_LEN;
+	default:
+		return -EOPNOTSUPP;
+	}
 }
 
 static void e1000_diag_test(struct net_device *netdev,
@@ -1692,11 +1697,6 @@ static int e1000_nway_reset(struct net_device *netdev)
 	return 0;
 }
 
-static int e1000_get_stats_count(struct net_device *netdev)
-{
-	return E1000_STATS_LEN;
-}
-
 static void e1000_get_ethtool_stats(struct net_device *netdev,
 				    struct ethtool_stats *stats,
 				    u64 *data)
@@ -1760,12 +1760,11 @@ static const struct ethtool_ops e1000_ethtool_ops = {
 	.set_sg			= ethtool_op_set_sg,
 	.get_tso		= ethtool_op_get_tso,
 	.set_tso		= e1000_set_tso,
-	.self_test_count	= e1000_diag_test_count,
 	.self_test		= e1000_diag_test,
 	.get_strings		= e1000_get_strings,
 	.phys_id		= e1000_phys_id,
-	.get_stats_count	= e1000_get_stats_count,
 	.get_ethtool_stats	= e1000_get_ethtool_stats,
+	.get_sset_count		= e1000e_get_sset_count,
 };
 
 void e1000e_set_ethtool_ops(struct net_device *netdev)
diff --git a/drivers/net/ehea/ehea_ethtool.c b/drivers/net/ehea/ehea_ethtool.c
index 6498455..679f40e 100644
--- a/drivers/net/ehea/ehea_ethtool.c
+++ b/drivers/net/ehea/ehea_ethtool.c
@@ -196,9 +196,14 @@ static void ehea_get_strings(struct net_device *dev, u32 stringset, u8 *data)
 	}
 }
 
-static int ehea_get_stats_count(struct net_device *dev)
+static int ehea_get_sset_count(struct net_device *dev, int sset)
 {
-	return ARRAY_SIZE(ehea_ethtool_stats_keys);
+	switch (sset) {
+	case ETH_SS_STATS:
+		return ARRAY_SIZE(ehea_ethtool_stats_keys);
+	default:
+		return -EOPNOTSUPP;
+	}
 }
 
 static void ehea_get_ethtool_stats(struct net_device *dev,
@@ -207,7 +212,7 @@ static void ehea_get_ethtool_stats(struct net_device *dev,
 	int i, k, tmp;
 	struct ehea_port *port = netdev_priv(dev);
 
-	for (i = 0; i < ehea_get_stats_count(dev); i++)
+	for (i = 0; i < ehea_get_sset_count(dev, ETH_SS_STATS); i++)
 		data[i] = 0;
 	i = 0;
 
@@ -264,7 +269,7 @@ const struct ethtool_ops ehea_ethtool_ops = {
 	.get_link = ethtool_op_get_link,
 	.set_tso = ethtool_op_set_tso,
 	.get_strings = ehea_get_strings,
-	.get_stats_count = ehea_get_stats_count,
+	.get_sset_count = ehea_get_sset_count,
 	.get_ethtool_stats = ehea_get_ethtool_stats,
 	.get_rx_csum = ehea_get_rx_csum,
 	.set_settings = ehea_set_settings,
diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index be74457..cacb290 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -4333,16 +4333,26 @@ static int nv_set_sg(struct net_device *dev, u32 data)
 		return -EOPNOTSUPP;
 }
 
-static int nv_get_stats_count(struct net_device *dev)
+static int nv_get_sset_count(struct net_device *dev, int sset)
 {
 	struct fe_priv *np = netdev_priv(dev);
 
-	if (np->driver_data & DEV_HAS_STATISTICS_V1)
-		return NV_DEV_STATISTICS_V1_COUNT;
-	else if (np->driver_data & DEV_HAS_STATISTICS_V2)
-		return NV_DEV_STATISTICS_V2_COUNT;
-	else
-		return 0;
+	switch (sset) {
+	case ETH_SS_TEST:
+		if (np->driver_data & DEV_HAS_TEST_EXTENDED)
+			return NV_TEST_COUNT_EXTENDED;
+		else
+			return NV_TEST_COUNT_BASE;
+	case ETH_SS_STATS:
+		if (np->driver_data & DEV_HAS_STATISTICS_V1)
+			return NV_DEV_STATISTICS_V1_COUNT;
+		else if (np->driver_data & DEV_HAS_STATISTICS_V2)
+			return NV_DEV_STATISTICS_V2_COUNT;
+		else
+			return 0;
+	default:
+		return -EOPNOTSUPP;
+	}
 }
 
 static void nv_get_ethtool_stats(struct net_device *dev, struct ethtool_stats *estats, u64 *buffer)
@@ -4352,17 +4362,7 @@ static void nv_get_ethtool_stats(struct net_device *dev, struct ethtool_stats *e
 	/* update stats */
 	nv_do_stats_poll((unsigned long)dev);
 
-	memcpy(buffer, &np->estats, nv_get_stats_count(dev)*sizeof(u64));
-}
-
-static int nv_self_test_count(struct net_device *dev)
-{
-	struct fe_priv *np = netdev_priv(dev);
-
-	if (np->driver_data & DEV_HAS_TEST_EXTENDED)
-		return NV_TEST_COUNT_EXTENDED;
-	else
-		return NV_TEST_COUNT_BASE;
+	memcpy(buffer, &np->estats, nv_get_sset_count(dev, ETH_SS_STATS)*sizeof(u64));
 }
 
 static int nv_link_test(struct net_device *dev)
@@ -4609,7 +4609,7 @@ static void nv_self_test(struct net_device *dev, struct ethtool_test *test, u64
 	struct fe_priv *np = netdev_priv(dev);
 	u8 __iomem *base = get_hwbase(dev);
 	int result;
-	memset(buffer, 0, nv_self_test_count(dev)*sizeof(u64));
+	memset(buffer, 0, nv_get_sset_count(dev, ETH_SS_TEST)*sizeof(u64));
 
 	if (!nv_link_test(dev)) {
 		test->flags |= ETH_TEST_FL_FAILED;
@@ -4692,10 +4692,10 @@ static void nv_get_strings(struct net_device *dev, u32 stringset, u8 *buffer)
 {
 	switch (stringset) {
 	case ETH_SS_STATS:
-		memcpy(buffer, &nv_estats_str, nv_get_stats_count(dev)*sizeof(struct nv_ethtool_str));
+		memcpy(buffer, &nv_estats_str, nv_get_sset_count(dev, ETH_SS_STATS)*sizeof(struct nv_ethtool_str));
 		break;
 	case ETH_SS_TEST:
-		memcpy(buffer, &nv_etests_str, nv_self_test_count(dev)*sizeof(struct nv_ethtool_str));
+		memcpy(buffer, &nv_etests_str, nv_get_sset_count(dev, ETH_SS_TEST)*sizeof(struct nv_ethtool_str));
 		break;
 	}
 }
@@ -4720,9 +4720,8 @@ static const struct ethtool_ops ops = {
 	.set_tx_csum = nv_set_tx_csum,
 	.set_sg = nv_set_sg,
 	.get_strings = nv_get_strings,
-	.get_stats_count = nv_get_stats_count,
 	.get_ethtool_stats = nv_get_ethtool_stats,
-	.self_test_count = nv_self_test_count,
+	.get_sset_count = nv_get_sset_count,
 	.self_test = nv_self_test,
 };
 
diff --git a/drivers/net/gianfar_ethtool.c b/drivers/net/gianfar_ethtool.c
index 2470903..6007147 100644
--- a/drivers/net/gianfar_ethtool.c
+++ b/drivers/net/gianfar_ethtool.c
@@ -152,15 +152,19 @@ static void gfar_fill_stats(struct net_device *dev, struct ethtool_stats *dummy,
 			buf[i] = extra[i];
 }
 
-/* Returns the number of stats (and their corresponding strings) */
-static int gfar_stats_count(struct net_device *dev)
+static int gfar_sset_count(struct net_device *dev, int sset)
 {
 	struct gfar_private *priv = netdev_priv(dev);
 
-	if (priv->einfo->device_flags & FSL_GIANFAR_DEV_HAS_RMON)
-		return GFAR_STATS_LEN;
-	else
-		return GFAR_EXTRA_STATS_LEN;
+	switch (sset) {
+	case ETH_SS_STATS:
+		if (priv->einfo->device_flags & FSL_GIANFAR_DEV_HAS_RMON)
+			return GFAR_STATS_LEN;
+		else
+			return GFAR_EXTRA_STATS_LEN;
+	default:
+		return -EOPNOTSUPP;
+	}
 }
 
 /* Fills in the drvinfo structure with some basic info */
@@ -171,8 +175,6 @@ static void gfar_gdrvinfo(struct net_device *dev, struct
 	strncpy(drvinfo->version, gfar_driver_version, GFAR_INFOSTR_LEN);
 	strncpy(drvinfo->fw_version, "N/A", GFAR_INFOSTR_LEN);
 	strncpy(drvinfo->bus_info, "N/A", GFAR_INFOSTR_LEN);
-	drvinfo->n_stats = GFAR_STATS_LEN;
-	drvinfo->testinfo_len = 0;
 	drvinfo->regdump_len = 0;
 	drvinfo->eedump_len = 0;
 }
@@ -575,7 +577,7 @@ const struct ethtool_ops gfar_ethtool_ops = {
 	.get_ringparam = gfar_gringparam,
 	.set_ringparam = gfar_sringparam,
 	.get_strings = gfar_gstrings,
-	.get_stats_count = gfar_stats_count,
+	.get_sset_count = gfar_sset_count,
 	.get_ethtool_stats = gfar_fill_stats,
 	.get_rx_csum = gfar_get_rx_csum,
 	.get_tx_csum = gfar_get_tx_csum,
diff --git a/drivers/net/ibm_emac/ibm_emac_core.c b/drivers/net/ibm_emac/ibm_emac_core.c
index d7da56b..4db765a 100644
--- a/drivers/net/ibm_emac/ibm_emac_core.c
+++ b/drivers/net/ibm_emac/ibm_emac_core.c
@@ -1843,9 +1843,14 @@ static int emac_ethtool_nway_reset(struct net_device *ndev)
 	return res;
 }
 
-static int emac_ethtool_get_stats_count(struct net_device *ndev)
+static int emac_get_sset_count(struct net_device *ndev, int sset)
 {
-	return EMAC_ETHTOOL_STATS_COUNT;
+	switch (sset) {
+	case ETH_SS_STATS:
+		return EMAC_ETHTOOL_STATS_COUNT;
+	default:
+		return -EOPNOTSUPP;
+	}
 }
 
 static void emac_ethtool_get_strings(struct net_device *ndev, u32 stringset,
@@ -1876,7 +1881,6 @@ static void emac_ethtool_get_drvinfo(struct net_device *ndev,
 	strcpy(info->version, DRV_VERSION);
 	info->fw_version[0] = '\0';
 	sprintf(info->bus_info, "PPC 4xx EMAC %d", dev->def->index);
-	info->n_stats = emac_ethtool_get_stats_count(ndev);
 	info->regdump_len = emac_ethtool_get_regs_len(ndev);
 }
 
@@ -1896,7 +1900,7 @@ static const struct ethtool_ops emac_ethtool_ops = {
 	.get_rx_csum = emac_ethtool_get_rx_csum,
 
 	.get_strings = emac_ethtool_get_strings,
-	.get_stats_count = emac_ethtool_get_stats_count,
+	.get_sset_count = emac_get_sset_count,
 	.get_ethtool_stats = emac_ethtool_get_ethtool_stats,
 
 	.get_link = ethtool_op_get_link,
diff --git a/drivers/net/ibmveth.c b/drivers/net/ibmveth.c
index b8d7cec..cc838bf 100644
--- a/drivers/net/ibmveth.c
+++ b/drivers/net/ibmveth.c
@@ -802,9 +802,14 @@ static void ibmveth_get_strings(struct net_device *dev, u32 stringset, u8 *data)
 		memcpy(data, ibmveth_stats[i].name, ETH_GSTRING_LEN);
 }
 
-static int ibmveth_get_stats_count(struct net_device *dev)
+static int ibmveth_get_sset_count(struct net_device *dev, int sset)
 {
-	return ARRAY_SIZE(ibmveth_stats);
+	switch (sset) {
+	case ETH_SS_STATS:
+		return ARRAY_SIZE(ibmveth_stats);
+	default:
+		return -EOPNOTSUPP;
+	}
 }
 
 static void ibmveth_get_ethtool_stats(struct net_device *dev,
@@ -825,7 +830,7 @@ static const struct ethtool_ops netdev_ethtool_ops = {
 	.get_rx_csum		= ibmveth_get_rx_csum,
 	.set_rx_csum		= ibmveth_set_rx_csum,
 	.get_strings		= ibmveth_get_strings,
-	.get_stats_count	= ibmveth_get_stats_count,
+	.get_sset_count		= ibmveth_get_sset_count,
 	.get_ethtool_stats	= ibmveth_get_ethtool_stats,
 };
 
diff --git a/drivers/net/ixgb/ixgb_ethtool.c b/drivers/net/ixgb/ixgb_ethtool.c
index 181b59d..ddad26b 100644
--- a/drivers/net/ixgb/ixgb_ethtool.c
+++ b/drivers/net/ixgb/ixgb_ethtool.c
@@ -659,9 +659,14 @@ ixgb_phys_id(struct net_device *netdev, uint32_t data)
 }
 
 static int 
-ixgb_get_stats_count(struct net_device *netdev)
+ixgb_get_sset_count(struct net_device *netdev, int sset)
 {
-	return IXGB_STATS_LEN;
+	switch (sset) {
+	case ETH_SS_STATS:
+		return IXGB_STATS_LEN;
+	default:
+		return -EOPNOTSUPP;
+	}
 }
 
 static void 
@@ -719,7 +724,7 @@ static const struct ethtool_ops ixgb_ethtool_ops = {
 	.set_tso = ixgb_set_tso,
 	.get_strings = ixgb_get_strings,
 	.phys_id = ixgb_phys_id,
-	.get_stats_count = ixgb_get_stats_count,
+	.get_sset_count = ixgb_get_sset_count,
 	.get_ethtool_stats = ixgb_get_ethtool_stats,
 };
 
diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index 43a2a46..a4e576a 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -737,9 +737,14 @@ err_setup:
 	return err;
 }
 
-static int ixgbe_get_stats_count(struct net_device *netdev)
+static int ixgbe_get_sset_count(struct net_device *netdev, int sset)
 {
-	return IXGBE_STATS_LEN;
+	switch (sset) {
+	case ETH_SS_STATS:
+		return IXGBE_STATS_LEN;
+	default:
+		return -EOPNOTSUPP;
+	}
 }
 
 static void ixgbe_get_ethtool_stats(struct net_device *netdev,
@@ -931,7 +936,7 @@ static struct ethtool_ops ixgbe_ethtool_ops = {
 	.set_tso                = ixgbe_set_tso,
 	.get_strings            = ixgbe_get_strings,
 	.phys_id                = ixgbe_phys_id,
-	.get_stats_count        = ixgbe_get_stats_count,
+	.get_sset_count		= ixgbe_get_sset_count,
 	.get_ethtool_stats      = ixgbe_get_ethtool_stats,
 	.get_coalesce           = ixgbe_get_coalesce,
 	.set_coalesce           = ixgbe_set_coalesce,
diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index a827bca..76585d7 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -2674,9 +2674,14 @@ static void mv643xx_get_drvinfo(struct net_device *netdev,
 	drvinfo->n_stats = MV643XX_STATS_LEN;
 }
 
-static int mv643xx_get_stats_count(struct net_device *netdev)
+static int mv643xx_get_sset_count(struct net_device *netdev, int sset)
 {
-	return MV643XX_STATS_LEN;
+	switch (sset) {
+	case ETH_SS_STATS:
+		return MV643XX_STATS_LEN;
+	default:
+		return -EOPNOTSUPP;
+	}
 }
 
 static void mv643xx_get_ethtool_stats(struct net_device *netdev,
@@ -2737,10 +2742,9 @@ static const struct ethtool_ops mv643xx_ethtool_ops = {
 	.get_drvinfo            = mv643xx_get_drvinfo,
 	.get_link               = mv643xx_eth_get_link,
 	.set_sg			= ethtool_op_set_sg,
-	.get_stats_count        = mv643xx_get_stats_count,
+	.get_sset_count		= mv643xx_get_sset_count,
 	.get_ethtool_stats      = mv643xx_get_ethtool_stats,
 	.get_strings            = mv643xx_get_strings,
-	.get_stats_count        = mv643xx_get_stats_count,
 	.get_ethtool_stats      = mv643xx_get_ethtool_stats,
 	.nway_reset		= mv643xx_eth_nway_restart,
 };
diff --git a/drivers/net/myri10ge/myri10ge.c b/drivers/net/myri10ge/myri10ge.c
index 7fa1609..a7e5bda 100644
--- a/drivers/net/myri10ge/myri10ge.c
+++ b/drivers/net/myri10ge/myri10ge.c
@@ -1418,9 +1418,14 @@ myri10ge_get_strings(struct net_device *netdev, u32 stringset, u8 * data)
 	}
 }
 
-static int myri10ge_get_stats_count(struct net_device *netdev)
+static int myri10ge_get_sset_count(struct net_device *netdev, int sset)
 {
-	return MYRI10GE_STATS_LEN;
+	switch (sset) {
+	case ETH_SS_STATS:
+		return MYRI10GE_STATS_LEN;
+	default:
+		return -EOPNOTSUPP;
+	}
 }
 
 static void
@@ -1504,7 +1509,7 @@ static const struct ethtool_ops myri10ge_ethtool_ops = {
 	.set_tso = ethtool_op_set_tso,
 	.get_link = ethtool_op_get_link,
 	.get_strings = myri10ge_get_strings,
-	.get_stats_count = myri10ge_get_stats_count,
+	.get_sset_count = myri10ge_get_sset_count,
 	.get_ethtool_stats = myri10ge_get_ethtool_stats,
 	.set_msglevel = myri10ge_set_msglevel,
 	.get_msglevel = myri10ge_get_msglevel
diff --git a/drivers/net/netxen/netxen_nic_ethtool.c b/drivers/net/netxen/netxen_nic_ethtool.c
index 08c76b3..78e4231 100644
--- a/drivers/net/netxen/netxen_nic_ethtool.c
+++ b/drivers/net/netxen/netxen_nic_ethtool.c
@@ -115,8 +115,6 @@ netxen_nic_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *drvinfo)
 	sprintf(drvinfo->fw_version, "%d.%d.%d", fw_major, fw_minor, fw_build);
 
 	strncpy(drvinfo->bus_info, pci_name(adapter->pdev), 32);
-	drvinfo->n_stats = NETXEN_NIC_STATS_LEN;
-	drvinfo->testinfo_len = NETXEN_NIC_TEST_LEN;
 	drvinfo->regdump_len = NETXEN_NIC_REGS_LEN;
 	drvinfo->eedump_len = netxen_nic_get_eeprom_len(dev);
 }
@@ -672,9 +670,16 @@ static int netxen_nic_reg_test(struct net_device *dev)
 	return 0;
 }
 
-static int netxen_nic_diag_test_count(struct net_device *dev)
+static int netxen_get_sset_count(struct net_device *dev, int sset)
 {
-	return NETXEN_NIC_TEST_LEN;
+	switch (sset) {
+	case ETH_SS_TEST:
+		return NETXEN_NIC_TEST_LEN;
+	case ETH_SS_STATS:
+		return NETXEN_NIC_STATS_LEN;
+	default:
+		return -EOPNOTSUPP;
+	}
 }
 
 static void
@@ -709,11 +714,6 @@ netxen_nic_get_strings(struct net_device *dev, u32 stringset, u8 * data)
 	}
 }
 
-static int netxen_nic_get_stats_count(struct net_device *dev)
-{
-	return NETXEN_NIC_STATS_LEN;
-}
-
 static void
 netxen_nic_get_ethtool_stats(struct net_device *dev,
 			     struct ethtool_stats *stats, u64 * data)
@@ -747,9 +747,8 @@ struct ethtool_ops netxen_nic_ethtool_ops = {
 	.set_tx_csum = ethtool_op_set_tx_csum,
 	.set_sg = ethtool_op_set_sg,
 	.set_tso = ethtool_op_set_tso,
-	.self_test_count = netxen_nic_diag_test_count,
 	.self_test = netxen_nic_diag_test,
 	.get_strings = netxen_nic_get_strings,
-	.get_stats_count = netxen_nic_get_stats_count,
 	.get_ethtool_stats = netxen_nic_get_ethtool_stats,
+	.get_sset_count = netxen_get_sset_count,
 };
diff --git a/drivers/net/pcnet32.c b/drivers/net/pcnet32.c
index 4840dde..36f92dd 100644
--- a/drivers/net/pcnet32.c
+++ b/drivers/net/pcnet32.c
@@ -847,9 +847,14 @@ static void pcnet32_get_strings(struct net_device *dev, u32 stringset,
 	memcpy(data, pcnet32_gstrings_test, sizeof(pcnet32_gstrings_test));
 }
 
-static int pcnet32_self_test_count(struct net_device *dev)
+static int pcnet32_get_sset_count(struct net_device *dev, int sset)
 {
-	return PCNET32_TEST_LEN;
+	switch (sset) {
+	case ETH_SS_TEST:
+		return PCNET32_TEST_LEN;
+	default:
+		return -EOPNOTSUPP;
+	}
 }
 
 static void pcnet32_ethtool_test(struct net_device *dev,
@@ -1510,11 +1515,11 @@ static const struct ethtool_ops pcnet32_ethtool_ops = {
 	.get_ringparam		= pcnet32_get_ringparam,
 	.set_ringparam		= pcnet32_set_ringparam,
 	.get_strings		= pcnet32_get_strings,
-	.self_test_count	= pcnet32_self_test_count,
 	.self_test		= pcnet32_ethtool_test,
 	.phys_id		= pcnet32_phys_id,
 	.get_regs_len		= pcnet32_get_regs_len,
 	.get_regs		= pcnet32_get_regs,
+	.get_sset_count		= pcnet32_get_sset_count,
 };
 
 /* only probes for non-PCI devices, the rest are handled by
diff --git a/drivers/net/qla3xxx.c b/drivers/net/qla3xxx.c
index 9052b1b..4824fe2 100755
--- a/drivers/net/qla3xxx.c
+++ b/drivers/net/qla3xxx.c
@@ -1865,8 +1865,6 @@ static void ql_get_drvinfo(struct net_device *ndev,
 	strncpy(drvinfo->version, ql3xxx_driver_version, 32);
 	strncpy(drvinfo->fw_version, "N/A", 32);
 	strncpy(drvinfo->bus_info, pci_name(qdev->pdev), 32);
-	drvinfo->n_stats = 0;
-	drvinfo->testinfo_len = 0;
 	drvinfo->regdump_len = 0;
 	drvinfo->eedump_len = 0;
 }
diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 2ec8724..2dbecd5 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -992,9 +992,14 @@ struct rtl8169_counters {
 	u16	tx_underun;
 };
 
-static int rtl8169_get_stats_count(struct net_device *dev)
+static int rtl8169_get_sset_count(struct net_device *dev, int sset)
 {
-	return ARRAY_SIZE(rtl8169_gstrings);
+	switch (sset) {
+	case ETH_SS_STATS:
+		return ARRAY_SIZE(rtl8169_gstrings);
+	default:
+		return -EOPNOTSUPP;
+	}
 }
 
 static void rtl8169_get_ethtool_stats(struct net_device *dev,
@@ -1068,7 +1073,7 @@ static const struct ethtool_ops rtl8169_ethtool_ops = {
 	.get_wol		= rtl8169_get_wol,
 	.set_wol		= rtl8169_set_wol,
 	.get_strings		= rtl8169_get_strings,
-	.get_stats_count	= rtl8169_get_stats_count,
+	.get_sset_count		= rtl8169_get_sset_count,
 	.get_ethtool_stats	= rtl8169_get_ethtool_stats,
 };
 
diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index a285dd7..2de8319 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -5040,12 +5040,6 @@ static void s2io_ethtool_gdrvinfo(struct net_device *dev,
 	strncpy(info->bus_info, pci_name(sp->pdev), sizeof(info->bus_info));
 	info->regdump_len = XENA_REG_SPACE;
 	info->eedump_len = XENA_EEPROM_SPACE;
-	info->testinfo_len = S2IO_TEST_LEN;
-
-	if (sp->device_type == XFRAME_I_DEVICE)
-		info->n_stats = XFRAME_I_STAT_LEN;
-	else
-		info->n_stats = XFRAME_II_STAT_LEN;
 }
 
 /**
@@ -6241,9 +6235,25 @@ static int s2io_get_eeprom_len(struct net_device *dev)
 	return (XENA_EEPROM_SPACE);
 }
 
-static int s2io_ethtool_self_test_count(struct net_device *dev)
+static int s2io_get_sset_count(struct net_device *dev, int sset)
 {
-	return (S2IO_TEST_LEN);
+	struct s2io_nic *sp = dev->priv;
+
+	switch (sset) {
+	case ETH_SS_TEST:
+		return S2IO_TEST_LEN;
+	case ETH_SS_STATS:
+		switch(sp->device_type) {
+		case XFRAME_I_DEVICE:
+			return XFRAME_I_STAT_LEN;
+		case XFRAME_II_DEVICE:
+			return XFRAME_II_STAT_LEN;
+		default:
+			return 0;
+		}
+	default:
+		return -EOPNOTSUPP;
+	}
 }
 
 static void s2io_ethtool_get_strings(struct net_device *dev,
@@ -6270,22 +6280,6 @@ static void s2io_ethtool_get_strings(struct net_device *dev,
 			sizeof(ethtool_driver_stats_keys));
 	}
 }
-static int s2io_ethtool_get_stats_count(struct net_device *dev)
-{
-	struct s2io_nic *sp = dev->priv;
-	int stat_count = 0;
-	switch(sp->device_type) {
-	case XFRAME_I_DEVICE:
-		stat_count = XFRAME_I_STAT_LEN;
-	break;
-
-	case XFRAME_II_DEVICE:
-		stat_count = XFRAME_II_STAT_LEN;
-	break;
-	}
-
-	return stat_count;
-}
 
 static int s2io_ethtool_op_set_tx_csum(struct net_device *dev, u32 data)
 {
@@ -6331,12 +6325,11 @@ static const struct ethtool_ops netdev_ethtool_ops = {
 	.get_tso = s2io_ethtool_op_get_tso,
 	.set_tso = s2io_ethtool_op_set_tso,
 	.set_ufo = ethtool_op_set_ufo,
-	.self_test_count = s2io_ethtool_self_test_count,
 	.self_test = s2io_ethtool_test,
 	.get_strings = s2io_ethtool_get_strings,
 	.phys_id = s2io_ethtool_idnic,
-	.get_stats_count = s2io_ethtool_get_stats_count,
-	.get_ethtool_stats = s2io_get_ethtool_stats
+	.get_ethtool_stats = s2io_get_ethtool_stats,
+	.get_sset_count = s2io_get_sset_count,
 };
 
 /**
diff --git a/drivers/net/sc92031.c b/drivers/net/sc92031.c
index 02c472e..37b4239 100644
--- a/drivers/net/sc92031.c
+++ b/drivers/net/sc92031.c
@@ -1372,9 +1372,14 @@ static void sc92031_ethtool_get_strings(struct net_device *dev,
 				SILAN_STATS_NUM * ETH_GSTRING_LEN);
 }
 
-static int sc92031_ethtool_get_stats_count(struct net_device *dev)
+static int sc92031_ethtool_get_sset_count(struct net_device *dev, int sset)
 {
-	return SILAN_STATS_NUM;
+	switch (sset) {
+	case ETH_SS_STATS:
+		return SILAN_STATS_NUM;
+	default:
+		return -EOPNOTSUPP;
+	}
 }
 
 static void sc92031_ethtool_get_ethtool_stats(struct net_device *dev,
@@ -1397,7 +1402,7 @@ static struct ethtool_ops sc92031_ethtool_ops = {
 	.nway_reset		= sc92031_ethtool_nway_reset,
 	.get_link		= ethtool_op_get_link,
 	.get_strings		= sc92031_ethtool_get_strings,
-	.get_stats_count	= sc92031_ethtool_get_stats_count,
+	.get_sset_count		= sc92031_ethtool_get_sset_count,
 	.get_ethtool_stats	= sc92031_ethtool_get_ethtool_stats,
 };
 
diff --git a/drivers/net/skge.c b/drivers/net/skge.c
index cac499f..d482ab9 100644
--- a/drivers/net/skge.c
+++ b/drivers/net/skge.c
@@ -410,9 +410,14 @@ static const struct skge_stat {
 	{ "rx_fcs_error",	XM_RXF_FCS_ERR, GM_RXF_FCS_ERR },
 };
 
-static int skge_get_stats_count(struct net_device *dev)
+static int skge_get_sset_count(struct net_device *dev, int sset)
 {
-	return ARRAY_SIZE(skge_stats);
+	switch (sset) {
+	case ETH_SS_STATS:
+		return ARRAY_SIZE(skge_stats);
+	default:
+		return -EOPNOTSUPP;
+	}
 }
 
 static void skge_get_ethtool_stats(struct net_device *dev,
@@ -817,7 +822,7 @@ static const struct ethtool_ops skge_ethtool_ops = {
 	.set_rx_csum	= skge_set_rx_csum,
 	.get_strings	= skge_get_strings,
 	.phys_id	= skge_phys_id,
-	.get_stats_count = skge_get_stats_count,
+	.get_sset_count = skge_get_sset_count,
 	.get_ethtool_stats = skge_get_ethtool_stats,
 };
 
diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index 3f6ee98..800ab5c 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -3063,9 +3063,14 @@ static void sky2_set_msglevel(struct net_device *netdev, u32 value)
 	sky2->msg_enable = value;
 }
 
-static int sky2_get_stats_count(struct net_device *dev)
+static int sky2_get_sset_count(struct net_device *dev, int sset)
 {
-	return ARRAY_SIZE(sky2_stats);
+	switch (sset) {
+	case ETH_SS_STATS:
+		return ARRAY_SIZE(sky2_stats);
+	default:
+		return -EOPNOTSUPP;
+	}
 }
 
 static void sky2_get_ethtool_stats(struct net_device *dev,
@@ -3596,7 +3601,7 @@ static const struct ethtool_ops sky2_ethtool_ops = {
 	.get_pauseparam = sky2_get_pauseparam,
 	.set_pauseparam = sky2_set_pauseparam,
 	.phys_id	= sky2_phys_id,
-	.get_stats_count = sky2_get_stats_count,
+	.get_sset_count = sky2_get_sset_count,
 	.get_ethtool_stats = sky2_get_ethtool_stats,
 };
 
diff --git a/drivers/net/spider_net_ethtool.c b/drivers/net/spider_net_ethtool.c
index 1460d50..9427303 100644
--- a/drivers/net/spider_net_ethtool.c
+++ b/drivers/net/spider_net_ethtool.c
@@ -147,9 +147,14 @@ spider_net_ethtool_get_ringparam(struct net_device *netdev,
 	ering->rx_pending = card->rx_chain.num_desc;
 }
 
-static int spider_net_get_stats_count(struct net_device *netdev)
+static int spider_net_get_sset_count(struct net_device *netdev, int sset)
 {
-	return SPIDER_NET_NUM_STATS;
+	switch (sset) {
+	case ETH_SS_STATS:
+		return SPIDER_NET_NUM_STATS;
+	default:
+		return -EOPNOTSUPP;
+	}
 }
 
 static void spider_net_get_ethtool_stats(struct net_device *netdev,
@@ -191,7 +196,7 @@ const struct ethtool_ops spider_net_ethtool_ops = {
 	.set_tx_csum		= ethtool_op_set_tx_csum,
 	.get_ringparam          = spider_net_ethtool_get_ringparam,
 	.get_strings		= spider_net_get_strings,
-	.get_stats_count	= spider_net_get_stats_count,
+	.get_sset_count		= spider_net_get_sset_count,
 	.get_ethtool_stats	= spider_net_get_ethtool_stats,
 };
 
diff --git a/drivers/net/tc35815.c b/drivers/net/tc35815.c
index df82373..a679f43 100644
--- a/drivers/net/tc35815.c
+++ b/drivers/net/tc35815.c
@@ -2162,10 +2162,16 @@ static void tc35815_set_msglevel(struct net_device *dev, u32 datum)
 	lp->msg_enable = datum;
 }
 
-static int tc35815_get_stats_count(struct net_device *dev)
+static int tc35815_get_sset_count(struct net_device *dev, int sset)
 {
 	struct tc35815_local *lp = dev->priv;
-	return sizeof(lp->lstats) / sizeof(int);
+
+	switch (sset) {
+	case ETH_SS_STATS:
+		return sizeof(lp->lstats) / sizeof(int);
+	default:
+		return -EOPNOTSUPP;
+	}
 }
 
 static void tc35815_get_ethtool_stats(struct net_device *dev, struct ethtool_stats *stats, u64 *data)
@@ -2200,7 +2206,7 @@ static const struct ethtool_ops tc35815_ethtool_ops = {
 	.get_msglevel		= tc35815_get_msglevel,
 	.set_msglevel		= tc35815_set_msglevel,
 	.get_strings		= tc35815_get_strings,
-	.get_stats_count	= tc35815_get_stats_count,
+	.get_sset_count		= tc35815_get_sset_count,
 	.get_ethtool_stats	= tc35815_get_ethtool_stats,
 };
 
diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 1b860e0..d4ac6e9 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -8347,14 +8347,16 @@ static int tg3_set_tx_csum(struct net_device *dev, u32 data)
 	return 0;
 }
 
-static int tg3_get_stats_count (struct net_device *dev)
+static int tg3_get_sset_count (struct net_device *dev, int sset)
 {
-	return TG3_NUM_STATS;
-}
-
-static int tg3_get_test_count (struct net_device *dev)
-{
-	return TG3_NUM_TEST;
+	switch (sset) {
+	case ETH_SS_TEST:
+		return TG3_NUM_TEST;
+	case ETH_SS_STATS:
+		return TG3_NUM_STATS;
+	default:
+		return -EOPNOTSUPP;
+	}
 }
 
 static void tg3_get_strings (struct net_device *dev, u32 stringset, u8 *buf)
@@ -9281,14 +9283,13 @@ static const struct ethtool_ops tg3_ethtool_ops = {
 	.set_tx_csum		= tg3_set_tx_csum,
 	.set_sg			= ethtool_op_set_sg,
 	.set_tso		= tg3_set_tso,
-	.self_test_count	= tg3_get_test_count,
 	.self_test		= tg3_self_test,
 	.get_strings		= tg3_get_strings,
 	.phys_id		= tg3_phys_id,
-	.get_stats_count	= tg3_get_stats_count,
 	.get_ethtool_stats	= tg3_get_ethtool_stats,
 	.get_coalesce		= tg3_get_coalesce,
 	.set_coalesce		= tg3_set_coalesce,
+	.get_sset_count		= tg3_get_sset_count,
 };
 
 static void __devinit tg3_get_eeprom_size(struct tg3 *tp)
diff --git a/drivers/net/ucc_geth_ethtool.c b/drivers/net/ucc_geth_ethtool.c
index 73aa677..9a9622c 100644
--- a/drivers/net/ucc_geth_ethtool.c
+++ b/drivers/net/ucc_geth_ethtool.c
@@ -276,20 +276,26 @@ uec_set_ringparam(struct net_device *netdev,
 	return ret;
 }
 
-static int uec_get_stats_count(struct net_device *netdev)
+static int uec_get_sset_count(struct net_device *netdev, int sset)
 {
 	struct ucc_geth_private *ugeth = netdev_priv(netdev);
 	u32 stats_mode = ugeth->ug_info->statisticsMode;
 	int len = 0;
 
-	if (stats_mode & UCC_GETH_STATISTICS_GATHERING_MODE_HARDWARE)
-		len += UEC_HW_STATS_LEN;
-	if (stats_mode & UCC_GETH_STATISTICS_GATHERING_MODE_FIRMWARE_TX)
-		len += UEC_TX_FW_STATS_LEN;
-	if (stats_mode & UCC_GETH_STATISTICS_GATHERING_MODE_FIRMWARE_RX)
-		len += UEC_RX_FW_STATS_LEN;
+	switch (sset) {
+	case ETH_SS_STATS:
+		if (stats_mode & UCC_GETH_STATISTICS_GATHERING_MODE_HARDWARE)
+			len += UEC_HW_STATS_LEN;
+		if (stats_mode & UCC_GETH_STATISTICS_GATHERING_MODE_FIRMWARE_TX)
+			len += UEC_TX_FW_STATS_LEN;
+		if (stats_mode & UCC_GETH_STATISTICS_GATHERING_MODE_FIRMWARE_RX)
+			len += UEC_RX_FW_STATS_LEN;
+
+		return len;
 
-	return len;
+	default:
+		return -EOPNOTSUPP;
+	}
 }
 
 static void uec_get_strings(struct net_device *netdev, u32 stringset, u8 *buf)
@@ -353,8 +359,6 @@ uec_get_drvinfo(struct net_device *netdev,
 	strncpy(drvinfo->version, DRV_VERSION, 32);
 	strncpy(drvinfo->fw_version, "N/A", 32);
 	strncpy(drvinfo->bus_info, "QUICC ENGINE", 32);
-	drvinfo->n_stats = uec_get_stats_count(netdev);
-	drvinfo->testinfo_len = 0;
 	drvinfo->eedump_len = 0;
 	drvinfo->regdump_len = uec_get_regs_len(netdev);
 }
@@ -374,7 +378,7 @@ static const struct ethtool_ops uec_ethtool_ops = {
 	.get_pauseparam         = uec_get_pauseparam,
 	.set_pauseparam         = uec_set_pauseparam,
 	.set_sg                 = ethtool_op_set_sg,
-	.get_stats_count        = uec_get_stats_count,
+	.get_sset_count		= uec_get_sset_count,
 	.get_strings            = uec_get_strings,
 	.get_ethtool_stats      = uec_get_ethtool_stats,
 };
diff --git a/drivers/net/veth.c b/drivers/net/veth.c
index 9e6a746..9407130 100644
--- a/drivers/net/veth.c
+++ b/drivers/net/veth.c
@@ -79,9 +79,14 @@ static void veth_get_strings(struct net_device *dev, u32 stringset, u8 *buf)
 	}
 }
 
-static int veth_get_stats_count(struct net_device *dev)
+static int veth_get_sset_count(struct net_device *dev, int sset)
 {
-	return ARRAY_SIZE(ethtool_stats_keys);
+	switch (sset) {
+	case ETH_SS_STATS:
+		return ARRAY_SIZE(ethtool_stats_keys);
+	default:
+		return -EOPNOTSUPP;
+	}
 }
 
 static void veth_get_ethtool_stats(struct net_device *dev,
@@ -135,7 +140,7 @@ static struct ethtool_ops veth_ethtool_ops = {
 	.get_sg			= ethtool_op_get_sg,
 	.set_sg			= ethtool_op_set_sg,
 	.get_strings		= veth_get_strings,
-	.get_stats_count	= veth_get_stats_count,
+	.get_sset_count		= veth_get_sset_count,
 	.get_ethtool_stats	= veth_get_ethtool_stats,
 };
 
diff --git a/drivers/net/wireless/libertas/ethtool.c b/drivers/net/wireless/libertas/ethtool.c
index d793d84..3dae152 100644
--- a/drivers/net/wireless/libertas/ethtool.c
+++ b/drivers/net/wireless/libertas/ethtool.c
@@ -109,29 +109,8 @@ static void libertas_ethtool_get_stats(struct net_device * dev,
 				struct ethtool_stats * stats, u64 * data)
 {
 	wlan_private *priv = dev->priv;
-
-	lbs_deb_enter(LBS_DEB_ETHTOOL);
-
-	stats->cmd = ETHTOOL_GSTATS;
-	BUG_ON(stats->n_stats != MESH_STATS_NUM);
-
-        data[0] = priv->mstats.fwd_drop_rbt;
-        data[1] = priv->mstats.fwd_drop_ttl;
-        data[2] = priv->mstats.fwd_drop_noroute;
-        data[3] = priv->mstats.fwd_drop_nobuf;
-        data[4] = priv->mstats.fwd_unicast_cnt;
-        data[5] = priv->mstats.fwd_bcast_cnt;
-        data[6] = priv->mstats.drop_blind;
-        data[7] = priv->mstats.tx_failed_cnt;
-
-	lbs_deb_enter(LBS_DEB_ETHTOOL);
-}
-
-static int libertas_ethtool_get_stats_count(struct net_device * dev)
-{
-	int ret;
-	wlan_private *priv = dev->priv;
 	struct cmd_ds_mesh_access mesh_access;
+	int ret;
 
 	lbs_deb_enter(LBS_DEB_ETHTOOL);
 
@@ -140,25 +119,38 @@ static int libertas_ethtool_get_stats_count(struct net_device * dev)
 			CMD_MESH_ACCESS, CMD_ACT_MESH_GET_STATS,
 			CMD_OPTION_WAITFORRSP, 0, &mesh_access);
 
-	if (ret) {
-		ret = 0;
-		goto done;
-	}
-
-        priv->mstats.fwd_drop_rbt = le32_to_cpu(mesh_access.data[0]);
-        priv->mstats.fwd_drop_ttl = le32_to_cpu(mesh_access.data[1]);
-        priv->mstats.fwd_drop_noroute = le32_to_cpu(mesh_access.data[2]);
-        priv->mstats.fwd_drop_nobuf = le32_to_cpu(mesh_access.data[3]);
-        priv->mstats.fwd_unicast_cnt = le32_to_cpu(mesh_access.data[4]);
-        priv->mstats.fwd_bcast_cnt = le32_to_cpu(mesh_access.data[5]);
-        priv->mstats.drop_blind = le32_to_cpu(mesh_access.data[6]);
-        priv->mstats.tx_failed_cnt = le32_to_cpu(mesh_access.data[7]);
+	if (ret)
+		return;
+
+	priv->mstats.fwd_drop_rbt = le32_to_cpu(mesh_access.data[0]);
+	priv->mstats.fwd_drop_ttl = le32_to_cpu(mesh_access.data[1]);
+	priv->mstats.fwd_drop_noroute = le32_to_cpu(mesh_access.data[2]);
+	priv->mstats.fwd_drop_nobuf = le32_to_cpu(mesh_access.data[3]);
+	priv->mstats.fwd_unicast_cnt = le32_to_cpu(mesh_access.data[4]);
+	priv->mstats.fwd_bcast_cnt = le32_to_cpu(mesh_access.data[5]);
+	priv->mstats.drop_blind = le32_to_cpu(mesh_access.data[6]);
+	priv->mstats.tx_failed_cnt = le32_to_cpu(mesh_access.data[7]);
+
+	data[0] = priv->mstats.fwd_drop_rbt;
+	data[1] = priv->mstats.fwd_drop_ttl;
+	data[2] = priv->mstats.fwd_drop_noroute;
+	data[3] = priv->mstats.fwd_drop_nobuf;
+	data[4] = priv->mstats.fwd_unicast_cnt;
+	data[5] = priv->mstats.fwd_bcast_cnt;
+	data[6] = priv->mstats.drop_blind;
+	data[7] = priv->mstats.tx_failed_cnt;
 
-	ret = MESH_STATS_NUM;
+	lbs_deb_enter(LBS_DEB_ETHTOOL);
+}
 
-done:
-	lbs_deb_enter_args(LBS_DEB_ETHTOOL, "ret %d", ret);
-	return ret;
+static int libertas_ethtool_get_sset_count(struct net_device * dev, int sset)
+{
+	switch (sset) {
+	case ETH_SS_STATS:
+		return MESH_STATS_NUM;
+	default:
+		return -EOPNOTSUPP;
+	}
 }
 
 static void libertas_ethtool_get_strings (struct net_device * dev,
@@ -185,7 +177,7 @@ struct ethtool_ops libertas_ethtool_ops = {
 	.get_drvinfo = libertas_ethtool_get_drvinfo,
 	.get_eeprom =  libertas_ethtool_get_eeprom,
 	.get_eeprom_len = libertas_ethtool_get_eeprom_len,
-	.get_stats_count = libertas_ethtool_get_stats_count,
+	.get_sset_count = libertas_ethtool_get_sset_count,
 	.get_ethtool_stats = libertas_ethtool_get_stats,
 	.get_strings = libertas_ethtool_get_strings,
 };
