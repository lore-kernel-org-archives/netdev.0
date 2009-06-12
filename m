From: Patrick McHardy <kaber@trash.net>
Subject: net: use symbolic values for ndo_start_xmit() return codes
Date: Fri, 12 Jun 2009 18:22:29 +0200
Message-ID: <4A3280C5.2090101@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040204090905050505040802"
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:48531 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751843AbZFLQW3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Jun 2009 12:22:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------040204090905050505040802
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

This is the final patch for now to get rid of invalid or magic return
values in ndo_start_xmit() functions. There are no NETDEV_TX_OK
conversions at this time to keep the noise down, but I wouldn't mind
doing that as a final step at the end of the merge window.

I'll make a final pass over all the drivers before submitting
the remaining patches.


--------------040204090905050505040802
Content-Type: text/x-patch;
 name="09.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="09.diff"

commit 6cf799f99801090d6ba57b71fb78daa99f006a0d
Author: Patrick McHardy <kaber@trash.net>
Date:   Fri Jun 12 18:14:48 2009 +0200

    net: use symbolic values for ndo_start_xmit() return codes
    
    Convert magic values 1 and -1 to NETDEV_TX_BUSY and NETDEV_TX_LOCKED respectively.
    
    0 (NETDEV_TX_OK) is not changed to keep the noise down, except in very few cases
    where its in direct proximity to one of the other values.
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 drivers/isdn/i4l/isdn_net.c                        |    6 +++---
 drivers/message/fusion/mptlan.c                    |    4 ++--
 drivers/net/3c505.c                                |    2 +-
 drivers/net/3c515.c                                |    2 +-
 drivers/net/3c527.c                                |    2 +-
 drivers/net/3c59x.c                                |    2 +-
 drivers/net/7990.c                                 |    2 +-
 drivers/net/8139cp.c                               |    2 +-
 drivers/net/a2065.c                                |    2 +-
 drivers/net/arm/at91_ether.c                       |    2 +-
 drivers/net/arm/ether3.c                           |    2 +-
 drivers/net/au1000_eth.c                           |    2 +-
 drivers/net/cassini.c                              |    2 +-
 drivers/net/cs89x0.c                               |    2 +-
 drivers/net/de600.c                                |    6 +++---
 drivers/net/de620.c                                |    2 +-
 drivers/net/defxx.c                                |    2 +-
 drivers/net/depca.c                                |    4 ++--
 drivers/net/dm9000.c                               |    2 +-
 drivers/net/e100.c                                 |    2 +-
 drivers/net/ewrk3.c                                |    2 +-
 drivers/net/fec.c                                  |    4 ++--
 drivers/net/hamachi.c                              |    2 +-
 drivers/net/hamradio/baycom_epp.c                  |    2 +-
 drivers/net/hamradio/hdlcdrv.c                     |    2 +-
 drivers/net/hamradio/mkiss.c                       |    4 ++--
 drivers/net/ibm_newemac/core.c                     |    2 +-
 drivers/net/irda/au1k_ir.c                         |    4 ++--
 drivers/net/irda/sir_dev.c                         |    2 +-
 drivers/net/lib8390.c                              |    2 +-
 drivers/net/mac89x0.c                              |    2 +-
 drivers/net/macb.c                                 |    2 +-
 drivers/net/mace.c                                 |    2 +-
 drivers/net/myri10ge/myri10ge.c                    |    2 +-
 drivers/net/myri_sbus.c                            |    2 +-
 drivers/net/ni65.c                                 |    2 +-
 drivers/net/ns83820.c                              |    4 ++--
 drivers/net/pcmcia/axnet_cs.c                      |    2 +-
 drivers/net/pcmcia/fmvj18x_cs.c                    |    2 +-
 drivers/net/pcmcia/smc91c92_cs.c                   |    2 +-
 drivers/net/pcmcia/xirc2ps_cs.c                    |    2 +-
 drivers/net/plip.c                                 |    6 +++---
 drivers/net/sb1250-mac.c                           |    2 +-
 drivers/net/sh_eth.c                               |    2 +-
 drivers/net/sis900.c                               |    2 +-
 drivers/net/skfp/skfddi.c                          |    2 +-
 drivers/net/smc9194.c                              |    2 +-
 drivers/net/sonic.c                                |    2 +-
 drivers/net/starfire.c                             |    2 +-
 drivers/net/sun3_82586.c                           |    2 +-
 drivers/net/sun3lance.c                            |    4 ++--
 drivers/net/sunhme.c                               |    2 +-
 drivers/net/tlan.c                                 |    2 +-
 drivers/net/tokenring/3c359.c                      |    2 +-
 drivers/net/tokenring/lanstreamer.c                |    2 +-
 drivers/net/tokenring/olympic.c                    |    2 +-
 drivers/net/tokenring/smctr.c                      |    2 +-
 drivers/net/tokenring/tms380tr.c                   |    2 +-
 drivers/net/tulip/de2104x.c                        |    2 +-
 drivers/net/tulip/de4x5.c                          |    6 +++---
 drivers/net/tulip/dmfe.c                           |    2 +-
 drivers/net/tulip/uli526x.c                        |    2 +-
 drivers/net/wan/dlci.c                             |    6 +++---
 drivers/net/wan/sbni.c                             |    2 +-
 drivers/net/wan/wanxl.c                            |    2 +-
 drivers/net/wireless/airo.c                        |    6 +++---
 drivers/net/wireless/arlan-main.c                  |    2 +-
 drivers/net/wireless/atmel.c                       |    2 +-
 drivers/net/wireless/hostap/hostap_80211_tx.c      |    2 +-
 drivers/net/wireless/ipw2x00/libipw_tx.c           |    2 +-
 drivers/net/wireless/ray_cs.c                      |    6 +++---
 drivers/net/wireless/strip.c                       |    2 +-
 drivers/net/wireless/wavelan.c                     |    6 +++---
 drivers/s390/net/netiucv.c                         |    4 ++--
 drivers/staging/et131x/et131x_netdev.c             |    4 ++--
 drivers/staging/rtl8187se/ieee80211/ieee80211_tx.c |    2 +-
 drivers/staging/wlan-ng/p80211netdev.c             |    8 ++++----
 drivers/usb/gadget/u_ether.c                       |    2 +-
 net/mac80211/tx.c                                  |    2 +-
 net/rose/rose_dev.c                                |    2 +-
 net/sched/sch_teql.c                               |    2 +-
 81 files changed, 109 insertions(+), 109 deletions(-)

diff --git a/drivers/isdn/i4l/isdn_net.c b/drivers/isdn/i4l/isdn_net.c
index cb8943d..34d54e7 100644
--- a/drivers/isdn/i4l/isdn_net.c
+++ b/drivers/isdn/i4l/isdn_net.c
@@ -1069,7 +1069,7 @@ isdn_net_xmit(struct net_device *ndev, struct sk_buff *skb)
 	lp = isdn_net_get_locked_lp(nd);
 	if (!lp) {
 		printk(KERN_WARNING "%s: all channels busy - requeuing!\n", ndev->name);
-		return 1;
+		return NETDEV_TX_BUSY;
 	}
 	/* we have our lp locked from now on */
 
@@ -1273,14 +1273,14 @@ isdn_net_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 					spin_unlock_irqrestore(&dev->lock, flags);
 					isdn_net_dial();	/* Initiate dialing */
 					netif_stop_queue(ndev);
-					return 1;	/* let upper layer requeue skb packet */
+					return NETDEV_TX_BUSY;	/* let upper layer requeue skb packet */
 				}
 #endif
 				/* Initiate dialing */
 				spin_unlock_irqrestore(&dev->lock, flags);
 				isdn_net_dial();
 				isdn_net_device_stop_queue(lp);
-				return 1;
+				return NETDEV_TX_BUSY;
 			} else {
 				isdn_net_unreachable(ndev, skb,
 						     "No phone number");
diff --git a/drivers/message/fusion/mptlan.c b/drivers/message/fusion/mptlan.c
index c2804f2..a9e48e2 100644
--- a/drivers/message/fusion/mptlan.c
+++ b/drivers/message/fusion/mptlan.c
@@ -703,7 +703,7 @@ mpt_lan_sdu_send (struct sk_buff *skb, struct net_device *dev)
 
 		printk (KERN_ERR "%s: no tx context available: %u\n",
 			__func__, priv->mpt_txfidx_tail);
-		return 1;
+		return NETDEV_TX_BUSY;
 	}
 
 	mf = mpt_get_msg_frame(LanCtx, mpt_dev);
@@ -713,7 +713,7 @@ mpt_lan_sdu_send (struct sk_buff *skb, struct net_device *dev)
 
 		printk (KERN_ERR "%s: Unable to alloc request frame\n",
 			__func__);
-		return 1;
+		return NETDEV_TX_BUSY;
 	}
 
 	ctx = priv->mpt_txfidx[priv->mpt_txfidx_tail--];
diff --git a/drivers/net/3c505.c b/drivers/net/3c505.c
index b284994..f71b354 100644
--- a/drivers/net/3c505.c
+++ b/drivers/net/3c505.c
@@ -1088,7 +1088,7 @@ static int elp_start_xmit(struct sk_buff *skb, struct net_device *dev)
 			pr_debug("%s: failed to transmit packet\n", dev->name);
 		}
 		spin_unlock_irqrestore(&adapter->lock, flags);
-		return 1;
+		return NETDEV_TX_BUSY;
 	}
 	if (elp_debug >= 3)
 		pr_debug("%s: packet of length %d sent\n", dev->name, (int) skb->len);
diff --git a/drivers/net/3c515.c b/drivers/net/3c515.c
index 7fd0ff7..3e00fa8 100644
--- a/drivers/net/3c515.c
+++ b/drivers/net/3c515.c
@@ -1014,7 +1014,7 @@ static int corkscrew_start_xmit(struct sk_buff *skb,
 		int i;
 
 		if (vp->tx_full)	/* No room to transmit with */
-			return 1;
+			return NETDEV_TX_BUSY;
 		if (vp->cur_tx != 0)
 			prev_entry = &vp->tx_ring[(vp->cur_tx - 1) % TX_RING_SIZE];
 		else
diff --git a/drivers/net/3c527.c b/drivers/net/3c527.c
index c10ca30..aaa8a9f 100644
--- a/drivers/net/3c527.c
+++ b/drivers/net/3c527.c
@@ -1030,7 +1030,7 @@ static int mc32_send_packet(struct sk_buff *skb, struct net_device *dev)
 	netif_stop_queue(dev);
 
 	if(atomic_read(&lp->tx_count)==0) {
-		return 1;
+		return NETDEV_TX_BUSY;
 	}
 
 	if (skb_padto(skb, ETH_ZLEN)) {
diff --git a/drivers/net/3c59x.c b/drivers/net/3c59x.c
index a6e8a2d..c34aee9 100644
--- a/drivers/net/3c59x.c
+++ b/drivers/net/3c59x.c
@@ -2107,7 +2107,7 @@ boomerang_start_xmit(struct sk_buff *skb, struct net_device *dev)
 			pr_warning("%s: BUG! Tx Ring full, refusing to send buffer.\n",
 				   dev->name);
 		netif_stop_queue(dev);
-		return 1;
+		return NETDEV_TX_BUSY;
 	}
 
 	vp->tx_skbuff[entry] = skb;
diff --git a/drivers/net/7990.c b/drivers/net/7990.c
index 7a331ac..69f5b7d 100644
--- a/drivers/net/7990.c
+++ b/drivers/net/7990.c
@@ -541,7 +541,7 @@ int lance_start_xmit (struct sk_buff *skb, struct net_device *dev)
 	unsigned long flags;
 
         if (!TX_BUFFS_AVAIL)
-                return -1;
+                return NETDEV_TX_LOCKED;
 
 	netif_stop_queue (dev);
 
diff --git a/drivers/net/8139cp.c b/drivers/net/8139cp.c
index c9fc0ff..50efde1 100644
--- a/drivers/net/8139cp.c
+++ b/drivers/net/8139cp.c
@@ -756,7 +756,7 @@ static int cp_start_xmit (struct sk_buff *skb, struct net_device *dev)
 		spin_unlock_irqrestore(&cp->lock, intr_flags);
 		pr_err(PFX "%s: BUG! Tx Ring full when queue awake!\n",
 		       dev->name);
-		return 1;
+		return NETDEV_TX_BUSY;
 	}
 
 #if CP_VLAN_TAG_USED
diff --git a/drivers/net/a2065.c b/drivers/net/a2065.c
index 02f64d5..85a1817 100644
--- a/drivers/net/a2065.c
+++ b/drivers/net/a2065.c
@@ -564,7 +564,7 @@ static int lance_start_xmit (struct sk_buff *skb, struct net_device *dev)
 
 	if (!TX_BUFFS_AVAIL){
 		local_irq_restore(flags);
-		return -1;
+		return NETDEV_TX_LOCKED;
 	}
 
 #ifdef DEBUG_DRIVER
diff --git a/drivers/net/arm/at91_ether.c b/drivers/net/arm/at91_ether.c
index 7f4bc8a..2e7419a 100644
--- a/drivers/net/arm/at91_ether.c
+++ b/drivers/net/arm/at91_ether.c
@@ -829,7 +829,7 @@ static int at91ether_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		dev->trans_start = jiffies;
 	} else {
 		printk(KERN_ERR "at91_ether.c: at91ether_start_xmit() called, but device is busy!\n");
-		return 1;	/* if we return anything but zero, dev.c:1055 calls kfree_skb(skb)
+		return NETDEV_TX_BUSY;	/* if we return anything but zero, dev.c:1055 calls kfree_skb(skb)
 				on this skb, he also reports -ENETDOWN and printk's, so either
 				we free and return(0) or don't free and return 1 */
 	}
diff --git a/drivers/net/arm/ether3.c b/drivers/net/arm/ether3.c
index ec8a1ae..4550371 100644
--- a/drivers/net/arm/ether3.c
+++ b/drivers/net/arm/ether3.c
@@ -526,7 +526,7 @@ ether3_sendpacket(struct sk_buff *skb, struct net_device *dev)
 
 	if (priv(dev)->tx_tail == next_ptr) {
 		local_irq_restore(flags);
-		return 1;	/* unable to queue */
+		return NETDEV_TX_BUSY;	/* unable to queue */
 	}
 
 	dev->trans_start = jiffies;
diff --git a/drivers/net/au1000_eth.c b/drivers/net/au1000_eth.c
index d58c105..d3c734f 100644
--- a/drivers/net/au1000_eth.c
+++ b/drivers/net/au1000_eth.c
@@ -957,7 +957,7 @@ static int au1000_tx(struct sk_buff *skb, struct net_device *dev)
 		/* We've wrapped around and the transmitter is still busy */
 		netif_stop_queue(dev);
 		aup->tx_full = 1;
-		return 1;
+		return NETDEV_TX_BUSY;
 	}
 	else if (buff_stat & TX_T_DONE) {
 		update_tx_stats(dev, ptxd->status);
diff --git a/drivers/net/cassini.c b/drivers/net/cassini.c
index f522276..eb06667 100644
--- a/drivers/net/cassini.c
+++ b/drivers/net/cassini.c
@@ -2934,7 +2934,7 @@ static int cas_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	 *      individual queues.
 	 */
 	if (cas_xmit_tx_ringN(cp, ring++ & N_TX_RINGS_MASK, skb))
-		return 1;
+		return NETDEV_TX_BUSY;
 	dev->trans_start = jiffies;
 	return 0;
 }
diff --git a/drivers/net/cs89x0.c b/drivers/net/cs89x0.c
index 7433b88..3eee666 100644
--- a/drivers/net/cs89x0.c
+++ b/drivers/net/cs89x0.c
@@ -1551,7 +1551,7 @@ static int net_send_packet(struct sk_buff *skb, struct net_device *dev)
 
 		spin_unlock_irq(&lp->lock);
 		if (net_debug) printk("cs89x0: Tx buffer not free!\n");
-		return 1;
+		return NETDEV_TX_BUSY;
 	}
 	/* Write the contents of the packet */
 	writewords(dev->base_addr, TX_FRAME_PORT,skb->data,(skb->len+1) >>1);
diff --git a/drivers/net/de600.c b/drivers/net/de600.c
index c866ca9..e1af089 100644
--- a/drivers/net/de600.c
+++ b/drivers/net/de600.c
@@ -168,14 +168,14 @@ static int de600_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (free_tx_pages <= 0) {	/* Do timeouts, to avoid hangs. */
 		tickssofar = jiffies - dev->trans_start;
 		if (tickssofar < 5)
-			return 1;
+			return NETDEV_TX_BUSY;
 		/* else */
 		printk(KERN_WARNING "%s: transmit timed out (%d), %s?\n", dev->name, tickssofar, "network cable problem");
 		/* Restart the adapter. */
 		spin_lock_irqsave(&de600_lock, flags);
 		if (adapter_init(dev)) {
 			spin_unlock_irqrestore(&de600_lock, flags);
-			return 1;
+			return NETDEV_TX_BUSY;
 		}
 		spin_unlock_irqrestore(&de600_lock, flags);
 	}
@@ -199,7 +199,7 @@ static int de600_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		if (was_down || (de600_read_byte(READ_DATA, dev) != 0xde)) {
 			if (adapter_init(dev)) {
 				spin_unlock_irqrestore(&de600_lock, flags);
-				return 1;
+				return NETDEV_TX_BUSY;
 			}
 		}
 	}
diff --git a/drivers/net/de620.c b/drivers/net/de620.c
index 039bc1a..55d2bb6 100644
--- a/drivers/net/de620.c
+++ b/drivers/net/de620.c
@@ -531,7 +531,7 @@ static int de620_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	case (TXBF0 | TXBF1): /* NONE!!! */
 		printk(KERN_WARNING "%s: No tx-buffer available!\n", dev->name);
 		spin_unlock_irqrestore(&de620_lock, flags);
-		return 1;
+		return NETDEV_TX_BUSY;
 	}
 	de620_write_block(dev, buffer, skb->len, len-skb->len);
 
diff --git a/drivers/net/defxx.c b/drivers/net/defxx.c
index 4ec055d..102b8d4 100644
--- a/drivers/net/defxx.c
+++ b/drivers/net/defxx.c
@@ -3318,7 +3318,7 @@ static int dfx_xmt_queue_pkt(
 	{
 		skb_pull(skb,3);
 		spin_unlock_irqrestore(&bp->lock, flags);
-		return(1);			/* requeue packet for later */
+		return NETDEV_TX_BUSY;	/* requeue packet for later */
 	}
 
 	/*
diff --git a/drivers/net/depca.c b/drivers/net/depca.c
index 9301eb2..97ea2d6 100644
--- a/drivers/net/depca.c
+++ b/drivers/net/depca.c
@@ -957,7 +957,7 @@ static int depca_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		if (TX_BUFFS_AVAIL)
 			netif_start_queue(dev);
 	} else
-		status = -1;
+		status = NETDEV_TX_LOCKED;
 
       out:
 	return status;
@@ -1839,7 +1839,7 @@ static int load_packet(struct net_device *dev, struct sk_buff *skb)
 
 		lp->tx_new = (++end) & lp->txRingMask;	/* update current pointers */
 	} else {
-		status = -1;
+		status = NETDEV_TX_LOCKED;
 	}
 
 	return status;
diff --git a/drivers/net/dm9000.c b/drivers/net/dm9000.c
index e402e91..dd771de 100644
--- a/drivers/net/dm9000.c
+++ b/drivers/net/dm9000.c
@@ -756,7 +756,7 @@ dm9000_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	dm9000_dbg(db, 3, "%s:\n", __func__);
 
 	if (db->tx_pkt_cnt > 1)
-		return 1;
+		return NETDEV_TX_BUSY;
 
 	spin_lock_irqsave(&db->lock, flags);
 
diff --git a/drivers/net/e100.c b/drivers/net/e100.c
index 119dc53..e52a201 100644
--- a/drivers/net/e100.c
+++ b/drivers/net/e100.c
@@ -1716,7 +1716,7 @@ static int e100_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 		/* This is a hard error - log it. */
 		DPRINTK(TX_ERR, DEBUG, "Out of Tx resources, returning skb\n");
 		netif_stop_queue(netdev);
-		return 1;
+		return NETDEV_TX_BUSY;
 	}
 
 	netdev->trans_start = jiffies;
diff --git a/drivers/net/ewrk3.c b/drivers/net/ewrk3.c
index 1a685a0..1e97232 100644
--- a/drivers/net/ewrk3.c
+++ b/drivers/net/ewrk3.c
@@ -873,7 +873,7 @@ static int ewrk3_queue_pkt (struct sk_buff *skb, struct net_device *dev)
 err_out:
 	ENABLE_IRQs;
 	spin_unlock_irq (&lp->hw_lock);
-	return 1;
+	return NETDEV_TX_BUSY;
 }
 
 /*
diff --git a/drivers/net/fec.c b/drivers/net/fec.c
index 28db691..0f19b74 100644
--- a/drivers/net/fec.c
+++ b/drivers/net/fec.c
@@ -290,7 +290,7 @@ fec_enet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	if (!fep->link) {
 		/* Link is down or autonegotiation is in progress. */
-		return 1;
+		return NETDEV_TX_BUSY;
 	}
 
 	spin_lock_irqsave(&fep->hw_lock, flags);
@@ -305,7 +305,7 @@ fec_enet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		 */
 		printk("%s: tx queue full!.\n", dev->name);
 		spin_unlock_irqrestore(&fep->hw_lock, flags);
-		return 1;
+		return NETDEV_TX_BUSY;
 	}
 
 	/* Clear all of the status flags */
diff --git a/drivers/net/hamachi.c b/drivers/net/hamachi.c
index 26151fa..9d5b62c 100644
--- a/drivers/net/hamachi.c
+++ b/drivers/net/hamachi.c
@@ -1280,7 +1280,7 @@ static int hamachi_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		status=readw(hmp->base + TxStatus);
 		if( !(status & 0x0001) || (status & 0x0002))
 			writew(0x0001, hmp->base + TxCmd);
-		return 1;
+		return NETDEV_TX_BUSY;
 	}
 
 	/* Caution: the write order is important here, set the field
diff --git a/drivers/net/hamradio/baycom_epp.c b/drivers/net/hamradio/baycom_epp.c
index bb78c11..5e4b7af 100644
--- a/drivers/net/hamradio/baycom_epp.c
+++ b/drivers/net/hamradio/baycom_epp.c
@@ -777,7 +777,7 @@ static int baycom_send_packet(struct sk_buff *skb, struct net_device *dev)
 		return 0;
 	}
 	if (bc->skb)
-		return -1;
+		return NETDEV_TX_LOCKED;
 	/* strip KISS byte */
 	if (skb->len >= HDLCDRV_MAXFLEN+1 || skb->len < 3) {
 		dev_kfree_skb(skb);
diff --git a/drivers/net/hamradio/hdlcdrv.c b/drivers/net/hamradio/hdlcdrv.c
index 61de56e..d034f8c 100644
--- a/drivers/net/hamradio/hdlcdrv.c
+++ b/drivers/net/hamradio/hdlcdrv.c
@@ -409,7 +409,7 @@ static int hdlcdrv_send_packet(struct sk_buff *skb, struct net_device *dev)
 		return 0;
 	}
 	if (sm->skb)
-		return -1;
+		return NETDEV_TX_LOCKED;
 	netif_stop_queue(dev);
 	sm->skb = skb;
 	return 0;
diff --git a/drivers/net/hamradio/mkiss.c b/drivers/net/hamradio/mkiss.c
index 032c0db..fda2fc8 100644
--- a/drivers/net/hamradio/mkiss.c
+++ b/drivers/net/hamradio/mkiss.c
@@ -531,7 +531,7 @@ static int ax_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	if (!netif_running(dev))  {
 		printk(KERN_ERR "mkiss: %s: xmit call when iface is down\n", dev->name);
-		return 1;
+		return NETDEV_TX_BUSY;
 	}
 
 	if (netif_queue_stopped(dev)) {
@@ -541,7 +541,7 @@ static int ax_xmit(struct sk_buff *skb, struct net_device *dev)
 		 */
 		if (time_before(jiffies, dev->trans_start + 20 * HZ)) {
 			/* 20 sec timeout not reached */
-			return 1;
+			return NETDEV_TX_BUSY;
 		}
 
 		printk(KERN_ERR "mkiss: %s: transmit timed out, %s?\n", dev->name,
diff --git a/drivers/net/ibm_newemac/core.c b/drivers/net/ibm_newemac/core.c
index 806533c..beb8421 100644
--- a/drivers/net/ibm_newemac/core.c
+++ b/drivers/net/ibm_newemac/core.c
@@ -1484,7 +1484,7 @@ static int emac_start_xmit_sg(struct sk_buff *skb, struct net_device *ndev)
  stop_queue:
 	netif_stop_queue(ndev);
 	DBG2(dev, "stopped TX queue" NL);
-	return 1;
+	return NETDEV_TX_BUSY;
 }
 
 /* Tx lock BHs */
diff --git a/drivers/net/irda/au1k_ir.c b/drivers/net/irda/au1k_ir.c
index 269153e..c4361d4 100644
--- a/drivers/net/irda/au1k_ir.c
+++ b/drivers/net/irda/au1k_ir.c
@@ -512,13 +512,13 @@ static int au1k_irda_hard_xmit(struct sk_buff *skb, struct net_device *dev)
 		printk(KERN_DEBUG "%s: tx_full\n", dev->name);
 		netif_stop_queue(dev);
 		aup->tx_full = 1;
-		return 1;
+		return NETDEV_TX_BUSY;
 	}
 	else if (((aup->tx_head + 1) & (NUM_IR_DESC - 1)) == aup->tx_tail) {
 		printk(KERN_DEBUG "%s: tx_full\n", dev->name);
 		netif_stop_queue(dev);
 		aup->tx_full = 1;
-		return 1;
+		return NETDEV_TX_BUSY;
 	}
 
 	pDB = aup->tx_db_inuse[aup->tx_head];
diff --git a/drivers/net/irda/sir_dev.c b/drivers/net/irda/sir_dev.c
index d940809..fd0796c 100644
--- a/drivers/net/irda/sir_dev.c
+++ b/drivers/net/irda/sir_dev.c
@@ -607,7 +607,7 @@ static int sirdev_hard_xmit(struct sk_buff *skb, struct net_device *ndev)
 				 * stopped so the network layer will retry after the
 				 * fsm completes and wakes the queue.
 				 */
-				 return 1;
+				 return NETDEV_TX_BUSY;
 			}
 			else if (unlikely(err)) {
 				/* other fatal error - forget the speed change and
diff --git a/drivers/net/lib8390.c b/drivers/net/lib8390.c
index 789b6cb..f28c233 100644
--- a/drivers/net/lib8390.c
+++ b/drivers/net/lib8390.c
@@ -370,7 +370,7 @@ static int __ei_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		spin_unlock(&ei_local->page_lock);
 		enable_irq_lockdep_irqrestore(dev->irq, &flags);
 		dev->stats.tx_errors++;
-		return 1;
+		return NETDEV_TX_BUSY;
 	}
 
 	/*
diff --git a/drivers/net/mac89x0.c b/drivers/net/mac89x0.c
index e24175a..dab4533 100644
--- a/drivers/net/mac89x0.c
+++ b/drivers/net/mac89x0.c
@@ -400,7 +400,7 @@ net_send_packet(struct sk_buff *skb, struct net_device *dev)
 		/* Gasp!  It hasn't.  But that shouldn't happen since
 		   we're waiting for TxOk, so return 1 and requeue this packet. */
 		local_irq_restore(flags);
-		return 1;
+		return NETDEV_TX_BUSY;
 	}
 
 	/* Write the contents of the packet */
diff --git a/drivers/net/macb.c b/drivers/net/macb.c
index 7222659..5b5c253 100644
--- a/drivers/net/macb.c
+++ b/drivers/net/macb.c
@@ -645,7 +645,7 @@ static int macb_start_xmit(struct sk_buff *skb, struct net_device *dev)
 			"BUG! Tx Ring full when queue awake!\n");
 		dev_dbg(&bp->pdev->dev, "tx_head = %u, tx_tail = %u\n",
 			bp->tx_head, bp->tx_tail);
-		return 1;
+		return NETDEV_TX_BUSY;
 	}
 
 	entry = bp->tx_head;
diff --git a/drivers/net/mace.c b/drivers/net/mace.c
index 1ad740b..1427755 100644
--- a/drivers/net/mace.c
+++ b/drivers/net/mace.c
@@ -547,7 +547,7 @@ static int mace_xmit_start(struct sk_buff *skb, struct net_device *dev)
 	netif_stop_queue(dev);
 	mp->tx_fullup = 1;
 	spin_unlock_irqrestore(&mp->lock, flags);
-	return 1;		/* can't take it at the moment */
+	return NETDEV_TX_BUSY;		/* can't take it at the moment */
     }
     spin_unlock_irqrestore(&mp->lock, flags);
 
diff --git a/drivers/net/myri10ge/myri10ge.c b/drivers/net/myri10ge/myri10ge.c
index c9a30d3..1f6e36e 100644
--- a/drivers/net/myri10ge/myri10ge.c
+++ b/drivers/net/myri10ge/myri10ge.c
@@ -2687,7 +2687,7 @@ again:
 		/* we are out of transmit resources */
 		tx->stop_queue++;
 		netif_tx_stop_queue(netdev_queue);
-		return 1;
+		return NETDEV_TX_BUSY;
 	}
 
 	/* Setup checksum offloading, if needed */
diff --git a/drivers/net/myri_sbus.c b/drivers/net/myri_sbus.c
index 9a802ad..5f0758b 100644
--- a/drivers/net/myri_sbus.c
+++ b/drivers/net/myri_sbus.c
@@ -640,7 +640,7 @@ static int myri_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	if (!TX_BUFFS_AVAIL(head, tail)) {
 		DTX(("no buffs available, returning 1\n"));
-		return 1;
+		return NETDEV_TX_BUSY;
 	}
 
 	spin_lock_irqsave(&mp->irq_lock, flags);
diff --git a/drivers/net/ni65.c b/drivers/net/ni65.c
index 6474f02..1f10ed6 100644
--- a/drivers/net/ni65.c
+++ b/drivers/net/ni65.c
@@ -1165,7 +1165,7 @@ static int ni65_send_packet(struct sk_buff *skb, struct net_device *dev)
 
 	if (test_and_set_bit(0, (void*)&p->lock)) {
 		printk(KERN_ERR "%s: Queue was locked.\n", dev->name);
-		return 1;
+		return NETDEV_TX_BUSY;
 	}
 
 	{
diff --git a/drivers/net/ns83820.c b/drivers/net/ns83820.c
index 940962a..1576ac0 100644
--- a/drivers/net/ns83820.c
+++ b/drivers/net/ns83820.c
@@ -1097,7 +1097,7 @@ again:
 	if (unlikely(dev->CFG_cache & CFG_LNKSTS)) {
 		netif_stop_queue(ndev);
 		if (unlikely(dev->CFG_cache & CFG_LNKSTS))
-			return 1;
+			return NETDEV_TX_BUSY;
 		netif_start_queue(ndev);
 	}
 
@@ -1115,7 +1115,7 @@ again:
 			netif_start_queue(ndev);
 			goto again;
 		}
-		return 1;
+		return NETDEV_TX_BUSY;
 	}
 
 	if (free_idx == dev->tx_intr_idx) {
diff --git a/drivers/net/pcmcia/axnet_cs.c b/drivers/net/pcmcia/axnet_cs.c
index 15b8fe6..0e38d80 100644
--- a/drivers/net/pcmcia/axnet_cs.c
+++ b/drivers/net/pcmcia/axnet_cs.c
@@ -1130,7 +1130,7 @@ static int axnet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		outb_p(ENISR_ALL, e8390_base + EN0_IMR);
 		spin_unlock_irqrestore(&ei_local->page_lock, flags);
 		dev->stats.tx_errors++;
-		return 1;
+		return NETDEV_TX_BUSY;
 	}
 
 	/*
diff --git a/drivers/net/pcmcia/fmvj18x_cs.c b/drivers/net/pcmcia/fmvj18x_cs.c
index 81e6660..479d5b4 100644
--- a/drivers/net/pcmcia/fmvj18x_cs.c
+++ b/drivers/net/pcmcia/fmvj18x_cs.c
@@ -877,7 +877,7 @@ static int fjn_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (length > ETH_FRAME_LEN) {
 	    printk(KERN_NOTICE "%s: Attempting to send a large packet"
 		   " (%d bytes).\n", dev->name, length);
-	    return 1;
+	    return NETDEV_TX_BUSY;
 	}
 
 	DEBUG(4, "%s: Transmitting a packet of length %lu.\n",
diff --git a/drivers/net/pcmcia/smc91c92_cs.c b/drivers/net/pcmcia/smc91c92_cs.c
index 48dbb35..37e05d3 100644
--- a/drivers/net/pcmcia/smc91c92_cs.c
+++ b/drivers/net/pcmcia/smc91c92_cs.c
@@ -1388,7 +1388,7 @@ static int smc_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	dev->stats.tx_aborted_errors++;
 	printk(KERN_DEBUG "%s: Internal error -- sent packet while busy.\n",
 	       dev->name);
-	return 1;
+	return NETDEV_TX_BUSY;
     }
     smc->saved_skb = skb;
 
diff --git a/drivers/net/pcmcia/xirc2ps_cs.c b/drivers/net/pcmcia/xirc2ps_cs.c
index a3685c0..ef37d22 100644
--- a/drivers/net/pcmcia/xirc2ps_cs.c
+++ b/drivers/net/pcmcia/xirc2ps_cs.c
@@ -1399,7 +1399,7 @@ do_start_xmit(struct sk_buff *skb, struct net_device *dev)
     DEBUG(2 + (okay ? 2 : 0), "%s: avail. tx space=%u%s\n",
 	  dev->name, freespace, okay ? " (okay)":" (not enough)");
     if (!okay) { /* not enough space */
-	return 1;  /* upper layer may decide to requeue this packet */
+	return NETDEV_TX_BUSY;  /* upper layer may decide to requeue this packet */
     }
     /* send the packet */
     PutWord(XIRCREG_EDP, (u_short)pktlen);
diff --git a/drivers/net/plip.c b/drivers/net/plip.c
index 0be0f0b..7a62f78 100644
--- a/drivers/net/plip.c
+++ b/drivers/net/plip.c
@@ -955,12 +955,12 @@ plip_tx_packet(struct sk_buff *skb, struct net_device *dev)
 	struct plip_local *snd = &nl->snd_data;
 
 	if (netif_queue_stopped(dev))
-		return 1;
+		return NETDEV_TX_BUSY;
 
 	/* We may need to grab the bus */
 	if (!nl->port_owner) {
 		if (parport_claim(nl->pardev))
-			return 1;
+			return NETDEV_TX_BUSY;
 		nl->port_owner = 1;
 	}
 
@@ -969,7 +969,7 @@ plip_tx_packet(struct sk_buff *skb, struct net_device *dev)
 	if (skb->len > dev->mtu + dev->hard_header_len) {
 		printk(KERN_WARNING "%s: packet too big, %d.\n", dev->name, (int)skb->len);
 		netif_start_queue (dev);
-		return 1;
+		return NETDEV_TX_BUSY;
 	}
 
 	if (net_debug > 2)
diff --git a/drivers/net/sb1250-mac.c b/drivers/net/sb1250-mac.c
index 7a4b9fb..d8c9cf1 100644
--- a/drivers/net/sb1250-mac.c
+++ b/drivers/net/sb1250-mac.c
@@ -2084,7 +2084,7 @@ static int sbmac_start_tx(struct sk_buff *skb, struct net_device *dev)
 		netif_stop_queue(dev);
 		spin_unlock_irqrestore(&sc->sbm_lock, flags);
 
-		return 1;
+		return NETDEV_TX_BUSY;
 	}
 
 	dev->trans_start = jiffies;
diff --git a/drivers/net/sh_eth.c b/drivers/net/sh_eth.c
index 0709b75..341882f 100644
--- a/drivers/net/sh_eth.c
+++ b/drivers/net/sh_eth.c
@@ -1108,7 +1108,7 @@ static int sh_eth_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 		if (!sh_eth_txfree(ndev)) {
 			netif_stop_queue(ndev);
 			spin_unlock_irqrestore(&mdp->lock, flags);
-			return 1;
+			return NETDEV_TX_BUSY;
 		}
 	}
 	spin_unlock_irqrestore(&mdp->lock, flags);
diff --git a/drivers/net/sis900.c b/drivers/net/sis900.c
index 2d4617b..a9a897b 100644
--- a/drivers/net/sis900.c
+++ b/drivers/net/sis900.c
@@ -1584,7 +1584,7 @@ sis900_start_xmit(struct sk_buff *skb, struct net_device *net_dev)
 	/* Don't transmit data before the complete of auto-negotiation */
 	if(!sis_priv->autong_complete){
 		netif_stop_queue(net_dev);
-		return 1;
+		return NETDEV_TX_BUSY;
 	}
 
 	spin_lock_irqsave(&sis_priv->lock, flags);
diff --git a/drivers/net/skfp/skfddi.c b/drivers/net/skfp/skfddi.c
index 19d343c..088fe26 100644
--- a/drivers/net/skfp/skfddi.c
+++ b/drivers/net/skfp/skfddi.c
@@ -1082,7 +1082,7 @@ static int skfp_send_pkt(struct sk_buff *skb, struct net_device *dev)
 	if (bp->QueueSkb == 0) {	// return with tbusy set: queue full
 
 		netif_stop_queue(dev);
-		return 1;
+		return NETDEV_TX_BUSY;
 	}
 	bp->QueueSkb--;
 	skb_queue_tail(&bp->SendSkbQueue, skb);
diff --git a/drivers/net/smc9194.c b/drivers/net/smc9194.c
index 9a7973a..e02471b 100644
--- a/drivers/net/smc9194.c
+++ b/drivers/net/smc9194.c
@@ -503,7 +503,7 @@ static int smc_wait_to_send_packet( struct sk_buff * skb, struct net_device * de
 		/* THIS SHOULD NEVER HAPPEN. */
 		dev->stats.tx_aborted_errors++;
 		printk(CARDNAME": Bad Craziness - sent packet while busy.\n" );
-		return 1;
+		return NETDEV_TX_BUSY;
 	}
 	lp->saved_skb = skb;
 
diff --git a/drivers/net/sonic.c b/drivers/net/sonic.c
index 211e805..e4255d8 100644
--- a/drivers/net/sonic.c
+++ b/drivers/net/sonic.c
@@ -223,7 +223,7 @@ static int sonic_send_packet(struct sk_buff *skb, struct net_device *dev)
 	if (!laddr) {
 		printk(KERN_ERR "%s: failed to map tx DMA buffer.\n", dev->name);
 		dev_kfree_skb(skb);
-		return 1;
+		return NETDEV_TX_BUSY
 	}
 
 	sonic_tda_put(dev, entry, SONIC_TD_STATUS, 0);       /* clear status */
diff --git a/drivers/net/starfire.c b/drivers/net/starfire.c
index fcb943f..838cce8 100644
--- a/drivers/net/starfire.c
+++ b/drivers/net/starfire.c
@@ -1236,7 +1236,7 @@ static int start_tx(struct sk_buff *skb, struct net_device *dev)
 	 */
 	if ((np->cur_tx - np->dirty_tx) + skb_num_frags(skb) * 2 > TX_RING_SIZE) {
 		netif_stop_queue(dev);
-		return 1;
+		return NETDEV_TX_BUSY;
 	}
 
 #if defined(ZEROCOPY) && defined(HAS_BROKEN_FIRMWARE)
diff --git a/drivers/net/sun3_82586.c b/drivers/net/sun3_82586.c
index a39c0b9..7bb2742 100644
--- a/drivers/net/sun3_82586.c
+++ b/drivers/net/sun3_82586.c
@@ -1023,7 +1023,7 @@ static int sun3_82586_send_packet(struct sk_buff *skb, struct net_device *dev)
 #if(NUM_XMIT_BUFFS > 1)
 	if(test_and_set_bit(0,(void *) &p->lock)) {
 		printk("%s: Queue was locked\n",dev->name);
-		return 1;
+		return NETDEV_TX_BUSY;
 	}
 	else
 #endif
diff --git a/drivers/net/sun3lance.c b/drivers/net/sun3lance.c
index 9bd9dad..534dfe3 100644
--- a/drivers/net/sun3lance.c
+++ b/drivers/net/sun3lance.c
@@ -526,7 +526,7 @@ static int lance_start_xmit( struct sk_buff *skb, struct net_device *dev )
 	if (netif_queue_stopped(dev)) {
 		int tickssofar = jiffies - dev->trans_start;
 		if (tickssofar < 20)
-			return( 1 );
+			return NETDEV_TX_BUSY;
 
 		DPRINTK( 1, ( "%s: transmit timed out, status %04x, resetting.\n",
 					  dev->name, DREG ));
@@ -577,7 +577,7 @@ static int lance_start_xmit( struct sk_buff *skb, struct net_device *dev )
 	if (test_and_set_bit( 0, (void*)&lp->lock ) != 0) {
 		printk( "%s: tx queue lock!.\n", dev->name);
 		/* don't clear dev->tbusy flag. */
-		return 1;
+		return NETDEV_TX_BUSY;
 	}
 
 	AREG = CSR0;
diff --git a/drivers/net/sunhme.c b/drivers/net/sunhme.c
index 4e9bd38..4ef7291 100644
--- a/drivers/net/sunhme.c
+++ b/drivers/net/sunhme.c
@@ -2275,7 +2275,7 @@ static int happy_meal_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		spin_unlock_irq(&hp->happy_lock);
 		printk(KERN_ERR "%s: BUG! Tx Ring full when queue awake!\n",
 		       dev->name);
-		return 1;
+		return NETDEV_TX_BUSY;
 	}
 
 	entry = hp->tx_new;
diff --git a/drivers/net/tlan.c b/drivers/net/tlan.c
index aa69649..384cb5e 100644
--- a/drivers/net/tlan.c
+++ b/drivers/net/tlan.c
@@ -1111,7 +1111,7 @@ static int TLan_StartTx( struct sk_buff *skb, struct net_device *dev )
 			  dev->name, priv->txHead, priv->txTail );
 		netif_stop_queue(dev);
 		priv->txBusyCount++;
-		return 1;
+		return NETDEV_TX_BUSY;
 	}
 
 	tail_list->forward = 0;
diff --git a/drivers/net/tokenring/3c359.c b/drivers/net/tokenring/3c359.c
index 534c0f3..13dbc59 100644
--- a/drivers/net/tokenring/3c359.c
+++ b/drivers/net/tokenring/3c359.c
@@ -1243,7 +1243,7 @@ static int xl_xmit(struct sk_buff *skb, struct net_device *dev)
 		return 0;
 	} else {
 		spin_unlock_irqrestore(&xl_priv->xl_lock,flags) ; 
-		return 1;
+		return NETDEV_TX_BUSY;
 	}
 
 }
diff --git a/drivers/net/tokenring/lanstreamer.c b/drivers/net/tokenring/lanstreamer.c
index 2e70ee8..b358bbb 100644
--- a/drivers/net/tokenring/lanstreamer.c
+++ b/drivers/net/tokenring/lanstreamer.c
@@ -1187,7 +1187,7 @@ static int streamer_xmit(struct sk_buff *skb, struct net_device *dev)
 	} else {
 	        netif_stop_queue(dev);
 	        spin_unlock_irqrestore(&streamer_priv->streamer_lock,flags);
-		return 1;
+		return NETDEV_TX_BUSY;
 	}
 }
 
diff --git a/drivers/net/tokenring/olympic.c b/drivers/net/tokenring/olympic.c
index d068a9d..c369749 100644
--- a/drivers/net/tokenring/olympic.c
+++ b/drivers/net/tokenring/olympic.c
@@ -1055,7 +1055,7 @@ static int olympic_xmit(struct sk_buff *skb, struct net_device *dev)
 		return 0;
 	} else {
 		spin_unlock_irqrestore(&olympic_priv->olympic_lock,flags);
-		return 1;
+		return NETDEV_TX_BUSY;
 	} 
 
 }
diff --git a/drivers/net/tokenring/smctr.c b/drivers/net/tokenring/smctr.c
index a91d9c5..54ad4ed 100644
--- a/drivers/net/tokenring/smctr.c
+++ b/drivers/net/tokenring/smctr.c
@@ -4601,7 +4601,7 @@ static int smctr_send_packet(struct sk_buff *skb, struct net_device *dev)
         netif_stop_queue(dev);
 
         if(tp->QueueSkb == 0)
-                return (1);     /* Return with tbusy set: queue full */
+                return NETDEV_TX_BUSY;     /* Return with tbusy set: queue full */
 
         tp->QueueSkb--;
         skb_queue_tail(&tp->SendSkbQueue, skb);
diff --git a/drivers/net/tokenring/tms380tr.c b/drivers/net/tokenring/tms380tr.c
index b11bb72..a2eab72 100644
--- a/drivers/net/tokenring/tms380tr.c
+++ b/drivers/net/tokenring/tms380tr.c
@@ -633,7 +633,7 @@ static int tms380tr_hardware_send_packet(struct sk_buff *skb, struct net_device
 		if (tms380tr_debug > 0)
 			printk(KERN_DEBUG "%s: No free TPL\n", dev->name);
 		spin_unlock_irqrestore(&tp->lock, flags);
-		return 1;
+		return NETDEV_TX_BUSY;
 	}
 
 	dmabuf = 0;
diff --git a/drivers/net/tulip/de2104x.c b/drivers/net/tulip/de2104x.c
index e7609a0..81f054d 100644
--- a/drivers/net/tulip/de2104x.c
+++ b/drivers/net/tulip/de2104x.c
@@ -612,7 +612,7 @@ static int de_start_xmit (struct sk_buff *skb, struct net_device *dev)
 	if (tx_free == 0) {
 		netif_stop_queue(dev);
 		spin_unlock_irq(&de->lock);
-		return 1;
+		return NETDEV_TX_BUSY;
 	}
 	tx_free--;
 
diff --git a/drivers/net/tulip/de4x5.c b/drivers/net/tulip/de4x5.c
index 3225617..eb72d2e 100644
--- a/drivers/net/tulip/de4x5.c
+++ b/drivers/net/tulip/de4x5.c
@@ -1461,12 +1461,12 @@ de4x5_queue_pkt(struct sk_buff *skb, struct net_device *dev)
 {
     struct de4x5_private *lp = netdev_priv(dev);
     u_long iobase = dev->base_addr;
-    int status = 0;
+    int status = NETDEV_TX_OK;
     u_long flags = 0;
 
     netif_stop_queue(dev);
     if (!lp->tx_enable) {                   /* Cannot send for now */
-	return -1;
+	return NETDEV_TX_LOCKED;
     }
 
     /*
@@ -1480,7 +1480,7 @@ de4x5_queue_pkt(struct sk_buff *skb, struct net_device *dev)
 
     /* Test if cache is already locked - requeue skb if so */
     if (test_and_set_bit(0, (void *)&lp->cache.lock) && !lp->interrupt)
-	return -1;
+	return NETDEV_TX_LOCKED;
 
     /* Transmit descriptor ring full or stale skb */
     if (netif_queue_stopped(dev) || (u_long) lp->tx_skb[lp->tx_new] > 1) {
diff --git a/drivers/net/tulip/dmfe.c b/drivers/net/tulip/dmfe.c
index f2e6699..8e78f00 100644
--- a/drivers/net/tulip/dmfe.c
+++ b/drivers/net/tulip/dmfe.c
@@ -686,7 +686,7 @@ static int dmfe_start_xmit(struct sk_buff *skb, struct DEVICE *dev)
 		spin_unlock_irqrestore(&db->lock, flags);
 		printk(KERN_ERR DRV_NAME ": No Tx resource %ld\n",
 		       db->tx_queue_cnt);
-		return 1;
+		return NETDEV_TX_BUSY;
 	}
 
 	/* Disable NIC interrupt */
diff --git a/drivers/net/tulip/uli526x.c b/drivers/net/tulip/uli526x.c
index 8761a5a..9277ce8 100644
--- a/drivers/net/tulip/uli526x.c
+++ b/drivers/net/tulip/uli526x.c
@@ -591,7 +591,7 @@ static int uli526x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (db->tx_packet_cnt >= TX_FREE_DESC_CNT) {
 		spin_unlock_irqrestore(&db->lock, flags);
 		printk(KERN_ERR DRV_NAME ": No Tx resource %ld\n", db->tx_packet_cnt);
-		return 1;
+		return NETDEV_TX_BUSY;
 	}
 
 	/* Disable NIC interrupt */
diff --git a/drivers/net/wan/dlci.c b/drivers/net/wan/dlci.c
index e8d155c..2fa275a 100644
--- a/drivers/net/wan/dlci.c
+++ b/drivers/net/wan/dlci.c
@@ -205,15 +205,15 @@ static int dlci_transmit(struct sk_buff *skb, struct net_device *dev)
 	{
 		case DLCI_RET_OK:
 			dev->stats.tx_packets++;
-			ret = 0;
+			ret = NETDEV_TX_OK;
 			break;
 			case DLCI_RET_ERR:
 			dev->stats.tx_errors++;
-			ret = 0;
+			ret = NETDEV_TX_OK;
 			break;
 			case DLCI_RET_DROP:
 			dev->stats.tx_dropped++;
-			ret = 1;
+			ret = NETDEV_TX_BUSY;
 			break;
 	}
 	/* Alan Cox recommends always returning 0, and always freeing the packet */
diff --git a/drivers/net/wan/sbni.c b/drivers/net/wan/sbni.c
index f4211fe..3fb9dbc 100644
--- a/drivers/net/wan/sbni.c
+++ b/drivers/net/wan/sbni.c
@@ -469,7 +469,7 @@ sbni_start_xmit( struct sk_buff  *skb,  struct net_device  *dev )
 		}
 	}
 
-	return  1;
+	return NETDEV_TX_BUSY;
 }
 
 #else	/* CONFIG_SBNI_MULTILINE */
diff --git a/drivers/net/wan/wanxl.c b/drivers/net/wan/wanxl.c
index 8130b79..e4ad7b6 100644
--- a/drivers/net/wan/wanxl.c
+++ b/drivers/net/wan/wanxl.c
@@ -283,7 +283,7 @@ static int wanxl_xmit(struct sk_buff *skb, struct net_device *dev)
 #endif
 		netif_stop_queue(dev);
 		spin_unlock_irq(&port->lock);
-		return 1;       /* request packet to be queued */
+		return NETDEV_TX_BUSY;       /* request packet to be queued */
 	}
 
 #ifdef DEBUG_PKT
diff --git a/drivers/net/wireless/airo.c b/drivers/net/wireless/airo.c
index dfb30b9..c70604f 100644
--- a/drivers/net/wireless/airo.c
+++ b/drivers/net/wireless/airo.c
@@ -1935,7 +1935,7 @@ static int mpi_start_xmit(struct sk_buff *skb, struct net_device *dev) {
 		netif_stop_queue (dev);
 		if (npacks > MAXTXQ) {
 			dev->stats.tx_fifo_errors++;
-			return 1;
+			return NETDEV_TX_BUSY;
 		}
 		skb_queue_tail (&ai->txq, skb);
 		return 0;
@@ -2139,7 +2139,7 @@ static int airo_start_xmit(struct sk_buff *skb, struct net_device *dev) {
 
 		if (i == MAX_FIDS / 2) {
 			dev->stats.tx_fifo_errors++;
-			return 1;
+			return NETDEV_TX_BUSY;
 		}
 	}
 	/* check min length*/
@@ -2211,7 +2211,7 @@ static int airo_start_xmit11(struct sk_buff *skb, struct net_device *dev) {
 
 		if (i == MAX_FIDS) {
 			dev->stats.tx_fifo_errors++;
-			return 1;
+			return NETDEV_TX_BUSY;
 		}
 	}
 	/* check min length*/
diff --git a/drivers/net/wireless/arlan-main.c b/drivers/net/wireless/arlan-main.c
index a54a67c..d84caf1 100644
--- a/drivers/net/wireless/arlan-main.c
+++ b/drivers/net/wireless/arlan-main.c
@@ -1199,7 +1199,7 @@ bad_end:
 	arlan_process_interrupt(dev);
 	netif_stop_queue (dev);
 	ARLAN_DEBUG_EXIT("arlan_tx");
-	return 1;
+	return NETDEV_TX_BUSY;
 }
 
 
diff --git a/drivers/net/wireless/atmel.c b/drivers/net/wireless/atmel.c
index 27eef8f..291a94b 100644
--- a/drivers/net/wireless/atmel.c
+++ b/drivers/net/wireless/atmel.c
@@ -818,7 +818,7 @@ static int start_tx(struct sk_buff *skb, struct net_device *dev)
 		spin_unlock_irqrestore(&priv->irqlock, flags);
 		spin_unlock_bh(&priv->timerlock);
 		netif_stop_queue(dev);
-		return 1;
+		return NETDEV_TX_BUSY;
 	}
 
 	frame_ctl = IEEE80211_FTYPE_DATA;
diff --git a/drivers/net/wireless/hostap/hostap_80211_tx.c b/drivers/net/wireless/hostap/hostap_80211_tx.c
index 6693423..d313b00 100644
--- a/drivers/net/wireless/hostap/hostap_80211_tx.c
+++ b/drivers/net/wireless/hostap/hostap_80211_tx.c
@@ -377,7 +377,7 @@ int hostap_master_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct hostap_interface *iface;
 	local_info_t *local;
-	int ret = 1;
+	int ret = NETDEV_TX_BUSY;
 	u16 fc;
 	struct hostap_tx_data tx;
 	ap_tx_ret tx_ret;
diff --git a/drivers/net/wireless/ipw2x00/libipw_tx.c b/drivers/net/wireless/ipw2x00/libipw_tx.c
index 65a8195..da2ad54 100644
--- a/drivers/net/wireless/ipw2x00/libipw_tx.c
+++ b/drivers/net/wireless/ipw2x00/libipw_tx.c
@@ -539,7 +539,7 @@ int ieee80211_xmit(struct sk_buff *skb, struct net_device *dev)
 	spin_unlock_irqrestore(&ieee->lock, flags);
 	netif_stop_queue(dev);
 	dev->stats.tx_errors++;
-	return 1;
+	return NETDEV_TX_BUSY;
 }
 EXPORT_SYMBOL(ieee80211_xmit);
 
diff --git a/drivers/net/wireless/ray_cs.c b/drivers/net/wireless/ray_cs.c
index 22e7185..b10b038 100644
--- a/drivers/net/wireless/ray_cs.c
+++ b/drivers/net/wireless/ray_cs.c
@@ -923,7 +923,7 @@ static int ray_dev_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	if (!(pcmcia_dev_present(link))) {
 		DEBUG(2, "ray_dev_start_xmit - device not present\n");
-		return -1;
+		return NETDEV_TX_LOCKED;
 	}
 	DEBUG(3, "ray_dev_start_xmit(skb=%p, dev=%p)\n", skb, dev);
 	if (local->authentication_state == NEED_TO_AUTH) {
@@ -931,7 +931,7 @@ static int ray_dev_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		if (!build_auth_frame(local, local->auth_id, OPEN_AUTH_REQUEST)) {
 			local->authentication_state = AUTHENTICATED;
 			netif_stop_queue(dev);
-			return 1;
+			return NETDEV_TX_BUSY;
 		}
 	}
 
@@ -944,7 +944,7 @@ static int ray_dev_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	case XMIT_NO_CCS:
 	case XMIT_NEED_AUTH:
 		netif_stop_queue(dev);
-		return 1;
+		return NETDEV_TX_BUSY;
 	case XMIT_NO_INTR:
 	case XMIT_MSG_BAD:
 	case XMIT_OK:
diff --git a/drivers/net/wireless/strip.c b/drivers/net/wireless/strip.c
index b7b0c46..38366a5 100644
--- a/drivers/net/wireless/strip.c
+++ b/drivers/net/wireless/strip.c
@@ -1540,7 +1540,7 @@ static int strip_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (!netif_running(dev)) {
 		printk(KERN_ERR "%s: xmit call when iface is down\n",
 		       dev->name);
-		return (1);
+		return NETDEV_TX_BUSY;
 	}
 
 	netif_stop_queue(dev);
diff --git a/drivers/net/wireless/wavelan.c b/drivers/net/wireless/wavelan.c
index 25d27b6..ab7fc5c 100644
--- a/drivers/net/wireless/wavelan.c
+++ b/drivers/net/wireless/wavelan.c
@@ -2867,7 +2867,7 @@ static int wavelan_packet_xmit(struct sk_buff *skb, struct net_device * dev)
 		spin_unlock_irqrestore(&lp->spinlock, flags);
 		/* Check that we can continue */
 		if (lp->tx_n_in_use == (NTXBLOCKS - 1))
-			return 1;
+			return NETDEV_TX_BUSY;
 	}
 
 	/* Do we need some padding? */
@@ -2880,10 +2880,10 @@ static int wavelan_packet_xmit(struct sk_buff *skb, struct net_device * dev)
 		skb_copy_from_linear_data(skb, data, skb->len);
 		/* Write packet on the card */
 		if(wv_packet_write(dev, data, ETH_ZLEN))
-			return 1;	/* We failed */
+			return NETDEV_TX_BUSY;	/* We failed */
 	}
 	else if(wv_packet_write(dev, skb->data, skb->len))
-		return 1;	/* We failed */
+		return NETDEV_TX_BUSY;	/* We failed */
 
 
 	dev_kfree_skb(skb);
diff --git a/drivers/s390/net/netiucv.c b/drivers/s390/net/netiucv.c
index be716e4..aec9e5d 100644
--- a/drivers/s390/net/netiucv.c
+++ b/drivers/s390/net/netiucv.c
@@ -1315,9 +1315,9 @@ static int netiucv_tx(struct sk_buff *skb, struct net_device *dev)
 		return NETDEV_TX_BUSY;
 	}
 	dev->trans_start = jiffies;
-	rc = netiucv_transmit_skb(privptr->conn, skb) != 0;
+	rc = netiucv_transmit_skb(privptr->conn, skb);
 	netiucv_clear_busy(dev);
-	return rc;
+	return rc ? NETDEV_TX_BUSY : NETDEV_TX_OK;
 }
 
 /**
diff --git a/drivers/staging/et131x/et131x_netdev.c b/drivers/staging/et131x/et131x_netdev.c
index 951c73d..59e99cc 100644
--- a/drivers/staging/et131x/et131x_netdev.c
+++ b/drivers/staging/et131x/et131x_netdev.c
@@ -585,11 +585,11 @@ int et131x_tx(struct sk_buff *skb, struct net_device *netdev)
 			 * available
 			 */
 			netif_stop_queue(netdev);
-			status = 1;
+			status = NETDEV_TX_BUSY;
 		} else {
 			DBG_WARNING(et131x_dbginfo,
 				    "Misc error; drop packet\n");
-			status = 0;
+			status = NETDEV_TX_OK;
 		}
 	}
 
diff --git a/drivers/staging/rtl8187se/ieee80211/ieee80211_tx.c b/drivers/staging/rtl8187se/ieee80211/ieee80211_tx.c
index 33a0687..1294e05 100644
--- a/drivers/staging/rtl8187se/ieee80211/ieee80211_tx.c
+++ b/drivers/staging/rtl8187se/ieee80211/ieee80211_tx.c
@@ -814,7 +814,7 @@ int ieee80211_xmit(struct sk_buff *skb,
 	spin_unlock_irqrestore(&ieee->lock, flags);
 	netif_stop_queue(dev);
 	stats->tx_errors++;
-	return 1;
+	return NETDEV_TX_BUSY;
 
 }
 
diff --git a/drivers/staging/wlan-ng/p80211netdev.c b/drivers/staging/wlan-ng/p80211netdev.c
index 393e4df..bc0d764 100644
--- a/drivers/staging/wlan-ng/p80211netdev.c
+++ b/drivers/staging/wlan-ng/p80211netdev.c
@@ -432,21 +432,21 @@ static int p80211knetdev_hard_start_xmit(struct sk_buff *skb,
 		/* success and more buf */
 		/* avail, re: hw_txdata */
 		netif_wake_queue(wlandev->netdev);
-		result = 0;
+		result = NETDEV_TX_OK;
 	} else if (txresult == 1) {
 		/* success, no more avail */
 		pr_debug("txframe success, no more bufs\n");
 		/* netdev->tbusy = 1;  don't set here, irqhdlr */
 		/*   may have already cleared it */
-		result = 0;
+		result = NETDEV_TX_OK;
 	} else if (txresult == 2) {
 		/* alloc failure, drop frame */
 		pr_debug("txframe returned alloc_fail\n");
-		result = 1;
+		result = NETDEV_TX_BUSY;
 	} else {
 		/* buffer full or queue busy, drop frame. */
 		pr_debug("txframe returned full or busy\n");
-		result = 1;
+		result = NETDEV_TX_BUSY;
 	}
 
 failed:
diff --git a/drivers/usb/gadget/u_ether.c b/drivers/usb/gadget/u_ether.c
index 4007770..016f63b 100644
--- a/drivers/usb/gadget/u_ether.c
+++ b/drivers/usb/gadget/u_ether.c
@@ -520,7 +520,7 @@ static int eth_start_xmit(struct sk_buff *skb, struct net_device *net)
 	 */
 	if (list_empty(&dev->tx_reqs)) {
 		spin_unlock_irqrestore(&dev->req_lock, flags);
-		return 1;
+		return NETDEV_TX_BUSY;
 	}
 
 	req = container_of(dev->tx_reqs.next, struct usb_request, list);
diff --git a/net/mac80211/tx.c b/net/mac80211/tx.c
index 364222b..d238a89 100644
--- a/net/mac80211/tx.c
+++ b/net/mac80211/tx.c
@@ -1615,7 +1615,7 @@ int ieee80211_subif_start_xmit(struct sk_buff *skb,
 {
 	struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(dev);
 	struct ieee80211_local *local = sdata->local;
-	int ret = 1, head_need;
+	int ret = NETDEV_TX_BUSY, head_need;
 	u16 ethertype, hdrlen,  meshhdrlen = 0;
 	__le16 fc;
 	struct ieee80211_hdr hdr;
diff --git a/net/rose/rose_dev.c b/net/rose/rose_dev.c
index 7dcf256..389d6e0 100644
--- a/net/rose/rose_dev.c
+++ b/net/rose/rose_dev.c
@@ -137,7 +137,7 @@ static int rose_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	if (!netif_running(dev)) {
 		printk(KERN_ERR "ROSE: rose_xmit - called when iface is down\n");
-		return 1;
+		return NETDEV_TX_BUSY;
 	}
 	dev_kfree_skb(skb);
 	stats->tx_errors++;
diff --git a/net/sched/sch_teql.c b/net/sched/sch_teql.c
index cb1cb1e..9c002b6 100644
--- a/net/sched/sch_teql.c
+++ b/net/sched/sch_teql.c
@@ -338,7 +338,7 @@ restart:
 
 	if (busy) {
 		netif_stop_queue(dev);
-		return 1;
+		return NETDEV_TX_BUSY;
 	}
 	dev->stats.tx_errors++;
 

--------------040204090905050505040802--
