From: "Dale Farnsworth" <dale@farnsworth.org>
Subject: mv643xx(5/20): update ppc7d platform for new mv643xx_eth platform data
Date: Mon, 28 Mar 2005 16:45:44 -0700
Message-ID: <20050328234544.GE29098@xyzzy>
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

This patch updates the ethernet device platform data of Radstone
PPC7D.

Signed-off-by: James Chapman <jchapman@katalix.com>
Acked-by: Dale Farnsworth <dale@farnsworth.org>

Index: linux-2.6/arch/ppc/platforms/radstone_ppc7d.c
===================================================================
--- linux-2.6.orig/arch/ppc/platforms/radstone_ppc7d.c	2005-03-27 15:09:33.000000000 +0100
+++ linux-2.6/arch/ppc/platforms/radstone_ppc7d.c	2005-03-27 15:29:58.000000000 +0100
@@ -41,6 +41,7 @@
 #include <linux/serial_core.h>
 #include <linux/mv643xx.h>
 #include <linux/netdevice.h>
+#include <linux/ethtool.h>
 
 #include <asm/system.h>
 #include <asm/pgtable.h>
@@ -638,21 +639,30 @@
 #endif
 
 #if defined(CONFIG_MV643XX_ETH)
+static struct ethtool_cmd ppc7d_ethtool_cmd[] = {
+	[0] = {
+		.phy_address =	PPC7D_ETH0_PHY_ADDR,
+		.autoneg =	AUTONEG_ENABLE,
+	},
+	[1] = {
+		.phy_address =	PPC7D_ETH1_PHY_ADDR,
+		.autoneg =	AUTONEG_ENABLE,
+	},
+	[2] = {
+		.phy_address =	PPC7D_ETH2_PHY_ADDR,
+		.autoneg =	AUTONEG_ENABLE,
+	}
+};
+
 static void __init ppc7d_fixup_eth_pdata(struct platform_device *pdev)
 {
 	struct mv643xx_eth_platform_data *eth_pd;
-	static u16 phy_addr[] = {
-		PPC7D_ETH0_PHY_ADDR,
-		PPC7D_ETH1_PHY_ADDR,
-		PPC7D_ETH2_PHY_ADDR,
-	};
 	int i;
 
 	eth_pd = pdev->dev.platform_data;
-	eth_pd->force_phy_addr = 1;
-	eth_pd->phy_addr = phy_addr[pdev->id];
 	eth_pd->tx_queue_size = PPC7D_ETH_TX_QUEUE_SIZE;
 	eth_pd->rx_queue_size = PPC7D_ETH_RX_QUEUE_SIZE;
+	eth_pd->ethtool_cmd = &ppc7d_ethtool_cmd[pdev->id];
 
 	/* Adjust IRQ by mv64360_irq_base */
 	for (i = 0; i < pdev->num_resources; i++) {
@@ -665,7 +675,6 @@
 				 (int)r->start);
 		}
 	}
-
 }
 #endif
 
