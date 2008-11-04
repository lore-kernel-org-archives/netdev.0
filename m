From: David Miller <davem@davemloft.net>
Subject: [PATCH]: drivers/net: Kill now superfluous ->last_rx stores.
Date: Mon, 03 Nov 2008 21:12:56 -0800 (PST)
Message-ID: <20081103.211255.143270364.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37830
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750750AbYKDFNV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Nov 2008 00:13:21 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 26292C8C183
	for <netdev@vger.kernel.org>; Mon,  3 Nov 2008 21:12:56 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Checking this in made me feel as if the weight of the
world had been lifted off of my shoulders :-)

Commited to net-next-2.6

drivers/net: Kill now superfluous ->last_rx stores.

The generic packet receive code takes care of setting
netdev->last_rx when necessary, for the sake of the
bonding ARP monitor.

Drivers need not do it any more.

Some cases had to be skipped over because the drivers
were making use of the ->last_rx value themselves.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/3c501.c                           |    1 -
 drivers/net/3c505.c                           |    1 -
 drivers/net/3c507.c                           |    1 -
 drivers/net/3c509.c                           |    1 -
 drivers/net/3c515.c                           |    2 --
 drivers/net/3c523.c                           |    1 -
 drivers/net/3c527.c                           |    1 -
 drivers/net/3c59x.c                           |    2 --
 drivers/net/7990.c                            |    1 -
 drivers/net/8139cp.c                          |    1 -
 drivers/net/8139too.c                         |    1 -
 drivers/net/82596.c                           |    1 -
 drivers/net/a2065.c                           |    1 -
 drivers/net/acenic.c                          |    1 -
 drivers/net/amd8111e.c                        |    1 -
 drivers/net/appletalk/cops.c                  |    1 -
 drivers/net/appletalk/ltpc.c                  |    1 -
 drivers/net/arcnet/arc-rawmode.c              |    1 -
 drivers/net/arcnet/capmode.c                  |    1 -
 drivers/net/arcnet/rfc1051.c                  |    1 -
 drivers/net/arcnet/rfc1201.c                  |    2 --
 drivers/net/ariadne.c                         |    1 -
 drivers/net/arm/am79c961a.c                   |    1 -
 drivers/net/arm/at91_ether.c                  |    1 -
 drivers/net/arm/ep93xx_eth.c                  |    2 --
 drivers/net/arm/ixp4xx_eth.c                  |    1 -
 drivers/net/at1700.c                          |    1 -
 drivers/net/atarilance.c                      |    1 -
 drivers/net/atl1e/atl1e_main.c                |    1 -
 drivers/net/atlx/atl1.c                       |    2 --
 drivers/net/atlx/atl2.c                       |    1 -
 drivers/net/au1000_eth.c                      |    1 -
 drivers/net/b44.c                             |    1 -
 drivers/net/bfin_mac.c                        |    1 -
 drivers/net/bmac.c                            |    2 --
 drivers/net/bnx2.c                            |    1 -
 drivers/net/bnx2x_main.c                      |    3 ---
 drivers/net/cassini.c                         |    1 -
 drivers/net/chelsio/sge.c                     |    1 -
 drivers/net/cs89x0.c                          |    2 --
 drivers/net/cxgb3/sge.c                       |    1 -
 drivers/net/de600.c                           |    1 -
 drivers/net/de620.c                           |    1 -
 drivers/net/declance.c                        |    1 -
 drivers/net/defxx.c                           |    1 -
 drivers/net/depca.c                           |    1 -
 drivers/net/dl2k.c                            |    1 -
 drivers/net/e100.c                            |    1 -
 drivers/net/e1000/e1000_main.c                |    2 --
 drivers/net/e1000e/netdev.c                   |    2 --
 drivers/net/eepro.c                           |    1 -
 drivers/net/eexpress.c                        |    1 -
 drivers/net/ehea/ehea_main.c                  |    1 -
 drivers/net/enc28j60.c                        |    1 -
 drivers/net/enic/enic_main.c                  |    1 -
 drivers/net/epic100.c                         |    1 -
 drivers/net/eth16i.c                          |    1 -
 drivers/net/ewrk3.c                           |    1 -
 drivers/net/fealnx.c                          |    1 -
 drivers/net/fec_mpc52xx.c                     |    1 -
 drivers/net/forcedeth.c                       |    2 --
 drivers/net/gianfar.c                         |    2 --
 drivers/net/hamachi.c                         |    1 -
 drivers/net/hamradio/6pack.c                  |    1 -
 drivers/net/hamradio/baycom_epp.c             |    1 -
 drivers/net/hamradio/bpqether.c               |    1 -
 drivers/net/hamradio/dmascc.c                 |    1 -
 drivers/net/hamradio/hdlcdrv.c                |    1 -
 drivers/net/hamradio/mkiss.c                  |    1 -
 drivers/net/hamradio/scc.c                    |    1 -
 drivers/net/hamradio/yam.c                    |    1 -
 drivers/net/hp100.c                           |    2 --
 drivers/net/ibmlana.c                         |    1 -
 drivers/net/ibmveth.c                         |    1 -
 drivers/net/igb/igb_main.c                    |    2 --
 drivers/net/ioc3-eth.c                        |    1 -
 drivers/net/ipg.c                             |    9 ---------
 drivers/net/irda/ali-ircc.c                   |    1 -
 drivers/net/irda/au1k_ir.c                    |    1 -
 drivers/net/irda/irda-usb.c                   |    1 -
 drivers/net/irda/kingsun-sir.c                |    1 -
 drivers/net/irda/ks959-sir.c                  |    1 -
 drivers/net/irda/ksdazzle-sir.c               |    1 -
 drivers/net/irda/mcs7780.c                    |    1 -
 drivers/net/irda/nsc-ircc.c                   |    1 -
 drivers/net/irda/pxaficp_ir.c                 |    4 ----
 drivers/net/irda/sa1100_ir.c                  |    2 --
 drivers/net/irda/stir4200.c                   |    1 -
 drivers/net/irda/vlsi_ir.c                    |    1 -
 drivers/net/irda/w83977af_ir.c                |    1 -
 drivers/net/isa-skeleton.c                    |    1 -
 drivers/net/ixgb/ixgb_main.c                  |    1 -
 drivers/net/ixgbe/ixgbe_main.c                |    1 -
 drivers/net/ixp2000/ixpdev.c                  |    2 --
 drivers/net/jme.c                             |    1 -
 drivers/net/korina.c                          |    1 -
 drivers/net/lance.c                           |    1 -
 drivers/net/lib82596.c                        |    1 -
 drivers/net/lib8390.c                         |    1 -
 drivers/net/loopback.c                        |    2 --
 drivers/net/lp486e.c                          |    1 -
 drivers/net/mac89x0.c                         |    1 -
 drivers/net/macb.c                            |    1 -
 drivers/net/mace.c                            |    1 -
 drivers/net/macmace.c                         |    1 -
 drivers/net/macvlan.c                         |    2 --
 drivers/net/meth.c                            |    1 -
 drivers/net/mlx4/en_rx.c                      |    2 --
 drivers/net/mv643xx_eth.c                     |    2 --
 drivers/net/myri10ge/myri10ge.c               |    1 -
 drivers/net/myri_sbus.c                       |    1 -
 drivers/net/natsemi.c                         |    1 -
 drivers/net/netx-eth.c                        |    1 -
 drivers/net/netxen/netxen_nic_init.c          |    2 --
 drivers/net/ni5010.c                          |    1 -
 drivers/net/ni52.c                            |    1 -
 drivers/net/ni65.c                            |    1 -
 drivers/net/niu.c                             |    2 --
 drivers/net/pci-skeleton.c                    |    1 -
 drivers/net/pcmcia/3c574_cs.c                 |    1 -
 drivers/net/pcmcia/3c589_cs.c                 |    1 -
 drivers/net/pcmcia/axnet_cs.c                 |    1 -
 drivers/net/pcmcia/fmvj18x_cs.c               |    1 -
 drivers/net/pcmcia/nmclan_cs.c                |    1 -
 drivers/net/pcmcia/xirc2ps_cs.c               |    1 -
 drivers/net/pcnet32.c                         |    1 -
 drivers/net/plip.c                            |    1 -
 drivers/net/ppp_generic.c                     |    1 -
 drivers/net/qla3xxx.c                         |    2 --
 drivers/net/qlge/qlge_main.c                  |    1 -
 drivers/net/r6040.c                           |    1 -
 drivers/net/r8169.c                           |    1 -
 drivers/net/rrunner.c                         |    1 -
 drivers/net/s2io.c                            |    1 -
 drivers/net/sb1000.c                          |    1 -
 drivers/net/sc92031.c                         |    1 -
 drivers/net/seeq8005.c                        |    1 -
 drivers/net/sfc/rx.c                          |    2 +-
 drivers/net/sgiseeq.c                         |    1 -
 drivers/net/sh_eth.c                          |    1 -
 drivers/net/sis190.c                          |    1 -
 drivers/net/sis900.c                          |    1 -
 drivers/net/skfp/skfddi.c                     |    2 --
 drivers/net/skge.c                            |    1 -
 drivers/net/slip.c                            |    1 -
 drivers/net/smc911x.c                         |    2 --
 drivers/net/smc9194.c                         |    1 -
 drivers/net/smc91x.c                          |    1 -
 drivers/net/sonic.c                           |    1 -
 drivers/net/starfire.c                        |    1 -
 drivers/net/sun3lance.c                       |    1 -
 drivers/net/sunbmac.c                         |    1 -
 drivers/net/sundance.c                        |    1 -
 drivers/net/sungem.c                          |    1 -
 drivers/net/sunhme.c                          |    1 -
 drivers/net/sunlance.c                        |    2 --
 drivers/net/sunqe.c                           |    1 -
 drivers/net/tc35815.c                         |    1 -
 drivers/net/tehuti.c                          |    1 -
 drivers/net/tg3.c                             |    1 -
 drivers/net/tlan.c                            |    2 --
 drivers/net/tokenring/3c359.c                 |    2 --
 drivers/net/tokenring/ibmtr.c                 |    1 -
 drivers/net/tokenring/lanstreamer.c           |    1 -
 drivers/net/tokenring/olympic.c               |    2 --
 drivers/net/tokenring/smctr.c                 |    2 --
 drivers/net/tokenring/tms380tr.c              |    1 -
 drivers/net/tsi108_eth.c                      |    1 -
 drivers/net/tulip/de2104x.c                   |    1 -
 drivers/net/tulip/de4x5.c                     |    1 -
 drivers/net/tulip/dmfe.c                      |    1 -
 drivers/net/tulip/interrupt.c                 |    2 --
 drivers/net/tulip/uli526x.c                   |    1 -
 drivers/net/tulip/winbond-840.c               |    1 -
 drivers/net/tulip/xircom_cb.c                 |    1 -
 drivers/net/tun.c                             |    1 -
 drivers/net/typhoon.c                         |    1 -
 drivers/net/ucc_geth.c                        |    2 --
 drivers/net/usb/catc.c                        |    2 --
 drivers/net/via-rhine.c                       |    1 -
 drivers/net/via-velocity.c                    |    2 --
 drivers/net/wan/cosa.c                        |    1 -
 drivers/net/wan/cycx_x25.c                    |    2 --
 drivers/net/wan/dlci.c                        |    1 -
 drivers/net/wan/dscc4.c                       |    1 -
 drivers/net/wan/farsync.c                     |    2 --
 drivers/net/wan/hd6457x.c                     |    1 -
 drivers/net/wan/hostess_sv11.c                |    1 -
 drivers/net/wan/lapbether.c                   |    3 ---
 drivers/net/wan/lmc/lmc_main.c                |    1 -
 drivers/net/wan/lmc/lmc_proto.c               |    1 -
 drivers/net/wan/sbni.c                        |    2 --
 drivers/net/wan/sealevel.c                    |    1 -
 drivers/net/wan/syncppp.c                     |    4 ----
 drivers/net/wan/wanxl.c                       |    1 -
 drivers/net/wan/x25_asy.c                     |    4 ----
 drivers/net/wireless/airo.c                   |    3 ---
 drivers/net/wireless/arlan-main.c             |    1 -
 drivers/net/wireless/atmel.c                  |    2 --
 drivers/net/wireless/hostap/hostap_80211_rx.c |    3 ---
 drivers/net/wireless/netwave_cs.c             |    1 -
 drivers/net/wireless/orinoco.c                |    2 --
 drivers/net/wireless/ray_cs.c                 |    1 -
 drivers/net/wireless/strip.c                  |    2 --
 drivers/net/wireless/wavelan.c                |    1 -
 drivers/net/wireless/wavelan_cs.c             |    1 -
 drivers/net/wireless/wl3501_cs.c              |    1 -
 drivers/net/wireless/zd1201.c                 |    2 --
 drivers/net/xen-netfront.c                    |    1 -
 drivers/net/yellowfin.c                       |    1 -
 drivers/net/znet.c                            |    1 -
 211 files changed, 1 insertions(+), 276 deletions(-)

diff --git a/drivers/net/3c501.c b/drivers/net/3c501.c
index 7d15e7c..3a44db1 100644
--- a/drivers/net/3c501.c
+++ b/drivers/net/3c501.c
@@ -725,7 +725,6 @@ static void el_receive(struct net_device *dev)
 		insb(DATAPORT, skb_put(skb, pkt_len), pkt_len);
 		skb->protocol = eth_type_trans(skb, dev);
 		netif_rx(skb);
-		dev->last_rx = jiffies;
 		dev->stats.rx_packets++;
 		dev->stats.rx_bytes += pkt_len;
 	}
diff --git a/drivers/net/3c505.c b/drivers/net/3c505.c
index 6ecb418..e669da7 100644
--- a/drivers/net/3c505.c
+++ b/drivers/net/3c505.c
@@ -672,7 +672,6 @@ static irqreturn_t elp_interrupt(int irq, void *dev_id)
 					skb->protocol = eth_type_trans(skb,dev);
 					dev->stats.rx_bytes += skb->len;
 					netif_rx(skb);
-					dev->last_rx = jiffies;
 				}
 			}
 			adapter->dmaing = 0;
diff --git a/drivers/net/3c507.c b/drivers/net/3c507.c
index 66fd505..b8585ec 100644
--- a/drivers/net/3c507.c
+++ b/drivers/net/3c507.c
@@ -865,7 +865,6 @@ static void el16_rx(struct net_device *dev)
 
 			skb->protocol=eth_type_trans(skb,dev);
 			netif_rx(skb);
-			dev->last_rx = jiffies;
 			dev->stats.rx_packets++;
 			dev->stats.rx_bytes += pkt_len;
 		}
diff --git a/drivers/net/3c509.c b/drivers/net/3c509.c
index cc970c4..226a017 100644
--- a/drivers/net/3c509.c
+++ b/drivers/net/3c509.c
@@ -1074,7 +1074,6 @@ el3_rx(struct net_device *dev)
 				outw(RxDiscard, ioaddr + EL3_CMD); /* Pop top Rx packet. */
 				skb->protocol = eth_type_trans(skb,dev);
 				netif_rx(skb);
-				dev->last_rx = jiffies;
 				dev->stats.rx_bytes += pkt_len;
 				dev->stats.rx_packets++;
 				continue;
diff --git a/drivers/net/3c515.c b/drivers/net/3c515.c
index a2c2468..7f99500 100644
--- a/drivers/net/3c515.c
+++ b/drivers/net/3c515.c
@@ -1301,7 +1301,6 @@ static int corkscrew_rx(struct net_device *dev)
 				outw(RxDiscard, ioaddr + EL3_CMD);	/* Pop top Rx packet. */
 				skb->protocol = eth_type_trans(skb, dev);
 				netif_rx(skb);
-				dev->last_rx = jiffies;
 				dev->stats.rx_packets++;
 				dev->stats.rx_bytes += pkt_len;
 				/* Wait a limited time to go to next packet. */
@@ -1388,7 +1387,6 @@ static int boomerang_rx(struct net_device *dev)
 			}
 			skb->protocol = eth_type_trans(skb, dev);
 			netif_rx(skb);
-			dev->last_rx = jiffies;
 			dev->stats.rx_packets++;
 		}
 		entry = (++vp->cur_rx) % RX_RING_SIZE;
diff --git a/drivers/net/3c523.c b/drivers/net/3c523.c
index 23a3123..0885aee 100644
--- a/drivers/net/3c523.c
+++ b/drivers/net/3c523.c
@@ -983,7 +983,6 @@ static void elmc_rcv_int(struct net_device *dev)
 					skb_copy_to_linear_data(skb, (char *) p->base+(unsigned long) rbd->buffer,totlen);
 					skb->protocol = eth_type_trans(skb, dev);
 					netif_rx(skb);
-					dev->last_rx = jiffies;
 					dev->stats.rx_packets++;
 					dev->stats.rx_bytes += totlen;
 				} else {
diff --git a/drivers/net/3c527.c b/drivers/net/3c527.c
index 0f4cabb..2df3af3 100644
--- a/drivers/net/3c527.c
+++ b/drivers/net/3c527.c
@@ -1186,7 +1186,6 @@ static void mc32_rx_ring(struct net_device *dev)
 			}
 
 			skb->protocol=eth_type_trans(skb,dev);
-			dev->last_rx = jiffies;
  			dev->stats.rx_packets++;
  			dev->stats.rx_bytes += length;
 			netif_rx(skb);
diff --git a/drivers/net/3c59x.c b/drivers/net/3c59x.c
index 38d58fd..b4168df 100644
--- a/drivers/net/3c59x.c
+++ b/drivers/net/3c59x.c
@@ -2446,7 +2446,6 @@ static int vortex_rx(struct net_device *dev)
 				iowrite16(RxDiscard, ioaddr + EL3_CMD); /* Pop top Rx packet. */
 				skb->protocol = eth_type_trans(skb, dev);
 				netif_rx(skb);
-				dev->last_rx = jiffies;
 				dev->stats.rx_packets++;
 				/* Wait a limited time to go to next packet. */
 				for (i = 200; i >= 0; i--)
@@ -2529,7 +2528,6 @@ boomerang_rx(struct net_device *dev)
 				}
 			}
 			netif_rx(skb);
-			dev->last_rx = jiffies;
 			dev->stats.rx_packets++;
 		}
 		entry = (++vp->cur_rx) % RX_RING_SIZE;
diff --git a/drivers/net/7990.c b/drivers/net/7990.c
index ad6b8a5..7a331ac 100644
--- a/drivers/net/7990.c
+++ b/drivers/net/7990.c
@@ -336,7 +336,6 @@ static int lance_rx (struct net_device *dev)
                                          len);
                         skb->protocol = eth_type_trans (skb, dev);
 			netif_rx (skb);
-			dev->last_rx = jiffies;
 			dev->stats.rx_packets++;
 			dev->stats.rx_bytes += len;
                 }
diff --git a/drivers/net/8139cp.c b/drivers/net/8139cp.c
index 9e90d41..664bd73 100644
--- a/drivers/net/8139cp.c
+++ b/drivers/net/8139cp.c
@@ -457,7 +457,6 @@ static inline void cp_rx_skb (struct cp_private *cp, struct sk_buff *skb,
 
 	cp->dev->stats.rx_packets++;
 	cp->dev->stats.rx_bytes += skb->len;
-	cp->dev->last_rx = jiffies;
 
 #if CP_VLAN_TAG_USED
 	if (cp->vlgrp && (desc->opts2 & cpu_to_le32(RxVlanTagged))) {
diff --git a/drivers/net/8139too.c b/drivers/net/8139too.c
index 96841e4..37456ad 100644
--- a/drivers/net/8139too.c
+++ b/drivers/net/8139too.c
@@ -2025,7 +2025,6 @@ no_early_rx:
 
 			skb->protocol = eth_type_trans (skb, dev);
 
-			dev->last_rx = jiffies;
 			dev->stats.rx_bytes += pkt_size;
 			dev->stats.rx_packets++;
 
diff --git a/drivers/net/82596.c b/drivers/net/82596.c
index 1d97bb5..717fe2f 100644
--- a/drivers/net/82596.c
+++ b/drivers/net/82596.c
@@ -841,7 +841,6 @@ memory_squeeze:
 						pkt_len);
 #endif
 				netif_rx(skb);
-				dev->last_rx = jiffies;
 				dev->stats.rx_packets++;
 				dev->stats.rx_bytes+=pkt_len;
 			}
diff --git a/drivers/net/a2065.c b/drivers/net/a2065.c
index 48965de..7a60bdd 100644
--- a/drivers/net/a2065.c
+++ b/drivers/net/a2065.c
@@ -324,7 +324,6 @@ static int lance_rx (struct net_device *dev)
 					 len);
 			skb->protocol = eth_type_trans (skb, dev);
 			netif_rx (skb);
-			dev->last_rx = jiffies;
 			dev->stats.rx_packets++;
 			dev->stats.rx_bytes += len;
 		}
diff --git a/drivers/net/acenic.c b/drivers/net/acenic.c
index 6eefd93..b9d35f6 100644
--- a/drivers/net/acenic.c
+++ b/drivers/net/acenic.c
@@ -2033,7 +2033,6 @@ static void ace_rx_int(struct net_device *dev, u32 rxretprd, u32 rxretcsm)
 #endif
 			netif_rx(skb);
 
-		dev->last_rx = jiffies;
 		dev->stats.rx_packets++;
 		dev->stats.rx_bytes += retdesc->size;
 
diff --git a/drivers/net/amd8111e.c b/drivers/net/amd8111e.c
index 4a2ef83..0bc4f54 100644
--- a/drivers/net/amd8111e.c
+++ b/drivers/net/amd8111e.c
@@ -809,7 +809,6 @@ static int amd8111e_rx_poll(struct napi_struct *napi, int budget)
 			lp->coal_conf.rx_packets++;
 			lp->coal_conf.rx_bytes += pkt_len;
 			num_rx_pkt++;
-			dev->last_rx = jiffies;
 
 		err_next_pkt:
 			lp->rx_ring[rx_index].buff_phy_addr
diff --git a/drivers/net/appletalk/cops.c b/drivers/net/appletalk/cops.c
index 735fc94..0c4e3c5 100644
--- a/drivers/net/appletalk/cops.c
+++ b/drivers/net/appletalk/cops.c
@@ -851,7 +851,6 @@ static void cops_rx(struct net_device *dev)
 
         /* Send packet to a higher place. */
         netif_rx(skb);
-	dev->last_rx = jiffies;
 }
 
 static void cops_timeout(struct net_device *dev)
diff --git a/drivers/net/appletalk/ltpc.c b/drivers/net/appletalk/ltpc.c
index fef5560..8d109a5 100644
--- a/drivers/net/appletalk/ltpc.c
+++ b/drivers/net/appletalk/ltpc.c
@@ -783,7 +783,6 @@ static int sendup_buffer (struct net_device *dev)
 
 	/* toss it onwards */
 	netif_rx(skb);
-	dev->last_rx = jiffies;
 	return 0;
 }
 
diff --git a/drivers/net/arcnet/arc-rawmode.c b/drivers/net/arcnet/arc-rawmode.c
index e0a18e7..60088b3 100644
--- a/drivers/net/arcnet/arc-rawmode.c
+++ b/drivers/net/arcnet/arc-rawmode.c
@@ -125,7 +125,6 @@ static void rx(struct net_device *dev, int bufnum,
 	skb->protocol = __constant_htons(ETH_P_ARCNET);
 ;
 	netif_rx(skb);
-	dev->last_rx = jiffies;
 }
 
 
diff --git a/drivers/net/arcnet/capmode.c b/drivers/net/arcnet/capmode.c
index 02cb8f1..67bc47a 100644
--- a/drivers/net/arcnet/capmode.c
+++ b/drivers/net/arcnet/capmode.c
@@ -151,7 +151,6 @@ static void rx(struct net_device *dev, int bufnum,
 	skb->protocol = __constant_htons(ETH_P_ARCNET);
 ;
 	netif_rx(skb);
-	dev->last_rx = jiffies;
 }
 
 
diff --git a/drivers/net/arcnet/rfc1051.c b/drivers/net/arcnet/rfc1051.c
index dab185b..994be49 100644
--- a/drivers/net/arcnet/rfc1051.c
+++ b/drivers/net/arcnet/rfc1051.c
@@ -159,7 +159,6 @@ static void rx(struct net_device *dev, int bufnum,
 
 	skb->protocol = type_trans(skb, dev);
 	netif_rx(skb);
-	dev->last_rx = jiffies;
 }
 
 
diff --git a/drivers/net/arcnet/rfc1201.c b/drivers/net/arcnet/rfc1201.c
index 6d6d95c..962641e 100644
--- a/drivers/net/arcnet/rfc1201.c
+++ b/drivers/net/arcnet/rfc1201.c
@@ -230,7 +230,6 @@ static void rx(struct net_device *dev, int bufnum,
 
 		skb->protocol = type_trans(skb, dev);
 		netif_rx(skb);
-		dev->last_rx = jiffies;
 	} else {		/* split packet */
 		/*
 		 * NOTE: MSDOS ARP packet correction should only need to apply to
@@ -366,7 +365,6 @@ static void rx(struct net_device *dev, int bufnum,
 
 			skb->protocol = type_trans(skb, dev);
 			netif_rx(skb);
-			dev->last_rx = jiffies;
 		}
 	}
 }
diff --git a/drivers/net/ariadne.c b/drivers/net/ariadne.c
index 2903191..e1d72e0 100644
--- a/drivers/net/ariadne.c
+++ b/drivers/net/ariadne.c
@@ -753,7 +753,6 @@ static int ariadne_rx(struct net_device *dev)
 #endif
 
 	    netif_rx(skb);
-	    dev->last_rx = jiffies;
 	    dev->stats.rx_packets++;
 	    dev->stats.rx_bytes += pkt_len;
 	}
diff --git a/drivers/net/arm/am79c961a.c b/drivers/net/arm/am79c961a.c
index 6459155..0c628a9 100644
--- a/drivers/net/arm/am79c961a.c
+++ b/drivers/net/arm/am79c961a.c
@@ -532,7 +532,6 @@ am79c961_rx(struct net_device *dev, struct dev_priv *priv)
 			am_writeword(dev, hdraddr + 2, RMD_OWN);
 			skb->protocol = eth_type_trans(skb, dev);
 			netif_rx(skb);
-			dev->last_rx = jiffies;
 			priv->stats.rx_bytes += len;
 			priv->stats.rx_packets ++;
 		} else {
diff --git a/drivers/net/arm/at91_ether.c b/drivers/net/arm/at91_ether.c
index e21dc20..442938d 100644
--- a/drivers/net/arm/at91_ether.c
+++ b/drivers/net/arm/at91_ether.c
@@ -893,7 +893,6 @@ static void at91ether_rx(struct net_device *dev)
 			memcpy(skb_put(skb, pktlen), p_recv, pktlen);
 
 			skb->protocol = eth_type_trans(skb, dev);
-			dev->last_rx = jiffies;
 			dev->stats.rx_bytes += pktlen;
 			netif_rx(skb);
 		}
diff --git a/drivers/net/arm/ep93xx_eth.c b/drivers/net/arm/ep93xx_eth.c
index 1267444..588c973 100644
--- a/drivers/net/arm/ep93xx_eth.c
+++ b/drivers/net/arm/ep93xx_eth.c
@@ -259,8 +259,6 @@ static int ep93xx_rx(struct net_device *dev, int processed, int budget)
 			skb_put(skb, length);
 			skb->protocol = eth_type_trans(skb, dev);
 
-			dev->last_rx = jiffies;
-
 			netif_receive_skb(skb);
 
 			ep->stats.rx_packets++;
diff --git a/drivers/net/arm/ixp4xx_eth.c b/drivers/net/arm/ixp4xx_eth.c
index e2d702b..14ffa2a 100644
--- a/drivers/net/arm/ixp4xx_eth.c
+++ b/drivers/net/arm/ixp4xx_eth.c
@@ -588,7 +588,6 @@ static int eth_poll(struct napi_struct *napi, int budget)
 		debug_pkt(dev, "eth_poll", skb->data, skb->len);
 
 		skb->protocol = eth_type_trans(skb, dev);
-		dev->last_rx = jiffies;
 		port->stat.rx_packets++;
 		port->stat.rx_bytes += skb->len;
 		netif_receive_skb(skb);
diff --git a/drivers/net/at1700.c b/drivers/net/at1700.c
index 18f7245..2d4b5c3 100644
--- a/drivers/net/at1700.c
+++ b/drivers/net/at1700.c
@@ -767,7 +767,6 @@ net_rx(struct net_device *dev)
 			insw(ioaddr + DATAPORT, skb_put(skb,pkt_len), (pkt_len + 1) >> 1);
 			skb->protocol=eth_type_trans(skb, dev);
 			netif_rx(skb);
-			dev->last_rx = jiffies;
 			dev->stats.rx_packets++;
 			dev->stats.rx_bytes += pkt_len;
 		}
diff --git a/drivers/net/atarilance.c b/drivers/net/atarilance.c
index 5a94c49..701214b 100644
--- a/drivers/net/atarilance.c
+++ b/drivers/net/atarilance.c
@@ -1030,7 +1030,6 @@ static int lance_rx( struct net_device *dev )
 				lp->memcpy_f( skb->data, PKTBUF_ADDR(head), pkt_len );
 				skb->protocol = eth_type_trans( skb, dev );
 				netif_rx( skb );
-				dev->last_rx = jiffies;
 				dev->stats.rx_packets++;
 				dev->stats.rx_bytes += pkt_len;
 			}
diff --git a/drivers/net/atl1e/atl1e_main.c b/drivers/net/atl1e/atl1e_main.c
index 9b60352..0f8c752 100644
--- a/drivers/net/atl1e/atl1e_main.c
+++ b/drivers/net/atl1e/atl1e_main.c
@@ -1460,7 +1460,6 @@ static void atl1e_clean_rx_irq(struct atl1e_adapter *adapter, u8 que,
 				netif_receive_skb(skb);
 			}
 
-			netdev->last_rx = jiffies;
 skip_pkt:
 	/* skip current packet whether it's ok or not. */
 			rx_page->read_offset +=
diff --git a/drivers/net/atlx/atl1.c b/drivers/net/atlx/atl1.c
index 3836e62..09ed2fd 100644
--- a/drivers/net/atlx/atl1.c
+++ b/drivers/net/atlx/atl1.c
@@ -2028,8 +2028,6 @@ rrd_ok:
 		buffer_info->skb = NULL;
 		buffer_info->alloced = 0;
 		rrd->xsz.valid = 0;
-
-		adapter->netdev->last_rx = jiffies;
 	}
 
 	atomic_set(&rrd_ring->next_to_clean, rrd_next_to_clean);
diff --git a/drivers/net/atlx/atl2.c b/drivers/net/atlx/atl2.c
index 21ca6dd..60c9e53 100644
--- a/drivers/net/atlx/atl2.c
+++ b/drivers/net/atlx/atl2.c
@@ -437,7 +437,6 @@ static void atl2_intr_rx(struct atl2_adapter *adapter)
 			netif_rx(skb);
 			netdev->stats.rx_bytes += rx_size;
 			netdev->stats.rx_packets++;
-			netdev->last_rx = jiffies;
 		} else {
 			netdev->stats.rx_errors++;
 
diff --git a/drivers/net/au1000_eth.c b/drivers/net/au1000_eth.c
index 019b13c..2b69b2b 100644
--- a/drivers/net/au1000_eth.c
+++ b/drivers/net/au1000_eth.c
@@ -1240,7 +1240,6 @@ static int au1000_rx(struct net_device *dev)
 		/* next descriptor */
 		prxd = aup->rx_dma_ring[aup->rx_head];
 		buff_stat = prxd->buff_stat;
-		dev->last_rx = jiffies;
 	}
 	return 0;
 }
diff --git a/drivers/net/b44.c b/drivers/net/b44.c
index 1978d25..2c7a32e 100644
--- a/drivers/net/b44.c
+++ b/drivers/net/b44.c
@@ -829,7 +829,6 @@ static int b44_rx(struct b44 *bp, int budget)
 		skb->ip_summed = CHECKSUM_NONE;
 		skb->protocol = eth_type_trans(skb, bp->dev);
 		netif_receive_skb(skb);
-		bp->dev->last_rx = jiffies;
 		received++;
 		budget--;
 	next_pkt:
diff --git a/drivers/net/bfin_mac.c b/drivers/net/bfin_mac.c
index b458d60..78e31aa 100644
--- a/drivers/net/bfin_mac.c
+++ b/drivers/net/bfin_mac.c
@@ -741,7 +741,6 @@ static void bfin_mac_rx(struct net_device *dev)
 	blackfin_dcache_invalidate_range((unsigned long)skb->head,
 					 (unsigned long)skb->tail);
 
-	dev->last_rx = jiffies;
 	skb->protocol = eth_type_trans(skb, dev);
 #if defined(BFIN_MAC_CSUM_OFFLOAD)
 	skb->csum = current_rx_ptr->status.ip_payload_csum;
diff --git a/drivers/net/bmac.c b/drivers/net/bmac.c
index b141d02..8a546a3 100644
--- a/drivers/net/bmac.c
+++ b/drivers/net/bmac.c
@@ -716,13 +716,11 @@ static irqreturn_t bmac_rxdma_intr(int irq, void *dev_id)
 			skb_put(skb, nb);
 			skb->protocol = eth_type_trans(skb, dev);
 			netif_rx(skb);
-			dev->last_rx = jiffies;
 			++dev->stats.rx_packets;
 			dev->stats.rx_bytes += nb;
 		} else {
 			++dev->stats.rx_dropped;
 		}
-		dev->last_rx = jiffies;
 		if ((skb = bp->rx_bufs[i]) == NULL) {
 			bp->rx_bufs[i] = skb = dev_alloc_skb(RX_BUFLEN+2);
 			if (skb != NULL)
diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index f2e8c3b..51b163a 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -3000,7 +3000,6 @@ bnx2_rx_int(struct bnx2 *bp, struct bnx2_napi *bnapi, int budget)
 #endif
 			netif_receive_skb(skb);
 
-		bp->dev->last_rx = jiffies;
 		rx_pkt++;
 
 next_rx:
diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 42965ad..68d0ed3 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -1328,7 +1328,6 @@ static void bnx2x_tpa_stop(struct bnx2x *bp, struct bnx2x_fastpath *fp,
 			dev_kfree_skb(skb);
 		}
 
-		bp->dev->last_rx = jiffies;
 
 		/* put new skb in bin */
 		fp->tpa_pool[queue].skb = new_skb;
@@ -1557,7 +1556,6 @@ reuse_rx:
 #endif
 			netif_receive_skb(skb);
 
-		bp->dev->last_rx = jiffies;
 
 next_rx:
 		rx_buf->skb = NULL;
@@ -8767,7 +8765,6 @@ static int bnx2x_run_loopback(struct bnx2x *bp, int loopback_mode, u8 link_up)
 	rc = 0;
 
 test_loopback_rx_exit:
-	bp->dev->last_rx = jiffies;
 
 	fp->rx_bd_cons = NEXT_RX_IDX(fp->rx_bd_cons);
 	fp->rx_bd_prod = NEXT_RX_IDX(fp->rx_bd_prod);
diff --git a/drivers/net/cassini.c b/drivers/net/cassini.c
index a06931d..bc84c4c 100644
--- a/drivers/net/cassini.c
+++ b/drivers/net/cassini.c
@@ -2405,7 +2405,6 @@ static int cas_rx_ringN(struct cas *cp, int ring, int budget)
 		cp->net_stats[ring].rx_packets++;
 		cp->net_stats[ring].rx_bytes += len;
 		spin_unlock(&cp->stat_lock[ring]);
-		cp->dev->last_rx = jiffies;
 
 	next:
 		npackets++;
diff --git a/drivers/net/chelsio/sge.c b/drivers/net/chelsio/sge.c
index d6c7d2a..fa0a1f1 100644
--- a/drivers/net/chelsio/sge.c
+++ b/drivers/net/chelsio/sge.c
@@ -1385,7 +1385,6 @@ static void sge_rx(struct sge *sge, struct freelQ *fl, unsigned int len)
 	st = per_cpu_ptr(sge->port_stats[p->iff], smp_processor_id());
 
 	skb->protocol = eth_type_trans(skb, adapter->port[p->iff].dev);
-	skb->dev->last_rx = jiffies;
 	if ((adapter->flags & RX_CSUM_ENABLED) && p->csum == 0xffff &&
 	    skb->protocol == htons(ETH_P_IP) &&
 	    (skb->data[9] == IPPROTO_TCP || skb->data[9] == IPPROTO_UDP)) {
diff --git a/drivers/net/cs89x0.c b/drivers/net/cs89x0.c
index 65174d3..b063395 100644
--- a/drivers/net/cs89x0.c
+++ b/drivers/net/cs89x0.c
@@ -1024,7 +1024,6 @@ skip_this_frame:
 	}
         skb->protocol=eth_type_trans(skb,dev);
 	netif_rx(skb);
-	dev->last_rx = jiffies;
 	lp->stats.rx_packets++;
 	lp->stats.rx_bytes += length;
 }
@@ -1718,7 +1717,6 @@ net_rx(struct net_device *dev)
 
         skb->protocol=eth_type_trans(skb,dev);
 	netif_rx(skb);
-	dev->last_rx = jiffies;
 	lp->stats.rx_packets++;
 	lp->stats.rx_bytes += length;
 }
diff --git a/drivers/net/cxgb3/sge.c b/drivers/net/cxgb3/sge.c
index c6480be..268f158 100644
--- a/drivers/net/cxgb3/sge.c
+++ b/drivers/net/cxgb3/sge.c
@@ -1876,7 +1876,6 @@ static void rx_eth(struct adapter *adap, struct sge_rspq *rq,
 
 	skb_pull(skb, sizeof(*p) + pad);
 	skb->protocol = eth_type_trans(skb, adap->port[p->iff]);
-	skb->dev->last_rx = jiffies;
 	pi = netdev_priv(skb->dev);
 	if (pi->rx_csum_offload && p->csum_valid && p->csum == htons(0xffff) &&
 	    !p->fragment) {
diff --git a/drivers/net/de600.c b/drivers/net/de600.c
index 2826c74..970f820 100644
--- a/drivers/net/de600.c
+++ b/drivers/net/de600.c
@@ -369,7 +369,6 @@ static void de600_rx_intr(struct net_device *dev)
 	netif_rx(skb);
 
 	/* update stats */
-	dev->last_rx = jiffies;
 	dev->stats.rx_packets++; /* count all receives */
 	dev->stats.rx_bytes += size; /* count all received bytes */
 
diff --git a/drivers/net/de620.c b/drivers/net/de620.c
index 643b1ea..0d4b6ac 100644
--- a/drivers/net/de620.c
+++ b/drivers/net/de620.c
@@ -686,7 +686,6 @@ static int de620_rx_intr(struct net_device *dev)
 			PRINTK(("Read %d bytes\n", size));
 			skb->protocol=eth_type_trans(skb,dev);
 			netif_rx(skb); /* deliver it "upstairs" */
-			dev->last_rx = jiffies;
 			/* count all receives */
 			dev->stats.rx_packets++;
 			dev->stats.rx_bytes += size;
diff --git a/drivers/net/declance.c b/drivers/net/declance.c
index df01ad3..f6988d7 100644
--- a/drivers/net/declance.c
+++ b/drivers/net/declance.c
@@ -622,7 +622,6 @@ static int lance_rx(struct net_device *dev)
 
 			skb->protocol = eth_type_trans(skb, dev);
 			netif_rx(skb);
-			dev->last_rx = jiffies;
 			dev->stats.rx_packets++;
 		}
 
diff --git a/drivers/net/defxx.c b/drivers/net/defxx.c
index c062aac..f078874 100644
--- a/drivers/net/defxx.c
+++ b/drivers/net/defxx.c
@@ -3103,7 +3103,6 @@ static void dfx_rcv_queue_process(
 					netif_rx(skb);
 
 					/* Update the rcv counters */
-					bp->dev->last_rx = jiffies;
 					bp->rcv_total_frames++;
 					if (*(p_buff + RCV_BUFF_K_DA) & 0x01)
 						bp->rcv_multicast_frames++;
diff --git a/drivers/net/depca.c b/drivers/net/depca.c
index bf6401f..fda1226 100644
--- a/drivers/net/depca.c
+++ b/drivers/net/depca.c
@@ -1056,7 +1056,6 @@ static int depca_rx(struct net_device *dev)
 					/*
 					   ** Update stats
 					 */
-					dev->last_rx = jiffies;
 					dev->stats.rx_packets++;
 					dev->stats.rx_bytes += pkt_len;
 					for (i = 1; i < DEPCA_PKT_STAT_SZ - 1; i++) {
diff --git a/drivers/net/dl2k.c b/drivers/net/dl2k.c
index f9e405a..9ec9785 100644
--- a/drivers/net/dl2k.c
+++ b/drivers/net/dl2k.c
@@ -891,7 +891,6 @@ receive_packet (struct net_device *dev)
 			}
 #endif
 			netif_rx (skb);
-			dev->last_rx = jiffies;
 		}
 		entry = (entry + 1) % RX_RING_SIZE;
 	}
diff --git a/drivers/net/e100.c b/drivers/net/e100.c
index 084127f..62cdefa 100644
--- a/drivers/net/e100.c
+++ b/drivers/net/e100.c
@@ -1880,7 +1880,6 @@ static int e100_rx_indicate(struct nic *nic, struct rx *rx,
 	} else {
 		dev->stats.rx_packets++;
 		dev->stats.rx_bytes += actual_size;
-		nic->netdev->last_rx = jiffies;
 		netif_receive_skb(skb);
 		if(work_done)
 			(*work_done)++;
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 07b38fb..78a4250 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -4099,8 +4099,6 @@ static bool e1000_clean_rx_irq(struct e1000_adapter *adapter,
 			netif_receive_skb(skb);
 		}
 
-		netdev->last_rx = jiffies;
-
 next_desc:
 		rx_desc->status = 0;
 
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index a5c9266..63e5688 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -103,8 +103,6 @@ static void e1000_receive_skb(struct e1000_adapter *adapter,
 					 le16_to_cpu(vlan));
 	else
 		netif_receive_skb(skb);
-
-	netdev->last_rx = jiffies;
 }
 
 /**
diff --git a/drivers/net/eepro.c b/drivers/net/eepro.c
index 5f72362..93387f1 100644
--- a/drivers/net/eepro.c
+++ b/drivers/net/eepro.c
@@ -1580,7 +1580,6 @@ eepro_rx(struct net_device *dev)
 
 			skb->protocol = eth_type_trans(skb,dev);
 			netif_rx(skb);
-			dev->last_rx = jiffies;
 			dev->stats.rx_packets++;
 		}
 
diff --git a/drivers/net/eexpress.c b/drivers/net/eexpress.c
index b751c1b..a125e41 100644
--- a/drivers/net/eexpress.c
+++ b/drivers/net/eexpress.c
@@ -967,7 +967,6 @@ static void eexp_hw_rx_pio(struct net_device *dev)
 			        insw(ioaddr+DATAPORT, skb_put(skb,pkt_len),(pkt_len+1)>>1);
 				skb->protocol = eth_type_trans(skb,dev);
 				netif_rx(skb);
-				dev->last_rx = jiffies;
 				dev->stats.rx_packets++;
 				dev->stats.rx_bytes += pkt_len;
 			}
diff --git a/drivers/net/ehea/ehea_main.c b/drivers/net/ehea/ehea_main.c
index 422fcb9..44c9ae1 100644
--- a/drivers/net/ehea/ehea_main.c
+++ b/drivers/net/ehea/ehea_main.c
@@ -728,7 +728,6 @@ static int ehea_proc_rwqes(struct net_device *dev,
 			}
 
 			ehea_proc_skb(pr, cqe, skb);
-			dev->last_rx = jiffies;
 		} else {
 			pr->p_stats.poll_receive_errors++;
 			port_reset = ehea_treat_poll_error(pr, rq, cqe,
diff --git a/drivers/net/enc28j60.c b/drivers/net/enc28j60.c
index a5c7bd4..d186a52 100644
--- a/drivers/net/enc28j60.c
+++ b/drivers/net/enc28j60.c
@@ -944,7 +944,6 @@ static void enc28j60_hw_rx(struct net_device *ndev)
 			/* update statistics */
 			ndev->stats.rx_packets++;
 			ndev->stats.rx_bytes += len;
-			ndev->last_rx = jiffies;
 			netif_rx(skb);
 		}
 	}
diff --git a/drivers/net/enic/enic_main.c b/drivers/net/enic/enic_main.c
index 180e968..8594d7f 100644
--- a/drivers/net/enic/enic_main.c
+++ b/drivers/net/enic/enic_main.c
@@ -951,7 +951,6 @@ static void enic_rq_indicate_buf(struct vnic_rq *rq,
 		}
 
 		skb->dev = enic->netdev;
-		enic->netdev->last_rx = jiffies;
 
 		if (enic->vlan_group && vlan_stripped) {
 
diff --git a/drivers/net/epic100.c b/drivers/net/epic100.c
index 65a4040..6f399bd 100644
--- a/drivers/net/epic100.c
+++ b/drivers/net/epic100.c
@@ -1222,7 +1222,6 @@ static int epic_rx(struct net_device *dev, int budget)
 			}
 			skb->protocol = eth_type_trans(skb, dev);
 			netif_receive_skb(skb);
-			dev->last_rx = jiffies;
 			ep->stats.rx_packets++;
 			ep->stats.rx_bytes += pkt_len;
 		}
diff --git a/drivers/net/eth16i.c b/drivers/net/eth16i.c
index bee8b3f..88b1be0 100644
--- a/drivers/net/eth16i.c
+++ b/drivers/net/eth16i.c
@@ -1205,7 +1205,6 @@ static void eth16i_rx(struct net_device *dev)
 				printk(KERN_DEBUG ".\n");
 			}
 			netif_rx(skb);
-			dev->last_rx = jiffies;
 			dev->stats.rx_packets++;
 			dev->stats.rx_bytes += pkt_len;
 
diff --git a/drivers/net/ewrk3.c b/drivers/net/ewrk3.c
index 3ab2156..f3b664a 100644
--- a/drivers/net/ewrk3.c
+++ b/drivers/net/ewrk3.c
@@ -1026,7 +1026,6 @@ static int ewrk3_rx(struct net_device *dev)
 						/*
 						   ** Update stats
 						 */
-						dev->last_rx = jiffies;
 						dev->stats.rx_packets++;
 						dev->stats.rx_bytes += pkt_len;
 					} else {
diff --git a/drivers/net/fealnx.c b/drivers/net/fealnx.c
index 61c7cbb..31ab1ff 100644
--- a/drivers/net/fealnx.c
+++ b/drivers/net/fealnx.c
@@ -1726,7 +1726,6 @@ static int netdev_rx(struct net_device *dev)
 			}
 			skb->protocol = eth_type_trans(skb, dev);
 			netif_rx(skb);
-			dev->last_rx = jiffies;
 			np->stats.rx_packets++;
 			np->stats.rx_bytes += pkt_len;
 		}
diff --git a/drivers/net/fec_mpc52xx.c b/drivers/net/fec_mpc52xx.c
index aec3b97..94054b4 100644
--- a/drivers/net/fec_mpc52xx.c
+++ b/drivers/net/fec_mpc52xx.c
@@ -487,7 +487,6 @@ static irqreturn_t mpc52xx_fec_rx_interrupt(int irq, void *dev_id)
 			rskb->protocol = eth_type_trans(rskb, dev);
 
 			netif_rx(rskb);
-			dev->last_rx = jiffies;
 		} else {
 			/* Can't get a new one : reuse the same & drop pkt */
 			dev_notice(&dev->dev, "Memory squeeze, dropping packet.\n");
diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index 0b12e48..765210e 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -2735,7 +2735,6 @@ static int nv_rx_process(struct net_device *dev, int limit)
 #else
 		netif_rx(skb);
 #endif
-		dev->last_rx = jiffies;
 		dev->stats.rx_packets++;
 		dev->stats.rx_bytes += len;
 next_pkt:
@@ -2848,7 +2847,6 @@ static int nv_rx_process_optimized(struct net_device *dev, int limit)
 				}
 			}
 
-			dev->last_rx = jiffies;
 			dev->stats.rx_packets++;
 			dev->stats.rx_bytes += len;
 		} else {
diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 013525f..a091db3 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -1693,8 +1693,6 @@ int gfar_clean_rx_ring(struct net_device *dev, int rx_work_limit)
 			dev->stats.rx_bytes += pkt_len;
 		}
 
-		dev->last_rx = jiffies;
-
 		priv->rx_skbuff[priv->skb_currx] = newskb;
 
 		/* Setup the new bdp */
diff --git a/drivers/net/hamachi.c b/drivers/net/hamachi.c
index 1dc0fd0..77f2b29 100644
--- a/drivers/net/hamachi.c
+++ b/drivers/net/hamachi.c
@@ -1645,7 +1645,6 @@ static int hamachi_rx(struct net_device *dev)
 #endif  /* RX_CHECKSUM */
 
 			netif_rx(skb);
-			dev->last_rx = jiffies;
 			hmp->stats.rx_packets++;
 		}
 		entry = (++hmp->cur_rx) % RX_RING_SIZE;
diff --git a/drivers/net/hamradio/6pack.c b/drivers/net/hamradio/6pack.c
index 0f501d2..50f1e17 100644
--- a/drivers/net/hamradio/6pack.c
+++ b/drivers/net/hamradio/6pack.c
@@ -373,7 +373,6 @@ static void sp_bump(struct sixpack *sp, char cmd)
 	memcpy(ptr, sp->cooked_buf + 1, count);
 	skb->protocol = ax25_type_trans(skb, sp->dev);
 	netif_rx(skb);
-	sp->dev->last_rx = jiffies;
 	sp->dev->stats.rx_packets++;
 
 	return;
diff --git a/drivers/net/hamradio/baycom_epp.c b/drivers/net/hamradio/baycom_epp.c
index 00bc7fb..81a65e3 100644
--- a/drivers/net/hamradio/baycom_epp.c
+++ b/drivers/net/hamradio/baycom_epp.c
@@ -555,7 +555,6 @@ static void do_rxpacket(struct net_device *dev)
 	memcpy(cp, bc->hdlcrx.buf, pktlen - 1);
 	skb->protocol = ax25_type_trans(skb, dev);
 	netif_rx(skb);
-	dev->last_rx = jiffies;
 	bc->stats.rx_packets++;
 }
 
diff --git a/drivers/net/hamradio/bpqether.c b/drivers/net/hamradio/bpqether.c
index 74529c8..46f8f33 100644
--- a/drivers/net/hamradio/bpqether.c
+++ b/drivers/net/hamradio/bpqether.c
@@ -230,7 +230,6 @@ static int bpq_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_ty
 
 	skb->protocol = ax25_type_trans(skb, dev);
 	netif_rx(skb);
-	dev->last_rx = jiffies;
 unlock:
 
 	rcu_read_unlock();
diff --git a/drivers/net/hamradio/dmascc.c b/drivers/net/hamradio/dmascc.c
index e8cfade..7e46114 100644
--- a/drivers/net/hamradio/dmascc.c
+++ b/drivers/net/hamradio/dmascc.c
@@ -1283,7 +1283,6 @@ static void rx_bh(struct work_struct *ugli_api)
 			memcpy(&data[1], priv->rx_buf[i], cb);
 			skb->protocol = ax25_type_trans(skb, priv->dev);
 			netif_rx(skb);
-			priv->dev->last_rx = jiffies;
 			priv->stats.rx_packets++;
 			priv->stats.rx_bytes += cb;
 		}
diff --git a/drivers/net/hamradio/hdlcdrv.c b/drivers/net/hamradio/hdlcdrv.c
index c258a05..8eba61a 100644
--- a/drivers/net/hamradio/hdlcdrv.c
+++ b/drivers/net/hamradio/hdlcdrv.c
@@ -162,7 +162,6 @@ static void hdlc_rx_flag(struct net_device *dev, struct hdlcdrv_state *s)
 	memcpy(cp, s->hdlcrx.buffer, pkt_len - 1);
 	skb->protocol = ax25_type_trans(skb, dev);
 	netif_rx(skb);
-	dev->last_rx = jiffies;
 	s->stats.rx_packets++;
 }
 
diff --git a/drivers/net/hamradio/mkiss.c b/drivers/net/hamradio/mkiss.c
index b8e25c4..7570c73 100644
--- a/drivers/net/hamradio/mkiss.c
+++ b/drivers/net/hamradio/mkiss.c
@@ -303,7 +303,6 @@ static void ax_bump(struct mkiss *ax)
 	memcpy(skb_put(skb,count), ax->rbuff, count);
 	skb->protocol = ax25_type_trans(skb, ax->dev);
 	netif_rx(skb);
-	ax->dev->last_rx = jiffies;
 	ax->stats.rx_packets++;
 	ax->stats.rx_bytes += count;
 	spin_unlock_bh(&ax->buflock);
diff --git a/drivers/net/hamradio/scc.c b/drivers/net/hamradio/scc.c
index c17e39b..802d1c7 100644
--- a/drivers/net/hamradio/scc.c
+++ b/drivers/net/hamradio/scc.c
@@ -1627,7 +1627,6 @@ static void scc_net_rx(struct scc_channel *scc, struct sk_buff *skb)
 	skb->protocol = ax25_type_trans(skb, scc->dev);
 	
 	netif_rx(skb);
-	scc->dev->last_rx = jiffies;
 	return;
 }
 
diff --git a/drivers/net/hamradio/yam.c b/drivers/net/hamradio/yam.c
index 1c94286..5407f74 100644
--- a/drivers/net/hamradio/yam.c
+++ b/drivers/net/hamradio/yam.c
@@ -515,7 +515,6 @@ static inline void yam_rx_flag(struct net_device *dev, struct yam_port *yp)
 				memcpy(cp, yp->rx_buf, pkt_len - 1);
 				skb->protocol = ax25_type_trans(skb, dev);
 				netif_rx(skb);
-				dev->last_rx = jiffies;
 				++yp->stats.rx_packets;
 			}
 		}
diff --git a/drivers/net/hp100.c b/drivers/net/hp100.c
index fd34452..4dda9b0 100644
--- a/drivers/net/hp100.c
+++ b/drivers/net/hp100.c
@@ -1834,7 +1834,6 @@ static void hp100_rx(struct net_device *dev)
 					ptr[9], ptr[10], ptr[11]);
 #endif
 			netif_rx(skb);
-			dev->last_rx = jiffies;
 			lp->stats.rx_packets++;
 			lp->stats.rx_bytes += pkt_len;
 		}
@@ -1925,7 +1924,6 @@ static void hp100_rx_bm(struct net_device *dev)
 
 				netif_rx(ptr->skb);	/* Up and away... */
 
-				dev->last_rx = jiffies;
 				lp->stats.rx_packets++;
 				lp->stats.rx_bytes += pkt_len;
 			}
diff --git a/drivers/net/ibmlana.c b/drivers/net/ibmlana.c
index 0fad08c..5b5bf9f 100644
--- a/drivers/net/ibmlana.c
+++ b/drivers/net/ibmlana.c
@@ -605,7 +605,6 @@ static void irqrx_handler(struct net_device *dev)
 				skb->ip_summed = CHECKSUM_NONE;
 
 				/* bookkeeping */
-				dev->last_rx = jiffies;
 				dev->stats.rx_packets++;
 				dev->stats.rx_bytes += rda.length;
 
diff --git a/drivers/net/ibmveth.c b/drivers/net/ibmveth.c
index 9dc4958..2c40957 100644
--- a/drivers/net/ibmveth.c
+++ b/drivers/net/ibmveth.c
@@ -1014,7 +1014,6 @@ static int ibmveth_poll(struct napi_struct *napi, int budget)
 			netdev->stats.rx_packets++;
 			netdev->stats.rx_bytes += length;
 			frames_processed++;
-			netdev->last_rx = jiffies;
 		}
 	} while (frames_processed < budget);
 
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 3b42665..89ffc07 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -3940,8 +3940,6 @@ send_up:
 
 		igb_receive_skb(rx_ring, staterr, rx_desc, skb);
 
-		netdev->last_rx = jiffies;
-
 next_desc:
 		rx_desc->wb.upper.status_error = 0;
 
diff --git a/drivers/net/ioc3-eth.c b/drivers/net/ioc3-eth.c
index afac65e..170b12d 100644
--- a/drivers/net/ioc3-eth.c
+++ b/drivers/net/ioc3-eth.c
@@ -621,7 +621,6 @@ static inline void ioc3_rx(struct ioc3_private *ip)
 			rxb = (struct ioc3_erxbuf *) new_skb->data;
 			skb_reserve(new_skb, RX_OFFSET);
 
-			priv_netdev(ip)->last_rx = jiffies;
 			ip->stats.rx_packets++;		/* Statistics */
 			ip->stats.rx_bytes += len;
 		} else {
diff --git a/drivers/net/ipg.c b/drivers/net/ipg.c
index 7373daf..24c777a 100644
--- a/drivers/net/ipg.c
+++ b/drivers/net/ipg.c
@@ -1222,7 +1222,6 @@ static void ipg_nic_rx_with_start_and_end(struct net_device *dev,
 	skb->protocol = eth_type_trans(skb, dev);
 	skb->ip_summed = CHECKSUM_NONE;
 	netif_rx(skb);
-	dev->last_rx = jiffies;
 	sp->rx_buff[entry] = NULL;
 }
 
@@ -1256,7 +1255,6 @@ static void ipg_nic_rx_with_start(struct net_device *dev,
 	jumbo->skb = skb;
 
 	sp->rx_buff[entry] = NULL;
-	dev->last_rx = jiffies;
 }
 
 static void ipg_nic_rx_with_end(struct net_device *dev,
@@ -1292,7 +1290,6 @@ static void ipg_nic_rx_with_end(struct net_device *dev,
 			}
 		}
 
-		dev->last_rx = jiffies;
 		jumbo->found_start = 0;
 		jumbo->current_size = 0;
 		jumbo->skb = NULL;
@@ -1325,7 +1322,6 @@ static void ipg_nic_rx_no_start_no_end(struct net_device *dev,
 					       skb->data, sp->rxfrag_size);
 				}
 			}
-			dev->last_rx = jiffies;
 			ipg_nic_rx_free_skb(dev);
 		}
 	} else {
@@ -1494,11 +1490,6 @@ static int ipg_nic_rx(struct net_device *dev)
 			 * when processing completes.
 			 */
 			netif_rx(skb);
-
-			/* Record frame receive time (jiffies = Linux
-			 * kernel current time stamp).
-			 */
-			dev->last_rx = jiffies;
 		}
 
 		/* Assure RX buffer is not reused by IPG. */
diff --git a/drivers/net/irda/ali-ircc.c b/drivers/net/irda/ali-ircc.c
index 2ff1818..9fde748 100644
--- a/drivers/net/irda/ali-ircc.c
+++ b/drivers/net/irda/ali-ircc.c
@@ -1931,7 +1931,6 @@ static int  ali_ircc_dma_receive_complete(struct ali_ircc_cb *self)
 			skb_reset_mac_header(skb);
 			skb->protocol = htons(ETH_P_IRDA);
 			netif_rx(skb);
-			self->netdev->last_rx = jiffies;
 		}
 	}
 	
diff --git a/drivers/net/irda/au1k_ir.c b/drivers/net/irda/au1k_ir.c
index a1e4508..6c4b53f 100644
--- a/drivers/net/irda/au1k_ir.c
+++ b/drivers/net/irda/au1k_ir.c
@@ -620,7 +620,6 @@ static int au1k_irda_rx(struct net_device *dev)
 		/* next descriptor */
 		prxd = aup->rx_ring[aup->rx_head];
 		flags = prxd->flags;
-		dev->last_rx = jiffies;
 
 	}
 	return 0;
diff --git a/drivers/net/irda/irda-usb.c b/drivers/net/irda/irda-usb.c
index b5d6b9a..761ed8c 100644
--- a/drivers/net/irda/irda-usb.c
+++ b/drivers/net/irda/irda-usb.c
@@ -929,7 +929,6 @@ static void irda_usb_receive(struct urb *urb)
 	/* Keep stats up to date */
 	self->stats.rx_bytes += len;
 	self->stats.rx_packets++;
-	self->netdev->last_rx = jiffies;
 
 done:
 	/* Note : at this point, the URB we've just received (urb)
diff --git a/drivers/net/irda/kingsun-sir.c b/drivers/net/irda/kingsun-sir.c
index e1429fc..c747c87 100644
--- a/drivers/net/irda/kingsun-sir.c
+++ b/drivers/net/irda/kingsun-sir.c
@@ -235,7 +235,6 @@ static void kingsun_rcv_irq(struct urb *urb)
 						  &kingsun->stats,
 						  &kingsun->rx_buff, bytes[i]);
 			}
-			kingsun->netdev->last_rx = jiffies;
 			do_gettimeofday(&kingsun->rx_time);
 			kingsun->receiving =
 				(kingsun->rx_buff.state != OUTSIDE_FRAME)
diff --git a/drivers/net/irda/ks959-sir.c b/drivers/net/irda/ks959-sir.c
index 2482d61..f59d5b6 100644
--- a/drivers/net/irda/ks959-sir.c
+++ b/drivers/net/irda/ks959-sir.c
@@ -475,7 +475,6 @@ static void ks959_rcv_irq(struct urb *urb)
 						  bytes[i]);
 			}
 		}
-		kingsun->netdev->last_rx = jiffies;
 		do_gettimeofday(&kingsun->rx_time);
 		kingsun->receiving =
 		    (kingsun->rx_unwrap_buff.state != OUTSIDE_FRAME) ? 1 : 0;
diff --git a/drivers/net/irda/ksdazzle-sir.c b/drivers/net/irda/ksdazzle-sir.c
index 1e0de93..6c39f3f 100644
--- a/drivers/net/irda/ksdazzle-sir.c
+++ b/drivers/net/irda/ksdazzle-sir.c
@@ -372,7 +372,6 @@ static void ksdazzle_rcv_irq(struct urb *urb)
 			async_unwrap_char(kingsun->netdev, &kingsun->stats,
 					  &kingsun->rx_unwrap_buff, bytes[i]);
 		}
-		kingsun->netdev->last_rx = jiffies;
 		kingsun->receiving =
 		    (kingsun->rx_unwrap_buff.state != OUTSIDE_FRAME) ? 1 : 0;
 	}
diff --git a/drivers/net/irda/mcs7780.c b/drivers/net/irda/mcs7780.c
index ad92d3f..904c961 100644
--- a/drivers/net/irda/mcs7780.c
+++ b/drivers/net/irda/mcs7780.c
@@ -806,7 +806,6 @@ static void mcs_receive_irq(struct urb *urb)
 			mcs_unwrap_fir(mcs, urb->transfer_buffer,
 				urb->actual_length);
 		}
-		mcs->netdev->last_rx = jiffies;
 		do_gettimeofday(&mcs->rx_time);
 	}
 
diff --git a/drivers/net/irda/nsc-ircc.c b/drivers/net/irda/nsc-ircc.c
index 8583d95..4e1bc08 100644
--- a/drivers/net/irda/nsc-ircc.c
+++ b/drivers/net/irda/nsc-ircc.c
@@ -1896,7 +1896,6 @@ static int nsc_ircc_dma_receive_complete(struct nsc_ircc_cb *self, int iobase)
 			skb_reset_mac_header(skb);
 			skb->protocol = htons(ETH_P_IRDA);
 			netif_rx(skb);
-			self->netdev->last_rx = jiffies;
 		}
 	}
 	/* Restore bank register */
diff --git a/drivers/net/irda/pxaficp_ir.c b/drivers/net/irda/pxaficp_ir.c
index c5b02b6..a0ee053 100644
--- a/drivers/net/irda/pxaficp_ir.c
+++ b/drivers/net/irda/pxaficp_ir.c
@@ -225,7 +225,6 @@ static irqreturn_t pxa_irda_sir_irq(int irq, void *dev_id)
 			}
 			lsr = STLSR;
 		}
-		dev->last_rx = jiffies;
 		si->last_oscr = OSCR;
 		break;
 
@@ -237,7 +236,6 @@ static irqreturn_t pxa_irda_sir_irq(int irq, void *dev_id)
 		    si->stats.rx_bytes++;
 	            async_unwrap_char(dev, &si->stats, &si->rx_buff, STRBR);
 	  	} while (STLSR & LSR_DR);
-	  	dev->last_rx = jiffies;
 		si->last_oscr = OSCR;
 	  	break;
 
@@ -397,8 +395,6 @@ static void pxa_irda_fir_irq_eif(struct pxa_irda *si, struct net_device *dev, in
 
 		si->stats.rx_packets++;
 		si->stats.rx_bytes += len;
-
-		dev->last_rx = jiffies;
 	}
 }
 
diff --git a/drivers/net/irda/sa1100_ir.c b/drivers/net/irda/sa1100_ir.c
index a951889..aa6fef8 100644
--- a/drivers/net/irda/sa1100_ir.c
+++ b/drivers/net/irda/sa1100_ir.c
@@ -410,7 +410,6 @@ static void sa1100_irda_hpsir_irq(struct net_device *dev)
 					  Ser2UTDR);
 		} while (Ser2UTSR1 & UTSR1_RNE);
 
-		dev->last_rx = jiffies;
 	}
 
 	if (status & UTSR0_TFS && si->tx_buff.len) {
@@ -515,7 +514,6 @@ static void sa1100_irda_fir_error(struct sa1100_irda *si, struct net_device *dev
 		sa1100_irda_rx_alloc(si);
 
 		netif_rx(skb);
-		dev->last_rx = jiffies;
 	} else {
 		/*
 		 * Remap the buffer.
diff --git a/drivers/net/irda/stir4200.c b/drivers/net/irda/stir4200.c
index 3575804..ca4cd92 100644
--- a/drivers/net/irda/stir4200.c
+++ b/drivers/net/irda/stir4200.c
@@ -824,7 +824,6 @@ static void stir_rcv_irq(struct urb *urb)
 		unwrap_chars(stir, urb->transfer_buffer,
 			     urb->actual_length);
 		
-		stir->netdev->last_rx = jiffies;
 		do_gettimeofday(&stir->rx_time);
 	}
 
diff --git a/drivers/net/irda/vlsi_ir.c b/drivers/net/irda/vlsi_ir.c
index 9c926d2..a3d27d7 100644
--- a/drivers/net/irda/vlsi_ir.c
+++ b/drivers/net/irda/vlsi_ir.c
@@ -600,7 +600,6 @@ static int vlsi_process_rx(struct vlsi_ring *r, struct ring_descr *rd)
 		netif_rx(skb);
 	else
 		netif_rx_ni(skb);
-	ndev->last_rx = jiffies;
 
 done:
 	rd_set_status(rd, 0);
diff --git a/drivers/net/irda/w83977af_ir.c b/drivers/net/irda/w83977af_ir.c
index 002a6d7..fa60020 100644
--- a/drivers/net/irda/w83977af_ir.c
+++ b/drivers/net/irda/w83977af_ir.c
@@ -923,7 +923,6 @@ int w83977af_dma_receive_complete(struct w83977af_ir *self)
 			skb_reset_mac_header(skb);
 			skb->protocol = htons(ETH_P_IRDA);
 			netif_rx(skb);
-			self->netdev->last_rx = jiffies;
 		}
 	}
 	/* Restore set register */
diff --git a/drivers/net/isa-skeleton.c b/drivers/net/isa-skeleton.c
index 1c8d72b..15ebae9 100644
--- a/drivers/net/isa-skeleton.c
+++ b/drivers/net/isa-skeleton.c
@@ -583,7 +583,6 @@ net_rx(struct net_device *dev)
 			insw(ioaddr, skb->data, (pkt_len + 1) >> 1);
 
 			netif_rx(skb);
-			dev->last_rx = jiffies;
 			lp->stats.rx_packets++;
 			lp->stats.rx_bytes += pkt_len;
 		}
diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index 21995df..cb7d1a6 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -1980,7 +1980,6 @@ ixgb_clean_rx_irq(struct ixgb_adapter *adapter, int *work_done, int work_to_do)
 		} else {
 			netif_receive_skb(skb);
 		}
-		netdev->last_rx = jiffies;
 
 rxdesc_done:
 		/* clean up descriptor, might be written over by hw */
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 2a12e97..b3be579 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -668,7 +668,6 @@ static bool ixgbe_clean_rx_irq(struct ixgbe_adapter *adapter,
 
 		skb->protocol = eth_type_trans(skb, adapter->netdev);
 		ixgbe_receive_skb(adapter, skb, staterr, rx_ring, rx_desc);
-		adapter->netdev->last_rx = jiffies;
 
 next_desc:
 		rx_desc->wb.upper.status_error = 0;
diff --git a/drivers/net/ixp2000/ixpdev.c b/drivers/net/ixp2000/ixpdev.c
index 7b70c66..bd96dbc 100644
--- a/drivers/net/ixp2000/ixpdev.c
+++ b/drivers/net/ixp2000/ixpdev.c
@@ -114,8 +114,6 @@ static int ixpdev_rx(struct net_device *dev, int processed, int budget)
 			skb_put(skb, desc->pkt_length);
 			skb->protocol = eth_type_trans(skb, nds[desc->channel]);
 
-			dev->last_rx = jiffies;
-
 			netif_receive_skb(skb);
 		}
 
diff --git a/drivers/net/jme.c b/drivers/net/jme.c
index a10c687..0796d0b 100644
--- a/drivers/net/jme.c
+++ b/drivers/net/jme.c
@@ -931,7 +931,6 @@ jme_alloc_and_feed_skb(struct jme_adapter *jme, int idx)
 				RXWBFLAG_DEST_MUL)
 			++(NET_STAT(jme).multicast);
 
-		jme->dev->last_rx = jiffies;
 		NET_STAT(jme).rx_bytes += framesize;
 		++(NET_STAT(jme).rx_packets);
 	}
diff --git a/drivers/net/korina.c b/drivers/net/korina.c
index e185763..6362695 100644
--- a/drivers/net/korina.c
+++ b/drivers/net/korina.c
@@ -409,7 +409,6 @@ static int korina_rx(struct net_device *dev, int limit)
 
 				/* Pass the packet to upper layers */
 				netif_receive_skb(skb);
-				dev->last_rx = jiffies;
 				dev->stats.rx_packets++;
 				dev->stats.rx_bytes += pkt_len;
 
diff --git a/drivers/net/lance.c b/drivers/net/lance.c
index 4ab536d..f63789a 100644
--- a/drivers/net/lance.c
+++ b/drivers/net/lance.c
@@ -1190,7 +1190,6 @@ lance_rx(struct net_device *dev)
 					pkt_len);
 				skb->protocol=eth_type_trans(skb,dev);
 				netif_rx(skb);
-				dev->last_rx = jiffies;
 				lp->stats.rx_packets++;
 				lp->stats.rx_bytes+=pkt_len;
 			}
diff --git a/drivers/net/lib82596.c b/drivers/net/lib82596.c
index cc8f641..7415f51 100644
--- a/drivers/net/lib82596.c
+++ b/drivers/net/lib82596.c
@@ -739,7 +739,6 @@ memory_squeeze:
 				skb->len = pkt_len;
 				skb->protocol = eth_type_trans(skb, dev);
 				netif_rx(skb);
-				dev->last_rx = jiffies;
 				dev->stats.rx_packets++;
 				dev->stats.rx_bytes += pkt_len;
 			}
diff --git a/drivers/net/lib8390.c b/drivers/net/lib8390.c
index f80dcc1..9430167 100644
--- a/drivers/net/lib8390.c
+++ b/drivers/net/lib8390.c
@@ -764,7 +764,6 @@ static void ei_receive(struct net_device *dev)
 				ei_block_input(dev, pkt_len, skb, current_offset + sizeof(rx_frame));
 				skb->protocol=eth_type_trans(skb,dev);
 				netif_rx(skb);
-				dev->last_rx = jiffies;
 				dev->stats.rx_packets++;
 				dev->stats.rx_bytes += pkt_len;
 				if (pkt_stat & ENRSR_PHY)
diff --git a/drivers/net/loopback.c b/drivers/net/loopback.c
index b1ac63a..91d0858 100644
--- a/drivers/net/loopback.c
+++ b/drivers/net/loopback.c
@@ -76,8 +76,6 @@ static int loopback_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	skb->protocol = eth_type_trans(skb,dev);
 
-	dev->last_rx = jiffies;
-
 	/* it's OK to use per_cpu_ptr() because BHs are off */
 	pcpu_lstats = dev->ml_priv;
 	lb_stats = per_cpu_ptr(pcpu_lstats, smp_processor_id());
diff --git a/drivers/net/lp486e.c b/drivers/net/lp486e.c
index 83fa9d8..d6b0036 100644
--- a/drivers/net/lp486e.c
+++ b/drivers/net/lp486e.c
@@ -676,7 +676,6 @@ i596_rx_one(struct net_device *dev, struct i596_private *lp,
 
 		skb->protocol = eth_type_trans(skb,dev);
 		netif_rx(skb);
-		dev->last_rx = jiffies;
 		dev->stats.rx_packets++;
 	} else {
 #if 0
diff --git a/drivers/net/mac89x0.c b/drivers/net/mac89x0.c
index ca9c5a8..2ee477c 100644
--- a/drivers/net/mac89x0.c
+++ b/drivers/net/mac89x0.c
@@ -516,7 +516,6 @@ net_rx(struct net_device *dev)
 
         skb->protocol=eth_type_trans(skb,dev);
 	netif_rx(skb);
-	dev->last_rx = jiffies;
 	lp->stats.rx_packets++;
 	lp->stats.rx_bytes += length;
 }
diff --git a/drivers/net/macb.c b/drivers/net/macb.c
index e00c896..261b950 100644
--- a/drivers/net/macb.c
+++ b/drivers/net/macb.c
@@ -435,7 +435,6 @@ static int macb_rx_frame(struct macb *bp, unsigned int first_frag,
 
 	bp->stats.rx_packets++;
 	bp->stats.rx_bytes += len;
-	bp->dev->last_rx = jiffies;
 	dev_dbg(&bp->pdev->dev, "received skb of length %u, csum: %08x\n",
 		skb->len, skb->csum);
 	netif_receive_skb(skb);
diff --git a/drivers/net/mace.c b/drivers/net/mace.c
index a2021c0..b52f050 100644
--- a/drivers/net/mace.c
+++ b/drivers/net/mace.c
@@ -928,7 +928,6 @@ static irqreturn_t mace_rxdma_intr(int irq, void *dev_id)
 		skb->protocol = eth_type_trans(skb, dev);
 		dev->stats.rx_bytes += skb->len;
 		netif_rx(skb);
-		dev->last_rx = jiffies;
 		mp->rx_bufs[i] = NULL;
 		++dev->stats.rx_packets;
 	    }
diff --git a/drivers/net/macmace.c b/drivers/net/macmace.c
index 0b28318..274e99b 100644
--- a/drivers/net/macmace.c
+++ b/drivers/net/macmace.c
@@ -673,7 +673,6 @@ static void mace_dma_rx_frame(struct net_device *dev, struct mace_frame *mf)
 
 		skb->protocol = eth_type_trans(skb, dev);
 		netif_rx(skb);
-		dev->last_rx = jiffies;
 		dev->stats.rx_packets++;
 		dev->stats.rx_bytes += frame_length;
 	}
diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 1d2de0b..cabde9a 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -84,7 +84,6 @@ static void macvlan_broadcast(struct sk_buff *skb,
 			dev->stats.rx_bytes += skb->len + ETH_HLEN;
 			dev->stats.rx_packets++;
 			dev->stats.multicast++;
-			dev->last_rx = jiffies;
 
 			nskb->dev = dev;
 			if (!compare_ether_addr(eth->h_dest, dev->broadcast))
@@ -133,7 +132,6 @@ static struct sk_buff *macvlan_handle_frame(struct sk_buff *skb)
 
 	dev->stats.rx_bytes += skb->len + ETH_HLEN;
 	dev->stats.rx_packets++;
-	dev->last_rx = jiffies;
 
 	skb->dev = dev;
 	skb->pkt_type = PACKET_HOST;
diff --git a/drivers/net/meth.c b/drivers/net/meth.c
index 621133b..c336a1f 100644
--- a/drivers/net/meth.c
+++ b/drivers/net/meth.c
@@ -420,7 +420,6 @@ static void meth_rx(struct net_device* dev, unsigned long int_status)
 					skb_put(skb_c, len);
 					priv->rx_skbs[priv->rx_write] = skb;
 					skb_c->protocol = eth_type_trans(skb_c, dev);
-					dev->last_rx = jiffies;
 					dev->stats.rx_packets++;
 					dev->stats.rx_bytes += len;
 					netif_rx(skb_c);
diff --git a/drivers/net/mlx4/en_rx.c b/drivers/net/mlx4/en_rx.c
index 6232227..944ad47 100644
--- a/drivers/net/mlx4/en_rx.c
+++ b/drivers/net/mlx4/en_rx.c
@@ -776,8 +776,6 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 		} else
 			netif_receive_skb(skb);
 
-		dev->last_rx = jiffies;
-
 next:
 		++cq->mcq.cons_index;
 		index = (cq->mcq.cons_index) & ring->size_mask;
diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index 3a759d0..e521d2c 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -557,8 +557,6 @@ static int rxq_process(struct rx_queue *rxq, int budget)
 			skb->protocol = eth_type_trans(skb, mp->dev);
 			netif_receive_skb(skb);
 		}
-
-		mp->dev->last_rx = jiffies;
 	}
 
 	if (rx < budget)
diff --git a/drivers/net/myri10ge/myri10ge.c b/drivers/net/myri10ge/myri10ge.c
index d2cbc7d..72afe0a 100644
--- a/drivers/net/myri10ge/myri10ge.c
+++ b/drivers/net/myri10ge/myri10ge.c
@@ -1334,7 +1334,6 @@ myri10ge_rx_done(struct myri10ge_slice_state *ss, struct myri10ge_rx_buf *rx,
 			myri10ge_vlan_ip_csum(skb, csum);
 	}
 	netif_receive_skb(skb);
-	dev->last_rx = jiffies;
 	return 1;
 }
 
diff --git a/drivers/net/myri_sbus.c b/drivers/net/myri_sbus.c
index 1bbdde1..a78d4b9 100644
--- a/drivers/net/myri_sbus.c
+++ b/drivers/net/myri_sbus.c
@@ -525,7 +525,6 @@ static void myri_rx(struct myri_eth *mp, struct net_device *dev)
 		DRX(("prot[%04x] netif_rx ", skb->protocol));
 		netif_rx(skb);
 
-		dev->last_rx = jiffies;
 		dev->stats.rx_packets++;
 		dev->stats.rx_bytes += len;
 	next:
diff --git a/drivers/net/natsemi.c b/drivers/net/natsemi.c
index 5f1de80..9f81fcb 100644
--- a/drivers/net/natsemi.c
+++ b/drivers/net/natsemi.c
@@ -2361,7 +2361,6 @@ static void netdev_rx(struct net_device *dev, int *work_done, int work_to_do)
 			}
 			skb->protocol = eth_type_trans(skb, dev);
 			netif_receive_skb(skb);
-			dev->last_rx = jiffies;
 			np->stats.rx_packets++;
 			np->stats.rx_bytes += pkt_len;
 		}
diff --git a/drivers/net/netx-eth.c b/drivers/net/netx-eth.c
index b9bed82..b418771 100644
--- a/drivers/net/netx-eth.c
+++ b/drivers/net/netx-eth.c
@@ -165,7 +165,6 @@ static void netx_eth_receive(struct net_device *ndev)
 	pfifo_push(EMPTY_PTR_FIFO(priv->id),
 		FIFO_PTR_SEGMENT(seg) | FIFO_PTR_FRAMENO(frameno));
 
-	ndev->last_rx = jiffies;
 	skb->protocol = eth_type_trans(skb, ndev);
 	netif_rx(skb);
 	ndev->stats.rx_packets++;
diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
index 5bba675..d924468 100644
--- a/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@ -1285,9 +1285,7 @@ static void netxen_process_rcv(struct netxen_adapter *adapter, int ctxid,
 		}
 		adapter->stats.rxdropped++;
 	} else {
-
 		netif_receive_skb(skb);
-		netdev->last_rx = jiffies;
 
 		adapter->stats.no_rcv++;
 		adapter->stats.rxbytes += length;
diff --git a/drivers/net/ni5010.c b/drivers/net/ni5010.c
index e88ec8a..6c11557 100644
--- a/drivers/net/ni5010.c
+++ b/drivers/net/ni5010.c
@@ -569,7 +569,6 @@ static void ni5010_rx(struct net_device *dev)
 
 	skb->protocol = eth_type_trans(skb,dev);
 	netif_rx(skb);
-	dev->last_rx = jiffies;
 	dev->stats.rx_packets++;
 	dev->stats.rx_bytes += i_pkt_size;
 
diff --git a/drivers/net/ni52.c b/drivers/net/ni52.c
index b9a882d..6d7cf3c 100644
--- a/drivers/net/ni52.c
+++ b/drivers/net/ni52.c
@@ -970,7 +970,6 @@ static void ni52_rcv_int(struct net_device *dev)
 					memcpy_fromio(skb->data, p->base + readl(&rbd->buffer), totlen);
 					skb->protocol = eth_type_trans(skb, dev);
 					netif_rx(skb);
-					dev->last_rx = jiffies;
 					p->stats.rx_packets++;
 					p->stats.rx_bytes += totlen;
 				} else
diff --git a/drivers/net/ni65.c b/drivers/net/ni65.c
index 3edc971..24e393b 100644
--- a/drivers/net/ni65.c
+++ b/drivers/net/ni65.c
@@ -1113,7 +1113,6 @@ static void ni65_recv_intr(struct net_device *dev,int csr0)
 				p->stats.rx_bytes += len;
 				skb->protocol=eth_type_trans(skb,dev);
 				netif_rx(skb);
-				dev->last_rx = jiffies;
 			}
 			else
 			{
diff --git a/drivers/net/niu.c b/drivers/net/niu.c
index f927bc0..0d83384 100644
--- a/drivers/net/niu.c
+++ b/drivers/net/niu.c
@@ -3139,8 +3139,6 @@ static int niu_process_rx_pkt(struct niu *np, struct rx_ring_info *rp)
 	skb->protocol = eth_type_trans(skb, np->dev);
 	netif_receive_skb(skb);
 
-	np->dev->last_rx = jiffies;
-
 	return num_rcr;
 }
 
diff --git a/drivers/net/pci-skeleton.c b/drivers/net/pci-skeleton.c
index bf952ac..b23b5c3 100644
--- a/drivers/net/pci-skeleton.c
+++ b/drivers/net/pci-skeleton.c
@@ -1565,7 +1565,6 @@ static void netdrv_rx_interrupt (struct net_device *dev,
 
 			skb->protocol = eth_type_trans (skb, dev);
 			netif_rx (skb);
-			dev->last_rx = jiffies;
 			dev->stats.rx_bytes += pkt_size;
 			dev->stats.rx_packets++;
 		} else {
diff --git a/drivers/net/pcmcia/3c574_cs.c b/drivers/net/pcmcia/3c574_cs.c
index dcbb11a..e5cb6b1 100644
--- a/drivers/net/pcmcia/3c574_cs.c
+++ b/drivers/net/pcmcia/3c574_cs.c
@@ -1061,7 +1061,6 @@ static int el3_rx(struct net_device *dev, int worklimit)
 						((pkt_len+3)>>2));
 				skb->protocol = eth_type_trans(skb, dev);
 				netif_rx(skb);
-				dev->last_rx = jiffies;
 				dev->stats.rx_packets++;
 				dev->stats.rx_bytes += pkt_len;
 			} else {
diff --git a/drivers/net/pcmcia/3c589_cs.c b/drivers/net/pcmcia/3c589_cs.c
index 5882109..73ecc65 100644
--- a/drivers/net/pcmcia/3c589_cs.c
+++ b/drivers/net/pcmcia/3c589_cs.c
@@ -883,7 +883,6 @@ static int el3_rx(struct net_device *dev)
 			(pkt_len+3)>>2);
 		skb->protocol = eth_type_trans(skb, dev);
 		netif_rx(skb);
-		dev->last_rx = jiffies;
 		dev->stats.rx_packets++;
 		dev->stats.rx_bytes += pkt_len;
 	    } else {
diff --git a/drivers/net/pcmcia/axnet_cs.c b/drivers/net/pcmcia/axnet_cs.c
index 889f1bd..2aca8df 100644
--- a/drivers/net/pcmcia/axnet_cs.c
+++ b/drivers/net/pcmcia/axnet_cs.c
@@ -1492,7 +1492,6 @@ static void ei_receive(struct net_device *dev)
 				ei_block_input(dev, pkt_len, skb, current_offset + sizeof(rx_frame));
 				skb->protocol=eth_type_trans(skb,dev);
 				netif_rx(skb);
-				dev->last_rx = jiffies;
 				dev->stats.rx_packets++;
 				dev->stats.rx_bytes += pkt_len;
 				if (pkt_stat & ENRSR_PHY)
diff --git a/drivers/net/pcmcia/fmvj18x_cs.c b/drivers/net/pcmcia/fmvj18x_cs.c
index 465e4ad..e4f8fe3 100644
--- a/drivers/net/pcmcia/fmvj18x_cs.c
+++ b/drivers/net/pcmcia/fmvj18x_cs.c
@@ -1035,7 +1035,6 @@ static void fjn_rx(struct net_device *dev)
 #endif
 
 	    netif_rx(skb);
-	    dev->last_rx = jiffies;
 	    lp->stats.rx_packets++;
 	    lp->stats.rx_bytes += pkt_len;
 	}
diff --git a/drivers/net/pcmcia/nmclan_cs.c b/drivers/net/pcmcia/nmclan_cs.c
index 35a1d10..ec7c588 100644
--- a/drivers/net/pcmcia/nmclan_cs.c
+++ b/drivers/net/pcmcia/nmclan_cs.c
@@ -1192,7 +1192,6 @@ static int mace_rx(struct net_device *dev, unsigned char RxCnt)
 	
 	netif_rx(skb); /* Send the packet to the upper (protocol) layers. */
 
-	dev->last_rx = jiffies;
 	lp->linux_stats.rx_packets++;
 	lp->linux_stats.rx_bytes += pkt_len;
 	outb(0xFF, ioaddr + AM2150_RCV_NEXT); /* skip to next frame */
diff --git a/drivers/net/pcmcia/xirc2ps_cs.c b/drivers/net/pcmcia/xirc2ps_cs.c
index c45c306..fef7e18 100644
--- a/drivers/net/pcmcia/xirc2ps_cs.c
+++ b/drivers/net/pcmcia/xirc2ps_cs.c
@@ -1242,7 +1242,6 @@ xirc2ps_interrupt(int irq, void *dev_id)
 		}
 		skb->protocol = eth_type_trans(skb, dev);
 		netif_rx(skb);
-		dev->last_rx = jiffies;
 		lp->stats.rx_packets++;
 		lp->stats.rx_bytes += pktlen;
 		if (!(rsr & PhyPkt))
diff --git a/drivers/net/pcnet32.c b/drivers/net/pcnet32.c
index 15bf6fe..f2b192c 100644
--- a/drivers/net/pcnet32.c
+++ b/drivers/net/pcnet32.c
@@ -1246,7 +1246,6 @@ static void pcnet32_rx_entry(struct net_device *dev,
 	dev->stats.rx_bytes += skb->len;
 	skb->protocol = eth_type_trans(skb, dev);
 	netif_receive_skb(skb);
-	dev->last_rx = jiffies;
 	dev->stats.rx_packets++;
 	return;
 }
diff --git a/drivers/net/plip.c b/drivers/net/plip.c
index 1e96542..2ea78e6 100644
--- a/drivers/net/plip.c
+++ b/drivers/net/plip.c
@@ -664,7 +664,6 @@ plip_receive_packet(struct net_device *dev, struct net_local *nl,
 		/* Inform the upper layer for the arrival of a packet. */
 		rcv->skb->protocol=plip_type_trans(rcv->skb, dev);
 		netif_rx_ni(rcv->skb);
-		dev->last_rx = jiffies;
 		dev->stats.rx_bytes += rcv->length.h;
 		dev->stats.rx_packets++;
 		rcv->skb = NULL;
diff --git a/drivers/net/ppp_generic.c b/drivers/net/ppp_generic.c
index 7e857e9..274d495 100644
--- a/drivers/net/ppp_generic.c
+++ b/drivers/net/ppp_generic.c
@@ -1684,7 +1684,6 @@ ppp_receive_nonmp_frame(struct ppp *ppp, struct sk_buff *skb)
 			skb->protocol = htons(npindex_to_ethertype[npi]);
 			skb_reset_mac_header(skb);
 			netif_rx(skb);
-			ppp->dev->last_rx = jiffies;
 		}
 	}
 	return;
diff --git a/drivers/net/qla3xxx.c b/drivers/net/qla3xxx.c
index acf8dc5..8b41242 100644
--- a/drivers/net/qla3xxx.c
+++ b/drivers/net/qla3xxx.c
@@ -2136,7 +2136,6 @@ static void ql_process_mac_rx_intr(struct ql3_adapter *qdev,
 	skb->protocol = eth_type_trans(skb, qdev->ndev);
 
 	netif_receive_skb(skb);
-	qdev->ndev->last_rx = jiffies;
 	lrg_buf_cb2->skb = NULL;
 
 	if (qdev->device_id == QL3022_DEVICE_ID)
@@ -2210,7 +2209,6 @@ static void ql_process_macip_rx_intr(struct ql3_adapter *qdev,
 	netif_receive_skb(skb2);
 	ndev->stats.rx_packets++;
 	ndev->stats.rx_bytes += length;
-	ndev->last_rx = jiffies;
 	lrg_buf_cb2->skb = NULL;
 
 	if (qdev->device_id == QL3022_DEVICE_ID)
diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index 6445d2c..3a6d3ac 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -1451,7 +1451,6 @@ static void ql_process_mac_rx_intr(struct ql_adapter *qdev,
 			"Passing a normal packet upstream.\n");
 		netif_rx(skb);
 	}
-	ndev->last_rx = jiffies;
 }
 
 /* Process an outbound completion from an rx ring. */
diff --git a/drivers/net/r6040.c b/drivers/net/r6040.c
index 34fe7ef..d9a6e92 100644
--- a/drivers/net/r6040.c
+++ b/drivers/net/r6040.c
@@ -598,7 +598,6 @@ static int r6040_rx(struct net_device *dev, int limit)
 		
 		/* Send to upper layer */
 		netif_receive_skb(skb_ptr);
-		dev->last_rx = jiffies;
 		dev->stats.rx_packets++;
 		dev->stats.rx_bytes += descptr->len - 4;
 
diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 4b7cb38..cb5042e 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -3484,7 +3484,6 @@ static int rtl8169_rx_interrupt(struct net_device *dev,
 			if (rtl8169_rx_vlan_skb(tp, desc, skb) < 0)
 				netif_receive_skb(skb);
 
-			dev->last_rx = jiffies;
 			dev->stats.rx_bytes += pkt_size;
 			dev->stats.rx_packets++;
 		}
diff --git a/drivers/net/rrunner.c b/drivers/net/rrunner.c
index 7343291..6e4131f 100644
--- a/drivers/net/rrunner.c
+++ b/drivers/net/rrunner.c
@@ -1005,7 +1005,6 @@ static void rx_int(struct net_device *dev, u32 rxlimit, u32 index)
 
 			netif_rx(skb);		/* send it up */
 
-			dev->last_rx = jiffies;
 			dev->stats.rx_packets++;
 			dev->stats.rx_bytes += pkt_len;
 		}
diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index 5663fa7..cec9fe0 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -7544,7 +7544,6 @@ static int rx_osm_handler(struct ring_info *ring_data, struct RxD_t * rxdp)
 	sp->mac_control.stats_info->sw_stat.mem_freed += skb->truesize;
 send_up:
 	queue_rx_frame(skb, RXD_GET_VLAN_TAG(rxdp->Control_2));
-	dev->last_rx = jiffies;
 aggregate:
 	sp->mac_control.rings[ring_no].rx_bufs_left -= 1;
 	return SUCCESS;
diff --git a/drivers/net/sb1000.c b/drivers/net/sb1000.c
index 5986cec..be30253 100644
--- a/drivers/net/sb1000.c
+++ b/drivers/net/sb1000.c
@@ -869,7 +869,6 @@ printk("cm0: IP identification: %02x%02x  fragment offset: %02x%02x\n", buffer[3
 	/* datagram completed: send to upper level */
 	skb_trim(skb, dlen);
 	netif_rx(skb);
-	dev->last_rx = jiffies;
 	stats->rx_bytes+=dlen;
 	stats->rx_packets++;
 	lp->rx_skb[ns] = NULL;
diff --git a/drivers/net/sc92031.c b/drivers/net/sc92031.c
index 61955f8..590f217 100644
--- a/drivers/net/sc92031.c
+++ b/drivers/net/sc92031.c
@@ -816,7 +816,6 @@ static void _sc92031_rx_tasklet(struct net_device *dev)
 		}
 
 		skb->protocol = eth_type_trans(skb, dev);
-		dev->last_rx = jiffies;
 		netif_rx(skb);
 
 		dev->stats.rx_bytes += pkt_size;
diff --git a/drivers/net/seeq8005.c b/drivers/net/seeq8005.c
index ad12e7f..2fbc8f1 100644
--- a/drivers/net/seeq8005.c
+++ b/drivers/net/seeq8005.c
@@ -563,7 +563,6 @@ static void seeq8005_rx(struct net_device *dev)
 
 			skb->protocol=eth_type_trans(skb,dev);
 			netif_rx(skb);
-			dev->last_rx = jiffies;
 			dev->stats.rx_packets++;
 			dev->stats.rx_bytes += pkt_len;
 		}
diff --git a/drivers/net/sfc/rx.c b/drivers/net/sfc/rx.c
index 0f805da..b8ba4bb 100644
--- a/drivers/net/sfc/rx.c
+++ b/drivers/net/sfc/rx.c
@@ -752,7 +752,7 @@ void __efx_rx_packet(struct efx_channel *channel,
 	channel->rx_alloc_level += RX_ALLOC_FACTOR_SKB;
 
 done:
-	efx->net_dev->last_rx = jiffies;
+	;
 }
 
 void efx_rx_strategy(struct efx_channel *channel)
diff --git a/drivers/net/sgiseeq.c b/drivers/net/sgiseeq.c
index ffc700e..cdffea6 100644
--- a/drivers/net/sgiseeq.c
+++ b/drivers/net/sgiseeq.c
@@ -377,7 +377,6 @@ memory_squeeze:
 					skb_put(skb, len);
 					skb->protocol = eth_type_trans(skb, dev);
 					netif_rx(skb);
-					dev->last_rx = jiffies;
 					dev->stats.rx_packets++;
 					dev->stats.rx_bytes += len;
 				} else {
diff --git a/drivers/net/sh_eth.c b/drivers/net/sh_eth.c
index a24bb68..c51bfc5 100644
--- a/drivers/net/sh_eth.c
+++ b/drivers/net/sh_eth.c
@@ -540,7 +540,6 @@ static int sh_eth_rx(struct net_device *ndev)
 			skb_put(skb, pkt_len);
 			skb->protocol = eth_type_trans(skb, ndev);
 			netif_rx(skb);
-			ndev->last_rx = jiffies;
 			mdp->stats.rx_packets++;
 			mdp->stats.rx_bytes += pkt_len;
 		}
diff --git a/drivers/net/sis190.c b/drivers/net/sis190.c
index f6c8f70..83cc3c5 100644
--- a/drivers/net/sis190.c
+++ b/drivers/net/sis190.c
@@ -627,7 +627,6 @@ static int sis190_rx_interrupt(struct net_device *dev,
 
 			sis190_rx_skb(skb);
 
-			dev->last_rx = jiffies;
 			stats->rx_packets++;
 			stats->rx_bytes += pkt_size;
 			if ((status & BCAST) == MCAST)
diff --git a/drivers/net/sis900.c b/drivers/net/sis900.c
index bb7056a..28f6c04 100644
--- a/drivers/net/sis900.c
+++ b/drivers/net/sis900.c
@@ -1789,7 +1789,6 @@ static int sis900_rx(struct net_device *net_dev)
 			/* some network statistics */
 			if ((rx_status & BCAST) == MCAST)
 				net_dev->stats.multicast++;
-			net_dev->last_rx = jiffies;
 			net_dev->stats.rx_bytes += rx_size;
 			net_dev->stats.rx_packets++;
 			sis_priv->dirty_rx++;
diff --git a/drivers/net/skfp/skfddi.c b/drivers/net/skfp/skfddi.c
index a2b092b..282bb47 100644
--- a/drivers/net/skfp/skfddi.c
+++ b/drivers/net/skfp/skfddi.c
@@ -1680,7 +1680,6 @@ void mac_drv_rx_complete(struct s_smc *smc, volatile struct s_smt_fp_rxd *rxd,
 	skb->protocol = fddi_type_trans(skb, bp->dev);
 
 	netif_rx(skb);
-	bp->dev->last_rx = jiffies;
 
 	HWM_RX_CHECK(smc, RX_LOW_WATERMARK);
 	return;
@@ -1939,7 +1938,6 @@ int mac_drv_rx_init(struct s_smc *smc, int len, int fc,
 
 	// deliver frame to system
 	skb->protocol = fddi_type_trans(skb, smc->os.dev);
-	skb->dev->last_rx = jiffies;
 	netif_rx(skb);
 
 	return (0);
diff --git a/drivers/net/skge.c b/drivers/net/skge.c
index 7911839..05f9d50 100644
--- a/drivers/net/skge.c
+++ b/drivers/net/skge.c
@@ -3186,7 +3186,6 @@ static int skge_poll(struct napi_struct *napi, int to_do)
 
 		skb = skge_rx_get(dev, e, control, rd->status, rd->csum2);
 		if (likely(skb)) {
-			dev->last_rx = jiffies;
 			netif_receive_skb(skb);
 
 			++work_done;
diff --git a/drivers/net/slip.c b/drivers/net/slip.c
index 1d58991..25cec06 100644
--- a/drivers/net/slip.c
+++ b/drivers/net/slip.c
@@ -365,7 +365,6 @@ static void sl_bump(struct slip *sl)
 	skb_reset_mac_header(skb);
 	skb->protocol = htons(ETH_P_IP);
 	netif_rx(skb);
-	sl->dev->last_rx = jiffies;
 	sl->rx_packets++;
 }
 
diff --git a/drivers/net/smc911x.c b/drivers/net/smc911x.c
index f59c777..a8cf006 100644
--- a/drivers/net/smc911x.c
+++ b/drivers/net/smc911x.c
@@ -439,7 +439,6 @@ static inline void	 smc911x_rcv(struct net_device *dev)
 
 		DBG(SMC_DEBUG_PKTS, "%s: Received packet\n", dev->name);
 		PRINT_PKT(data, ((pkt_len - 4) <= 64) ? pkt_len - 4 : 64);
-		dev->last_rx = jiffies;
 		skb->protocol = eth_type_trans(skb, dev);
 		netif_rx(skb);
 		dev->stats.rx_packets++;
@@ -1231,7 +1230,6 @@ smc911x_rx_dma_irq(int dma, void *data)
 	BUG_ON(skb == NULL);
 	lp->current_rx_skb = NULL;
 	PRINT_PKT(skb->data, skb->len);
-	dev->last_rx = jiffies;
 	skb->protocol = eth_type_trans(skb, dev);
 	dev->stats.rx_packets++;
 	dev->stats.rx_bytes += skb->len;
diff --git a/drivers/net/smc9194.c b/drivers/net/smc9194.c
index 3bc7336..e35fab1 100644
--- a/drivers/net/smc9194.c
+++ b/drivers/net/smc9194.c
@@ -1270,7 +1270,6 @@ static void smc_rcv(struct net_device *dev)
 
 		skb->protocol = eth_type_trans(skb, dev );
 		netif_rx(skb);
-		dev->last_rx = jiffies;
 		dev->stats.rx_packets++;
 		dev->stats.rx_bytes += packet_length;
 	} else {
diff --git a/drivers/net/smc91x.c b/drivers/net/smc91x.c
index b5ff632..2ca301d 100644
--- a/drivers/net/smc91x.c
+++ b/drivers/net/smc91x.c
@@ -518,7 +518,6 @@ static inline void  smc_rcv(struct net_device *dev)
 
 		PRINT_PKT(data, packet_len - 4);
 
-		dev->last_rx = jiffies;
 		skb->protocol = eth_type_trans(skb, dev);
 		netif_rx(skb);
 		dev->stats.rx_packets++;
diff --git a/drivers/net/sonic.c b/drivers/net/sonic.c
index 8069f3e..211e805 100644
--- a/drivers/net/sonic.c
+++ b/drivers/net/sonic.c
@@ -450,7 +450,6 @@ static void sonic_rx(struct net_device *dev)
 			skb_trim(used_skb, pkt_len);
 			used_skb->protocol = eth_type_trans(used_skb, dev);
 			netif_rx(used_skb);
-			dev->last_rx = jiffies;
 			lp->stats.rx_packets++;
 			lp->stats.rx_bytes += pkt_len;
 
diff --git a/drivers/net/starfire.c b/drivers/net/starfire.c
index 3281418..0358809 100644
--- a/drivers/net/starfire.c
+++ b/drivers/net/starfire.c
@@ -1496,7 +1496,6 @@ static int __netdev_rx(struct net_device *dev, int *quota)
 		} else
 #endif /* VLAN_SUPPORT */
 			netif_receive_skb(skb);
-		dev->last_rx = jiffies;
 		np->stats.rx_packets++;
 
 	next_rx:
diff --git a/drivers/net/sun3lance.c b/drivers/net/sun3lance.c
index 608aa2f..4bb8f72 100644
--- a/drivers/net/sun3lance.c
+++ b/drivers/net/sun3lance.c
@@ -849,7 +849,6 @@ static int lance_rx( struct net_device *dev )
 
 				skb->protocol = eth_type_trans( skb, dev );
 				netif_rx( skb );
-				dev->last_rx = jiffies;
 				dev->stats.rx_packets++;
 				dev->stats.rx_bytes += pkt_len;
 			}
diff --git a/drivers/net/sunbmac.c b/drivers/net/sunbmac.c
index e964395..3f57ba0 100644
--- a/drivers/net/sunbmac.c
+++ b/drivers/net/sunbmac.c
@@ -878,7 +878,6 @@ static void bigmac_rx(struct bigmac *bp)
 		/* No checksums done by the BigMAC ;-( */
 		skb->protocol = eth_type_trans(skb, bp->dev);
 		netif_rx(skb);
-		bp->dev->last_rx = jiffies;
 		bp->enet_stats.rx_packets++;
 		bp->enet_stats.rx_bytes += len;
 	next:
diff --git a/drivers/net/sundance.c b/drivers/net/sundance.c
index 8c6a894..698893b 100644
--- a/drivers/net/sundance.c
+++ b/drivers/net/sundance.c
@@ -1350,7 +1350,6 @@ static void rx_poll(unsigned long data)
 			skb->protocol = eth_type_trans(skb, dev);
 			/* Note: checksum -> skb->ip_summed = CHECKSUM_UNNECESSARY; */
 			netif_rx(skb);
-			dev->last_rx = jiffies;
 		}
 		entry = (entry + 1) % RX_RING_SIZE;
 		received++;
diff --git a/drivers/net/sungem.c b/drivers/net/sungem.c
index 250f086..deb1148 100644
--- a/drivers/net/sungem.c
+++ b/drivers/net/sungem.c
@@ -863,7 +863,6 @@ static int gem_rx(struct gem *gp, int work_to_do)
 
 		gp->net_stats.rx_packets++;
 		gp->net_stats.rx_bytes += len;
-		gp->dev->last_rx = jiffies;
 
 	next:
 		entry = NEXT_RX(entry);
diff --git a/drivers/net/sunhme.c b/drivers/net/sunhme.c
index b55f7a4..e55db66 100644
--- a/drivers/net/sunhme.c
+++ b/drivers/net/sunhme.c
@@ -2072,7 +2072,6 @@ static void happy_meal_rx(struct happy_meal *hp, struct net_device *dev)
 		skb->protocol = eth_type_trans(skb, dev);
 		netif_rx(skb);
 
-		dev->last_rx = jiffies;
 		hp->net_stats.rx_packets++;
 		hp->net_stats.rx_bytes += len;
 	next:
diff --git a/drivers/net/sunlance.c b/drivers/net/sunlance.c
index c67cf94..2813732 100644
--- a/drivers/net/sunlance.c
+++ b/drivers/net/sunlance.c
@@ -555,7 +555,6 @@ static void lance_rx_dvma(struct net_device *dev)
 					 len);
 			skb->protocol = eth_type_trans(skb, dev);
 			netif_rx(skb);
-			dev->last_rx = jiffies;
 			dev->stats.rx_packets++;
 		}
 
@@ -726,7 +725,6 @@ static void lance_rx_pio(struct net_device *dev)
 			lance_piocopy_to_skb(skb, &(ib->rx_buf[entry][0]), len);
 			skb->protocol = eth_type_trans(skb, dev);
 			netif_rx(skb);
-			dev->last_rx = jiffies;
 			dev->stats.rx_packets++;
 		}
 
diff --git a/drivers/net/sunqe.c b/drivers/net/sunqe.c
index f636447..8f1e7ff 100644
--- a/drivers/net/sunqe.c
+++ b/drivers/net/sunqe.c
@@ -446,7 +446,6 @@ static void qe_rx(struct sunqe *qep)
 						 len);
 				skb->protocol = eth_type_trans(skb, qep->dev);
 				netif_rx(skb);
-				qep->dev->last_rx = jiffies;
 				dev->stats.rx_packets++;
 				dev->stats.rx_bytes += len;
 			}
diff --git a/drivers/net/tc35815.c b/drivers/net/tc35815.c
index 51de139..44126c4 100644
--- a/drivers/net/tc35815.c
+++ b/drivers/net/tc35815.c
@@ -1757,7 +1757,6 @@ tc35815_rx(struct net_device *dev)
 #else
 			netif_rx(skb);
 #endif
-			dev->last_rx = jiffies;
 			dev->stats.rx_packets++;
 			dev->stats.rx_bytes += pkt_len;
 		} else {
diff --git a/drivers/net/tehuti.c b/drivers/net/tehuti.c
index 91f9054..30d5065 100644
--- a/drivers/net/tehuti.c
+++ b/drivers/net/tehuti.c
@@ -1237,7 +1237,6 @@ static int bdx_rx_receive(struct bdx_priv *priv, struct rxd_fifo *f, int budget)
 	ENTER;
 	max_done = budget;
 
-	priv->ndev->last_rx = jiffies;
 	f->m.wptr = READ_REG(priv, f->m.reg_WPTR) & TXF_WPTR_WR_PTR;
 
 	size = f->m.wptr - f->m.rptr;
diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index babf83d..546b9ee 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -4288,7 +4288,6 @@ static int tg3_rx(struct tg3 *tp, int budget)
 #endif
 			netif_receive_skb(skb);
 
-		tp->dev->last_rx = jiffies;
 		received++;
 		budget--;
 
diff --git a/drivers/net/tlan.c b/drivers/net/tlan.c
index c41d687..055d342 100644
--- a/drivers/net/tlan.c
+++ b/drivers/net/tlan.c
@@ -1649,8 +1649,6 @@ drop_and_reuse:
 		}
 	}
 
-	dev->last_rx = jiffies;
-
 	return ack;
 
 } /* TLan_HandleRxEOF */
diff --git a/drivers/net/tokenring/3c359.c b/drivers/net/tokenring/3c359.c
index bf62132..87509a6 100644
--- a/drivers/net/tokenring/3c359.c
+++ b/drivers/net/tokenring/3c359.c
@@ -974,7 +974,6 @@ static void xl_rx(struct net_device *dev)
 
 			netif_rx(skb2) ; 		
 		 } /* if multiple buffers */
-		dev->last_rx = jiffies ; 	
 	} /* while packet to do */
 
 	/* Clear the updComplete interrupt */
@@ -1571,7 +1570,6 @@ static void xl_arb_cmd(struct net_device *dev)
 		 * anyway.
 		 */
 
-		dev->last_rx = jiffies ; 
 		/* Acknowledge interrupt, this tells nic we are done with the arb */
 		writel(ACK_INTERRUPT | ARBCACK | LATCH_ACK, xl_mmio + MMIO_COMMAND) ; 
 
diff --git a/drivers/net/tokenring/ibmtr.c b/drivers/net/tokenring/ibmtr.c
index ad97898..9fd0993 100644
--- a/drivers/net/tokenring/ibmtr.c
+++ b/drivers/net/tokenring/ibmtr.c
@@ -1822,7 +1822,6 @@ static void tr_rx(struct net_device *dev)
 		skb->ip_summed = CHECKSUM_COMPLETE;
 	}
 	netif_rx(skb);
-	dev->last_rx = jiffies;
 }				/*tr_rx */
 
 /*****************************************************************************/
diff --git a/drivers/net/tokenring/lanstreamer.c b/drivers/net/tokenring/lanstreamer.c
index bd70e81..239c752 100644
--- a/drivers/net/tokenring/lanstreamer.c
+++ b/drivers/net/tokenring/lanstreamer.c
@@ -1009,7 +1009,6 @@ static void streamer_rx(struct net_device *dev)
 					/* send up to the protocol */
 					netif_rx(skb);
 				}
-				dev->last_rx = jiffies;
 				streamer_priv->streamer_stats.rx_packets++;
 				streamer_priv->streamer_stats.rx_bytes += length;
 			}	/* if skb == null */
diff --git a/drivers/net/tokenring/olympic.c b/drivers/net/tokenring/olympic.c
index f78bc5d..ecb5c7c 100644
--- a/drivers/net/tokenring/olympic.c
+++ b/drivers/net/tokenring/olympic.c
@@ -862,7 +862,6 @@ static void olympic_rx(struct net_device *dev)
 						skb->protocol = tr_type_trans(skb,dev);
 						netif_rx(skb) ; 
 					} 
-					dev->last_rx = jiffies ; 
 					olympic_priv->olympic_stats.rx_packets++ ; 
 					olympic_priv->olympic_stats.rx_bytes += length ; 
 				} /* if skb == null */
@@ -1441,7 +1440,6 @@ static void olympic_arb_cmd(struct net_device *dev)
 			       dev->name, mac_hdr->saddr);
 		}
 		netif_rx(mac_frame);
-		dev->last_rx = jiffies;
 
 drop_frame:
 		/* Now tell the card we have dealt with the received frame */
diff --git a/drivers/net/tokenring/smctr.c b/drivers/net/tokenring/smctr.c
index ed50d28..a011666 100644
--- a/drivers/net/tokenring/smctr.c
+++ b/drivers/net/tokenring/smctr.c
@@ -3910,7 +3910,6 @@ static int smctr_process_rx_packet(MAC_HEADER *rmf, __u16 size,
                 /* Kick the packet on up. */
                 skb->protocol = tr_type_trans(skb, dev);
                 netif_rx(skb);
-		dev->last_rx = jiffies;
                 err = 0;
         }
 
@@ -4496,7 +4495,6 @@ static int smctr_rx_frame(struct net_device *dev)
                                 	/* Kick the packet on up. */
                                 	skb->protocol = tr_type_trans(skb, dev);
                                 	netif_rx(skb);
-					dev->last_rx = jiffies;
 				} else {
 				}
                         }
diff --git a/drivers/net/tokenring/tms380tr.c b/drivers/net/tokenring/tms380tr.c
index d07c452..b408397 100644
--- a/drivers/net/tokenring/tms380tr.c
+++ b/drivers/net/tokenring/tms380tr.c
@@ -2186,7 +2186,6 @@ static void tms380tr_rcv_status_irq(struct net_device *dev)
 				skb_trim(skb,Length);
 				skb->protocol = tr_type_trans(skb,dev);
 				netif_rx(skb);
-				dev->last_rx = jiffies;
 			}
 		}
 		else	/* Invalid frame */
diff --git a/drivers/net/tsi108_eth.c b/drivers/net/tsi108_eth.c
index 6924805..271bc23 100644
--- a/drivers/net/tsi108_eth.c
+++ b/drivers/net/tsi108_eth.c
@@ -788,7 +788,6 @@ static int tsi108_complete_rx(struct net_device *dev, int budget)
 		skb_put(skb, data->rxring[rx].len);
 		skb->protocol = eth_type_trans(skb, dev);
 		netif_receive_skb(skb);
-		dev->last_rx = jiffies;
 	}
 
 	return done;
diff --git a/drivers/net/tulip/de2104x.c b/drivers/net/tulip/de2104x.c
index 0807618..e23a508 100644
--- a/drivers/net/tulip/de2104x.c
+++ b/drivers/net/tulip/de2104x.c
@@ -459,7 +459,6 @@ static void de_rx (struct de_private *de)
 
 		de->net_stats.rx_packets++;
 		de->net_stats.rx_bytes += skb->len;
-		de->dev->last_rx = jiffies;
 		rc = netif_rx (skb);
 		if (rc == NET_RX_DROP)
 			drop = 1;
diff --git a/drivers/net/tulip/de4x5.c b/drivers/net/tulip/de4x5.c
index 1e7d5e2..f8a4525 100644
--- a/drivers/net/tulip/de4x5.c
+++ b/drivers/net/tulip/de4x5.c
@@ -1646,7 +1646,6 @@ de4x5_rx(struct net_device *dev)
 		    netif_rx(skb);
 
 		    /* Update stats */
-		    dev->last_rx = jiffies;
 		    lp->stats.rx_packets++;
  		    lp->stats.rx_bytes += pkt_len;
 		}
diff --git a/drivers/net/tulip/dmfe.c b/drivers/net/tulip/dmfe.c
index 0ec3281..28a5c51 100644
--- a/drivers/net/tulip/dmfe.c
+++ b/drivers/net/tulip/dmfe.c
@@ -1008,7 +1008,6 @@ static void dmfe_rx_packet(struct DEVICE *dev, struct dmfe_board_info * db)
 
 					skb->protocol = eth_type_trans(skb, dev);
 					netif_rx(skb);
-					dev->last_rx = jiffies;
 					db->stats.rx_packets++;
 					db->stats.rx_bytes += rxlen;
 				}
diff --git a/drivers/net/tulip/interrupt.c b/drivers/net/tulip/interrupt.c
index c6bad98..739d610 100644
--- a/drivers/net/tulip/interrupt.c
+++ b/drivers/net/tulip/interrupt.c
@@ -231,7 +231,6 @@ int tulip_poll(struct napi_struct *napi, int budget)
 
                                netif_receive_skb(skb);
 
-                               dev->last_rx = jiffies;
                                tp->stats.rx_packets++;
                                tp->stats.rx_bytes += pkt_len;
                        }
@@ -444,7 +443,6 @@ static int tulip_rx(struct net_device *dev)
 
 			netif_rx(skb);
 
-			dev->last_rx = jiffies;
 			tp->stats.rx_packets++;
 			tp->stats.rx_bytes += pkt_len;
 		}
diff --git a/drivers/net/tulip/uli526x.c b/drivers/net/tulip/uli526x.c
index 298649a..35c57f6 100644
--- a/drivers/net/tulip/uli526x.c
+++ b/drivers/net/tulip/uli526x.c
@@ -854,7 +854,6 @@ static void uli526x_rx_packet(struct net_device *dev, struct uli526x_board_info
 
 				skb->protocol = eth_type_trans(skb, dev);
 				netif_rx(skb);
-				dev->last_rx = jiffies;
 				db->stats.rx_packets++;
 				db->stats.rx_bytes += rxlen;
 
diff --git a/drivers/net/tulip/winbond-840.c b/drivers/net/tulip/winbond-840.c
index e4cb408..022d99a 100644
--- a/drivers/net/tulip/winbond-840.c
+++ b/drivers/net/tulip/winbond-840.c
@@ -1253,7 +1253,6 @@ static int netdev_rx(struct net_device *dev)
 #endif
 			skb->protocol = eth_type_trans(skb, dev);
 			netif_rx(skb);
-			dev->last_rx = jiffies;
 			np->stats.rx_packets++;
 			np->stats.rx_bytes += pkt_len;
 		}
diff --git a/drivers/net/tulip/xircom_cb.c b/drivers/net/tulip/xircom_cb.c
index 3c0b96b..13c8703 100644
--- a/drivers/net/tulip/xircom_cb.c
+++ b/drivers/net/tulip/xircom_cb.c
@@ -1201,7 +1201,6 @@ static void investigate_read_descriptor(struct net_device *dev,struct xircom_pri
 			skb_put(skb, pkt_len);
 			skb->protocol = eth_type_trans(skb, dev);
 			netif_rx(skb);
-			dev->last_rx = jiffies;
 			card->stats.rx_packets++;
 			card->stats.rx_bytes += pkt_len;
 
diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 64c7fc7..680d78e 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -529,7 +529,6 @@ static __inline__ ssize_t tun_get_user(struct tun_struct *tun, struct iovec *iv,
 	}
 
 	netif_rx_ni(skb);
-	tun->dev->last_rx = jiffies;
 
 	tun->dev->stats.rx_packets++;
 	tun->dev->stats.rx_bytes += len;
diff --git a/drivers/net/typhoon.c b/drivers/net/typhoon.c
index 6f191e9..8763987 100644
--- a/drivers/net/typhoon.c
+++ b/drivers/net/typhoon.c
@@ -1729,7 +1729,6 @@ typhoon_rx(struct typhoon *tp, struct basic_ring *rxRing, volatile __le32 * read
 			netif_receive_skb(new_skb);
 		spin_unlock(&tp->state_lock);
 
-		tp->dev->last_rx = jiffies;
 		received++;
 		budget--;
 	}
diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index c87747b..4931af7 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -3502,8 +3502,6 @@ static int ucc_geth_rx(struct ucc_geth_private *ugeth, u8 rxQ, int rx_work_limit
 			netif_receive_skb(skb);
 		}
 
-		ugeth->dev->last_rx = jiffies;
-
 		skb = get_new_skb(ugeth, bd);
 		if (!skb) {
 			if (netif_msg_rx_err(ugeth))
diff --git a/drivers/net/usb/catc.c b/drivers/net/usb/catc.c
index 466a89e..d762123 100644
--- a/drivers/net/usb/catc.c
+++ b/drivers/net/usb/catc.c
@@ -271,8 +271,6 @@ static void catc_rx_done(struct urb *urb)
 
 	} while (pkt_start - (u8 *) urb->transfer_buffer < urb->actual_length);
 
-	catc->netdev->last_rx = jiffies;
-
 	if (catc->is_f5u011) {
 		if (atomic_read(&catc->recq_sz)) {
 			int status;
diff --git a/drivers/net/via-rhine.c b/drivers/net/via-rhine.c
index bb54a93..9a650d0 100644
--- a/drivers/net/via-rhine.c
+++ b/drivers/net/via-rhine.c
@@ -1504,7 +1504,6 @@ static int rhine_rx(struct net_device *dev, int limit)
 			}
 			skb->protocol = eth_type_trans(skb, dev);
 			netif_receive_skb(skb);
-			dev->last_rx = jiffies;
 			rp->stats.rx_bytes += pkt_len;
 			rp->stats.rx_packets++;
 		}
diff --git a/drivers/net/via-velocity.c b/drivers/net/via-velocity.c
index 3590ea5..448772f 100644
--- a/drivers/net/via-velocity.c
+++ b/drivers/net/via-velocity.c
@@ -1412,8 +1412,6 @@ static int velocity_rx_srv(struct velocity_info *vptr, int status)
 
 		rd->size |= RX_INTEN;
 
-		vptr->dev->last_rx = jiffies;
-
 		rd_curr++;
 		if (rd_curr >= vptr->options.numrx)
 			rd_curr = 0;
diff --git a/drivers/net/wan/cosa.c b/drivers/net/wan/cosa.c
index 7f97f8d..d80b72e 100644
--- a/drivers/net/wan/cosa.c
+++ b/drivers/net/wan/cosa.c
@@ -754,7 +754,6 @@ static int cosa_net_rx_done(struct channel_data *chan)
 	chan->netdev->stats.rx_bytes += chan->cosa->rxsize;
 	netif_rx(chan->rx_skb);
 	chan->rx_skb = NULL;
-	chan->netdev->last_rx = jiffies;
 	return 0;
 }
 
diff --git a/drivers/net/wan/cycx_x25.c b/drivers/net/wan/cycx_x25.c
index 5a7303d..aeea321 100644
--- a/drivers/net/wan/cycx_x25.c
+++ b/drivers/net/wan/cycx_x25.c
@@ -843,7 +843,6 @@ static void cycx_x25_irq_rx(struct cycx_device *card, struct cycx_x25_cmd *cmd)
 
 	skb_reset_mac_header(skb);
 	netif_rx(skb);
-	dev->last_rx = jiffies;		/* timestamp */
 }
 
 /* Connect interrupt handler. */
@@ -1494,7 +1493,6 @@ static void cycx_x25_chan_send_event(struct net_device *dev, u8 event)
 
 	skb->protocol = x25_type_trans(skb, dev);
 	netif_rx(skb);
-	dev->last_rx = jiffies;		/* timestamp */
 }
 
 /* Convert line speed in bps to a number used by cyclom 2x code. */
diff --git a/drivers/net/wan/dlci.c b/drivers/net/wan/dlci.c
index b142427..5d13832 100644
--- a/drivers/net/wan/dlci.c
+++ b/drivers/net/wan/dlci.c
@@ -181,7 +181,6 @@ static void dlci_receive(struct sk_buff *skb, struct net_device *dev)
 		dlp->stats.rx_bytes += skb->len;
 		netif_rx(skb);
 		dlp->stats.rx_packets++;
-		dev->last_rx = jiffies;
 	}
 	else
 		dev_kfree_skb(skb);
diff --git a/drivers/net/wan/dscc4.c b/drivers/net/wan/dscc4.c
index 7d16ca3..888025d 100644
--- a/drivers/net/wan/dscc4.c
+++ b/drivers/net/wan/dscc4.c
@@ -659,7 +659,6 @@ static inline void dscc4_rx_skb(struct dscc4_dev_priv *dpriv,
 		skb_put(skb, pkt_len);
 		if (netif_running(dev))
 			skb->protocol = hdlc_type_trans(skb, dev);
-		skb->dev->last_rx = jiffies;
 		netif_rx(skb);
 	} else {
 		if (skb->data[pkt_len] & FrameRdo)
diff --git a/drivers/net/wan/farsync.c b/drivers/net/wan/farsync.c
index 9557ad0..48a2c9d 100644
--- a/drivers/net/wan/farsync.c
+++ b/drivers/net/wan/farsync.c
@@ -896,7 +896,6 @@ fst_rx_dma_complete(struct fst_card_info *card, struct fst_port_info *port,
 	fst_process_rx_status(rx_status, port_to_dev(port)->name);
 	if (rx_status == NET_RX_DROP)
 		dev->stats.rx_dropped++;
-	dev->last_rx = jiffies;
 }
 
 /*
@@ -1322,7 +1321,6 @@ fst_intr_rx(struct fst_card_info *card, struct fst_port_info *port)
 		fst_process_rx_status(rx_status, port_to_dev(port)->name);
 		if (rx_status == NET_RX_DROP)
 			dev->stats.rx_dropped++;
-		dev->last_rx = jiffies;
 	} else {
 		card->dma_skb_rx = skb;
 		card->dma_port_rx = port;
diff --git a/drivers/net/wan/hd6457x.c b/drivers/net/wan/hd6457x.c
index 591fb45..434583a 100644
--- a/drivers/net/wan/hd6457x.c
+++ b/drivers/net/wan/hd6457x.c
@@ -328,7 +328,6 @@ static inline void sca_rx(card_t *card, port_t *port, pkt_desc __iomem *desc, u1
 #endif
 	dev->stats.rx_packets++;
 	dev->stats.rx_bytes += skb->len;
-	dev->last_rx = jiffies;
 	skb->protocol = hdlc_type_trans(skb, dev);
 	netif_rx(skb);
 }
diff --git a/drivers/net/wan/hostess_sv11.c b/drivers/net/wan/hostess_sv11.c
index e299313..af54f0c 100644
--- a/drivers/net/wan/hostess_sv11.c
+++ b/drivers/net/wan/hostess_sv11.c
@@ -66,7 +66,6 @@ static void hostess_input(struct z8530_channel *c, struct sk_buff *skb)
 	 *	it right now.
 	 */
 	netif_rx(skb);
-	c->netdevice->last_rx = jiffies;
 }
 
 /*
diff --git a/drivers/net/wan/lapbether.c b/drivers/net/wan/lapbether.c
index 24fd613..5b61b3e 100644
--- a/drivers/net/wan/lapbether.c
+++ b/drivers/net/wan/lapbether.c
@@ -143,7 +143,6 @@ static int lapbeth_data_indication(struct net_device *dev, struct sk_buff *skb)
 	*ptr = 0x00;
 
 	skb->protocol = x25_type_trans(skb, dev);
-	skb->dev->last_rx = jiffies;
 	return netif_rx(skb);
 }
 
@@ -235,7 +234,6 @@ static void lapbeth_connected(struct net_device *dev, int reason)
 	*ptr = 0x01;
 
 	skb->protocol = x25_type_trans(skb, dev);
-	skb->dev->last_rx = jiffies;
 	netif_rx(skb);
 }
 
@@ -253,7 +251,6 @@ static void lapbeth_disconnected(struct net_device *dev, int reason)
 	*ptr = 0x02;
 
 	skb->protocol = x25_type_trans(skb, dev);
-	skb->dev->last_rx = jiffies;
 	netif_rx(skb);
 }
 
diff --git a/drivers/net/wan/lmc/lmc_main.c b/drivers/net/wan/lmc/lmc_main.c
index d7bb63e..feac3b9 100644
--- a/drivers/net/wan/lmc/lmc_main.c
+++ b/drivers/net/wan/lmc/lmc_main.c
@@ -1594,7 +1594,6 @@ static int lmc_rx(struct net_device *dev)
             goto skip_packet;
         }
         
-        dev->last_rx = jiffies;
 	sc->lmc_device->stats.rx_packets++;
 	sc->lmc_device->stats.rx_bytes += len;
 
diff --git a/drivers/net/wan/lmc/lmc_proto.c b/drivers/net/wan/lmc/lmc_proto.c
index be9877f..94b4c20 100644
--- a/drivers/net/wan/lmc/lmc_proto.c
+++ b/drivers/net/wan/lmc/lmc_proto.c
@@ -142,7 +142,6 @@ void lmc_proto_netif(lmc_softc_t *sc, struct sk_buff *skb) /*FOLD00*/
     case LMC_PPP:
     case LMC_NET:
     default:
-        skb->dev->last_rx = jiffies;
         netif_rx(skb);
         break;
     case LMC_RAW:
diff --git a/drivers/net/wan/sbni.c b/drivers/net/wan/sbni.c
index ee51b6a..6db063e 100644
--- a/drivers/net/wan/sbni.c
+++ b/drivers/net/wan/sbni.c
@@ -1013,13 +1013,11 @@ indicate_pkt( struct net_device  *dev )
 #ifdef CONFIG_SBNI_MULTILINE
 	skb->protocol = eth_type_trans( skb, nl->master );
 	netif_rx( skb );
-	dev->last_rx = jiffies;
 	++((struct net_local *) nl->master->priv)->stats.rx_packets;
 	((struct net_local *) nl->master->priv)->stats.rx_bytes += nl->inppos;
 #else
 	skb->protocol = eth_type_trans( skb, dev );
 	netif_rx( skb );
-	dev->last_rx = jiffies;
 	++nl->stats.rx_packets;
 	nl->stats.rx_bytes += nl->inppos;
 #endif
diff --git a/drivers/net/wan/sealevel.c b/drivers/net/wan/sealevel.c
index c023584..0941a26 100644
--- a/drivers/net/wan/sealevel.c
+++ b/drivers/net/wan/sealevel.c
@@ -68,7 +68,6 @@ static void sealevel_input(struct z8530_channel *c, struct sk_buff *skb)
 	skb_reset_mac_header(skb);
 	skb->dev = c->netdevice;
 	netif_rx(skb);
-	c->netdevice->last_rx = jiffies;
 }
 
 /*
diff --git a/drivers/net/wan/syncppp.c b/drivers/net/wan/syncppp.c
index 6e92f7b..58ae8a2 100644
--- a/drivers/net/wan/syncppp.c
+++ b/drivers/net/wan/syncppp.c
@@ -284,7 +284,6 @@ static void sppp_input (struct net_device *dev, struct sk_buff *skb)
 					printk(KERN_DEBUG "Yow an IP frame.\n");
 				skb->protocol=htons(ETH_P_IP);
 				netif_rx(skb);
-				dev->last_rx = jiffies;
 				goto done;
 			}
 			break;
@@ -294,7 +293,6 @@ static void sppp_input (struct net_device *dev, struct sk_buff *skb)
 			if (sp->lcp.state == LCP_STATE_OPENED) {
 				skb->protocol=htons(ETH_P_IPX);
 				netif_rx(skb);
-				dev->last_rx = jiffies;
 				goto done;
 			}
 			break;
@@ -321,14 +319,12 @@ static void sppp_input (struct net_device *dev, struct sk_buff *skb)
 		case ETH_P_IP:
 			skb->protocol=htons(ETH_P_IP);
 			netif_rx(skb);
-			dev->last_rx = jiffies;
 			goto done;
 #endif
 #ifdef CONFIG_IPX
 		case ETH_P_IPX:
 			skb->protocol=htons(ETH_P_IPX);
 			netif_rx(skb);
-			dev->last_rx = jiffies;
 			goto done;
 #endif
 		}
diff --git a/drivers/net/wan/wanxl.c b/drivers/net/wan/wanxl.c
index a8a5ca0..8845949 100644
--- a/drivers/net/wan/wanxl.c
+++ b/drivers/net/wan/wanxl.c
@@ -220,7 +220,6 @@ static inline void wanxl_rx_intr(card_t *card)
 #endif
 				dev->stats.rx_packets++;
 				dev->stats.rx_bytes += skb->len;
-				dev->last_rx = jiffies;
 				skb->protocol = hdlc_type_trans(skb, dev);
 				netif_rx(skb);
 				skb = NULL;
diff --git a/drivers/net/wan/x25_asy.c b/drivers/net/wan/x25_asy.c
index 2a6c7a6..3b7bdfd 100644
--- a/drivers/net/wan/x25_asy.c
+++ b/drivers/net/wan/x25_asy.c
@@ -211,7 +211,6 @@ static void x25_asy_bump(struct x25_asy *sl)
 		printk(KERN_DEBUG "x25_asy: data received err - %d\n", err);
 	} else {
 		netif_rx(skb);
-		sl->dev->last_rx = jiffies;
 		sl->stats.rx_packets++;
 	}
 }
@@ -361,7 +360,6 @@ static int x25_asy_xmit(struct sk_buff *skb, struct net_device *dev)
 
 static int x25_asy_data_indication(struct net_device *dev, struct sk_buff *skb)
 {
-	skb->dev->last_rx = jiffies;
 	return netif_rx(skb);
 }
 
@@ -413,7 +411,6 @@ static void x25_asy_connected(struct net_device *dev, int reason)
 
 	skb->protocol = x25_type_trans(skb, sl->dev);
 	netif_rx(skb);
-	sl->dev->last_rx = jiffies;
 }
 
 static void x25_asy_disconnected(struct net_device *dev, int reason)
@@ -433,7 +430,6 @@ static void x25_asy_disconnected(struct net_device *dev, int reason)
 
 	skb->protocol = x25_type_trans(skb, sl->dev);
 	netif_rx(skb);
-	sl->dev->last_rx = jiffies;
 }
 
 static struct lapb_register_struct x25_asy_callbacks = {
diff --git a/drivers/net/wireless/airo.c b/drivers/net/wireless/airo.c
index d7388d2..c8dc656 100644
--- a/drivers/net/wireless/airo.c
+++ b/drivers/net/wireless/airo.c
@@ -3366,7 +3366,6 @@ badrx:
 				skb->protocol = htons(ETH_P_802_2);
 			} else
 				skb->protocol = eth_type_trans(skb,dev);
-			skb->dev->last_rx = jiffies;
 			skb->ip_summed = CHECKSUM_NONE;
 
 			netif_rx( skb );
@@ -3596,7 +3595,6 @@ badmic:
 
 		skb->ip_summed = CHECKSUM_NONE;
 		skb->protocol = eth_type_trans(skb, ai->dev);
-		skb->dev->last_rx = jiffies;
 		netif_rx(skb);
 	}
 badrx:
@@ -3690,7 +3688,6 @@ void mpi_receive_802_11 (struct airo_info *ai)
 	skb->pkt_type = PACKET_OTHERHOST;
 	skb->dev = ai->wifidev;
 	skb->protocol = htons(ETH_P_802_2);
-	skb->dev->last_rx = jiffies;
 	skb->ip_summed = CHECKSUM_NONE;
 	netif_rx( skb );
 badrx:
diff --git a/drivers/net/wireless/arlan-main.c b/drivers/net/wireless/arlan-main.c
index b608643..bfca15d 100644
--- a/drivers/net/wireless/arlan-main.c
+++ b/drivers/net/wireless/arlan-main.c
@@ -1529,7 +1529,6 @@ static void arlan_rx_interrupt(struct net_device *dev, u_char rxStatus, u_short
 					printk(KERN_WARNING "arlan kernel pkt type trans %x \n", skb->protocol);
 				}
 			netif_rx(skb);
-			dev->last_rx = jiffies;
 			dev->stats.rx_packets++;
 			dev->stats.rx_bytes += pkt_len;
 		}
diff --git a/drivers/net/wireless/atmel.c b/drivers/net/wireless/atmel.c
index 6e20552..d169315 100644
--- a/drivers/net/wireless/atmel.c
+++ b/drivers/net/wireless/atmel.c
@@ -919,7 +919,6 @@ static void fast_rx_path(struct atmel_private *priv,
 	else
 		memcpy(&skbp[6], header->addr2, 6); /* source address */
 
-	priv->dev->last_rx = jiffies;
 	skb->protocol = eth_type_trans(skb, priv->dev);
 	skb->ip_summed = CHECKSUM_NONE;
 	netif_rx(skb);
@@ -1026,7 +1025,6 @@ static void frag_rx_path(struct atmel_private *priv,
 				memcpy(skb_put(skb, priv->frag_len + 12),
 				       priv->rx_buf,
 				       priv->frag_len + 12);
-				priv->dev->last_rx = jiffies;
 				skb->protocol = eth_type_trans(skb, priv->dev);
 				skb->ip_summed = CHECKSUM_NONE;
 				netif_rx(skb);
diff --git a/drivers/net/wireless/hostap/hostap_80211_rx.c b/drivers/net/wireless/hostap/hostap_80211_rx.c
index bbb8ec6..5f64461 100644
--- a/drivers/net/wireless/hostap/hostap_80211_rx.c
+++ b/drivers/net/wireless/hostap/hostap_80211_rx.c
@@ -67,7 +67,6 @@ int prism2_rx_80211(struct net_device *dev, struct sk_buff *skb,
 
 	iface = netdev_priv(dev);
 	local = iface->local;
-	dev->last_rx = jiffies;
 
 	if (dev->type == ARPHRD_IEEE80211_PRISM) {
 		if (local->monitor_type == PRISM2_MONITOR_PRISM) {
@@ -883,8 +882,6 @@ void hostap_80211_rx(struct net_device *dev, struct sk_buff *skb,
 		from_assoc_ap = 1;
 	}
 
-	dev->last_rx = jiffies;
-
 	if ((local->iw_mode == IW_MODE_MASTER ||
 	     local->iw_mode == IW_MODE_REPEAT) &&
 	    !from_assoc_ap) {
diff --git a/drivers/net/wireless/netwave_cs.c b/drivers/net/wireless/netwave_cs.c
index be80c00..24caec6 100644
--- a/drivers/net/wireless/netwave_cs.c
+++ b/drivers/net/wireless/netwave_cs.c
@@ -1307,7 +1307,6 @@ static int netwave_rx(struct net_device *dev)
 	/* Queue packet for network layer */
 	netif_rx(skb);
 
-	dev->last_rx = jiffies;
 	priv->stats.rx_packets++;
 	priv->stats.rx_bytes += rcvLen;
 
diff --git a/drivers/net/wireless/orinoco.c b/drivers/net/wireless/orinoco.c
index 5a39166..b657a91 100644
--- a/drivers/net/wireless/orinoco.c
+++ b/drivers/net/wireless/orinoco.c
@@ -1289,7 +1289,6 @@ static void orinoco_rx_monitor(struct net_device *dev, u16 rxfid,
 	skb->pkt_type = PACKET_OTHERHOST;
 	skb->protocol = __constant_htons(ETH_P_802_2);
 	
-	dev->last_rx = jiffies;
 	stats->rx_packets++;
 	stats->rx_bytes += skb->len;
 
@@ -1538,7 +1537,6 @@ static void orinoco_rx(struct net_device *dev,
 	else
 		memcpy(hdr->h_source, desc->addr2, ETH_ALEN);
 
-	dev->last_rx = jiffies;
 	skb->protocol = eth_type_trans(skb, dev);
 	skb->ip_summed = CHECKSUM_NONE;
 	if (fc & IEEE80211_FCTL_TODS)
diff --git a/drivers/net/wireless/ray_cs.c b/drivers/net/wireless/ray_cs.c
index bf0b929..81b71f0 100644
--- a/drivers/net/wireless/ray_cs.c
+++ b/drivers/net/wireless/ray_cs.c
@@ -2284,7 +2284,6 @@ static void rx_data(struct net_device *dev, struct rcs __iomem *prcs, unsigned i
 
     skb->protocol = eth_type_trans(skb,dev);
     netif_rx(skb);
-    dev->last_rx = jiffies;
     local->stats.rx_packets++;
     local->stats.rx_bytes += total_len;
 
diff --git a/drivers/net/wireless/strip.c b/drivers/net/wireless/strip.c
index 417e9e6..cf0d070 100644
--- a/drivers/net/wireless/strip.c
+++ b/drivers/net/wireless/strip.c
@@ -1997,7 +1997,6 @@ static void deliver_packet(struct strip *strip_info, STRIP_Header * header,
 #ifdef EXT_COUNTERS
 		strip_info->rx_bytes += packetlen;
 #endif
-		skb->dev->last_rx = jiffies;
 		netif_rx(skb);
 	}
 }
@@ -2490,7 +2489,6 @@ static void strip_dev_setup(struct net_device *dev)
 	 */
 
 	dev->trans_start = 0;
-	dev->last_rx = 0;
 	dev->tx_queue_len = 30;	/* Drop after 30 frames queued */
 
 	dev->flags = 0;
diff --git a/drivers/net/wireless/wavelan.c b/drivers/net/wireless/wavelan.c
index 6fa3d79..1ac37e8 100644
--- a/drivers/net/wireless/wavelan.c
+++ b/drivers/net/wireless/wavelan.c
@@ -2528,7 +2528,6 @@ wv_packet_read(struct net_device * dev, u16 buf_off, int sksize)
 	netif_rx(skb);
 
 	/* Keep statistics up to date */
-	dev->last_rx = jiffies;
 	lp->stats.rx_packets++;
 	lp->stats.rx_bytes += sksize;
 
diff --git a/drivers/net/wireless/wavelan_cs.c b/drivers/net/wireless/wavelan_cs.c
index 0a3bacc..de717f8 100644
--- a/drivers/net/wireless/wavelan_cs.c
+++ b/drivers/net/wireless/wavelan_cs.c
@@ -2878,7 +2878,6 @@ wv_packet_read(struct net_device *		dev,
   netif_rx(skb);
 
   /* Keep stats up to date */
-  dev->last_rx = jiffies;
   lp->stats.rx_packets++;
   lp->stats.rx_bytes += sksize;
 
diff --git a/drivers/net/wireless/wl3501_cs.c b/drivers/net/wireless/wl3501_cs.c
index 8b96f50..c99a1b6 100644
--- a/drivers/net/wireless/wl3501_cs.c
+++ b/drivers/net/wireless/wl3501_cs.c
@@ -1013,7 +1013,6 @@ static inline void wl3501_md_ind_interrupt(struct net_device *dev,
 		wl3501_receive(this, skb->data, pkt_len);
 		skb_put(skb, pkt_len);
 		skb->protocol	= eth_type_trans(skb, dev);
-		dev->last_rx	= jiffies;
 		this->stats.rx_packets++;
 		this->stats.rx_bytes += skb->len;
 		netif_rx(skb);
diff --git a/drivers/net/wireless/zd1201.c b/drivers/net/wireless/zd1201.c
index b16ec6e..bf744c1 100644
--- a/drivers/net/wireless/zd1201.c
+++ b/drivers/net/wireless/zd1201.c
@@ -328,7 +328,6 @@ static void zd1201_usbrx(struct urb *urb)
 			memcpy(skb_put(skb, 2), &data[datalen-24], 2);
 			memcpy(skb_put(skb, len), data, len);
 			skb->protocol = eth_type_trans(skb, zd->dev);
-			skb->dev->last_rx = jiffies;
 			zd->stats.rx_packets++;
 			zd->stats.rx_bytes += skb->len;
 			netif_rx(skb);
@@ -385,7 +384,6 @@ static void zd1201_usbrx(struct urb *urb)
 			memcpy(skb_put(skb, len), data+8, len);
 		}
 		skb->protocol = eth_type_trans(skb, zd->dev);
-		skb->dev->last_rx = jiffies;
 		zd->stats.rx_packets++;
 		zd->stats.rx_bytes += skb->len;
 		netif_rx(skb);
diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index c6948d8..4b21bcf 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -841,7 +841,6 @@ static int handle_incoming_queue(struct net_device *dev,
 
 		/* Pass it up. */
 		netif_receive_skb(skb);
-		dev->last_rx = jiffies;
 	}
 
 	return packets_dropped;
diff --git a/drivers/net/yellowfin.c b/drivers/net/yellowfin.c
index 5110666..d8dbc57 100644
--- a/drivers/net/yellowfin.c
+++ b/drivers/net/yellowfin.c
@@ -1138,7 +1138,6 @@ static int yellowfin_rx(struct net_device *dev)
 			}
 			skb->protocol = eth_type_trans(skb, dev);
 			netif_rx(skb);
-			dev->last_rx = jiffies;
 			dev->stats.rx_packets++;
 			dev->stats.rx_bytes += pkt_len;
 		}
diff --git a/drivers/net/znet.c b/drivers/net/znet.c
index fc7a884..d7588bf 100644
--- a/drivers/net/znet.c
+++ b/drivers/net/znet.c
@@ -785,7 +785,6 @@ static void znet_rx(struct net_device *dev)
 		  }
 		  skb->protocol=eth_type_trans(skb,dev);
 		  netif_rx(skb);
-		  dev->last_rx = jiffies;
 		  dev->stats.rx_packets++;
 		  dev->stats.rx_bytes += pkt_len;
 		}
-- 
1.5.6.5

