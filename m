From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]: Third (final?) release of Sun Neptune driver
Date: Fri, 05 Oct 2007 15:54:48 -0700 (PDT)
Message-ID: <20071005.155448.64007750.davem@davemloft.net>
References: <20071005.031209.57156822.davem@davemloft.net>
	<20071005083556.7076dd43@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ariel.Hendel@sun.com, greg.onufer@sun.com,
	jeff@garzik.org, Ashley.Saulsbury@sun.com, Matheos.Worku@sun.com
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59702
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1761592AbXJEWyt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Oct 2007 18:54:49 -0400
In-Reply-To: <20071005083556.7076dd43@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Fri, 5 Oct 2007 08:35:56 -0700

> pr_info() ?

All corrected, thanks!

>From 11aaa8adc8e9141a440faaa3260ad5922c71eeda Mon Sep 17 00:00:00 2001
From: David S. Miller <davem@sunset.davemloft.net>
Date: Fri, 5 Oct 2007 15:53:21 -0700
Subject: [PATCH] [NIU]: Use pr_info().

Suggested by Stephen Hemminger.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/niu.c |   78 ++++++++++++++++++++++++++--------------------------
 1 files changed, 39 insertions(+), 39 deletions(-)

diff --git a/drivers/net/niu.c b/drivers/net/niu.c
index 1d56a1a..92059d7 100644
--- a/drivers/net/niu.c
+++ b/drivers/net/niu.c
@@ -845,21 +845,21 @@ static int xcvr_init_10g(struct niu *np)
 			MII_STAT1000);
 	if (err < 0)
 		return err;
-	printk(KERN_INFO PFX "Port %u PMA_PMD(MII_STAT1000) [%04x]\n",
-	       np->port, err);
+	pr_info(PFX "Port %u PMA_PMD(MII_STAT1000) [%04x]\n",
+		np->port, err);
 
 	err = mdio_read(np, np->phy_addr, BCM8704_USER_DEV3_ADDR, 0x20);
 	if (err < 0)
 		return err;
-	printk(KERN_INFO PFX "Port %u USER_DEV3(0x20) [%04x]\n",
-	       np->port, err);
+	pr_info(PFX "Port %u USER_DEV3(0x20) [%04x]\n",
+		np->port, err);
 
 	err = mdio_read(np, np->phy_addr, BCM8704_PHYXS_DEV_ADDR,
 			MII_NWAYTEST);
 	if (err < 0)
 		return err;
-	printk(KERN_INFO PFX "Port %u PHYXS(MII_NWAYTEST) [%04x]\n",
-	       np->port, err);
+	pr_info(PFX "Port %u PHYXS(MII_NWAYTEST) [%04x]\n",
+		np->port, err);
 #endif
 
 	/* XXX dig this out it might not be so useful XXX */
@@ -885,11 +885,11 @@ static int xcvr_init_10g(struct niu *np)
 
 	if (analog_stat0 != 0x03fc) {
 		if ((analog_stat0 == 0x43bc) && (tx_alarm_status != 0)) {
-			printk(KERN_INFO PFX "Port %u cable not connected "
-			       "or bad cable.\n", np->port);
+			pr_info(PFX "Port %u cable not connected "
+				"or bad cable.\n", np->port);
 		} else if (analog_stat0 == 0x639c) {
-			printk(KERN_INFO PFX "Port %u optical module is bad "
-			       "or missing.\n", np->port);
+			pr_info(PFX "Port %u optical module is bad "
+				"or missing.\n", np->port);
 		}
 	}
 
@@ -6295,13 +6295,13 @@ static int __devinit phy_record(struct niu_parent *parent,
 			return 0;
 	}
 
-	printk(KERN_INFO PFX "niu%d: Found PHY %08x type %s at phy_port %u\n",
-	       parent->index, id,
-	       (type == PHY_TYPE_PMA_PMD ?
-		"PMA/PMD" :
-		(type == PHY_TYPE_PCS ?
-		 "PCS" : "MII")),
-	       phy_port);
+	pr_info("niu%d: Found PHY %08x type %s at phy_port %u\n",
+		parent->index, id,
+		(type == PHY_TYPE_PMA_PMD ?
+		 "PMA/PMD" :
+		 (type == PHY_TYPE_PCS ?
+		  "PCS" : "MII")),
+		phy_port);
 
 	if (p->cur[type] >= NIU_MAX_PORTS) {
 		printk(KERN_ERR PFX "Too many PHY ports.\n");
@@ -6365,11 +6365,11 @@ static void __devinit niu_n2_divide_channels(struct niu_parent *parent)
 		parent->rxchan_per_port[i] = (16 / num_ports);
 		parent->txchan_per_port[i] = (16 / num_ports);
 
-		printk(KERN_INFO PFX "niu%d: Port %u [%u RX chans] "
-		       "[%u TX chans]\n",
-		       parent->index, i,
-		       parent->rxchan_per_port[i],
-		       parent->txchan_per_port[i]);
+		pr_info(PFX "niu%d: Port %u [%u RX chans] "
+			"[%u TX chans]\n",
+			parent->index, i,
+			parent->rxchan_per_port[i],
+			parent->txchan_per_port[i]);
 	}
 }
 
@@ -6409,11 +6409,11 @@ static void __devinit niu_divide_channels(struct niu_parent *parent,
 			parent->rxchan_per_port[i] = rx_chans_per_1g;
 			parent->txchan_per_port[i] = tx_chans_per_1g;
 		}
-		printk(KERN_INFO PFX "niu%d: Port %u [%u RX chans] "
-		       "[%u TX chans]\n",
-		       parent->index, i,
-		       parent->rxchan_per_port[i],
-		       parent->txchan_per_port[i]);
+		pr_info(PFX "niu%d: Port %u [%u RX chans] "
+			"[%u TX chans]\n",
+			parent->index, i,
+			parent->rxchan_per_port[i],
+			parent->txchan_per_port[i]);
 		tot_rx += parent->rxchan_per_port[i];
 		tot_tx += parent->txchan_per_port[i];
 	}
@@ -6463,8 +6463,8 @@ static void __devinit niu_divide_rdc_groups(struct niu_parent *parent,
 			struct rdc_table *rt = &tp->tables[grp];
 			int slot;
 
-			printk(KERN_INFO PFX "niu%d: Port %d RDC tbl(%d) [ ",
-			       parent->index, i, tp->first_table_num + grp);
+			pr_info(PFX "niu%d: Port %d RDC tbl(%d) [ ",
+				parent->index, i, tp->first_table_num + grp);
 			for (slot = 0; slot < NIU_RDC_TABLE_SLOTS; slot++) {
 				rt->rxdma_channel[slot] =
 					rdc_channel_base + this_channel_offset;
@@ -7342,7 +7342,7 @@ static void __devinit niu_driver_version(void)
 	static int niu_version_printed = 0;
 
 	if (niu_version_printed++ == 0)
-		printk(KERN_INFO "%s", version);
+		pr_info("%s", version);
 }
 
 static struct net_device * __devinit niu_alloc_and_init(struct device *gen_dev,
@@ -7398,19 +7398,19 @@ static void __devinit niu_device_announce(struct niu *np)
 	struct net_device *dev = np->dev;
 	int i;
 
-	printk(KERN_INFO "%s: NIU Ethernet ", dev->name);
+	pr_info("%s: NIU Ethernet ", dev->name);
 	for (i = 0; i < 6; i++)
 		printk("%2.2x%c", dev->dev_addr[i],
 		       i == 5 ? '\n' : ':');
 
-	printk(KERN_INFO "%s: Port type[%s] mode[%s:%s] XCVR[%s] phy[%s]\n",
-	       dev->name,
-	       (np->flags & NIU_FLAGS_XMAC ? "XMAC" : "BMAC"),
-	       (np->flags & NIU_FLAGS_10G ? "10G" : "1G"),
-	       (np->flags & NIU_FLAGS_FIBER ? "FIBER" : "COPPER"),
-	       (np->mac_xcvr == MAC_XCVR_MII ? "MII" :
-		(np->mac_xcvr == MAC_XCVR_PCS ? "PCS" : "XPCS")),
-	       np->vpd.phy_type);
+	pr_info("%s: Port type[%s] mode[%s:%s] XCVR[%s] phy[%s]\n",
+		dev->name,
+		(np->flags & NIU_FLAGS_XMAC ? "XMAC" : "BMAC"),
+		(np->flags & NIU_FLAGS_10G ? "10G" : "1G"),
+		(np->flags & NIU_FLAGS_FIBER ? "FIBER" : "COPPER"),
+		(np->mac_xcvr == MAC_XCVR_MII ? "MII" :
+		 (np->mac_xcvr == MAC_XCVR_PCS ? "PCS" : "XPCS")),
+		np->vpd.phy_type);
 }
 
 static int __devinit niu_pci_init_one(struct pci_dev *pdev,
-- 
1.5.3.3

