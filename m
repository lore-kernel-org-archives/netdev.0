From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 6/7][MV643XX_ETH] report netdev name in all printks
Date: Mon, 17 Mar 2008 20:19:06 +0100
Message-ID: <20080317191906.GG17828@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dale Farnsworth <dale@farnsworth.org>,
	Nicolas Pitre <nico@marvell.com>,
	Tzachi Perelstein <tzachi@marvell.com>,
	Saeed Bishara <saeed@marvell.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from alephnull.demon.nl ([83.160.184.112]:37960 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753089AbYCQTTI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Mar 2008 15:19:08 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In error and warning printks, always report the netdevice name
instead of the port index (the latter has no meaning when there
are multiple mv643xx_eth silicon blocks in the system.)

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
Acked-by: Tzachi Perelstein <tzachi@marvell.com>

Index: linux-2.6.25-rc6/drivers/net/mv643xx_eth.c
===================================================================
--- linux-2.6.25-rc6.orig/drivers/net/mv643xx_eth.c
+++ linux-2.6.25-rc6/drivers/net/mv643xx_eth.c
@@ -1315,8 +1315,7 @@ static int mv643xx_eth_open(struct net_d
 	err = request_irq(dev->irq, mv643xx_eth_int_handler,
 			IRQF_SHARED | IRQF_SAMPLE_RANDOM, dev->name, dev);
 	if (err) {
-		printk(KERN_ERR "Can not assign IRQ number to MV643XX_eth%d\n",
-								port_num);
+		printk(KERN_ERR "%s: Can not assign IRQ\n", dev->name);
 		return -EAGAIN;
 	}
 
@@ -1916,9 +1915,8 @@ static int mv643xx_eth_probe(struct plat
 
 	err = ethernet_phy_detect(mp);
 	if (err) {
-		pr_debug("MV643xx ethernet port %d: "
-					"No PHY detected at addr %d\n",
-					port_num, ethernet_phy_get(mp));
+		pr_debug("%s: No PHY detected at addr %d\n",
+				dev->name, ethernet_phy_get(mp));
 		goto out;
 	}
 
@@ -2911,7 +2909,7 @@ static void eth_port_read_smi_reg(struct
 	/* wait for the SMI register to become available */
 	for (i = 0; rdl(mp, SMI_REG) & ETH_SMI_BUSY; i++) {
 		if (i == PHY_WAIT_ITERATIONS) {
-			printk("mv643xx PHY busy timeout, port %d\n", port_num);
+			printk("%s: PHY busy timeout\n", mp->dev->name);
 			goto out;
 		}
 		udelay(PHY_WAIT_MICRO_SECONDS);
@@ -2923,7 +2921,7 @@ static void eth_port_read_smi_reg(struct
 	/* now wait for the data to be valid */
 	for (i = 0; !(rdl(mp, SMI_REG) & ETH_SMI_READ_VALID); i++) {
 		if (i == PHY_WAIT_ITERATIONS) {
-			printk("mv643xx PHY read timeout, port %d\n", port_num);
+			printk("%s: PHY read timeout\n", mp->dev->name);
 			goto out;
 		}
 		udelay(PHY_WAIT_MICRO_SECONDS);
@@ -2969,8 +2967,7 @@ static void eth_port_write_smi_reg(struc
 	/* wait for the SMI register to become available */
 	for (i = 0; rdl(mp, SMI_REG) & ETH_SMI_BUSY; i++) {
 		if (i == PHY_WAIT_ITERATIONS) {
-			printk("mv643xx PHY busy timeout, port %d\n",
-								eth_port_num);
+			printk("%s: PHY busy timeout\n", mp->dev->name);
 			goto out;
 		}
 		udelay(PHY_WAIT_MICRO_SECONDS);
