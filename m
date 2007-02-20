From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 2/3] chelsio: use C99 style initialization
Date: Tue, 20 Feb 2007 15:58:01 -0800
Message-ID: <20070220235905.224376488@linux-foundation.org>
References: <20070220235759.102686172@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:57070 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965261AbXBUAEG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Feb 2007 19:04:06 -0500
Content-Disposition: inline; filename=t1_board_c99.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Convert some initialized structures to C99 style.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

---
 drivers/net/chelsio/subr.c |  195 ++++++++++++++++++++++++++++++---------------
 1 file changed, 134 insertions(+), 61 deletions(-)

--- chelsio.orig/drivers/net/chelsio/subr.c
+++ chelsio/drivers/net/chelsio/subr.c
@@ -322,9 +322,9 @@ static int mi1_mdio_write(adapter_t *ada
 
 #if defined(CONFIG_CHELSIO_T1_1G) || defined(CONFIG_CHELSIO_T1_COUGAR)
 static struct mdio_ops mi1_mdio_ops = {
-	mi1_mdio_init,
-	mi1_mdio_read,
-	mi1_mdio_write
+	.init = mi1_mdio_init,
+	.read = mi1_mdio_read,
+	.write = mi1_mdio_write
 };
 #endif
 
@@ -378,9 +378,9 @@ static int mi1_mdio_ext_write(adapter_t 
 }
 
 static struct mdio_ops mi1_mdio_ext_ops = {
-	mi1_mdio_init,
-	mi1_mdio_ext_read,
-	mi1_mdio_ext_write
+	.init = mi1_mdio_init,
+	.read = mi1_mdio_ext_read,
+	.write = mi1_mdio_ext_write
 };
 
 enum {
@@ -392,63 +392,136 @@ enum {
 	CH_BRD_N204_4CU,
 };
 
-static struct board_info t1_board[] = {
-
-{ CHBT_BOARD_CHT110, 1/*ports#*/,
-  SUPPORTED_10000baseT_Full /*caps*/, CHBT_TERM_T1,
-  CHBT_MAC_PM3393, CHBT_PHY_MY3126,
-  125000000/*clk-core*/, 150000000/*clk-mc3*/, 125000000/*clk-mc4*/,
-  1/*espi-ports*/, 0/*clk-cspi*/, 44/*clk-elmer0*/, 1/*mdien*/,
-  1/*mdiinv*/, 1/*mdc*/, 1/*phybaseaddr*/, &t1_pm3393_ops,
-  &t1_my3126_ops, &mi1_mdio_ext_ops,
-  "Chelsio T110 1x10GBase-CX4 TOE" },
-
-{ CHBT_BOARD_N110, 1/*ports#*/,
-  SUPPORTED_10000baseT_Full | SUPPORTED_FIBRE /*caps*/, CHBT_TERM_T1,
-  CHBT_MAC_PM3393, CHBT_PHY_88X2010,
-  125000000/*clk-core*/, 0/*clk-mc3*/, 0/*clk-mc4*/,
-  1/*espi-ports*/, 0/*clk-cspi*/, 44/*clk-elmer0*/, 0/*mdien*/,
-  0/*mdiinv*/, 1/*mdc*/, 0/*phybaseaddr*/, &t1_pm3393_ops,
-  &t1_mv88x201x_ops, &mi1_mdio_ext_ops,
-  "Chelsio N110 1x10GBaseX NIC" },
-
-{ CHBT_BOARD_N210, 1/*ports#*/,
-  SUPPORTED_10000baseT_Full | SUPPORTED_FIBRE /*caps*/, CHBT_TERM_T2,
-  CHBT_MAC_PM3393, CHBT_PHY_88X2010,
-  125000000/*clk-core*/, 0/*clk-mc3*/, 0/*clk-mc4*/,
-  1/*espi-ports*/, 0/*clk-cspi*/, 44/*clk-elmer0*/, 0/*mdien*/,
-  0/*mdiinv*/, 1/*mdc*/, 0/*phybaseaddr*/, &t1_pm3393_ops,
-  &t1_mv88x201x_ops, &mi1_mdio_ext_ops,
-  "Chelsio N210 1x10GBaseX NIC" },
-
-{ CHBT_BOARD_CHT210, 1/*ports#*/,
-  SUPPORTED_10000baseT_Full /*caps*/, CHBT_TERM_T2,
-  CHBT_MAC_PM3393, CHBT_PHY_88X2010,
-  125000000/*clk-core*/, 133000000/*clk-mc3*/, 125000000/*clk-mc4*/,
-  1/*espi-ports*/, 0/*clk-cspi*/, 44/*clk-elmer0*/, 0/*mdien*/,
-  0/*mdiinv*/, 1/*mdc*/, 0/*phybaseaddr*/, &t1_pm3393_ops,
-  &t1_mv88x201x_ops, &mi1_mdio_ext_ops,
-  "Chelsio T210 1x10GBaseX TOE" },
-
-{ CHBT_BOARD_CHT210, 1/*ports#*/,
-  SUPPORTED_10000baseT_Full /*caps*/, CHBT_TERM_T2,
-  CHBT_MAC_PM3393, CHBT_PHY_MY3126,
-  125000000/*clk-core*/, 133000000/*clk-mc3*/, 125000000/*clk-mc4*/,
-  1/*espi-ports*/, 0/*clk-cspi*/, 44/*clk-elmer0*/, 1/*mdien*/,
-  1/*mdiinv*/, 1/*mdc*/, 1/*phybaseaddr*/, &t1_pm3393_ops,
-  &t1_my3126_ops, &mi1_mdio_ext_ops,
-  "Chelsio T210 1x10GBase-CX4 TOE" },
+static const struct board_info t1_board[] = {
+	{
+		.board		= CHBT_BOARD_CHT110,
+		.port_number	= 1,
+		.caps		= SUPPORTED_10000baseT_Full,
+		.chip_term	= CHBT_TERM_T1,
+		.chip_mac	= CHBT_MAC_PM3393,
+		.chip_phy	= CHBT_PHY_MY3126,
+		.clock_core	= 125000000,
+		.clock_mc3	= 150000000,
+		.clock_mc4	= 125000000,
+		.espi_nports	= 1,
+		.clock_elmer0	= 44,
+		.mdio_mdien	= 1,
+		.mdio_mdiinv	= 1,
+		.mdio_mdc	= 1,
+		.mdio_phybaseaddr = 1,
+		.gmac		= &t1_pm3393_ops,
+		.gphy		= &t1_my3126_ops,
+		.mdio_ops	= &mi1_mdio_ext_ops,
+		.desc		= "Chelsio T110 1x10GBase-CX4 TOE",
+	},
+
+	{
+		.board		= CHBT_BOARD_N110,
+		.port_number	= 1,
+		.caps		= SUPPORTED_10000baseT_Full | SUPPORTED_FIBRE,
+		.chip_term	= CHBT_TERM_T1,
+		.chip_mac	= CHBT_MAC_PM3393,
+		.chip_phy	= CHBT_PHY_88X2010,
+		.clock_core	= 125000000,
+		.espi_nports	= 1,
+		.clock_elmer0	= 44,
+		.mdio_mdien	= 0,
+		.mdio_mdiinv	= 0,
+		.mdio_mdc	= 1,
+		.mdio_phybaseaddr = 0,
+		.gmac		= &t1_pm3393_ops,
+		.gphy		= &t1_mv88x201x_ops,
+		.mdio_ops	= &mi1_mdio_ext_ops,
+		.desc		= "Chelsio N110 1x10GBaseX NIC",
+	},
+
+	{
+		.board		= CHBT_BOARD_N210,
+		.port_number	= 1,
+		.caps		= SUPPORTED_10000baseT_Full | SUPPORTED_FIBRE,
+		.chip_term	= CHBT_TERM_T2,
+		.chip_mac	= CHBT_MAC_PM3393,
+		.chip_phy	= CHBT_PHY_88X2010,
+		.clock_core	= 125000000,
+		.espi_nports	= 1,
+		.clock_elmer0	= 44,
+		.mdio_mdien	= 0,
+		.mdio_mdiinv	= 0,
+		.mdio_mdc	= 1,
+		.mdio_phybaseaddr = 0,
+		.gmac		= &t1_pm3393_ops,
+		.gphy		= &t1_mv88x201x_ops,
+		.mdio_ops	= &mi1_mdio_ext_ops,
+		.desc		= "Chelsio N210 1x10GBaseX NIC",
+	},
+
+	{
+		.board		= CHBT_BOARD_CHT210,
+		.port_number	= 1,
+		.caps		= SUPPORTED_10000baseT_Full,
+		.chip_term	= CHBT_TERM_T2,
+		.chip_mac	= CHBT_MAC_PM3393,
+		.chip_phy	= CHBT_PHY_88X2010,
+		.clock_core	= 125000000,
+		.clock_mc3	= 133000000,
+		.clock_mc4	= 125000000,
+		.espi_nports	= 1,
+		.clock_elmer0	= 44,
+		.mdio_mdien	= 0,
+		.mdio_mdiinv	= 0,
+		.mdio_mdc	= 1,
+		.mdio_phybaseaddr = 0,
+		.gmac		= &t1_pm3393_ops,
+		.gphy		= &t1_mv88x201x_ops,
+		.mdio_ops	= &mi1_mdio_ext_ops,
+		.desc		= "Chelsio T210 1x10GBaseX TOE",
+	},
+
+	{
+		.board		= CHBT_BOARD_CHT210,
+		.port_number	= 1,
+		.caps		= SUPPORTED_10000baseT_Full,
+		.chip_term	= CHBT_TERM_T2,
+		.chip_mac	= CHBT_MAC_PM3393,
+		.chip_phy	= CHBT_PHY_MY3126,
+		.clock_core	= 125000000,
+		.clock_mc3	= 133000000,
+		.clock_mc4	= 125000000,
+		.espi_nports	= 1,
+		.clock_elmer0	= 44,
+		.mdio_mdien	= 1,
+		.mdio_mdiinv	= 1,
+		.mdio_mdc	= 1,
+		.mdio_phybaseaddr = 1,
+		.gmac		= &t1_pm3393_ops,
+		.gphy		= &t1_my3126_ops,
+		.mdio_ops	= &mi1_mdio_ext_ops,
+		.desc		= "Chelsio T210 1x10GBase-CX4 TOE",
+	},
 
 #ifdef CONFIG_CHELSIO_T1_1G
-{ CHBT_BOARD_CHN204, 4/*ports#*/,
-  SUPPORTED_10baseT_Half | SUPPORTED_10baseT_Full | SUPPORTED_100baseT_Half |
-  SUPPORTED_100baseT_Full | SUPPORTED_1000baseT_Full | SUPPORTED_Autoneg |
-  SUPPORTED_PAUSE | SUPPORTED_TP /*caps*/, CHBT_TERM_T2, CHBT_MAC_VSC7321, CHBT_PHY_88E1111,
-  100000000/*clk-core*/, 0/*clk-mc3*/, 0/*clk-mc4*/,
-  4/*espi-ports*/, 0/*clk-cspi*/, 44/*clk-elmer0*/, 0/*mdien*/,
-  0/*mdiinv*/, 1/*mdc*/, 4/*phybaseaddr*/, &t1_vsc7326_ops,
-  &t1_mv88e1xxx_ops, &mi1_mdio_ops,
-  "Chelsio N204 4x100/1000BaseT NIC" },
+	{
+		.board		= CHBT_BOARD_CHN204,
+		.port_number	= 4,
+		.caps		= SUPPORTED_10baseT_Half | SUPPORTED_10baseT_Full
+				| SUPPORTED_100baseT_Half | SUPPORTED_100baseT_Full
+				| SUPPORTED_1000baseT_Full | SUPPORTED_Autoneg |
+				  SUPPORTED_PAUSE | SUPPORTED_TP,
+		.chip_term	= CHBT_TERM_T2,
+		.chip_mac	= CHBT_MAC_VSC7321,
+		.chip_phy	= CHBT_PHY_88E1111,
+		.clock_core	= 100000000,
+		.espi_nports	= 4,
+		.clock_elmer0	= 44,
+		.mdio_mdien	= 0,
+		.mdio_mdiinv	= 0,
+		.mdio_mdc	= 0,
+		.mdio_phybaseaddr = 4,
+		.gmac		= &t1_vsc7326_ops,
+		.gphy		= &t1_mv88e1xxx_ops,
+		.mdio_ops	= &mi1_mdio_ops,
+		.desc		= "Chelsio N204 4x100/1000BaseT NIC",
+	},
 #endif
 
 };

-- 

