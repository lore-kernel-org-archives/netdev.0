From: Daniele Venzano <webvenza@libero.it>
Subject: [PATCH 3/5] sis900 printk audit
Date: Sat, 22 Jan 2005 22:46:59 +0100 (CET)
Message-ID: <20050122214659.18649.83119@localhost.localdomain>
References: <20050122214657.18649.66345@localhost.localdomain>
Mime-Version: 1.0
Content-Type: multipart/mixed; charset="us-ascii";
	boundary="===============1829249079=="
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <20050122214657.18649.66345@localhost.localdomain>
To: Jeff Garzik <jgarzik@pobox.com>, NetDev <netdev@oss.sgi.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a MIME message, see the first attachment for the text
and the second for the patch
--===============1829249079==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit



Change priority of printk where appropriate
Remove two cryptic and useless printk



Signed-off-by: Daniele Venzano <webvenza@libero.it>


--===============1829249079==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit

Index: sis900.c
===================================================================
--- a/drivers/net/sis900.c	(revision 85)
+++ b/drivers/net/sis900.c	(revision 86)
@@ -242,7 +242,7 @@
 	/* check to see if we have sane EEPROM */
 	signature = (u16) read_eeprom(ioaddr, EEPROMSignature);    
 	if (signature == 0xffff || signature == 0x0000) {
-		printk (KERN_INFO "%s: Error EERPOM read %x\n", 
+		printk (KERN_WARNING "%s: Error EERPOM read %x\n", 
 			net_dev->name, signature);
 		return 0;
 	}
@@ -275,7 +275,7 @@
 	if (!isa_bridge)
 		isa_bridge = pci_get_device(PCI_VENDOR_ID_SI, 0x0018, isa_bridge);
 	if (!isa_bridge) {
-		printk("%s: Can not find ISA bridge\n", net_dev->name);
+		printk(KERN_WARNING "%s: Can not find ISA bridge\n", net_dev->name);
 		return 0;
 	}
 	pci_read_config_byte(isa_bridge, 0x48, &reg);
@@ -567,7 +567,7 @@
 			continue;
 		
 		if ((mii_phy = kmalloc(sizeof(struct mii_phy), GFP_KERNEL)) == NULL) {
-			printk(KERN_INFO "Cannot allocate mem for struct mii_phy\n");
+			printk(KERN_WARNING "Cannot allocate mem for struct mii_phy\n");
 			mii_phy = sis_priv->first_mii;
 			while (mii_phy) {
 				struct mii_phy *phy;
@@ -1029,7 +1029,7 @@
 		outl(w, ioaddr + rfdr);
 
 		if (sis900_debug > 2) {
-			printk(KERN_INFO "%s: Receive Filter Addrss[%d]=%x\n",
+			printk(KERN_DEBUG "%s: Receive Filter Addrss[%d]=%x\n",
 			       net_dev->name, i, inl(ioaddr + rfdr));
 		}
 	}
@@ -1067,7 +1067,7 @@
 	/* load Transmit Descriptor Register */
 	outl(sis_priv->tx_ring_dma, ioaddr + txdp);
 	if (sis900_debug > 2)
-		printk(KERN_INFO "%s: TX descriptor register loaded with: %8.8x\n",
+		printk(KERN_DEBUG "%s: TX descriptor register loaded with: %8.8x\n",
 		       net_dev->name, inl(ioaddr + txdp));
 }
 
@@ -1121,7 +1121,7 @@
 	/* load Receive Descriptor Register */
 	outl(sis_priv->rx_ring_dma, ioaddr + rxdp);
 	if (sis900_debug > 2)
-		printk(KERN_INFO "%s: RX descriptor register loaded with: %8.8x\n",
+		printk(KERN_DEBUG "%s: RX descriptor register loaded with: %8.8x\n",
 		       net_dev->name, inl(ioaddr + rxdp));
 }
 
@@ -1571,7 +1571,7 @@
 	net_dev->trans_start = jiffies;
 
 	if (sis900_debug > 3)
-		printk(KERN_INFO "%s: Queued Tx packet at %p size %d "
+		printk(KERN_DEBUG "%s: Queued Tx packet at %p size %d "
 		       "to slot %d.\n",
 		       net_dev->name, skb->data, (int)skb->len, entry);
 
@@ -1631,7 +1631,7 @@
 	} while (1);
 
 	if (sis900_debug > 3)
-		printk(KERN_INFO "%s: exiting interrupt, "
+		printk(KERN_DEBUG "%s: exiting interrupt, "
 		       "interrupt status = 0x%#8.8x.\n",
 		       net_dev->name, inl(ioaddr + isr));
 	
@@ -1657,7 +1657,7 @@
 	u32 rx_status = sis_priv->rx_ring[entry].cmdsts;
 
 	if (sis900_debug > 3)
-		printk(KERN_INFO "sis900_rx, cur_rx:%4.4d, dirty_rx:%4.4d "
+		printk(KERN_DEBUG "sis900_rx, cur_rx:%4.4d, dirty_rx:%4.4d "
 		       "status:0x%8.8x\n",
 		       sis_priv->cur_rx, sis_priv->dirty_rx, rx_status);
 
@@ -1669,7 +1669,7 @@
 		if (rx_status & (ABORT|OVERRUN|TOOLONG|RUNT|RXISERR|CRCERR|FAERR)) {
 			/* corrupted packet received */
 			if (sis900_debug > 3)
-				printk(KERN_INFO "%s: Corrupted packet "
+				printk(KERN_DEBUG "%s: Corrupted packet "
 				       "received, buffer status = 0x%8.8x.\n",
 				       net_dev->name, rx_status);
 			sis_priv->stats.rx_errors++;
@@ -1807,7 +1807,7 @@
 		if (tx_status & (ABORT | UNDERRUN | OWCOLL)) {
 			/* packet unsuccessfully transmitted */
 			if (sis900_debug > 3)
-				printk(KERN_INFO "%s: Transmit "
+				printk(KERN_DEBUG "%s: Transmit "
 				       "error, Tx status %8.8x.\n",
 				       net_dev->name, tx_status);
 			sis_priv->stats.tx_errors++;
@@ -2074,12 +2074,10 @@
 		case IF_PORT_AUI: /* AUI */
 		case IF_PORT_100BASEFX: /* 100BaseFx */
                 	/* These Modes are not supported (are they?)*/
-			printk(KERN_INFO "Not supported");
 			return -EOPNOTSUPP;
 			break;
             
 		default:
-			printk(KERN_INFO "Invalid");
 			return -EINVAL;
 		}
 	}

--===============1829249079==--
