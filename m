From: "Dale Farnsworth" <dale@farnsworth.org>
Subject: mv643xx(18/20): Isolate the PHY at device close
Date: Mon, 28 Mar 2005 16:59:26 -0700
Message-ID: <20050328235926.GR29098@xyzzy>
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

Signed-off-by: James Chapman <jchapman@katalix.com>
Acked-by: Dale Farnsworth <dale@farnsworth.org>

Index: linux-2.5-enet/drivers/net/mv643xx_eth.c
===================================================================
--- linux-2.5-enet.orig/drivers/net/mv643xx_eth.c
+++ linux-2.5-enet/drivers/net/mv643xx_eth.c
@@ -591,6 +591,12 @@
 	mv643xx_eth_write_smi_reg(dev, MII_BMCR, phy_reg_data | BMCR_RESET);
 }
 
+static void mv643xx_eth_phy_isolate(struct net_device *dev)
+{
+	/* Isolate the PHY (force link down) */
+	mv643xx_eth_write_smi_reg(dev, MII_BMCR, BMCR_PDOWN | BMCR_ISOLATE);
+}
+
 /*
  * This function prepares the ethernet port to start its activity:
  * 1) Completes the ethernet port driver struct initialization toward port
@@ -2210,6 +2216,9 @@
 
 	mv643xx_eth_real_stop(dev);
 
+	/* Isolate the PHY from the network (force link down) */
+	mv643xx_eth_phy_isolate(dev);
+
 	free_irq(dev->irq, dev);
 	spin_unlock_irq(&mp->lock);
 
