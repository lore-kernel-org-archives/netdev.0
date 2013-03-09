From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH net-next] drivers:net: Remove
	unnecessary OOM messages after netdev_alloc_skb
Date: Fri,  8 Mar 2013 17:03:25 -0800
Message-ID: <6379afbec3439c45180956b06c13b02ce3c9f802.1362790535.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: uclinux-dist-devel-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org, linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <uclinux-dist-devel-bounces-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org>
List-Unsubscribe: <https://blackfin.uclinux.org/mailman/options/uclinux-dist-devel>,
	<mailto:uclinux-dist-devel-request-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org?subject=unsubscribe>
List-Archive: <http://blackfin.uclinux.org/pipermail/uclinux-dist-devel>
List-Post: <mailto:uclinux-dist-devel-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org>
List-Help: <mailto:uclinux-dist-devel-request-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org?subject=help>
List-Subscribe: <https://blackfin.uclinux.org/mailman/listinfo/uclinux-dist-devel>,
	<mailto:uclinux-dist-devel-request-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org?subject=subscribe>
Sender: uclinux-dist-devel-bounces-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org
Errors-To: uclinux-dist-devel-bounces-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org
List-Id: netdev.vger.kernel.org

Emitting netdev_alloc_skb and netdev_alloc_skb_ip_align OOM
messages is unnecessary as there is already a dump_stack
after allocation failures.

Other trivial changes around these removals:

Convert a few comparisons of pointer to 0 to !pointer.
Change flow to remove unnecessary label.
Remove now unused variable.
Hoist assignment from if.

Signed-off-by: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
---
 drivers/net/caif/caif_shmcore.c                    |  5 +----
 drivers/net/ethernet/adi/bfin_mac.c                |  6 ++----
 drivers/net/ethernet/amd/7990.c                    |  2 --
 drivers/net/ethernet/amd/a2065.c                   |  1 -
 drivers/net/ethernet/amd/am79c961a.c               |  1 -
 drivers/net/ethernet/amd/ariadne.c                 |  1 -
 drivers/net/ethernet/amd/atarilance.c              |  2 --
 drivers/net/ethernet/amd/au1000_eth.c              |  1 -
 drivers/net/ethernet/amd/declance.c                |  2 --
 drivers/net/ethernet/amd/pcnet32.c                 |  1 -
 drivers/net/ethernet/amd/sun3lance.c               |  3 ---
 drivers/net/ethernet/amd/sunlance.c                |  4 ----
 drivers/net/ethernet/atheros/atl1e/atl1e_main.c    |  6 ++----
 drivers/net/ethernet/atheros/atlx/atl2.c           |  3 ---
 drivers/net/ethernet/broadcom/bgmac.c              |  4 +---
 drivers/net/ethernet/broadcom/sb1250-mac.c         |  5 +----
 drivers/net/ethernet/cadence/at91_ether.c          |  1 -
 drivers/net/ethernet/cirrus/cs89x0.c               |  6 ------
 drivers/net/ethernet/dlink/dl2k.c                  |  7 ++-----
 drivers/net/ethernet/freescale/fec.c               |  2 --
 .../net/ethernet/freescale/fs_enet/fs_enet-main.c  | 17 +++--------------
 drivers/net/ethernet/fujitsu/fmvj18x_cs.c          |  2 --
 drivers/net/ethernet/i825xx/82596.c                |  8 +++-----
 drivers/net/ethernet/i825xx/lib82596.c             |  6 ++----
 drivers/net/ethernet/ibm/ehea/ehea_main.c          |  9 ++-------
 drivers/net/ethernet/mellanox/mlx4/en_selftest.c   |  5 ++---
 drivers/net/ethernet/natsemi/sonic.c               |  1 -
 drivers/net/ethernet/netx-eth.c                    |  2 --
 drivers/net/ethernet/nuvoton/w90p910_ether.c       |  1 -
 drivers/net/ethernet/nvidia/forcedeth.c            |  1 -
 drivers/net/ethernet/qlogic/qla3xxx.c              |  1 -
 drivers/net/ethernet/qlogic/qlge/qlge_main.c       |  6 ------
 drivers/net/ethernet/rdc/r6040.c                   |  1 -
 drivers/net/ethernet/realtek/8139too.c             |  2 --
 drivers/net/ethernet/realtek/atp.c                 |  2 --
 drivers/net/ethernet/seeq/ether3.c                 | 22 +++++-----------------
 drivers/net/ethernet/seeq/sgiseeq.c                |  2 --
 drivers/net/ethernet/sis/sis900.c                  |  7 ++-----
 drivers/net/ethernet/smsc/smc9194.c                |  2 --
 drivers/net/ethernet/smsc/smc91x.c                 |  2 --
 drivers/net/ethernet/smsc/smsc9420.c               |  4 +---
 drivers/net/ethernet/sun/sunqe.c                   |  5 +----
 drivers/net/ethernet/tehuti/tehuti.c               |  5 ++---
 drivers/net/ethernet/ti/tlan.c                     |  4 +---
 drivers/net/ethernet/xilinx/ll_temac_main.c        | 10 +++-------
 drivers/net/ethernet/xilinx/xilinx_axienet_main.c  |  9 +++------
 drivers/net/ethernet/xircom/xirc2ps_cs.c           |  1 -
 47 files changed, 39 insertions(+), 161 deletions(-)

diff --git a/drivers/net/caif/caif_shmcore.c b/drivers/net/caif/caif_shmcore.c
index bce8bac..cca2afc 100644
--- a/drivers/net/caif/caif_shmcore.c
+++ b/drivers/net/caif/caif_shmcore.c
@@ -338,11 +338,8 @@ static void shm_rx_work_func(struct work_struct *rx_work)
 			/* Get a suitable CAIF packet and copy in data. */
 			skb = netdev_alloc_skb(pshm_drv->pshm_dev->pshm_netdev,
 							frm_pck_len + 1);
-
-			if (skb == NULL) {
-				pr_info("OOM: Try next frame in descriptor\n");
+			if (skb == NULL)
 				break;
-			}
 
 			p = skb_put(skb, frm_pck_len);
 			memcpy(p, pbuf->desc_vptr + frm_pck_ofs, frm_pck_len);
diff --git a/drivers/net/ethernet/adi/bfin_mac.c b/drivers/net/ethernet/adi/bfin_mac.c
index a175d0b..ee70577 100644
--- a/drivers/net/ethernet/adi/bfin_mac.c
+++ b/drivers/net/ethernet/adi/bfin_mac.c
@@ -188,10 +188,9 @@ static int desc_list_init(struct net_device *dev)
 
 		/* allocate a new skb for next time receive */
 		new_skb = netdev_alloc_skb(dev, PKT_BUF_SZ + NET_IP_ALIGN);
-		if (!new_skb) {
-			pr_notice("init: low on mem - packet dropped\n");
+		if (!new_skb)
 			goto init_error;
-		}
+
 		skb_reserve(new_skb, NET_IP_ALIGN);
 		/* Invidate the data cache of skb->data range when it is write back
 		 * cache. It will prevent overwritting the new data from DMA
@@ -1236,7 +1235,6 @@ static void bfin_mac_rx(struct net_device *dev)
 
 	new_skb = netdev_alloc_skb(dev, PKT_BUF_SZ + NET_IP_ALIGN);
 	if (!new_skb) {
-		netdev_notice(dev, "rx: low on mem - packet dropped\n");
 		dev->stats.rx_dropped++;
 		goto out;
 	}
diff --git a/drivers/net/ethernet/amd/7990.c b/drivers/net/ethernet/amd/7990.c
index 6e722dc..65926a9 100644
--- a/drivers/net/ethernet/amd/7990.c
+++ b/drivers/net/ethernet/amd/7990.c
@@ -318,8 +318,6 @@ static int lance_rx (struct net_device *dev)
 			struct sk_buff *skb = netdev_alloc_skb(dev, len + 2);
 
                         if (!skb) {
-                                printk ("%s: Memory squeeze, deferring packet.\n",
-                                        dev->name);
                                 dev->stats.rx_dropped++;
                                 rd->mblength = 0;
                                 rd->rmd1_bits = LE_R1_OWN;
diff --git a/drivers/net/ethernet/amd/a2065.c b/drivers/net/ethernet/amd/a2065.c
index 3789aff..0866e76 100644
--- a/drivers/net/ethernet/amd/a2065.c
+++ b/drivers/net/ethernet/amd/a2065.c
@@ -293,7 +293,6 @@ static int lance_rx(struct net_device *dev)
 			struct sk_buff *skb = netdev_alloc_skb(dev, len + 2);
 
 			if (!skb) {
-				netdev_warn(dev, "Memory squeeze, deferring packet\n");
 				dev->stats.rx_dropped++;
 				rd->mblength = 0;
 				rd->rmd1_bits = LE_R1_OWN;
diff --git a/drivers/net/ethernet/amd/am79c961a.c b/drivers/net/ethernet/amd/am79c961a.c
index 60e2b70..9793767 100644
--- a/drivers/net/ethernet/amd/am79c961a.c
+++ b/drivers/net/ethernet/amd/am79c961a.c
@@ -528,7 +528,6 @@ am79c961_rx(struct net_device *dev, struct dev_priv *priv)
 			dev->stats.rx_packets++;
 		} else {
 			am_writeword (dev, hdraddr + 2, RMD_OWN);
-			printk (KERN_WARNING "%s: memory squeeze, dropping packet.\n", dev->name);
 			dev->stats.rx_dropped++;
 			break;
 		}
diff --git a/drivers/net/ethernet/amd/ariadne.c b/drivers/net/ethernet/amd/ariadne.c
index 98f4522..c178eb4 100644
--- a/drivers/net/ethernet/amd/ariadne.c
+++ b/drivers/net/ethernet/amd/ariadne.c
@@ -193,7 +193,6 @@ static int ariadne_rx(struct net_device *dev)
 
 			skb = netdev_alloc_skb(dev, pkt_len + 2);
 			if (skb == NULL) {
-				netdev_warn(dev, "Memory squeeze, deferring packet\n");
 				for (i = 0; i < RX_RING_SIZE; i++)
 					if (lowb(priv->rx_ring[(entry + i) % RX_RING_SIZE]->RMD1) & RF_OWN)
 						break;
diff --git a/drivers/net/ethernet/amd/atarilance.c b/drivers/net/ethernet/amd/atarilance.c
index 84219df..ab9bedb 100644
--- a/drivers/net/ethernet/amd/atarilance.c
+++ b/drivers/net/ethernet/amd/atarilance.c
@@ -996,8 +996,6 @@ static int lance_rx( struct net_device *dev )
 			else {
 				skb = netdev_alloc_skb(dev, pkt_len + 2);
 				if (skb == NULL) {
-					DPRINTK( 1, ( "%s: Memory squeeze, deferring packet.\n",
-								  dev->name ));
 					for( i = 0; i < RX_RING_SIZE; i++ )
 						if (MEM->rx_head[(entry+i) & RX_RING_MOD_MASK].flag &
 							RMD1_OWN_CHIP)
diff --git a/drivers/net/ethernet/amd/au1000_eth.c b/drivers/net/ethernet/amd/au1000_eth.c
index de774d4..688aede 100644
--- a/drivers/net/ethernet/amd/au1000_eth.c
+++ b/drivers/net/ethernet/amd/au1000_eth.c
@@ -727,7 +727,6 @@ static int au1000_rx(struct net_device *dev)
 			frmlen -= 4; /* Remove FCS */
 			skb = netdev_alloc_skb(dev, frmlen + 2);
 			if (skb == NULL) {
-				netdev_err(dev, "Memory squeeze, dropping packet.\n");
 				dev->stats.rx_dropped++;
 				continue;
 			}
diff --git a/drivers/net/ethernet/amd/declance.c b/drivers/net/ethernet/amd/declance.c
index baca0bd..3d86ffe 100644
--- a/drivers/net/ethernet/amd/declance.c
+++ b/drivers/net/ethernet/amd/declance.c
@@ -607,8 +607,6 @@ static int lance_rx(struct net_device *dev)
 			skb = netdev_alloc_skb(dev, len + 2);
 
 			if (skb == 0) {
-				printk("%s: Memory squeeze, deferring packet.\n",
-				       dev->name);
 				dev->stats.rx_dropped++;
 				*rds_ptr(rd, mblength, lp->type) = 0;
 				*rds_ptr(rd, rmd1, lp->type) =
diff --git a/drivers/net/ethernet/amd/pcnet32.c b/drivers/net/ethernet/amd/pcnet32.c
index 797f847..ed21307 100644
--- a/drivers/net/ethernet/amd/pcnet32.c
+++ b/drivers/net/ethernet/amd/pcnet32.c
@@ -1166,7 +1166,6 @@ static void pcnet32_rx_entry(struct net_device *dev,
 		skb = netdev_alloc_skb(dev, pkt_len + NET_IP_ALIGN);
 
 	if (skb == NULL) {
-		netif_err(lp, drv, dev, "Memory squeeze, dropping packet\n");
 		dev->stats.rx_dropped++;
 		return;
 	}
diff --git a/drivers/net/ethernet/amd/sun3lance.c b/drivers/net/ethernet/amd/sun3lance.c
index 74b3891..de412d3 100644
--- a/drivers/net/ethernet/amd/sun3lance.c
+++ b/drivers/net/ethernet/amd/sun3lance.c
@@ -812,9 +812,6 @@ static int lance_rx( struct net_device *dev )
 			else {
 				skb = netdev_alloc_skb(dev, pkt_len + 2);
 				if (skb == NULL) {
-					DPRINTK( 1, ( "%s: Memory squeeze, deferring packet.\n",
-						      dev->name ));
-
 					dev->stats.rx_dropped++;
 					head->msg_length = 0;
 					head->flag |= RMD1_OWN_CHIP;
diff --git a/drivers/net/ethernet/amd/sunlance.c b/drivers/net/ethernet/amd/sunlance.c
index 6a40290..70d5430 100644
--- a/drivers/net/ethernet/amd/sunlance.c
+++ b/drivers/net/ethernet/amd/sunlance.c
@@ -536,8 +536,6 @@ static void lance_rx_dvma(struct net_device *dev)
 			skb = netdev_alloc_skb(dev, len + 2);
 
 			if (skb == NULL) {
-				printk(KERN_INFO "%s: Memory squeeze, deferring packet.\n",
-				       dev->name);
 				dev->stats.rx_dropped++;
 				rd->mblength = 0;
 				rd->rmd1_bits = LE_R1_OWN;
@@ -708,8 +706,6 @@ static void lance_rx_pio(struct net_device *dev)
 			skb = netdev_alloc_skb(dev, len + 2);
 
 			if (skb == NULL) {
-				printk(KERN_INFO "%s: Memory squeeze, deferring packet.\n",
-				       dev->name);
 				dev->stats.rx_dropped++;
 				sbus_writew(0, &rd->mblength);
 				sbus_writeb(LE_R1_OWN, &rd->rmd1_bits);
diff --git a/drivers/net/ethernet/atheros/atl1e/atl1e_main.c b/drivers/net/ethernet/atheros/atl1e/atl1e_main.c
index 92f4734..e1f1b2a 100644
--- a/drivers/net/ethernet/atheros/atl1e/atl1e_main.c
+++ b/drivers/net/ethernet/atheros/atl1e/atl1e_main.c
@@ -1420,11 +1420,9 @@ static void atl1e_clean_rx_irq(struct atl1e_adapter *adapter, u8 que,
 			packet_size = ((prrs->word1 >> RRS_PKT_SIZE_SHIFT) &
 					RRS_PKT_SIZE_MASK) - 4; /* CRC */
 			skb = netdev_alloc_skb_ip_align(netdev, packet_size);
-			if (skb == NULL) {
-				netdev_warn(netdev,
-					    "Memory squeeze, deferring packet\n");
+			if (skb == NULL)
 				goto skip_pkt;
-			}
+
 			memcpy(skb->data, (u8 *)(prrs + 1), packet_size);
 			skb_put(skb, packet_size);
 			skb->protocol = eth_type_trans(skb, netdev);
diff --git a/drivers/net/ethernet/atheros/atlx/atl2.c b/drivers/net/ethernet/atheros/atlx/atl2.c
index 1278b47..a046b6f 100644
--- a/drivers/net/ethernet/atheros/atlx/atl2.c
+++ b/drivers/net/ethernet/atheros/atlx/atl2.c
@@ -437,9 +437,6 @@ static void atl2_intr_rx(struct atl2_adapter *adapter)
 			/* alloc new buffer */
 			skb = netdev_alloc_skb_ip_align(netdev, rx_size);
 			if (NULL == skb) {
-				printk(KERN_WARNING
-					"%s: Mem squeeze, deferring packet.\n",
-					netdev->name);
 				/*
 				 * Check that some rx space is free. If not,
 				 * free one and mark stats->rx_dropped++.
diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/ethernet/broadcom/bgmac.c
index d6cb376..eec0af4 100644
--- a/drivers/net/ethernet/broadcom/bgmac.c
+++ b/drivers/net/ethernet/broadcom/bgmac.c
@@ -245,10 +245,8 @@ static int bgmac_dma_rx_skb_for_slot(struct bgmac *bgmac,
 
 	/* Alloc skb */
 	slot->skb = netdev_alloc_skb(bgmac->net_dev, BGMAC_RX_BUF_SIZE);
-	if (!slot->skb) {
-		bgmac_err(bgmac, "Allocation of skb failed!\n");
+	if (!slot->skb)
 		return -ENOMEM;
-	}
 
 	/* Poison - if everything goes fine, hardware will overwrite it */
 	rx = (struct bgmac_rx_header *)slot->skb->data;
diff --git a/drivers/net/ethernet/broadcom/sb1250-mac.c b/drivers/net/ethernet/broadcom/sb1250-mac.c
index e9b35da..e80bfb6 100644
--- a/drivers/net/ethernet/broadcom/sb1250-mac.c
+++ b/drivers/net/ethernet/broadcom/sb1250-mac.c
@@ -831,11 +831,8 @@ static int sbdma_add_rcvbuffer(struct sbmac_softc *sc, struct sbmacdma *d,
 		sb_new = netdev_alloc_skb(dev, ENET_PACKET_SIZE +
 					       SMP_CACHE_BYTES * 2 +
 					       NET_IP_ALIGN);
-		if (sb_new == NULL) {
-			pr_info("%s: sk_buff allocation failed\n",
-			       d->sbdma_eth->sbm_dev->name);
+		if (sb_new == NULL)
 			return -ENOBUFS;
-		}
 
 		sbdma_align_skb(sb_new, SMP_CACHE_BYTES, NET_IP_ALIGN);
 	}
diff --git a/drivers/net/ethernet/cadence/at91_ether.c b/drivers/net/ethernet/cadence/at91_ether.c
index 1a57e16..5bd7786 100644
--- a/drivers/net/ethernet/cadence/at91_ether.c
+++ b/drivers/net/ethernet/cadence/at91_ether.c
@@ -209,7 +209,6 @@ static void at91ether_rx(struct net_device *dev)
 			netif_rx(skb);
 		} else {
 			lp->stats.rx_dropped++;
-			netdev_notice(dev, "Memory squeeze, dropping packet.\n");
 		}
 
 		if (lp->rx_ring[lp->rx_tail].ctrl & MACB_BIT(RX_MHASH_MATCH))
diff --git a/drivers/net/ethernet/cirrus/cs89x0.c b/drivers/net/ethernet/cirrus/cs89x0.c
index 73c1c8c..aaa0499 100644
--- a/drivers/net/ethernet/cirrus/cs89x0.c
+++ b/drivers/net/ethernet/cirrus/cs89x0.c
@@ -478,9 +478,6 @@ dma_rx(struct net_device *dev)
 	/* Malloc up new buffer. */
 	skb = netdev_alloc_skb(dev, length + 2);
 	if (skb == NULL) {
-		/* I don't think we want to do this to a stressed system */
-		cs89_dbg(0, err, "%s: Memory squeeze, dropping packet\n",
-			 dev->name);
 		dev->stats.rx_dropped++;
 
 		/* AKPM: advance bp to the next frame */
@@ -731,9 +728,6 @@ net_rx(struct net_device *dev)
 	/* Malloc up new buffer. */
 	skb = netdev_alloc_skb(dev, length + 2);
 	if (skb == NULL) {
-#if 0		/* Again, this seems a cruel thing to do */
-		pr_warn("%s: Memory squeeze, dropping packet\n", dev->name);
-#endif
 		dev->stats.rx_dropped++;
 		return;
 	}
diff --git a/drivers/net/ethernet/dlink/dl2k.c b/drivers/net/ethernet/dlink/dl2k.c
index 110d26f..afa8e3a 100644
--- a/drivers/net/ethernet/dlink/dl2k.c
+++ b/drivers/net/ethernet/dlink/dl2k.c
@@ -580,12 +580,9 @@ alloc_list (struct net_device *dev)
 
 		skb = netdev_alloc_skb_ip_align(dev, np->rx_buf_sz);
 		np->rx_skbuff[i] = skb;
-		if (skb == NULL) {
-			printk (KERN_ERR
-				"%s: alloc_list: allocate Rx buffer error! ",
-				dev->name);
+		if (skb == NULL)
 			break;
-		}
+
 		/* Rubicon now supports 40 bits of addressing space. */
 		np->rx_ring[i].fraginfo =
 		    cpu_to_le64 ( pci_map_single (
diff --git a/drivers/net/ethernet/freescale/fec.c b/drivers/net/ethernet/freescale/fec.c
index 069a155..f97c60f 100644
--- a/drivers/net/ethernet/freescale/fec.c
+++ b/drivers/net/ethernet/freescale/fec.c
@@ -743,8 +743,6 @@ fec_enet_rx(struct net_device *ndev, int budget)
 		skb = netdev_alloc_skb(ndev, pkt_len - 4 + NET_IP_ALIGN);
 
 		if (unlikely(!skb)) {
-			printk("%s: Memory squeeze, dropping packet.\n",
-					ndev->name);
 			ndev->stats.rx_dropped++;
 		} else {
 			skb_reserve(skb, NET_IP_ALIGN);
diff --git a/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c b/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c
index 46df288..edc1200 100644
--- a/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c
+++ b/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c
@@ -177,8 +177,6 @@ static int fs_enet_rx_napi(struct napi_struct *napi, int budget)
 				received++;
 				netif_receive_skb(skb);
 			} else {
-				dev_warn(fep->dev,
-					 "Memory squeeze, dropping packet.\n");
 				fep->stats.rx_dropped++;
 				skbn = skb;
 			}
@@ -309,8 +307,6 @@ static int fs_enet_rx_non_napi(struct net_device *dev)
 				received++;
 				netif_rx(skb);
 			} else {
-				dev_warn(fep->dev,
-					 "Memory squeeze, dropping packet.\n");
 				fep->stats.rx_dropped++;
 				skbn = skb;
 			}
@@ -505,11 +501,9 @@ void fs_init_bds(struct net_device *dev)
 	 */
 	for (i = 0, bdp = fep->rx_bd_base; i < fep->rx_ring; i++, bdp++) {
 		skb = netdev_alloc_skb(dev, ENET_RX_FRSIZE);
-		if (skb == NULL) {
-			dev_warn(fep->dev,
-				 "Memory squeeze, unable to allocate skb\n");
+		if (skb == NULL)
 			break;
-		}
+
 		skb_align(skb, ENET_RX_ALIGN);
 		fep->rx_skbuff[i] = skb;
 		CBDW_BUFADDR(bdp,
@@ -593,13 +587,8 @@ static struct sk_buff *tx_skb_align_workaround(struct net_device *dev,
 
 	/* Alloc new skb */
 	new_skb = netdev_alloc_skb(dev, skb->len + 4);
-	if (!new_skb) {
-		if (net_ratelimit()) {
-			dev_warn(fep->dev,
-				 "Memory squeeze, dropping tx packet.\n");
-		}
+	if (!new_skb)
 		return NULL;
-	}
 
 	/* Make sure new skb is properly aligned */
 	skb_align(new_skb, 4);
diff --git a/drivers/net/ethernet/fujitsu/fmvj18x_cs.c b/drivers/net/ethernet/fujitsu/fmvj18x_cs.c
index 2418faf..8412570 100644
--- a/drivers/net/ethernet/fujitsu/fmvj18x_cs.c
+++ b/drivers/net/ethernet/fujitsu/fmvj18x_cs.c
@@ -1003,8 +1003,6 @@ static void fjn_rx(struct net_device *dev)
 	    }
 	    skb = netdev_alloc_skb(dev, pkt_len + 2);
 	    if (skb == NULL) {
-		netdev_notice(dev, "Memory squeeze, dropping packet (len %d)\n",
-			      pkt_len);
 		outb(F_SKP_PKT, ioaddr + RX_SKIP);
 		dev->stats.rx_dropped++;
 		break;
diff --git a/drivers/net/ethernet/i825xx/82596.c b/drivers/net/ethernet/i825xx/82596.c
index 1c54e22..e388161 100644
--- a/drivers/net/ethernet/i825xx/82596.c
+++ b/drivers/net/ethernet/i825xx/82596.c
@@ -798,16 +798,14 @@ static inline int i596_rx(struct net_device *dev)
 #ifdef __mc68000__
 				cache_clear(virt_to_phys(newskb->data), PKT_BUF_SZ);
 #endif
-			}
-			else
+			} else {
 				skb = netdev_alloc_skb(dev, pkt_len + 2);
+			}
 memory_squeeze:
 			if (skb == NULL) {
 				/* XXX tulip.c can defer packets here!! */
-				printk(KERN_WARNING "%s: i596_rx Memory squeeze, dropping packet.\n", dev->name);
 				dev->stats.rx_dropped++;
-			}
-			else {
+			} else {
 				if (!rx_in_place) {
 					/* 16 byte align the data fields */
 					skb_reserve(skb, 2);
diff --git a/drivers/net/ethernet/i825xx/lib82596.c b/drivers/net/ethernet/i825xx/lib82596.c
index f045ea4..d653bac 100644
--- a/drivers/net/ethernet/i825xx/lib82596.c
+++ b/drivers/net/ethernet/i825xx/lib82596.c
@@ -715,14 +715,12 @@ static inline int i596_rx(struct net_device *dev)
 				rbd->v_data = newskb->data;
 				rbd->b_data = SWAP32(dma_addr);
 				DMA_WBACK_INV(dev, rbd, sizeof(struct i596_rbd));
-			} else
+			} else {
 				skb = netdev_alloc_skb_ip_align(dev, pkt_len);
+			}
 memory_squeeze:
 			if (skb == NULL) {
 				/* XXX tulip.c can defer packets here!! */
-				printk(KERN_ERR
-				       "%s: i596_rx Memory squeeze, dropping packet.\n",
-				       dev->name);
 				dev->stats.rx_dropped++;
 			} else {
 				if (!rx_in_place) {
diff --git a/drivers/net/ethernet/ibm/ehea/ehea_main.c b/drivers/net/ethernet/ibm/ehea/ehea_main.c
index 328f47c..0296334 100644
--- a/drivers/net/ethernet/ibm/ehea/ehea_main.c
+++ b/drivers/net/ethernet/ibm/ehea/ehea_main.c
@@ -402,7 +402,6 @@ static void ehea_refill_rq1(struct ehea_port_res *pr, int index, int nr_of_wqes)
 			skb_arr_rq1[index] = netdev_alloc_skb(dev,
 							      EHEA_L_PKT_SIZE);
 			if (!skb_arr_rq1[index]) {
-				netdev_info(dev, "Unable to allocate enough skb in the array\n");
 				pr->rq1_skba.os_skbs = fill_wqes - i;
 				break;
 			}
@@ -432,10 +431,8 @@ static void ehea_init_fill_rq1(struct ehea_port_res *pr, int nr_rq1a)
 
 	for (i = 0; i < nr_rq1a; i++) {
 		skb_arr_rq1[i] = netdev_alloc_skb(dev, EHEA_L_PKT_SIZE);
-		if (!skb_arr_rq1[i]) {
-			netdev_info(dev, "Not enough memory to allocate skb array\n");
+		if (!skb_arr_rq1[i])
 			break;
-		}
 	}
 	/* Ring doorbell */
 	ehea_update_rq1a(pr->qp, i - 1);
@@ -695,10 +692,8 @@ static int ehea_proc_rwqes(struct net_device *dev,
 
 					skb = netdev_alloc_skb(dev,
 							       EHEA_L_PKT_SIZE);
-					if (!skb) {
-						netdev_err(dev, "Not enough memory to allocate skb\n");
+					if (!skb)
 						break;
-					}
 				}
 				skb_copy_to_linear_data(skb, ((char *)cqe) + 64,
 						 cqe->num_bytes_transfered - 4);
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_selftest.c b/drivers/net/ethernet/mellanox/mlx4/en_selftest.c
index 3488c6d..2448f0d 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_selftest.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_selftest.c
@@ -58,10 +58,9 @@ static int mlx4_en_test_loopback_xmit(struct mlx4_en_priv *priv)
 
 	/* build the pkt before xmit */
 	skb = netdev_alloc_skb(priv->dev, MLX4_LOOPBACK_TEST_PAYLOAD + ETH_HLEN + NET_IP_ALIGN);
-	if (!skb) {
-		en_err(priv, "-LOOPBACK_TEST_XMIT- failed to create skb for xmit\n");
+	if (!skb)
 		return -ENOMEM;
-	}
+
 	skb_reserve(skb, NET_IP_ALIGN);
 
 	ethh = (struct ethhdr *)skb_put(skb, sizeof(struct ethhdr));
diff --git a/drivers/net/ethernet/natsemi/sonic.c b/drivers/net/ethernet/natsemi/sonic.c
index 46795e4..1bd419d 100644
--- a/drivers/net/ethernet/natsemi/sonic.c
+++ b/drivers/net/ethernet/natsemi/sonic.c
@@ -424,7 +424,6 @@ static void sonic_rx(struct net_device *dev)
 			/* Malloc up new buffer. */
 			new_skb = netdev_alloc_skb(dev, SONIC_RBSIZE + 2);
 			if (new_skb == NULL) {
-				printk(KERN_ERR "%s: Memory squeeze, dropping packet.\n", dev->name);
 				lp->stats.rx_dropped++;
 				break;
 			}
diff --git a/drivers/net/ethernet/netx-eth.c b/drivers/net/ethernet/netx-eth.c
index 63e7af4..cb9e638 100644
--- a/drivers/net/ethernet/netx-eth.c
+++ b/drivers/net/ethernet/netx-eth.c
@@ -152,8 +152,6 @@ static void netx_eth_receive(struct net_device *ndev)
 
 	skb = netdev_alloc_skb(ndev, len);
 	if (unlikely(skb == NULL)) {
-		printk(KERN_NOTICE "%s: Low memory, packet dropped.\n",
-			ndev->name);
 		ndev->stats.rx_dropped++;
 		return;
 	}
diff --git a/drivers/net/ethernet/nuvoton/w90p910_ether.c b/drivers/net/ethernet/nuvoton/w90p910_ether.c
index 162da89..539d202 100644
--- a/drivers/net/ethernet/nuvoton/w90p910_ether.c
+++ b/drivers/net/ethernet/nuvoton/w90p910_ether.c
@@ -737,7 +737,6 @@ static void netdev_rx(struct net_device *dev)
 			data = ether->rdesc->recv_buf[ether->cur_rx];
 			skb = netdev_alloc_skb(dev, length + 2);
 			if (!skb) {
-				dev_err(&pdev->dev, "get skb buffer error\n");
 				ether->stats.rx_dropped++;
 				return;
 			}
diff --git a/drivers/net/ethernet/nvidia/forcedeth.c b/drivers/net/ethernet/nvidia/forcedeth.c
index 0b8de12..b62262c 100644
--- a/drivers/net/ethernet/nvidia/forcedeth.c
+++ b/drivers/net/ethernet/nvidia/forcedeth.c
@@ -5025,7 +5025,6 @@ static int nv_loopback_test(struct net_device *dev)
 	pkt_len = ETH_DATA_LEN;
 	tx_skb = netdev_alloc_skb(dev, pkt_len);
 	if (!tx_skb) {
-		netdev_err(dev, "netdev_alloc_skb() failed during loopback test\n");
 		ret = 0;
 		goto out;
 	}
diff --git a/drivers/net/ethernet/qlogic/qla3xxx.c b/drivers/net/ethernet/qlogic/qla3xxx.c
index 8fd38cb6..91a8fcd 100644
--- a/drivers/net/ethernet/qlogic/qla3xxx.c
+++ b/drivers/net/ethernet/qlogic/qla3xxx.c
@@ -312,7 +312,6 @@ static void ql_release_to_lrg_buf_free_list(struct ql3_adapter *qdev,
 		lrg_buf_cb->skb = netdev_alloc_skb(qdev->ndev,
 						   qdev->lrg_buffer_len);
 		if (unlikely(!lrg_buf_cb->skb)) {
-			netdev_err(qdev->ndev, "failed netdev_alloc_skb()\n");
 			qdev->lrg_buf_skb_check++;
 		} else {
 			/*
diff --git a/drivers/net/ethernet/qlogic/qlge/qlge_main.c b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
index b13ab54..1dd778a 100644
--- a/drivers/net/ethernet/qlogic/qlge/qlge_main.c
+++ b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
@@ -1211,8 +1211,6 @@ static void ql_update_sbq(struct ql_adapter *qdev, struct rx_ring *rx_ring)
 				    netdev_alloc_skb(qdev->ndev,
 						     SMALL_BUFFER_SIZE);
 				if (sbq_desc->p.skb == NULL) {
-					netif_err(qdev, probe, qdev->ndev,
-						  "Couldn't get an skb.\n");
 					rx_ring->sbq_clean_idx = clean_idx;
 					return;
 				}
@@ -1519,8 +1517,6 @@ static void ql_process_mac_rx_page(struct ql_adapter *qdev,
 
 	skb = netdev_alloc_skb(ndev, length);
 	if (!skb) {
-		netif_err(qdev, drv, qdev->ndev,
-			  "Couldn't get an skb, need to unwind!.\n");
 		rx_ring->rx_dropped++;
 		put_page(lbq_desc->p.pg_chunk.page);
 		return;
@@ -1605,8 +1601,6 @@ static void ql_process_mac_rx_skb(struct ql_adapter *qdev,
 	/* Allocate new_skb and copy */
 	new_skb = netdev_alloc_skb(qdev->ndev, length + NET_IP_ALIGN);
 	if (new_skb == NULL) {
-		netif_err(qdev, probe, qdev->ndev,
-			  "No skb available, drop the packet.\n");
 		rx_ring->rx_dropped++;
 		return;
 	}
diff --git a/drivers/net/ethernet/rdc/r6040.c b/drivers/net/ethernet/rdc/r6040.c
index d5622ab..e9dc849 100644
--- a/drivers/net/ethernet/rdc/r6040.c
+++ b/drivers/net/ethernet/rdc/r6040.c
@@ -350,7 +350,6 @@ static int r6040_alloc_rxbufs(struct net_device *dev)
 	do {
 		skb = netdev_alloc_skb(dev, MAX_BUF_SIZE);
 		if (!skb) {
-			netdev_err(dev, "failed to alloc skb for rx\n");
 			rc = -ENOMEM;
 			goto err_exit;
 		}
diff --git a/drivers/net/ethernet/realtek/8139too.c b/drivers/net/ethernet/realtek/8139too.c
index 1276ac7..3ccedeb 100644
--- a/drivers/net/ethernet/realtek/8139too.c
+++ b/drivers/net/ethernet/realtek/8139too.c
@@ -2041,8 +2041,6 @@ keep_pkt:
 
 			netif_receive_skb (skb);
 		} else {
-			if (net_ratelimit())
-				netdev_warn(dev, "Memory squeeze, dropping packet\n");
 			dev->stats.rx_dropped++;
 		}
 		received++;
diff --git a/drivers/net/ethernet/realtek/atp.c b/drivers/net/ethernet/realtek/atp.c
index 9f2d416..d77d60e 100644
--- a/drivers/net/ethernet/realtek/atp.c
+++ b/drivers/net/ethernet/realtek/atp.c
@@ -782,8 +782,6 @@ static void net_rx(struct net_device *dev)
 
 		skb = netdev_alloc_skb(dev, pkt_len + 2);
 		if (skb == NULL) {
-			printk(KERN_ERR "%s: Memory squeeze, dropping packet.\n",
-				   dev->name);
 			dev->stats.rx_dropped++;
 			goto done;
 		}
diff --git a/drivers/net/ethernet/seeq/ether3.c b/drivers/net/ethernet/seeq/ether3.c
index 3aca578..bdac936 100644
--- a/drivers/net/ethernet/seeq/ether3.c
+++ b/drivers/net/ethernet/seeq/ether3.c
@@ -651,8 +651,11 @@ if (next_ptr < RX_START || next_ptr >= RX_END) {
 				skb->protocol = eth_type_trans(skb, dev);
 				netif_rx(skb);
 				received ++;
-			} else
-				goto dropping;
+			} else {
+				ether3_outw(next_ptr >> 8, REG_RECVEND);
+				dev->stats.rx_dropped++;
+				goto done;
+			}
 		} else {
 			struct net_device_stats *stats = &dev->stats;
 			ether3_outw(next_ptr >> 8, REG_RECVEND);
@@ -679,21 +682,6 @@ done:
 	}
 
 	return maxcnt;
-
-dropping:{
-	static unsigned long last_warned;
-
-	ether3_outw(next_ptr >> 8, REG_RECVEND);
-	/*
-	 * Don't print this message too many times...
-	 */
-	if (time_after(jiffies, last_warned + 10 * HZ)) {
-		last_warned = jiffies;
-		printk("%s: memory squeeze, dropping packet.\n", dev->name);
-	}
-	dev->stats.rx_dropped++;
-	goto done;
-	}
 }
 
 /*
diff --git a/drivers/net/ethernet/seeq/sgiseeq.c b/drivers/net/ethernet/seeq/sgiseeq.c
index 0fde9ca..0ad5694 100644
--- a/drivers/net/ethernet/seeq/sgiseeq.c
+++ b/drivers/net/ethernet/seeq/sgiseeq.c
@@ -381,8 +381,6 @@ memory_squeeze:
 					dev->stats.rx_packets++;
 					dev->stats.rx_bytes += len;
 				} else {
-					printk(KERN_NOTICE "%s: Memory squeeze, deferring packet.\n",
-						dev->name);
 					dev->stats.rx_dropped++;
 				}
 			} else {
diff --git a/drivers/net/ethernet/sis/sis900.c b/drivers/net/ethernet/sis/sis900.c
index efca14e..e458296 100644
--- a/drivers/net/ethernet/sis/sis900.c
+++ b/drivers/net/ethernet/sis/sis900.c
@@ -1841,15 +1841,12 @@ refill_rx_ring:
 		entry = sis_priv->dirty_rx % NUM_RX_DESC;
 
 		if (sis_priv->rx_skbuff[entry] == NULL) {
-			if ((skb = netdev_alloc_skb(net_dev, RX_BUF_SIZE)) == NULL) {
+			skb = netdev_alloc_skb(net_dev, RX_BUF_SIZE);
+			if (skb == NULL) {
 				/* not enough memory for skbuff, this makes a
 				 * "hole" on the buffer ring, it is not clear
 				 * how the hardware will react to this kind
 				 * of degenerated buffer */
-				if (netif_msg_rx_err(sis_priv))
-					printk(KERN_INFO "%s: Memory squeeze, "
-						"deferring packet.\n",
-						net_dev->name);
 				net_dev->stats.rx_dropped++;
 				break;
 			}
diff --git a/drivers/net/ethernet/smsc/smc9194.c b/drivers/net/ethernet/smsc/smc9194.c
index 50823da..e85c2e7 100644
--- a/drivers/net/ethernet/smsc/smc9194.c
+++ b/drivers/net/ethernet/smsc/smc9194.c
@@ -1223,9 +1223,7 @@ static void smc_rcv(struct net_device *dev)
 			dev->stats.multicast++;
 
 		skb = netdev_alloc_skb(dev, packet_length + 5);
-
 		if ( skb == NULL ) {
-			printk(KERN_NOTICE CARDNAME ": Low memory, packet dropped.\n");
 			dev->stats.rx_dropped++;
 			goto done;
 		}
diff --git a/drivers/net/ethernet/smsc/smc91x.c b/drivers/net/ethernet/smsc/smc91x.c
index 591650a..dfbf978 100644
--- a/drivers/net/ethernet/smsc/smc91x.c
+++ b/drivers/net/ethernet/smsc/smc91x.c
@@ -465,8 +465,6 @@ static inline void  smc_rcv(struct net_device *dev)
 		 */
 		skb = netdev_alloc_skb(dev, packet_len);
 		if (unlikely(skb == NULL)) {
-			printk(KERN_NOTICE "%s: Low memory, packet dropped.\n",
-				dev->name);
 			SMC_WAIT_MMU_BUSY(lp);
 			SMC_SET_MMU_CMD(lp, MC_RELEASE);
 			dev->stats.rx_dropped++;
diff --git a/drivers/net/ethernet/smsc/smsc9420.c b/drivers/net/ethernet/smsc/smsc9420.c
index d457fa2..ffa5c4a 100644
--- a/drivers/net/ethernet/smsc/smsc9420.c
+++ b/drivers/net/ethernet/smsc/smsc9420.c
@@ -848,10 +848,8 @@ static int smsc9420_alloc_rx_buffer(struct smsc9420_pdata *pd, int index)
 	BUG_ON(pd->rx_buffers[index].skb);
 	BUG_ON(pd->rx_buffers[index].mapping);
 
-	if (unlikely(!skb)) {
-		smsc_warn(RX_ERR, "Failed to allocate new skb!");
+	if (unlikely(!skb))
 		return -ENOMEM;
-	}
 
 	mapping = pci_map_single(pd->pdev, skb_tail_pointer(skb),
 				 PKT_BUF_SZ, PCI_DMA_FROMDEVICE);
diff --git a/drivers/net/ethernet/sun/sunqe.c b/drivers/net/ethernet/sun/sunqe.c
index 49bf3e2..8182591b 100644
--- a/drivers/net/ethernet/sun/sunqe.c
+++ b/drivers/net/ethernet/sun/sunqe.c
@@ -414,7 +414,7 @@ static void qe_rx(struct sunqe *qep)
 	struct qe_rxd *this;
 	struct sunqe_buffers *qbufs = qep->buffers;
 	__u32 qbufs_dvma = qep->buffers_dvma;
-	int elem = qep->rx_new, drops = 0;
+	int elem = qep->rx_new;
 	u32 flags;
 
 	this = &rxbase[elem];
@@ -436,7 +436,6 @@ static void qe_rx(struct sunqe *qep)
 		} else {
 			skb = netdev_alloc_skb(dev, len + 2);
 			if (skb == NULL) {
-				drops++;
 				dev->stats.rx_dropped++;
 			} else {
 				skb_reserve(skb, 2);
@@ -456,8 +455,6 @@ static void qe_rx(struct sunqe *qep)
 		this = &rxbase[elem];
 	}
 	qep->rx_new = elem;
-	if (drops)
-		printk(KERN_NOTICE "%s: Memory squeeze, deferring packet.\n", qep->dev->name);
 }
 
 static void qe_tx_reclaim(struct sunqe *qep);
diff --git a/drivers/net/ethernet/tehuti/tehuti.c b/drivers/net/ethernet/tehuti/tehuti.c
index e15cc71..e8824ce 100644
--- a/drivers/net/ethernet/tehuti/tehuti.c
+++ b/drivers/net/ethernet/tehuti/tehuti.c
@@ -1102,10 +1102,9 @@ static void bdx_rx_alloc_skbs(struct bdx_priv *priv, struct rxf_fifo *f)
 	dno = bdx_rxdb_available(db) - 1;
 	while (dno > 0) {
 		skb = netdev_alloc_skb(priv->ndev, f->m.pktsz + NET_IP_ALIGN);
-		if (!skb) {
-			pr_err("NO MEM: netdev_alloc_skb failed\n");
+		if (!skb)
 			break;
-		}
+
 		skb_reserve(skb, NET_IP_ALIGN);
 
 		idx = bdx_rxdb_alloc_elem(db);
diff --git a/drivers/net/ethernet/ti/tlan.c b/drivers/net/ethernet/ti/tlan.c
index 2272538..bdda36f 100644
--- a/drivers/net/ethernet/ti/tlan.c
+++ b/drivers/net/ethernet/ti/tlan.c
@@ -1911,10 +1911,8 @@ static void tlan_reset_lists(struct net_device *dev)
 		list->frame_size = TLAN_MAX_FRAME_SIZE;
 		list->buffer[0].count = TLAN_MAX_FRAME_SIZE | TLAN_LAST_BUFFER;
 		skb = netdev_alloc_skb_ip_align(dev, TLAN_MAX_FRAME_SIZE + 5);
-		if (!skb) {
-			netdev_err(dev, "Out of memory for received data\n");
+		if (!skb)
 			break;
-		}
 
 		list->buffer[0].address = pci_map_single(priv->pci_dev,
 							 skb->data,
diff --git a/drivers/net/ethernet/xilinx/ll_temac_main.c b/drivers/net/ethernet/xilinx/ll_temac_main.c
index 9fc2ada..5ac43e4 100644
--- a/drivers/net/ethernet/xilinx/ll_temac_main.c
+++ b/drivers/net/ethernet/xilinx/ll_temac_main.c
@@ -273,11 +273,9 @@ static int temac_dma_bd_init(struct net_device *ndev)
 
 		skb = netdev_alloc_skb_ip_align(ndev,
 						XTE_MAX_JUMBO_FRAME_SIZE);
-
-		if (skb == 0) {
-			dev_err(&ndev->dev, "alloc_skb error %d\n", i);
+		if (!skb)
 			goto out;
-		}
+
 		lp->rx_skb[i] = skb;
 		/* returns physical address of skb->data */
 		lp->rx_bd_v[i].phys = dma_map_single(ndev->dev.parent,
@@ -789,9 +787,7 @@ static void ll_temac_recv(struct net_device *ndev)
 
 		new_skb = netdev_alloc_skb_ip_align(ndev,
 						XTE_MAX_JUMBO_FRAME_SIZE);
-
-		if (new_skb == 0) {
-			dev_err(&ndev->dev, "no memory for new sk_buff\n");
+		if (!new_skb) {
 			spin_unlock_irqrestore(&lp->rx_lock, flags);
 			return;
 		}
diff --git a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
index 278c9db..397d4a6 100644
--- a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
+++ b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
@@ -235,10 +235,8 @@ static int axienet_dma_bd_init(struct net_device *ndev)
 				      ((i + 1) % RX_BD_NUM);
 
 		skb = netdev_alloc_skb_ip_align(ndev, lp->max_frm_size);
-		if (!skb) {
-			dev_err(&ndev->dev, "alloc_skb error %d\n", i);
+		if (!skb)
 			goto out;
-		}
 
 		lp->rx_bd_v[i].sw_id_offset = (u32) skb;
 		lp->rx_bd_v[i].phys = dma_map_single(ndev->dev.parent,
@@ -777,10 +775,9 @@ static void axienet_recv(struct net_device *ndev)
 		packets++;
 
 		new_skb = netdev_alloc_skb_ip_align(ndev, lp->max_frm_size);
-		if (!new_skb) {
-			dev_err(&ndev->dev, "no memory for new sk_buff\n");
+		if (!new_skb)
 			return;
-		}
+
 		cur_p->phys = dma_map_single(ndev->dev.parent, new_skb->data,
 					     lp->max_frm_size,
 					     DMA_FROM_DEVICE);
diff --git a/drivers/net/ethernet/xircom/xirc2ps_cs.c b/drivers/net/ethernet/xircom/xirc2ps_cs.c
index 98e09d0..76210ab 100644
--- a/drivers/net/ethernet/xircom/xirc2ps_cs.c
+++ b/drivers/net/ethernet/xircom/xirc2ps_cs.c
@@ -1041,7 +1041,6 @@ xirc2ps_interrupt(int irq, void *dev_id)
 	    /* 1 extra so we can use insw */
 	    skb = netdev_alloc_skb(dev, pktlen + 3);
 	    if (!skb) {
-		pr_notice("low memory, packet dropped (size=%u)\n", pktlen);
 		dev->stats.rx_dropped++;
 	    } else { /* okay get the packet */
 		skb_reserve(skb, 2);
-- 
1.8.1.2.459.gbcd45b4.dirty
