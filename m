From: "Dale Farnsworth" <dale@farnsworth.org>
Subject: mv643xx(4/20): Update the Artesyn katana mv643xx ethernet platform data
Date: Mon, 28 Mar 2005 16:44:39 -0700
Message-ID: <20050328234439.GD29098@xyzzy>
References: <20050328233807.GA28423@xyzzy>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ralf Baechle <ralf@linux-mips.org>, Manish Lachwani <mlachwani@mvista.com>,
        Brian Waite <brian@waitefamily.us>,
        "Steven J. Hill" <sjhill@realitydiluted.com>,
        Benjamin Herrenschmidt <benh@kernel.crashing.org>,
        James Chapman <jchapman@katalix.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Netdev <netdev@oss.sgi.com>, Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <20050328233807.GA28423@xyzzy>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Signed-off-by: Dale Farnsworth <dale@farnsworth.org>

Index: linux-2.5-enet/arch/ppc/platforms/katana.c
===================================================================
--- linux-2.5-enet.orig/arch/ppc/platforms/katana.c
+++ linux-2.5-enet/arch/ppc/platforms/katana.c
@@ -30,6 +30,7 @@
 #include <linux/bootmem.h>
 #include <linux/mtd/physmap.h>
 #include <linux/mv643xx.h>
+#include <linux/ethtool.h>
 #ifdef CONFIG_BOOTIMG
 #include <linux/bootimg.h>
 #endif
@@ -495,21 +496,30 @@
 #endif
 
 #if defined(CONFIG_MV643XX_ETH)
+static struct ethtool_cmd mv643xx_ethtool_cmd[] = {
+	[0] = {
+		.phy_address =	KATANA_ETH0_PHY_ADDR,
+		.autoneg =	AUTONEG_ENABLE,
+	},
+	[1] = {
+		.phy_address =	KATANA_ETH1_PHY_ADDR,
+		.autoneg =	AUTONEG_ENABLE,
+	},
+	[2] = {
+		.phy_address =	KATANA_ETH2_PHY_ADDR,
+		.autoneg =	AUTONEG_ENABLE,
+	}
+};
+
 static void __init
 katana_fixup_eth_pdata(struct platform_device *pdev)
 {
 	struct mv643xx_eth_platform_data *eth_pd;
-	static u16 phy_addr[] = {
-		KATANA_ETH0_PHY_ADDR,
-		KATANA_ETH1_PHY_ADDR,
-		KATANA_ETH2_PHY_ADDR,
-	};
 
 	eth_pd = pdev->dev.platform_data;
-	eth_pd->force_phy_addr = 1;
-	eth_pd->phy_addr = phy_addr[pdev->id];
 	eth_pd->tx_queue_size = KATANA_ETH_TX_QUEUE_SIZE;
 	eth_pd->rx_queue_size = KATANA_ETH_RX_QUEUE_SIZE;
+	eth_pd->ethtool_cmd = &mv643xx_ethtool_cmd[pdev->id];
 }
 #endif
 
