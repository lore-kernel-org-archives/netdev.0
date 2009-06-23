From: Patrick McHardy <kaber@trash.net>
Subject: net: use NETDEV_TX_OK instead of 0 in ndo_start_xmit() functions
Date: Tue, 23 Jun 2009 18:03:08 +0200
Message-ID: <4A40FCBC.9040700@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010301000907030908060503"
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:47450 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751444AbZFWQDL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jun 2009 12:03:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------010301000907030908060503
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit


--------------010301000907030908060503
Content-Type: text/x-patch;
 name="01.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="01.diff"

commit 42cd52fcc5c454acd1fe9dd55d6c2de5a35084dc
Author: Patrick McHardy <kaber@trash.net>
Date:   Tue Jun 23 18:02:26 2009 +0200

    net: use NETDEV_TX_OK instead of 0 in ndo_start_xmit() functions
    
    This patch is the result of an automatic spatch transformation to convert
    all ndo_start_xmit() return values of 0 to NETDEV_TX_OK.
    
    Some occurences are missed by the automatic conversion, those will be
    handled in a seperate patch.
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/arch/ia64/hp/sim/simeth.c b/arch/ia64/hp/sim/simeth.c
index e4d8fde..7e81966 100644
--- a/arch/ia64/hp/sim/simeth.c
+++ b/arch/ia64/hp/sim/simeth.c
@@ -412,7 +412,7 @@ simeth_tx(struct sk_buff *skb, struct net_device *dev)
 	 */
 
 	dev_kfree_skb(skb);
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 static inline struct sk_buff *
diff --git a/arch/um/drivers/net_kern.c b/arch/um/drivers/net_kern.c
index 434ba12..dd84cb7 100644
--- a/arch/um/drivers/net_kern.c
+++ b/arch/um/drivers/net_kern.c
@@ -245,7 +245,7 @@ static int uml_net_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	dev_kfree_skb(skb);
 
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 static void uml_net_set_multicast_list(struct net_device *dev)
diff --git a/drivers/ieee802154/fakehard.c b/drivers/ieee802154/fakehard.c
index 0384144..14045a7 100644
--- a/drivers/ieee802154/fakehard.c
+++ b/drivers/ieee802154/fakehard.c
@@ -132,7 +132,7 @@ static int ieee802154_fake_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	/* FIXME: do hardware work here ... */
 
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 
diff --git a/drivers/isdn/i4l/isdn_net.c b/drivers/isdn/i4l/isdn_net.c
index de4aad0..8209ed6 100644
--- a/drivers/isdn/i4l/isdn_net.c
+++ b/drivers/isdn/i4l/isdn_net.c
@@ -1202,7 +1202,7 @@ isdn_net_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 			if (!(ISDN_NET_DIALMODE(*lp) == ISDN_NET_DM_AUTO)) {
 				isdn_net_unreachable(ndev, skb, "dial rejected: interface not in dialmode `auto'");
 				dev_kfree_skb(skb);
-				return 0;
+				return NETDEV_TX_OK;
 			}
 			if (lp->phone[1]) {
 				ulong flags;
@@ -1215,7 +1215,7 @@ isdn_net_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 					if(time_before(jiffies, lp->dialwait_timer)) {
 						isdn_net_unreachable(ndev, skb, "dial rejected: retry-time not reached");
 						dev_kfree_skb(skb);
-						return 0;
+						return NETDEV_TX_OK;
 					} else
 						lp->dialwait_timer = 0;
 				}
@@ -1243,7 +1243,7 @@ isdn_net_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 					isdn_net_unreachable(ndev, skb,
 							   "No channel");
 					dev_kfree_skb(skb);
-					return 0;
+					return NETDEV_TX_OK;
 				}
 				/* Log packet, which triggered dialing */
 				if (dev->net_verbose)
@@ -1258,7 +1258,7 @@ isdn_net_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 						dev_kfree_skb(skb);
 						isdn_net_unbind_channel(lp);
 						spin_unlock_irqrestore(&dev->lock, flags);
-						return 0;	/* STN (skb to nirvana) ;) */
+						return NETDEV_TX_OK;	/* STN (skb to nirvana) ;) */
 					}
 #ifdef CONFIG_IPPP_FILTER
 					if (isdn_ppp_autodial_filter(skb, lp)) {
@@ -1267,7 +1267,7 @@ isdn_net_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 						spin_unlock_irqrestore(&dev->lock, flags);
 						isdn_net_unreachable(ndev, skb, "dial rejected: packet filtered");
 						dev_kfree_skb(skb);
-						return 0;
+						return NETDEV_TX_OK;
 					}
 #endif
 					spin_unlock_irqrestore(&dev->lock, flags);
@@ -1285,7 +1285,7 @@ isdn_net_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 				isdn_net_unreachable(ndev, skb,
 						     "No phone number");
 				dev_kfree_skb(skb);
-				return 0;
+				return NETDEV_TX_OK;
 			}
 		} else {
 			/* Device is connected to an ISDN channel */ 
diff --git a/drivers/media/dvb/dvb-core/dvb_net.c b/drivers/media/dvb/dvb-core/dvb_net.c
index 8280f8d..8c9ae0a 100644
--- a/drivers/media/dvb/dvb-core/dvb_net.c
+++ b/drivers/media/dvb/dvb-core/dvb_net.c
@@ -904,7 +904,7 @@ static int dvb_net_sec_callback(const u8 *buffer1, size_t buffer1_len,
 static int dvb_net_tx(struct sk_buff *skb, struct net_device *dev)
 {
 	dev_kfree_skb(skb);
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 static u8 mask_normal[6]={0xff, 0xff, 0xff, 0xff, 0xff, 0xff};
diff --git a/drivers/message/fusion/mptlan.c b/drivers/message/fusion/mptlan.c
index a9e48e2..bc2ec21 100644
--- a/drivers/message/fusion/mptlan.c
+++ b/drivers/message/fusion/mptlan.c
@@ -795,7 +795,7 @@ mpt_lan_sdu_send (struct sk_buff *skb, struct net_device *dev)
 			IOC_AND_NETDEV_NAMES_s_s(dev),
 			le32_to_cpu(pSimple->FlagsLength)));
 
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 /*=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=*/
diff --git a/drivers/misc/sgi-xp/xpnet.c b/drivers/misc/sgi-xp/xpnet.c
index 8d1c60a..b681bf8 100644
--- a/drivers/misc/sgi-xp/xpnet.c
+++ b/drivers/misc/sgi-xp/xpnet.c
@@ -436,7 +436,7 @@ xpnet_dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	if (skb->data[0] == 0x33) {
 		dev_kfree_skb(skb);
-		return 0;	/* nothing needed to be done */
+		return NETDEV_TX_OK;	/* nothing needed to be done */
 	}
 
 	/*
@@ -503,7 +503,7 @@ xpnet_dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	dev->stats.tx_packets++;
 	dev->stats.tx_bytes += skb->len;
 
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 /*
diff --git a/drivers/net/3c505.c b/drivers/net/3c505.c
index f71b354..7bba480 100644
--- a/drivers/net/3c505.c
+++ b/drivers/net/3c505.c
@@ -1101,7 +1101,7 @@ static int elp_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	prime_rx(dev);
 	spin_unlock_irqrestore(&adapter->lock, flags);
 	netif_start_queue(dev);
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 /******************************************************
diff --git a/drivers/net/3c507.c b/drivers/net/3c507.c
index 96b8665..9e93a0b 100644
--- a/drivers/net/3c507.c
+++ b/drivers/net/3c507.c
@@ -537,7 +537,7 @@ static int el16_send_packet (struct sk_buff *skb, struct net_device *dev)
 
 	/* You might need to clean up and record Tx statistics here. */
 
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 /*	The typical workload of the driver:
diff --git a/drivers/net/3c509.c b/drivers/net/3c509.c
index d2137ef..d2515d8 100644
--- a/drivers/net/3c509.c
+++ b/drivers/net/3c509.c
@@ -892,7 +892,7 @@ el3_start_xmit(struct sk_buff *skb, struct net_device *dev)
 			outb(0x00, ioaddr + TX_STATUS); /* Pop the status stack. */
 		}
 	}
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 /* The EL3 interrupt handler. */
diff --git a/drivers/net/3c515.c b/drivers/net/3c515.c
index 3e00fa8..85ffd13 100644
--- a/drivers/net/3c515.c
+++ b/drivers/net/3c515.c
@@ -1054,7 +1054,7 @@ static int corkscrew_start_xmit(struct sk_buff *skb,
 			netif_wake_queue(dev);
 		}
 		dev->trans_start = jiffies;
-		return 0;
+		return NETDEV_TX_OK;
 	}
 	/* Put out the doubleword header... */
 	outl(skb->len, ioaddr + TX_FIFO);
@@ -1117,7 +1117,7 @@ static int corkscrew_start_xmit(struct sk_buff *skb,
 			outb(0x00, ioaddr + TxStatus);	/* Pop the status stack. */
 		}
 	}
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 /* The interrupt handler does all of the Rx thread work and cleans up
diff --git a/drivers/net/3c523.c b/drivers/net/3c523.c
index cdd955c..70c701b 100644
--- a/drivers/net/3c523.c
+++ b/drivers/net/3c523.c
@@ -1198,7 +1198,7 @@ static int elmc_send_packet(struct sk_buff *skb, struct net_device *dev)
 		netif_wake_queue(dev);
 	dev_kfree_skb(skb);
 #endif
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 /*******************************************
diff --git a/drivers/net/3c527.c b/drivers/net/3c527.c
index aaa8a9f..72b9ed7 100644
--- a/drivers/net/3c527.c
+++ b/drivers/net/3c527.c
@@ -1035,7 +1035,7 @@ static int mc32_send_packet(struct sk_buff *skb, struct net_device *dev)
 
 	if (skb_padto(skb, ETH_ZLEN)) {
 		netif_wake_queue(dev);
-		return 0;
+		return NETDEV_TX_OK;
 	}
 
 	atomic_dec(&lp->tx_count);
@@ -1066,7 +1066,7 @@ static int mc32_send_packet(struct sk_buff *skb, struct net_device *dev)
 	p->control     &= ~CONTROL_EOL;
 
 	netif_wake_queue(dev);
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 
diff --git a/drivers/net/3c59x.c b/drivers/net/3c59x.c
index c34aee9..2020484 100644
--- a/drivers/net/3c59x.c
+++ b/drivers/net/3c59x.c
@@ -2083,7 +2083,7 @@ vortex_start_xmit(struct sk_buff *skb, struct net_device *dev)
 			iowrite8(0x00, ioaddr + TxStatus); /* Pop the status stack. */
 		}
 	}
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 static int
@@ -2173,7 +2173,7 @@ boomerang_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	iowrite16(DownUnstall, ioaddr + EL3_CMD);
 	spin_unlock_irqrestore(&vp->lock, flags);
 	dev->trans_start = jiffies;
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 /* The interrupt handler does all of the Rx thread work and cleans up
diff --git a/drivers/net/8139cp.c b/drivers/net/8139cp.c
index 50efde1..07919d0 100644
--- a/drivers/net/8139cp.c
+++ b/drivers/net/8139cp.c
@@ -891,7 +891,7 @@ static int cp_start_xmit (struct sk_buff *skb, struct net_device *dev)
 	cpw8(TxPoll, NormalTxPoll);
 	dev->trans_start = jiffies;
 
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 /* Set or clear the multicast filter for this adaptor.
diff --git a/drivers/net/8139too.c b/drivers/net/8139too.c
index 8ae72ec..1a223cd 100644
--- a/drivers/net/8139too.c
+++ b/drivers/net/8139too.c
@@ -1706,7 +1706,7 @@ static int rtl8139_start_xmit (struct sk_buff *skb, struct net_device *dev)
 	} else {
 		dev_kfree_skb(skb);
 		dev->stats.tx_dropped++;
-		return 0;
+		return NETDEV_TX_OK;
 	}
 
 	spin_lock_irqsave(&tp->lock, flags);
@@ -1731,7 +1731,7 @@ static int rtl8139_start_xmit (struct sk_buff *skb, struct net_device *dev)
 		pr_debug("%s: Queued Tx packet size %u to slot %d.\n",
 			dev->name, len, entry);
 
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 
diff --git a/drivers/net/82596.c b/drivers/net/82596.c
index 7754754..996cc91 100644
--- a/drivers/net/82596.c
+++ b/drivers/net/82596.c
@@ -1068,7 +1068,7 @@ static int i596_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	if (skb->len < ETH_ZLEN) {
 		if (skb_padto(skb, ETH_ZLEN))
-			return 0;
+			return NETDEV_TX_OK;
 		length = ETH_ZLEN;
 	}
 	netif_stop_queue(dev);
@@ -1110,7 +1110,7 @@ static int i596_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	netif_start_queue(dev);
 
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 static void print_eth(unsigned char *add, char *str)
diff --git a/drivers/net/amd8111e.c b/drivers/net/amd8111e.c
index 19831bd..61ac671 100644
--- a/drivers/net/amd8111e.c
+++ b/drivers/net/amd8111e.c
@@ -1346,7 +1346,7 @@ static int amd8111e_start_xmit(struct sk_buff *skb, struct net_device * dev)
 		netif_stop_queue(dev);
 	}
 	spin_unlock_irqrestore(&lp->lock, flags);
-	return 0;
+	return NETDEV_TX_OK;
 }
 /*
 This function returns all the memory mapped registers of the device.
diff --git a/drivers/net/appletalk/cops.c b/drivers/net/appletalk/cops.c
index 7f83254..29b279f 100644
--- a/drivers/net/appletalk/cops.c
+++ b/drivers/net/appletalk/cops.c
@@ -920,7 +920,7 @@ static int cops_send_packet(struct sk_buff *skb, struct net_device *dev)
 	dev->stats.tx_bytes += skb->len;
 	dev->trans_start = jiffies;
 	dev_kfree_skb (skb);
-        return 0;
+        return NETDEV_TX_OK;
 }
 
 /*
diff --git a/drivers/net/appletalk/ipddp.c b/drivers/net/appletalk/ipddp.c
index 78cea5e..6cfd961 100644
--- a/drivers/net/appletalk/ipddp.c
+++ b/drivers/net/appletalk/ipddp.c
@@ -132,7 +132,7 @@ static int ipddp_xmit(struct sk_buff *skb, struct net_device *dev)
         }
         if(rt == NULL) {
 		spin_unlock(&ipddp_route_lock);
-                return 0;
+                return NETDEV_TX_OK;
 	}
 
         our_addr = atalk_find_dev_addr(rt->dev);
@@ -181,7 +181,7 @@ static int ipddp_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	spin_unlock(&ipddp_route_lock);
 
-        return 0;
+        return NETDEV_TX_OK;
 }
 
 /*
diff --git a/drivers/net/appletalk/ltpc.c b/drivers/net/appletalk/ltpc.c
index b642647..c80fb9c 100644
--- a/drivers/net/appletalk/ltpc.c
+++ b/drivers/net/appletalk/ltpc.c
@@ -932,7 +932,7 @@ static int ltpc_xmit(struct sk_buff *skb, struct net_device *dev)
 	dev->stats.tx_bytes += skb->len;
 
 	dev_kfree_skb(skb);
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 /* initialization stuff */
diff --git a/drivers/net/ariadne.c b/drivers/net/ariadne.c
index 58e8d52..47d976c 100644
--- a/drivers/net/ariadne.c
+++ b/drivers/net/ariadne.c
@@ -610,7 +610,7 @@ static int ariadne_start_xmit(struct sk_buff *skb, struct net_device *dev)
     if (skb->len < ETH_ZLEN)
     {
     	if (skb_padto(skb, ETH_ZLEN))
-    	    return 0;
+    	    return NETDEV_TX_OK;
     	len = ETH_ZLEN;
     }
 
@@ -685,7 +685,7 @@ static int ariadne_start_xmit(struct sk_buff *skb, struct net_device *dev)
     }
     local_irq_restore(flags);
 
-    return 0;
+    return NETDEV_TX_OK;
 }
 
 
diff --git a/drivers/net/arm/am79c961a.c b/drivers/net/arm/am79c961a.c
index 627bc75..164b37e 100644
--- a/drivers/net/arm/am79c961a.c
+++ b/drivers/net/arm/am79c961a.c
@@ -482,7 +482,7 @@ am79c961_sendpacket(struct sk_buff *skb, struct net_device *dev)
 
 	dev_kfree_skb(skb);
 
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 /*
diff --git a/drivers/net/arm/at91_ether.c b/drivers/net/arm/at91_ether.c
index 2e7419a..d46a06e 100644
--- a/drivers/net/arm/at91_ether.c
+++ b/drivers/net/arm/at91_ether.c
@@ -834,7 +834,7 @@ static int at91ether_start_xmit(struct sk_buff *skb, struct net_device *dev)
 				we free and return(0) or don't free and return 1 */
 	}
 
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 /*
diff --git a/drivers/net/arm/ether1.c b/drivers/net/arm/ether1.c
index edf770f..e47c0d9 100644
--- a/drivers/net/arm/ether1.c
+++ b/drivers/net/arm/ether1.c
@@ -748,7 +748,7 @@ ether1_sendpacket (struct sk_buff *skb, struct net_device *dev)
 		netif_stop_queue(dev);
 
  out:
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 static void
diff --git a/drivers/net/arm/ether3.c b/drivers/net/arm/ether3.c
index 4550371..1f7a69c 100644
--- a/drivers/net/arm/ether3.c
+++ b/drivers/net/arm/ether3.c
@@ -511,7 +511,7 @@ ether3_sendpacket(struct sk_buff *skb, struct net_device *dev)
 		dev_kfree_skb(skb);
 		priv(dev)->stats.tx_dropped ++;
 		netif_start_queue(dev);
-		return 0;
+		return NETDEV_TX_OK;
 	}
 
 	length = (length + 1) & ~1;
@@ -562,7 +562,7 @@ ether3_sendpacket(struct sk_buff *skb, struct net_device *dev)
 		netif_stop_queue(dev);
 
  out:
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 static irqreturn_t
diff --git a/drivers/net/at1700.c b/drivers/net/at1700.c
index 18b566a..c2227d7 100644
--- a/drivers/net/at1700.c
+++ b/drivers/net/at1700.c
@@ -643,7 +643,7 @@ static int net_send_packet (struct sk_buff *skb, struct net_device *dev)
 		netif_start_queue (dev);
 	dev_kfree_skb (skb);
 
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 /* The typical workload of the driver:
diff --git a/drivers/net/atarilance.c b/drivers/net/atarilance.c
index 5425ab0..0c0dece 100644
--- a/drivers/net/atarilance.c
+++ b/drivers/net/atarilance.c
@@ -796,7 +796,7 @@ static int lance_start_xmit( struct sk_buff *skb, struct net_device *dev )
 
 	if (len > skb->len) {
 		if (skb_padto(skb, len))
-			return 0;
+			return NETDEV_TX_OK;
 	}
 
 	netif_stop_queue (dev);
@@ -846,7 +846,7 @@ static int lance_start_xmit( struct sk_buff *skb, struct net_device *dev )
 		lp->tx_full = 1;
 	spin_unlock_irqrestore (&lp->devlock, flags);
 
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 /* The LANCE interrupt handler. */
diff --git a/drivers/net/atp.c b/drivers/net/atp.c
index 4317b3e..4beacc9 100644
--- a/drivers/net/atp.c
+++ b/drivers/net/atp.c
@@ -587,7 +587,7 @@ static int atp_send_packet(struct sk_buff *skb, struct net_device *dev)
 
 	dev->trans_start = jiffies;
 	dev_kfree_skb (skb);
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 
diff --git a/drivers/net/au1000_eth.c b/drivers/net/au1000_eth.c
index d3c734f..2aab1eb 100644
--- a/drivers/net/au1000_eth.c
+++ b/drivers/net/au1000_eth.c
@@ -988,7 +988,7 @@ static int au1000_tx(struct sk_buff *skb, struct net_device *dev)
 	dev_kfree_skb(skb);
 	aup->tx_head = (aup->tx_head + 1) & (NUM_TX_DMA - 1);
 	dev->trans_start = jiffies;
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 /*
diff --git a/drivers/net/bfin_mac.c b/drivers/net/bfin_mac.c
index c15fc28..f580b21 100644
--- a/drivers/net/bfin_mac.c
+++ b/drivers/net/bfin_mac.c
@@ -656,7 +656,7 @@ out:
 	dev->trans_start = jiffies;
 	dev->stats.tx_packets++;
 	dev->stats.tx_bytes += (skb->len);
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 static void bfin_mac_rx(struct net_device *dev)
diff --git a/drivers/net/bmac.c b/drivers/net/bmac.c
index 9578a3d..4160001 100644
--- a/drivers/net/bmac.c
+++ b/drivers/net/bmac.c
@@ -1488,7 +1488,7 @@ bmac_output(struct sk_buff *skb, struct net_device *dev)
 	struct bmac_data *bp = netdev_priv(dev);
 	skb_queue_tail(bp->queue, skb);
 	bmac_start(dev);
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 static void bmac_tx_timeout(unsigned long data)
diff --git a/drivers/net/can/sja1000/sja1000.c b/drivers/net/can/sja1000/sja1000.c
index 571f133..1c30dbe 100644
--- a/drivers/net/can/sja1000/sja1000.c
+++ b/drivers/net/can/sja1000/sja1000.c
@@ -283,7 +283,7 @@ static int sja1000_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	priv->write_reg(priv, REG_CMR, CMD_TR);
 
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 static void sja1000_rx(struct net_device *dev)
diff --git a/drivers/net/cassini.c b/drivers/net/cassini.c
index eb06667..299a33b 100644
--- a/drivers/net/cassini.c
+++ b/drivers/net/cassini.c
@@ -2928,7 +2928,7 @@ static int cas_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	static int ring;
 
 	if (skb_padto(skb, cp->min_frame_size))
-		return 0;
+		return NETDEV_TX_OK;
 
 	/* XXX: we need some higher-level QoS hooks to steer packets to
 	 *      individual queues.
@@ -2936,7 +2936,7 @@ static int cas_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (cas_xmit_tx_ringN(cp, ring++ & N_TX_RINGS_MASK, skb))
 		return NETDEV_TX_BUSY;
 	dev->trans_start = jiffies;
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 static void cas_init_tx_dma(struct cas *cp)
diff --git a/drivers/net/cris/eth_v10.c b/drivers/net/cris/eth_v10.c
index 7a18dc7..15c0195 100644
--- a/drivers/net/cris/eth_v10.c
+++ b/drivers/net/cris/eth_v10.c
@@ -1108,7 +1108,7 @@ e100_send_packet(struct sk_buff *skb, struct net_device *dev)
 
 	spin_unlock_irqrestore(&np->lock, flags);
 
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 /*
diff --git a/drivers/net/cs89x0.c b/drivers/net/cs89x0.c
index 3eee666..b5f553a 100644
--- a/drivers/net/cs89x0.c
+++ b/drivers/net/cs89x0.c
@@ -1571,7 +1571,7 @@ static int net_send_packet(struct sk_buff *skb, struct net_device *dev)
 	 * to restart the netdevice layer
 	 */
 
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 /* The typical workload of the driver:
diff --git a/drivers/net/de600.c b/drivers/net/de600.c
index e1af089..6b13f4f 100644
--- a/drivers/net/de600.c
+++ b/drivers/net/de600.c
@@ -226,7 +226,7 @@ static int de600_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	}
 	spin_unlock_irqrestore(&de600_lock, flags);
 	dev_kfree_skb(skb);
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 /*
diff --git a/drivers/net/de620.c b/drivers/net/de620.c
index 55d2bb6..45794f6 100644
--- a/drivers/net/de620.c
+++ b/drivers/net/de620.c
@@ -542,7 +542,7 @@ static int de620_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	dev->stats.tx_packets++;
 	spin_unlock_irqrestore(&de620_lock, flags);
 	dev_kfree_skb (skb);
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 /*****************************************************
diff --git a/drivers/net/declance.c b/drivers/net/declance.c
index 2b22e58..a31696a 100644
--- a/drivers/net/declance.c
+++ b/drivers/net/declance.c
@@ -902,7 +902,7 @@ static int lance_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	if (len < ETH_ZLEN) {
 		if (skb_padto(skb, ETH_ZLEN))
-			return 0;
+			return NETDEV_TX_OK;
 		len = ETH_ZLEN;
 	}
 
@@ -933,7 +933,7 @@ static int lance_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	dev->trans_start = jiffies;
 	dev_kfree_skb(skb);
 
- 	return 0;
+ 	return NETDEV_TX_OK;
 }
 
 static void lance_load_multicast(struct net_device *dev)
diff --git a/drivers/net/dm9000.c b/drivers/net/dm9000.c
index dd771de..ffd9edc 100644
--- a/drivers/net/dm9000.c
+++ b/drivers/net/dm9000.c
@@ -788,7 +788,7 @@ dm9000_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	/* free this SKB */
 	dev_kfree_skb(skb);
 
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 /*
diff --git a/drivers/net/dnet.c b/drivers/net/dnet.c
index 33fa9ee..2818d5d 100644
--- a/drivers/net/dnet.c
+++ b/drivers/net/dnet.c
@@ -596,7 +596,7 @@ static int dnet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	dev->trans_start = jiffies;
 
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 static void dnet_reset_hw(struct dnet *bp)
diff --git a/drivers/net/dummy.c b/drivers/net/dummy.c
index 8ebd7d7..713ce6c 100644
--- a/drivers/net/dummy.c
+++ b/drivers/net/dummy.c
@@ -85,7 +85,7 @@ static int dummy_xmit(struct sk_buff *skb, struct net_device *dev)
 	dev->stats.tx_bytes += skb->len;
 
 	dev_kfree_skb(skb);
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 static int dummy_validate(struct nlattr *tb[], struct nlattr *data[])
diff --git a/drivers/net/e100.c b/drivers/net/e100.c
index efa680f..a150d58 100644
--- a/drivers/net/e100.c
+++ b/drivers/net/e100.c
@@ -1720,7 +1720,7 @@ static int e100_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	}
 
 	netdev->trans_start = jiffies;
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 static int e100_tx_clean(struct nic *nic)
diff --git a/drivers/net/eepro.c b/drivers/net/eepro.c
index cc2ab64..71605d6 100644
--- a/drivers/net/eepro.c
+++ b/drivers/net/eepro.c
@@ -1145,7 +1145,7 @@ static int eepro_send_packet(struct sk_buff *skb, struct net_device *dev)
 
 	if (length < ETH_ZLEN) {
 		if (skb_padto(skb, ETH_ZLEN))
-			return 0;
+			return NETDEV_TX_OK;
 		length = ETH_ZLEN;
 	}
 	netif_stop_queue (dev);
@@ -1178,7 +1178,7 @@ static int eepro_send_packet(struct sk_buff *skb, struct net_device *dev)
 	eepro_en_int(ioaddr);
 	spin_unlock_irqrestore(&lp->lock, flags);
 
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 
diff --git a/drivers/net/eexpress.c b/drivers/net/eexpress.c
index 1686dca..8c44ef4 100644
--- a/drivers/net/eexpress.c
+++ b/drivers/net/eexpress.c
@@ -664,7 +664,7 @@ static int eexp_xmit(struct sk_buff *buf, struct net_device *dev)
 
 	if (buf->len < ETH_ZLEN) {
 		if (skb_padto(buf, ETH_ZLEN))
-			return 0;
+			return NETDEV_TX_OK;
 		length = ETH_ZLEN;
 	}
 
@@ -691,7 +691,7 @@ static int eexp_xmit(struct sk_buff *buf, struct net_device *dev)
 	spin_unlock_irqrestore(&lp->lock, flags);
 #endif
 	enable_irq(dev->irq);
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 /*
diff --git a/drivers/net/enc28j60.c b/drivers/net/enc28j60.c
index fc6cc03..372d6c6 100644
--- a/drivers/net/enc28j60.c
+++ b/drivers/net/enc28j60.c
@@ -1299,7 +1299,7 @@ static int enc28j60_send_packet(struct sk_buff *skb, struct net_device *dev)
 	priv->tx_skb = skb;
 	schedule_work(&priv->tx_work);
 
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 static void enc28j60_tx_work_handler(struct work_struct *work)
diff --git a/drivers/net/epic100.c b/drivers/net/epic100.c
index b60e27d..d6a7aa3 100644
--- a/drivers/net/epic100.c
+++ b/drivers/net/epic100.c
@@ -970,7 +970,7 @@ static int epic_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	unsigned long flags;
 
 	if (skb_padto(skb, ETH_ZLEN))
-		return 0;
+		return NETDEV_TX_OK;
 
 	/* Caution: the write order is important here, set the field with the
 	   "ownership" bit last. */
@@ -1014,7 +1014,7 @@ static int epic_start_xmit(struct sk_buff *skb, struct net_device *dev)
 			   dev->name, (int)skb->len, entry, ctrl_word,
 			   (int)inl(dev->base_addr + TxSTAT));
 
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 static void epic_tx_error(struct net_device *dev, struct epic_private *ep,
diff --git a/drivers/net/eql.c b/drivers/net/eql.c
index 19b7dd9..c0e69c5 100644
--- a/drivers/net/eql.c
+++ b/drivers/net/eql.c
@@ -348,7 +348,7 @@ static int eql_slave_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	spin_unlock(&eql->queue.lock);
 
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 /*
diff --git a/drivers/net/eth16i.c b/drivers/net/eth16i.c
index 0d8b6da..97d5205 100644
--- a/drivers/net/eth16i.c
+++ b/drivers/net/eth16i.c
@@ -1064,7 +1064,7 @@ static int eth16i_tx(struct sk_buff *skb, struct net_device *dev)
 
 	if (length < ETH_ZLEN) {
 		if (skb_padto(skb, ETH_ZLEN))
-			return 0;
+			return NETDEV_TX_OK;
 		length = ETH_ZLEN;
 	}
 	buf = skb->data;
@@ -1126,7 +1126,7 @@ static int eth16i_tx(struct sk_buff *skb, struct net_device *dev)
 	/* outb(TX_INTR_DONE | TX_INTR_16_COL, ioaddr + TX_INTR_REG); */
 	status = 0;
 	dev_kfree_skb(skb);
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 static void eth16i_rx(struct net_device *dev)
diff --git a/drivers/net/ewrk3.c b/drivers/net/ewrk3.c
index 1e97232..9c51bc8 100644
--- a/drivers/net/ewrk3.c
+++ b/drivers/net/ewrk3.c
@@ -868,7 +868,7 @@ static int ewrk3_queue_pkt (struct sk_buff *skb, struct net_device *dev)
 	if (inb (EWRK3_FMQC) == 0)
 		netif_stop_queue (dev);
 
-	return 0;
+	return NETDEV_TX_OK;
 
 err_out:
 	ENABLE_IRQs;
diff --git a/drivers/net/fealnx.c b/drivers/net/fealnx.c
index 891be28..75e5fe5 100644
--- a/drivers/net/fealnx.c
+++ b/drivers/net/fealnx.c
@@ -1374,7 +1374,7 @@ static int start_tx(struct sk_buff *skb, struct net_device *dev)
 	dev->trans_start = jiffies;
 
 	spin_unlock_irqrestore(&np->lock, flags);
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 
diff --git a/drivers/net/fec.c b/drivers/net/fec.c
index 0f19b74..08f1edb 100644
--- a/drivers/net/fec.c
+++ b/drivers/net/fec.c
@@ -366,7 +366,7 @@ fec_enet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	spin_unlock_irqrestore(&fep->hw_lock, flags);
 
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 static void
diff --git a/drivers/net/hamachi.c b/drivers/net/hamachi.c
index 9d5b62c..4e8d372 100644
--- a/drivers/net/hamachi.c
+++ b/drivers/net/hamachi.c
@@ -1369,7 +1369,7 @@ static int hamachi_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		printk(KERN_DEBUG "%s: Hamachi transmit frame #%d queued in slot %d.\n",
 			   dev->name, hmp->cur_tx, entry);
 	}
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 /* The interrupt handler does all of the Rx thread work and cleans up
diff --git a/drivers/net/hamradio/6pack.c b/drivers/net/hamradio/6pack.c
index 1551600..e88209f 100644
--- a/drivers/net/hamradio/6pack.c
+++ b/drivers/net/hamradio/6pack.c
@@ -255,7 +255,7 @@ static int sp_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	dev_kfree_skb(skb);
 
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 static int sp_open_dev(struct net_device *dev)
diff --git a/drivers/net/hamradio/baycom_epp.c b/drivers/net/hamradio/baycom_epp.c
index 5e4b7af..e229edf 100644
--- a/drivers/net/hamradio/baycom_epp.c
+++ b/drivers/net/hamradio/baycom_epp.c
@@ -774,18 +774,18 @@ static int baycom_send_packet(struct sk_buff *skb, struct net_device *dev)
 	if (skb->data[0] != 0) {
 		do_kiss_params(bc, skb->data, skb->len);
 		dev_kfree_skb(skb);
-		return 0;
+		return NETDEV_TX_OK;
 	}
 	if (bc->skb)
 		return NETDEV_TX_LOCKED;
 	/* strip KISS byte */
 	if (skb->len >= HDLCDRV_MAXFLEN+1 || skb->len < 3) {
 		dev_kfree_skb(skb);
-		return 0;
+		return NETDEV_TX_OK;
 	}
 	netif_stop_queue(dev);
 	bc->skb = skb;
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 /* --------------------------------------------------------------------- */
diff --git a/drivers/net/hamradio/bpqether.c b/drivers/net/hamradio/bpqether.c
index abcd19a..4c5f4df 100644
--- a/drivers/net/hamradio/bpqether.c
+++ b/drivers/net/hamradio/bpqether.c
@@ -305,7 +305,7 @@ static int bpq_xmit(struct sk_buff *skb, struct net_device *dev)
   
 	dev_queue_xmit(skb);
 	netif_wake_queue(dev);
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 /*
diff --git a/drivers/net/hamradio/dmascc.c b/drivers/net/hamradio/dmascc.c
index 7459b3a..950f3bb 100644
--- a/drivers/net/hamradio/dmascc.c
+++ b/drivers/net/hamradio/dmascc.c
@@ -959,7 +959,7 @@ static int scc_send_packet(struct sk_buff *skb, struct net_device *dev)
 	spin_unlock_irqrestore(&priv->ring_lock, flags);
 	dev_kfree_skb(skb);
 
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 
diff --git a/drivers/net/hamradio/hdlcdrv.c b/drivers/net/hamradio/hdlcdrv.c
index d034f8c..16b060b 100644
--- a/drivers/net/hamradio/hdlcdrv.c
+++ b/drivers/net/hamradio/hdlcdrv.c
@@ -406,13 +406,13 @@ static int hdlcdrv_send_packet(struct sk_buff *skb, struct net_device *dev)
 	if (skb->data[0] != 0) {
 		do_kiss_params(sm, skb->data, skb->len);
 		dev_kfree_skb(skb);
-		return 0;
+		return NETDEV_TX_OK;
 	}
 	if (sm->skb)
 		return NETDEV_TX_LOCKED;
 	netif_stop_queue(dev);
 	sm->skb = skb;
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 /* --------------------------------------------------------------------- */
diff --git a/drivers/net/hamradio/mkiss.c b/drivers/net/hamradio/mkiss.c
index fda2fc8..ac191ef 100644
--- a/drivers/net/hamradio/mkiss.c
+++ b/drivers/net/hamradio/mkiss.c
@@ -560,7 +560,7 @@ static int ax_xmit(struct sk_buff *skb, struct net_device *dev)
 		kfree_skb(skb);
 	}
 
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 static int ax_open_dev(struct net_device *dev)
diff --git a/drivers/net/hamradio/scc.c b/drivers/net/hamradio/scc.c
index d712e7a..c540652 100644
--- a/drivers/net/hamradio/scc.c
+++ b/drivers/net/hamradio/scc.c
@@ -1643,7 +1643,7 @@ static int scc_net_tx(struct sk_buff *skb, struct net_device *dev)
 	if (skb->len > scc->stat.bufsize || skb->len < 2) {
 		scc->dev_stat.tx_dropped++;	/* bogus frame */
 		dev_kfree_skb(skb);
-		return 0;
+		return NETDEV_TX_OK;
 	}
 	
 	scc->dev_stat.tx_packets++;
@@ -1656,7 +1656,7 @@ static int scc_net_tx(struct sk_buff *skb, struct net_device *dev)
 	if (kisscmd) {
 		scc_set_param(scc, kisscmd, *skb->data);
 		dev_kfree_skb(skb);
-		return 0;
+		return NETDEV_TX_OK;
 	}
 
 	spin_lock_irqsave(&scc->lock, flags);
@@ -1684,7 +1684,7 @@ static int scc_net_tx(struct sk_buff *skb, struct net_device *dev)
 			__scc_start_tx_timer(scc, t_dwait, 0);
 	}
 	spin_unlock_irqrestore(&scc->lock, flags);
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 /* ----> ioctl functions <---- */
diff --git a/drivers/net/hamradio/yam.c b/drivers/net/hamradio/yam.c
index b066919..b85aa16 100644
--- a/drivers/net/hamradio/yam.c
+++ b/drivers/net/hamradio/yam.c
@@ -600,7 +600,7 @@ static int yam_send_packet(struct sk_buff *skb, struct net_device *dev)
 
 	skb_queue_tail(&yp->send_queue, skb);
 	dev->trans_start = jiffies;
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 static void yam_start_tx(struct net_device *dev, struct yam_port *yp)
diff --git a/drivers/net/hp100.c b/drivers/net/hp100.c
index 1d3429a..d1b6338 100644
--- a/drivers/net/hp100.c
+++ b/drivers/net/hp100.c
@@ -1499,7 +1499,7 @@ static int hp100_start_xmit_bm(struct sk_buff *skb, struct net_device *dev)
 		goto drop;
 
 	if (lp->chip == HP100_CHIPID_SHASTA && skb_padto(skb, ETH_ZLEN))
-		return 0;
+		return NETDEV_TX_OK;
 
 	/* Get Tx ring tail pointer */
 	if (lp->txrtail->next == lp->txrhead) {
@@ -1585,7 +1585,7 @@ static int hp100_start_xmit_bm(struct sk_buff *skb, struct net_device *dev)
 	lp->stats.tx_bytes += skb->len;
 	dev->trans_start = jiffies;
 
-	return 0;
+	return NETDEV_TX_OK;
 
 drop:
 	dev_kfree_skb(skb);
@@ -1752,7 +1752,7 @@ static int hp100_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	printk("hp100: %s: start_xmit: end\n", dev->name);
 #endif
 
-	return 0;
+	return NETDEV_TX_OK;
 
 drop:
 	dev_kfree_skb(skb);
diff --git a/drivers/net/ibmveth.c b/drivers/net/ibmveth.c
index 0995c43..76b295a 100644
--- a/drivers/net/ibmveth.c
+++ b/drivers/net/ibmveth.c
@@ -971,7 +971,7 @@ out:	spin_lock_irqsave(&adapter->stats_lock, flags);
 	spin_unlock_irqrestore(&adapter->stats_lock, flags);
 
 	dev_kfree_skb(skb);
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 static int ibmveth_poll(struct napi_struct *napi, int budget)
diff --git a/drivers/net/ioc3-eth.c b/drivers/net/ioc3-eth.c
index e3cfefa..8ec15ab 100644
--- a/drivers/net/ioc3-eth.c
+++ b/drivers/net/ioc3-eth.c
@@ -1515,7 +1515,7 @@ static int ioc3_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	spin_unlock_irq(&ip->ioc3_lock);
 
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 static void ioc3_timeout(struct net_device *dev)
diff --git a/drivers/net/irda/ali-ircc.c b/drivers/net/irda/ali-ircc.c
index ad17955..7098357 100644
--- a/drivers/net/irda/ali-ircc.c
+++ b/drivers/net/irda/ali-ircc.c
@@ -1466,7 +1466,7 @@ static int ali_ircc_fir_hard_xmit(struct sk_buff *skb, struct net_device *dev)
 			dev->trans_start = jiffies;
 			spin_unlock_irqrestore(&self->lock, flags);
 			dev_kfree_skb(skb);
-			return 0;
+			return NETDEV_TX_OK;
 		} else
 			self->new_speed = speed;
 	}
@@ -1577,7 +1577,7 @@ static int ali_ircc_fir_hard_xmit(struct sk_buff *skb, struct net_device *dev)
 	dev_kfree_skb(skb);
 
 	IRDA_DEBUG(1, "%s(), ----------------- End ------------------\n", __func__ );
-	return 0;	
+	return NETDEV_TX_OK;	
 }
 
 
@@ -1991,7 +1991,7 @@ static int ali_ircc_sir_hard_xmit(struct sk_buff *skb, struct net_device *dev)
 			dev->trans_start = jiffies;
 			spin_unlock_irqrestore(&self->lock, flags);
 			dev_kfree_skb(skb);
-			return 0;
+			return NETDEV_TX_OK;
 		} else
 			self->new_speed = speed;
 	}
@@ -2015,7 +2015,7 @@ static int ali_ircc_sir_hard_xmit(struct sk_buff *skb, struct net_device *dev)
 	
 	IRDA_DEBUG(2, "%s(), ----------------- End ------------------\n", __func__ );
 	
-	return 0;	
+	return NETDEV_TX_OK;	
 }
 
 
diff --git a/drivers/net/irda/au1k_ir.c b/drivers/net/irda/au1k_ir.c
index c4361d4..22baf65 100644
--- a/drivers/net/irda/au1k_ir.c
+++ b/drivers/net/irda/au1k_ir.c
@@ -502,7 +502,7 @@ static int au1k_irda_hard_xmit(struct sk_buff *skb, struct net_device *dev)
 			aup->newspeed = 0;
 		}
 		dev_kfree_skb(skb);
-		return 0;
+		return NETDEV_TX_OK;
 	}
 
 	ptxd = aup->tx_ring[aup->tx_head];
@@ -555,7 +555,7 @@ static int au1k_irda_hard_xmit(struct sk_buff *skb, struct net_device *dev)
 	dev_kfree_skb(skb);
 	aup->tx_head = (aup->tx_head + 1) & (NUM_IR_DESC - 1);
 	dev->trans_start = jiffies;
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 
diff --git a/drivers/net/irda/donauboe.c b/drivers/net/irda/donauboe.c
index 9a0346e..1484c76 100644
--- a/drivers/net/irda/donauboe.c
+++ b/drivers/net/irda/donauboe.c
@@ -1021,7 +1021,7 @@ toshoboe_hard_xmit (struct sk_buff *skb, struct net_device *dev)
             {
 	      spin_unlock_irqrestore(&self->spinlock, flags);
               dev_kfree_skb (skb);
-              return 0;
+              return NETDEV_TX_OK;
             }
           /* True packet, go on, but */
           /* do not accept anything before change speed execution */
@@ -1036,7 +1036,7 @@ toshoboe_hard_xmit (struct sk_buff *skb, struct net_device *dev)
           toshoboe_setbaud (self);
 	  spin_unlock_irqrestore(&self->spinlock, flags);
           dev_kfree_skb (skb);
-          return 0;
+          return NETDEV_TX_OK;
         }
 
     }
@@ -1143,7 +1143,7 @@ dumpbufs(skb->data,skb->len,'>');
   spin_unlock_irqrestore(&self->spinlock, flags);
   dev_kfree_skb (skb);
 
-  return 0;
+  return NETDEV_TX_OK;
 }
 
 /*interrupt handler */
diff --git a/drivers/net/irda/irda-usb.c b/drivers/net/irda/irda-usb.c
index 0c0831c..6a1aa7a 100644
--- a/drivers/net/irda/irda-usb.c
+++ b/drivers/net/irda/irda-usb.c
@@ -534,7 +534,7 @@ static int irda_usb_hard_xmit(struct sk_buff *skb, struct net_device *netdev)
 	}
 	spin_unlock_irqrestore(&self->lock, flags);
 	
-	return 0;
+	return NETDEV_TX_OK;
 
 drop:
 	/* Drop silently the skb and exit */
diff --git a/drivers/net/irda/nsc-ircc.c b/drivers/net/irda/nsc-ircc.c
index 45fd9c1..05bfc98 100644
--- a/drivers/net/irda/nsc-ircc.c
+++ b/drivers/net/irda/nsc-ircc.c
@@ -1397,7 +1397,7 @@ static int nsc_ircc_hard_xmit_sir(struct sk_buff *skb, struct net_device *dev)
 			dev->trans_start = jiffies;
 			spin_unlock_irqrestore(&self->lock, flags);
 			dev_kfree_skb(skb);
-			return 0;
+			return NETDEV_TX_OK;
 		} else
 			self->new_speed = speed;
 	}
@@ -1424,7 +1424,7 @@ static int nsc_ircc_hard_xmit_sir(struct sk_buff *skb, struct net_device *dev)
 
 	dev_kfree_skb(skb);
 
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 static int nsc_ircc_hard_xmit_fir(struct sk_buff *skb, struct net_device *dev)
@@ -1467,7 +1467,7 @@ static int nsc_ircc_hard_xmit_fir(struct sk_buff *skb, struct net_device *dev)
 			dev->trans_start = jiffies;
 			spin_unlock_irqrestore(&self->lock, flags);
 			dev_kfree_skb(skb);
-			return 0;
+			return NETDEV_TX_OK;
 		} else {
 			/* Change speed after current frame */
 			self->new_speed = speed;
@@ -1554,7 +1554,7 @@ static int nsc_ircc_hard_xmit_fir(struct sk_buff *skb, struct net_device *dev)
 	spin_unlock_irqrestore(&self->lock, flags);
 	dev_kfree_skb(skb);
 
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 /*
diff --git a/drivers/net/irda/pxaficp_ir.c b/drivers/net/irda/pxaficp_ir.c
index 3376a4f..e76a083 100644
--- a/drivers/net/irda/pxaficp_ir.c
+++ b/drivers/net/irda/pxaficp_ir.c
@@ -504,7 +504,7 @@ static int pxa_irda_hard_xmit(struct sk_buff *skb, struct net_device *dev)
 			pxa_irda_set_speed(si, speed);
 		}
 		dev_kfree_skb(skb);
-		return 0;
+		return NETDEV_TX_OK;
 	}
 
 	netif_stop_queue(dev);
@@ -539,7 +539,7 @@ static int pxa_irda_hard_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	dev_kfree_skb(skb);
 	dev->trans_start = jiffies;
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 static int pxa_irda_ioctl(struct net_device *dev, struct ifreq *ifreq, int cmd)
diff --git a/drivers/net/irda/sa1100_ir.c b/drivers/net/irda/sa1100_ir.c
index 2aeb2e6..70e6acc 100644
--- a/drivers/net/irda/sa1100_ir.c
+++ b/drivers/net/irda/sa1100_ir.c
@@ -667,7 +667,7 @@ static int sa1100_irda_hard_xmit(struct sk_buff *skb, struct net_device *dev)
 			sa1100_irda_set_speed(si, speed);
 		}
 		dev_kfree_skb(skb);
-		return 0;
+		return NETDEV_TX_OK;
 	}
 
 	if (!IS_FIR(si)) {
@@ -715,7 +715,7 @@ static int sa1100_irda_hard_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	dev->trans_start = jiffies;
 
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 static int
diff --git a/drivers/net/irda/sir_dev.c b/drivers/net/irda/sir_dev.c
index fd0796c..bde004f 100644
--- a/drivers/net/irda/sir_dev.c
+++ b/drivers/net/irda/sir_dev.c
@@ -621,7 +621,7 @@ static int sirdev_hard_xmit(struct sk_buff *skb, struct net_device *ndev)
 			 */
 
 			dev_kfree_skb_any(skb);
-			return 0;
+			return NETDEV_TX_OK;
 		} else
 			dev->new_speed = speed;
 	}
@@ -668,7 +668,7 @@ static int sirdev_hard_xmit(struct sk_buff *skb, struct net_device *ndev)
 	}
 	spin_unlock_irqrestore(&dev->tx_lock, flags);
 
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 /* called from network layer with rtnl hold */
diff --git a/drivers/net/irda/stir4200.c b/drivers/net/irda/stir4200.c
index 8e5e45c..c475b23 100644
--- a/drivers/net/irda/stir4200.c
+++ b/drivers/net/irda/stir4200.c
@@ -578,7 +578,7 @@ static int stir_hard_xmit(struct sk_buff *skb, struct net_device *netdev)
 		dev_kfree_skb(skb);
 	}
 
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 /*
diff --git a/drivers/net/irda/via-ircc.c b/drivers/net/irda/via-ircc.c
index 8647985..62ba94b 100644
--- a/drivers/net/irda/via-ircc.c
+++ b/drivers/net/irda/via-ircc.c
@@ -844,7 +844,7 @@ static int via_ircc_hard_xmit_sir(struct sk_buff *skb,
 			via_ircc_change_speed(self, speed);
 			dev->trans_start = jiffies;
 			dev_kfree_skb(skb);
-			return 0;
+			return NETDEV_TX_OK;
 		} else
 			self->new_speed = speed;
 	}
@@ -892,7 +892,7 @@ static int via_ircc_hard_xmit_sir(struct sk_buff *skb,
 	dev->trans_start = jiffies;
 	spin_unlock_irqrestore(&self->lock, flags);
 	dev_kfree_skb(skb);
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 static int via_ircc_hard_xmit_fir(struct sk_buff *skb,
@@ -907,7 +907,7 @@ static int via_ircc_hard_xmit_fir(struct sk_buff *skb,
 	iobase = self->io.fir_base;
 
 	if (self->st_fifo.len)
-		return 0;
+		return NETDEV_TX_OK;
 	if (self->chip_id == 0x3076)
 		iodelay(1500);
 	else
@@ -919,7 +919,7 @@ static int via_ircc_hard_xmit_fir(struct sk_buff *skb,
 			via_ircc_change_speed(self, speed);
 			dev->trans_start = jiffies;
 			dev_kfree_skb(skb);
-			return 0;
+			return NETDEV_TX_OK;
 		} else
 			self->new_speed = speed;
 	}
@@ -940,7 +940,7 @@ static int via_ircc_hard_xmit_fir(struct sk_buff *skb,
 	dev->trans_start = jiffies;
 	dev_kfree_skb(skb);
 	spin_unlock_irqrestore(&self->lock, flags);
-	return 0;
+	return NETDEV_TX_OK;
 
 }
 
diff --git a/drivers/net/irda/vlsi_ir.c b/drivers/net/irda/vlsi_ir.c
index ac0e4b6..08e26f1 100644
--- a/drivers/net/irda/vlsi_ir.c
+++ b/drivers/net/irda/vlsi_ir.c
@@ -915,7 +915,7 @@ static int vlsi_hard_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 			 */
 		spin_unlock_irqrestore(&idev->lock, flags);
 		dev_kfree_skb_any(skb);
-		return 0;
+		return NETDEV_TX_OK;
 	}
 
 	/* sanity checks - simply drop the packet */
@@ -1044,7 +1044,7 @@ static int vlsi_hard_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 	}
 	spin_unlock_irqrestore(&idev->lock, flags);
 
-	return 0;
+	return NETDEV_TX_OK;
 
 drop_unlock:
 	spin_unlock_irqrestore(&idev->lock, flags);
@@ -1058,7 +1058,7 @@ drop:
 	 * packet for later retry of transmission - which isn't exactly
 	 * what we want after we've just called dev_kfree_skb_any ;-)
 	 */
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 static void vlsi_tx_interrupt(struct net_device *ndev)
diff --git a/drivers/net/irda/w83977af_ir.c b/drivers/net/irda/w83977af_ir.c
index d088383..49ef763 100644
--- a/drivers/net/irda/w83977af_ir.c
+++ b/drivers/net/irda/w83977af_ir.c
@@ -516,7 +516,7 @@ static int w83977af_hard_xmit(struct sk_buff *skb, struct net_device *dev)
 			w83977af_change_speed(self, speed); 
 			dev->trans_start = jiffies;
 			dev_kfree_skb(skb);
-			return 0;
+			return NETDEV_TX_OK;
 		} else
 			self->new_speed = speed;
 	}
@@ -576,7 +576,7 @@ static int w83977af_hard_xmit(struct sk_buff *skb, struct net_device *dev)
 	/* Restore set register */
 	outb(set, iobase+SSR);
 
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 /*
diff --git a/drivers/net/isa-skeleton.c b/drivers/net/isa-skeleton.c
index 73585fd..86d2300 100644
--- a/drivers/net/isa-skeleton.c
+++ b/drivers/net/isa-skeleton.c
@@ -467,7 +467,7 @@ static int net_send_packet(struct sk_buff *skb, struct net_device *dev)
 	dev_kfree_skb (skb);
 #endif
 
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 #if TX_RING
diff --git a/drivers/net/iseries_veth.c b/drivers/net/iseries_veth.c
index e44215c..e36e951 100644
--- a/drivers/net/iseries_veth.c
+++ b/drivers/net/iseries_veth.c
@@ -1205,7 +1205,7 @@ static int veth_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 		if ( ! ((1 << rlp) & port->lpar_map) ) {
 			dev_kfree_skb(skb);
-			return 0;
+			return NETDEV_TX_OK;
 		}
 
 		lpmask = 1 << rlp;
@@ -1217,7 +1217,7 @@ static int veth_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	dev_kfree_skb(skb);
 
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 /* You must hold the connection's lock when you call this function. */
diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index 9c897cf..eb917f1 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -1459,7 +1459,7 @@ ixgb_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 
 	if (skb->len <= 0) {
 		dev_kfree_skb(skb);
-		return 0;
+		return NETDEV_TX_OK;
 	}
 
 	if (unlikely(ixgb_maybe_stop_tx(netdev, &adapter->tx_ring,
diff --git a/drivers/net/ixp2000/ixpdev.c b/drivers/net/ixp2000/ixpdev.c
index 2a0174b..588b44d 100644
--- a/drivers/net/ixp2000/ixpdev.c
+++ b/drivers/net/ixp2000/ixpdev.c
@@ -45,7 +45,7 @@ static int ixpdev_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (unlikely(skb->len > PAGE_SIZE)) {
 		/* @@@ Count drops.  */
 		dev_kfree_skb(skb);
-		return 0;
+		return NETDEV_TX_OK;
 	}
 
 	entry = tx_pointer;
@@ -69,7 +69,7 @@ static int ixpdev_xmit(struct sk_buff *skb, struct net_device *dev)
 		netif_stop_queue(dev);
 	local_irq_enable();
 
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 
diff --git a/drivers/net/lance.c b/drivers/net/lance.c
index 633808d..30fd4f5 100644
--- a/drivers/net/lance.c
+++ b/drivers/net/lance.c
@@ -1016,7 +1016,7 @@ static int lance_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 out:
 	spin_unlock_irqrestore(&lp->devlock, flags);
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 /* The LANCE interrupt handler. */
diff --git a/drivers/net/lib82596.c b/drivers/net/lib82596.c
index 070fa45..51e11c3 100644
--- a/drivers/net/lib82596.c
+++ b/drivers/net/lib82596.c
@@ -983,7 +983,7 @@ static int i596_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	if (length < ETH_ZLEN) {
 		if (skb_padto(skb, ETH_ZLEN))
-			return 0;
+			return NETDEV_TX_OK;
 		length = ETH_ZLEN;
 	}
 
@@ -1028,7 +1028,7 @@ static int i596_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	netif_start_queue(dev);
 
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 static void print_eth(unsigned char *add, char *str)
diff --git a/drivers/net/ll_temac_main.c b/drivers/net/ll_temac_main.c
index 96e7248..da8d0a0 100644
--- a/drivers/net/ll_temac_main.c
+++ b/drivers/net/ll_temac_main.c
@@ -591,7 +591,7 @@ static int temac_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 	/* Kick off the transfer */
 	temac_dma_out32(lp, TX_TAILDESC_PTR, tail_p); /* DMA start */
 
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 
diff --git a/drivers/net/loopback.c b/drivers/net/loopback.c
index da472c6..51bbce7 100644
--- a/drivers/net/loopback.c
+++ b/drivers/net/loopback.c
@@ -89,7 +89,7 @@ static int loopback_xmit(struct sk_buff *skb, struct net_device *dev)
 	} else
 		lb_stats->drops++;
 
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 static struct net_device_stats *loopback_get_stats(struct net_device *dev)
diff --git a/drivers/net/lp486e.c b/drivers/net/lp486e.c
index d44bddb..c292bad 100644
--- a/drivers/net/lp486e.c
+++ b/drivers/net/lp486e.c
@@ -871,7 +871,7 @@ static int i596_start_xmit (struct sk_buff *skb, struct net_device *dev) {
 
 	if (length < ETH_ZLEN) {
 		if (skb_padto(skb, ETH_ZLEN))
-			return 0;
+			return NETDEV_TX_OK;
 		length = ETH_ZLEN;
 	}
 
@@ -906,7 +906,7 @@ static int i596_start_xmit (struct sk_buff *skb, struct net_device *dev) {
 		dev->stats.tx_packets++;
 	}
 
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 static void
diff --git a/drivers/net/mac89x0.c b/drivers/net/mac89x0.c
index dab4533..149e0ed 100644
--- a/drivers/net/mac89x0.c
+++ b/drivers/net/mac89x0.c
@@ -411,7 +411,7 @@ net_send_packet(struct sk_buff *skb, struct net_device *dev)
 	dev->trans_start = jiffies;
 	dev_kfree_skb (skb);
 
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 /* The typical workload of the driver:
diff --git a/drivers/net/macb.c b/drivers/net/macb.c
index 5b5c253..d22952c 100644
--- a/drivers/net/macb.c
+++ b/drivers/net/macb.c
@@ -678,7 +678,7 @@ static int macb_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	dev->trans_start = jiffies;
 
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 static void macb_free_consistent(struct macb *bp)
diff --git a/drivers/net/mace.c b/drivers/net/mace.c
index 1427755..7d7577b 100644
--- a/drivers/net/mace.c
+++ b/drivers/net/mace.c
@@ -581,7 +581,7 @@ static int mace_xmit_start(struct sk_buff *skb, struct net_device *dev)
 	netif_stop_queue(dev);
     spin_unlock_irqrestore(&mp->lock, flags);
 
-    return 0;
+    return NETDEV_TX_OK;
 }
 
 static void mace_set_multicast(struct net_device *dev)
diff --git a/drivers/net/meth.c b/drivers/net/meth.c
index 5d04d94..abea35d 100644
--- a/drivers/net/meth.c
+++ b/drivers/net/meth.c
@@ -715,7 +715,7 @@ static int meth_tx(struct sk_buff *skb, struct net_device *dev)
 
 	spin_unlock_irqrestore(&priv->meth_lock, flags);
 
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 /*
diff --git a/drivers/net/mipsnet.c b/drivers/net/mipsnet.c
index b3b9a14..8ea98bd 100644
--- a/drivers/net/mipsnet.c
+++ b/drivers/net/mipsnet.c
@@ -141,7 +141,7 @@ static int mipsnet_xmit(struct sk_buff *skb, struct net_device *dev)
 	netif_stop_queue(dev);
 	mipsnet_put_todevice(dev, skb);
 
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 static inline ssize_t mipsnet_get_fromdev(struct net_device *dev, size_t len)
diff --git a/drivers/net/myri10ge/myri10ge.c b/drivers/net/myri10ge/myri10ge.c
index 1f6e36e..05cd24d 100644
--- a/drivers/net/myri10ge/myri10ge.c
+++ b/drivers/net/myri10ge/myri10ge.c
@@ -2748,7 +2748,7 @@ again:
 				/* The packet is gone, so we must
 				 * return 0 */
 				ss->stats.tx_dropped += 1;
-				return 0;
+				return NETDEV_TX_OK;
 			}
 			/* adjust the len to account for the zero pad
 			 * so that the nic can know how long it is */
@@ -2892,7 +2892,7 @@ again:
 		tx->stop_queue++;
 		netif_tx_stop_queue(netdev_queue);
 	}
-	return 0;
+	return NETDEV_TX_OK;
 
 abort_linearize:
 	/* Free any DMA resources we've alloced and clear out the skb
@@ -2936,7 +2936,7 @@ abort_linearize:
 drop:
 	dev_kfree_skb_any(skb);
 	ss->stats.tx_dropped += 1;
-	return 0;
+	return NETDEV_TX_OK;
 
 }
 
diff --git a/drivers/net/myri_sbus.c b/drivers/net/myri_sbus.c
index 5f0758b..29ebebc 100644
--- a/drivers/net/myri_sbus.c
+++ b/drivers/net/myri_sbus.c
@@ -692,7 +692,7 @@ static int myri_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	DTX(("tbusy=0, returning 0\n"));
 	netif_start_queue(dev);
 	spin_unlock_irqrestore(&mp->irq_lock, flags);
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 /* Create the MyriNet MAC header for an arbitrary protocol layer
diff --git a/drivers/net/natsemi.c b/drivers/net/natsemi.c
index c9bfe4e..481aa2d 100644
--- a/drivers/net/natsemi.c
+++ b/drivers/net/natsemi.c
@@ -2125,7 +2125,7 @@ static int start_tx(struct sk_buff *skb, struct net_device *dev)
 		printk(KERN_DEBUG "%s: Transmit frame #%d queued in slot %d.\n",
 			dev->name, np->cur_tx, entry);
 	}
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 static void netdev_tx_done(struct net_device *dev)
diff --git a/drivers/net/netx-eth.c b/drivers/net/netx-eth.c
index 946366d..9f42354 100644
--- a/drivers/net/netx-eth.c
+++ b/drivers/net/netx-eth.c
@@ -134,7 +134,7 @@ netx_eth_hard_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 	spin_unlock_irq(&priv->lock);
 	dev_kfree_skb(skb);
 
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 static void netx_eth_receive(struct net_device *ndev)
diff --git a/drivers/net/ni5010.c b/drivers/net/ni5010.c
index 2a8da47..462d20f 100644
--- a/drivers/net/ni5010.c
+++ b/drivers/net/ni5010.c
@@ -463,7 +463,7 @@ static int ni5010_send_packet(struct sk_buff *skb, struct net_device *dev)
 	hardware_send_packet(dev, (unsigned char *)skb->data, skb->len, length-skb->len);
 	dev->trans_start = jiffies;
 	dev_kfree_skb (skb);
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 /*
diff --git a/drivers/net/ni65.c b/drivers/net/ni65.c
index 1f10ed6..81a0617 100644
--- a/drivers/net/ni65.c
+++ b/drivers/net/ni65.c
@@ -1216,7 +1216,7 @@ static int ni65_send_packet(struct sk_buff *skb, struct net_device *dev)
 		spin_unlock_irqrestore(&p->ring_lock, flags);
 	}
 
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 static void set_multicast_list(struct net_device *dev)
diff --git a/drivers/net/pci-skeleton.c b/drivers/net/pci-skeleton.c
index 8c1f698..e4a93b8 100644
--- a/drivers/net/pci-skeleton.c
+++ b/drivers/net/pci-skeleton.c
@@ -1356,7 +1356,7 @@ static int netdrv_start_xmit (struct sk_buff *skb, struct net_device *dev)
 	DPRINTK ("%s: Queued Tx packet at %p size %u to slot %d.\n",
 		 dev->name, skb->data, skb->len, entry);
 
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 
diff --git a/drivers/net/pcmcia/3c574_cs.c b/drivers/net/pcmcia/3c574_cs.c
index f35c609..a23aa87 100644
--- a/drivers/net/pcmcia/3c574_cs.c
+++ b/drivers/net/pcmcia/3c574_cs.c
@@ -806,7 +806,7 @@ static int el3_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	pop_tx_status(dev);
 	spin_unlock_irqrestore(&lp->window_lock, flags);
 	dev_kfree_skb(skb);
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 /* The EL3 interrupt handler. */
diff --git a/drivers/net/pcmcia/3c589_cs.c b/drivers/net/pcmcia/3c589_cs.c
index ec7cf5a..a77417c 100644
--- a/drivers/net/pcmcia/3c589_cs.c
+++ b/drivers/net/pcmcia/3c589_cs.c
@@ -635,7 +635,7 @@ static int el3_start_xmit(struct sk_buff *skb, struct net_device *dev)
     spin_unlock_irqrestore(&priv->lock, flags);    
     dev_kfree_skb(skb);
     
-    return 0;
+    return NETDEV_TX_OK;
 }
 
 /* The EL3 interrupt handler. */
diff --git a/drivers/net/pcmcia/axnet_cs.c b/drivers/net/pcmcia/axnet_cs.c
index 0e38d80..b5cfac7 100644
--- a/drivers/net/pcmcia/axnet_cs.c
+++ b/drivers/net/pcmcia/axnet_cs.c
@@ -1179,7 +1179,7 @@ static int axnet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	dev_kfree_skb (skb);
 	dev->stats.tx_bytes += send_length;
     
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 /**
diff --git a/drivers/net/pcmcia/fmvj18x_cs.c b/drivers/net/pcmcia/fmvj18x_cs.c
index 479d5b4..434d940 100644
--- a/drivers/net/pcmcia/fmvj18x_cs.c
+++ b/drivers/net/pcmcia/fmvj18x_cs.c
@@ -865,7 +865,7 @@ static int fjn_start_xmit(struct sk_buff *skb, struct net_device *dev)
     if (length < ETH_ZLEN)
     {
     	if (skb_padto(skb, ETH_ZLEN))
-    		return 0;
+    		return NETDEV_TX_OK;
     	length = ETH_ZLEN;
     }
 
@@ -924,7 +924,7 @@ static int fjn_start_xmit(struct sk_buff *skb, struct net_device *dev)
     }
     dev_kfree_skb (skb);
 
-    return 0;
+    return NETDEV_TX_OK;
 } /* fjn_start_xmit */
 
 /*====================================================================*/
diff --git a/drivers/net/pcmcia/nmclan_cs.c b/drivers/net/pcmcia/nmclan_cs.c
index 02ef63e..0f8118a 100644
--- a/drivers/net/pcmcia/nmclan_cs.c
+++ b/drivers/net/pcmcia/nmclan_cs.c
@@ -990,7 +990,7 @@ static int mace_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
   dev_kfree_skb(skb);
 
-  return 0;
+  return NETDEV_TX_OK;
 } /* mace_start_xmit */
 
 /* ----------------------------------------------------------------------------
diff --git a/drivers/net/pcmcia/smc91c92_cs.c b/drivers/net/pcmcia/smc91c92_cs.c
index 37e05d3..2f39244 100644
--- a/drivers/net/pcmcia/smc91c92_cs.c
+++ b/drivers/net/pcmcia/smc91c92_cs.c
@@ -1399,7 +1399,7 @@ static int smc_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	dev_kfree_skb (skb);
 	smc->saved_skb = NULL;
 	dev->stats.tx_dropped++;
-	return 0;		/* Do not re-queue this packet. */
+	return NETDEV_TX_OK;		/* Do not re-queue this packet. */
     }
     /* A packet is now waiting. */
     smc->packets_waiting++;
@@ -1422,7 +1422,7 @@ static int smc_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	    outw((ir&0xff00) | IM_ALLOC_INT, ioaddr + INTERRUPT);
 	    smc_hardware_send_packet(dev);	/* Send the packet now.. */
 	    spin_unlock_irqrestore(&smc->lock, flags);
-	    return 0;
+	    return NETDEV_TX_OK;
 	}
     }
 
@@ -1431,7 +1431,7 @@ static int smc_start_xmit(struct sk_buff *skb, struct net_device *dev)
     outw((IM_ALLOC_INT << 8) | (ir & 0xff00), ioaddr + INTERRUPT);
     spin_unlock_irqrestore(&smc->lock, flags);
 
-    return 0;
+    return NETDEV_TX_OK;
 }
 
 /*======================================================================
diff --git a/drivers/net/pcmcia/xirc2ps_cs.c b/drivers/net/pcmcia/xirc2ps_cs.c
index ef37d22..eda7bf6 100644
--- a/drivers/net/pcmcia/xirc2ps_cs.c
+++ b/drivers/net/pcmcia/xirc2ps_cs.c
@@ -1384,7 +1384,7 @@ do_start_xmit(struct sk_buff *skb, struct net_device *dev)
     if (pktlen < ETH_ZLEN)
     {
         if (skb_padto(skb, ETH_ZLEN))
-        	return 0;
+        	return NETDEV_TX_OK;
 	pktlen = ETH_ZLEN;
     }
 
@@ -1414,7 +1414,7 @@ do_start_xmit(struct sk_buff *skb, struct net_device *dev)
     dev->trans_start = jiffies;
     dev->stats.tx_bytes += pktlen;
     netif_start_queue(dev);
-    return 0;
+    return NETDEV_TX_OK;
 }
 
 /****************
diff --git a/drivers/net/pcnet32.c b/drivers/net/pcnet32.c
index 1c35e1d..955a87a 100644
--- a/drivers/net/pcnet32.c
+++ b/drivers/net/pcnet32.c
@@ -2536,7 +2536,7 @@ static int pcnet32_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		netif_stop_queue(dev);
 	}
 	spin_unlock_irqrestore(&lp->lock, flags);
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 /* The PCNET32 interrupt handler. */
diff --git a/drivers/net/plip.c b/drivers/net/plip.c
index 7a62f78..ef2e229 100644
--- a/drivers/net/plip.c
+++ b/drivers/net/plip.c
@@ -987,7 +987,7 @@ plip_tx_packet(struct sk_buff *skb, struct net_device *dev)
 	schedule_work(&nl->immediate);
 	spin_unlock_irq(&nl->lock);
 
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 static void
diff --git a/drivers/net/ppp_generic.c b/drivers/net/ppp_generic.c
index 639d11b..d0b9655 100644
--- a/drivers/net/ppp_generic.c
+++ b/drivers/net/ppp_generic.c
@@ -988,12 +988,12 @@ ppp_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	netif_stop_queue(dev);
 	skb_queue_tail(&ppp->file.xq, skb);
 	ppp_xmit_process(ppp);
-	return 0;
+	return NETDEV_TX_OK;
 
  outf:
 	kfree_skb(skb);
 	++dev->stats.tx_dropped;
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 static int
diff --git a/drivers/net/rionet.c b/drivers/net/rionet.c
index 8702e7a..560d24f 100644
--- a/drivers/net/rionet.c
+++ b/drivers/net/rionet.c
@@ -208,7 +208,7 @@ static int rionet_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 
 	spin_unlock_irqrestore(&rnet->tx_lock, flags);
 
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 static void rionet_dbell_event(struct rio_mport *mport, void *dev_id, u16 sid, u16 tid,
diff --git a/drivers/net/rrunner.c b/drivers/net/rrunner.c
index 81dbcbb..d955346 100644
--- a/drivers/net/rrunner.c
+++ b/drivers/net/rrunner.c
@@ -1466,7 +1466,7 @@ static int rr_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	spin_unlock_irqrestore(&rrpriv->lock, flags);
 
 	dev->trans_start = jiffies;
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 
diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index 458daa0..d4df933 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -4111,14 +4111,14 @@ static int s2io_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (unlikely(skb->len <= 0)) {
 		DBG_PRINT(TX_DBG, "%s:Buffer has no data..\n", dev->name);
 		dev_kfree_skb_any(skb);
-		return 0;
+		return NETDEV_TX_OK;
 	}
 
 	if (!is_s2io_card_up(sp)) {
 		DBG_PRINT(TX_DBG, "%s: Card going down for reset\n",
 			  dev->name);
 		dev_kfree_skb(skb);
-		return 0;
+		return NETDEV_TX_OK;
 	}
 
 	queue = 0;
@@ -4192,7 +4192,7 @@ static int s2io_xmit(struct sk_buff *skb, struct net_device *dev)
 		s2io_stop_tx_queue(sp, fifo->fifo_no);
 		dev_kfree_skb(skb);
 		spin_unlock_irqrestore(&fifo->tx_lock, flags);
-		return 0;
+		return NETDEV_TX_OK;
 	}
 
 	offload_type = s2io_offload_type(skb);
@@ -4304,14 +4304,14 @@ static int s2io_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (sp->config.intr_type == MSI_X)
 		tx_intr_handler(fifo);
 
-	return 0;
+	return NETDEV_TX_OK;
 pci_map_failed:
 	stats->pci_map_fail_cnt++;
 	s2io_stop_tx_queue(sp, fifo->fifo_no);
 	stats->mem_freed += skb->truesize;
 	dev_kfree_skb(skb);
 	spin_unlock_irqrestore(&fifo->tx_lock, flags);
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 static void
diff --git a/drivers/net/sb1000.c b/drivers/net/sb1000.c
index fc0e38b..6a81aec 100644
--- a/drivers/net/sb1000.c
+++ b/drivers/net/sb1000.c
@@ -1086,7 +1086,7 @@ sb1000_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	printk(KERN_WARNING "%s: trying to transmit!!!\n", dev->name);
 	/* sb1000 can't xmit datagrams */
 	dev_kfree_skb(skb);
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 /* SB1000 interrupt handler. */
diff --git a/drivers/net/sb1250-mac.c b/drivers/net/sb1250-mac.c
index d8c9cf1..4c2450b 100644
--- a/drivers/net/sb1250-mac.c
+++ b/drivers/net/sb1250-mac.c
@@ -2091,7 +2091,7 @@ static int sbmac_start_tx(struct sk_buff *skb, struct net_device *dev)
 
 	spin_unlock_irqrestore(&sc->sbm_lock, flags);
 
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 /**********************************************************************
diff --git a/drivers/net/seeq8005.c b/drivers/net/seeq8005.c
index ebbbe09..7cc8bb8 100644
--- a/drivers/net/seeq8005.c
+++ b/drivers/net/seeq8005.c
@@ -401,7 +401,7 @@ static int seeq8005_send_packet(struct sk_buff *skb, struct net_device *dev)
 
 	if (length < ETH_ZLEN) {
 		if (skb_padto(skb, ETH_ZLEN))
-			return 0;
+			return NETDEV_TX_OK;
 		length = ETH_ZLEN;
 	}
 	buf = skb->data;
@@ -415,7 +415,7 @@ static int seeq8005_send_packet(struct sk_buff *skb, struct net_device *dev)
 	dev_kfree_skb (skb);
 	/* You might need to clean up and record Tx statistics here. */
 
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 /*
diff --git a/drivers/net/sgiseeq.c b/drivers/net/sgiseeq.c
index 5fb88ca..78f6008 100644
--- a/drivers/net/sgiseeq.c
+++ b/drivers/net/sgiseeq.c
@@ -594,7 +594,7 @@ static int sgiseeq_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	len = skb->len;
 	if (len < ETH_ZLEN) {
 		if (skb_padto(skb, ETH_ZLEN))
-			return 0;
+			return NETDEV_TX_OK;
 		len = ETH_ZLEN;
 	}
 
@@ -642,7 +642,7 @@ static int sgiseeq_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		netif_stop_queue(dev);
 	spin_unlock_irqrestore(&sp->tx_lock, flags);
 
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 static void timeout(struct net_device *dev)
diff --git a/drivers/net/sh_eth.c b/drivers/net/sh_eth.c
index 341882f..d9b5430 100644
--- a/drivers/net/sh_eth.c
+++ b/drivers/net/sh_eth.c
@@ -1140,7 +1140,7 @@ static int sh_eth_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 
 	ndev->trans_start = jiffies;
 
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 /* device close function */
diff --git a/drivers/net/sis900.c b/drivers/net/sis900.c
index a9a897b..61ceeaa 100644
--- a/drivers/net/sis900.c
+++ b/drivers/net/sis900.c
@@ -1628,7 +1628,7 @@ sis900_start_xmit(struct sk_buff *skb, struct net_device *net_dev)
 		       "to slot %d.\n",
 		       net_dev->name, skb->data, (int)skb->len, entry);
 
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 /**
diff --git a/drivers/net/skfp/skfddi.c b/drivers/net/skfp/skfddi.c
index 088fe26..0c31272 100644
--- a/drivers/net/skfp/skfddi.c
+++ b/drivers/net/skfp/skfddi.c
@@ -1091,7 +1091,7 @@ static int skfp_send_pkt(struct sk_buff *skb, struct net_device *dev)
 		netif_stop_queue(dev);
 	}
 	dev->trans_start = jiffies;
-	return 0;
+	return NETDEV_TX_OK;
 
 }				// skfp_send_pkt
 
diff --git a/drivers/net/slip.c b/drivers/net/slip.c
index 5c61d5f..899c4a2 100644
--- a/drivers/net/slip.c
+++ b/drivers/net/slip.c
@@ -484,12 +484,12 @@ sl_xmit(struct sk_buff *skb, struct net_device *dev)
 		spin_unlock(&sl->lock);
 		printk(KERN_WARNING "%s: xmit call when iface is down\n", dev->name);
 		dev_kfree_skb(skb);
-		return 0;
+		return NETDEV_TX_OK;
 	}
 	if (sl->tty == NULL) {
 		spin_unlock(&sl->lock);
 		dev_kfree_skb(skb);
-		return 0;
+		return NETDEV_TX_OK;
 	}
 
 	sl_lock(sl);
@@ -498,7 +498,7 @@ sl_xmit(struct sk_buff *skb, struct net_device *dev)
 	spin_unlock(&sl->lock);
 
 	dev_kfree_skb(skb);
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 
diff --git a/drivers/net/smc911x.c b/drivers/net/smc911x.c
index bc4976a..2a6b6de 100644
--- a/drivers/net/smc911x.c
+++ b/drivers/net/smc911x.c
@@ -553,7 +553,7 @@ static int smc911x_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		dev->stats.tx_dropped++;
 		spin_unlock_irqrestore(&lp->lock, flags);
 		dev_kfree_skb(skb);
-		return 0;
+		return NETDEV_TX_OK;
 	}
 
 #ifdef SMC_USE_DMA
@@ -566,7 +566,7 @@ static int smc911x_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 			lp->pending_tx_skb = skb;
 			netif_stop_queue(dev);
 			spin_unlock_irqrestore(&lp->lock, flags);
-			return 0;
+			return NETDEV_TX_OK;
 		} else {
 			DBG(SMC_DEBUG_TX | SMC_DEBUG_DMA, "%s: Activating Tx DMA\n", dev->name);
 			lp->txdma_active = 1;
@@ -577,7 +577,7 @@ static int smc911x_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	smc911x_hardware_send_pkt(dev);
 	spin_unlock_irqrestore(&lp->lock, flags);
 
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 /*
diff --git a/drivers/net/smc9194.c b/drivers/net/smc9194.c
index e02471b..0a1b6f4 100644
--- a/drivers/net/smc9194.c
+++ b/drivers/net/smc9194.c
@@ -512,7 +512,7 @@ static int smc_wait_to_send_packet( struct sk_buff * skb, struct net_device * de
 	if (length < ETH_ZLEN) {
 		if (skb_padto(skb, ETH_ZLEN)) {
 			netif_wake_queue(dev);
-			return 0;
+			return NETDEV_TX_OK;
 		}
 		length = ETH_ZLEN;
 	}
@@ -534,7 +534,7 @@ static int smc_wait_to_send_packet( struct sk_buff * skb, struct net_device * de
 		lp->saved_skb = NULL;
 		/* this IS an error, but, i don't want the skb saved */
 		netif_wake_queue(dev);
-		return 0;
+		return NETDEV_TX_OK;
 	}
 	/* either way, a packet is waiting now */
 	lp->packets_waiting++;
@@ -571,12 +571,12 @@ static int smc_wait_to_send_packet( struct sk_buff * skb, struct net_device * de
 		SMC_ENABLE_INT( IM_ALLOC_INT );
       		PRINTK2((CARDNAME": memory allocation deferred. \n"));
 		/* it's deferred, but I'll handle it later */
-      		return 0;
+      		return NETDEV_TX_OK;
    	}
 	/* or YES! I can send the packet now.. */
 	smc_hardware_send_packet(dev);
 	netif_wake_queue(dev);
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 /*
diff --git a/drivers/net/smc91x.c b/drivers/net/smc91x.c
index fdcbaf8..2968c75 100644
--- a/drivers/net/smc91x.c
+++ b/drivers/net/smc91x.c
@@ -655,7 +655,7 @@ static int smc_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		dev->stats.tx_errors++;
 		dev->stats.tx_dropped++;
 		dev_kfree_skb(skb);
-		return 0;
+		return NETDEV_TX_OK;
 	}
 
 	smc_special_lock(&lp->lock);
@@ -692,7 +692,7 @@ static int smc_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		smc_hardware_send_pkt((unsigned long)dev);
 	}
 
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 /*
diff --git a/drivers/net/starfire.c b/drivers/net/starfire.c
index 838cce8..1018349 100644
--- a/drivers/net/starfire.c
+++ b/drivers/net/starfire.c
@@ -1311,7 +1311,7 @@ static int start_tx(struct sk_buff *skb, struct net_device *dev)
 
 	dev->trans_start = jiffies;
 
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 
diff --git a/drivers/net/sun3_82586.c b/drivers/net/sun3_82586.c
index 7bb2742..2f1eaaf 100644
--- a/drivers/net/sun3_82586.c
+++ b/drivers/net/sun3_82586.c
@@ -1015,7 +1015,7 @@ static int sun3_82586_send_packet(struct sk_buff *skb, struct net_device *dev)
 	if(skb->len > XMIT_BUFF_SIZE)
 	{
 		printk("%s: Sorry, max. framelength is %d bytes. The length of your frame is %d bytes.\n",dev->name,XMIT_BUFF_SIZE,skb->len);
-		return 0;
+		return NETDEV_TX_OK;
 	}
 
 	netif_stop_queue(dev);
@@ -1110,7 +1110,7 @@ static int sun3_82586_send_packet(struct sk_buff *skb, struct net_device *dev)
 		dev_kfree_skb(skb);
 #endif
 	}
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 /*******************************************
diff --git a/drivers/net/sun3lance.c b/drivers/net/sun3lance.c
index 534dfe3..0ca4241 100644
--- a/drivers/net/sun3lance.c
+++ b/drivers/net/sun3lance.c
@@ -562,7 +562,7 @@ static int lance_start_xmit( struct sk_buff *skb, struct net_device *dev )
 		netif_start_queue(dev);
 		dev->trans_start = jiffies;
 
-		return 0;
+		return NETDEV_TX_OK;
 	}
 
 
@@ -648,7 +648,7 @@ static int lance_start_xmit( struct sk_buff *skb, struct net_device *dev )
 
 	local_irq_restore(flags);
 
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 /* The LANCE interrupt handler. */
diff --git a/drivers/net/sunbmac.c b/drivers/net/sunbmac.c
index 5017d7f..536cf7e 100644
--- a/drivers/net/sunbmac.c
+++ b/drivers/net/sunbmac.c
@@ -984,7 +984,7 @@ static int bigmac_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	dev->trans_start = jiffies;
 
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 static struct net_device_stats *bigmac_get_stats(struct net_device *dev)
diff --git a/drivers/net/sundance.c b/drivers/net/sundance.c
index 545f81b..0df6332 100644
--- a/drivers/net/sundance.c
+++ b/drivers/net/sundance.c
@@ -1091,7 +1091,7 @@ start_tx (struct sk_buff *skb, struct net_device *dev)
 			"%s: Transmit frame #%d queued in slot %d.\n",
 			dev->name, np->cur_tx, entry);
 	}
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 /* Reset hardware tx and free all of tx buffers */
diff --git a/drivers/net/sunhme.c b/drivers/net/sunhme.c
index 4ef7291..008bd59 100644
--- a/drivers/net/sunhme.c
+++ b/drivers/net/sunhme.c
@@ -2338,7 +2338,7 @@ static int happy_meal_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	dev->trans_start = jiffies;
 
 	tx_add_log(hp, TXLOG_ACTION_TXMIT, 0);
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 static struct net_device_stats *happy_meal_get_stats(struct net_device *dev)
diff --git a/drivers/net/sunlance.c b/drivers/net/sunlance.c
index afc7b35..9d6fd47 100644
--- a/drivers/net/sunlance.c
+++ b/drivers/net/sunlance.c
@@ -1163,7 +1163,7 @@ static int lance_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	dev->trans_start = jiffies;
 	dev_kfree_skb(skb);
 
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 /* taken from the depca driver */
diff --git a/drivers/net/sunqe.c b/drivers/net/sunqe.c
index c6ec61e..dcefb60 100644
--- a/drivers/net/sunqe.c
+++ b/drivers/net/sunqe.c
@@ -621,7 +621,7 @@ static int qe_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	dev_kfree_skb(skb);
 
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 static void qe_set_multicast(struct net_device *dev)
diff --git a/drivers/net/tc35815.c b/drivers/net/tc35815.c
index d737f6b..1ce2da1 100644
--- a/drivers/net/tc35815.c
+++ b/drivers/net/tc35815.c
@@ -1509,7 +1509,7 @@ static int tc35815_send_packet(struct sk_buff *skb, struct net_device *dev)
 	 */
 
 	spin_unlock_irqrestore(&lp->lock, flags);
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 #define FATAL_ERROR_INT \
diff --git a/drivers/net/tlan.c b/drivers/net/tlan.c
index 384cb5e..70c9ec4 100644
--- a/drivers/net/tlan.c
+++ b/drivers/net/tlan.c
@@ -1095,11 +1095,11 @@ static int TLan_StartTx( struct sk_buff *skb, struct net_device *dev )
 		TLAN_DBG( TLAN_DEBUG_TX, "TRANSMIT:  %s PHY is not ready\n",
 			  dev->name );
 		dev_kfree_skb_any(skb);
-		return 0;
+		return NETDEV_TX_OK;
 	}
 
 	if (skb_padto(skb, TLAN_MIN_FRAME_SIZE))
-		return 0;
+		return NETDEV_TX_OK;
 	txlen = max(skb->len, (unsigned int)TLAN_MIN_FRAME_SIZE);
 
 	tail_list = priv->txList + priv->txTail;
@@ -1150,7 +1150,7 @@ static int TLan_StartTx( struct sk_buff *skb, struct net_device *dev )
 	CIRC_INC( priv->txTail, TLAN_NUM_TX_LISTS );
 
 	dev->trans_start = jiffies;
-	return 0;
+	return NETDEV_TX_OK;
 
 } /* TLan_StartTx */
 
diff --git a/drivers/net/tokenring/3c359.c b/drivers/net/tokenring/3c359.c
index b40b6de..1787d52 100644
--- a/drivers/net/tokenring/3c359.c
+++ b/drivers/net/tokenring/3c359.c
@@ -1240,7 +1240,7 @@ static int xl_xmit(struct sk_buff *skb, struct net_device *dev)
 
 		spin_unlock_irqrestore(&xl_priv->xl_lock,flags) ; 
  
-		return 0;
+		return NETDEV_TX_OK;
 	} else {
 		spin_unlock_irqrestore(&xl_priv->xl_lock,flags) ; 
 		return NETDEV_TX_BUSY;
diff --git a/drivers/net/tokenring/ibmtr.c b/drivers/net/tokenring/ibmtr.c
index 9d89611..6472ba5 100644
--- a/drivers/net/tokenring/ibmtr.c
+++ b/drivers/net/tokenring/ibmtr.c
@@ -1041,7 +1041,7 @@ static int tok_send_packet(struct sk_buff *skb, struct net_device *dev)
 	writeb(CMD_IN_SRB, ti->mmio + ACA_OFFSET + ACA_SET + ISRA_ODD);
 	spin_unlock_irqrestore(&(ti->lock), flags);
 	dev->trans_start = jiffies;
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 /*****************************************************************************/
diff --git a/drivers/net/tokenring/lanstreamer.c b/drivers/net/tokenring/lanstreamer.c
index b3715ef..d07e61a 100644
--- a/drivers/net/tokenring/lanstreamer.c
+++ b/drivers/net/tokenring/lanstreamer.c
@@ -1183,7 +1183,7 @@ static int streamer_xmit(struct sk_buff *skb, struct net_device *dev)
 
 		streamer_priv->tx_ring_free = (streamer_priv->tx_ring_free + 1) & (STREAMER_TX_RING_SIZE - 1);
 		spin_unlock_irqrestore(&streamer_priv->streamer_lock,flags);
-		return 0;
+		return NETDEV_TX_OK;
 	} else {
 	        netif_stop_queue(dev);
 	        spin_unlock_irqrestore(&streamer_priv->streamer_lock,flags);
diff --git a/drivers/net/tokenring/olympic.c b/drivers/net/tokenring/olympic.c
index 451b541..f73f4e6 100644
--- a/drivers/net/tokenring/olympic.c
+++ b/drivers/net/tokenring/olympic.c
@@ -1052,7 +1052,7 @@ static int olympic_xmit(struct sk_buff *skb, struct net_device *dev)
 		writew((((readw(olympic_mmio+TXENQ_1)) & 0x8000) ^ 0x8000) | 1,olympic_mmio+TXENQ_1);
 		netif_wake_queue(dev);
 		spin_unlock_irqrestore(&olympic_priv->olympic_lock,flags);
-		return 0;
+		return NETDEV_TX_OK;
 	} else {
 		spin_unlock_irqrestore(&olympic_priv->olympic_lock,flags);
 		return NETDEV_TX_BUSY;
diff --git a/drivers/net/tulip/de2104x.c b/drivers/net/tulip/de2104x.c
index 81f054d..769af55 100644
--- a/drivers/net/tulip/de2104x.c
+++ b/drivers/net/tulip/de2104x.c
@@ -651,7 +651,7 @@ static int de_start_xmit (struct sk_buff *skb, struct net_device *dev)
 	dw32(TxPoll, NormalTxPoll);
 	dev->trans_start = jiffies;
 
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 /* Set or clear the multicast filter for this adaptor.
diff --git a/drivers/net/tulip/tulip_core.c b/drivers/net/tulip/tulip_core.c
index 2abb5d3..9d46638 100644
--- a/drivers/net/tulip/tulip_core.c
+++ b/drivers/net/tulip/tulip_core.c
@@ -690,7 +690,7 @@ tulip_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	dev->trans_start = jiffies;
 
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 static void tulip_clean_tx_ring(struct tulip_private *tp)
diff --git a/drivers/net/tulip/uli526x.c b/drivers/net/tulip/uli526x.c
index 9277ce8..9074a34 100644
--- a/drivers/net/tulip/uli526x.c
+++ b/drivers/net/tulip/uli526x.c
@@ -582,7 +582,7 @@ static int uli526x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (skb->len > MAX_PACKET_SIZE) {
 		printk(KERN_ERR DRV_NAME ": big packet = %d\n", (u16)skb->len);
 		dev_kfree_skb(skb);
-		return 0;
+		return NETDEV_TX_OK;
 	}
 
 	spin_lock_irqsave(&db->lock, flags);
@@ -624,7 +624,7 @@ static int uli526x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	/* free this SKB */
 	dev_kfree_skb(skb);
 
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 
diff --git a/drivers/net/tulip/winbond-840.c b/drivers/net/tulip/winbond-840.c
index 842b1a2..6bc7540 100644
--- a/drivers/net/tulip/winbond-840.c
+++ b/drivers/net/tulip/winbond-840.c
@@ -1058,7 +1058,7 @@ static int start_tx(struct sk_buff *skb, struct net_device *dev)
 		printk(KERN_DEBUG "%s: Transmit frame #%d queued in slot %d.\n",
 			   dev->name, np->cur_tx, entry);
 	}
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 static void netdev_tx_done(struct net_device *dev)
diff --git a/drivers/net/tulip/xircom_cb.c b/drivers/net/tulip/xircom_cb.c
index c2ca9f4..22b6a23 100644
--- a/drivers/net/tulip/xircom_cb.c
+++ b/drivers/net/tulip/xircom_cb.c
@@ -434,7 +434,7 @@ static int xircom_start_xmit(struct sk_buff *skb, struct net_device *dev)
 			card->transmit_used = nextdescriptor;
 			leave("xircom-start_xmit - sent");
 			spin_unlock_irqrestore(&card->lock,flags);
-			return 0;
+			return NETDEV_TX_OK;
 	}
 
 
diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 811d351..f8132fc 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -398,12 +398,12 @@ static int tun_net_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (tun->flags & TUN_FASYNC)
 		kill_fasync(&tun->fasync, SIGIO, POLL_IN);
 	wake_up_interruptible(&tun->socket.wait);
-	return 0;
+	return NETDEV_TX_OK;
 
 drop:
 	dev->stats.tx_dropped++;
 	kfree_skb(skb);
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 static void tun_net_mclist(struct net_device *dev)
diff --git a/drivers/net/typhoon.c b/drivers/net/typhoon.c
index cf25eb4..2c26b45 100644
--- a/drivers/net/typhoon.c
+++ b/drivers/net/typhoon.c
@@ -909,7 +909,7 @@ typhoon_start_tx(struct sk_buff *skb, struct net_device *dev)
 			netif_wake_queue(dev);
 	}
 
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 static void
diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index 255d28d..40be995 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -3165,7 +3165,7 @@ static int ucc_geth_start_xmit(struct sk_buff *skb, struct net_device *dev)
 #endif
 	spin_unlock_irq(&ugeth->lock);
 
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 static int ucc_geth_rx(struct ucc_geth_private *ugeth, u8 rxQ, int rx_work_limit)
diff --git a/drivers/net/usb/catc.c b/drivers/net/usb/catc.c
index b9dd425..7abdc4a 100644
--- a/drivers/net/usb/catc.c
+++ b/drivers/net/usb/catc.c
@@ -448,7 +448,7 @@ static int catc_start_xmit(struct sk_buff *skb, struct net_device *netdev)
 
 	dev_kfree_skb(skb);
 
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 static void catc_tx_timeout(struct net_device *netdev)
diff --git a/drivers/net/usb/hso.c b/drivers/net/usb/hso.c
index f8c6d7e..ffe4106 100644
--- a/drivers/net/usb/hso.c
+++ b/drivers/net/usb/hso.c
@@ -780,7 +780,7 @@ static int hso_net_start_xmit(struct sk_buff *skb, struct net_device *net)
 	netif_stop_queue(net);
 	if (hso_get_activity(odev->parent) == -EAGAIN) {
 		odev->skb_tx_buf = skb;
-		return 0;
+		return NETDEV_TX_OK;
 	}
 
 	/* log if asked */
diff --git a/drivers/net/usb/kaweth.c b/drivers/net/usb/kaweth.c
index e013147..09a5bd3 100644
--- a/drivers/net/usb/kaweth.c
+++ b/drivers/net/usb/kaweth.c
@@ -829,7 +829,7 @@ static int kaweth_start_xmit(struct sk_buff *skb, struct net_device *net)
 			kaweth->stats.tx_errors++;
 			netif_start_queue(net);
 			spin_unlock_irq(&kaweth->device_lock);
-			return 0;
+			return NETDEV_TX_OK;
 		}
 	}
 
@@ -864,7 +864,7 @@ skip:
 
 	spin_unlock_irq(&kaweth->device_lock);
 
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 /****************************************************************
diff --git a/drivers/net/usb/pegasus.c b/drivers/net/usb/pegasus.c
index 73acbd2..632d1ae 100644
--- a/drivers/net/usb/pegasus.c
+++ b/drivers/net/usb/pegasus.c
@@ -914,7 +914,7 @@ static int pegasus_start_xmit(struct sk_buff *skb, struct net_device *net)
 	}
 	dev_kfree_skb(skb);
 
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 static struct net_device_stats *pegasus_netdev_stats(struct net_device *dev)
diff --git a/drivers/net/usb/rtl8150.c b/drivers/net/usb/rtl8150.c
index fcc6fa0..bac8b77 100644
--- a/drivers/net/usb/rtl8150.c
+++ b/drivers/net/usb/rtl8150.c
@@ -753,7 +753,7 @@ static int rtl8150_start_xmit(struct sk_buff *skb, struct net_device *netdev)
 		netdev->trans_start = jiffies;
 	}
 
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 
diff --git a/drivers/net/veth.c b/drivers/net/veth.c
index 87197dd..e8a65d7 100644
--- a/drivers/net/veth.c
+++ b/drivers/net/veth.c
@@ -189,17 +189,17 @@ static int veth_xmit(struct sk_buff *skb, struct net_device *dev)
 	rcv_stats->rx_packets++;
 
 	netif_rx(skb);
-	return 0;
+	return NETDEV_TX_OK;
 
 tx_drop:
 	kfree_skb(skb);
 	stats->tx_dropped++;
-	return 0;
+	return NETDEV_TX_OK;
 
 rx_drop:
 	kfree_skb(skb);
 	rcv_stats->rx_dropped++;
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 /*
diff --git a/drivers/net/via-rhine.c b/drivers/net/via-rhine.c
index d3489a3..7152201 100644
--- a/drivers/net/via-rhine.c
+++ b/drivers/net/via-rhine.c
@@ -1225,7 +1225,7 @@ static int rhine_start_tx(struct sk_buff *skb, struct net_device *dev)
 	entry = rp->cur_tx % TX_RING_SIZE;
 
 	if (skb_padto(skb, ETH_ZLEN))
-		return 0;
+		return NETDEV_TX_OK;
 
 	rp->tx_skbuff[entry] = skb;
 
@@ -1237,7 +1237,7 @@ static int rhine_start_tx(struct sk_buff *skb, struct net_device *dev)
 			dev_kfree_skb(skb);
 			rp->tx_skbuff[entry] = NULL;
 			dev->stats.tx_dropped++;
-			return 0;
+			return NETDEV_TX_OK;
 		}
 
 		/* Padding is not copied and so must be redone. */
@@ -1285,7 +1285,7 @@ static int rhine_start_tx(struct sk_buff *skb, struct net_device *dev)
 		printk(KERN_DEBUG "%s: Transmit frame #%d queued in slot %d.\n",
 		       dev->name, rp->cur_tx-1, entry);
 	}
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 /* The interrupt handler does all of the Rx thread work and cleans up
diff --git a/drivers/net/via-velocity.c b/drivers/net/via-velocity.c
index 3ba3595..42365e5 100644
--- a/drivers/net/via-velocity.c
+++ b/drivers/net/via-velocity.c
@@ -2098,7 +2098,7 @@ static int velocity_xmit(struct sk_buff *skb, struct net_device *dev)
 #ifdef VELOCITY_ZERO_COPY_SUPPORT
 	if (skb_shinfo(skb)->nr_frags > 6 && __skb_linearize(skb)) {
 		kfree_skb(skb);
-		return 0;
+		return NETDEV_TX_OK;
 	}
 #endif
 
diff --git a/drivers/net/vxge/vxge-main.c b/drivers/net/vxge/vxge-main.c
index 6034497..fd0ebf7 100644
--- a/drivers/net/vxge/vxge-main.c
+++ b/drivers/net/vxge/vxge-main.c
@@ -1000,7 +1000,7 @@ vxge_xmit(struct sk_buff *skb, struct net_device *dev)
 	VXGE_COMPLETE_VPATH_TX(fifo);
 	vxge_debug_entryexit(VXGE_TRACE, "%s: %s:%d  Exiting...",
 		dev->name, __func__, __LINE__);
-	return 0;
+	return NETDEV_TX_OK;
 
 _exit0:
 	vxge_debug_tx(VXGE_TRACE, "%s: pci_map_page failed", dev->name);
@@ -1024,7 +1024,7 @@ _exit2:
 	spin_unlock_irqrestore(&fifo->tx_lock, flags);
 	VXGE_COMPLETE_VPATH_TX(fifo);
 
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 /*
diff --git a/drivers/net/wan/cycx_x25.c b/drivers/net/wan/cycx_x25.c
index f525f9f..4ae9bd2 100644
--- a/drivers/net/wan/cycx_x25.c
+++ b/drivers/net/wan/cycx_x25.c
@@ -663,7 +663,7 @@ static int cycx_netdevice_hard_start_xmit(struct sk_buff *skb,
 free_packet:
 	dev_kfree_skb(skb);
 
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 /* Get Ethernet-style interface statistics.
diff --git a/drivers/net/wan/hdlc_fr.c b/drivers/net/wan/hdlc_fr.c
index bfa0161..52438c7 100644
--- a/drivers/net/wan/hdlc_fr.c
+++ b/drivers/net/wan/hdlc_fr.c
@@ -421,7 +421,7 @@ static int pvc_xmit(struct sk_buff *skb, struct net_device *dev)
 							     GFP_ATOMIC)) {
 						dev->stats.tx_dropped++;
 						dev_kfree_skb(skb);
-						return 0;
+						return NETDEV_TX_OK;
 					}
 				skb_put(skb, pad);
 				memset(skb->data + len, 0, pad);
@@ -435,13 +435,13 @@ static int pvc_xmit(struct sk_buff *skb, struct net_device *dev)
 				dev->stats.tx_compressed++;
 			skb->dev = pvc->frad;
 			dev_queue_xmit(skb);
-			return 0;
+			return NETDEV_TX_OK;
 		}
 	}
 
 	dev->stats.tx_dropped++;
 	dev_kfree_skb(skb);
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 static inline void fr_log_dlci_active(pvc_device *pvc)
diff --git a/drivers/net/wan/sbni.c b/drivers/net/wan/sbni.c
index 3fb9dbc..545178e 100644
--- a/drivers/net/wan/sbni.c
+++ b/drivers/net/wan/sbni.c
@@ -465,7 +465,7 @@ sbni_start_xmit( struct sk_buff  *skb,  struct net_device  *dev )
 			prepare_to_send( skb, p );
 			spin_unlock( &nl->lock );
 			netif_start_queue( dev );
-			return  0;
+			return NETDEV_TX_OK;
 		}
 	}
 
@@ -485,7 +485,7 @@ sbni_start_xmit( struct sk_buff  *skb,  struct net_device  *dev )
 	prepare_to_send( skb, dev );
 
 	spin_unlock( &nl->lock );
-	return  0;
+	return NETDEV_TX_OK;
 }
 
 #endif	/* CONFIG_SBNI_MULTILINE */
diff --git a/drivers/net/wan/x25_asy.c b/drivers/net/wan/x25_asy.c
index d67e208..1047920 100644
--- a/drivers/net/wan/x25_asy.c
+++ b/drivers/net/wan/x25_asy.c
@@ -308,7 +308,7 @@ static int x25_asy_xmit(struct sk_buff *skb, struct net_device *dev)
 		printk(KERN_ERR "%s: xmit call when iface is down\n",
 			dev->name);
 		kfree_skb(skb);
-		return 0;
+		return NETDEV_TX_OK;
 	}
 
 	switch (skb->data[0]) {
@@ -319,14 +319,14 @@ static int x25_asy_xmit(struct sk_buff *skb, struct net_device *dev)
 		if (err != LAPB_OK)
 			printk(KERN_ERR "x25_asy: lapb_connect_request error - %d\n", err);
 		kfree_skb(skb);
-		return 0;
+		return NETDEV_TX_OK;
 	case 0x02: /* Disconnect request .. do nothing - hang up ?? */
 		err = lapb_disconnect_request(dev);
 		if (err != LAPB_OK)
 			printk(KERN_ERR "x25_asy: lapb_disconnect_request error - %d\n", err);
 	default:
 		kfree_skb(skb);
-		return  0;
+		return NETDEV_TX_OK;
 	}
 	skb_pull(skb, 1);	/* Remove control byte */
 	/*
@@ -344,9 +344,9 @@ static int x25_asy_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (err != LAPB_OK) {
 		printk(KERN_ERR "x25_asy: lapb_data_request error - %d\n", err);
 		kfree_skb(skb);
-		return 0;
+		return NETDEV_TX_OK;
 	}
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 
diff --git a/drivers/net/wireless/airo.c b/drivers/net/wireless/airo.c
index c70604f..49f3139 100644
--- a/drivers/net/wireless/airo.c
+++ b/drivers/net/wireless/airo.c
@@ -1927,7 +1927,7 @@ static int mpi_start_xmit(struct sk_buff *skb, struct net_device *dev) {
 
 	if (!skb) {
 		airo_print_err(dev->name, "%s: skb == NULL!",__func__);
-		return 0;
+		return NETDEV_TX_OK;
 	}
 	npacks = skb_queue_len (&ai->txq);
 
@@ -1938,7 +1938,7 @@ static int mpi_start_xmit(struct sk_buff *skb, struct net_device *dev) {
 			return NETDEV_TX_BUSY;
 		}
 		skb_queue_tail (&ai->txq, skb);
-		return 0;
+		return NETDEV_TX_OK;
 	}
 
 	spin_lock_irqsave(&ai->aux_lock, flags);
@@ -1951,7 +1951,7 @@ static int mpi_start_xmit(struct sk_buff *skb, struct net_device *dev) {
 		set_bit(FLAG_PENDING_XMIT, &ai->flags);
 		mpi_send_packet (dev);
 	}
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 /*
@@ -2127,7 +2127,7 @@ static int airo_start_xmit(struct sk_buff *skb, struct net_device *dev) {
 
 	if ( skb == NULL ) {
 		airo_print_err(dev->name, "%s: skb == NULL!", __func__);
-		return 0;
+		return NETDEV_TX_OK;
 	}
 
 	/* Find a vacant FID */
@@ -2155,7 +2155,7 @@ static int airo_start_xmit(struct sk_buff *skb, struct net_device *dev) {
 		wake_up_interruptible(&priv->thr_wait);
 	} else
 		airo_end_xmit(dev);
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 static void airo_end_xmit11(struct net_device *dev) {
@@ -2199,7 +2199,7 @@ static int airo_start_xmit11(struct sk_buff *skb, struct net_device *dev) {
 
 	if ( skb == NULL ) {
 		airo_print_err(dev->name, "%s: skb == NULL!", __func__);
-		return 0;
+		return NETDEV_TX_OK;
 	}
 
 	/* Find a vacant FID */
@@ -2227,7 +2227,7 @@ static int airo_start_xmit11(struct sk_buff *skb, struct net_device *dev) {
 		wake_up_interruptible(&priv->thr_wait);
 	} else
 		airo_end_xmit11(dev);
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 static void airo_read_stats(struct net_device *dev)
diff --git a/drivers/net/wireless/arlan-main.c b/drivers/net/wireless/arlan-main.c
index d84caf1..d479f47 100644
--- a/drivers/net/wireless/arlan-main.c
+++ b/drivers/net/wireless/arlan-main.c
@@ -1193,7 +1193,7 @@ static int arlan_tx(struct sk_buff *skb, struct net_device *dev)
 
 	arlan_process_interrupt(dev);
 	ARLAN_DEBUG_EXIT("arlan_tx");
-	return 0;
+	return NETDEV_TX_OK;
 
 bad_end:
 	arlan_process_interrupt(dev);
diff --git a/drivers/net/wireless/atmel.c b/drivers/net/wireless/atmel.c
index 291a94b..05813bc 100644
--- a/drivers/net/wireless/atmel.c
+++ b/drivers/net/wireless/atmel.c
@@ -793,13 +793,13 @@ static int start_tx(struct sk_buff *skb, struct net_device *dev)
 	    !(*priv->present_callback)(priv->card)) {
 		dev->stats.tx_errors++;
 		dev_kfree_skb(skb);
-		return 0;
+		return NETDEV_TX_OK;
 	}
 
 	if (priv->station_state != STATION_STATE_READY) {
 		dev->stats.tx_errors++;
 		dev_kfree_skb(skb);
-		return 0;
+		return NETDEV_TX_OK;
 	}
 
 	/* first ensure the timer func cannot run */
@@ -856,7 +856,7 @@ static int start_tx(struct sk_buff *skb, struct net_device *dev)
 	spin_unlock_bh(&priv->timerlock);
 	dev_kfree_skb(skb);
 
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 static void atmel_transmit_management_frame(struct atmel_private *priv,
diff --git a/drivers/net/wireless/mac80211_hwsim.c b/drivers/net/wireless/mac80211_hwsim.c
index e789c6e..55f77ad 100644
--- a/drivers/net/wireless/mac80211_hwsim.c
+++ b/drivers/net/wireless/mac80211_hwsim.c
@@ -314,7 +314,7 @@ static int hwsim_mon_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	/* TODO: allow packet injection */
 	dev_kfree_skb(skb);
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 
diff --git a/drivers/net/wireless/netwave_cs.c b/drivers/net/wireless/netwave_cs.c
index d63c899..712f26e 100644
--- a/drivers/net/wireless/netwave_cs.c
+++ b/drivers/net/wireless/netwave_cs.c
@@ -1047,7 +1047,7 @@ static int netwave_start_xmit(struct sk_buff *skb, struct net_device *dev) {
     }
     dev_kfree_skb(skb);
     
-    return 0;
+    return NETDEV_TX_OK;
 } /* netwave_start_xmit */
 
 /*
diff --git a/drivers/net/wireless/ray_cs.c b/drivers/net/wireless/ray_cs.c
index b10b038..64e574c 100644
--- a/drivers/net/wireless/ray_cs.c
+++ b/drivers/net/wireless/ray_cs.c
@@ -937,7 +937,7 @@ static int ray_dev_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	if (length < ETH_ZLEN) {
 		if (skb_padto(skb, ETH_ZLEN))
-			return 0;
+			return NETDEV_TX_OK;
 		length = ETH_ZLEN;
 	}
 	switch (ray_hw_xmit(skb->data, length, dev, DATA_TYPE)) {
@@ -951,9 +951,9 @@ static int ray_dev_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	default:
 		dev->trans_start = jiffies;
 		dev_kfree_skb(skb);
-		return 0;
+		return NETDEV_TX_OK;
 	}
-	return 0;
+	return NETDEV_TX_OK;
 } /* ray_dev_start_xmit */
 
 /*===========================================================================*/
diff --git a/drivers/net/wireless/strip.c b/drivers/net/wireless/strip.c
index 38366a5..73300c2 100644
--- a/drivers/net/wireless/strip.c
+++ b/drivers/net/wireless/strip.c
@@ -1582,7 +1582,7 @@ static int strip_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	if (skb)
 		dev_kfree_skb(skb);
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 /*
diff --git a/drivers/net/wireless/zd1201.c b/drivers/net/wireless/zd1201.c
index 4430b8d..dae1bfb 100644
--- a/drivers/net/wireless/zd1201.c
+++ b/drivers/net/wireless/zd1201.c
@@ -789,7 +789,7 @@ static int zd1201_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (!zd->mac_enabled || zd->monitor) {
 		dev->stats.tx_dropped++;
 		kfree_skb(skb);
-		return 0;
+		return NETDEV_TX_OK;
 	}
 	netif_stop_queue(dev);
 
@@ -826,7 +826,7 @@ static int zd1201_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	}
 	kfree_skb(skb);
 
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 static void zd1201_tx_timeout(struct net_device *dev)
diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index f673253..f14f1f7 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -558,12 +558,12 @@ static int xennet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	spin_unlock_irq(&np->tx_lock);
 
-	return 0;
+	return NETDEV_TX_OK;
 
  drop:
 	dev->stats.tx_dropped++;
 	dev_kfree_skb(skb);
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 static int xennet_close(struct net_device *dev)
diff --git a/drivers/net/yellowfin.c b/drivers/net/yellowfin.c
index 3c7a505..c3722b4 100644
--- a/drivers/net/yellowfin.c
+++ b/drivers/net/yellowfin.c
@@ -827,7 +827,7 @@ static int yellowfin_start_xmit(struct sk_buff *skb, struct net_device *dev)
 			if (skb_padto(skb, len)) {
 				yp->tx_skbuff[entry] = NULL;
 				netif_wake_queue(dev);
-				return 0;
+				return NETDEV_TX_OK;
 			}
 		}
 	}
@@ -881,7 +881,7 @@ static int yellowfin_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		printk(KERN_DEBUG "%s: Yellowfin transmit frame #%d queued in slot %d.\n",
 			   dev->name, yp->cur_tx, entry);
 	}
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 /* The interrupt handler does all of the Rx thread work and cleans up
diff --git a/drivers/net/znet.c b/drivers/net/znet.c
index 0a6992d..7f9e141 100644
--- a/drivers/net/znet.c
+++ b/drivers/net/znet.c
@@ -546,7 +546,7 @@ static int znet_send_packet(struct sk_buff *skb, struct net_device *dev)
 
 	if (length < ETH_ZLEN) {
 		if (skb_padto(skb, ETH_ZLEN))
-			return 0;
+			return NETDEV_TX_OK;
 		length = ETH_ZLEN;
 	}
 
@@ -600,7 +600,7 @@ static int znet_send_packet(struct sk_buff *skb, struct net_device *dev)
 		  printk(KERN_DEBUG "%s: Transmitter queued, length %d.\n", dev->name, length);
 	}
 	dev_kfree_skb(skb);
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 /* The ZNET interrupt handler. */
diff --git a/drivers/s390/net/ctcm_main.c b/drivers/s390/net/ctcm_main.c
index 54c4649..31d7d74 100644
--- a/drivers/s390/net/ctcm_main.c
+++ b/drivers/s390/net/ctcm_main.c
@@ -880,7 +880,7 @@ static int ctcm_tx(struct sk_buff *skb, struct net_device *dev)
 				"%s(%s): NULL sk_buff passed",
 					CTCM_FUNTAIL, dev->name);
 		priv->stats.tx_dropped++;
-		return 0;
+		return NETDEV_TX_OK;
 	}
 	if (skb_headroom(skb) < (LL_HEADER_LENGTH + 2)) {
 		CTCM_DBF_TEXT_(ERROR, CTC_DBF_ERROR,
@@ -888,7 +888,7 @@ static int ctcm_tx(struct sk_buff *skb, struct net_device *dev)
 			CTCM_FUNTAIL, dev->name, LL_HEADER_LENGTH + 2);
 		dev_kfree_skb(skb);
 		priv->stats.tx_dropped++;
-		return 0;
+		return NETDEV_TX_OK;
 	}
 
 	/*
@@ -901,7 +901,7 @@ static int ctcm_tx(struct sk_buff *skb, struct net_device *dev)
 		priv->stats.tx_dropped++;
 		priv->stats.tx_errors++;
 		priv->stats.tx_carrier_errors++;
-		return 0;
+		return NETDEV_TX_OK;
 	}
 
 	if (ctcm_test_and_set_busy(dev))
@@ -910,7 +910,7 @@ static int ctcm_tx(struct sk_buff *skb, struct net_device *dev)
 	dev->trans_start = jiffies;
 	if (ctcm_transmit_skb(priv->channel[WRITE], skb) != 0)
 		return NETDEV_TX_BUSY;
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 /* unmerged MPC variant of ctcm_tx */
@@ -1008,7 +1008,7 @@ done:
 	if (do_debug)
 		MPC_DBF_DEV_NAME(TRACE, dev, "exit");
 
-	return 0;	/* handle freeing of skb here */
+	return NETDEV_TX_OK;	/* handle freeing of skb here */
 }
 
 
diff --git a/drivers/staging/at76_usb/at76_usb.c b/drivers/staging/at76_usb/at76_usb.c
index 3f303ae..7b8aa5e 100644
--- a/drivers/staging/at76_usb/at76_usb.c
+++ b/drivers/staging/at76_usb/at76_usb.c
@@ -3134,7 +3134,7 @@ static int at76_tx(struct sk_buff *skb, struct net_device *netdev)
 		       netdev->name, __func__);
 		/* skip this packet */
 		dev_kfree_skb(skb);
-		return 0;
+		return NETDEV_TX_OK;
 	}
 
 	if (priv->tx_urb->status == -EINPROGRESS) {
@@ -3142,14 +3142,14 @@ static int at76_tx(struct sk_buff *skb, struct net_device *netdev)
 		       netdev->name, __func__);
 		/* skip this packet */
 		dev_kfree_skb(skb);
-		return 0;
+		return NETDEV_TX_OK;
 	}
 
 	if (skb->len < ETH_HLEN) {
 		printk(KERN_ERR "%s: %s: skb too short (%d)\n",
 		       netdev->name, __func__, skb->len);
 		dev_kfree_skb(skb);
-		return 0;
+		return NETDEV_TX_OK;
 	}
 
 	at76_ledtrig_tx_activity();	/* tell ledtrigger we send a packet */
@@ -3173,7 +3173,7 @@ static int at76_tx(struct sk_buff *skb, struct net_device *netdev)
 			       skb->data[ETH_HLEN + 1],
 			       skb->data[ETH_HLEN + 2]);
 			dev_kfree_skb(skb);
-			return 0;
+			return NETDEV_TX_OK;
 		}
 	} else {
 		/* add RFC 1042 header in front */
diff --git a/drivers/staging/epl/VirtualEthernetLinux.c b/drivers/staging/epl/VirtualEthernetLinux.c
index 077724a..7b7cce1 100644
--- a/drivers/staging/epl/VirtualEthernetLinux.c
+++ b/drivers/staging/epl/VirtualEthernetLinux.c
@@ -223,7 +223,7 @@ static int VEthXmit(struct sk_buff *pSkb_p, struct net_device *pNetDevice_p)
 	}
 
       Exit:
-	return 0;
+	return NETDEV_TX_OK;
 
 }
 
diff --git a/drivers/staging/otus/usbdrv.c b/drivers/staging/otus/usbdrv.c
index 540cbbb..7cd87ca 100644
--- a/drivers/staging/otus/usbdrv.c
+++ b/drivers/staging/otus/usbdrv.c
@@ -659,7 +659,7 @@ int usbdrv_xmit_frame(struct sk_buff *skb, struct net_device *dev)
         netif_stop_queue(dev);
     }
 
-    return 0;
+    return NETDEV_TX_OK;
 }
 
 
@@ -796,13 +796,13 @@ int zfLnxVapXmitFrame(struct sk_buff *skb, struct net_device *dev)
     if (vapId >= ZM_VAP_PORT_NUMBER)
     {
         dev_kfree_skb_irq(skb);
-        return 0;
+        return NETDEV_TX_OK;
     }
 #if 1
     if (vap[vapId].openFlag == 0)
     {
         dev_kfree_skb_irq(skb);
-        return 0;
+        return NETDEV_TX_OK;
     }
 #endif
 
@@ -819,7 +819,7 @@ int zfLnxVapXmitFrame(struct sk_buff *skb, struct net_device *dev)
         netif_stop_queue(dev);
     }
 
-    return 0;
+    return NETDEV_TX_OK;
 }
 
 static const struct net_device_ops vap_netdev_ops = {
diff --git a/drivers/staging/slicoss/slicoss.c b/drivers/staging/slicoss/slicoss.c
index 6f5d0bf..dbe8020 100644
--- a/drivers/staging/slicoss/slicoss.c
+++ b/drivers/staging/slicoss/slicoss.c
@@ -845,7 +845,7 @@ static int slic_xmit_start(struct sk_buff *skb, struct net_device *dev)
 				 hcmd->paddrh, DONT_FLUSH);
 	}
 xmit_done:
-	return 0;
+	return NETDEV_TX_OK;
 xmit_fail:
 	slic_xmit_fail(adapter, skb, offloadcmd, skbtype, status);
 	goto xmit_done;
diff --git a/drivers/usb/gadget/f_phonet.c b/drivers/usb/gadget/f_phonet.c
index 96fb118..d17f108 100644
--- a/drivers/usb/gadget/f_phonet.c
+++ b/drivers/usb/gadget/f_phonet.c
@@ -256,7 +256,7 @@ out:
 		dev_kfree_skb(skb);
 		dev->stats.tx_dropped++;
 	}
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 static int pn_net_mtu(struct net_device *dev, int new_mtu)
diff --git a/drivers/usb/gadget/u_ether.c b/drivers/usb/gadget/u_ether.c
index 016f63b..aac69b5 100644
--- a/drivers/usb/gadget/u_ether.c
+++ b/drivers/usb/gadget/u_ether.c
@@ -487,7 +487,7 @@ static int eth_start_xmit(struct sk_buff *skb, struct net_device *net)
 
 	if (!in) {
 		dev_kfree_skb_any(skb);
-		return 0;
+		return NETDEV_TX_OK;
 	}
 
 	/* apply outgoing CDC or RNDIS filters */
@@ -506,7 +506,7 @@ static int eth_start_xmit(struct sk_buff *skb, struct net_device *net)
 				type = USB_CDC_PACKET_TYPE_ALL_MULTICAST;
 			if (!(cdc_filter & type)) {
 				dev_kfree_skb_any(skb);
-				return 0;
+				return NETDEV_TX_OK;
 			}
 		}
 		/* ignores USB_CDC_PACKET_TYPE_DIRECTED */
@@ -586,7 +586,7 @@ drop:
 		list_add(&req->list, &dev->tx_reqs);
 		spin_unlock_irqrestore(&dev->req_lock, flags);
 	}
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 /*-------------------------------------------------------------------------*/
diff --git a/net/atm/br2684.c b/net/atm/br2684.c
index 2912665..848af11 100644
--- a/net/atm/br2684.c
+++ b/net/atm/br2684.c
@@ -238,7 +238,7 @@ static int br2684_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		/* netif_stop_queue(dev); */
 		dev_kfree_skb(skb);
 		read_unlock(&devs_lock);
-		return 0;
+		return NETDEV_TX_OK;
 	}
 	if (!br2684_xmit_vcc(skb, dev, brvcc)) {
 		/*
@@ -252,7 +252,7 @@ static int br2684_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		dev->stats.tx_fifo_errors++;
 	}
 	read_unlock(&devs_lock);
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 /*
diff --git a/net/atm/clip.c b/net/atm/clip.c
index e65a3b1..64910bb 100644
--- a/net/atm/clip.c
+++ b/net/atm/clip.c
@@ -373,7 +373,7 @@ static int clip_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		printk(KERN_ERR "clip_start_xmit: skb_dst(skb) == NULL\n");
 		dev_kfree_skb(skb);
 		dev->stats.tx_dropped++;
-		return 0;
+		return NETDEV_TX_OK;
 	}
 	if (!skb_dst(skb)->neighbour) {
 #if 0
@@ -387,7 +387,7 @@ static int clip_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		printk(KERN_ERR "clip_start_xmit: NO NEIGHBOUR !\n");
 		dev_kfree_skb(skb);
 		dev->stats.tx_dropped++;
-		return 0;
+		return NETDEV_TX_OK;
 	}
 	entry = NEIGH2ENTRY(skb_dst(skb)->neighbour);
 	if (!entry->vccs) {
@@ -402,7 +402,7 @@ static int clip_start_xmit(struct sk_buff *skb, struct net_device *dev)
 			dev_kfree_skb(skb);
 			dev->stats.tx_dropped++;
 		}
-		return 0;
+		return NETDEV_TX_OK;
 	}
 	pr_debug("neigh %p, vccs %p\n", entry, entry->vccs);
 	ATM_SKB(skb)->vcc = vcc = entry->vccs->vcc;
@@ -421,14 +421,14 @@ static int clip_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	old = xchg(&entry->vccs->xoff, 1);	/* assume XOFF ... */
 	if (old) {
 		printk(KERN_WARNING "clip_start_xmit: XOFF->XOFF transition\n");
-		return 0;
+		return NETDEV_TX_OK;
 	}
 	dev->stats.tx_packets++;
 	dev->stats.tx_bytes += skb->len;
 	vcc->send(vcc, skb);
 	if (atm_may_send(vcc, 0)) {
 		entry->vccs->xoff = 0;
-		return 0;
+		return NETDEV_TX_OK;
 	}
 	spin_lock_irqsave(&clip_priv->xoff_lock, flags);
 	netif_stop_queue(dev);	/* XOFF -> throttle immediately */
@@ -440,7 +440,7 @@ static int clip_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	   of the brief netif_stop_queue. If this isn't true or if it
 	   changes, use netif_wake_queue instead. */
 	spin_unlock_irqrestore(&clip_priv->xoff_lock, flags);
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 static int clip_mkip(struct atm_vcc *vcc, int timeout)
diff --git a/net/atm/lec.c b/net/atm/lec.c
index ff2e594..c463868 100644
--- a/net/atm/lec.c
+++ b/net/atm/lec.c
@@ -289,7 +289,7 @@ static int lec_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		skb2 = skb_realloc_headroom(skb, LEC_HEADER_LEN);
 		kfree_skb(skb);
 		if (skb2 == NULL)
-			return 0;
+			return NETDEV_TX_OK;
 		skb = skb2;
 	}
 	skb_push(skb, 2);
@@ -307,7 +307,7 @@ static int lec_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		skb2 = skb_realloc_headroom(skb, LEC_HEADER_LEN);
 		kfree_skb(skb);
 		if (skb2 == NULL)
-			return 0;
+			return NETDEV_TX_OK;
 		skb = skb2;
 	}
 #endif
@@ -345,7 +345,7 @@ static int lec_start_xmit(struct sk_buff *skb, struct net_device *dev)
 			dev_kfree_skb(skb);
 			if (skb2 == NULL) {
 				dev->stats.tx_dropped++;
-				return 0;
+				return NETDEV_TX_OK;
 			}
 			skb = skb2;
 		}
@@ -416,7 +416,7 @@ out:
 	if (entry)
 		lec_arp_put(entry);
 	dev->trans_start = jiffies;
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 /* The inverse routine to net_open(). */
diff --git a/net/bluetooth/bnep/netdev.c b/net/bluetooth/bnep/netdev.c
index d7a0e97..9c42990 100644
--- a/net/bluetooth/bnep/netdev.c
+++ b/net/bluetooth/bnep/netdev.c
@@ -175,14 +175,14 @@ static int bnep_net_xmit(struct sk_buff *skb, struct net_device *dev)
 #ifdef CONFIG_BT_BNEP_MC_FILTER
 	if (bnep_net_mc_filter(skb, s)) {
 		kfree_skb(skb);
-		return 0;
+		return NETDEV_TX_OK;
 	}
 #endif
 
 #ifdef CONFIG_BT_BNEP_PROTO_FILTER
 	if (bnep_net_proto_filter(skb, s)) {
 		kfree_skb(skb);
-		return 0;
+		return NETDEV_TX_OK;
 	}
 #endif
 
@@ -203,7 +203,7 @@ static int bnep_net_xmit(struct sk_buff *skb, struct net_device *dev)
 		netif_stop_queue(dev);
 	}
 
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 static const struct net_device_ops bnep_netdev_ops = {
diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index 18538d7..15d43ba 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -39,7 +39,7 @@ int br_dev_xmit(struct sk_buff *skb, struct net_device *dev)
 	else
 		br_flood_deliver(br, skb);
 
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 static int br_dev_open(struct net_device *dev)
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 44e2a3d..cd85ebc 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -821,7 +821,7 @@ static int ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 			stats->tx_dropped++;
 			dev_kfree_skb(skb);
 			tunnel->recursion--;
-			return 0;
+			return NETDEV_TX_OK;
 		}
 		if (skb->sk)
 			skb_set_owner_w(new_skb, skb->sk);
@@ -889,7 +889,7 @@ static int ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	IPTUNNEL_XMIT();
 	tunnel->recursion--;
-	return 0;
+	return NETDEV_TX_OK;
 
 tx_error_icmp:
 	dst_link_failure(skb);
@@ -898,7 +898,7 @@ tx_error:
 	stats->tx_errors++;
 	dev_kfree_skb(skb);
 	tunnel->recursion--;
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 static int ipgre_tunnel_bind_dev(struct net_device *dev)
diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index 93e2b78..98075b6 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -486,7 +486,7 @@ static int ipip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 			stats->tx_dropped++;
 			dev_kfree_skb(skb);
 			tunnel->recursion--;
-			return 0;
+			return NETDEV_TX_OK;
 		}
 		if (skb->sk)
 			skb_set_owner_w(new_skb, skb->sk);
@@ -524,7 +524,7 @@ static int ipip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	IPTUNNEL_XMIT();
 	tunnel->recursion--;
-	return 0;
+	return NETDEV_TX_OK;
 
 tx_error_icmp:
 	dst_link_failure(skb);
@@ -532,7 +532,7 @@ tx_error:
 	stats->tx_errors++;
 	dev_kfree_skb(skb);
 	tunnel->recursion--;
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 static void ipip_tunnel_bind_dev(struct net_device *dev)
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 9a8da5e..06c33fb 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -212,7 +212,7 @@ static int reg_vif_xmit(struct sk_buff *skb, struct net_device *dev)
 			  IGMPMSG_WHOLEPKT);
 	read_unlock(&mrt_lock);
 	kfree_skb(skb);
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 static const struct net_device_ops reg_vif_netdev_ops = {
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 404d16a..e7f7987 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -1063,14 +1063,14 @@ ip6_tnl_xmit(struct sk_buff *skb, struct net_device *dev)
 		goto tx_err;
 
 	t->recursion--;
-	return 0;
+	return NETDEV_TX_OK;
 
 tx_err:
 	stats->tx_errors++;
 	stats->tx_dropped++;
 	kfree_skb(skb);
 	t->recursion--;
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 static void ip6_tnl_set_cap(struct ip6_tnl *t)
diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index c769f15..07ded50 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -427,7 +427,7 @@ static int reg_vif_xmit(struct sk_buff *skb, struct net_device *dev)
 			   MRT6MSG_WHOLEPKT);
 	read_unlock(&mrt_lock);
 	kfree_skb(skb);
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 static const struct net_device_ops reg_vif_netdev_ops = {
diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 68e5230..d0b8505 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -753,7 +753,7 @@ static int ipip6_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 			stats->tx_dropped++;
 			dev_kfree_skb(skb);
 			tunnel->recursion--;
-			return 0;
+			return NETDEV_TX_OK;
 		}
 		if (skb->sk)
 			skb_set_owner_w(new_skb, skb->sk);
@@ -794,7 +794,7 @@ static int ipip6_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	IPTUNNEL_XMIT();
 	tunnel->recursion--;
-	return 0;
+	return NETDEV_TX_OK;
 
 tx_error_icmp:
 	dst_link_failure(skb);
@@ -802,7 +802,7 @@ tx_error:
 	stats->tx_errors++;
 	dev_kfree_skb(skb);
 	tunnel->recursion--;
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 static void ipip6_tunnel_bind_dev(struct net_device *dev)
diff --git a/net/irda/irlan/irlan_eth.c b/net/irda/irlan/irlan_eth.c
index 724bcf9..64230cf 100644
--- a/net/irda/irlan/irlan_eth.c
+++ b/net/irda/irlan/irlan_eth.c
@@ -177,7 +177,7 @@ static int irlan_eth_xmit(struct sk_buff *skb, struct net_device *dev)
 
 		/* Did the realloc succeed? */
 		if (new_skb == NULL)
-			return 0;
+			return NETDEV_TX_OK;
 
 		/* Use the new skb instead */
 		skb = new_skb;
@@ -209,7 +209,7 @@ static int irlan_eth_xmit(struct sk_buff *skb, struct net_device *dev)
 		self->stats.tx_bytes += skb->len;
 	}
 
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 /*
diff --git a/net/netrom/nr_dev.c b/net/netrom/nr_dev.c
index 3513724..c7b7838 100644
--- a/net/netrom/nr_dev.c
+++ b/net/netrom/nr_dev.c
@@ -177,13 +177,13 @@ static int nr_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (!nr_route_frame(skb, NULL)) {
 		kfree_skb(skb);
 		stats->tx_errors++;
-		return 0;
+		return NETDEV_TX_OK;
 	}
 
 	stats->tx_packets++;
 	stats->tx_bytes += len;
 
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 static const struct header_ops nr_header_ops = {
diff --git a/net/phonet/pep-gprs.c b/net/phonet/pep-gprs.c
index 480839d..4667af5 100644
--- a/net/phonet/pep-gprs.c
+++ b/net/phonet/pep-gprs.c
@@ -195,7 +195,7 @@ static int gprs_xmit(struct sk_buff *skb, struct net_device *dev)
 		break;
 	default:
 		dev_kfree_skb(skb);
-		return 0;
+		return NETDEV_TX_OK;
 	}
 
 	skb_orphan(skb);
@@ -215,7 +215,7 @@ static int gprs_xmit(struct sk_buff *skb, struct net_device *dev)
 	netif_stop_queue(dev);
 	if (pep_writeable(sk))
 		netif_wake_queue(dev);
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 static int gprs_set_mtu(struct net_device *dev, int new_mtu)
diff --git a/net/rose/rose_dev.c b/net/rose/rose_dev.c
index 389d6e0..c711e2e 100644
--- a/net/rose/rose_dev.c
+++ b/net/rose/rose_dev.c
@@ -141,7 +141,7 @@ static int rose_xmit(struct sk_buff *skb, struct net_device *dev)
 	}
 	dev_kfree_skb(skb);
 	stats->tx_errors++;
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 static const struct header_ops rose_header_ops = {
diff --git a/net/sched/sch_teql.c b/net/sched/sch_teql.c
index 9c002b6..12434b6 100644
--- a/net/sched/sch_teql.c
+++ b/net/sched/sch_teql.c
@@ -314,7 +314,7 @@ restart:
 					netif_wake_queue(dev);
 					txq->tx_packets++;
 					txq->tx_bytes += length;
-					return 0;
+					return NETDEV_TX_OK;
 				}
 				__netif_tx_unlock(slave_txq);
 			}
@@ -323,7 +323,7 @@ restart:
 			break;
 		case 1:
 			master->slaves = NEXT_SLAVE(q);
-			return 0;
+			return NETDEV_TX_OK;
 		default:
 			nores = 1;
 			break;
@@ -345,7 +345,7 @@ restart:
 drop:
 	txq->tx_dropped++;
 	dev_kfree_skb(skb);
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 static int teql_master_open(struct net_device *dev)

--------------010301000907030908060503--
