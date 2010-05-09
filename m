From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] net: trans_start cleanups
Date: Sun, 09 May 2010 22:02:03 +0200
Message-ID: <1273435324.2325.61.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:54092 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751442Ab0EIUFe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 May 2010 16:05:34 -0400
Received: by bwz19 with SMTP id 19so1416078bwz.21
        for <netdev@vger.kernel.org>; Sun, 09 May 2010 13:05:32 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that core network takes care of trans_start updates, dont do it
in drivers themselves, if possible. Drivers can avoid one cache miss
(on dev->trans_start) in their start_xmit() handler.

Exceptions are NETIF_F_LLTX drivers

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 drivers/net/3c501.c                       |    1 -
 drivers/net/3c505.c                       |    7 +------
 drivers/net/3c507.c                       |    3 +--
 drivers/net/3c509.c                       |    3 +--
 drivers/net/3c515.c                       |    4 +---
 drivers/net/3c523.c                       |    3 ---
 drivers/net/3c59x.c                       |    4 +---
 drivers/net/7990.c                        |    5 ++---
 drivers/net/8139cp.c                      |    1 -
 drivers/net/8139too.c                     |    2 --
 drivers/net/82596.c                       |    3 +--
 drivers/net/a2065.c                       |    3 +--
 drivers/net/amd8111e.c                    |    2 --
 drivers/net/appletalk/cops.c              |    5 ++---
 drivers/net/arcnet/arcnet.c               |    1 -
 drivers/net/ariadne.c                     |    2 --
 drivers/net/arm/am79c961a.c               |    1 -
 drivers/net/arm/at91_ether.c              |    1 -
 drivers/net/arm/ep93xx_eth.c              |    2 --
 drivers/net/arm/ether1.c                  |    1 -
 drivers/net/arm/ether3.c                  |    1 -
 drivers/net/arm/ixp4xx_eth.c              |    1 -
 drivers/net/arm/ks8695net.c               |    2 --
 drivers/net/arm/w90p910_ether.c           |    6 ++----
 drivers/net/at1700.c                      |    3 +--
 drivers/net/atarilance.c                  |    5 ++---
 drivers/net/atlx/atl2.c                   |    1 -
 drivers/net/atp.c                         |    3 +--
 drivers/net/au1000_eth.c                  |    3 +--
 drivers/net/b44.c                         |    2 --
 drivers/net/bcm63xx_enet.c                |    1 -
 drivers/net/bfin_mac.c                    |    3 +--
 drivers/net/can/at91_can.c                |    1 -
 drivers/net/can/bfin_can.c                |    2 --
 drivers/net/can/mcp251x.c                 |    1 -
 drivers/net/can/sja1000/sja1000.c         |    2 --
 drivers/net/cassini.c                     |    1 -
 drivers/net/cpmac.c                       |    1 -
 drivers/net/cris/eth_v10.c                |    2 +-
 drivers/net/cs89x0.c                      |    1 -
 drivers/net/davinci_emac.c                |    1 -
 drivers/net/de600.c                       |    4 ++--
 drivers/net/de620.c                       |    1 -
 drivers/net/declance.c                    |    3 +--
 drivers/net/depca.c                       |    3 +--
 drivers/net/dm9000.c                      |    6 +++---
 drivers/net/dnet.c                        |    2 --
 drivers/net/e100.c                        |    1 -
 drivers/net/eepro.c                       |    3 +--
 drivers/net/eexpress.c                    |    4 ++--
 drivers/net/ehea/ehea_main.c              |    2 +-
 drivers/net/enc28j60.c                    |    2 --
 drivers/net/epic100.c                     |    3 +--
 drivers/net/eth16i.c                      |    5 ++---
 drivers/net/ethoc.c                       |    1 -
 drivers/net/ewrk3.c                       |    3 +--
 drivers/net/fealnx.c                      |    3 +--
 drivers/net/fec.c                         |    2 --
 drivers/net/fec_mpc52xx.c                 |    1 -
 drivers/net/forcedeth.c                   |    2 --
 drivers/net/fs_enet/fs_enet-main.c        |    2 --
 drivers/net/gianfar.c                     |    4 +---
 drivers/net/hp100.c                       |   10 +++-------
 drivers/net/ibmveth.c                     |    2 +-
 drivers/net/ifb.c                         |    1 -
 drivers/net/ioc3-eth.c                    |    1 -
 drivers/net/irda/au1k_ir.c                |    1 -
 drivers/net/irda/donauboe.c               |    2 --
 drivers/net/irda/pxaficp_ir.c             |    1 -
 drivers/net/irda/sa1100_ir.c              |    2 --
 drivers/net/irda/sir_dev.c                |    1 -
 drivers/net/irda/smsc-ircc2.c             |    2 +-
 drivers/net/irda/vlsi_ir.c                |    1 -
 drivers/net/irda/w83977af_ir.c            |    2 --
 drivers/net/ixgbevf/ixgbevf_main.c        |    2 --
 drivers/net/ixp2000/ixpdev.c              |    2 --
 drivers/net/lance.c                       |    4 +---
 drivers/net/lib82596.c                    |    3 +--
 drivers/net/lib8390.c                     |    3 +--
 drivers/net/ll_temac_main.c               |    2 +-
 drivers/net/lp486e.c                      |    2 --
 drivers/net/mac89x0.c                     |    1 -
 drivers/net/macb.c                        |    2 --
 drivers/net/macmace.c                     |    1 -
 drivers/net/meth.c                        |    2 +-
 drivers/net/mv643xx_eth.c                 |    1 -
 drivers/net/natsemi.c                     |    4 +---
 drivers/net/netx-eth.c                    |    1 -
 drivers/net/ni5010.c                      |    3 +--
 drivers/net/ni52.c                        |    7 ++-----
 drivers/net/ni65.c                        |    5 ++---
 drivers/net/octeon/octeon_mgmt.c          |    1 -
 drivers/net/pci-skeleton.c                |    1 -
 drivers/net/pcmcia/3c574_cs.c             |    4 +---
 drivers/net/pcmcia/3c589_cs.c             |    3 +--
 drivers/net/pcmcia/axnet_cs.c             |    2 +-
 drivers/net/pcmcia/fmvj18x_cs.c           |    1 -
 drivers/net/pcmcia/nmclan_cs.c            |    4 +---
 drivers/net/pcmcia/smc91c92_cs.c          |    2 +-
 drivers/net/pcmcia/xirc2ps_cs.c           |    3 +--
 drivers/net/pcnet32.c                     |    6 ++----
 drivers/net/plip.c                        |    1 -
 drivers/net/ps3_gelic_net.c               |    3 ---
 drivers/net/r6040.c                       |    1 -
 drivers/net/rrunner.c                     |    1 -
 drivers/net/s6gmac.c                      |    2 +-
 drivers/net/sb1250-mac.c                  |    4 +---
 drivers/net/sc92031.c                     |    2 --
 drivers/net/seeq8005.c                    |    3 +--
 drivers/net/sgiseeq.c                     |    6 ++----
 drivers/net/sh_eth.c                      |    2 --
 drivers/net/sis900.c                      |    4 +---
 drivers/net/skfp/skfddi.c                 |    1 -
 drivers/net/slip.c                        |    2 +-
 drivers/net/smc911x.c                     |    2 +-
 drivers/net/smc9194.c                     |    2 +-
 drivers/net/smc91x.c                      |    2 +-
 drivers/net/smsc911x.c                    |    1 -
 drivers/net/smsc9420.c                    |    2 --
 drivers/net/sonic.c                       |    4 +---
 drivers/net/starfire.c                    |    4 +---
 drivers/net/sun3_82586.c                  |    7 ++-----
 drivers/net/sun3lance.c                   |    8 +++-----
 drivers/net/sunbmac.c                     |    2 --
 drivers/net/sundance.c                    |    3 +--
 drivers/net/sungem.c                      |    2 +-
 drivers/net/sunhme.c                      |    2 --
 drivers/net/sunlance.c                    |    3 +--
 drivers/net/sunqe.c                       |    1 -
 drivers/net/sunvnet.c                     |    1 -
 drivers/net/tc35815.c                     |    2 --
 drivers/net/tlan.c                        |    3 +--
 drivers/net/tokenring/ibmtr.c             |    1 -
 drivers/net/tokenring/smctr.c             |    2 +-
 drivers/net/tokenring/tms380tr.c          |    2 +-
 drivers/net/tulip/de2104x.c               |    1 -
 drivers/net/tulip/de4x5.c                 |    5 ++---
 drivers/net/tulip/dmfe.c                  |    4 ++--
 drivers/net/tulip/pnic.c                  |    2 +-
 drivers/net/tulip/tulip_core.c            |    4 +---
 drivers/net/tulip/uli526x.c               |    4 ++--
 drivers/net/tulip/winbond-840.c           |    4 +---
 drivers/net/tun.c                         |    1 -
 drivers/net/typhoon.c                     |    2 --
 drivers/net/ucc_geth.c                    |    2 --
 drivers/net/usb/hso.c                     |    2 --
 drivers/net/usb/kaweth.c                  |    1 -
 drivers/net/usb/pegasus.c                 |    3 +--
 drivers/net/via-rhine.c                   |    4 +---
 drivers/net/via-velocity.c                |    1 -
 drivers/net/vmxnet3/vmxnet3_drv.c         |    1 -
 drivers/net/wan/dscc4.c                   |    2 --
 drivers/net/wan/hd64570.c                 |    1 -
 drivers/net/wan/hd64572.c                 |    1 -
 drivers/net/wan/ixp4xx_hss.c              |    1 -
 drivers/net/wan/lmc/lmc_main.c            |    6 ++----
 drivers/net/wan/pc300_drv.c               |    3 +--
 drivers/net/wan/wanxl.c                   |    1 -
 drivers/net/wireless/atmel.c              |    1 -
 drivers/net/wireless/libertas/main.c      |    2 +-
 drivers/net/wireless/libertas/tx.c        |    2 --
 drivers/net/wireless/orinoco/main.c       |    1 -
 drivers/net/wireless/prism54/islpci_eth.c |    2 --
 drivers/net/wireless/ray_cs.c             |    1 -
 drivers/net/wireless/wl3501_cs.c          |    3 +--
 drivers/net/wireless/zd1201.c             |    3 +--
 drivers/net/xilinx_emaclite.c             |    5 ++---
 drivers/net/znet.c                        |    1 -
 168 files changed, 103 insertions(+), 314 deletions(-)

diff --git a/drivers/net/3c501.c b/drivers/net/3c501.c
index 3ea42ff..4fed2a8 100644
--- a/drivers/net/3c501.c
+++ b/drivers/net/3c501.c
@@ -480,7 +480,6 @@ static netdev_tx_t el_start_xmit(struct sk_buff *skb, struct net_device *dev)
 			/* fire ... Trigger xmit.  */
 			outb(AX_XMIT, AX_CMD);
 			lp->loading = 0;
-			dev->trans_start = jiffies;
 			if (el_debug > 2)
 				pr_debug(" queued xmit.\n");
 			dev_kfree_skb(skb);
diff --git a/drivers/net/3c505.c b/drivers/net/3c505.c
index 8d584f5..88d766e 100644
--- a/drivers/net/3c505.c
+++ b/drivers/net/3c505.c
@@ -1055,7 +1055,7 @@ static void elp_timeout(struct net_device *dev)
 		   (stat & ACRF) ? "interrupt" : "command");
 	if (elp_debug >= 1)
 		pr_debug("%s: status %#02x\n", dev->name, stat);
-	dev->trans_start = jiffies;
+	dev->trans_start = jiffies; /* prevent tx timeout */
 	dev->stats.tx_dropped++;
 	netif_wake_queue(dev);
 }
@@ -1093,11 +1093,6 @@ static netdev_tx_t elp_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (elp_debug >= 3)
 		pr_debug("%s: packet of length %d sent\n", dev->name, (int) skb->len);
 
-	/*
-	 * start the transmit timeout
-	 */
-	dev->trans_start = jiffies;
-
 	prime_rx(dev);
 	spin_unlock_irqrestore(&adapter->lock, flags);
 	netif_start_queue(dev);
diff --git a/drivers/net/3c507.c b/drivers/net/3c507.c
index 9e95afa..c4e272f 100644
--- a/drivers/net/3c507.c
+++ b/drivers/net/3c507.c
@@ -504,7 +504,7 @@ static void el16_tx_timeout (struct net_device *dev)
 		outb (0, ioaddr + SIGNAL_CA);	/* Issue channel-attn. */
 		lp->last_restart = dev->stats.tx_packets;
 	}
-	dev->trans_start = jiffies;
+	dev->trans_start = jiffies; /* prevent tx timeout */
 	netif_wake_queue (dev);
 }
 
@@ -528,7 +528,6 @@ static netdev_tx_t el16_send_packet (struct sk_buff *skb,
 
 	hardware_send_packet (dev, buf, skb->len, length - skb->len);
 
-	dev->trans_start = jiffies;
 	/* Enable the 82586 interrupt input. */
 	outb (0x84, ioaddr + MISC_CTRL);
 
diff --git a/drivers/net/3c509.c b/drivers/net/3c509.c
index ab9bb3c..54deaa9 100644
--- a/drivers/net/3c509.c
+++ b/drivers/net/3c509.c
@@ -807,7 +807,7 @@ el3_tx_timeout (struct net_device *dev)
 		   dev->name, inb(ioaddr + TX_STATUS), inw(ioaddr + EL3_STATUS),
 		   inw(ioaddr + TX_FREE));
 	dev->stats.tx_errors++;
-	dev->trans_start = jiffies;
+	dev->trans_start = jiffies; /* prevent tx timeout */
 	/* Issue TX_RESET and TX_START commands. */
 	outw(TxReset, ioaddr + EL3_CMD);
 	outw(TxEnable, ioaddr + EL3_CMD);
@@ -868,7 +868,6 @@ el3_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	/* ... and the packet rounded to a doubleword. */
 	outsl(ioaddr + TX_FIFO, skb->data, (skb->len + 3) >> 2);
 
-	dev->trans_start = jiffies;
 	if (inw(ioaddr + TX_FREE) > 1536)
 		netif_start_queue(dev);
 	else
diff --git a/drivers/net/3c515.c b/drivers/net/3c515.c
index 2e17837..569e269 100644
--- a/drivers/net/3c515.c
+++ b/drivers/net/3c515.c
@@ -992,7 +992,7 @@ static void corkscrew_timeout(struct net_device *dev)
 		if (!(inw(ioaddr + EL3_STATUS) & CmdInProgress))
 			break;
 	outw(TxEnable, ioaddr + EL3_CMD);
-	dev->trans_start = jiffies;
+	dev->trans_start = jiffies; /* prevent tx timeout */
 	dev->stats.tx_errors++;
 	dev->stats.tx_dropped++;
 	netif_wake_queue(dev);
@@ -1055,7 +1055,6 @@ static netdev_tx_t corkscrew_start_xmit(struct sk_buff *skb,
 				prev_entry->status &= ~0x80000000;
 			netif_wake_queue(dev);
 		}
-		dev->trans_start = jiffies;
 		return NETDEV_TX_OK;
 	}
 	/* Put out the doubleword header... */
@@ -1091,7 +1090,6 @@ static netdev_tx_t corkscrew_start_xmit(struct sk_buff *skb,
 		outw(SetTxThreshold + (1536 >> 2), ioaddr + EL3_CMD);
 #endif				/* bus master */
 
-	dev->trans_start = jiffies;
 
 	/* Clear the Tx status stack. */
 	{
diff --git a/drivers/net/3c523.c b/drivers/net/3c523.c
index 55d219e..a7b0e5e 100644
--- a/drivers/net/3c523.c
+++ b/drivers/net/3c523.c
@@ -1152,7 +1152,6 @@ static netdev_tx_t elmc_send_packet(struct sk_buff *skb, struct net_device *dev)
 		p->scb->cmd = CUC_START;
 		p->xmit_cmds[0]->cmd_status = 0;
 			elmc_attn586();
-		dev->trans_start = jiffies;
 		if (!i) {
 			dev_kfree_skb(skb);
 		}
@@ -1176,7 +1175,6 @@ static netdev_tx_t elmc_send_packet(struct sk_buff *skb, struct net_device *dev)
 	p->xmit_cmds[0]->cmd_status = p->nop_cmds[next_nop]->cmd_status = 0;
 
 	p->nop_cmds[p->nop_point]->cmd_link = make16((p->xmit_cmds[0]));
-	dev->trans_start = jiffies;
 	p->nop_point = next_nop;
 	dev_kfree_skb(skb);
 #endif
@@ -1190,7 +1188,6 @@ static netdev_tx_t elmc_send_packet(struct sk_buff *skb, struct net_device *dev)
 	    = make16((p->nop_cmds[next_nop]));
 	p->nop_cmds[next_nop]->cmd_status = 0;
 		p->nop_cmds[p->xmit_count]->cmd_link = make16((p->xmit_cmds[p->xmit_count]));
-	dev->trans_start = jiffies;
 	p->xmit_count = next_nop;
 	if (p->xmit_count != p->xmit_last)
 		netif_wake_queue(dev);
diff --git a/drivers/net/3c59x.c b/drivers/net/3c59x.c
index 9752530..dab2afa 100644
--- a/drivers/net/3c59x.c
+++ b/drivers/net/3c59x.c
@@ -1917,7 +1917,7 @@ static void vortex_tx_timeout(struct net_device *dev)
 
 	/* Issue Tx Enable */
 	iowrite16(TxEnable, ioaddr + EL3_CMD);
-	dev->trans_start = jiffies;
+	dev->trans_start = jiffies; /* prevent tx timeout */
 
 	/* Switch to register set 7 for normal use. */
 	EL3WINDOW(7);
@@ -2063,7 +2063,6 @@ vortex_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		}
 	}
 
-	dev->trans_start = jiffies;
 
 	/* Clear the Tx status stack. */
 	{
@@ -2174,7 +2173,6 @@ boomerang_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	}
 	iowrite16(DownUnstall, ioaddr + EL3_CMD);
 	spin_unlock_irqrestore(&vp->lock, flags);
-	dev->trans_start = jiffies;
 	return NETDEV_TX_OK;
 }
 
diff --git a/drivers/net/7990.c b/drivers/net/7990.c
index f09e594..561d3d5 100644
--- a/drivers/net/7990.c
+++ b/drivers/net/7990.c
@@ -262,7 +262,7 @@ static int lance_reset (struct net_device *dev)
 
         load_csrs (lp);
         lance_init_ring (dev);
-        dev->trans_start = jiffies;
+        dev->trans_start = jiffies; /* prevent tx timeout */
         status = init_restart_lance (lp);
 #ifdef DEBUG_DRIVER
         printk ("Lance restart=%d\n", status);
@@ -526,7 +526,7 @@ void lance_tx_timeout(struct net_device *dev)
 {
 	printk("lance_tx_timeout\n");
 	lance_reset(dev);
-	dev->trans_start = jiffies;
+	dev->trans_start = jiffies; /* prevent tx timeout */
 	netif_wake_queue (dev);
 }
 EXPORT_SYMBOL_GPL(lance_tx_timeout);
@@ -574,7 +574,6 @@ int lance_start_xmit (struct sk_buff *skb, struct net_device *dev)
         outs++;
         /* Kick the lance: transmit now */
         WRITERDP(lp, LE_C0_INEA | LE_C0_TDMD);
-        dev->trans_start = jiffies;
         dev_kfree_skb (skb);
 
 	spin_lock_irqsave (&lp->devlock, flags);
diff --git a/drivers/net/8139cp.c b/drivers/net/8139cp.c
index 4e8d11c..cd63b97 100644
--- a/drivers/net/8139cp.c
+++ b/drivers/net/8139cp.c
@@ -882,7 +882,6 @@ static netdev_tx_t cp_start_xmit (struct sk_buff *skb,
 	spin_unlock_irqrestore(&cp->lock, intr_flags);
 
 	cpw8(TxPoll, NormalTxPoll);
-	dev->trans_start = jiffies;
 
 	return NETDEV_TX_OK;
 }
diff --git a/drivers/net/8139too.c b/drivers/net/8139too.c
index d0cb372..4ba7293 100644
--- a/drivers/net/8139too.c
+++ b/drivers/net/8139too.c
@@ -1716,8 +1716,6 @@ static netdev_tx_t rtl8139_start_xmit (struct sk_buff *skb,
 	RTL_W32_F (TxStatus0 + (entry * sizeof (u32)),
 		   tp->tx_flag | max(len, (unsigned int)ETH_ZLEN));
 
-	dev->trans_start = jiffies;
-
 	tp->cur_tx++;
 
 	if ((tp->cur_tx - NUM_TX_DESC) == tp->dirty_tx)
diff --git a/drivers/net/82596.c b/drivers/net/82596.c
index 97c5fc0..dd8dc15 100644
--- a/drivers/net/82596.c
+++ b/drivers/net/82596.c
@@ -1050,7 +1050,7 @@ static void i596_tx_timeout (struct net_device *dev)
 		lp->last_restart = dev->stats.tx_packets;
 	}
 
-	dev->trans_start = jiffies;
+	dev->trans_start = jiffies; /* prevent tx timeout */
 	netif_wake_queue (dev);
 }
 
@@ -1060,7 +1060,6 @@ static netdev_tx_t i596_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	struct tx_cmd *tx_cmd;
 	struct i596_tbd *tbd;
 	short length = skb->len;
-	dev->trans_start = jiffies;
 
 	DEB(DEB_STARTTX,printk(KERN_DEBUG "%s: i596_start_xmit(%x,%p) called\n",
 				dev->name, skb->len, skb->data));
diff --git a/drivers/net/a2065.c b/drivers/net/a2065.c
index ce0a0b8..ecaa28c 100644
--- a/drivers/net/a2065.c
+++ b/drivers/net/a2065.c
@@ -525,7 +525,7 @@ static inline int lance_reset (struct net_device *dev)
 	load_csrs (lp);
 
 	lance_init_ring (dev);
-	dev->trans_start = jiffies;
+	dev->trans_start = jiffies; /* prevent tx timeout */
 	netif_start_queue(dev);
 
 	status = init_restart_lance (lp);
@@ -588,7 +588,6 @@ static netdev_tx_t lance_start_xmit (struct sk_buff *skb,
 
 	/* Kick the lance: transmit now */
 	ll->rdp = LE_C0_INEA | LE_C0_TDMD;
-	dev->trans_start = jiffies;
 	dev_kfree_skb (skb);
 
 	local_irq_restore(flags);
diff --git a/drivers/net/amd8111e.c b/drivers/net/amd8111e.c
index 97d71a9..585c25f 100644
--- a/drivers/net/amd8111e.c
+++ b/drivers/net/amd8111e.c
@@ -1339,8 +1339,6 @@ static netdev_tx_t amd8111e_start_xmit(struct sk_buff *skb,
 	writel( VAL1 | TDMD0, lp->mmio + CMD0);
 	writel( VAL2 | RDMD0,lp->mmio + CMD0);
 
-	dev->trans_start = jiffies;
-
 	if(amd8111e_tx_queue_avail(lp) < 0){
 		netif_stop_queue(dev);
 	}
diff --git a/drivers/net/appletalk/cops.c b/drivers/net/appletalk/cops.c
index 6f8d620..14e1d95 100644
--- a/drivers/net/appletalk/cops.c
+++ b/drivers/net/appletalk/cops.c
@@ -866,7 +866,7 @@ static void cops_timeout(struct net_device *dev)
 	}
 	printk(KERN_WARNING "%s: Transmit timed out.\n", dev->name);
 	cops_jumpstart(dev);	/* Restart the card. */
-	dev->trans_start = jiffies;
+	dev->trans_start = jiffies; /* prevent tx timeout */
 	netif_wake_queue(dev);
 }
 
@@ -919,9 +919,8 @@ static netdev_tx_t cops_send_packet(struct sk_buff *skb,
 	/* Done sending packet, update counters and cleanup. */
 	dev->stats.tx_packets++;
 	dev->stats.tx_bytes += skb->len;
-	dev->trans_start = jiffies;
 	dev_kfree_skb (skb);
-        return NETDEV_TX_OK;
+	return NETDEV_TX_OK;
 }
 
 /*
diff --git a/drivers/net/arcnet/arcnet.c b/drivers/net/arcnet/arcnet.c
index d8f0293..a746ba2 100644
--- a/drivers/net/arcnet/arcnet.c
+++ b/drivers/net/arcnet/arcnet.c
@@ -654,7 +654,6 @@ netdev_tx_t arcnet_send_packet(struct sk_buff *skb,
 			}
 		}
 		retval = NETDEV_TX_OK;
-		dev->trans_start = jiffies;
 		lp->next_tx = txbuf;
 	} else {
 		retval = NETDEV_TX_BUSY;
diff --git a/drivers/net/ariadne.c b/drivers/net/ariadne.c
index fa1a235..705373a 100644
--- a/drivers/net/ariadne.c
+++ b/drivers/net/ariadne.c
@@ -676,8 +676,6 @@ static netdev_tx_t ariadne_start_xmit(struct sk_buff *skb,
     lance->RAP = CSR0;		/* PCnet-ISA Controller Status */
     lance->RDP = INEA|TDMD;
 
-    dev->trans_start = jiffies;
-
     if (lowb(priv->tx_ring[(entry+1) % TX_RING_SIZE]->TMD1) != 0) {
 	netif_stop_queue(dev);
 	priv->tx_full = 1;
diff --git a/drivers/net/arm/am79c961a.c b/drivers/net/arm/am79c961a.c
index a4b5b08..8c496fb 100644
--- a/drivers/net/arm/am79c961a.c
+++ b/drivers/net/arm/am79c961a.c
@@ -469,7 +469,6 @@ am79c961_sendpacket(struct sk_buff *skb, struct net_device *dev)
 
 	spin_lock_irqsave(&priv->chip_lock, flags);
 	write_rreg (dev->base_addr, CSR0, CSR0_TDMD|CSR0_IENA);
-	dev->trans_start = jiffies;
 	spin_unlock_irqrestore(&priv->chip_lock, flags);
 
 	/*
diff --git a/drivers/net/arm/at91_ether.c b/drivers/net/arm/at91_ether.c
index 0adab30..e07b314 100644
--- a/drivers/net/arm/at91_ether.c
+++ b/drivers/net/arm/at91_ether.c
@@ -824,7 +824,6 @@ static int at91ether_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		/* Set length of the packet in the Transmit Control register */
 		at91_emac_write(AT91_EMAC_TCR, skb->len);
 
-		dev->trans_start = jiffies;
 	} else {
 		printk(KERN_ERR "at91_ether.c: at91ether_start_xmit() called, but device is busy!\n");
 		return NETDEV_TX_BUSY;	/* if we return anything but zero, dev.c:1055 calls kfree_skb(skb)
diff --git a/drivers/net/arm/ep93xx_eth.c b/drivers/net/arm/ep93xx_eth.c
index 6995169..c5f6736 100644
--- a/drivers/net/arm/ep93xx_eth.c
+++ b/drivers/net/arm/ep93xx_eth.c
@@ -374,8 +374,6 @@ static int ep93xx_xmit(struct sk_buff *skb, struct net_device *dev)
 				skb->len, DMA_TO_DEVICE);
 	dev_kfree_skb(skb);
 
-	dev->trans_start = jiffies;
-
 	spin_lock_irq(&ep->tx_pending_lock);
 	ep->tx_pending++;
 	if (ep->tx_pending == TX_QUEUE_ENTRIES)
diff --git a/drivers/net/arm/ether1.c b/drivers/net/arm/ether1.c
index e47c0d9..b17ab51 100644
--- a/drivers/net/arm/ether1.c
+++ b/drivers/net/arm/ether1.c
@@ -736,7 +736,6 @@ ether1_sendpacket (struct sk_buff *skb, struct net_device *dev)
 	local_irq_restore(flags);
 
 	/* handle transmit */
-	dev->trans_start = jiffies;
 
 	/* check to see if we have room for a full sized ether frame */
 	tmp = priv(dev)->tx_head;
diff --git a/drivers/net/arm/ether3.c b/drivers/net/arm/ether3.c
index d9de9bc..1361b73 100644
--- a/drivers/net/arm/ether3.c
+++ b/drivers/net/arm/ether3.c
@@ -529,7 +529,6 @@ ether3_sendpacket(struct sk_buff *skb, struct net_device *dev)
 		return NETDEV_TX_BUSY;	/* unable to queue */
 	}
 
-	dev->trans_start = jiffies;
 	ptr		 = 0x600 * priv(dev)->tx_head;
 	priv(dev)->tx_head = next_ptr;
 	next_ptr	*= 0x600;
diff --git a/drivers/net/arm/ixp4xx_eth.c b/drivers/net/arm/ixp4xx_eth.c
index 7800d7d..24df032 100644
--- a/drivers/net/arm/ixp4xx_eth.c
+++ b/drivers/net/arm/ixp4xx_eth.c
@@ -708,7 +708,6 @@ static int eth_xmit(struct sk_buff *skb, struct net_device *dev)
 	/* NPE firmware pads short frames with zeros internally */
 	wmb();
 	queue_put_desc(TX_QUEUE(port->id), tx_desc_phys(port, n), desc);
-	dev->trans_start = jiffies;
 
 	if (qmgr_stat_below_low_watermark(txreadyq)) { /* empty */
 #if DEBUG_TX
diff --git a/drivers/net/arm/ks8695net.c b/drivers/net/arm/ks8695net.c
index 6404704..54c6d84 100644
--- a/drivers/net/arm/ks8695net.c
+++ b/drivers/net/arm/ks8695net.c
@@ -1302,8 +1302,6 @@ ks8695_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 	if (++ksp->tx_ring_used == MAX_TX_DESC)
 		netif_stop_queue(ndev);
 
-	ndev->trans_start = jiffies;
-
 	/* Kick the TX DMA in case it decided to go IDLE */
 	ks8695_writereg(ksp, KS8695_DTSC, 0);
 
diff --git a/drivers/net/arm/w90p910_ether.c b/drivers/net/arm/w90p910_ether.c
index 2491934..2e85246 100644
--- a/drivers/net/arm/w90p910_ether.c
+++ b/drivers/net/arm/w90p910_ether.c
@@ -483,7 +483,7 @@ static void w90p910_reset_mac(struct net_device *dev)
 
 	w90p910_init_desc(dev);
 
-	dev->trans_start = jiffies;
+	dev->trans_start = jiffies; /* prevent tx timeout */
 	ether->cur_tx = 0x0;
 	ether->finish_tx = 0x0;
 	ether->cur_rx = 0x0;
@@ -497,7 +497,7 @@ static void w90p910_reset_mac(struct net_device *dev)
 	w90p910_trigger_tx(dev);
 	w90p910_trigger_rx(dev);
 
-	dev->trans_start = jiffies;
+	dev->trans_start = jiffies; /* prevent tx timeout */
 
 	if (netif_queue_stopped(dev))
 		netif_wake_queue(dev);
@@ -634,8 +634,6 @@ static int w90p910_send_frame(struct net_device *dev,
 
 	txbd = &ether->tdesc->desclist[ether->cur_tx];
 
-	dev->trans_start = jiffies;
-
 	if (txbd->mode & TX_OWEN_DMA)
 		netif_stop_queue(dev);
 
diff --git a/drivers/net/at1700.c b/drivers/net/at1700.c
index 332f980..861f07a 100644
--- a/drivers/net/at1700.c
+++ b/drivers/net/at1700.c
@@ -583,7 +583,7 @@ static void net_tx_timeout (struct net_device *dev)
 	outb (0x00, ioaddr + TX_START);
 	outb (0x03, ioaddr + COL16CNTL);
 
-	dev->trans_start = jiffies;
+	dev->trans_start = jiffies; /* prevent tx timeout */
 
 	lp->tx_started = 0;
 	lp->tx_queue_ready = 1;
@@ -636,7 +636,6 @@ static netdev_tx_t net_send_packet (struct sk_buff *skb,
 		outb (0x80 | lp->tx_queue, ioaddr + TX_START);
 		lp->tx_queue = 0;
 		lp->tx_queue_len = 0;
-		dev->trans_start = jiffies;
 		lp->tx_started = 1;
 		netif_start_queue (dev);
 	} else if (lp->tx_queue_len < 4096 - 1502)
diff --git a/drivers/net/atarilance.c b/drivers/net/atarilance.c
index a8686bf..b57d7de 100644
--- a/drivers/net/atarilance.c
+++ b/drivers/net/atarilance.c
@@ -767,8 +767,8 @@ static void lance_tx_timeout (struct net_device *dev)
 	/* lance_restart, essentially */
 	lance_init_ring(dev);
 	REGA( CSR0 ) = CSR0_INEA | CSR0_INIT | CSR0_STRT;
-	dev->trans_start = jiffies;
-	netif_wake_queue (dev);
+	dev->trans_start = jiffies; /* prevent tx timeout */
+	netif_wake_queue(dev);
 }
 
 /* XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX */
@@ -836,7 +836,6 @@ static int lance_start_xmit( struct sk_buff *skb, struct net_device *dev )
 
 	/* Trigger an immediate send poll. */
 	DREG = CSR0_INEA | CSR0_TDMD;
-	dev->trans_start = jiffies;
 
 	if ((MEM->tx_head[(entry+1) & TX_RING_MOD_MASK].flag & TMD1_OWN) ==
 		TMD1_OWN_HOST)
diff --git a/drivers/net/atlx/atl2.c b/drivers/net/atlx/atl2.c
index fee9cf6..8da8738 100644
--- a/drivers/net/atlx/atl2.c
+++ b/drivers/net/atlx/atl2.c
@@ -892,7 +892,6 @@ static netdev_tx_t atl2_xmit_frame(struct sk_buff *skb,
 		(adapter->txd_write_ptr >> 2));
 
 	mmiowb();
-	netdev->trans_start = jiffies;
 	dev_kfree_skb_any(skb);
 	return NETDEV_TX_OK;
 }
diff --git a/drivers/net/atp.c b/drivers/net/atp.c
index 2bd1a5c..75ff0c5 100644
--- a/drivers/net/atp.c
+++ b/drivers/net/atp.c
@@ -547,7 +547,7 @@ static void tx_timeout(struct net_device *dev)
 	dev->stats.tx_errors++;
 	/* Try to restart the adapter. */
 	hardware_init(dev);
-	dev->trans_start = jiffies;
+	dev->trans_start = jiffies; /* prevent tx timeout */
 	netif_wake_queue(dev);
 	dev->stats.tx_errors++;
 }
@@ -586,7 +586,6 @@ static netdev_tx_t atp_send_packet(struct sk_buff *skb,
 	write_reg(ioaddr, IMR, ISR_RxOK | ISR_TxErr | ISR_TxOK);
 	write_reg_high(ioaddr, IMR, ISRh_RxErr);
 
-	dev->trans_start = jiffies;
 	dev_kfree_skb (skb);
 	return NETDEV_TX_OK;
 }
diff --git a/drivers/net/au1000_eth.c b/drivers/net/au1000_eth.c
index 7abb2c8..ece6128 100644
--- a/drivers/net/au1000_eth.c
+++ b/drivers/net/au1000_eth.c
@@ -924,7 +924,6 @@ static netdev_tx_t au1000_tx(struct sk_buff *skb, struct net_device *dev)
 	au_sync();
 	dev_kfree_skb(skb);
 	aup->tx_head = (aup->tx_head + 1) & (NUM_TX_DMA - 1);
-	dev->trans_start = jiffies;
 	return NETDEV_TX_OK;
 }
 
@@ -937,7 +936,7 @@ static void au1000_tx_timeout(struct net_device *dev)
 	netdev_err(dev, "au1000_tx_timeout: dev=%p\n", dev);
 	au1000_reset_mac(dev);
 	au1000_init(dev);
-	dev->trans_start = jiffies;
+	dev->trans_start = jiffies; /* prevent tx timeout */
 	netif_wake_queue(dev);
 }
 
diff --git a/drivers/net/b44.c b/drivers/net/b44.c
index 4582721..293f9c1 100644
--- a/drivers/net/b44.c
+++ b/drivers/net/b44.c
@@ -1014,8 +1014,6 @@ static netdev_tx_t b44_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (TX_BUFFS_AVAIL(bp) < 1)
 		netif_stop_queue(dev);
 
-	dev->trans_start = jiffies;
-
 out_unlock:
 	spin_unlock_irqrestore(&bp->lock, flags);
 
diff --git a/drivers/net/bcm63xx_enet.c b/drivers/net/bcm63xx_enet.c
index f48ba80..faf5add 100644
--- a/drivers/net/bcm63xx_enet.c
+++ b/drivers/net/bcm63xx_enet.c
@@ -565,7 +565,6 @@ static int bcm_enet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	priv->stats.tx_bytes += skb->len;
 	priv->stats.tx_packets++;
-	dev->trans_start = jiffies;
 	ret = NETDEV_TX_OK;
 
 out_unlock:
diff --git a/drivers/net/bfin_mac.c b/drivers/net/bfin_mac.c
index c488cea..b0207f0 100644
--- a/drivers/net/bfin_mac.c
+++ b/drivers/net/bfin_mac.c
@@ -654,7 +654,6 @@ static int bfin_mac_hard_start_xmit(struct sk_buff *skb,
 out:
 	adjust_tx_list();
 	current_tx_ptr = current_tx_ptr->next;
-	dev->trans_start = jiffies;
 	dev->stats.tx_packets++;
 	dev->stats.tx_bytes += (skb->len);
 	return NETDEV_TX_OK;
@@ -805,7 +804,7 @@ static void bfin_mac_timeout(struct net_device *dev)
 	bfin_mac_enable();
 
 	/* We can accept TX packets again */
-	dev->trans_start = jiffies;
+	dev->trans_start = jiffies; /* prevent tx timeout */
 	netif_wake_queue(dev);
 }
 
diff --git a/drivers/net/can/at91_can.c b/drivers/net/can/at91_can.c
index 5f98348..2d8bd86 100644
--- a/drivers/net/can/at91_can.c
+++ b/drivers/net/can/at91_can.c
@@ -375,7 +375,6 @@ static netdev_tx_t at91_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	at91_write(priv, AT91_MCR(mb), reg_mcr);
 
 	stats->tx_bytes += cf->can_dlc;
-	dev->trans_start = jiffies;
 
 	/* _NOTE_: substract AT91_MB_TX_FIRST offset from mb! */
 	can_put_echo_skb(skb, dev, mb - AT91_MB_TX_FIRST);
diff --git a/drivers/net/can/bfin_can.c b/drivers/net/can/bfin_can.c
index d77264a..b6e890d 100644
--- a/drivers/net/can/bfin_can.c
+++ b/drivers/net/can/bfin_can.c
@@ -269,8 +269,6 @@ static int bfin_can_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	/* fill data length code */
 	bfin_write16(&reg->chl[TRANSMIT_CHL].dlc, dlc);
 
-	dev->trans_start = jiffies;
-
 	can_put_echo_skb(skb, dev, 0);
 
 	/* set transmit request */
diff --git a/drivers/net/can/mcp251x.c b/drivers/net/can/mcp251x.c
index 8431eb0..b11a0cb 100644
--- a/drivers/net/can/mcp251x.c
+++ b/drivers/net/can/mcp251x.c
@@ -475,7 +475,6 @@ static netdev_tx_t mcp251x_hard_start_xmit(struct sk_buff *skb,
 
 	netif_stop_queue(net);
 	priv->tx_skb = skb;
-	net->trans_start = jiffies;
 	queue_work(priv->wq, &priv->tx_work);
 
 	return NETDEV_TX_OK;
diff --git a/drivers/net/can/sja1000/sja1000.c b/drivers/net/can/sja1000/sja1000.c
index 618c112..24b5861 100644
--- a/drivers/net/can/sja1000/sja1000.c
+++ b/drivers/net/can/sja1000/sja1000.c
@@ -292,8 +292,6 @@ static netdev_tx_t sja1000_start_xmit(struct sk_buff *skb,
 	for (i = 0; i < dlc; i++)
 		priv->write_reg(priv, dreg++, cf->data[i]);
 
-	dev->trans_start = jiffies;
-
 	can_put_echo_skb(skb, dev, 0);
 
 	priv->write_reg(priv, REG_CMR, CMD_TR);
diff --git a/drivers/net/cassini.c b/drivers/net/cassini.c
index bd857a2..6d76236 100644
--- a/drivers/net/cassini.c
+++ b/drivers/net/cassini.c
@@ -2889,7 +2889,6 @@ static netdev_tx_t cas_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	 */
 	if (cas_xmit_tx_ringN(cp, ring++ & N_TX_RINGS_MASK, skb))
 		return NETDEV_TX_BUSY;
-	dev->trans_start = jiffies;
 	return NETDEV_TX_OK;
 }
 
diff --git a/drivers/net/cpmac.c b/drivers/net/cpmac.c
index bdfff78..3c58db5 100644
--- a/drivers/net/cpmac.c
+++ b/drivers/net/cpmac.c
@@ -579,7 +579,6 @@ static int cpmac_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	}
 
 	spin_lock(&priv->lock);
-	dev->trans_start = jiffies;
 	spin_unlock(&priv->lock);
 	desc->dataflags = CPMAC_SOP | CPMAC_EOP | CPMAC_OWN;
 	desc->skb = skb;
diff --git a/drivers/net/cris/eth_v10.c b/drivers/net/cris/eth_v10.c
index f49ad8e..7e00027 100644
--- a/drivers/net/cris/eth_v10.c
+++ b/drivers/net/cris/eth_v10.c
@@ -1108,7 +1108,7 @@ e100_send_packet(struct sk_buff *skb, struct net_device *dev)
 
 	myNextTxDesc->skb = skb;
 
-	dev->trans_start = jiffies;
+	dev->trans_start = jiffies; /* NETIF_F_LLTX driver :( */
 
 	e100_hardware_send_packet(np, buf, skb->len);
 
diff --git a/drivers/net/cs89x0.c b/drivers/net/cs89x0.c
index 4c38491..2281ebc 100644
--- a/drivers/net/cs89x0.c
+++ b/drivers/net/cs89x0.c
@@ -1554,7 +1554,6 @@ static netdev_tx_t net_send_packet(struct sk_buff *skb,struct net_device *dev)
 	writewords(dev->base_addr, TX_FRAME_PORT,skb->data,(skb->len+1) >>1);
 	spin_unlock_irqrestore(&lp->lock, flags);
 	lp->stats.tx_bytes += skb->len;
-	dev->trans_start = jiffies;
 	dev_kfree_skb (skb);
 
 	/*
diff --git a/drivers/net/davinci_emac.c b/drivers/net/davinci_emac.c
index 1f9df5c..08e82b1 100644
--- a/drivers/net/davinci_emac.c
+++ b/drivers/net/davinci_emac.c
@@ -1468,7 +1468,6 @@ static int emac_dev_xmit(struct sk_buff *skb, struct net_device *ndev)
 	tx_buf.length = skb->len;
 	tx_buf.buf_token = (void *)skb;
 	tx_buf.data_ptr = skb->data;
-	ndev->trans_start = jiffies;
 	ret_code = emac_send(priv, &tx_packet, EMAC_DEF_TX_CH);
 	if (unlikely(ret_code != 0)) {
 		if (ret_code == EMAC_ERR_TX_OUT_OF_BD) {
diff --git a/drivers/net/de600.c b/drivers/net/de600.c
index 6b13f4f..23a6539 100644
--- a/drivers/net/de600.c
+++ b/drivers/net/de600.c
@@ -166,8 +166,8 @@ static int de600_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	int	i;
 
 	if (free_tx_pages <= 0) {	/* Do timeouts, to avoid hangs. */
-		tickssofar = jiffies - dev->trans_start;
-		if (tickssofar < 5)
+		tickssofar = jiffies - dev_trans_start(dev);
+		if (tickssofar < HZ/20)
 			return NETDEV_TX_BUSY;
 		/* else */
 		printk(KERN_WARNING "%s: transmit timed out (%d), %s?\n", dev->name, tickssofar, "network cable problem");
diff --git a/drivers/net/de620.c b/drivers/net/de620.c
index a0a6830..f3650fd 100644
--- a/drivers/net/de620.c
+++ b/drivers/net/de620.c
@@ -535,7 +535,6 @@ static int de620_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	}
 	de620_write_block(dev, buffer, skb->len, len-skb->len);
 
-	dev->trans_start = jiffies;
 	if(!(using_txbuf == (TXBF0 | TXBF1)))
 		netif_wake_queue(dev);
 
diff --git a/drivers/net/declance.c b/drivers/net/declance.c
index fb3f098..74abe19 100644
--- a/drivers/net/declance.c
+++ b/drivers/net/declance.c
@@ -874,7 +874,7 @@ static inline int lance_reset(struct net_device *dev)
 
 	lance_init_ring(dev);
 	load_csrs(lp);
-	dev->trans_start = jiffies;
+	dev->trans_start = jiffies; /* prevent tx timeout */
 	status = init_restart_lance(lp);
 	return status;
 }
@@ -930,7 +930,6 @@ static int lance_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	spin_unlock_irqrestore(&lp->lock, flags);
 
-	dev->trans_start = jiffies;
 	dev_kfree_skb(skb);
 
  	return NETDEV_TX_OK;
diff --git a/drivers/net/depca.c b/drivers/net/depca.c
index a88300a..38d4d9e 100644
--- a/drivers/net/depca.c
+++ b/drivers/net/depca.c
@@ -921,7 +921,7 @@ static void depca_tx_timeout(struct net_device *dev)
 	STOP_DEPCA;
 	depca_init_ring(dev);
 	LoadCSRs(dev);
-	dev->trans_start = jiffies;
+	dev->trans_start = jiffies; /* prevent tx timeout */
 	netif_wake_queue(dev);
 	InitRestartDepca(dev);
 }
@@ -954,7 +954,6 @@ static netdev_tx_t depca_start_xmit(struct sk_buff *skb,
 			outw(CSR0, DEPCA_ADDR);
 			outw(INEA | TDMD, DEPCA_DATA);
 
-			dev->trans_start = jiffies;
 			dev_kfree_skb(skb);
 		}
 		if (TX_BUFFS_AVAIL)
diff --git a/drivers/net/dm9000.c b/drivers/net/dm9000.c
index a818ea9..254b6f7 100644
--- a/drivers/net/dm9000.c
+++ b/drivers/net/dm9000.c
@@ -769,7 +769,7 @@ dm9000_hash_table(struct net_device *dev)
 }
 
 /*
- * Initilize dm9000 board
+ * Initialize dm9000 board
  */
 static void
 dm9000_init_dm9000(struct net_device *dev)
@@ -825,7 +825,7 @@ dm9000_init_dm9000(struct net_device *dev)
 	/* Init Driver variable */
 	db->tx_pkt_cnt = 0;
 	db->queue_pkt_len = 0;
-	dev->trans_start = 0;
+	dev->trans_start = jiffies;
 }
 
 /* Our watchdog timed out. Called by the networking layer */
@@ -843,7 +843,7 @@ static void dm9000_timeout(struct net_device *dev)
 	dm9000_reset(db);
 	dm9000_init_dm9000(dev);
 	/* We can accept TX packets again */
-	dev->trans_start = jiffies;
+	dev->trans_start = jiffies; /* prevent tx timeout */
 	netif_wake_queue(dev);
 
 	/* Restore previous register address */
diff --git a/drivers/net/dnet.c b/drivers/net/dnet.c
index d51a83e..8b0f50b 100644
--- a/drivers/net/dnet.c
+++ b/drivers/net/dnet.c
@@ -594,8 +594,6 @@ static netdev_tx_t dnet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	spin_unlock_irqrestore(&bp->lock, flags);
 
-	dev->trans_start = jiffies;
-
 	return NETDEV_TX_OK;
 }
 
diff --git a/drivers/net/e100.c b/drivers/net/e100.c
index ef97bfc..b194bad 100644
--- a/drivers/net/e100.c
+++ b/drivers/net/e100.c
@@ -1764,7 +1764,6 @@ static netdev_tx_t e100_xmit_frame(struct sk_buff *skb,
 		return NETDEV_TX_BUSY;
 	}
 
-	netdev->trans_start = jiffies;
 	return NETDEV_TX_OK;
 }
 
diff --git a/drivers/net/eepro.c b/drivers/net/eepro.c
index eed65d8..8d97f16 100644
--- a/drivers/net/eepro.c
+++ b/drivers/net/eepro.c
@@ -1161,8 +1161,7 @@ static netdev_tx_t eepro_send_packet(struct sk_buff *skb,
 			/* we won't wake queue here because we're out of space */
 			dev->stats.tx_dropped++;
 		else {
-		dev->stats.tx_bytes+=skb->len;
-		dev->trans_start = jiffies;
+			dev->stats.tx_bytes+=skb->len;
 			netif_wake_queue(dev);
 		}
 
diff --git a/drivers/net/eexpress.c b/drivers/net/eexpress.c
index c31dd06..43c9c9c 100644
--- a/drivers/net/eexpress.c
+++ b/drivers/net/eexpress.c
@@ -543,7 +543,7 @@ static void unstick_cu(struct net_device *dev)
 
 	if (lp->started)
 	{
-		if (time_after(jiffies, dev->trans_start + 50))
+		if (time_after(jiffies, dev_trans_start(dev) + HZ/2))
 		{
 			if (lp->tx_link==lp->last_tx_restart)
 			{
@@ -1018,7 +1018,7 @@ static void eexp_hw_tx_pio(struct net_device *dev, unsigned short *buf,
 	outw(lp->tx_head+0x16, ioaddr + DATAPORT);
 	outw(0, ioaddr + DATAPORT);
 
-        outsw(ioaddr + DATAPORT, buf, (len+1)>>1);
+	outsw(ioaddr + DATAPORT, buf, (len+1)>>1);
 
 	outw(lp->tx_tail+0xc, ioaddr + WRITE_PTR);
 	outw(lp->tx_head, ioaddr + DATAPORT);
diff --git a/drivers/net/ehea/ehea_main.c b/drivers/net/ehea/ehea_main.c
index 3977481..33a41e2 100644
--- a/drivers/net/ehea/ehea_main.c
+++ b/drivers/net/ehea/ehea_main.c
@@ -2241,7 +2241,7 @@ static int ehea_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		}
 		spin_unlock_irqrestore(&pr->netif_queue, flags);
 	}
-	dev->trans_start = jiffies;
+	dev->trans_start = jiffies; /* NETIF_F_LLTX driver :( */
 	spin_unlock(&pr->xmit_lock);
 
 	return NETDEV_TX_OK;
diff --git a/drivers/net/enc28j60.c b/drivers/net/enc28j60.c
index ff27f72..112c5aa 100644
--- a/drivers/net/enc28j60.c
+++ b/drivers/net/enc28j60.c
@@ -1293,8 +1293,6 @@ static netdev_tx_t enc28j60_send_packet(struct sk_buff *skb,
 	 */
 	netif_stop_queue(dev);
 
-	/* save the timestamp */
-	priv->netdev->trans_start = jiffies;
 	/* Remember the skb for deferred processing */
 	priv->tx_skb = skb;
 	schedule_work(&priv->tx_work);
diff --git a/drivers/net/epic100.c b/drivers/net/epic100.c
index 8b5a203..a48da2d 100644
--- a/drivers/net/epic100.c
+++ b/drivers/net/epic100.c
@@ -908,7 +908,7 @@ static void epic_tx_timeout(struct net_device *dev)
 		outl(TxQueued, dev->base_addr + COMMAND);
 	}
 
-	dev->trans_start = jiffies;
+	dev->trans_start = jiffies; /* prevent tx timeout */
 	ep->stats.tx_errors++;
 	if (!ep->tx_full)
 		netif_wake_queue(dev);
@@ -1006,7 +1006,6 @@ static netdev_tx_t epic_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	/* Trigger an immediate transmit demand. */
 	outl(TxQueued, dev->base_addr + COMMAND);
 
-	dev->trans_start = jiffies;
 	if (debug > 4)
 		printk(KERN_DEBUG "%s: Queued Tx packet size %d to slot %d, "
 			   "flag %2.2x Tx status %8.8x.\n",
diff --git a/drivers/net/eth16i.c b/drivers/net/eth16i.c
index d4e24f0..874973f 100644
--- a/drivers/net/eth16i.c
+++ b/drivers/net/eth16i.c
@@ -1027,7 +1027,7 @@ static void eth16i_timeout(struct net_device *dev)
 	inw(ioaddr + TX_STATUS_REG),  (inb(ioaddr + TX_STATUS_REG) & TX_DONE) ?
 		       "IRQ conflict" : "network cable problem");
 
-	dev->trans_start = jiffies;
+	dev->trans_start = jiffies; /* prevent tx timeout */
 
 	/* Let's dump all registers */
 	if(eth16i_debug > 0) {
@@ -1047,7 +1047,7 @@ static void eth16i_timeout(struct net_device *dev)
 	}
 	dev->stats.tx_errors++;
 	eth16i_reset(dev);
-	dev->trans_start = jiffies;
+	dev->trans_start = jiffies; /* prevent tx timeout */
 	outw(ETH16I_INTR_ON, ioaddr + TX_INTR_REG);
 	netif_wake_queue(dev);
 }
@@ -1109,7 +1109,6 @@ static netdev_tx_t eth16i_tx(struct sk_buff *skb, struct net_device *dev)
 		outb(TX_START | lp->tx_queue, ioaddr + TRANSMIT_START_REG);
 		lp->tx_queue = 0;
 		lp->tx_queue_len = 0;
-		dev->trans_start = jiffies;
 		lp->tx_started = 1;
 		netif_wake_queue(dev);
 	}
diff --git a/drivers/net/ethoc.c b/drivers/net/ethoc.c
index ad1bc73..14cbde5 100644
--- a/drivers/net/ethoc.c
+++ b/drivers/net/ethoc.c
@@ -851,7 +851,6 @@ static netdev_tx_t ethoc_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		netif_stop_queue(dev);
 	}
 
-	dev->trans_start = jiffies;
 	spin_unlock_irq(&priv->lock);
 out:
 	dev_kfree_skb(skb);
diff --git a/drivers/net/ewrk3.c b/drivers/net/ewrk3.c
index 11ba70f..99eb56b 100644
--- a/drivers/net/ewrk3.c
+++ b/drivers/net/ewrk3.c
@@ -757,7 +757,7 @@ static void ewrk3_timeout(struct net_device *dev)
 		 */
 		ENABLE_IRQs;
 
-		dev->trans_start = jiffies;
+		dev->trans_start = jiffies; /* prevent tx timeout */
 		netif_wake_queue(dev);
 	}
 }
@@ -862,7 +862,6 @@ static netdev_tx_t ewrk3_queue_pkt(struct sk_buff *skb, struct net_device *dev)
 	spin_unlock_irq (&lp->hw_lock);
 
 	dev->stats.tx_bytes += skb->len;
-	dev->trans_start = jiffies;
 	dev_kfree_skb (skb);
 
 	/* Check for free resources: stop Tx queue if there are none */
diff --git a/drivers/net/fealnx.c b/drivers/net/fealnx.c
index 51b738d..15f4f8d 100644
--- a/drivers/net/fealnx.c
+++ b/drivers/net/fealnx.c
@@ -1233,7 +1233,7 @@ static void fealnx_tx_timeout(struct net_device *dev)
 
 	spin_unlock_irqrestore(&np->lock, flags);
 
-	dev->trans_start = jiffies;
+	dev->trans_start = jiffies; /* prevent tx timeout */
 	np->stats.tx_errors++;
 	netif_wake_queue(dev); /* or .._start_.. ?? */
 }
@@ -1374,7 +1374,6 @@ static netdev_tx_t start_tx(struct sk_buff *skb, struct net_device *dev)
 		netif_stop_queue(dev);
 	++np->really_tx_count;
 	iowrite32(0, np->mem + TXPDR);
-	dev->trans_start = jiffies;
 
 	spin_unlock_irqrestore(&np->lock, flags);
 	return NETDEV_TX_OK;
diff --git a/drivers/net/fec.c b/drivers/net/fec.c
index 2b1651a..47da519 100644
--- a/drivers/net/fec.c
+++ b/drivers/net/fec.c
@@ -275,8 +275,6 @@ fec_enet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 			| BD_ENET_TX_LAST | BD_ENET_TX_TC);
 	bdp->cbd_sc = status;
 
-	dev->trans_start = jiffies;
-
 	/* Trigger transmission start */
 	writel(0, fep->hwp + FEC_X_DES_ACTIVE);
 
diff --git a/drivers/net/fec_mpc52xx.c b/drivers/net/fec_mpc52xx.c
index 0376c3e..221f440 100644
--- a/drivers/net/fec_mpc52xx.c
+++ b/drivers/net/fec_mpc52xx.c
@@ -327,7 +327,6 @@ static int mpc52xx_fec_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	}
 
 	spin_lock_irqsave(&priv->lock, flags);
-	dev->trans_start = jiffies;
 
 	bd = (struct bcom_fec_bd *)
 		bcom_prepare_next_buffer(priv->tx_dmatsk);
diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index e282d0a..268ea4d 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -2214,7 +2214,6 @@ static netdev_tx_t nv_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		dprintk("\n");
 	}
 
-	dev->trans_start = jiffies;
 	writel(NVREG_TXRXCTL_KICK|np->txrxctl_bits, get_hwbase(dev) + NvRegTxRxControl);
 	return NETDEV_TX_OK;
 }
@@ -2369,7 +2368,6 @@ static netdev_tx_t nv_start_xmit_optimized(struct sk_buff *skb,
 		dprintk("\n");
 	}
 
-	dev->trans_start = jiffies;
 	writel(NVREG_TXRXCTL_KICK|np->txrxctl_bits, get_hwbase(dev) + NvRegTxRxControl);
 	return NETDEV_TX_OK;
 }
diff --git a/drivers/net/fs_enet/fs_enet-main.c b/drivers/net/fs_enet/fs_enet-main.c
index 0770e2f..0fb0fef 100644
--- a/drivers/net/fs_enet/fs_enet-main.c
+++ b/drivers/net/fs_enet/fs_enet-main.c
@@ -674,8 +674,6 @@ static int fs_enet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 				skb->data, skb->len, DMA_TO_DEVICE));
 	CBDW_DATLEN(bdp, skb->len);
 
-	dev->trans_start = jiffies;
-
 	/*
 	 * If this was the last BD in the ring, start at the beginning again.
 	 */
diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 5267c27..11d8cae 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -1738,7 +1738,7 @@ void gfar_start(struct net_device *dev)
 		gfar_write(&regs->imask, IMASK_DEFAULT);
 	}
 
-	dev->trans_start = jiffies;
+	dev->trans_start = jiffies; /* prevent tx timeout */
 }
 
 void gfar_configure_coalescing(struct gfar_private *priv,
@@ -2161,8 +2161,6 @@ static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	/* reduce TxBD free count */
 	tx_queue->num_txbdfree -= (nr_txbds);
 
-	dev->trans_start = jiffies;
-
 	/* If the next BD still needs to be cleaned up, then the bds
 	   are full.  We need to tell the kernel to stop sending us stuff. */
 	if (!tx_queue->num_txbdfree) {
diff --git a/drivers/net/hp100.c b/drivers/net/hp100.c
index 0f3f6c2..68e5ac8 100644
--- a/drivers/net/hp100.c
+++ b/drivers/net/hp100.c
@@ -1102,7 +1102,7 @@ static int hp100_open(struct net_device *dev)
 		return -EAGAIN;
 	}
 
-	dev->trans_start = jiffies;
+	dev->trans_start = jiffies; /* prevent tx timeout */
 	netif_start_queue(dev);
 
 	lp->lan_type = hp100_sense_lan(dev);
@@ -1510,7 +1510,7 @@ static netdev_tx_t hp100_start_xmit_bm(struct sk_buff *skb,
 		printk("hp100: %s: start_xmit_bm: No TX PDL available.\n", dev->name);
 #endif
 		/* not waited long enough since last tx? */
-		if (time_before(jiffies, dev->trans_start + HZ))
+		if (time_before(jiffies, dev_trans_start(dev) + HZ))
 			goto drop;
 
 		if (hp100_check_lan(dev))
@@ -1547,7 +1547,6 @@ static netdev_tx_t hp100_start_xmit_bm(struct sk_buff *skb,
 			}
 		}
 
-		dev->trans_start = jiffies;
 		goto drop;
 	}
 
@@ -1585,7 +1584,6 @@ static netdev_tx_t hp100_start_xmit_bm(struct sk_buff *skb,
 	/* Update statistics */
 	lp->stats.tx_packets++;
 	lp->stats.tx_bytes += skb->len;
-	dev->trans_start = jiffies;
 
 	return NETDEV_TX_OK;
 
@@ -1663,7 +1661,7 @@ static netdev_tx_t hp100_start_xmit(struct sk_buff *skb,
 		printk("hp100: %s: start_xmit: tx free mem = 0x%x\n", dev->name, i);
 #endif
 		/* not waited long enough since last failed tx try? */
-		if (time_before(jiffies, dev->trans_start + HZ)) {
+		if (time_before(jiffies, dev_trans_start(dev) + HZ)) {
 #ifdef HP100_DEBUG
 			printk("hp100: %s: trans_start timing problem\n",
 			       dev->name);
@@ -1701,7 +1699,6 @@ static netdev_tx_t hp100_start_xmit(struct sk_buff *skb,
 				mdelay(1);
 			}
 		}
-		dev->trans_start = jiffies;
 		goto drop;
 	}
 
@@ -1745,7 +1742,6 @@ static netdev_tx_t hp100_start_xmit(struct sk_buff *skb,
 
 	lp->stats.tx_packets++;
 	lp->stats.tx_bytes += skb->len;
-	dev->trans_start = jiffies;
 	hp100_ints_on();
 	spin_unlock_irqrestore(&lp->lock, flags);
 
diff --git a/drivers/net/ibmveth.c b/drivers/net/ibmveth.c
index 0d2c3ac..092fb9d 100644
--- a/drivers/net/ibmveth.c
+++ b/drivers/net/ibmveth.c
@@ -957,7 +957,7 @@ static netdev_tx_t ibmveth_start_xmit(struct sk_buff *skb,
 	} else {
 		tx_packets++;
 		tx_bytes += skb->len;
-		netdev->trans_start = jiffies;
+		netdev->trans_start = jiffies; /* NETIF_F_LLTX driver :( */
 	}
 
 	if (!used_bounce)
diff --git a/drivers/net/ifb.c b/drivers/net/ifb.c
index f4081c0..ab9f675 100644
--- a/drivers/net/ifb.c
+++ b/drivers/net/ifb.c
@@ -182,7 +182,6 @@ static netdev_tx_t ifb_xmit(struct sk_buff *skb, struct net_device *dev)
 		netif_stop_queue(dev);
 	}
 
-	dev->trans_start = jiffies;
 	skb_queue_tail(&dp->rq, skb);
 	if (!dp->tasklet_pending) {
 		dp->tasklet_pending = 1;
diff --git a/drivers/net/ioc3-eth.c b/drivers/net/ioc3-eth.c
index 091ea33..e3b5e94 100644
--- a/drivers/net/ioc3-eth.c
+++ b/drivers/net/ioc3-eth.c
@@ -1503,7 +1503,6 @@ static int ioc3_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	BARRIER();
 
-	dev->trans_start = jiffies;
 	ip->tx_skbs[produce] = skb;			/* Remember skb */
 	produce = (produce + 1) & 127;
 	ip->tx_pi = produce;
diff --git a/drivers/net/irda/au1k_ir.c b/drivers/net/irda/au1k_ir.c
index b5cbd39..a3d696a 100644
--- a/drivers/net/irda/au1k_ir.c
+++ b/drivers/net/irda/au1k_ir.c
@@ -546,7 +546,6 @@ static int au1k_irda_hard_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	dev_kfree_skb(skb);
 	aup->tx_head = (aup->tx_head + 1) & (NUM_IR_DESC - 1);
-	dev->trans_start = jiffies;
 	return NETDEV_TX_OK;
 }
 
diff --git a/drivers/net/irda/donauboe.c b/drivers/net/irda/donauboe.c
index b7e6625..48bd5ec 100644
--- a/drivers/net/irda/donauboe.c
+++ b/drivers/net/irda/donauboe.c
@@ -1002,8 +1002,6 @@ toshoboe_hard_xmit (struct sk_buff *skb, struct net_device *dev)
 
   toshoboe_checkstuck (self);
 
-  dev->trans_start = jiffies;
-
  /* Check if we need to change the speed */
   /* But not now. Wait after transmission if mtt not required */
   speed=irda_get_next_speed(skb);
diff --git a/drivers/net/irda/pxaficp_ir.c b/drivers/net/irda/pxaficp_ir.c
index 1a54f6b..c192c31 100644
--- a/drivers/net/irda/pxaficp_ir.c
+++ b/drivers/net/irda/pxaficp_ir.c
@@ -556,7 +556,6 @@ static int pxa_irda_hard_xmit(struct sk_buff *skb, struct net_device *dev)
 	}
 
 	dev_kfree_skb(skb);
-	dev->trans_start = jiffies;
 	return NETDEV_TX_OK;
 }
 
diff --git a/drivers/net/irda/sa1100_ir.c b/drivers/net/irda/sa1100_ir.c
index 1dcdce0..da27050 100644
--- a/drivers/net/irda/sa1100_ir.c
+++ b/drivers/net/irda/sa1100_ir.c
@@ -715,8 +715,6 @@ static int sa1100_irda_hard_xmit(struct sk_buff *skb, struct net_device *dev)
 		Ser2HSCR0 = si->hscr0 | HSCR0_HSSP | HSCR0_TXE;
 	}
 
-	dev->trans_start = jiffies;
-
 	return NETDEV_TX_OK;
 }
 
diff --git a/drivers/net/irda/sir_dev.c b/drivers/net/irda/sir_dev.c
index de91cd1..1b051da 100644
--- a/drivers/net/irda/sir_dev.c
+++ b/drivers/net/irda/sir_dev.c
@@ -655,7 +655,6 @@ static netdev_tx_t sirdev_hard_xmit(struct sk_buff *skb,
 
 	if (likely(actual > 0)) {
 		dev->tx_skb = skb;
-		ndev->trans_start = jiffies;
 		dev->tx_buff.data += actual;
 		dev->tx_buff.len -= actual;
 	}
diff --git a/drivers/net/irda/smsc-ircc2.c b/drivers/net/irda/smsc-ircc2.c
index 6af84d8..35e4e44 100644
--- a/drivers/net/irda/smsc-ircc2.c
+++ b/drivers/net/irda/smsc-ircc2.c
@@ -868,7 +868,7 @@ static void smsc_ircc_timeout(struct net_device *dev)
 	spin_lock_irqsave(&self->lock, flags);
 	smsc_ircc_sir_start(self);
 	smsc_ircc_change_speed(self, self->io.speed);
-	dev->trans_start = jiffies;
+	dev->trans_start = jiffies; /* prevent tx timeout */
 	netif_wake_queue(dev);
 	spin_unlock_irqrestore(&self->lock, flags);
 }
diff --git a/drivers/net/irda/vlsi_ir.c b/drivers/net/irda/vlsi_ir.c
index e145052..c3d0738 100644
--- a/drivers/net/irda/vlsi_ir.c
+++ b/drivers/net/irda/vlsi_ir.c
@@ -1037,7 +1037,6 @@ static netdev_tx_t vlsi_hard_start_xmit(struct sk_buff *skb,
 		wmb();
 		outw(0, iobase+VLSI_PIO_PROMPT);
 	}
-	ndev->trans_start = jiffies;
 
 	if (ring_put(r) == NULL) {
 		netif_stop_queue(ndev);
diff --git a/drivers/net/irda/w83977af_ir.c b/drivers/net/irda/w83977af_ir.c
index cb0cb75..1f9c3f0 100644
--- a/drivers/net/irda/w83977af_ir.c
+++ b/drivers/net/irda/w83977af_ir.c
@@ -515,7 +515,6 @@ static netdev_tx_t w83977af_hard_xmit(struct sk_buff *skb,
 		/* Check for empty frame */
 		if (!skb->len) {
 			w83977af_change_speed(self, speed); 
-			dev->trans_start = jiffies;
 			dev_kfree_skb(skb);
 			return NETDEV_TX_OK;
 		} else
@@ -549,7 +548,6 @@ static netdev_tx_t w83977af_hard_xmit(struct sk_buff *skb,
 		switch_bank(iobase, SET0);
 		outb(ICR_ETXTHI, iobase+ICR);
 	}
-	dev->trans_start = jiffies;
 	dev_kfree_skb(skb);
 
 	/* Restore set register */
diff --git a/drivers/net/ixgbevf/ixgbevf_main.c b/drivers/net/ixgbevf/ixgbevf_main.c
index 460c37f..40f47b8 100644
--- a/drivers/net/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ixgbevf/ixgbevf_main.c
@@ -3184,8 +3184,6 @@ static int ixgbevf_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 			 ixgbevf_tx_map(adapter, tx_ring, skb, tx_flags, first),
 			 skb->len, hdr_len);
 
-	netdev->trans_start = jiffies;
-
 	ixgbevf_maybe_stop_tx(netdev, tx_ring, DESC_NEEDED);
 
 	return NETDEV_TX_OK;
diff --git a/drivers/net/ixp2000/ixpdev.c b/drivers/net/ixp2000/ixpdev.c
index d5932ca..78ddd8b 100644
--- a/drivers/net/ixp2000/ixpdev.c
+++ b/drivers/net/ixp2000/ixpdev.c
@@ -64,8 +64,6 @@ static int ixpdev_xmit(struct sk_buff *skb, struct net_device *dev)
 	ixp2000_reg_write(RING_TX_PENDING,
 		TX_BUF_DESC_BASE + (entry * sizeof(struct ixpdev_tx_desc)));
 
-	dev->trans_start = jiffies;
-
 	local_irq_save(flags);
 	ip->tx_queue_entries++;
 	if (ip->tx_queue_entries == TX_BUF_COUNT_PER_CHAN)
diff --git a/drivers/net/lance.c b/drivers/net/lance.c
index 7b94476..21f8ada 100644
--- a/drivers/net/lance.c
+++ b/drivers/net/lance.c
@@ -945,7 +945,7 @@ static void lance_tx_timeout (struct net_device *dev)
 #endif
 	lance_restart (dev, 0x0043, 1);
 
-	dev->trans_start = jiffies;
+	dev->trans_start = jiffies; /* prevent tx timeout */
 	netif_wake_queue (dev);
 }
 
@@ -1011,8 +1011,6 @@ static netdev_tx_t lance_start_xmit(struct sk_buff *skb,
 	outw(0x0000, ioaddr+LANCE_ADDR);
 	outw(0x0048, ioaddr+LANCE_DATA);
 
-	dev->trans_start = jiffies;
-
 	if ((lp->cur_tx - lp->dirty_tx) >= TX_RING_SIZE)
 		netif_stop_queue(dev);
 
diff --git a/drivers/net/lib82596.c b/drivers/net/lib82596.c
index 61c38ab..de856d8 100644
--- a/drivers/net/lib82596.c
+++ b/drivers/net/lib82596.c
@@ -963,7 +963,7 @@ static void i596_tx_timeout (struct net_device *dev)
 		lp->last_restart = dev->stats.tx_packets;
 	}
 
-	dev->trans_start = jiffies;
+	dev->trans_start = jiffies; /* prevent tx timeout */
 	netif_wake_queue (dev);
 }
 
@@ -974,7 +974,6 @@ static int i596_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	struct tx_cmd *tx_cmd;
 	struct i596_tbd *tbd;
 	short length = skb->len;
-	dev->trans_start = jiffies;
 
 	DEB(DEB_STARTTX, printk(KERN_DEBUG
 				"%s: i596_start_xmit(%x,%p) called\n",
diff --git a/drivers/net/lib8390.c b/drivers/net/lib8390.c
index 770b606..64d51d6 100644
--- a/drivers/net/lib8390.c
+++ b/drivers/net/lib8390.c
@@ -257,7 +257,7 @@ static void __ei_tx_timeout(struct net_device *dev)
 {
 	unsigned long e8390_base = dev->base_addr;
 	struct ei_device *ei_local = (struct ei_device *) netdev_priv(dev);
-	int txsr, isr, tickssofar = jiffies - dev->trans_start;
+	int txsr, isr, tickssofar = jiffies - dev_trans_start(dev);
 	unsigned long flags;
 
 	dev->stats.tx_errors++;
@@ -386,7 +386,6 @@ static netdev_tx_t __ei_start_xmit(struct sk_buff *skb,
 	{
 		ei_local->txing = 1;
 		NS8390_trigger_send(dev, send_length, output_page);
-		dev->trans_start = jiffies;
 		if (output_page == ei_local->tx_start_page)
 		{
 			ei_local->tx1 = -1;
diff --git a/drivers/net/ll_temac_main.c b/drivers/net/ll_temac_main.c
index 78c9a2e..b59b24d 100644
--- a/drivers/net/ll_temac_main.c
+++ b/drivers/net/ll_temac_main.c
@@ -527,7 +527,7 @@ static void temac_device_reset(struct net_device *ndev)
 		dev_err(&ndev->dev, "Error setting TEMAC options\n");
 
 	/* Init Driver variable */
-	ndev->trans_start = 0;
+	ndev->trans_start = jiffies; /* prevent tx timeout */
 }
 
 void temac_adjust_link(struct net_device *ndev)
diff --git a/drivers/net/lp486e.c b/drivers/net/lp486e.c
index 72379c5..3df046a 100644
--- a/drivers/net/lp486e.c
+++ b/drivers/net/lp486e.c
@@ -875,8 +875,6 @@ static netdev_tx_t i596_start_xmit (struct sk_buff *skb, struct net_device *dev)
 		length = ETH_ZLEN;
 	}
 
-	dev->trans_start = jiffies;
-
 	tx_cmd = kmalloc((sizeof (struct tx_cmd) + sizeof (struct i596_tbd)), GFP_ATOMIC);
 	if (tx_cmd == NULL) {
 		printk(KERN_WARNING "%s: i596_xmit Memory squeeze, dropping packet.\n", dev->name);
diff --git a/drivers/net/mac89x0.c b/drivers/net/mac89x0.c
index c0876e9..69fa4ef 100644
--- a/drivers/net/mac89x0.c
+++ b/drivers/net/mac89x0.c
@@ -408,7 +408,6 @@ net_send_packet(struct sk_buff *skb, struct net_device *dev)
 				  skb->len+1);
 
 	local_irq_restore(flags);
-	dev->trans_start = jiffies;
 	dev_kfree_skb (skb);
 
 	return NETDEV_TX_OK;
diff --git a/drivers/net/macb.c b/drivers/net/macb.c
index cf7debc..40797fb 100644
--- a/drivers/net/macb.c
+++ b/drivers/net/macb.c
@@ -666,8 +666,6 @@ static int macb_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	spin_unlock_irqrestore(&bp->lock, flags);
 
-	dev->trans_start = jiffies;
-
 	return NETDEV_TX_OK;
 }
 
diff --git a/drivers/net/macmace.c b/drivers/net/macmace.c
index a6e19fc..c685a46 100644
--- a/drivers/net/macmace.c
+++ b/drivers/net/macmace.c
@@ -488,7 +488,6 @@ static int mace_xmit_start(struct sk_buff *skb, struct net_device *dev)
 
 	dev_kfree_skb(skb);
 
-	dev->trans_start = jiffies;
 	return NETDEV_TX_OK;
 }
 
diff --git a/drivers/net/meth.c b/drivers/net/meth.c
index 9f72cb4..16a3594 100644
--- a/drivers/net/meth.c
+++ b/drivers/net/meth.c
@@ -746,7 +746,7 @@ static void meth_tx_timeout(struct net_device *dev)
 	/* Enable interrupt */
 	spin_unlock_irqrestore(&priv->meth_lock, flags);
 
-	dev->trans_start = jiffies;
+	dev->trans_start = jiffies; /* prevent tx timeout */
 	netif_wake_queue(dev);
 
 	return;
diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index 4ee9d04..1f724e5 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -882,7 +882,6 @@ static netdev_tx_t mv643xx_eth_xmit(struct sk_buff *skb, struct net_device *dev)
 
 		txq->tx_bytes += skb->len;
 		txq->tx_packets++;
-		dev->trans_start = jiffies;
 
 		entries_left = txq->tx_ring_size - txq->tx_desc_count;
 		if (entries_left < MAX_SKB_FRAGS + 1)
diff --git a/drivers/net/natsemi.c b/drivers/net/natsemi.c
index 9250bf6..2a17b50 100644
--- a/drivers/net/natsemi.c
+++ b/drivers/net/natsemi.c
@@ -1905,7 +1905,7 @@ static void ns_tx_timeout(struct net_device *dev)
 	spin_unlock_irq(&np->lock);
 	enable_irq(dev->irq);
 
-	dev->trans_start = jiffies;
+	dev->trans_start = jiffies; /* prevent tx timeout */
 	np->stats.tx_errors++;
 	netif_wake_queue(dev);
 }
@@ -2119,8 +2119,6 @@ static netdev_tx_t start_tx(struct sk_buff *skb, struct net_device *dev)
 	}
 	spin_unlock_irqrestore(&np->lock, flags);
 
-	dev->trans_start = jiffies;
-
 	if (netif_msg_tx_queued(np)) {
 		printk(KERN_DEBUG "%s: Transmit frame #%d queued in slot %d.\n",
 			dev->name, np->cur_tx, entry);
diff --git a/drivers/net/netx-eth.c b/drivers/net/netx-eth.c
index 6477029..2e4b421 100644
--- a/drivers/net/netx-eth.c
+++ b/drivers/net/netx-eth.c
@@ -126,7 +126,6 @@ netx_eth_hard_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 	           FIFO_PTR_FRAMENO(1) |
 	           FIFO_PTR_FRAMELEN(len));
 
-	ndev->trans_start = jiffies;
 	ndev->stats.tx_packets++;
 	ndev->stats.tx_bytes += skb->len;
 
diff --git a/drivers/net/ni5010.c b/drivers/net/ni5010.c
index 3892330..f80b501 100644
--- a/drivers/net/ni5010.c
+++ b/drivers/net/ni5010.c
@@ -444,7 +444,7 @@ static void ni5010_timeout(struct net_device *dev)
 	/* Try to restart the adaptor. */
 	/* FIXME: Give it a real kick here */
 	chipset_init(dev, 1);
-	dev->trans_start = jiffies;
+	dev->trans_start = jiffies; /* prevent tx timeout */
 	netif_wake_queue(dev);
 }
 
@@ -460,7 +460,6 @@ static int ni5010_send_packet(struct sk_buff *skb, struct net_device *dev)
 
 	netif_stop_queue(dev);
 	hardware_send_packet(dev, (unsigned char *)skb->data, skb->len, length-skb->len);
-	dev->trans_start = jiffies;
 	dev_kfree_skb (skb);
 	return NETDEV_TX_OK;
 }
diff --git a/drivers/net/ni52.c b/drivers/net/ni52.c
index b7837eb..9bddb5f 100644
--- a/drivers/net/ni52.c
+++ b/drivers/net/ni52.c
@@ -1147,7 +1147,7 @@ static void ni52_timeout(struct net_device *dev)
 		writeb(CUC_START, &p->scb->cmd_cuc);
 		ni_attn586();
 		wait_for_scb_cmd(dev);
-		dev->trans_start = jiffies;
+		dev->trans_start = jiffies; /* prevent tx timeout */
 		return 0;
 	}
 #endif
@@ -1165,7 +1165,7 @@ static void ni52_timeout(struct net_device *dev)
 		ni52_close(dev);
 		ni52_open(dev);
 	}
-	dev->trans_start = jiffies;
+	dev->trans_start = jiffies; /* prevent tx timeout */
 }
 
 /******************************************************
@@ -1218,7 +1218,6 @@ static netdev_tx_t ni52_send_packet(struct sk_buff *skb,
 			writeb(CUC_START, &p->scb->cmd_cuc);
 		}
 		ni_attn586();
-		dev->trans_start = jiffies;
 		if (!i)
 			dev_kfree_skb(skb);
 		wait_for_scb_cmd(dev);
@@ -1240,7 +1239,6 @@ static netdev_tx_t ni52_send_packet(struct sk_buff *skb,
 	writew(0, &p->nop_cmds[next_nop]->cmd_status);
 
 	writew(make16(p->xmit_cmds[0]), &p->nop_cmds[p->nop_point]->cmd_link);
-	dev->trans_start = jiffies;
 	p->nop_point = next_nop;
 	dev_kfree_skb(skb);
 #	endif
@@ -1256,7 +1254,6 @@ static netdev_tx_t ni52_send_packet(struct sk_buff *skb,
 	writew(0, &p->nop_cmds[next_nop]->cmd_status);
 	writew(make16(p->xmit_cmds[p->xmit_count]),
 				&p->nop_cmds[p->xmit_count]->cmd_link);
-	dev->trans_start = jiffies;
 	p->xmit_count = next_nop;
 	{
 		unsigned long flags;
diff --git a/drivers/net/ni65.c b/drivers/net/ni65.c
index 9225c76..da228a0 100644
--- a/drivers/net/ni65.c
+++ b/drivers/net/ni65.c
@@ -784,7 +784,7 @@ static void ni65_stop_start(struct net_device *dev,struct priv *p)
 		if(!p->lock)
 			if (p->tmdnum || !p->xmit_queued)
 				netif_wake_queue(dev);
-		dev->trans_start = jiffies;
+		dev->trans_start = jiffies; /* prevent tx timeout */
 	}
 	else
 		writedatareg(CSR0_STRT | csr0);
@@ -1150,7 +1150,7 @@ static void ni65_timeout(struct net_device *dev)
 		printk("%02x ",p->tmdhead[i].u.s.status);
 	printk("\n");
 	ni65_lance_reinit(dev);
-	dev->trans_start = jiffies;
+	dev->trans_start = jiffies; /* prevent tx timeout */
 	netif_wake_queue(dev);
 }
 
@@ -1213,7 +1213,6 @@ static netdev_tx_t ni65_send_packet(struct sk_buff *skb,
 			netif_wake_queue(dev);
 
 		p->lock = 0;
-		dev->trans_start = jiffies;
 
 		spin_unlock_irqrestore(&p->ring_lock, flags);
 	}
diff --git a/drivers/net/octeon/octeon_mgmt.c b/drivers/net/octeon/octeon_mgmt.c
index 3924703..43bf26f 100644
--- a/drivers/net/octeon/octeon_mgmt.c
+++ b/drivers/net/octeon/octeon_mgmt.c
@@ -992,7 +992,6 @@ static int octeon_mgmt_xmit(struct sk_buff *skb, struct net_device *netdev)
 	/* Ring the bell.  */
 	cvmx_write_csr(CVMX_MIXX_ORING2(port), 1);
 
-	netdev->trans_start = jiffies;
 	rv = NETDEV_TX_OK;
 out:
 	octeon_mgmt_update_tx_stats(netdev);
diff --git a/drivers/net/pci-skeleton.c b/drivers/net/pci-skeleton.c
index dc3b4c7..56f3fc4 100644
--- a/drivers/net/pci-skeleton.c
+++ b/drivers/net/pci-skeleton.c
@@ -1354,7 +1354,6 @@ static int netdrv_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	NETDRV_W32(TxStatus0 + (entry * sizeof(u32)),
 		   tp->tx_flag | (skb->len >= ETH_ZLEN ? skb->len : ETH_ZLEN));
 
-	dev->trans_start = jiffies;
 	atomic_inc(&tp->cur_tx);
 	if ((atomic_read(&tp->cur_tx) - atomic_read(&tp->dirty_tx)) >= NUM_TX_DESC)
 		netif_stop_queue(dev);
diff --git a/drivers/net/pcmcia/3c574_cs.c b/drivers/net/pcmcia/3c574_cs.c
index 757f87b..b6d9313 100644
--- a/drivers/net/pcmcia/3c574_cs.c
+++ b/drivers/net/pcmcia/3c574_cs.c
@@ -739,7 +739,7 @@ static void el3_tx_timeout(struct net_device *dev)
 	printk(KERN_NOTICE "%s: Transmit timed out!\n", dev->name);
 	dump_status(dev);
 	dev->stats.tx_errors++;
-	dev->trans_start = jiffies;
+	dev->trans_start = jiffies; /* prevent tx timeout */
 	/* Issue TX_RESET and TX_START commands. */
 	tc574_wait_for_completion(dev, TxReset);
 	outw(TxEnable, ioaddr + EL3_CMD);
@@ -790,8 +790,6 @@ static netdev_tx_t el3_start_xmit(struct sk_buff *skb,
 	/* ... and the packet rounded to a doubleword. */
 	outsl(ioaddr + TX_FIFO, skb->data, (skb->len+3)>>2);
 
-	dev->trans_start = jiffies;
-
 	/* TxFree appears only in Window 1, not offset 0x1c. */
 	if (inw(ioaddr + TxFree) <= 1536) {
 		netif_stop_queue(dev);
diff --git a/drivers/net/pcmcia/3c589_cs.c b/drivers/net/pcmcia/3c589_cs.c
index 580977f..d6a459d 100644
--- a/drivers/net/pcmcia/3c589_cs.c
+++ b/drivers/net/pcmcia/3c589_cs.c
@@ -563,7 +563,7 @@ static void el3_tx_timeout(struct net_device *dev)
     netdev_warn(dev, "Transmit timed out!\n");
     dump_status(dev);
     dev->stats.tx_errors++;
-    dev->trans_start = jiffies;
+    dev->trans_start = jiffies; /* prevent tx timeout */
     /* Issue TX_RESET and TX_START commands. */
     tc589_wait_for_completion(dev, TxReset);
     outw(TxEnable, ioaddr + EL3_CMD);
@@ -611,7 +611,6 @@ static netdev_tx_t el3_start_xmit(struct sk_buff *skb,
     /* ... and the packet rounded to a doubleword. */
     outsl(ioaddr + TX_FIFO, skb->data, (skb->len + 3) >> 2);
 
-    dev->trans_start = jiffies;
     if (inw(ioaddr + TX_FREE) <= 1536) {
 	netif_stop_queue(dev);
 	/* Interrupt us when the FIFO has room for max-sized packet. */
diff --git a/drivers/net/pcmcia/axnet_cs.c b/drivers/net/pcmcia/axnet_cs.c
index 70fc959..a1a6b08 100644
--- a/drivers/net/pcmcia/axnet_cs.c
+++ b/drivers/net/pcmcia/axnet_cs.c
@@ -1005,7 +1005,7 @@ static void axnet_tx_timeout(struct net_device *dev)
 {
 	long e8390_base = dev->base_addr;
 	struct ei_device *ei_local = (struct ei_device *) netdev_priv(dev);
-	int txsr, isr, tickssofar = jiffies - dev->trans_start;
+	int txsr, isr, tickssofar = jiffies - dev_trans_start(dev);
 	unsigned long flags;
 
 	dev->stats.tx_errors++;
diff --git a/drivers/net/pcmcia/fmvj18x_cs.c b/drivers/net/pcmcia/fmvj18x_cs.c
index 6734f7d..16fc3e5 100644
--- a/drivers/net/pcmcia/fmvj18x_cs.c
+++ b/drivers/net/pcmcia/fmvj18x_cs.c
@@ -890,7 +890,6 @@ static netdev_tx_t fjn_start_xmit(struct sk_buff *skb,
 	    lp->sent = lp->tx_queue ;
 	    lp->tx_queue = 0;
 	    lp->tx_queue_len = 0;
-	    dev->trans_start = jiffies;
 	    lp->tx_started = 1;
 	    netif_start_queue(dev);
 	} else {
diff --git a/drivers/net/pcmcia/nmclan_cs.c b/drivers/net/pcmcia/nmclan_cs.c
index c516c19..ca4efd2 100644
--- a/drivers/net/pcmcia/nmclan_cs.c
+++ b/drivers/net/pcmcia/nmclan_cs.c
@@ -903,7 +903,7 @@ static void mace_tx_timeout(struct net_device *dev)
 #else /* #if RESET_ON_TIMEOUT */
   printk("NOT resetting card\n");
 #endif /* #if RESET_ON_TIMEOUT */
-  dev->trans_start = jiffies;
+  dev->trans_start = jiffies; /* prevent tx timeout */
   netif_wake_queue(dev);
 }
 
@@ -945,8 +945,6 @@ static netdev_tx_t mace_start_xmit(struct sk_buff *skb,
       outb(skb->data[skb->len-1], ioaddr + AM2150_XMT);
     }
 
-    dev->trans_start = jiffies;
-
 #if MULTI_TX
     if (lp->tx_free_frames > 0)
       netif_start_queue(dev);
diff --git a/drivers/net/pcmcia/smc91c92_cs.c b/drivers/net/pcmcia/smc91c92_cs.c
index 949ac1a..b5c62db 100644
--- a/drivers/net/pcmcia/smc91c92_cs.c
+++ b/drivers/net/pcmcia/smc91c92_cs.c
@@ -1254,7 +1254,7 @@ static void smc_tx_timeout(struct net_device *dev)
 	   dev->name, inw(ioaddr)&0xff, inw(ioaddr + 2));
     dev->stats.tx_errors++;
     smc_reset(dev);
-    dev->trans_start = jiffies;
+    dev->trans_start = jiffies; /* prevent tx timeout */
     smc->saved_skb = NULL;
     netif_wake_queue(dev);
 }
diff --git a/drivers/net/pcmcia/xirc2ps_cs.c b/drivers/net/pcmcia/xirc2ps_cs.c
index 656be93..6622f04 100644
--- a/drivers/net/pcmcia/xirc2ps_cs.c
+++ b/drivers/net/pcmcia/xirc2ps_cs.c
@@ -1295,7 +1295,7 @@ xirc2ps_tx_timeout_task(struct work_struct *work)
 	struct net_device *dev = local->dev;
     /* reset the card */
     do_reset(dev,1);
-    dev->trans_start = jiffies;
+    dev->trans_start = jiffies; /* prevent tx timeout */
     netif_wake_queue(dev);
 }
 
@@ -1358,7 +1358,6 @@ do_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	PutByte(XIRCREG_CR, TransmitPacket|EnableIntr);
 
     dev_kfree_skb (skb);
-    dev->trans_start = jiffies;
     dev->stats.tx_bytes += pktlen;
     netif_start_queue(dev);
     return NETDEV_TX_OK;
diff --git a/drivers/net/pcnet32.c b/drivers/net/pcnet32.c
index a2254f7..566fd89 100644
--- a/drivers/net/pcnet32.c
+++ b/drivers/net/pcnet32.c
@@ -448,7 +448,7 @@ static void pcnet32_netif_stop(struct net_device *dev)
 {
 	struct pcnet32_private *lp = netdev_priv(dev);
 
-	dev->trans_start = jiffies;
+	dev->trans_start = jiffies; /* prevent tx timeout */
 	napi_disable(&lp->napi);
 	netif_tx_disable(dev);
 }
@@ -2398,7 +2398,7 @@ static void pcnet32_tx_timeout(struct net_device *dev)
 	}
 	pcnet32_restart(dev, CSR0_NORMAL);
 
-	dev->trans_start = jiffies;
+	dev->trans_start = jiffies; /* prevent tx timeout */
 	netif_wake_queue(dev);
 
 	spin_unlock_irqrestore(&lp->lock, flags);
@@ -2449,8 +2449,6 @@ static netdev_tx_t pcnet32_start_xmit(struct sk_buff *skb,
 	/* Trigger an immediate send poll. */
 	lp->a.write_csr(ioaddr, CSR0, CSR0_INTEN | CSR0_TXPOLL);
 
-	dev->trans_start = jiffies;
-
 	if (lp->tx_ring[(entry + 1) & lp->tx_mod_mask].base != 0) {
 		lp->tx_full = 1;
 		netif_stop_queue(dev);
diff --git a/drivers/net/plip.c b/drivers/net/plip.c
index 9a2103a..f4e1f9a 100644
--- a/drivers/net/plip.c
+++ b/drivers/net/plip.c
@@ -979,7 +979,6 @@ plip_tx_packet(struct sk_buff *skb, struct net_device *dev)
 		printk(KERN_DEBUG "%s: send request\n", dev->name);
 
 	spin_lock_irq(&nl->lock);
-	dev->trans_start = jiffies;
 	snd->skb = skb;
 	snd->length.h = skb->len;
 	snd->state = PLIP_PK_TRIGGER;
diff --git a/drivers/net/ps3_gelic_net.c b/drivers/net/ps3_gelic_net.c
index 022317d..87d6b8f 100644
--- a/drivers/net/ps3_gelic_net.c
+++ b/drivers/net/ps3_gelic_net.c
@@ -903,9 +903,6 @@ int gelic_net_xmit(struct sk_buff *skb, struct net_device *netdev)
 		gelic_descr_release_tx(card, descr->next);
 		card->tx_chain.tail = descr->next->next;
 		dev_info(ctodev(card), "%s: kick failure\n", __func__);
-	} else {
-		/* OK, DMA started/reserved */
-		netdev->trans_start = jiffies;
 	}
 
 	spin_unlock_irqrestore(&card->tx_lock, flags);
diff --git a/drivers/net/r6040.c b/drivers/net/r6040.c
index 4122916..3cc7bef 100644
--- a/drivers/net/r6040.c
+++ b/drivers/net/r6040.c
@@ -924,7 +924,6 @@ static netdev_tx_t r6040_start_xmit(struct sk_buff *skb,
 	if (!lp->tx_free_desc)
 		netif_stop_queue(dev);
 
-	dev->trans_start = jiffies;
 	spin_unlock_irqrestore(&lp->lock, flags);
 
 	return NETDEV_TX_OK;
diff --git a/drivers/net/rrunner.c b/drivers/net/rrunner.c
index f2e335f..e26e107 100644
--- a/drivers/net/rrunner.c
+++ b/drivers/net/rrunner.c
@@ -1467,7 +1467,6 @@ static netdev_tx_t rr_start_xmit(struct sk_buff *skb,
 
 	spin_unlock_irqrestore(&rrpriv->lock, flags);
 
-	dev->trans_start = jiffies;
 	return NETDEV_TX_OK;
 }
 
diff --git a/drivers/net/s6gmac.c b/drivers/net/s6gmac.c
index 6b12524..a7ff8ea 100644
--- a/drivers/net/s6gmac.c
+++ b/drivers/net/s6gmac.c
@@ -852,8 +852,8 @@ static int s6gmac_tx(struct sk_buff *skb, struct net_device *dev)
 {
 	struct s6gmac *pd = netdev_priv(dev);
 	unsigned long flags;
+
 	spin_lock_irqsave(&pd->lock, flags);
-	dev->trans_start = jiffies;
 	writel(skb->len << S6_GMAC_BURST_PREWR_LEN |
 		0 << S6_GMAC_BURST_PREWR_CFE |
 		1 << S6_GMAC_BURST_PREWR_PPE |
diff --git a/drivers/net/sb1250-mac.c b/drivers/net/sb1250-mac.c
index fec3c29..1f3acc3 100644
--- a/drivers/net/sb1250-mac.c
+++ b/drivers/net/sb1250-mac.c
@@ -2068,8 +2068,6 @@ static int sbmac_start_tx(struct sk_buff *skb, struct net_device *dev)
 		return NETDEV_TX_BUSY;
 	}
 
-	dev->trans_start = jiffies;
-
 	spin_unlock_irqrestore(&sc->sbm_lock, flags);
 
 	return NETDEV_TX_OK;
@@ -2488,7 +2486,7 @@ static void sbmac_tx_timeout (struct net_device *dev)
 	spin_lock_irqsave(&sc->sbm_lock, flags);
 
 
-	dev->trans_start = jiffies;
+	dev->trans_start = jiffies; /* prevent tx timeout */
 	dev->stats.tx_errors++;
 
 	spin_unlock_irqrestore(&sc->sbm_lock, flags);
diff --git a/drivers/net/sc92031.c b/drivers/net/sc92031.c
index 1b32605..8c4067a 100644
--- a/drivers/net/sc92031.c
+++ b/drivers/net/sc92031.c
@@ -987,8 +987,6 @@ static netdev_tx_t sc92031_start_xmit(struct sk_buff *skb,
 	iowrite32(tx_status, port_base + TxStatus0 + entry * 4);
 	mmiowb();
 
-	dev->trans_start = jiffies;
-
 	if (priv->tx_head - priv->tx_tail >= NUM_TX_DESC)
 		netif_stop_queue(dev);
 
diff --git a/drivers/net/seeq8005.c b/drivers/net/seeq8005.c
index 374832c..11ab32e 100644
--- a/drivers/net/seeq8005.c
+++ b/drivers/net/seeq8005.c
@@ -390,7 +390,7 @@ static void seeq8005_timeout(struct net_device *dev)
 		   tx_done(dev) ? "IRQ conflict" : "network cable problem");
 	/* Try to restart the adaptor. */
 	seeq8005_init(dev, 1);
-	dev->trans_start = jiffies;
+	dev->trans_start = jiffies; /* prevent tx timeout */
 	netif_wake_queue(dev);
 }
 
@@ -411,7 +411,6 @@ static netdev_tx_t seeq8005_send_packet(struct sk_buff *skb,
 	netif_stop_queue(dev);
 
 	hardware_send_packet(dev, buf, length);
-	dev->trans_start = jiffies;
 	dev->stats.tx_bytes += length;
 	dev_kfree_skb (skb);
 	/* You might need to clean up and record Tx statistics here. */
diff --git a/drivers/net/sgiseeq.c b/drivers/net/sgiseeq.c
index c8fc896..cc4bd8c 100644
--- a/drivers/net/sgiseeq.c
+++ b/drivers/net/sgiseeq.c
@@ -574,7 +574,7 @@ static inline int sgiseeq_reset(struct net_device *dev)
 	if (err)
 		return err;
 
-	dev->trans_start = jiffies;
+	dev->trans_start = jiffies; /* prevent tx timeout */
 	netif_wake_queue(dev);
 
 	return 0;
@@ -638,8 +638,6 @@ static int sgiseeq_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (!(hregs->tx_ctrl & HPC3_ETXCTRL_ACTIVE))
 		kick_tx(dev, sp, hregs);
 
-	dev->trans_start = jiffies;
-
 	if (!TX_BUFFS_AVAIL(sp))
 		netif_stop_queue(dev);
 	spin_unlock_irqrestore(&sp->tx_lock, flags);
@@ -652,7 +650,7 @@ static void timeout(struct net_device *dev)
 	printk(KERN_NOTICE "%s: transmit timed out, resetting\n", dev->name);
 	sgiseeq_reset(dev);
 
-	dev->trans_start = jiffies;
+	dev->trans_start = jiffies; /* prevent tx timeout */
 	netif_wake_queue(dev);
 }
 
diff --git a/drivers/net/sh_eth.c b/drivers/net/sh_eth.c
index 6242b85..586ed09 100644
--- a/drivers/net/sh_eth.c
+++ b/drivers/net/sh_eth.c
@@ -1148,8 +1148,6 @@ static int sh_eth_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 	if (!(ctrl_inl(ndev->base_addr + EDTRR) & EDTRR_TRNS))
 		ctrl_outl(EDTRR_TRNS, ndev->base_addr + EDTRR);
 
-	ndev->trans_start = jiffies;
-
 	return NETDEV_TX_OK;
 }
 
diff --git a/drivers/net/sis900.c b/drivers/net/sis900.c
index 6293592..11f7ebe 100644
--- a/drivers/net/sis900.c
+++ b/drivers/net/sis900.c
@@ -1553,7 +1553,7 @@ static void sis900_tx_timeout(struct net_device *net_dev)
 
 	spin_unlock_irqrestore(&sis_priv->lock, flags);
 
-	net_dev->trans_start = jiffies;
+	net_dev->trans_start = jiffies; /* prevent tx timeout */
 
 	/* load Transmit Descriptor Register */
 	outl(sis_priv->tx_ring_dma, ioaddr + txdp);
@@ -1623,8 +1623,6 @@ sis900_start_xmit(struct sk_buff *skb, struct net_device *net_dev)
 
 	spin_unlock_irqrestore(&sis_priv->lock, flags);
 
-	net_dev->trans_start = jiffies;
-
 	if (netif_msg_tx_queued(sis_priv))
 		printk(KERN_DEBUG "%s: Queued Tx packet at %p size %d "
 		       "to slot %d.\n",
diff --git a/drivers/net/skfp/skfddi.c b/drivers/net/skfp/skfddi.c
index 7912606..91adc38 100644
--- a/drivers/net/skfp/skfddi.c
+++ b/drivers/net/skfp/skfddi.c
@@ -1076,7 +1076,6 @@ static netdev_tx_t skfp_send_pkt(struct sk_buff *skb,
 	if (bp->QueueSkb == 0) {
 		netif_stop_queue(dev);
 	}
-	dev->trans_start = jiffies;
 	return NETDEV_TX_OK;
 
 }				// skfp_send_pkt
diff --git a/drivers/net/slip.c b/drivers/net/slip.c
index 8969615..d92772e 100644
--- a/drivers/net/slip.c
+++ b/drivers/net/slip.c
@@ -458,7 +458,7 @@ static void sl_tx_timeout(struct net_device *dev)
 		 *      14 Oct 1994 Dmitry Gorodchanin.
 		 */
 #ifdef SL_CHECK_TRANSMIT
-		if (time_before(jiffies, dev->trans_start + 20 * HZ))  {
+		if (time_before(jiffies, dev_trans_start(dev) + 20 * HZ))  {
 			/* 20 sec timeout not reached */
 			goto out;
 		}
diff --git a/drivers/net/smc911x.c b/drivers/net/smc911x.c
index 1e49fcf..66831f3 100644
--- a/drivers/net/smc911x.c
+++ b/drivers/net/smc911x.c
@@ -1289,7 +1289,7 @@ static void smc911x_timeout(struct net_device *dev)
 		schedule_work(&lp->phy_configure);
 
 	/* We can accept TX packets again */
-	dev->trans_start = jiffies;
+	dev->trans_start = jiffies; /* prevent tx timeout */
 	netif_wake_queue(dev);
 }
 
diff --git a/drivers/net/smc9194.c b/drivers/net/smc9194.c
index d76c815..acb81a8 100644
--- a/drivers/net/smc9194.c
+++ b/drivers/net/smc9194.c
@@ -1164,7 +1164,7 @@ static void smc_timeout(struct net_device *dev)
 	/* "kick" the adaptor */
 	smc_reset( dev->base_addr );
 	smc_enable( dev->base_addr );
-	dev->trans_start = jiffies;
+	dev->trans_start = jiffies; /* prevent tx timeout */
 	/* clear anything saved */
 	((struct smc_local *)netdev_priv(dev))->saved_skb = NULL;
 	netif_wake_queue(dev);
diff --git a/drivers/net/smc91x.c b/drivers/net/smc91x.c
index 682bc4f..10cf0cb 100644
--- a/drivers/net/smc91x.c
+++ b/drivers/net/smc91x.c
@@ -1360,7 +1360,7 @@ static void smc_timeout(struct net_device *dev)
 		schedule_work(&lp->phy_configure);
 
 	/* We can accept TX packets again */
-	dev->trans_start = jiffies;
+	dev->trans_start = jiffies; /* prevent tx timeout */
 	netif_wake_queue(dev);
 }
 
diff --git a/drivers/net/smsc911x.c b/drivers/net/smsc911x.c
index 746fb91..89f35f9 100644
--- a/drivers/net/smsc911x.c
+++ b/drivers/net/smsc911x.c
@@ -1335,7 +1335,6 @@ static int smsc911x_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	smsc911x_tx_writefifo(pdata, (unsigned int *)bufp, wrsz);
 	freespace -= (skb->len + 32);
 	dev_kfree_skb(skb);
-	dev->trans_start = jiffies;
 
 	if (unlikely(smsc911x_tx_get_txstatcount(pdata) >= 30))
 		smsc911x_tx_update_txcounters(dev);
diff --git a/drivers/net/smsc9420.c b/drivers/net/smsc9420.c
index ada05c4..6cdee6a 100644
--- a/drivers/net/smsc9420.c
+++ b/drivers/net/smsc9420.c
@@ -1034,8 +1034,6 @@ static netdev_tx_t smsc9420_hard_start_xmit(struct sk_buff *skb,
 	smsc9420_reg_write(pd, TX_POLL_DEMAND, 1);
 	smsc9420_pci_flush_write(pd);
 
-	dev->trans_start = jiffies;
-
 	return NETDEV_TX_OK;
 }
 
diff --git a/drivers/net/sonic.c b/drivers/net/sonic.c
index e5d6732..26e25d7 100644
--- a/drivers/net/sonic.c
+++ b/drivers/net/sonic.c
@@ -174,7 +174,7 @@ static void sonic_tx_timeout(struct net_device *dev)
 	/* Try to restart the adaptor. */
 	sonic_init(dev);
 	lp->stats.tx_errors++;
-	dev->trans_start = jiffies;
+	dev->trans_start = jiffies; /* prevent tx timeout */
 	netif_wake_queue(dev);
 }
 
@@ -263,8 +263,6 @@ static int sonic_send_packet(struct sk_buff *skb, struct net_device *dev)
 
 	SONIC_WRITE(SONIC_CMD, SONIC_CR_TXP);
 
-	dev->trans_start = jiffies;
-
 	return NETDEV_TX_OK;
 }
 
diff --git a/drivers/net/starfire.c b/drivers/net/starfire.c
index 8a6d27c..e19b5a1 100644
--- a/drivers/net/starfire.c
+++ b/drivers/net/starfire.c
@@ -1173,7 +1173,7 @@ static void tx_timeout(struct net_device *dev)
 
 	/* Trigger an immediate transmit demand. */
 
-	dev->trans_start = jiffies;
+	dev->trans_start = jiffies; /* prevent tx timeout */
 	np->stats.tx_errors++;
 	netif_wake_queue(dev);
 }
@@ -1312,8 +1312,6 @@ static netdev_tx_t start_tx(struct sk_buff *skb, struct net_device *dev)
 	if ((np->cur_tx - np->dirty_tx) + 4 > TX_RING_SIZE)
 		netif_stop_queue(dev);
 
-	dev->trans_start = jiffies;
-
 	return NETDEV_TX_OK;
 }
 
diff --git a/drivers/net/sun3_82586.c b/drivers/net/sun3_82586.c
index 31ab4ab..1513123 100644
--- a/drivers/net/sun3_82586.c
+++ b/drivers/net/sun3_82586.c
@@ -985,7 +985,7 @@ static void sun3_82586_timeout(struct net_device *dev)
 		p->scb->cmd_cuc = CUC_START;
 		sun3_attn586();
 		WAIT_4_SCB_CMD();
-		dev->trans_start = jiffies;
+		dev->trans_start = jiffies; /* prevent tx timeout */
 		return 0;
 	}
 #endif
@@ -998,7 +998,7 @@ static void sun3_82586_timeout(struct net_device *dev)
 		sun3_82586_close(dev);
 		sun3_82586_open(dev);
 	}
-	dev->trans_start = jiffies;
+	dev->trans_start = jiffies; /* prevent tx timeout */
 }
 
 /******************************************************
@@ -1062,7 +1062,6 @@ static int sun3_82586_send_packet(struct sk_buff *skb, struct net_device *dev)
 			}
 
 			sun3_attn586();
-			dev->trans_start = jiffies;
 			if(!i)
 				dev_kfree_skb(skb);
 			WAIT_4_SCB_CMD();
@@ -1082,7 +1081,6 @@ static int sun3_82586_send_packet(struct sk_buff *skb, struct net_device *dev)
 		p->xmit_cmds[0]->cmd_status = p->nop_cmds[next_nop]->cmd_status = 0;
 
 		p->nop_cmds[p->nop_point]->cmd_link = make16((p->xmit_cmds[0]));
-		dev->trans_start = jiffies;
 		p->nop_point = next_nop;
 		dev_kfree_skb(skb);
 #	endif
@@ -1097,7 +1095,6 @@ static int sun3_82586_send_packet(struct sk_buff *skb, struct net_device *dev)
 		p->nop_cmds[next_nop]->cmd_status = 0;
 
 		p->nop_cmds[p->xmit_count]->cmd_link = make16((p->xmit_cmds[p->xmit_count]));
-		dev->trans_start = jiffies;
 		p->xmit_count = next_nop;
 
 		{
diff --git a/drivers/net/sun3lance.c b/drivers/net/sun3lance.c
index 1694ca5..358c22f 100644
--- a/drivers/net/sun3lance.c
+++ b/drivers/net/sun3lance.c
@@ -523,8 +523,8 @@ static int lance_start_xmit( struct sk_buff *skb, struct net_device *dev )
 
 	/* Transmitter timeout, serious problems. */
 	if (netif_queue_stopped(dev)) {
-		int tickssofar = jiffies - dev->trans_start;
-		if (tickssofar < 20)
+		int tickssofar = jiffies - dev_trans_start(dev);
+		if (tickssofar < HZ/5)
 			return NETDEV_TX_BUSY;
 
 		DPRINTK( 1, ( "%s: transmit timed out, status %04x, resetting.\n",
@@ -559,7 +559,6 @@ static int lance_start_xmit( struct sk_buff *skb, struct net_device *dev )
 		REGA( CSR0 ) = CSR0_INEA | CSR0_INIT | CSR0_STRT;
 
 		netif_start_queue(dev);
-		dev->trans_start = jiffies;
 
 		return NETDEV_TX_OK;
 	}
@@ -637,8 +636,7 @@ static int lance_start_xmit( struct sk_buff *skb, struct net_device *dev )
 	AREG = CSR0;
   	DPRINTK( 2, ( "%s: lance_start_xmit() exiting, csr0 %4.4x.\n",
   				  dev->name, DREG ));
-	dev->trans_start = jiffies;
-	dev_kfree_skb( skb );
+	dev_kfree_skb(skb);
 
 	lp->lock = 0;
 	if ((MEM->tx_head[(entry+1) & TX_RING_MOD_MASK].flag & TMD1_OWN) ==
diff --git a/drivers/net/sunbmac.c b/drivers/net/sunbmac.c
index 5291315..34446b6 100644
--- a/drivers/net/sunbmac.c
+++ b/drivers/net/sunbmac.c
@@ -982,8 +982,6 @@ static int bigmac_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	sbus_writel(CREG_CTRL_TWAKEUP, bp->creg + CREG_CTRL);
 
 
-	dev->trans_start = jiffies;
-
 	return NETDEV_TX_OK;
 }
 
diff --git a/drivers/net/sundance.c b/drivers/net/sundance.c
index da45f01..1680325 100644
--- a/drivers/net/sundance.c
+++ b/drivers/net/sundance.c
@@ -972,7 +972,7 @@ static void tx_timeout(struct net_device *dev)
 
 	dev->if_port = 0;
 
-	dev->trans_start = jiffies;
+	dev->trans_start = jiffies; /* prevent tx timeout */
 	dev->stats.tx_errors++;
 	if (np->cur_tx - np->dirty_tx < TX_QUEUE_LEN - 4) {
 		netif_wake_queue(dev);
@@ -1084,7 +1084,6 @@ start_tx (struct sk_buff *skb, struct net_device *dev)
 	} else {
 		netif_stop_queue (dev);
 	}
-	dev->trans_start = jiffies;
 	if (netif_msg_tx_queued(np)) {
 		printk (KERN_DEBUG
 			"%s: Transmit frame #%d queued in slot %d.\n",
diff --git a/drivers/net/sungem.c b/drivers/net/sungem.c
index 2b78e97..5bc786f 100644
--- a/drivers/net/sungem.c
+++ b/drivers/net/sungem.c
@@ -1136,7 +1136,7 @@ static netdev_tx_t gem_start_xmit(struct sk_buff *skb,
 	writel(gp->tx_new, gp->regs + TXDMA_KICK);
 	spin_unlock_irqrestore(&gp->tx_lock, flags);
 
-	dev->trans_start = jiffies;
+	dev->trans_start = jiffies; /* NETIF_F_LLTX driver :( */
 
 	return NETDEV_TX_OK;
 }
diff --git a/drivers/net/sunhme.c b/drivers/net/sunhme.c
index 982ff12..377c0b5 100644
--- a/drivers/net/sunhme.c
+++ b/drivers/net/sunhme.c
@@ -2341,8 +2341,6 @@ static netdev_tx_t happy_meal_start_xmit(struct sk_buff *skb,
 
 	spin_unlock_irq(&hp->happy_lock);
 
-	dev->trans_start = jiffies;
-
 	tx_add_log(hp, TXLOG_ACTION_TXMIT, 0);
 	return NETDEV_TX_OK;
 }
diff --git a/drivers/net/sunlance.c b/drivers/net/sunlance.c
index c7748b7..f88a60f 100644
--- a/drivers/net/sunlance.c
+++ b/drivers/net/sunlance.c
@@ -1003,7 +1003,7 @@ static int lance_reset(struct net_device *dev)
 	}
 	lp->init_ring(dev);
 	load_csrs(lp);
-	dev->trans_start = jiffies;
+	dev->trans_start = jiffies; /* prevent tx timeout */
 	status = init_restart_lance(lp);
 	return status;
 }
@@ -1160,7 +1160,6 @@ static int lance_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	spin_unlock_irq(&lp->lock);
 
-	dev->trans_start = jiffies;
 	dev_kfree_skb(skb);
 
 	return NETDEV_TX_OK;
diff --git a/drivers/net/sunqe.c b/drivers/net/sunqe.c
index 239f097..a7542d2 100644
--- a/drivers/net/sunqe.c
+++ b/drivers/net/sunqe.c
@@ -602,7 +602,6 @@ static int qe_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	qep->tx_new = NEXT_TX(entry);
 
 	/* Get it going. */
-	dev->trans_start = jiffies;
 	sbus_writel(CREG_CTRL_TWAKEUP, qep->qcregs + CREG_CTRL);
 
 	dev->stats.tx_packets++;
diff --git a/drivers/net/sunvnet.c b/drivers/net/sunvnet.c
index 6cf8b06..d281a7b 100644
--- a/drivers/net/sunvnet.c
+++ b/drivers/net/sunvnet.c
@@ -717,7 +717,6 @@ static int vnet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	dev_kfree_skb(skb);
 
-	dev->trans_start = jiffies;
 	return NETDEV_TX_OK;
 
 out_dropped_unlock:
diff --git a/drivers/net/tc35815.c b/drivers/net/tc35815.c
index 36149dd..be08b75 100644
--- a/drivers/net/tc35815.c
+++ b/drivers/net/tc35815.c
@@ -1357,8 +1357,6 @@ static int tc35815_send_packet(struct sk_buff *skb, struct net_device *dev)
 	}
 	lp->tfd_start = (lp->tfd_start + 1) % TX_FD_NUM;
 
-	dev->trans_start = jiffies;
-
 	/* If we just used up the very last entry in the
 	 * TX ring on this device, tell the queueing
 	 * layer to send no more.
diff --git a/drivers/net/tlan.c b/drivers/net/tlan.c
index 8ffec22..ccee3ed 100644
--- a/drivers/net/tlan.c
+++ b/drivers/net/tlan.c
@@ -1034,7 +1034,7 @@ static void TLan_tx_timeout(struct net_device *dev)
 	TLan_ResetLists( dev );
 	TLan_ReadAndClearStats( dev, TLAN_IGNORE );
 	TLan_ResetAdapter( dev );
-	dev->trans_start = jiffies;
+	dev->trans_start = jiffies; /* prevent tx timeout */
 	netif_wake_queue( dev );
 
 }
@@ -1147,7 +1147,6 @@ static netdev_tx_t TLan_StartTx( struct sk_buff *skb, struct net_device *dev )
 
 	CIRC_INC( priv->txTail, TLAN_NUM_TX_LISTS );
 
-	dev->trans_start = jiffies;
 	return NETDEV_TX_OK;
 
 } /* TLan_StartTx */
diff --git a/drivers/net/tokenring/ibmtr.c b/drivers/net/tokenring/ibmtr.c
index eebdaae..91e6c78 100644
--- a/drivers/net/tokenring/ibmtr.c
+++ b/drivers/net/tokenring/ibmtr.c
@@ -1041,7 +1041,6 @@ static netdev_tx_t tok_send_packet(struct sk_buff *skb,
 	writew(ti->exsap_station_id, ti->srb + STATION_ID_OFST);
 	writeb(CMD_IN_SRB, ti->mmio + ACA_OFFSET + ACA_SET + ISRA_ODD);
 	spin_unlock_irqrestore(&(ti->lock), flags);
-	dev->trans_start = jiffies;
 	return NETDEV_TX_OK;
 }
 
diff --git a/drivers/net/tokenring/smctr.c b/drivers/net/tokenring/smctr.c
index e405601..213b9af 100644
--- a/drivers/net/tokenring/smctr.c
+++ b/drivers/net/tokenring/smctr.c
@@ -4562,7 +4562,7 @@ static void smctr_timeout(struct net_device *dev)
          * fake transmission time and go on trying. Our own timeout
          * routine is in sktr_timer_chk()
          */
-        dev->trans_start = jiffies;
+        dev->trans_start = jiffies; /* prevent tx timeout */
         netif_wake_queue(dev);
 }
 
diff --git a/drivers/net/tokenring/tms380tr.c b/drivers/net/tokenring/tms380tr.c
index c169fd0..8cb126a 100644
--- a/drivers/net/tokenring/tms380tr.c
+++ b/drivers/net/tokenring/tms380tr.c
@@ -592,7 +592,7 @@ static void tms380tr_timeout(struct net_device *dev)
 	 * fake transmission time and go on trying. Our own timeout
 	 * routine is in tms380tr_timer_chk()
 	 */
-	dev->trans_start = jiffies;
+	dev->trans_start = jiffies; /* prevent tx timeout */
 	netif_wake_queue(dev);
 }
 
diff --git a/drivers/net/tulip/de2104x.c b/drivers/net/tulip/de2104x.c
index 9c0f29c..c0e7000 100644
--- a/drivers/net/tulip/de2104x.c
+++ b/drivers/net/tulip/de2104x.c
@@ -654,7 +654,6 @@ static netdev_tx_t de_start_xmit (struct sk_buff *skb,
 
 	/* Trigger an immediate transmit demand. */
 	dw32(TxPoll, NormalTxPoll);
-	dev->trans_start = jiffies;
 
 	return NETDEV_TX_OK;
 }
diff --git a/drivers/net/tulip/de4x5.c b/drivers/net/tulip/de4x5.c
index d818456..9522baf 100644
--- a/drivers/net/tulip/de4x5.c
+++ b/drivers/net/tulip/de4x5.c
@@ -1337,7 +1337,7 @@ de4x5_open(struct net_device *dev)
     }
 
     lp->interrupt = UNMASK_INTERRUPTS;
-    dev->trans_start = jiffies;
+    dev->trans_start = jiffies; /* prevent tx timeout */
 
     START_DE4X5;
 
@@ -1507,7 +1507,6 @@ de4x5_queue_pkt(struct sk_buff *skb, struct net_device *dev)
 	    outl(POLL_DEMAND, DE4X5_TPD);/* Start the TX */
 
 	    lp->tx_new = (++lp->tx_new) % lp->txRingSize;
-	    dev->trans_start = jiffies;
 
 	    if (TX_BUFFS_AVAIL) {
 		netif_start_queue(dev);         /* Another pkt may be queued */
@@ -1937,7 +1936,7 @@ set_multicast_list(struct net_device *dev)
 
 	    lp->tx_new = (++lp->tx_new) % lp->txRingSize;
 	    outl(POLL_DEMAND, DE4X5_TPD);       /* Start the TX */
-	    dev->trans_start = jiffies;
+	    dev->trans_start = jiffies; /* prevent tx timeout */
 	}
     }
 }
diff --git a/drivers/net/tulip/dmfe.c b/drivers/net/tulip/dmfe.c
index 7278ecb..bdb25b8 100644
--- a/drivers/net/tulip/dmfe.c
+++ b/drivers/net/tulip/dmfe.c
@@ -1180,11 +1180,11 @@ static void dmfe_timer(unsigned long data)
 
 	/* TX polling kick monitor */
 	if ( db->tx_packet_cnt &&
-	     time_after(jiffies, dev->trans_start + DMFE_TX_KICK) ) {
+	     time_after(jiffies, dev_trans_start(dev) + DMFE_TX_KICK) ) {
 		outl(0x1, dev->base_addr + DCR1);   /* Tx polling again */
 
 		/* TX Timeout */
-		if ( time_after(jiffies, dev->trans_start + DMFE_TX_TIMEOUT) ) {
+		if (time_after(jiffies, dev_trans_start(dev) + DMFE_TX_TIMEOUT) ) {
 			db->reset_TXtimeout++;
 			db->wait_reset = 1;
 			dev_warn(&dev->dev, "Tx timeout - resetting\n");
diff --git a/drivers/net/tulip/pnic.c b/drivers/net/tulip/pnic.c
index 966efa1..a63e64b 100644
--- a/drivers/net/tulip/pnic.c
+++ b/drivers/net/tulip/pnic.c
@@ -67,7 +67,7 @@ void pnic_lnk_change(struct net_device *dev, int csr5)
 		 */
 		if (tulip_media_cap[dev->if_port] & MediaIsMII)
 			return;
-		if (! tp->nwayset  ||  time_after(jiffies, dev->trans_start + 1*HZ)) {
+		if (! tp->nwayset || time_after(jiffies, dev_trans_start(dev) + 1*HZ)) {
 			tp->csr6 = 0x00420000 | (tp->csr6 & 0x0000fdff);
 			iowrite32(tp->csr6, ioaddr + CSR6);
 			iowrite32(0x30, ioaddr + CSR12);
diff --git a/drivers/net/tulip/tulip_core.c b/drivers/net/tulip/tulip_core.c
index 22e766e..254643e 100644
--- a/drivers/net/tulip/tulip_core.c
+++ b/drivers/net/tulip/tulip_core.c
@@ -605,7 +605,7 @@ static void tulip_tx_timeout(struct net_device *dev)
 
 out_unlock:
 	spin_unlock_irqrestore (&tp->lock, flags);
-	dev->trans_start = jiffies;
+	dev->trans_start = jiffies; /* prevent tx timeout */
 	netif_wake_queue (dev);
 }
 
@@ -707,8 +707,6 @@ tulip_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	spin_unlock_irqrestore(&tp->lock, flags);
 
-	dev->trans_start = jiffies;
-
 	return NETDEV_TX_OK;
 }
 
diff --git a/drivers/net/tulip/uli526x.c b/drivers/net/tulip/uli526x.c
index c7f9728..96de582 100644
--- a/drivers/net/tulip/uli526x.c
+++ b/drivers/net/tulip/uli526x.c
@@ -1040,11 +1040,11 @@ static void uli526x_timer(unsigned long data)
 
 	/* TX polling kick monitor */
 	if ( db->tx_packet_cnt &&
-	     time_after(jiffies, dev->trans_start + ULI526X_TX_KICK) ) {
+	     time_after(jiffies, dev_trans_start(dev) + ULI526X_TX_KICK) ) {
 		outl(0x1, dev->base_addr + DCR1);   // Tx polling again
 
 		// TX Timeout
-		if ( time_after(jiffies, dev->trans_start + ULI526X_TX_TIMEOUT) ) {
+		if ( time_after(jiffies, dev_trans_start(dev) + ULI526X_TX_TIMEOUT) ) {
 			db->reset_TXtimeout++;
 			db->wait_reset = 1;
 			printk( "%s: Tx timeout - resetting\n",
diff --git a/drivers/net/tulip/winbond-840.c b/drivers/net/tulip/winbond-840.c
index 18c8ced..60a8754 100644
--- a/drivers/net/tulip/winbond-840.c
+++ b/drivers/net/tulip/winbond-840.c
@@ -969,7 +969,7 @@ static void tx_timeout(struct net_device *dev)
 	enable_irq(dev->irq);
 
 	netif_wake_queue(dev);
-	dev->trans_start = jiffies;
+	dev->trans_start = jiffies; /* prevent tx timeout */
 	np->stats.tx_errors++;
 	return;
 }
@@ -1055,8 +1055,6 @@ static netdev_tx_t start_tx(struct sk_buff *skb, struct net_device *dev)
 	}
 	spin_unlock_irq(&np->lock);
 
-	dev->trans_start = jiffies;
-
 	if (debug > 4) {
 		printk(KERN_DEBUG "%s: Transmit frame #%d queued in slot %d\n",
 		       dev->name, np->cur_tx, entry);
diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 6b150c0..dbdfb1f 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -396,7 +396,6 @@ static netdev_tx_t tun_net_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	/* Enqueue packet */
 	skb_queue_tail(&tun->socket.sk->sk_receive_queue, skb);
-	dev->trans_start = jiffies;
 
 	/* Notify and wake up reader process */
 	if (tun->flags & TUN_FASYNC)
diff --git a/drivers/net/typhoon.c b/drivers/net/typhoon.c
index b94c4cc..22bde49 100644
--- a/drivers/net/typhoon.c
+++ b/drivers/net/typhoon.c
@@ -881,8 +881,6 @@ typhoon_start_tx(struct sk_buff *skb, struct net_device *dev)
 	wmb();
 	iowrite32(txRing->lastWrite, tp->tx_ioaddr + txRing->writeRegister);
 
-	dev->trans_start = jiffies;
-
 	/* If we don't have room to put the worst case packet on the
 	 * queue, then we must stop the queue. We need 2 extra
 	 * descriptors -- one to prevent ring wrap, and one for the
diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index 081f76b..932602d 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -3148,8 +3148,6 @@ static int ucc_geth_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	/* set bd status and length */
 	out_be32((u32 __iomem *)bd, bd_status);
 
-	dev->trans_start = jiffies;
-
 	/* Move to next BD in the ring */
 	if (!(bd_status & T_W))
 		bd += sizeof(struct qe_bd);
diff --git a/drivers/net/usb/hso.c b/drivers/net/usb/hso.c
index be0cc99..a6227f8 100644
--- a/drivers/net/usb/hso.c
+++ b/drivers/net/usb/hso.c
@@ -834,8 +834,6 @@ static netdev_tx_t hso_net_start_xmit(struct sk_buff *skb,
 	} else {
 		net->stats.tx_packets++;
 		net->stats.tx_bytes += skb->len;
-		/* And tell the kernel when the last transmit started. */
-		net->trans_start = jiffies;
 	}
 	dev_kfree_skb(skb);
 	/* we're done */
diff --git a/drivers/net/usb/kaweth.c b/drivers/net/usb/kaweth.c
index c4c334d..46890dc 100644
--- a/drivers/net/usb/kaweth.c
+++ b/drivers/net/usb/kaweth.c
@@ -856,7 +856,6 @@ skip:
 	{
 		kaweth->stats.tx_packets++;
 		kaweth->stats.tx_bytes += skb->len;
-		net->trans_start = jiffies;
 	}
 
 	spin_unlock_irq(&kaweth->device_lock);
diff --git a/drivers/net/usb/pegasus.c b/drivers/net/usb/pegasus.c
index 4183877..1cd17d2 100644
--- a/drivers/net/usb/pegasus.c
+++ b/drivers/net/usb/pegasus.c
@@ -808,7 +808,7 @@ static void write_bulk_callback(struct urb *urb)
 		break;
 	}
 
-	net->trans_start = jiffies;
+	net->trans_start = jiffies; /* prevent tx timeout */
 	netif_wake_queue(net);
 }
 
@@ -909,7 +909,6 @@ static netdev_tx_t pegasus_start_xmit(struct sk_buff *skb,
 	} else {
 		pegasus->stats.tx_packets++;
 		pegasus->stats.tx_bytes += skb->len;
-		net->trans_start = jiffies;
 	}
 	dev_kfree_skb(skb);
 
diff --git a/drivers/net/via-rhine.c b/drivers/net/via-rhine.c
index 467bcff..4930f9d 100644
--- a/drivers/net/via-rhine.c
+++ b/drivers/net/via-rhine.c
@@ -1209,7 +1209,7 @@ static void rhine_reset_task(struct work_struct *work)
 	spin_unlock_bh(&rp->lock);
 	enable_irq(rp->pdev->irq);
 
-	dev->trans_start = jiffies;
+	dev->trans_start = jiffies; /* prevent tx timeout */
 	dev->stats.tx_errors++;
 	netif_wake_queue(dev);
 }
@@ -1294,8 +1294,6 @@ static netdev_tx_t rhine_start_tx(struct sk_buff *skb,
 	if (rp->cur_tx == rp->dirty_tx + TX_QUEUE_LEN)
 		netif_stop_queue(dev);
 
-	dev->trans_start = jiffies;
-
 	spin_unlock_irqrestore(&rp->lock, flags);
 
 	if (debug > 4) {
diff --git a/drivers/net/via-velocity.c b/drivers/net/via-velocity.c
index 616f8c9..42dffd3 100644
--- a/drivers/net/via-velocity.c
+++ b/drivers/net/via-velocity.c
@@ -2606,7 +2606,6 @@ static netdev_tx_t velocity_xmit(struct sk_buff *skb,
 	td_ptr->td_buf[0].size |= TD_QUEUE;
 	mac_tx_queue_wake(vptr->mac_regs, qnum);
 
-	dev->trans_start = jiffies;
 	spin_unlock_irqrestore(&vptr->lock, flags);
 out:
 	return NETDEV_TX_OK;
diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vmxnet3_drv.c
index 90e783a..3946232 100644
--- a/drivers/net/vmxnet3/vmxnet3_drv.c
+++ b/drivers/net/vmxnet3/vmxnet3_drv.c
@@ -992,7 +992,6 @@ vmxnet3_tq_xmit(struct sk_buff *skb, struct vmxnet3_tx_queue *tq,
 		VMXNET3_WRITE_BAR0_REG(adapter, VMXNET3_REG_TXPROD,
 				       tq->tx_ring.next2fill);
 	}
-	netdev->trans_start = jiffies;
 
 	return NETDEV_TX_OK;
 
diff --git a/drivers/net/wan/dscc4.c b/drivers/net/wan/dscc4.c
index a4859f7..d45b08d 100644
--- a/drivers/net/wan/dscc4.c
+++ b/drivers/net/wan/dscc4.c
@@ -1175,8 +1175,6 @@ static netdev_tx_t dscc4_start_xmit(struct sk_buff *skb,
 	spin_unlock(&dpriv->lock);
 #endif
 
-	dev->trans_start = jiffies;
-
 	if (debug > 2)
 		dscc4_tx_print(dev, dpriv, "Xmit");
 	/* To be cleaned(unsigned int)/optimized. Later, ok ? */
diff --git a/drivers/net/wan/hd64570.c b/drivers/net/wan/hd64570.c
index 4dde2ea..a3ea27c 100644
--- a/drivers/net/wan/hd64570.c
+++ b/drivers/net/wan/hd64570.c
@@ -658,7 +658,6 @@ static netdev_tx_t sca_xmit(struct sk_buff *skb, struct net_device *dev)
 #endif
 	writew(len, &desc->len);
 	writeb(ST_TX_EOM, &desc->stat);
-	dev->trans_start = jiffies;
 
 	port->txin = next_desc(port, port->txin, 1);
 	sca_outw(desc_offset(port, port->txin, 1),
diff --git a/drivers/net/wan/hd64572.c b/drivers/net/wan/hd64572.c
index aad9ed4..ea476cb 100644
--- a/drivers/net/wan/hd64572.c
+++ b/drivers/net/wan/hd64572.c
@@ -585,7 +585,6 @@ static netdev_tx_t sca_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	writew(len, &desc->len);
 	writeb(ST_TX_EOM, &desc->stat);
-	dev->trans_start = jiffies;
 
 	port->txin = (port->txin + 1) % card->tx_ring_buffers;
 	sca_outl(desc_offset(port, port->txin, 1),
diff --git a/drivers/net/wan/ixp4xx_hss.c b/drivers/net/wan/ixp4xx_hss.c
index 0c2cdde..88e3630 100644
--- a/drivers/net/wan/ixp4xx_hss.c
+++ b/drivers/net/wan/ixp4xx_hss.c
@@ -891,7 +891,6 @@ static int hss_hdlc_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	wmb();
 	queue_put_desc(queue_ids[port->id].tx, tx_desc_phys(port, n), desc);
-	dev->trans_start = jiffies;
 
 	if (qmgr_stat_below_low_watermark(txreadyq)) { /* empty */
 #if DEBUG_TX
diff --git a/drivers/net/wan/lmc/lmc_main.c b/drivers/net/wan/lmc/lmc_main.c
index b278503..e2c6f7f 100644
--- a/drivers/net/wan/lmc/lmc_main.c
+++ b/drivers/net/wan/lmc/lmc_main.c
@@ -1506,8 +1506,6 @@ static netdev_tx_t lmc_start_xmit(struct sk_buff *skb,
     /* send now! */
     LMC_CSR_WRITE (sc, csr_txpoll, 0);
 
-    dev->trans_start = jiffies;
-
     spin_unlock_irqrestore(&sc->lmc_lock, flags);
 
     lmc_trace(dev, "lmc_start_xmit_out");
@@ -2103,7 +2101,7 @@ static void lmc_driver_timeout(struct net_device *dev)
     printk("%s: Xmitter busy|\n", dev->name);
 
     sc->extra_stats.tx_tbusy_calls++;
-    if (jiffies - dev->trans_start < TX_TIMEOUT)
+    if (jiffies - dev_trans_start(dev) < TX_TIMEOUT)
 	    goto bug_out;
 
     /*
@@ -2135,7 +2133,7 @@ static void lmc_driver_timeout(struct net_device *dev)
     sc->lmc_device->stats.tx_errors++;
     sc->extra_stats.tx_ProcTimeout++; /* -baz */
 
-    dev->trans_start = jiffies;
+    dev->trans_start = jiffies; /* prevent tx timeout */
 
 bug_out:
 
diff --git a/drivers/net/wan/pc300_drv.c b/drivers/net/wan/pc300_drv.c
index 17502d8..c6aa66e 100644
--- a/drivers/net/wan/pc300_drv.c
+++ b/drivers/net/wan/pc300_drv.c
@@ -1790,7 +1790,7 @@ static void cpc_tx_timeout(struct net_device *dev)
 			   cpc_readb(card->hw.falcbase + card->hw.cpld_reg2) &
 			   ~(CPLD_REG2_FALC_LED1 << (2 * ch)));
 	}
-	dev->trans_start = jiffies;
+	dev->trans_start = jiffies; /* prevent tx timeout */
 	CPC_UNLOCK(card, flags);
 	netif_wake_queue(dev);
 }
@@ -1849,7 +1849,6 @@ static int cpc_queue_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (d->trace_on) {
 		cpc_trace(dev, skb, 'T');
 	}
-	dev->trans_start = jiffies;
 
 	/* Start transmission */
 	CPC_LOCK(card, flags);
diff --git a/drivers/net/wan/wanxl.c b/drivers/net/wan/wanxl.c
index 541c700..db73a7b 100644
--- a/drivers/net/wan/wanxl.c
+++ b/drivers/net/wan/wanxl.c
@@ -298,7 +298,6 @@ static netdev_tx_t wanxl_xmit(struct sk_buff *skb, struct net_device *dev)
 	desc->stat = PACKET_FULL;
 	writel(1 << (DOORBELL_TO_CARD_TX_0 + port->node),
 	       port->card->plx + PLX_DOORBELL_TO_CARD);
-	dev->trans_start = jiffies;
 
 	port->tx_out = (port->tx_out + 1) % TX_BUFFERS;
 
diff --git a/drivers/net/wireless/atmel.c b/drivers/net/wireless/atmel.c
index 3edbbcf..c8f7090 100644
--- a/drivers/net/wireless/atmel.c
+++ b/drivers/net/wireless/atmel.c
@@ -865,7 +865,6 @@ static netdev_tx_t start_tx(struct sk_buff *skb, struct net_device *dev)
 
 	/* low bit of first byte of destination tells us if broadcast */
 	tx_update_descriptor(priv, *(skb->data) & 0x01, len + 18, buff, TX_PACKET_TYPE_DATA);
-	dev->trans_start = jiffies;
 	dev->stats.tx_bytes += len;
 
 	spin_unlock_irqrestore(&priv->irqlock, flags);
diff --git a/drivers/net/wireless/libertas/main.c b/drivers/net/wireless/libertas/main.c
index 38edad6..d9b8ee1 100644
--- a/drivers/net/wireless/libertas/main.c
+++ b/drivers/net/wireless/libertas/main.c
@@ -229,7 +229,7 @@ static void lbs_tx_timeout(struct net_device *dev)
 
 	lbs_pr_err("tx watch dog timeout\n");
 
-	dev->trans_start = jiffies;
+	dev->trans_start = jiffies; /* prevent tx timeout */
 
 	if (priv->currenttxskb)
 		lbs_send_tx_feedback(priv, 0);
diff --git a/drivers/net/wireless/libertas/tx.c b/drivers/net/wireless/libertas/tx.c
index 52d244e..a9bf658 100644
--- a/drivers/net/wireless/libertas/tx.c
+++ b/drivers/net/wireless/libertas/tx.c
@@ -147,8 +147,6 @@ netdev_tx_t lbs_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	dev->stats.tx_packets++;
 	dev->stats.tx_bytes += skb->len;
 
-	dev->trans_start = jiffies;
-
 	if (priv->monitormode) {
 		/* Keep the skb to echo it back once Tx feedback is
 		   received from FW */
diff --git a/drivers/net/wireless/orinoco/main.c b/drivers/net/wireless/orinoco/main.c
index 1d60c7e..884a777 100644
--- a/drivers/net/wireless/orinoco/main.c
+++ b/drivers/net/wireless/orinoco/main.c
@@ -517,7 +517,6 @@ static netdev_tx_t orinoco_xmit(struct sk_buff *skb, struct net_device *dev)
 		goto busy;
 	}
 
-	dev->trans_start = jiffies;
 	stats->tx_bytes += HERMES_802_3_OFFSET + skb->len;
 	goto ok;
 
diff --git a/drivers/net/wireless/prism54/islpci_eth.c b/drivers/net/wireless/prism54/islpci_eth.c
index 64585da..2fc52bc 100644
--- a/drivers/net/wireless/prism54/islpci_eth.c
+++ b/drivers/net/wireless/prism54/islpci_eth.c
@@ -224,8 +224,6 @@ islpci_eth_transmit(struct sk_buff *skb, struct net_device *ndev)
 		priv->data_low_tx_full = 1;
 	}
 
-	/* set the transmission time */
-	ndev->trans_start = jiffies;
 	ndev->stats.tx_packets++;
 	ndev->stats.tx_bytes += skb->len;
 
diff --git a/drivers/net/wireless/ray_cs.c b/drivers/net/wireless/ray_cs.c
index d9c45bf..73972ee 100644
--- a/drivers/net/wireless/ray_cs.c
+++ b/drivers/net/wireless/ray_cs.c
@@ -941,7 +941,6 @@ static netdev_tx_t ray_dev_start_xmit(struct sk_buff *skb,
 	case XMIT_MSG_BAD:
 	case XMIT_OK:
 	default:
-		dev->trans_start = jiffies;
 		dev_kfree_skb(skb);
 	}
 
diff --git a/drivers/net/wireless/wl3501_cs.c b/drivers/net/wireless/wl3501_cs.c
index 65dd502..1e61e6c 100644
--- a/drivers/net/wireless/wl3501_cs.c
+++ b/drivers/net/wireless/wl3501_cs.c
@@ -1307,7 +1307,7 @@ static void wl3501_tx_timeout(struct net_device *dev)
 		printk(KERN_ERR "%s: Error %d resetting card on Tx timeout!\n",
 		       dev->name, rc);
 	else {
-		dev->trans_start = jiffies;
+		dev->trans_start = jiffies; /* prevent tx timeout */
 		netif_wake_queue(dev);
 	}
 }
@@ -1326,7 +1326,6 @@ static netdev_tx_t wl3501_hard_start_xmit(struct sk_buff *skb,
 
 	spin_lock_irqsave(&this->lock, flags);
 	enabled = wl3501_block_interrupt(this);
-	dev->trans_start = jiffies;
 	rc = wl3501_send_pkt(this, skb->data, skb->len);
 	if (enabled)
 		wl3501_unblock_interrupt(this);
diff --git a/drivers/net/wireless/zd1201.c b/drivers/net/wireless/zd1201.c
index 1e2b684..ece86a5 100644
--- a/drivers/net/wireless/zd1201.c
+++ b/drivers/net/wireless/zd1201.c
@@ -827,7 +827,6 @@ static netdev_tx_t zd1201_hard_start_xmit(struct sk_buff *skb,
 	} else {
 		dev->stats.tx_packets++;
 		dev->stats.tx_bytes += skb->len;
-		dev->trans_start = jiffies;
 	}
 	kfree_skb(skb);
 
@@ -845,7 +844,7 @@ static void zd1201_tx_timeout(struct net_device *dev)
 	usb_unlink_urb(zd->tx_urb);
 	dev->stats.tx_errors++;
 	/* Restart the timeout to quiet the watchdog: */
-	dev->trans_start = jiffies;
+	dev->trans_start = jiffies; /* prevent tx timeout */
 }
 
 static int zd1201_set_mac_address(struct net_device *dev, void *p)
diff --git a/drivers/net/xilinx_emaclite.c b/drivers/net/xilinx_emaclite.c
index 93828d5..a7db68d 100644
--- a/drivers/net/xilinx_emaclite.c
+++ b/drivers/net/xilinx_emaclite.c
@@ -558,7 +558,7 @@ static void xemaclite_tx_timeout(struct net_device *dev)
 	}
 
 	/* To exclude tx timeout */
-	dev->trans_start = 0xffffffff - TX_TIMEOUT - TX_TIMEOUT;
+	dev->trans_start = jiffies; /* prevent tx timeout */
 
 	/* We're all ready to go. Start the queue */
 	netif_wake_queue(dev);
@@ -590,7 +590,7 @@ static void xemaclite_tx_handler(struct net_device *dev)
 			dev->stats.tx_bytes += lp->deferred_skb->len;
 			dev_kfree_skb_irq(lp->deferred_skb);
 			lp->deferred_skb = NULL;
-			dev->trans_start = jiffies;
+			dev->trans_start = jiffies; /* prevent tx timeout */
 			netif_wake_queue(dev);
 		}
 	}
@@ -1054,7 +1054,6 @@ static int xemaclite_send(struct sk_buff *orig_skb, struct net_device *dev)
 
 	dev->stats.tx_bytes += len;
 	dev_kfree_skb(new_skb);
-	dev->trans_start = jiffies;
 
 	return 0;
 }
diff --git a/drivers/net/znet.c b/drivers/net/znet.c
index dbfef8d..b9fd2f0 100644
--- a/drivers/net/znet.c
+++ b/drivers/net/znet.c
@@ -587,7 +587,6 @@ static netdev_tx_t znet_send_packet(struct sk_buff *skb, struct net_device *dev)
 		}
 		spin_unlock_irqrestore (&znet->lock, flags);
 
-		dev->trans_start = jiffies;
 		netif_start_queue (dev);
 
 		if (znet_debug > 4)


