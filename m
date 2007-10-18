From: Alejandro Martinez Ruiz <alex@flawedcode.org>
Subject: [PATCH 1/3] netdev: use ARRAY_SIZE() instead of sizeof(array) /
	ETH_GSTRING_LEN
Date: Thu, 18 Oct 2007 11:49:04 +0200
Message-ID: <20071018094904.GB23058@inspiron>
References: <20071018094706.GA23058@inspiron>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.169]:17478 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755637AbXJRJpw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Oct 2007 05:45:52 -0400
Received: by ug-out-1314.google.com with SMTP id z38so396722ugc
        for <netdev@vger.kernel.org>; Thu, 18 Oct 2007 02:45:50 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20071018094706.GA23058@inspiron>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


From: Alejandro Martinez Ruiz <alex@flawedcode.org>
Date: Thu, 18 Oct 2007 10:00:15 +0200
Subject: [PATCH] netdev: use ARRAY_SIZE() instead of sizeof(array) / ETH_GSTRING_LEN

Using ARRAY_SIZE() on arrays of the form array[][K] makes it unnecessary
to know the value of K when checking its size.

Signed-off-by: Alejandro Martinez Ruiz <alex@flawedcode.org>
---
 drivers/net/cassini.c                   |    2 +-
 drivers/net/e100.c                      |    4 ++--
 drivers/net/e1000/e1000_ethtool.c       |    2 +-
 drivers/net/e1000e/ethtool.c            |    2 +-
 drivers/net/myri10ge/myri10ge.c         |    2 +-
 drivers/net/netxen/netxen_nic_ethtool.c |    2 +-
 drivers/net/pcnet32.c                   |    2 +-
 drivers/net/s2io.c                      |    9 ++++-----
 drivers/net/tehuti.c                    |    8 +++-----
 9 files changed, 15 insertions(+), 18 deletions(-)

diff --git a/drivers/net/cassini.c b/drivers/net/cassini.c
index 7df31b5..30ecbf5 100644
--- a/drivers/net/cassini.c
+++ b/drivers/net/cassini.c
@@ -4419,7 +4419,7 @@ static struct {
 	{"tx_fifo_errors"},
 	{"tx_packets"}
 };
-#define CAS_NUM_STAT_KEYS (sizeof(ethtool_cassini_statnames)/ETH_GSTRING_LEN)
+#define CAS_NUM_STAT_KEYS ARRAY_SIZE(ethtool_cassini_statnames)
 
 static struct {
 	const int offsets;	/* neg. values for 2nd arg to cas_read_phy */
diff --git a/drivers/net/e100.c b/drivers/net/e100.c
index 64f35e2..bcb940b 100644
--- a/drivers/net/e100.c
+++ b/drivers/net/e100.c
@@ -2372,7 +2372,7 @@ static const char e100_gstrings_test[][ETH_GSTRING_LEN] = {
 	"Mac loopback     (offline)",
 	"Phy loopback     (offline)",
 };
-#define E100_TEST_LEN	sizeof(e100_gstrings_test) / ETH_GSTRING_LEN
+#define E100_TEST_LEN	ARRAY_SIZE(e100_gstrings_test)
 
 static void e100_diag_test(struct net_device *netdev,
 	struct ethtool_test *test, u64 *data)
@@ -2434,7 +2434,7 @@ static const char e100_gstrings_stats[][ETH_GSTRING_LEN] = {
 	"rx_flow_control_unsupported", "tx_tco_packets", "rx_tco_packets",
 };
 #define E100_NET_STATS_LEN	21
-#define E100_STATS_LEN	sizeof(e100_gstrings_stats) / ETH_GSTRING_LEN
+#define E100_STATS_LEN	ARRAY_SIZE(e100_gstrings_stats)
 
 static int e100_get_sset_count(struct net_device *netdev, int sset)
 {
diff --git a/drivers/net/e1000/e1000_ethtool.c b/drivers/net/e1000/e1000_ethtool.c
index 6c9a643..6b97361 100644
--- a/drivers/net/e1000/e1000_ethtool.c
+++ b/drivers/net/e1000/e1000_ethtool.c
@@ -113,7 +113,7 @@ static const char e1000_gstrings_test[][ETH_GSTRING_LEN] = {
 	"Interrupt test (offline)", "Loopback test  (offline)",
 	"Link test   (on/offline)"
 };
-#define E1000_TEST_LEN sizeof(e1000_gstrings_test) / ETH_GSTRING_LEN
+#define E1000_TEST_LEN	ARRAY_SIZE(e1000_gstrings_test)
 
 static int
 e1000_get_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
diff --git a/drivers/net/e1000e/ethtool.c b/drivers/net/e1000e/ethtool.c
index 0666e62..61c84c0 100644
--- a/drivers/net/e1000e/ethtool.c
+++ b/drivers/net/e1000e/ethtool.c
@@ -103,7 +103,7 @@ static const char e1000_gstrings_test[][ETH_GSTRING_LEN] = {
 	"Interrupt test (offline)", "Loopback test  (offline)",
 	"Link test   (on/offline)"
 };
-#define E1000_TEST_LEN sizeof(e1000_gstrings_test) / ETH_GSTRING_LEN
+#define E1000_TEST_LEN	ARRAY_SIZE(e1000_gstrings_test)
 
 static int e1000_get_settings(struct net_device *netdev,
 			      struct ethtool_cmd *ecmd)
diff --git a/drivers/net/myri10ge/myri10ge.c b/drivers/net/myri10ge/myri10ge.c
index 64c8151..31b33c9 100644
--- a/drivers/net/myri10ge/myri10ge.c
+++ b/drivers/net/myri10ge/myri10ge.c
@@ -1431,7 +1431,7 @@ static const char myri10ge_gstrings_stats[][ETH_GSTRING_LEN] = {
 };
 
 #define MYRI10GE_NET_STATS_LEN      21
-#define MYRI10GE_STATS_LEN  sizeof(myri10ge_gstrings_stats) / ETH_GSTRING_LEN
+#define MYRI10GE_STATS_LEN	ARRAY_SIZE(myri10ge_gstrings_stats)
 
 static void
 myri10ge_get_strings(struct net_device *netdev, u32 stringset, u8 * data)
diff --git a/drivers/net/netxen/netxen_nic_ethtool.c b/drivers/net/netxen/netxen_nic_ethtool.c
index cfb847b..cdec4f8 100644
--- a/drivers/net/netxen/netxen_nic_ethtool.c
+++ b/drivers/net/netxen/netxen_nic_ethtool.c
@@ -86,7 +86,7 @@ static const char netxen_nic_gstrings_test[][ETH_GSTRING_LEN] = {
 	"Link_Test_on_offline"
 };
 
-#define NETXEN_NIC_TEST_LEN sizeof(netxen_nic_gstrings_test) / ETH_GSTRING_LEN
+#define NETXEN_NIC_TEST_LEN	ARRAY_SIZE(netxen_nic_gstrings_test)
 
 #define NETXEN_NIC_REGS_COUNT 42
 #define NETXEN_NIC_REGS_LEN (NETXEN_NIC_REGS_COUNT * sizeof(__le32))
diff --git a/drivers/net/pcnet32.c b/drivers/net/pcnet32.c
index 5f994b5..642adac 100644
--- a/drivers/net/pcnet32.c
+++ b/drivers/net/pcnet32.c
@@ -137,7 +137,7 @@ static const char pcnet32_gstrings_test[][ETH_GSTRING_LEN] = {
 	"Loopback test  (offline)"
 };
 
-#define PCNET32_TEST_LEN (sizeof(pcnet32_gstrings_test) / ETH_GSTRING_LEN)
+#define PCNET32_TEST_LEN	ARRAY_SIZE(pcnet32_gstrings_test)
 
 #define PCNET32_NUM_REGS 136
 
diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index 22e4054..7502f34 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -335,10 +335,9 @@ static char ethtool_driver_stats_keys[][ETH_GSTRING_LEN] = {
 	{"mc_err_cnt"}
 };
 
-#define S2IO_XENA_STAT_LEN sizeof(ethtool_xena_stats_keys)/ ETH_GSTRING_LEN
-#define S2IO_ENHANCED_STAT_LEN sizeof(ethtool_enhanced_stats_keys)/ \
-					ETH_GSTRING_LEN
-#define S2IO_DRIVER_STAT_LEN sizeof(ethtool_driver_stats_keys)/ ETH_GSTRING_LEN
+#define S2IO_XENA_STAT_LEN	ARRAY_SIZE(ethtool_xena_stats_keys)
+#define S2IO_ENHANCED_STAT_LEN	ARRAY_SIZE(ethtool_enhanced_stats_keys)
+#define S2IO_DRIVER_STAT_LEN	ARRAY_SIZE(ethtool_driver_stats_keys)
 
 #define XFRAME_I_STAT_LEN (S2IO_XENA_STAT_LEN + S2IO_DRIVER_STAT_LEN )
 #define XFRAME_II_STAT_LEN (XFRAME_I_STAT_LEN + S2IO_ENHANCED_STAT_LEN )
@@ -346,7 +345,7 @@ static char ethtool_driver_stats_keys[][ETH_GSTRING_LEN] = {
 #define XFRAME_I_STAT_STRINGS_LEN ( XFRAME_I_STAT_LEN * ETH_GSTRING_LEN )
 #define XFRAME_II_STAT_STRINGS_LEN ( XFRAME_II_STAT_LEN * ETH_GSTRING_LEN )
 
-#define S2IO_TEST_LEN	sizeof(s2io_gstrings) / ETH_GSTRING_LEN
+#define S2IO_TEST_LEN	ARRAY_SIZE(s2io_gstrings)
 #define S2IO_STRINGS_LEN	S2IO_TEST_LEN * ETH_GSTRING_LEN
 
 #define S2IO_TIMER_CONF(timer, handle, arg, exp)		\
diff --git a/drivers/net/tehuti.c b/drivers/net/tehuti.c
index 4e1b84e..7334d09 100644
--- a/drivers/net/tehuti.c
+++ b/drivers/net/tehuti.c
@@ -2174,8 +2174,7 @@ bdx_get_drvinfo(struct net_device *netdev, struct ethtool_drvinfo *drvinfo)
 	strncat(drvinfo->bus_info, pci_name(priv->pdev),
 		sizeof(drvinfo->bus_info));
 
-	drvinfo->n_stats = ((priv->stats_flag) ?
-			    (sizeof(bdx_stat_names) / ETH_GSTRING_LEN) : 0);
+	drvinfo->n_stats = ((priv->stats_flag) ? ARRAY_SIZE(bdx_stat_names) : 0);
 	drvinfo->testinfo_len = 0;
 	drvinfo->regdump_len = 0;
 	drvinfo->eedump_len = 0;
@@ -2375,10 +2374,9 @@ static void bdx_get_strings(struct net_device *netdev, u32 stringset, u8 *data)
 static int bdx_get_stats_count(struct net_device *netdev)
 {
 	struct bdx_priv *priv = netdev->priv;
-	BDX_ASSERT(sizeof(bdx_stat_names) / ETH_GSTRING_LEN
+	BDX_ASSERT(ARRAY_SIZE(bdx_stat_names)
 		   != sizeof(struct bdx_stats) / sizeof(u64));
-	return ((priv->stats_flag) ? (sizeof(bdx_stat_names) / ETH_GSTRING_LEN)
-		: 0);
+	return ((priv->stats_flag) ? ARRAY_SIZE(bdx_stat_names)	: 0);
 }
 
 /*
-- 
1.5.3.4


