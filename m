From: "Dale Farnsworth" <dale@farnsworth.org>
Subject: mv643xx(17/20): Reset the PHY only at driver open time
Date: Mon, 28 Mar 2005 16:58:54 -0700
Message-ID: <20050328235854.GQ29098@xyzzy>
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

Index: linux-2.5-enet/drivers/net/mv643xx_eth.c
===================================================================
--- linux-2.5-enet.orig/drivers/net/mv643xx_eth.c
+++ linux-2.5-enet/drivers/net/mv643xx_eth.c
@@ -587,10 +587,8 @@
 {
 	unsigned int phy_reg_data;
 
-	/* Reset the PHY */
-	mv643xx_eth_read_smi_reg(dev, 0, &phy_reg_data);
-	phy_reg_data |= 0x8000;	/* Set bit 15 to reset the PHY */
-	mv643xx_eth_write_smi_reg(dev, 0, phy_reg_data);
+	mv643xx_eth_read_smi_reg(dev, MII_BMCR, &phy_reg_data);
+	mv643xx_eth_write_smi_reg(dev, MII_BMCR, phy_reg_data | BMCR_RESET);
 }
 
 /*
@@ -618,8 +616,6 @@
 	mv643xx_eth_port_reset(dev);
 
 	mv643xx_eth_port_init_mac_tables(dev);
-
-	mv643xx_eth_phy_reset(dev);
 }
 
 static inline u32 mv643xx_eth_read_mib_counter(struct net_device *dev,
@@ -2173,6 +2169,8 @@
 
 	spin_lock_irq(&mp->lock);
 
+	mv643xx_eth_phy_reset(dev);
+
 	err = request_irq(dev->irq, mv643xx_eth_int_handler,
 			  SA_SHIRQ | SA_SAMPLE_RANDOM, dev->name, dev);
 
