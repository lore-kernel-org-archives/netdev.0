From: Patrick McHardy <kaber@trash.net>
Subject: net: convert remaining non-symbolic return values in ndo_start_xmit()
 functions
Date: Tue, 23 Jun 2009 18:13:07 +0200
Message-ID: <4A40FF13.2060704@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030101090403030000040002"
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:47732 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759400AbZFWQNG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jun 2009 12:13:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------030101090403030000040002
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit


--------------030101090403030000040002
Content-Type: text/x-patch;
 name="02.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="02.diff"

commit 8b3823ce30a3e57249fe7f329896f146e6eb920d
Author: Patrick McHardy <kaber@trash.net>
Date:   Tue Jun 23 18:08:59 2009 +0200

    net: convert remaining non-symbolic return values in ndo_start_xmit() functions
    
    This patch converts the remaining occurences of raw return values to their
    symbolic counterparts in ndo_start_xmit() functions that were missed by the
    previous automatic conversion.
    
    Additionally code that assumed the symbolic value of NETDEV_TX_OK to be zero
    is changed to explicitly use NETDEV_TX_OK.
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/arch/xtensa/platforms/iss/network.c b/arch/xtensa/platforms/iss/network.c
index edad415..2f0b86b 100644
--- a/arch/xtensa/platforms/iss/network.c
+++ b/arch/xtensa/platforms/iss/network.c
@@ -545,7 +545,7 @@ static int iss_net_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	spin_unlock_irqrestore(&lp->lock, flags);
 
 	dev_kfree_skb(skb);
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 
diff --git a/drivers/isdn/hysdn/hysdn_net.c b/drivers/isdn/hysdn/hysdn_net.c
index 579974c..c73004b 100644
--- a/drivers/isdn/hysdn/hysdn_net.c
+++ b/drivers/isdn/hysdn/hysdn_net.c
@@ -148,7 +148,7 @@ net_send_packet(struct sk_buff *skb, struct net_device *dev)
 	if (lp->sk_count <= 3) {
 		schedule_work(&((hysdn_card *) dev->ml_priv)->irq_queue);
 	}
-	return (0);		/* success */
+	return NETDEV_TX_OK;	/* success */
 }				/* net_send_packet */
 
 
diff --git a/drivers/isdn/i4l/isdn_net.c b/drivers/isdn/i4l/isdn_net.c
index 8209ed6..57bf4bf 100644
--- a/drivers/isdn/i4l/isdn_net.c
+++ b/drivers/isdn/i4l/isdn_net.c
@@ -1051,12 +1051,12 @@ isdn_net_xmit(struct net_device *ndev, struct sk_buff *skb)
 	isdn_net_dev *nd;
 	isdn_net_local *slp;
 	isdn_net_local *lp = (isdn_net_local *) netdev_priv(ndev);
-	int retv = 0;
+	int retv = NETDEV_TX_OK;
 
 	if (((isdn_net_local *) netdev_priv(ndev))->master) {
 		printk("isdn BUG at %s:%d!\n", __FILE__, __LINE__);
 		dev_kfree_skb(skb);
-		return 0;
+		return NETDEV_TX_OK;
 	}
 
 	/* For the other encaps the header has already been built */
diff --git a/drivers/isdn/i4l/isdn_ppp.c b/drivers/isdn/i4l/isdn_ppp.c
index aa30b5c..2d14b64 100644
--- a/drivers/isdn/i4l/isdn_ppp.c
+++ b/drivers/isdn/i4l/isdn_ppp.c
@@ -1223,7 +1223,7 @@ isdn_ppp_xmit(struct sk_buff *skb, struct net_device *netdev)
 	isdn_net_dev *nd;
 	unsigned int proto = PPP_IP;     /* 0x21 */
 	struct ippp_struct *ipt,*ipts;
-	int slot, retval = 0;
+	int slot, retval = NETDEV_TX_OK;
 
 	mlp = (isdn_net_local *) netdev_priv(netdev);
 	nd = mlp->netdev;       /* get master lp */
@@ -1240,7 +1240,7 @@ isdn_ppp_xmit(struct sk_buff *skb, struct net_device *netdev)
 	if (!(ipts->pppcfg & SC_ENABLE_IP)) {	/* PPP connected ? */
 		if (ipts->debug & 0x1)
 			printk(KERN_INFO "%s: IP frame delayed.\n", netdev->name);
-		retval = 1;
+		retval = NETDEV_TX_BUSY;
 		goto out;
 	}
 
@@ -1261,7 +1261,7 @@ isdn_ppp_xmit(struct sk_buff *skb, struct net_device *netdev)
 	lp = isdn_net_get_locked_lp(nd);
 	if (!lp) {
 		printk(KERN_WARNING "%s: all channels busy - requeuing!\n", netdev->name);
-		retval = 1;
+		retval = NETDEV_TX_BUSY;
 		goto out;
 	}
 	/* we have our lp locked from now on */
diff --git a/drivers/net/3c501.c b/drivers/net/3c501.c
index 367bec6..e29fb1a 100644
--- a/drivers/net/3c501.c
+++ b/drivers/net/3c501.c
@@ -485,7 +485,7 @@ static int el_start_xmit(struct sk_buff *skb, struct net_device *dev)
 			if (el_debug > 2)
 				pr_debug(" queued xmit.\n");
 			dev_kfree_skb(skb);
-			return 0;
+			return NETDEV_TX_OK;
 		}
 		/* A receive upset our load, despite our best efforts */
 		if (el_debug > 2)
diff --git a/drivers/net/7990.c b/drivers/net/7990.c
index 69f5b7d..b1e5764 100644
--- a/drivers/net/7990.c
+++ b/drivers/net/7990.c
@@ -585,7 +585,7 @@ int lance_start_xmit (struct sk_buff *skb, struct net_device *dev)
 		lp->tx_full = 1;
 	spin_unlock_irqrestore (&lp->devlock, flags);
 
-        return 0;
+        return NETDEV_TX_OK;
 }
 EXPORT_SYMBOL_GPL(lance_start_xmit);
 
diff --git a/drivers/net/a2065.c b/drivers/net/a2065.c
index 85a1817..7302e43 100644
--- a/drivers/net/a2065.c
+++ b/drivers/net/a2065.c
@@ -553,11 +553,11 @@ static int lance_start_xmit (struct sk_buff *skb, struct net_device *dev)
 	volatile struct lance_regs *ll = lp->ll;
 	volatile struct lance_init_block *ib = lp->init_block;
 	int entry, skblen;
-	int status = 0;
+	int status = NETDEV_TX_OK;
 	unsigned long flags;
 
 	if (skb_padto(skb, ETH_ZLEN))
-		return 0;
+		return NETDEV_TX_OK;
 	skblen = max_t(unsigned, skb->len, ETH_ZLEN);
 
 	local_irq_save(flags);
diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index d4b5708..0e7dfe0 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -2431,7 +2431,7 @@ out:
 		dev_kfree_skb(skb);
 	}
 	read_unlock(&bond->lock);
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 int bond_3ad_lacpdu_recv(struct sk_buff *skb, struct net_device *dev, struct packet_type* ptype, struct net_device *orig_dev)
diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index 46d312b..bf45d20 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -1413,7 +1413,7 @@ out:
 	}
 	read_unlock(&bond->curr_slave_lock);
 	read_unlock(&bond->lock);
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 void bond_alb_monitor(struct work_struct *work)
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index d927f71..66596d8 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4277,7 +4277,7 @@ out:
 		dev_kfree_skb(skb);
 	}
 	read_unlock(&bond->lock);
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 
@@ -4308,7 +4308,7 @@ out:
 
 	read_unlock(&bond->curr_slave_lock);
 	read_unlock(&bond->lock);
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 /*
@@ -4354,7 +4354,7 @@ out:
 		dev_kfree_skb(skb);
 	}
 	read_unlock(&bond->lock);
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 /*
@@ -4414,7 +4414,7 @@ out:
 
 	/* frame sent to all suitable interfaces */
 	read_unlock(&bond->lock);
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 /*------------------------- Device initialization ---------------------------*/
diff --git a/drivers/net/defxx.c b/drivers/net/defxx.c
index 102b8d4..b2e0a8f 100644
--- a/drivers/net/defxx.c
+++ b/drivers/net/defxx.c
@@ -3218,7 +3218,7 @@ static int dfx_xmt_queue_pkt(
 		bp->xmt_length_errors++;		/* bump error counter */
 		netif_wake_queue(dev);
 		dev_kfree_skb(skb);
-		return(0);				/* return "success" */
+		return NETDEV_TX_OK;			/* return "success" */
 	}
 	/*
 	 * See if adapter link is available, if not, free buffer
@@ -3241,7 +3241,7 @@ static int dfx_xmt_queue_pkt(
 			bp->xmt_discards++;					/* bump error counter */
 			dev_kfree_skb(skb);		/* free sk_buff now */
 			netif_wake_queue(dev);
-			return(0);							/* return "success" */
+			return NETDEV_TX_OK;		/* return "success" */
 			}
 		}
 
@@ -3345,7 +3345,7 @@ static int dfx_xmt_queue_pkt(
 	dfx_port_write_long(bp, PI_PDQ_K_REG_TYPE_2_PROD, bp->rcv_xmt_reg.lword);
 	spin_unlock_irqrestore(&bp->lock, flags);
 	netif_wake_queue(dev);
-	return(0);							/* packet queued to adapter */
+	return NETDEV_TX_OK;	/* packet queued to adapter */
 	}
 
 
diff --git a/drivers/net/depca.c b/drivers/net/depca.c
index 97ea2d6..adb997c 100644
--- a/drivers/net/depca.c
+++ b/drivers/net/depca.c
@@ -1793,7 +1793,7 @@ static int __init get_hw_addr(struct net_device *dev)
 static int load_packet(struct net_device *dev, struct sk_buff *skb)
 {
 	struct depca_private *lp = netdev_priv(dev);
-	int i, entry, end, len, status = 0;
+	int i, entry, end, len, status = NETDEV_TX_OK;
 
 	entry = lp->tx_new;	/* Ring around buffer number. */
 	end = (entry + (skb->len - 1) / TX_BUFF_SZ) & lp->txRingMask;
diff --git a/drivers/net/ibm_newemac/core.c b/drivers/net/ibm_newemac/core.c
index beb8421..5443558 100644
--- a/drivers/net/ibm_newemac/core.c
+++ b/drivers/net/ibm_newemac/core.c
@@ -1342,7 +1342,7 @@ static inline int emac_xmit_finish(struct emac_instance *dev, int len)
 	++dev->stats.tx_packets;
 	dev->stats.tx_bytes += len;
 
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 /* Tx lock BH */
diff --git a/drivers/net/ifb.c b/drivers/net/ifb.c
index 96713ef..0a79b45 100644
--- a/drivers/net/ifb.c
+++ b/drivers/net/ifb.c
@@ -164,7 +164,7 @@ static int ifb_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct ifb_private *dp = netdev_priv(dev);
 	struct net_device_stats *stats = &dev->stats;
-	int ret = 0;
+	int ret = NETDEV_TX_OK;
 	u32 from = G_TC_FROM(skb->tc_verd);
 
 	stats->rx_packets++;
diff --git a/drivers/net/irda/ali-ircc.c b/drivers/net/irda/ali-ircc.c
index 7098357..f0d0cea 100644
--- a/drivers/net/irda/ali-ircc.c
+++ b/drivers/net/irda/ali-ircc.c
@@ -1966,10 +1966,10 @@ static int ali_ircc_sir_hard_xmit(struct sk_buff *skb, struct net_device *dev)
 	
 	IRDA_DEBUG(2, "%s(), ---------------- Start ----------------\n", __func__ );
 	
-	IRDA_ASSERT(dev != NULL, return 0;);
+	IRDA_ASSERT(dev != NULL, return NETDEV_TX_OK;);
 	
 	self = netdev_priv(dev);
-	IRDA_ASSERT(self != NULL, return 0;);
+	IRDA_ASSERT(self != NULL, return NETDEV_TX_OK;);
 
 	iobase = self->io.sir_base;
 
diff --git a/drivers/net/irda/donauboe.c b/drivers/net/irda/donauboe.c
index 1484c76..e4e9056 100644
--- a/drivers/net/irda/donauboe.c
+++ b/drivers/net/irda/donauboe.c
@@ -981,7 +981,7 @@ toshoboe_hard_xmit (struct sk_buff *skb, struct net_device *dev)
 
   self = netdev_priv(dev);
 
-  IRDA_ASSERT (self != NULL, return 0; );
+  IRDA_ASSERT (self != NULL, return NETDEV_TX_OK; );
 
   IRDA_DEBUG (1, "%s.tx:%x(%x)%x\n", __func__
       ,skb->len,self->txpending,INB (OBOE_ENABLEH));
diff --git a/drivers/net/irda/nsc-ircc.c b/drivers/net/irda/nsc-ircc.c
index 05bfc98..51ca89c 100644
--- a/drivers/net/irda/nsc-ircc.c
+++ b/drivers/net/irda/nsc-ircc.c
@@ -1365,7 +1365,7 @@ static int nsc_ircc_hard_xmit_sir(struct sk_buff *skb, struct net_device *dev)
 	
 	self = netdev_priv(dev);
 
-	IRDA_ASSERT(self != NULL, return 0;);
+	IRDA_ASSERT(self != NULL, return NETDEV_TX_OK;);
 
 	iobase = self->io.fir_base;
 
diff --git a/drivers/net/irda/sir_dev.c b/drivers/net/irda/sir_dev.c
index bde004f..71dce20 100644
--- a/drivers/net/irda/sir_dev.c
+++ b/drivers/net/irda/sir_dev.c
@@ -590,7 +590,7 @@ static int sirdev_hard_xmit(struct sk_buff *skb, struct net_device *ndev)
 	int err;
 	s32 speed;
 
-	IRDA_ASSERT(dev != NULL, return 0;);
+	IRDA_ASSERT(dev != NULL, return NETDEV_TX_OK;);
 
 	netif_stop_queue(ndev);
 
diff --git a/drivers/net/irda/smsc-ircc2.c b/drivers/net/irda/smsc-ircc2.c
index d0797ad..15f8a7f 100644
--- a/drivers/net/irda/smsc-ircc2.c
+++ b/drivers/net/irda/smsc-ircc2.c
@@ -886,10 +886,10 @@ static int smsc_ircc_hard_xmit_sir(struct sk_buff *skb, struct net_device *dev)
 
 	IRDA_DEBUG(1, "%s\n", __func__);
 
-	IRDA_ASSERT(dev != NULL, return 0;);
+	IRDA_ASSERT(dev != NULL, return NETDEV_TX_OK;);
 
 	self = netdev_priv(dev);
-	IRDA_ASSERT(self != NULL, return 0;);
+	IRDA_ASSERT(self != NULL, return NETDEV_TX_OK;);
 
 	netif_stop_queue(dev);
 
@@ -914,7 +914,7 @@ static int smsc_ircc_hard_xmit_sir(struct sk_buff *skb, struct net_device *dev)
 			smsc_ircc_change_speed(self, speed);
 			spin_unlock_irqrestore(&self->lock, flags);
 			dev_kfree_skb(skb);
-			return 0;
+			return NETDEV_TX_OK;
 		}
 		self->new_speed = speed;
 	}
@@ -935,7 +935,7 @@ static int smsc_ircc_hard_xmit_sir(struct sk_buff *skb, struct net_device *dev)
 
 	dev_kfree_skb(skb);
 
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 /*
@@ -1190,9 +1190,9 @@ static int smsc_ircc_hard_xmit_fir(struct sk_buff *skb, struct net_device *dev)
 	s32 speed;
 	int mtt;
 
-	IRDA_ASSERT(dev != NULL, return 0;);
+	IRDA_ASSERT(dev != NULL, return NETDEV_TX_OK;);
 	self = netdev_priv(dev);
-	IRDA_ASSERT(self != NULL, return 0;);
+	IRDA_ASSERT(self != NULL, return NETDEV_TX_OK;);
 
 	netif_stop_queue(dev);
 
@@ -1210,7 +1210,7 @@ static int smsc_ircc_hard_xmit_fir(struct sk_buff *skb, struct net_device *dev)
 			smsc_ircc_change_speed(self, speed);
 			spin_unlock_irqrestore(&self->lock, flags);
 			dev_kfree_skb(skb);
-			return 0;
+			return NETDEV_TX_OK;
 		}
 
 		self->new_speed = speed;
@@ -1242,7 +1242,7 @@ static int smsc_ircc_hard_xmit_fir(struct sk_buff *skb, struct net_device *dev)
 	spin_unlock_irqrestore(&self->lock, flags);
 	dev_kfree_skb(skb);
 
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 /*
diff --git a/drivers/net/irda/via-ircc.c b/drivers/net/irda/via-ircc.c
index 62ba94b..36a6074 100644
--- a/drivers/net/irda/via-ircc.c
+++ b/drivers/net/irda/via-ircc.c
@@ -832,7 +832,7 @@ static int via_ircc_hard_xmit_sir(struct sk_buff *skb,
 	__u32 speed;
 
 	self = netdev_priv(dev);
-	IRDA_ASSERT(self != NULL, return 0;);
+	IRDA_ASSERT(self != NULL, return NETDEV_TX_OK;);
 	iobase = self->io.fir_base;
 
 	netif_stop_queue(dev);
diff --git a/drivers/net/lib8390.c b/drivers/net/lib8390.c
index f28c233..d6be360 100644
--- a/drivers/net/lib8390.c
+++ b/drivers/net/lib8390.c
@@ -414,7 +414,7 @@ static int __ei_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	dev_kfree_skb (skb);
 	dev->stats.tx_bytes += send_length;
 
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 /**
diff --git a/drivers/net/mlx4/en_tx.c b/drivers/net/mlx4/en_tx.c
index 08c43f2..d5c18c6 100644
--- a/drivers/net/mlx4/en_tx.c
+++ b/drivers/net/mlx4/en_tx.c
@@ -764,7 +764,7 @@ int mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 	/* Poll CQ here */
 	mlx4_en_xmit_poll(priv, tx_ind);
 
-	return 0;
+	return NETDEV_TX_OK;
 
 tx_drop:
 	dev_kfree_skb_any(skb);
diff --git a/drivers/net/myri10ge/myri10ge.c b/drivers/net/myri10ge/myri10ge.c
index 05cd24d..1a34f7e 100644
--- a/drivers/net/myri10ge/myri10ge.c
+++ b/drivers/net/myri10ge/myri10ge.c
@@ -2968,13 +2968,13 @@ static int myri10ge_sw_tso(struct sk_buff *skb, struct net_device *dev)
 		}
 	}
 	dev_kfree_skb_any(skb);
-	return 0;
+	return NETDEV_TX_OK;
 
 drop:
 	ss = &mgp->ss[skb_get_queue_mapping(skb)];
 	dev_kfree_skb_any(skb);
 	ss->stats.tx_dropped += 1;
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 static struct net_device_stats *myri10ge_get_stats(struct net_device *dev)
diff --git a/drivers/net/ni52.c b/drivers/net/ni52.c
index 77d44a0..a0ac5d4 100644
--- a/drivers/net/ni52.c
+++ b/drivers/net/ni52.c
@@ -1183,7 +1183,7 @@ static int ni52_send_packet(struct sk_buff *skb, struct net_device *dev)
 
 	if (skb->len > XMIT_BUFF_SIZE) {
 		printk(KERN_ERR "%s: Sorry, max. framelength is %d bytes. The length of your frame is %d bytes.\n", dev->name, XMIT_BUFF_SIZE, skb->len);
-		return 0;
+		return NETDEV_TX_OK;
 	}
 
 	netif_stop_queue(dev);
@@ -1267,7 +1267,7 @@ static int ni52_send_packet(struct sk_buff *skb, struct net_device *dev)
 	}
 	dev_kfree_skb(skb);
 #endif
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 /*******************************************
diff --git a/drivers/net/skfp/skfddi.c b/drivers/net/skfp/skfddi.c
index 0c31272..888a14a 100644
--- a/drivers/net/skfp/skfddi.c
+++ b/drivers/net/skfp/skfddi.c
@@ -1077,7 +1077,7 @@ static int skfp_send_pkt(struct sk_buff *skb, struct net_device *dev)
 		// dequeue packets from xmt queue and send them
 		netif_start_queue(dev);
 		dev_kfree_skb(skb);
-		return (0);	/* return "success" */
+		return NETDEV_TX_OK;	/* return "success" */
 	}
 	if (bp->QueueSkb == 0) {	// return with tbusy set: queue full
 
diff --git a/drivers/net/sonic.c b/drivers/net/sonic.c
index 753a1fb..9599ce7 100644
--- a/drivers/net/sonic.c
+++ b/drivers/net/sonic.c
@@ -211,7 +211,7 @@ static int sonic_send_packet(struct sk_buff *skb, struct net_device *dev)
 	length = skb->len;
 	if (length < ETH_ZLEN) {
 		if (skb_padto(skb, ETH_ZLEN))
-			return 0;
+			return NETDEV_TX_OK;
 		length = ETH_ZLEN;
 	}
 
@@ -265,7 +265,7 @@ static int sonic_send_packet(struct sk_buff *skb, struct net_device *dev)
 
 	dev->trans_start = jiffies;
 
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 /*
diff --git a/drivers/net/tokenring/smctr.c b/drivers/net/tokenring/smctr.c
index 54ad4ed..6515894 100644
--- a/drivers/net/tokenring/smctr.c
+++ b/drivers/net/tokenring/smctr.c
@@ -4609,7 +4609,7 @@ static int smctr_send_packet(struct sk_buff *skb, struct net_device *dev)
         if(tp->QueueSkb > 0)
 		netif_wake_queue(dev);
 		
-        return (0);
+        return NETDEV_TX_OK;
 }
 
 static int smctr_send_lobe_media_test(struct net_device *dev)
diff --git a/drivers/net/tokenring/tms380tr.c b/drivers/net/tokenring/tms380tr.c
index a2eab72..07f6dfd 100644
--- a/drivers/net/tokenring/tms380tr.c
+++ b/drivers/net/tokenring/tms380tr.c
@@ -682,7 +682,7 @@ static int tms380tr_hardware_send_packet(struct sk_buff *skb, struct net_device
 	tms380tr_exec_sifcmd(dev, CMD_TX_VALID);
 	spin_unlock_irqrestore(&tp->lock, flags);
 
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 /*
diff --git a/drivers/net/tulip/dmfe.c b/drivers/net/tulip/dmfe.c
index 8e78f00..5e15fab 100644
--- a/drivers/net/tulip/dmfe.c
+++ b/drivers/net/tulip/dmfe.c
@@ -676,7 +676,7 @@ static int dmfe_start_xmit(struct sk_buff *skb, struct DEVICE *dev)
 	if (skb->len > MAX_PACKET_SIZE) {
 		printk(KERN_ERR DRV_NAME ": big packet = %d\n", (u16)skb->len);
 		dev_kfree_skb(skb);
-		return 0;
+		return NETDEV_TX_OK;
 	}
 
 	spin_lock_irqsave(&db->lock, flags);
@@ -722,7 +722,7 @@ static int dmfe_start_xmit(struct sk_buff *skb, struct DEVICE *dev)
 	/* free this SKB */
 	dev_kfree_skb(skb);
 
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 
diff --git a/drivers/net/wan/dlci.c b/drivers/net/wan/dlci.c
index 2fa275a..8526b6d 100644
--- a/drivers/net/wan/dlci.c
+++ b/drivers/net/wan/dlci.c
@@ -194,7 +194,7 @@ static int dlci_transmit(struct sk_buff *skb, struct net_device *dev)
 	ret = 0;
 
 	if (!skb || !dev)
-		return(0);
+		return NETDEV_TX_OK;
 
 	dlp = netdev_priv(dev);
 
@@ -219,7 +219,7 @@ static int dlci_transmit(struct sk_buff *skb, struct net_device *dev)
 	/* Alan Cox recommends always returning 0, and always freeing the packet */
 	/* experience suggest a slightly more conservative approach */
 
-	if (!ret)
+	if (ret == NETDEV_TX_OK)
 	{
 		dev_kfree_skb(skb);
 		netif_wake_queue(dev);
diff --git a/drivers/net/wan/dscc4.c b/drivers/net/wan/dscc4.c
index 8face5d..e81946d 100644
--- a/drivers/net/wan/dscc4.c
+++ b/drivers/net/wan/dscc4.c
@@ -1182,7 +1182,7 @@ static int dscc4_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (dscc4_tx_quiescent(dpriv, dev))
 		dscc4_do_tx(dpriv, dev);
 
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 static int dscc4_close(struct net_device *dev)
diff --git a/drivers/net/wan/farsync.c b/drivers/net/wan/farsync.c
index 25c9ef6..fb540a2 100644
--- a/drivers/net/wan/farsync.c
+++ b/drivers/net/wan/farsync.c
@@ -2313,7 +2313,7 @@ fst_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		dbg(DBG_ASS,
 		    "Tried to transmit but no carrier on card %d port %d\n",
 		    card->card_no, port->index);
-		return 0;
+		return NETDEV_TX_OK;
 	}
 
 	/* Drop it if it's too big! MTU failure ? */
@@ -2322,7 +2322,7 @@ fst_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		    LEN_TX_BUFFER);
 		dev_kfree_skb(skb);
 		dev->stats.tx_errors++;
-		return 0;
+		return NETDEV_TX_OK;
 	}
 
 	/*
@@ -2356,7 +2356,7 @@ fst_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		dev->stats.tx_errors++;
 		dbg(DBG_ASS, "Tx queue overflow card %d port %d\n",
 		    card->card_no, port->index);
-		return 0;
+		return NETDEV_TX_OK;
 	}
 
 	/*
@@ -2373,7 +2373,7 @@ fst_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	fst_q_work_item(&fst_work_txq, card->card_no);
 	tasklet_schedule(&fst_tx_task);
 
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 /*
diff --git a/drivers/net/wan/lmc/lmc_main.c b/drivers/net/wan/lmc/lmc_main.c
index 45b1822..d1492ae 100644
--- a/drivers/net/wan/lmc/lmc_main.c
+++ b/drivers/net/wan/lmc/lmc_main.c
@@ -1428,7 +1428,7 @@ static int lmc_start_xmit(struct sk_buff *skb, struct net_device *dev)
     lmc_softc_t *sc = dev_to_sc(dev);
     u32 flag;
     int entry;
-    int ret = 0;
+    int ret = NETDEV_TX_OK;
     unsigned long flags;
 
     lmc_trace(dev, "lmc_start_xmit in");
diff --git a/drivers/net/wan/wanxl.c b/drivers/net/wan/wanxl.c
index e4ad7b6..03b76ad 100644
--- a/drivers/net/wan/wanxl.c
+++ b/drivers/net/wan/wanxl.c
@@ -310,7 +310,7 @@ static int wanxl_xmit(struct sk_buff *skb, struct net_device *dev)
 	}
 
 	spin_unlock(&port->lock);
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 
diff --git a/drivers/net/wireless/hostap/hostap_80211_tx.c b/drivers/net/wireless/hostap/hostap_80211_tx.c
index d313b00..1fe1bba 100644
--- a/drivers/net/wireless/hostap/hostap_80211_tx.c
+++ b/drivers/net/wireless/hostap/hostap_80211_tx.c
@@ -75,7 +75,7 @@ int hostap_data_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		printk(KERN_DEBUG "%s: hostap_data_start_xmit: short skb "
 		       "(len=%d)\n", dev->name, skb->len);
 		kfree_skb(skb);
-		return 0;
+		return NETDEV_TX_OK;
 	}
 
 	if (local->ddev != dev) {
@@ -89,14 +89,14 @@ int hostap_data_start_xmit(struct sk_buff *skb, struct net_device *dev)
 			printk(KERN_DEBUG "%s: prism2_tx: trying to use "
 			       "AP device with Ethernet net dev\n", dev->name);
 			kfree_skb(skb);
-			return 0;
+			return NETDEV_TX_OK;
 		}
 	} else {
 		if (local->iw_mode == IW_MODE_REPEAT) {
 			printk(KERN_DEBUG "%s: prism2_tx: trying to use "
 			       "non-WDS link in Repeater mode\n", dev->name);
 			kfree_skb(skb);
-			return 0;
+			return NETDEV_TX_OK;
 		} else if (local->iw_mode == IW_MODE_INFRA &&
 			   (local->wds_type & HOSTAP_WDS_AP_CLIENT) &&
 			   memcmp(skb->data + ETH_ALEN, dev->dev_addr,
@@ -210,13 +210,13 @@ int hostap_data_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		skb = skb_unshare(skb, GFP_ATOMIC);
 		if (skb == NULL) {
 			iface->stats.tx_dropped++;
-			return 0;
+			return NETDEV_TX_OK;
 		}
 		if (pskb_expand_head(skb, need_headroom, need_tailroom,
 				     GFP_ATOMIC)) {
 			kfree_skb(skb);
 			iface->stats.tx_dropped++;
-			return 0;
+			return NETDEV_TX_OK;
 		}
 	} else if (skb_headroom(skb) < need_headroom) {
 		struct sk_buff *tmp = skb;
@@ -224,13 +224,13 @@ int hostap_data_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		kfree_skb(tmp);
 		if (skb == NULL) {
 			iface->stats.tx_dropped++;
-			return 0;
+			return NETDEV_TX_OK;
 		}
 	} else {
 		skb = skb_unshare(skb, GFP_ATOMIC);
 		if (skb == NULL) {
 			iface->stats.tx_dropped++;
-			return 0;
+			return NETDEV_TX_OK;
 		}
 	}
 
@@ -256,7 +256,7 @@ int hostap_data_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	/* Send IEEE 802.11 encapsulated frame using the master radio device */
 	skb->dev = local->dev;
 	dev_queue_xmit(skb);
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 
@@ -276,7 +276,7 @@ int hostap_mgmt_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		printk(KERN_DEBUG "%s: hostap_mgmt_start_xmit: short skb "
 		       "(len=%d)\n", dev->name, skb->len);
 		kfree_skb(skb);
-		return 0;
+		return NETDEV_TX_OK;
 	}
 
 	iface->stats.tx_packets++;
@@ -301,7 +301,7 @@ int hostap_mgmt_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	/* Send IEEE 802.11 encapsulated frame using the master radio device */
 	skb->dev = local->dev;
 	dev_queue_xmit(skb);
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 
@@ -396,7 +396,7 @@ int hostap_master_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		printk(KERN_DEBUG "%s: invalid skb->cb magic (0x%08x, "
 		       "expected 0x%08x)\n",
 		       dev->name, meta->magic, HOSTAP_SKB_TX_DATA_MAGIC);
-		ret = 0;
+		ret = NETDEV_TX_OK;
 		iface->stats.tx_dropped++;
 		goto fail;
 	}
@@ -414,7 +414,7 @@ int hostap_master_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (skb->len < 24) {
 		printk(KERN_DEBUG "%s: hostap_master_start_xmit: short skb "
 		       "(len=%d)\n", dev->name, skb->len);
-		ret = 0;
+		ret = NETDEV_TX_OK;
 		iface->stats.tx_dropped++;
 		goto fail;
 	}
@@ -441,13 +441,13 @@ int hostap_master_start_xmit(struct sk_buff *skb, struct net_device *dev)
 			       dev->name, meta->ethertype);
 			hostap_dump_tx_80211(dev->name, skb);
 
-			ret = 0; /* drop packet */
+			ret = NETDEV_TX_OK; /* drop packet */
 			iface->stats.tx_dropped++;
 			goto fail;
 		}
 		break;
 	case AP_TX_DROP:
-		ret = 0; /* drop packet */
+		ret = NETDEV_TX_OK; /* drop packet */
 		iface->stats.tx_dropped++;
 		goto fail;
 	case AP_TX_RETRY:
@@ -455,7 +455,7 @@ int hostap_master_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	case AP_TX_BUFFERED:
 		/* do not free skb here, it will be freed when the
 		 * buffered frame is sent/timed out */
-		ret = 0;
+		ret = NETDEV_TX_OK;
 		goto tx_exit;
 	}
 
@@ -501,7 +501,7 @@ int hostap_master_start_xmit(struct sk_buff *skb, struct net_device *dev)
 			       "frame (drop_unencrypted=1)\n", dev->name);
 		}
 		iface->stats.tx_dropped++;
-		ret = 0;
+		ret = NETDEV_TX_OK;
 		goto fail;
 	}
 
@@ -510,7 +510,7 @@ int hostap_master_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		if (skb == NULL) {
 			printk(KERN_DEBUG "%s: TX - encryption failed\n",
 			       dev->name);
-			ret = 0;
+			ret = NETDEV_TX_OK;
 			goto fail;
 		}
 		meta = (struct hostap_skb_tx_data *) skb->cb;
@@ -519,23 +519,23 @@ int hostap_master_start_xmit(struct sk_buff *skb, struct net_device *dev)
 			       "expected 0x%08x) after hostap_tx_encrypt\n",
 			       dev->name, meta->magic,
 			       HOSTAP_SKB_TX_DATA_MAGIC);
-			ret = 0;
+			ret = NETDEV_TX_OK;
 			iface->stats.tx_dropped++;
 			goto fail;
 		}
 	}
 
 	if (local->func->tx == NULL || local->func->tx(skb, dev)) {
-		ret = 0;
+		ret = NETDEV_TX_OK;
 		iface->stats.tx_dropped++;
 	} else {
-		ret = 0;
+		ret = NETDEV_TX_OK;
 		iface->stats.tx_packets++;
 		iface->stats.tx_bytes += skb->len;
 	}
 
  fail:
-	if (!ret && skb)
+	if (ret == NETDEV_TX_OK && skb)
 		dev_kfree_skb(skb);
  tx_exit:
 	if (tx.sta_ptr)
diff --git a/drivers/net/wireless/ipw2x00/libipw_tx.c b/drivers/net/wireless/ipw2x00/libipw_tx.c
index da2ad54..2e8f84f 100644
--- a/drivers/net/wireless/ipw2x00/libipw_tx.c
+++ b/drivers/net/wireless/ipw2x00/libipw_tx.c
@@ -527,13 +527,13 @@ int ieee80211_xmit(struct sk_buff *skb, struct net_device *dev)
 		if (ret == 0) {
 			dev->stats.tx_packets++;
 			dev->stats.tx_bytes += txb->payload_size;
-			return 0;
+			return NETDEV_TX_OK;
 		}
 
 		ieee80211_txb_free(txb);
 	}
 
-	return 0;
+	return NETDEV_TX_OK;
 
       failed:
 	spin_unlock_irqrestore(&ieee->lock, flags);
diff --git a/drivers/net/wireless/prism54/islpci_eth.c b/drivers/net/wireless/prism54/islpci_eth.c
index 8f62109..c255d9c 100644
--- a/drivers/net/wireless/prism54/islpci_eth.c
+++ b/drivers/net/wireless/prism54/islpci_eth.c
@@ -234,7 +234,7 @@ islpci_eth_transmit(struct sk_buff *skb, struct net_device *ndev)
 	/* unlock the driver code */
 	spin_unlock_irqrestore(&priv->slock, flags);
 
-	return 0;
+	return NETDEV_TX_OK;
 
       drop_free:
 	ndev->stats.tx_dropped++;
diff --git a/drivers/net/wireless/wavelan.c b/drivers/net/wireless/wavelan.c
index ab7fc5c..5cb5329 100644
--- a/drivers/net/wireless/wavelan.c
+++ b/drivers/net/wireless/wavelan.c
@@ -2891,7 +2891,7 @@ static int wavelan_packet_xmit(struct sk_buff *skb, struct net_device * dev)
 #ifdef DEBUG_TX_TRACE
 	printk(KERN_DEBUG "%s: <-wavelan_packet_xmit()\n", dev->name);
 #endif
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 /*********************** HARDWARE CONFIGURATION ***********************/
diff --git a/drivers/net/wireless/wavelan_cs.c b/drivers/net/wireless/wavelan_cs.c
index 6af7064..9dd241a 100644
--- a/drivers/net/wireless/wavelan_cs.c
+++ b/drivers/net/wireless/wavelan_cs.c
@@ -3113,7 +3113,7 @@ wavelan_packet_xmit(struct sk_buff *	skb,
 	 * able to detect collisions, therefore in theory we don't really
 	 * need to pad. Jean II */
 	if (skb_padto(skb, ETH_ZLEN))
-		return 0;
+		return NETDEV_TX_OK;
 
   wv_packet_write(dev, skb->data, skb->len);
 
@@ -3122,7 +3122,7 @@ wavelan_packet_xmit(struct sk_buff *	skb,
 #ifdef DEBUG_TX_TRACE
   printk(KERN_DEBUG "%s: <-wavelan_packet_xmit()\n", dev->name);
 #endif
-  return(0);
+  return NETDEV_TX_OK;
 }
 
 /********************** HARDWARE CONFIGURATION **********************/
diff --git a/drivers/net/wireless/wl3501_cs.c b/drivers/net/wireless/wl3501_cs.c
index e3e96bb..a83a562 100644
--- a/drivers/net/wireless/wl3501_cs.c
+++ b/drivers/net/wireless/wl3501_cs.c
@@ -1348,7 +1348,6 @@ static int wl3501_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (rc) {
 		++dev->stats.tx_dropped;
 		netif_stop_queue(dev);
-		rc = NETDEV_TX_OK;
 	} else {
 		++dev->stats.tx_packets;
 		dev->stats.tx_bytes += skb->len;
@@ -1358,7 +1357,7 @@ static int wl3501_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 			netif_stop_queue(dev);
 	}
 	spin_unlock_irqrestore(&this->lock, flags);
-	return rc;
+	return NETDEV_TX_OK;
 }
 
 static int wl3501_open(struct net_device *dev)
diff --git a/drivers/s390/net/claw.c b/drivers/s390/net/claw.c
index 7b6f46d..fda6460 100644
--- a/drivers/s390/net/claw.c
+++ b/drivers/s390/net/claw.c
@@ -344,6 +344,8 @@ claw_tx(struct sk_buff *skb, struct net_device *dev)
 	CLAW_DBF_TEXT_(4, trace, "clawtx%d", rc);
 	if (rc)
 		rc = NETDEV_TX_BUSY;
+	else
+		rc = NETDEV_TX_OK;
         return rc;
 }   /*  end of claw_tx */
 
diff --git a/drivers/s390/net/lcs.c b/drivers/s390/net/lcs.c
index a45bc24..eaf9679 100644
--- a/drivers/s390/net/lcs.c
+++ b/drivers/s390/net/lcs.c
@@ -1556,24 +1556,24 @@ __lcs_start_xmit(struct lcs_card *card, struct sk_buff *skb,
 		 struct net_device *dev)
 {
 	struct lcs_header *header;
-	int rc = 0;
+	int rc = NETDEV_TX_OK;
 
 	LCS_DBF_TEXT(5, trace, "hardxmit");
 	if (skb == NULL) {
 		card->stats.tx_dropped++;
 		card->stats.tx_errors++;
-		return 0;
+		return NETDEV_TX_OK;
 	}
 	if (card->state != DEV_STATE_UP) {
 		dev_kfree_skb(skb);
 		card->stats.tx_dropped++;
 		card->stats.tx_errors++;
 		card->stats.tx_carrier_errors++;
-		return 0;
+		return NETDEV_TX_OK;
 	}
 	if (skb->protocol == htons(ETH_P_IPV6)) {
 		dev_kfree_skb(skb);
-		return 0;
+		return NETDEV_TX_OK;
 	}
 	netif_stop_queue(card->dev);
 	spin_lock(&card->lock);
diff --git a/drivers/s390/net/netiucv.c b/drivers/s390/net/netiucv.c
index aec9e5d..85e62be 100644
--- a/drivers/s390/net/netiucv.c
+++ b/drivers/s390/net/netiucv.c
@@ -1288,14 +1288,14 @@ static int netiucv_tx(struct sk_buff *skb, struct net_device *dev)
 	if (skb == NULL) {
 		IUCV_DBF_TEXT(data, 2, "netiucv_tx: skb is NULL\n");
 		privptr->stats.tx_dropped++;
-		return 0;
+		return NETDEV_TX_OK;
 	}
 	if (skb_headroom(skb) < NETIUCV_HDRLEN) {
 		IUCV_DBF_TEXT(data, 2,
 			"netiucv_tx: skb_headroom < NETIUCV_HDRLEN\n");
 		dev_kfree_skb(skb);
 		privptr->stats.tx_dropped++;
-		return 0;
+		return NETDEV_TX_OK;
 	}
 
 	/**
@@ -1307,7 +1307,7 @@ static int netiucv_tx(struct sk_buff *skb, struct net_device *dev)
 		privptr->stats.tx_dropped++;
 		privptr->stats.tx_errors++;
 		privptr->stats.tx_carrier_errors++;
-		return 0;
+		return NETDEV_TX_OK;
 	}
 
 	if (netiucv_test_and_set_busy(dev)) {
diff --git a/drivers/s390/net/qeth_l2_main.c b/drivers/s390/net/qeth_l2_main.c
index 3607d10..e41b08e 100644
--- a/drivers/s390/net/qeth_l2_main.c
+++ b/drivers/s390/net/qeth_l2_main.c
@@ -744,6 +744,7 @@ static int qeth_l2_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		card->stats.tx_bytes += tx_bytes;
 		if (new_skb != skb)
 			dev_kfree_skb_any(skb);
+		rc = NETDEV_TX_OK;
 	} else {
 		if (data_offset >= 0)
 			kmem_cache_free(qeth_core_header_cache, hdr);
diff --git a/drivers/s390/net/qeth_l3_main.c b/drivers/s390/net/qeth_l3_main.c
index 6f2386e..0bc6a43 100644
--- a/drivers/s390/net/qeth_l3_main.c
+++ b/drivers/s390/net/qeth_l3_main.c
@@ -2793,6 +2793,7 @@ static int qeth_l3_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 				card->perf_stats.sg_frags_sent += nr_frags + 1;
 			}
 		}
+		rc = NETDEV_TX_OK;
 	} else {
 		if (data_offset >= 0)
 			kmem_cache_free(qeth_core_header_cache, hdr);
diff --git a/drivers/staging/rt2860/rt_main_dev.c b/drivers/staging/rt2860/rt_main_dev.c
index 6c4396f..c42dc39 100644
--- a/drivers/staging/rt2860/rt_main_dev.c
+++ b/drivers/staging/rt2860/rt_main_dev.c
@@ -1314,7 +1314,7 @@ int rt28xx_packet_xmit(struct sk_buff *skb)
 {
 	struct net_device *net_dev = skb->dev;
 	PRTMP_ADAPTER pAd = net_dev->ml_priv;
-	int status = 0;
+	int status = NETDEV_TX_OK;
 	PNDIS_PACKET pPacket = (PNDIS_PACKET) skb;
 
 	/* RT2870STA does this in RTMPSendPackets() */
@@ -1322,7 +1322,7 @@ int rt28xx_packet_xmit(struct sk_buff *skb)
 	if (ATE_ON(pAd))
 	{
 		RELEASE_NDIS_PACKET(pAd, pPacket, NDIS_STATUS_RESOURCES);
-		return 0;
+		return NETDEV_TX_OK;
 	}
 #endif // RALINK_ATE //
 
@@ -1365,7 +1365,7 @@ int rt28xx_packet_xmit(struct sk_buff *skb)
 
 #endif // CONFIG_STA_SUPPORT //
 
-	status = 0;
+	status = NETDEV_TX_OK;
 done:
 
 	return status;
@@ -1396,7 +1396,7 @@ INT rt28xx_send_packets(
 	if (!(net_dev->flags & IFF_UP))
 	{
 		RELEASE_NDIS_PACKET(pAd, (PNDIS_PACKET)skb_p, NDIS_STATUS_FAILURE);
-		return 0;
+		return NETDEV_TX_OK;
 	}
 
 	NdisZeroMemory((PUCHAR)&skb_p->cb[CB_OFF], 15);
diff --git a/drivers/staging/rt2870/rt_main_dev.c b/drivers/staging/rt2870/rt_main_dev.c
index 48ad411..14dd7fa 100644
--- a/drivers/staging/rt2870/rt_main_dev.c
+++ b/drivers/staging/rt2870/rt_main_dev.c
@@ -1520,7 +1520,7 @@ int rt28xx_packet_xmit(struct sk_buff *skb)
 {
 	struct net_device *net_dev = skb->dev;
 	PRTMP_ADAPTER pAd = net_dev->ml_priv;
-	int status = 0;
+	int status = NETDEV_TX_OK;
 	PNDIS_PACKET pPacket = (PNDIS_PACKET) skb;
 
 	/* RT2870STA does this in RTMPSendPackets() */
@@ -1528,7 +1528,7 @@ int rt28xx_packet_xmit(struct sk_buff *skb)
 	if (ATE_ON(pAd))
 	{
 		RELEASE_NDIS_PACKET(pAd, pPacket, NDIS_STATUS_RESOURCES);
-		return 0;
+		return NETDEV_TX_OK;
 	}
 #endif // RALINK_ATE //
 
@@ -1580,7 +1580,7 @@ int rt28xx_packet_xmit(struct sk_buff *skb)
 
 #endif // CONFIG_STA_SUPPORT //
 
-	status = 0;
+	status = NETDEV_TX_OK;
 done:
 
 	return status;
@@ -1612,7 +1612,7 @@ INT rt28xx_send_packets(
 	if (!(net_dev->flags & IFF_UP))
 	{
 		RELEASE_NDIS_PACKET(pAd, (PNDIS_PACKET)skb_p, NDIS_STATUS_FAILURE);
-		return 0;
+		return NETDEV_TX_OK;
 	}
 
 	NdisZeroMemory((PUCHAR)&skb_p->cb[CB_OFF], 15);
diff --git a/drivers/staging/rt3070/rt_main_dev.c b/drivers/staging/rt3070/rt_main_dev.c
index 81f769c..64a5ad6 100644
--- a/drivers/staging/rt3070/rt_main_dev.c
+++ b/drivers/staging/rt3070/rt_main_dev.c
@@ -1513,7 +1513,7 @@ int rt28xx_packet_xmit(struct sk_buff *skb)
 {
 	struct net_device *net_dev = skb->dev;
 	PRTMP_ADAPTER pAd = net_dev->ml_priv;
-	int status = 0;
+	int status = NETDEV_TX_OK;
 	PNDIS_PACKET pPacket = (PNDIS_PACKET) skb;
 
 	/* RT2870STA does this in RTMPSendPackets() */
@@ -1521,7 +1521,7 @@ int rt28xx_packet_xmit(struct sk_buff *skb)
 	if (ATE_ON(pAd))
 	{
 		RELEASE_NDIS_PACKET(pAd, pPacket, NDIS_STATUS_RESOURCES);
-		return 0;
+		return NETDEV_TX_OK;
 	}
 #endif // RALINK_ATE //
 
@@ -1565,7 +1565,7 @@ int rt28xx_packet_xmit(struct sk_buff *skb)
 
 #endif // CONFIG_STA_SUPPORT //
 
-	status = 0;
+	status = NETDEV_TX_OK;
 done:
 
 	return status;
@@ -1597,7 +1597,7 @@ INT rt28xx_send_packets(
 	if (!(net_dev->flags & IFF_UP))
 	{
 		RELEASE_NDIS_PACKET(pAd, (PNDIS_PACKET)skb_p, NDIS_STATUS_FAILURE);
-		return 0;
+		return NETDEV_TX_OK;
 	}
 
 	NdisZeroMemory((PUCHAR)&skb_p->cb[CB_OFF], 15);
diff --git a/drivers/staging/rtl8187se/ieee80211/ieee80211_tx.c b/drivers/staging/rtl8187se/ieee80211/ieee80211_tx.c
index 1294e05..1b77460 100644
--- a/drivers/staging/rtl8187se/ieee80211/ieee80211_tx.c
+++ b/drivers/staging/rtl8187se/ieee80211/ieee80211_tx.c
@@ -802,13 +802,13 @@ int ieee80211_xmit(struct sk_buff *skb,
 			if ((*ieee->hard_start_xmit)(txb, dev) == 0) {
 				stats->tx_packets++;
 				stats->tx_bytes += txb->payload_size;
-				return 0;
+				return NETDEV_TX_OK;
 			}
 			ieee80211_txb_free(txb);
 		}
 	}
 
-	return 0;
+	return NETDEV_TX_OK;
 
  failed:
 	spin_unlock_irqrestore(&ieee->lock, flags);
diff --git a/drivers/staging/rtl8187se/r8180_core.c b/drivers/staging/rtl8187se/r8180_core.c
index e10413c..eddbbd3 100644
--- a/drivers/staging/rtl8187se/r8180_core.c
+++ b/drivers/staging/rtl8187se/r8180_core.c
@@ -3039,7 +3039,7 @@ int rtl8180_hard_start_xmit(struct sk_buff *skb,struct net_device *dev)
 		spin_unlock_irqrestore(&priv->tx_lock,flags);
 
 		dev_kfree_skb_any(skb);
-		return 0;
+		return NETDEV_TX_OK;
 	}
 
 	rtl8180_tx(dev, skb->data, skb->len, priority,
@@ -3050,7 +3050,7 @@ int rtl8180_hard_start_xmit(struct sk_buff *skb,struct net_device *dev)
 	spin_unlock_irqrestore(&priv->tx_lock,flags);
 
 	dev_kfree_skb_any(skb);
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 // longpre 144+48 shortpre 72+24
diff --git a/drivers/staging/wlan-ng/p80211netdev.c b/drivers/staging/wlan-ng/p80211netdev.c
index bc0d764..4578fe8 100644
--- a/drivers/staging/wlan-ng/p80211netdev.c
+++ b/drivers/staging/wlan-ng/p80211netdev.c
@@ -355,7 +355,7 @@ static int p80211knetdev_hard_start_xmit(struct sk_buff *skb,
 	p80211_metawep_t p80211_wep;
 
 	if (skb == NULL)
-		return 0;
+		return NETDEV_TX_OK;
 
 	if (wlandev->state != WLAN_DEVICE_OPEN) {
 		result = 1;
diff --git a/net/atm/mpc.c b/net/atm/mpc.c
index e5bf114..1ac4b94 100644
--- a/net/atm/mpc.c
+++ b/net/atm/mpc.c
@@ -554,7 +554,7 @@ static int mpc_send_packet(struct sk_buff *skb, struct net_device *dev)
 	while (i < mpc->number_of_mps_macs) {
 		if (!compare_ether_addr(eth->h_dest, (mpc->mps_macs + i*ETH_ALEN)))
 			if ( send_via_shortcut(skb, mpc) == 0 )           /* try shortcut */
-				return 0;                                 /* success!     */
+				return NETDEV_TX_OK;                      /* success!     */
 		i++;
 	}
 
diff --git a/net/core/dev.c b/net/core/dev.c
index baf2dc1..04aab3d 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1704,7 +1704,7 @@ int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
 			skb_dst_drop(skb);
 
 		rc = ops->ndo_start_xmit(skb, dev);
-		if (rc == 0)
+		if (rc == NETDEV_TX_OK)
 			txq_trans_update(txq);
 		/*
 		 * TODO: if skb_orphan() was called by
@@ -1730,7 +1730,7 @@ gso:
 		skb->next = nskb->next;
 		nskb->next = NULL;
 		rc = ops->ndo_start_xmit(nskb, dev);
-		if (unlikely(rc)) {
+		if (unlikely(rc != NETDEV_TX_OK)) {
 			nskb->next = skb->next;
 			skb->next = nskb;
 			return rc;
@@ -1744,7 +1744,7 @@ gso:
 
 out_kfree_skb:
 	kfree_skb(skb);
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 static u32 skb_tx_hashrnd;
diff --git a/net/mac80211/tx.c b/net/mac80211/tx.c
index d238a89..2ffb35d 100644
--- a/net/mac80211/tx.c
+++ b/net/mac80211/tx.c
@@ -1627,7 +1627,7 @@ int ieee80211_subif_start_xmit(struct sk_buff *skb,
 	u32 sta_flags = 0;
 
 	if (unlikely(skb->len < ETH_HLEN)) {
-		ret = 0;
+		ret = NETDEV_TX_OK;
 		goto fail;
 	}
 
@@ -1664,7 +1664,7 @@ int ieee80211_subif_start_xmit(struct sk_buff *skb,
 		if (!sdata->u.mesh.mshcfg.dot11MeshTTL) {
 			/* Do not send frames with mesh_ttl == 0 */
 			sdata->u.mesh.mshstats.dropped_frames_ttl++;
-			ret = 0;
+			ret = NETDEV_TX_OK;
 			goto fail;
 		}
 		memset(&mesh_hdr, 0, sizeof(mesh_hdr));
@@ -1724,7 +1724,7 @@ int ieee80211_subif_start_xmit(struct sk_buff *skb,
 		hdrlen = 24;
 		break;
 	default:
-		ret = 0;
+		ret = NETDEV_TX_OK;
 		goto fail;
 	}
 
@@ -1766,7 +1766,7 @@ int ieee80211_subif_start_xmit(struct sk_buff *skb,
 
 		I802_DEBUG_INC(local->tx_handlers_drop_unauth_port);
 
-		ret = 0;
+		ret = NETDEV_TX_OK;
 		goto fail;
 	}
 
@@ -1858,10 +1858,10 @@ int ieee80211_subif_start_xmit(struct sk_buff *skb,
 	dev->trans_start = jiffies;
 	dev_queue_xmit(skb);
 
-	return 0;
+	return NETDEV_TX_OK;
 
  fail:
-	if (!ret)
+	if (ret == NETDEV_TX_OK)
 		dev_kfree_skb(skb);
 
 	return ret;

--------------030101090403030000040002--
