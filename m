From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 10/15] drivers/net/skge.c: Use (pr|netdev)_<level> macro helpers
Date: Wed, 17 Feb 2010 17:01:57 -0800
Message-ID: <f38c47d9015203896e3bc4075c89032ad77eca33.1266454576.git.joe@perches.com>
References: <cover.1266454575.git.joe@perches.com>
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1057 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932134Ab0BRBCM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Feb 2010 20:02:12 -0500
In-Reply-To: <cover.1266454575.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
Remove #define PFX
Use pr_<level>
Use netdev_<level>

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/skge.c |   50 +++++++++++++++++++++-----------------------------
 1 files changed, 21 insertions(+), 29 deletions(-)

diff --git a/drivers/net/skge.c b/drivers/net/skge.c
index ffa55df..8aa24c5 100644
--- a/drivers/net/skge.c
+++ b/drivers/net/skge.c
@@ -23,6 +23,8 @@
  * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/in.h>
 #include <linux/kernel.h>
 #include <linux/module.h>
@@ -46,7 +48,6 @@
 
 #define DRV_NAME		"skge"
 #define DRV_VERSION		"1.13"
-#define PFX			DRV_NAME " "
 
 #define DEFAULT_TX_RING_SIZE	128
 #define DEFAULT_RX_RING_SIZE	512
@@ -1129,8 +1130,7 @@ static u16 xm_phy_read(struct skge_hw *hw, int port, u16 reg)
 {
 	u16 v = 0;
 	if (__xm_phy_read(hw, port, reg, &v))
-		printk(KERN_WARNING PFX "%s: phy read timed out\n",
-		       hw->dev[port]->name);
+		pr_warning("%s: phy read timed out\n", hw->dev[port]->name);
 	return v;
 }
 
@@ -1252,8 +1252,7 @@ static void bcom_check_link(struct skge_hw *hw, int port)
 
 		lpa = xm_phy_read(hw, port, PHY_XMAC_AUNE_LP);
 		if (lpa & PHY_B_AN_RF) {
-			printk(KERN_NOTICE PFX "%s: remote fault\n",
-			       dev->name);
+			netdev_notice(dev, "remote fault\n");
 			return;
 		}
 
@@ -1268,8 +1267,7 @@ static void bcom_check_link(struct skge_hw *hw, int port)
 			skge->duplex = DUPLEX_HALF;
 			break;
 		default:
-			printk(KERN_NOTICE PFX "%s: duplex mismatch\n",
-			       dev->name);
+			netdev_notice(dev, "duplex mismatch\n");
 			return;
 		}
 
@@ -1461,8 +1459,7 @@ static int xm_check_link(struct net_device *dev)
 
 		lpa = xm_phy_read(hw, port, PHY_XMAC_AUNE_LP);
 		if (lpa & PHY_B_AN_RF) {
-			printk(KERN_NOTICE PFX "%s: remote fault\n",
-			       dev->name);
+			netdev_notice(dev, "remote fault\n");
 			return 0;
 		}
 
@@ -1477,8 +1474,7 @@ static int xm_check_link(struct net_device *dev)
 			skge->duplex = DUPLEX_HALF;
 			break;
 		default:
-			printk(KERN_NOTICE PFX "%s: duplex mismatch\n",
-			       dev->name);
+			netdev_notice(dev, "duplex mismatch\n");
 			return 0;
 		}
 
@@ -1566,7 +1562,7 @@ static void genesis_mac_init(struct skge_hw *hw, int port)
 		udelay(1);
 	}
 
-	printk(KERN_WARNING PFX "%s: genesis reset failed\n", dev->name);
+	netdev_warn(dev, "genesis reset failed\n");
 
  reset_ok:
 	/* Unreset the XMAC. */
@@ -1898,7 +1894,7 @@ static inline void bcom_phy_intr(struct skge_port *skge)
 		     "phy interrupt status 0x%x\n", isrc);
 
 	if (isrc & PHY_B_IS_PSE)
-		printk(KERN_ERR PFX "%s: uncorrectable pair swap error\n",
+		pr_err("%s: uncorrectable pair swap error\n",
 		       hw->dev[port]->name);
 
 	/* Workaround BCom Errata:
@@ -1931,8 +1927,7 @@ static int gm_phy_write(struct skge_hw *hw, int port, u16 reg, u16 val)
 			return 0;
 	}
 
-	printk(KERN_WARNING PFX "%s: phy write timeout\n",
-	       hw->dev[port]->name);
+	pr_warning("%s: phy write timeout\n", hw->dev[port]->name);
 	return -EIO;
 }
 
@@ -1960,8 +1955,7 @@ static u16 gm_phy_read(struct skge_hw *hw, int port, u16 reg)
 {
 	u16 v = 0;
 	if (__gm_phy_read(hw, port, reg, &v))
-		printk(KERN_WARNING PFX "%s: phy read timeout\n",
-	       hw->dev[port]->name);
+		pr_warning("%s: phy read timeout\n", hw->dev[port]->name);
 	return v;
 }
 
@@ -2434,8 +2428,7 @@ static void yukon_phy_intr(struct skge_port *skge)
 	}
 	return;
  failed:
-	printk(KERN_ERR PFX "%s: autonegotiation failed (%s)\n",
-	       skge->netdev->name, reason);
+	pr_err("%s: autonegotiation failed (%s)\n", skge->netdev->name, reason);
 
 	/* XXX restart autonegotiation? */
 }
@@ -2824,7 +2817,7 @@ static netdev_tx_t skge_xmit_frame(struct sk_buff *skb,
 	smp_wmb();
 
 	if (skge_avail(&skge->tx_ring) <= TX_LOW_WATER) {
-		pr_debug("%s: transmit queue full\n", dev->name);
+		netdev_dbg(dev, "transmit queue full\n");
 		netif_stop_queue(dev);
 	}
 
@@ -3724,7 +3717,7 @@ static int skge_device_event(struct notifier_block *unused,
 			if (d)
 				skge->debugfs = d;
 			else {
-				pr_info(PFX "%s: rename failed\n", dev->name);
+				netdev_info(dev, "rename failed\n");
 				debugfs_remove(skge->debugfs);
 			}
 		}
@@ -3742,8 +3735,7 @@ static int skge_device_event(struct notifier_block *unused,
 					skge_debug, dev,
 					&skge_debug_fops);
 		if (!d || IS_ERR(d))
-			pr_info(PFX "%s: debugfs create failed\n",
-			       dev->name);
+			netdev_info(dev, "debugfs create failed\n");
 		else
 			skge->debugfs = d;
 		break;
@@ -3764,7 +3756,7 @@ static __init void skge_debug_init(void)
 
 	ent = debugfs_create_dir("skge", NULL);
 	if (!ent || IS_ERR(ent)) {
-		pr_info(PFX "debugfs create directory failed\n");
+		pr_info("debugfs create directory failed\n");
 		return;
 	}
 
@@ -3945,9 +3937,10 @@ static int __devinit skge_probe(struct pci_dev *pdev,
 	if (err)
 		goto err_out_iounmap;
 
-	printk(KERN_INFO PFX DRV_VERSION " addr 0x%llx irq %d chip %s rev %d\n",
-	       (unsigned long long)pci_resource_start(pdev, 0), pdev->irq,
-	       skge_board_name(hw), hw->chip_rev);
+	pr_info("%s addr 0x%llx irq %d chip %s rev %d\n",
+		DRV_VERSION,
+		(unsigned long long)pci_resource_start(pdev, 0), pdev->irq,
+		skge_board_name(hw), hw->chip_rev);
 
 	dev = skge_devinit(hw, 0, using_dac);
 	if (!dev)
@@ -4104,8 +4097,7 @@ static int skge_resume(struct pci_dev *pdev)
 			err = skge_up(dev);
 
 			if (err) {
-				printk(KERN_ERR PFX "%s: could not up: %d\n",
-				       dev->name, err);
+				netdev_err(dev, "could not up: %d\n", err);
 				dev_close(dev);
 				goto out;
 			}
-- 
1.7.0.14.g7e948

