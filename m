From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] drivers: Kill now superfluous ->last_rx stores
Date: Mon, 31 Aug 2009 18:34:50 +0200
Message-ID: <4A9BFBAA.10705@gmail.com>
References: <4A9B6963.5090207@cn.fujitsu.com> <4A9B6E57.7090703@gmail.com> <20090831111245.GA2105@hmsreliant.think-freely.org> <4A9BD13E.4040501@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Neil Horman <nhorman@tuxdriver.com>,
	Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:55417 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751999AbZHaQe6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Aug 2009 12:34:58 -0400
In-Reply-To: <4A9BD13E.4040501@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet a =E9crit :
> Neil Horman a =E9crit :
>> I still see a large number of drivers that update dev->last_rx, alth=
ough its
>> not all as I look through the list, so something definately seems am=
iss.
>=20
> Some drivers still update dev->last_rx for their own needs, not a cor=
e
> network concern.
>=20
> But a cleanup is certainly possible on few other drivers, about a doz=
en
> if I count correctly.

Well, a litle bit more if we look outside of drivers/net

[PATCH net-next-2.6] drivers: Kill now superfluous ->last_rx stores

The generic packet receive code takes care of setting
netdev->last_rx when necessary, for the sake of the
bonding ARP monitor.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 drivers/firewire/net.c                  |    2 --
 drivers/ieee1394/eth1394.c              |    1 -
 drivers/infiniband/hw/amso1100/c2.c     |    1 -
 drivers/infiniband/hw/nes/nes_hw.c      |    2 +-
 drivers/infiniband/ulp/ipoib/ipoib_cm.c |    1 -
 drivers/infiniband/ulp/ipoib/ipoib_ib.c |    1 -
 drivers/misc/sgi-xp/xpnet.c             |    1 -
 drivers/net/arm/ks8695net.c             |    1 -
 drivers/net/arm/w90p910_ether.c         |    1 -
 drivers/net/atl1c/atl1c_main.c          |    1 -
 drivers/net/benet/be_main.c             |    2 --
 drivers/net/can/dev.c                   |    1 -
 drivers/net/can/sja1000/sja1000.c       |    2 --
 drivers/net/davinci_emac.c              |    1 -
 drivers/net/ethoc.c                     |    1 -
 drivers/net/igbvf/netdev.c              |    4 ----
 drivers/net/smsc911x.c                  |    1 -
 drivers/net/smsc9420.c                  |    1 -
 drivers/net/vxge/vxge-main.c            |    2 --
 drivers/net/wireless/b43legacy/xmit.c   |    1 -
 drivers/net/xilinx_emaclite.c           |    1 -
 drivers/s390/net/ctcm_main.c            |    1 -
 drivers/s390/net/netiucv.c              |    1 -
 drivers/s390/net/qeth_l2_main.c         |    1 -
 drivers/s390/net/qeth_l3_main.c         |    1 -
 25 files changed, 1 insertion(+), 32 deletions(-)

diff --git a/drivers/firewire/net.c b/drivers/firewire/net.c
index a42209a..3f58969 100644
--- a/drivers/firewire/net.c
+++ b/drivers/firewire/net.c
@@ -663,8 +663,6 @@ static int fwnet_finish_incoming_packet(struct net_=
device *net,
 	if (netif_queue_stopped(net))
 		netif_wake_queue(net);
=20
-	net->last_rx =3D jiffies;
-
 	return 0;
 }
=20
diff --git a/drivers/ieee1394/eth1394.c b/drivers/ieee1394/eth1394.c
index f5c586c..f3bf083 100644
--- a/drivers/ieee1394/eth1394.c
+++ b/drivers/ieee1394/eth1394.c
@@ -1300,7 +1300,6 @@ static void ether1394_iso(struct hpsb_iso *iso)
=20
 	hpsb_iso_recv_release_packets(iso, i);
=20
-	dev->last_rx =3D jiffies;
 }
=20
 /******************************************
diff --git a/drivers/infiniband/hw/amso1100/c2.c b/drivers/infiniband/h=
w/amso1100/c2.c
index 0cfbb6d..8c5d284 100644
--- a/drivers/infiniband/hw/amso1100/c2.c
+++ b/drivers/infiniband/hw/amso1100/c2.c
@@ -530,7 +530,6 @@ static void c2_rx_interrupt(struct net_device *netd=
ev)
=20
 		netif_rx(skb);
=20
-		netdev->last_rx =3D jiffies;
 		netdev->stats.rx_packets++;
 		netdev->stats.rx_bytes +=3D buflen;
 	}
diff --git a/drivers/infiniband/hw/nes/nes_hw.c b/drivers/infiniband/hw=
/nes/nes_hw.c
index 4a84d02..97d4c2a 100644
--- a/drivers/infiniband/hw/nes/nes_hw.c
+++ b/drivers/infiniband/hw/nes/nes_hw.c
@@ -2741,7 +2741,7 @@ void nes_nic_ce_handler(struct nes_device *nesdev=
, struct nes_hw_nic_cq *cq)
 				}
=20
 skip_rx_indicate0:
-				nesvnic->netdev->last_rx =3D jiffies;
+				;
 				/* nesvnic->netstats.rx_packets++; */
 				/* nesvnic->netstats.rx_bytes +=3D rx_pkt_size; */
 			}
diff --git a/drivers/infiniband/ulp/ipoib/ipoib_cm.c b/drivers/infiniba=
nd/ulp/ipoib/ipoib_cm.c
index 181b1f3..986f07f 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_cm.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_cm.c
@@ -663,7 +663,6 @@ copied:
 	skb_reset_mac_header(skb);
 	skb_pull(skb, IPOIB_ENCAP_LEN);
=20
-	dev->last_rx =3D jiffies;
 	++dev->stats.rx_packets;
 	dev->stats.rx_bytes +=3D skb->len;
=20
diff --git a/drivers/infiniband/ulp/ipoib/ipoib_ib.c b/drivers/infiniba=
nd/ulp/ipoib/ipoib_ib.c
index e7e5adf..c9dcb20 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_ib.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_ib.c
@@ -277,7 +277,6 @@ static void ipoib_ib_handle_rx_wc(struct net_device=
 *dev, struct ib_wc *wc)
 	skb_reset_mac_header(skb);
 	skb_pull(skb, IPOIB_ENCAP_LEN);
=20
-	dev->last_rx =3D jiffies;
 	++dev->stats.rx_packets;
 	dev->stats.rx_bytes +=3D skb->len;
=20
diff --git a/drivers/misc/sgi-xp/xpnet.c b/drivers/misc/sgi-xp/xpnet.c
index 212da9a..16f0abd 100644
--- a/drivers/misc/sgi-xp/xpnet.c
+++ b/drivers/misc/sgi-xp/xpnet.c
@@ -240,7 +240,6 @@ xpnet_receive(short partid, int channel, struct xpn=
et_message *msg)
 		(void *)skb->head, (void *)skb->data, skb_tail_pointer(skb),
 		skb_end_pointer(skb), skb->len);
=20
-	xpnet_device->last_rx =3D jiffies;
 	xpnet_device->stats.rx_packets++;
 	xpnet_device->stats.rx_bytes +=3D skb->len + ETH_HLEN;
=20
diff --git a/drivers/net/arm/ks8695net.c b/drivers/net/arm/ks8695net.c
index 35cd264..e12d2c8 100644
--- a/drivers/net/arm/ks8695net.c
+++ b/drivers/net/arm/ks8695net.c
@@ -467,7 +467,6 @@ ks8695_rx_irq(int irq, void *dev_id)
 			netif_rx(skb);
=20
 			/* Record stats */
-			ndev->last_rx =3D jiffies;
 			ndev->stats.rx_packets++;
 			ndev->stats.rx_bytes +=3D pktlen;
 			goto rx_finished;
diff --git a/drivers/net/arm/w90p910_ether.c b/drivers/net/arm/w90p910_=
ether.c
index 890716f..04f4114 100644
--- a/drivers/net/arm/w90p910_ether.c
+++ b/drivers/net/arm/w90p910_ether.c
@@ -777,7 +777,6 @@ static void netdev_rx(struct net_device *dev)
=20
 		rxbd =3D &ether->rdesc->desclist[ether->cur_rx];
=20
-		dev->last_rx =3D jiffies;
 	} while (1);
 }
=20
diff --git a/drivers/net/atl1c/atl1c_main.c b/drivers/net/atl1c/atl1c_m=
ain.c
index 1d601ce..81c6928 100644
--- a/drivers/net/atl1c/atl1c_main.c
+++ b/drivers/net/atl1c/atl1c_main.c
@@ -1740,7 +1740,6 @@ rrs_checked:
 		} else
 			netif_receive_skb(skb);
=20
-		netdev->last_rx =3D jiffies;
 		(*work_done)++;
 		count++;
 	}
diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 7b9efee..0695acc 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -774,8 +774,6 @@ static void be_rx_compl_process(struct be_adapter *=
adapter,
 		netif_receive_skb(skb);
 	}
=20
-	adapter->netdev->last_rx =3D jiffies;
-
 	return;
 }
=20
diff --git a/drivers/net/can/dev.c b/drivers/net/can/dev.c
index e1a4f82..1d29082 100644
--- a/drivers/net/can/dev.c
+++ b/drivers/net/can/dev.c
@@ -357,7 +357,6 @@ void can_restart(unsigned long data)
=20
 	netif_rx(skb);
=20
-	dev->last_rx =3D jiffies;
 	stats->rx_packets++;
 	stats->rx_bytes +=3D cf->can_dlc;
=20
diff --git a/drivers/net/can/sja1000/sja1000.c b/drivers/net/can/sja100=
0/sja1000.c
index b3004de..56a1355 100644
--- a/drivers/net/can/sja1000/sja1000.c
+++ b/drivers/net/can/sja1000/sja1000.c
@@ -339,7 +339,6 @@ static void sja1000_rx(struct net_device *dev)
=20
 	netif_rx(skb);
=20
-	dev->last_rx =3D jiffies;
 	stats->rx_packets++;
 	stats->rx_bytes +=3D dlc;
 }
@@ -454,7 +453,6 @@ static int sja1000_err(struct net_device *dev, uint=
8_t isrc, uint8_t status)
=20
 	netif_rx(skb);
=20
-	dev->last_rx =3D jiffies;
 	stats->rx_packets++;
 	stats->rx_bytes +=3D cf->can_dlc;
=20
diff --git a/drivers/net/davinci_emac.c b/drivers/net/davinci_emac.c
index 5e6652b..d465eaa 100644
--- a/drivers/net/davinci_emac.c
+++ b/drivers/net/davinci_emac.c
@@ -1920,7 +1920,6 @@ static int emac_net_rx_cb(struct emac_priv *priv,
 	skb_put(p_skb, net_pkt_list->pkt_length);
 	EMAC_CACHE_INVALIDATE((unsigned long)p_skb->data, p_skb->len);
 	p_skb->protocol =3D eth_type_trans(p_skb, priv->ndev);
-	p_skb->dev->last_rx =3D jiffies;
 	netif_receive_skb(p_skb);
 	priv->net_dev_stats.rx_bytes +=3D net_pkt_list->pkt_length;
 	priv->net_dev_stats.rx_packets++;
diff --git a/drivers/net/ethoc.c b/drivers/net/ethoc.c
index 4dbe5f1..710b564 100644
--- a/drivers/net/ethoc.c
+++ b/drivers/net/ethoc.c
@@ -404,7 +404,6 @@ static int ethoc_rx(struct net_device *dev, int lim=
it)
 				void *src =3D priv->membase + bd.addr;
 				memcpy_fromio(skb_put(skb, size), src, size);
 				skb->protocol =3D eth_type_trans(skb, dev);
-				dev->last_rx =3D jiffies;
 				priv->stats.rx_packets++;
 				priv->stats.rx_bytes +=3D size;
 				netif_receive_skb(skb);
diff --git a/drivers/net/igbvf/netdev.c b/drivers/net/igbvf/netdev.c
index 3f03c42..3dced7c 100644
--- a/drivers/net/igbvf/netdev.c
+++ b/drivers/net/igbvf/netdev.c
@@ -96,8 +96,6 @@ static void igbvf_receive_skb(struct igbvf_adapter *a=
dapter,
 		                         E1000_RXD_SPC_VLAN_MASK);
 	else
 		netif_receive_skb(skb);
-
-	netdev->last_rx =3D jiffies;
 }
=20
 static inline void igbvf_rx_checksum_adv(struct igbvf_adapter *adapter=
,
@@ -342,8 +340,6 @@ send_up:
 		igbvf_receive_skb(adapter, netdev, skb, staterr,
 		                  rx_desc->wb.upper.vlan);
=20
-		netdev->last_rx =3D jiffies;
-
 next_desc:
 		rx_desc->wb.upper.status_error =3D 0;
=20
diff --git a/drivers/net/smsc911x.c b/drivers/net/smsc911x.c
index c266785..ccdd196 100644
--- a/drivers/net/smsc911x.c
+++ b/drivers/net/smsc911x.c
@@ -1047,7 +1047,6 @@ static int smsc911x_poll(struct napi_struct *napi=
, int budget)
 		/* Update counters */
 		dev->stats.rx_packets++;
 		dev->stats.rx_bytes +=3D (pktlength - 4);
-		dev->last_rx =3D jiffies;
 	}
=20
 	/* Return total received packets */
diff --git a/drivers/net/smsc9420.c b/drivers/net/smsc9420.c
index 60abdb1..4434b51 100644
--- a/drivers/net/smsc9420.c
+++ b/drivers/net/smsc9420.c
@@ -817,7 +817,6 @@ static void smsc9420_rx_handoff(struct smsc9420_pda=
ta *pd, const int index,
 	skb->protocol =3D eth_type_trans(skb, dev);
=20
 	netif_receive_skb(skb);
-	dev->last_rx =3D jiffies;
 }
=20
 static int smsc9420_alloc_rx_buffer(struct smsc9420_pdata *pd, int ind=
ex)
diff --git a/drivers/net/vxge/vxge-main.c b/drivers/net/vxge/vxge-main.=
c
index 094d155..53941b9 100644
--- a/drivers/net/vxge/vxge-main.c
+++ b/drivers/net/vxge/vxge-main.c
@@ -588,8 +588,6 @@ vxge_rx_1b_compl(struct __vxge_hw_ring *ringh, void=
 *dtr,
 	if (first_dtr)
 		vxge_hw_ring_rxd_post_post_wmb(ringh, first_dtr);
=20
-	dev->last_rx =3D jiffies;
-
 	vxge_debug_entryexit(VXGE_TRACE,
 				"%s:%d  Exiting...",
 				__func__, __LINE__);
diff --git a/drivers/net/wireless/b43legacy/xmit.c b/drivers/net/wirele=
ss/b43legacy/xmit.c
index f79cee8..103f3c9 100644
--- a/drivers/net/wireless/b43legacy/xmit.c
+++ b/drivers/net/wireless/b43legacy/xmit.c
@@ -590,7 +590,6 @@ void b43legacy_rx(struct b43legacy_wldev *dev,
 		       chanstat);
 	}
=20
-	dev->stats.last_rx =3D jiffies;
 	memcpy(IEEE80211_SKB_RXCB(skb), &status, sizeof(status));
 	ieee80211_rx_irqsafe(dev->wl->hw, skb);
=20
diff --git a/drivers/net/xilinx_emaclite.c b/drivers/net/xilinx_emaclit=
e.c
index 7e05b40..dc22782 100755
--- a/drivers/net/xilinx_emaclite.c
+++ b/drivers/net/xilinx_emaclite.c
@@ -587,7 +587,6 @@ static void xemaclite_rx_handler(struct net_device =
*dev)
=20
 	dev->stats.rx_packets++;
 	dev->stats.rx_bytes +=3D len;
-	dev->last_rx =3D jiffies;
=20
 	netif_rx(skb);		/* Send the packet upstream */
 }
diff --git a/drivers/s390/net/ctcm_main.c b/drivers/s390/net/ctcm_main.=
c
index 38b5079..c5b8387 100644
--- a/drivers/s390/net/ctcm_main.c
+++ b/drivers/s390/net/ctcm_main.c
@@ -164,7 +164,6 @@ void ctcm_unpack_skb(struct channel *ch, struct sk_=
buff *pskb)
 		priv->stats.rx_packets++;
 		priv->stats.rx_bytes +=3D skblen;
 		netif_rx_ni(skb);
-		dev->last_rx =3D jiffies;
 		if (len > 0) {
 			skb_pull(pskb, header->length);
 			if (skb_tailroom(pskb) < LL_HEADER_LENGTH) {
diff --git a/drivers/s390/net/netiucv.c b/drivers/s390/net/netiucv.c
index bb1183a..271c4a8 100644
--- a/drivers/s390/net/netiucv.c
+++ b/drivers/s390/net/netiucv.c
@@ -676,7 +676,6 @@ static void netiucv_unpack_skb(struct iucv_connecti=
on *conn,
 		 * we must use netif_rx_ni() instead of netif_rx()
 		 */
 		netif_rx_ni(skb);
-		dev->last_rx =3D jiffies;
 		skb_pull(pskb, header->next);
 		skb_put(pskb, NETIUCV_HDRLEN);
 	}
diff --git a/drivers/s390/net/qeth_l2_main.c b/drivers/s390/net/qeth_l2=
_main.c
index 12ee7a3..7d7d6d9 100644
--- a/drivers/s390/net/qeth_l2_main.c
+++ b/drivers/s390/net/qeth_l2_main.c
@@ -449,7 +449,6 @@ static void qeth_l2_process_inbound_buffer(struct q=
eth_card *card,
 			QETH_DBF_HEX(CTRL, 3, hdr, QETH_DBF_CTRL_LEN);
 			continue;
 		}
-		card->dev->last_rx =3D jiffies;
 		card->stats.rx_packets++;
 		card->stats.rx_bytes +=3D len;
 	}
diff --git a/drivers/s390/net/qeth_l3_main.c b/drivers/s390/net/qeth_l3=
_main.c
index d9fabe3..d2eabbc 100644
--- a/drivers/s390/net/qeth_l3_main.c
+++ b/drivers/s390/net/qeth_l3_main.c
@@ -1987,7 +1987,6 @@ static void qeth_l3_process_inbound_buffer(struct=
 qeth_card *card,
 			continue;
 		}
=20
-		card->dev->last_rx =3D jiffies;
 		card->stats.rx_packets++;
 		card->stats.rx_bytes +=3D len;
 	}
