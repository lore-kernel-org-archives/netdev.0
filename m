From: Yurii Pavlenko <pyldev@gmail.com>
Subject: [PATCH] au1k_ir.c fix warning: Prefer [subsystem eg: netdev]_info([subsystem]dev, ...
Date: Sat, 23 Sep 2017 22:13:37 +0200
Message-ID: <1506197617-28118-1-git-send-email-pyldev@gmail.com>
Cc: gregkh@linuxfoundation.org, davem@davemloft.net,
        manuel.lauss@gmail.com, netdev@vger.kernel.org,
        devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org,
        Yurii Pavlenko <pyldev@gmail.com>
To: samuel@sortiz.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fixes the following checkpatch.pl warning: fix
Prefer [subsystem eg: netdev]_info([subsystem]dev, ... then dev_info(dev, ...
then pr_info(...  to printk(KERN_INFO ...

Signed-off-by: Yurii Pavlenko <pyldev@gmail.com>
---
 drivers/staging/irda/drivers/au1k_ir.c | 40 +++++++++++++++-------------------
 1 file changed, 18 insertions(+), 22 deletions(-)

diff --git a/drivers/staging/irda/drivers/au1k_ir.c b/drivers/staging/irda/drivers/au1k_ir.c
index be4ea6a..73e3e4b 100644
--- a/drivers/staging/irda/drivers/au1k_ir.c
+++ b/drivers/staging/irda/drivers/au1k_ir.c
@@ -290,8 +290,7 @@ static int au1k_irda_set_speed(struct net_device *dev, int speed)
 	while (irda_read(aup, IR_STATUS) & (IR_RX_STATUS | IR_TX_STATUS)) {
 		msleep(20);
 		if (!timeout--) {
-			printk(KERN_ERR "%s: rx/tx disable timeout\n",
-					dev->name);
+			netdev_err(dev, "rx/tx disable timeout\n");
 			break;
 		}
 	}
@@ -349,7 +348,7 @@ static int au1k_irda_set_speed(struct net_device *dev, int speed)
 				IR_RX_ENABLE);
 		break;
 	default:
-		printk(KERN_ERR "%s unsupported speed %x\n", dev->name, speed);
+		netdev_err(dev, "unsupported speed %x\n", speed);
 		ret = -EINVAL;
 		break;
 	}
@@ -361,18 +360,18 @@ static int au1k_irda_set_speed(struct net_device *dev, int speed)
 	irda_write(aup, IR_RING_PROMPT, 0);
 
 	if (control & (1 << 14)) {
-		printk(KERN_ERR "%s: configuration error\n", dev->name);
+		netdev_err(dev, "configuration error\n");
 	} else {
 		if (control & (1 << 11))
-			printk(KERN_DEBUG "%s Valid SIR config\n", dev->name);
+			netdev_debug(dev, "Valid SIR config\n");
 		if (control & (1 << 12))
-			printk(KERN_DEBUG "%s Valid MIR config\n", dev->name);
+			netdev_debug(dev, "Valid MIR config\n");
 		if (control & (1 << 13))
-			printk(KERN_DEBUG "%s Valid FIR config\n", dev->name);
+			netdev_debug(dev, "Valid FIR config\n");
 		if (control & (1 << 10))
-			printk(KERN_DEBUG "%s TX enabled\n", dev->name);
+			netdev_debug(dev, "TX enabled\n");
 		if (control & (1 << 9))
-			printk(KERN_DEBUG "%s RX enabled\n", dev->name);
+			netdev_debug(dev, "RX enabled\n");
 	}
 
 	return ret;
@@ -584,23 +583,21 @@ static int au1k_irda_start(struct net_device *dev)
 
 	retval = au1k_init(dev);
 	if (retval) {
-		printk(KERN_ERR "%s: error in au1k_init\n", dev->name);
+		netdev_err(dev, "error in au1k_init\n");
 		return retval;
 	}
 
 	retval = request_irq(aup->irq_tx, &au1k_irda_interrupt, 0,
 			     dev->name, dev);
 	if (retval) {
-		printk(KERN_ERR "%s: unable to get IRQ %d\n",
-				dev->name, dev->irq);
+		netdev_err(dev, "unable to get IRQ %d\n", dev->irq);
 		return retval;
 	}
 	retval = request_irq(aup->irq_rx, &au1k_irda_interrupt, 0,
 			     dev->name, dev);
 	if (retval) {
 		free_irq(aup->irq_tx, dev);
-		printk(KERN_ERR "%s: unable to get IRQ %d\n",
-				dev->name, dev->irq);
+		netdev_err(dev, "unable to get IRQ %d\n", dev->irq);
 		return retval;
 	}
 
@@ -673,12 +670,12 @@ static int au1k_irda_hard_xmit(struct sk_buff *skb, struct net_device *dev)
 	flags = ptxd->flags;
 
 	if (flags & AU_OWN) {
-		printk(KERN_DEBUG "%s: tx_full\n", dev->name);
+		netdev_debug(dev, "tx_full\n");
 		netif_stop_queue(dev);
 		aup->tx_full = 1;
 		return 1;
 	} else if (((aup->tx_head + 1) & (NUM_IR_DESC - 1)) == aup->tx_tail) {
-		printk(KERN_DEBUG "%s: tx_full\n", dev->name);
+		netdev_debug(dev, "tx_full\n");
 		netif_stop_queue(dev);
 		aup->tx_full = 1;
 		return 1;
@@ -688,7 +685,7 @@ static int au1k_irda_hard_xmit(struct sk_buff *skb, struct net_device *dev)
 
 #if 0
 	if (irda_read(aup, IR_RX_BYTE_CNT) != 0) {
-		printk(KERN_DEBUG "tx warning: rx byte cnt %x\n",
+		netdev_debug(dev, "tx warning: rx byte cnt %x\n",
 				irda_read(aup, IR_RX_BYTE_CNT));
 	}
 #endif
@@ -726,7 +723,7 @@ static void au1k_tx_timeout(struct net_device *dev)
 	u32 speed;
 	struct au1k_private *aup = netdev_priv(dev);
 
-	printk(KERN_ERR "%s: tx timeout\n", dev->name);
+	netdev_err(dev, "tx timeout\n");
 	speed = aup->speed;
 	aup->speed = 0;
 	au1k_irda_set_speed(dev, speed);
@@ -751,8 +748,7 @@ static int au1k_irda_ioctl(struct net_device *dev, struct ifreq *ifreq, int cmd)
 				ret = au1k_irda_set_speed(dev,
 						rq->ifr_baudrate);
 			else {
-				printk(KERN_ERR "%s ioctl: !netif_running\n",
-						dev->name);
+				netdev_err(dev, "ioctl: !netif_running\n");
 				ret = 0;
 			}
 		}
@@ -868,7 +864,7 @@ static int au1k_irda_net_init(struct net_device *dev)
 out2:
 	kfree(aup->rx_buff.head);
 out1:
-	printk(KERN_ERR "au1k_irda_net_init() failed.  Returns %d\n", retval);
+	netdev_err(dev, "au1k_irda_net_init() failed.  Returns %d\n");
 	return retval;
 }
 
@@ -934,7 +930,7 @@ static int au1k_irda_probe(struct platform_device *pdev)
 
 	platform_set_drvdata(pdev, dev);
 
-	printk(KERN_INFO "IrDA: Registered device %s\n", dev->name);
+	netdev_info(dev, "IrDA: Registered device\n");
 	return 0;
 
 out4:
-- 
2.7.4
