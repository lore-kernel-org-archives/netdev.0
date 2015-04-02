From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH 10/12] net: dsa: Consolidate getting the statistics
Date: Thu,  2 Apr 2015 03:21:57 +0200
Message-ID: <1427937719-11630-11-git-send-email-andrew@lunn.ch>
References: <1427937719-11630-1-git-send-email-andrew@lunn.ch>
Cc: netdev@vger.kernel.org, Andrew Lunn <andrew@lunn.ch>
To: davem@davemloft.net, linux@roeck-us.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:35735 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752559AbbDBB0K (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Apr 2015 21:26:10 -0400
In-Reply-To: <1427937719-11630-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reading the statistics from the hardware is the same for all
chips. What differs is the number of available statistics. Have just
one copy of the code in the shared mv88e6xxx.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
Tested-by: Guenter Roeck <linux@roeck-us.net>
Reviewed-by: Guenter Roeck <linux@roeck-us.net>
---
 drivers/net/dsa/mv88e6123_61_65.c | 62 ++----------------------
 drivers/net/dsa/mv88e6131.c       | 59 ++---------------------
 drivers/net/dsa/mv88e6171.c       | 59 ++---------------------
 drivers/net/dsa/mv88e6352.c       | 61 ++----------------------
 drivers/net/dsa/mv88e6xxx.c       | 99 ++++++++++++++++++++++++++++++++++++---
 drivers/net/dsa/mv88e6xxx.h       | 11 ++---
 6 files changed, 110 insertions(+), 241 deletions(-)

diff --git a/drivers/net/dsa/mv88e6123_61_65.c b/drivers/net/dsa/mv88e6123_61_65.c
index 5f536722f7c7..81cc24448164 100644
--- a/drivers/net/dsa/mv88e6123_61_65.c
+++ b/drivers/net/dsa/mv88e6123_61_65.c
@@ -277,62 +277,6 @@ static int mv88e6123_61_65_setup(struct dsa_switch *ds)
 	return 0;
 }
 
-static struct mv88e6xxx_hw_stat mv88e6123_61_65_hw_stats[] = {
-	{ "in_good_octets", 8, 0x00, },
-	{ "in_bad_octets", 4, 0x02, },
-	{ "in_unicast", 4, 0x04, },
-	{ "in_broadcasts", 4, 0x06, },
-	{ "in_multicasts", 4, 0x07, },
-	{ "in_pause", 4, 0x16, },
-	{ "in_undersize", 4, 0x18, },
-	{ "in_fragments", 4, 0x19, },
-	{ "in_oversize", 4, 0x1a, },
-	{ "in_jabber", 4, 0x1b, },
-	{ "in_rx_error", 4, 0x1c, },
-	{ "in_fcs_error", 4, 0x1d, },
-	{ "out_octets", 8, 0x0e, },
-	{ "out_unicast", 4, 0x10, },
-	{ "out_broadcasts", 4, 0x13, },
-	{ "out_multicasts", 4, 0x12, },
-	{ "out_pause", 4, 0x15, },
-	{ "excessive", 4, 0x11, },
-	{ "collisions", 4, 0x1e, },
-	{ "deferred", 4, 0x05, },
-	{ "single", 4, 0x14, },
-	{ "multiple", 4, 0x17, },
-	{ "out_fcs_error", 4, 0x03, },
-	{ "late", 4, 0x1f, },
-	{ "hist_64bytes", 4, 0x08, },
-	{ "hist_65_127bytes", 4, 0x09, },
-	{ "hist_128_255bytes", 4, 0x0a, },
-	{ "hist_256_511bytes", 4, 0x0b, },
-	{ "hist_512_1023bytes", 4, 0x0c, },
-	{ "hist_1024_max_bytes", 4, 0x0d, },
-	{ "sw_in_discards", 4, 0x110, },
-	{ "sw_in_filtered", 2, 0x112, },
-	{ "sw_out_filtered", 2, 0x113, },
-};
-
-static void
-mv88e6123_61_65_get_strings(struct dsa_switch *ds, int port, uint8_t *data)
-{
-	mv88e6xxx_get_strings(ds, ARRAY_SIZE(mv88e6123_61_65_hw_stats),
-			      mv88e6123_61_65_hw_stats, port, data);
-}
-
-static void
-mv88e6123_61_65_get_ethtool_stats(struct dsa_switch *ds,
-				  int port, uint64_t *data)
-{
-	mv88e6xxx_get_ethtool_stats(ds, ARRAY_SIZE(mv88e6123_61_65_hw_stats),
-				    mv88e6123_61_65_hw_stats, port, data);
-}
-
-static int mv88e6123_61_65_get_sset_count(struct dsa_switch *ds)
-{
-	return ARRAY_SIZE(mv88e6123_61_65_hw_stats);
-}
-
 struct dsa_switch_driver mv88e6123_61_65_switch_driver = {
 	.tag_protocol		= DSA_TAG_PROTO_EDSA,
 	.priv_size		= sizeof(struct mv88e6xxx_priv_state),
@@ -342,9 +286,9 @@ struct dsa_switch_driver mv88e6123_61_65_switch_driver = {
 	.phy_read		= mv88e6xxx_phy_read,
 	.phy_write		= mv88e6xxx_phy_write,
 	.poll_link		= mv88e6xxx_poll_link,
-	.get_strings		= mv88e6123_61_65_get_strings,
-	.get_ethtool_stats	= mv88e6123_61_65_get_ethtool_stats,
-	.get_sset_count		= mv88e6123_61_65_get_sset_count,
+	.get_strings		= mv88e6xxx_get_strings,
+	.get_ethtool_stats	= mv88e6xxx_get_ethtool_stats,
+	.get_sset_count		= mv88e6xxx_get_sset_count,
 #ifdef CONFIG_NET_DSA_HWMON
 	.get_temp		= mv88e6xxx_get_temp,
 #endif
diff --git a/drivers/net/dsa/mv88e6131.c b/drivers/net/dsa/mv88e6131.c
index 534a8f0b1c28..5bec7a60b476 100644
--- a/drivers/net/dsa/mv88e6131.c
+++ b/drivers/net/dsa/mv88e6131.c
@@ -299,59 +299,6 @@ mv88e6131_phy_write(struct dsa_switch *ds,
 	return mv88e6xxx_phy_write_ppu(ds, addr, regnum, val);
 }
 
-static struct mv88e6xxx_hw_stat mv88e6131_hw_stats[] = {
-	{ "in_good_octets", 8, 0x00, },
-	{ "in_bad_octets", 4, 0x02, },
-	{ "in_unicast", 4, 0x04, },
-	{ "in_broadcasts", 4, 0x06, },
-	{ "in_multicasts", 4, 0x07, },
-	{ "in_pause", 4, 0x16, },
-	{ "in_undersize", 4, 0x18, },
-	{ "in_fragments", 4, 0x19, },
-	{ "in_oversize", 4, 0x1a, },
-	{ "in_jabber", 4, 0x1b, },
-	{ "in_rx_error", 4, 0x1c, },
-	{ "in_fcs_error", 4, 0x1d, },
-	{ "out_octets", 8, 0x0e, },
-	{ "out_unicast", 4, 0x10, },
-	{ "out_broadcasts", 4, 0x13, },
-	{ "out_multicasts", 4, 0x12, },
-	{ "out_pause", 4, 0x15, },
-	{ "excessive", 4, 0x11, },
-	{ "collisions", 4, 0x1e, },
-	{ "deferred", 4, 0x05, },
-	{ "single", 4, 0x14, },
-	{ "multiple", 4, 0x17, },
-	{ "out_fcs_error", 4, 0x03, },
-	{ "late", 4, 0x1f, },
-	{ "hist_64bytes", 4, 0x08, },
-	{ "hist_65_127bytes", 4, 0x09, },
-	{ "hist_128_255bytes", 4, 0x0a, },
-	{ "hist_256_511bytes", 4, 0x0b, },
-	{ "hist_512_1023bytes", 4, 0x0c, },
-	{ "hist_1024_max_bytes", 4, 0x0d, },
-};
-
-static void
-mv88e6131_get_strings(struct dsa_switch *ds, int port, uint8_t *data)
-{
-	mv88e6xxx_get_strings(ds, ARRAY_SIZE(mv88e6131_hw_stats),
-			      mv88e6131_hw_stats, port, data);
-}
-
-static void
-mv88e6131_get_ethtool_stats(struct dsa_switch *ds,
-				  int port, uint64_t *data)
-{
-	mv88e6xxx_get_ethtool_stats(ds, ARRAY_SIZE(mv88e6131_hw_stats),
-				    mv88e6131_hw_stats, port, data);
-}
-
-static int mv88e6131_get_sset_count(struct dsa_switch *ds)
-{
-	return ARRAY_SIZE(mv88e6131_hw_stats);
-}
-
 struct dsa_switch_driver mv88e6131_switch_driver = {
 	.tag_protocol		= DSA_TAG_PROTO_DSA,
 	.priv_size		= sizeof(struct mv88e6xxx_priv_state),
@@ -361,9 +308,9 @@ struct dsa_switch_driver mv88e6131_switch_driver = {
 	.phy_read		= mv88e6131_phy_read,
 	.phy_write		= mv88e6131_phy_write,
 	.poll_link		= mv88e6xxx_poll_link,
-	.get_strings		= mv88e6131_get_strings,
-	.get_ethtool_stats	= mv88e6131_get_ethtool_stats,
-	.get_sset_count		= mv88e6131_get_sset_count,
+	.get_strings		= mv88e6xxx_get_strings,
+	.get_ethtool_stats	= mv88e6xxx_get_ethtool_stats,
+	.get_sset_count		= mv88e6xxx_get_sset_count,
 };
 
 MODULE_ALIAS("platform:mv88e6085");
diff --git a/drivers/net/dsa/mv88e6171.c b/drivers/net/dsa/mv88e6171.c
index 4d6038991a59..7314e7d71a67 100644
--- a/drivers/net/dsa/mv88e6171.c
+++ b/drivers/net/dsa/mv88e6171.c
@@ -258,59 +258,6 @@ static int mv88e6171_setup(struct dsa_switch *ds)
 	return 0;
 }
 
-static struct mv88e6xxx_hw_stat mv88e6171_hw_stats[] = {
-	{ "in_good_octets", 8, 0x00, },
-	{ "in_bad_octets", 4, 0x02, },
-	{ "in_unicast", 4, 0x04, },
-	{ "in_broadcasts", 4, 0x06, },
-	{ "in_multicasts", 4, 0x07, },
-	{ "in_pause", 4, 0x16, },
-	{ "in_undersize", 4, 0x18, },
-	{ "in_fragments", 4, 0x19, },
-	{ "in_oversize", 4, 0x1a, },
-	{ "in_jabber", 4, 0x1b, },
-	{ "in_rx_error", 4, 0x1c, },
-	{ "in_fcs_error", 4, 0x1d, },
-	{ "out_octets", 8, 0x0e, },
-	{ "out_unicast", 4, 0x10, },
-	{ "out_broadcasts", 4, 0x13, },
-	{ "out_multicasts", 4, 0x12, },
-	{ "out_pause", 4, 0x15, },
-	{ "excessive", 4, 0x11, },
-	{ "collisions", 4, 0x1e, },
-	{ "deferred", 4, 0x05, },
-	{ "single", 4, 0x14, },
-	{ "multiple", 4, 0x17, },
-	{ "out_fcs_error", 4, 0x03, },
-	{ "late", 4, 0x1f, },
-	{ "hist_64bytes", 4, 0x08, },
-	{ "hist_65_127bytes", 4, 0x09, },
-	{ "hist_128_255bytes", 4, 0x0a, },
-	{ "hist_256_511bytes", 4, 0x0b, },
-	{ "hist_512_1023bytes", 4, 0x0c, },
-	{ "hist_1024_max_bytes", 4, 0x0d, },
-};
-
-static void
-mv88e6171_get_strings(struct dsa_switch *ds, int port, uint8_t *data)
-{
-	mv88e6xxx_get_strings(ds, ARRAY_SIZE(mv88e6171_hw_stats),
-			      mv88e6171_hw_stats, port, data);
-}
-
-static void
-mv88e6171_get_ethtool_stats(struct dsa_switch *ds,
-			    int port, uint64_t *data)
-{
-	mv88e6xxx_get_ethtool_stats(ds, ARRAY_SIZE(mv88e6171_hw_stats),
-				    mv88e6171_hw_stats, port, data);
-}
-
-static int mv88e6171_get_sset_count(struct dsa_switch *ds)
-{
-	return ARRAY_SIZE(mv88e6171_hw_stats);
-}
-
 static int mv88e6171_get_eee(struct dsa_switch *ds, int port,
 			     struct ethtool_eee *e)
 {
@@ -342,9 +289,9 @@ struct dsa_switch_driver mv88e6171_switch_driver = {
 	.phy_read		= mv88e6xxx_phy_read_indirect,
 	.phy_write		= mv88e6xxx_phy_write_indirect,
 	.poll_link		= mv88e6xxx_poll_link,
-	.get_strings		= mv88e6171_get_strings,
-	.get_ethtool_stats	= mv88e6171_get_ethtool_stats,
-	.get_sset_count		= mv88e6171_get_sset_count,
+	.get_strings		= mv88e6xxx_get_strings,
+	.get_ethtool_stats	= mv88e6xxx_get_ethtool_stats,
+	.get_sset_count		= mv88e6xxx_get_sset_count,
 	.set_eee		= mv88e6171_set_eee,
 	.get_eee		= mv88e6171_get_eee,
 #ifdef CONFIG_NET_DSA_HWMON
diff --git a/drivers/net/dsa/mv88e6352.c b/drivers/net/dsa/mv88e6352.c
index 3806ff1aaa9c..a1be6e3c0351 100644
--- a/drivers/net/dsa/mv88e6352.c
+++ b/drivers/net/dsa/mv88e6352.c
@@ -321,42 +321,6 @@ static int mv88e6352_setup(struct dsa_switch *ds)
 	return 0;
 }
 
-static struct mv88e6xxx_hw_stat mv88e6352_hw_stats[] = {
-	{ "in_good_octets", 8, 0x00, },
-	{ "in_bad_octets", 4, 0x02, },
-	{ "in_unicast", 4, 0x04, },
-	{ "in_broadcasts", 4, 0x06, },
-	{ "in_multicasts", 4, 0x07, },
-	{ "in_pause", 4, 0x16, },
-	{ "in_undersize", 4, 0x18, },
-	{ "in_fragments", 4, 0x19, },
-	{ "in_oversize", 4, 0x1a, },
-	{ "in_jabber", 4, 0x1b, },
-	{ "in_rx_error", 4, 0x1c, },
-	{ "in_fcs_error", 4, 0x1d, },
-	{ "out_octets", 8, 0x0e, },
-	{ "out_unicast", 4, 0x10, },
-	{ "out_broadcasts", 4, 0x13, },
-	{ "out_multicasts", 4, 0x12, },
-	{ "out_pause", 4, 0x15, },
-	{ "excessive", 4, 0x11, },
-	{ "collisions", 4, 0x1e, },
-	{ "deferred", 4, 0x05, },
-	{ "single", 4, 0x14, },
-	{ "multiple", 4, 0x17, },
-	{ "out_fcs_error", 4, 0x03, },
-	{ "late", 4, 0x1f, },
-	{ "hist_64bytes", 4, 0x08, },
-	{ "hist_65_127bytes", 4, 0x09, },
-	{ "hist_128_255bytes", 4, 0x0a, },
-	{ "hist_256_511bytes", 4, 0x0b, },
-	{ "hist_512_1023bytes", 4, 0x0c, },
-	{ "hist_1024_max_bytes", 4, 0x0d, },
-	{ "sw_in_discards", 4, 0x110, },
-	{ "sw_in_filtered", 2, 0x112, },
-	{ "sw_out_filtered", 2, 0x113, },
-};
-
 static int mv88e6352_read_eeprom_word(struct dsa_switch *ds, int addr)
 {
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
@@ -555,25 +519,6 @@ static int mv88e6352_set_eeprom(struct dsa_switch *ds,
 	return 0;
 }
 
-static void
-mv88e6352_get_strings(struct dsa_switch *ds, int port, uint8_t *data)
-{
-	mv88e6xxx_get_strings(ds, ARRAY_SIZE(mv88e6352_hw_stats),
-			      mv88e6352_hw_stats, port, data);
-}
-
-static void
-mv88e6352_get_ethtool_stats(struct dsa_switch *ds, int port, uint64_t *data)
-{
-	mv88e6xxx_get_ethtool_stats(ds, ARRAY_SIZE(mv88e6352_hw_stats),
-				    mv88e6352_hw_stats, port, data);
-}
-
-static int mv88e6352_get_sset_count(struct dsa_switch *ds)
-{
-	return ARRAY_SIZE(mv88e6352_hw_stats);
-}
-
 struct dsa_switch_driver mv88e6352_switch_driver = {
 	.tag_protocol		= DSA_TAG_PROTO_EDSA,
 	.priv_size		= sizeof(struct mv88e6xxx_priv_state),
@@ -583,9 +528,9 @@ struct dsa_switch_driver mv88e6352_switch_driver = {
 	.phy_read		= mv88e6xxx_phy_read_indirect,
 	.phy_write		= mv88e6xxx_phy_write_indirect,
 	.poll_link		= mv88e6xxx_poll_link,
-	.get_strings		= mv88e6352_get_strings,
-	.get_ethtool_stats	= mv88e6352_get_ethtool_stats,
-	.get_sset_count		= mv88e6352_get_sset_count,
+	.get_strings		= mv88e6xxx_get_strings,
+	.get_ethtool_stats	= mv88e6xxx_get_ethtool_stats,
+	.get_sset_count		= mv88e6xxx_get_sset_count,
 	.set_eee		= mv88e6xxx_set_eee,
 	.get_eee		= mv88e6xxx_get_eee,
 #ifdef CONFIG_NET_DSA_HWMON
diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index d9a78c71a4bb..b360fe5346d3 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -484,9 +484,62 @@ static void mv88e6xxx_stats_read(struct dsa_switch *ds, int stat, u32 *val)
 	*val = _val | ret;
 }
 
-void mv88e6xxx_get_strings(struct dsa_switch *ds,
-			   int nr_stats, struct mv88e6xxx_hw_stat *stats,
-			   int port, uint8_t *data)
+static struct mv88e6xxx_hw_stat mv88e6xxx_hw_stats[] = {
+	{ "in_good_octets", 8, 0x00, },
+	{ "in_bad_octets", 4, 0x02, },
+	{ "in_unicast", 4, 0x04, },
+	{ "in_broadcasts", 4, 0x06, },
+	{ "in_multicasts", 4, 0x07, },
+	{ "in_pause", 4, 0x16, },
+	{ "in_undersize", 4, 0x18, },
+	{ "in_fragments", 4, 0x19, },
+	{ "in_oversize", 4, 0x1a, },
+	{ "in_jabber", 4, 0x1b, },
+	{ "in_rx_error", 4, 0x1c, },
+	{ "in_fcs_error", 4, 0x1d, },
+	{ "out_octets", 8, 0x0e, },
+	{ "out_unicast", 4, 0x10, },
+	{ "out_broadcasts", 4, 0x13, },
+	{ "out_multicasts", 4, 0x12, },
+	{ "out_pause", 4, 0x15, },
+	{ "excessive", 4, 0x11, },
+	{ "collisions", 4, 0x1e, },
+	{ "deferred", 4, 0x05, },
+	{ "single", 4, 0x14, },
+	{ "multiple", 4, 0x17, },
+	{ "out_fcs_error", 4, 0x03, },
+	{ "late", 4, 0x1f, },
+	{ "hist_64bytes", 4, 0x08, },
+	{ "hist_65_127bytes", 4, 0x09, },
+	{ "hist_128_255bytes", 4, 0x0a, },
+	{ "hist_256_511bytes", 4, 0x0b, },
+	{ "hist_512_1023bytes", 4, 0x0c, },
+	{ "hist_1024_max_bytes", 4, 0x0d, },
+	/* Not all devices have the following counters */
+	{ "sw_in_discards", 4, 0x110, },
+	{ "sw_in_filtered", 2, 0x112, },
+	{ "sw_out_filtered", 2, 0x113, },
+
+};
+
+static bool have_sw_in_discards(struct dsa_switch *ds)
+{
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+
+	switch (ps->id) {
+	case ID_6095: case ID_6161: case ID_6165:
+	case ID_6171: case ID_6172: case ID_6176:
+	case ID_6182: case ID_6185: case ID_6352:
+		return true;
+	default:
+		return false;
+	}
+}
+
+static void _mv88e6xxx_get_strings(struct dsa_switch *ds,
+				   int nr_stats,
+				   struct mv88e6xxx_hw_stat *stats,
+				   int port, uint8_t *data)
 {
 	int i;
 
@@ -496,9 +549,10 @@ void mv88e6xxx_get_strings(struct dsa_switch *ds,
 	}
 }
 
-void mv88e6xxx_get_ethtool_stats(struct dsa_switch *ds,
-				 int nr_stats, struct mv88e6xxx_hw_stat *stats,
-				 int port, uint64_t *data)
+static void _mv88e6xxx_get_ethtool_stats(struct dsa_switch *ds,
+					 int nr_stats,
+					 struct mv88e6xxx_hw_stat *stats,
+					 int port, uint64_t *data)
 {
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 	int ret;
@@ -546,6 +600,39 @@ error:
 	mutex_unlock(&ps->stats_mutex);
 }
 
+/* All the statistics in the table */
+void
+mv88e6xxx_get_strings(struct dsa_switch *ds, int port, uint8_t *data)
+{
+	if (have_sw_in_discards(ds))
+		_mv88e6xxx_get_strings(ds, ARRAY_SIZE(mv88e6xxx_hw_stats),
+				       mv88e6xxx_hw_stats, port, data);
+	else
+		_mv88e6xxx_get_strings(ds, ARRAY_SIZE(mv88e6xxx_hw_stats) - 3,
+				       mv88e6xxx_hw_stats, port, data);
+}
+
+int mv88e6xxx_get_sset_count(struct dsa_switch *ds)
+{
+	if (have_sw_in_discards(ds))
+		return ARRAY_SIZE(mv88e6xxx_hw_stats);
+	return ARRAY_SIZE(mv88e6xxx_hw_stats) - 3;
+}
+
+void
+mv88e6xxx_get_ethtool_stats(struct dsa_switch *ds,
+			    int port, uint64_t *data)
+{
+	if (have_sw_in_discards(ds))
+		_mv88e6xxx_get_ethtool_stats(
+			ds, ARRAY_SIZE(mv88e6xxx_hw_stats),
+			mv88e6xxx_hw_stats, port, data);
+	else
+		_mv88e6xxx_get_ethtool_stats(
+			ds, ARRAY_SIZE(mv88e6xxx_hw_stats) - 3,
+			mv88e6xxx_hw_stats, port, data);
+}
+
 int mv88e6xxx_get_regs_len(struct dsa_switch *ds, int port)
 {
 	return 32 * sizeof(u16);
diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
index 44b0ec79cc6b..fbbedc07754f 100644
--- a/drivers/net/dsa/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx.h
@@ -150,12 +150,11 @@ int mv88e6xxx_phy_read_ppu(struct dsa_switch *ds, int addr, int regnum);
 int mv88e6xxx_phy_write_ppu(struct dsa_switch *ds, int addr,
 			    int regnum, u16 val);
 void mv88e6xxx_poll_link(struct dsa_switch *ds);
-void mv88e6xxx_get_strings(struct dsa_switch *ds,
-			   int nr_stats, struct mv88e6xxx_hw_stat *stats,
-			   int port, uint8_t *data);
-void mv88e6xxx_get_ethtool_stats(struct dsa_switch *ds,
-				 int nr_stats, struct mv88e6xxx_hw_stat *stats,
-				 int port, uint64_t *data);
+void mv88e6xxx_get_strings(struct dsa_switch *ds, int port, uint8_t *data);
+void mv88e6xxx_get_ethtool_stats(struct dsa_switch *ds, int port,
+				 uint64_t *data);
+int mv88e6xxx_get_sset_count(struct dsa_switch *ds);
+int mv88e6xxx_get_sset_count_basic(struct dsa_switch *ds);
 int mv88e6xxx_get_regs_len(struct dsa_switch *ds, int port);
 void mv88e6xxx_get_regs(struct dsa_switch *ds, int port,
 			struct ethtool_regs *regs, void *_p);
-- 
2.1.4
