From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: add skb frag size accessors
Date: Wed, 19 Oct 2011 09:00:24 +0200
Message-ID: <1319007624.16303.5.camel@edumazet-laptop>
References: <1318279267.2567.19.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:58694 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751352Ab1JSHAd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Oct 2011 03:00:33 -0400
Received: by wyg36 with SMTP id 36so1380058wyg.19
        for <netdev@vger.kernel.org>; Wed, 19 Oct 2011 00:00:31 -0700 (PDT)
In-Reply-To: <1318279267.2567.19.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To ease skb->truesize sanitization, its better to be able to localize
all references to skb frags size.

Define accessors : skb_frag_size() to fetch frag size, and
skb_frag_size_{set|add|sub}() to manipulate it.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 drivers/atm/eni.c                                    |    2 
 drivers/infiniband/hw/amso1100/c2.c                  |    4 
 drivers/infiniband/hw/nes/nes_nic.c                  |   10 -
 drivers/infiniband/ulp/ipoib/ipoib_cm.c              |    2 
 drivers/infiniband/ulp/ipoib/ipoib_ib.c              |   18 +-
 drivers/net/ethernet/3com/3c59x.c                    |    6 
 drivers/net/ethernet/3com/typhoon.c                  |    6 
 drivers/net/ethernet/adaptec/starfire.c              |    8 -
 drivers/net/ethernet/aeroflex/greth.c                |    8 -
 drivers/net/ethernet/alteon/acenic.c                 |   10 -
 drivers/net/ethernet/atheros/atl1c/atl1c_main.c      |    2 
 drivers/net/ethernet/atheros/atl1e/atl1e_main.c      |    6 
 drivers/net/ethernet/atheros/atlx/atl1.c             |   12 -
 drivers/net/ethernet/broadcom/bnx2.c                 |   12 -
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c      |   14 -
 drivers/net/ethernet/broadcom/tg3.c                  |    8 -
 drivers/net/ethernet/brocade/bna/bnad.c              |    6 
 drivers/net/ethernet/chelsio/cxgb/sge.c              |   10 -
 drivers/net/ethernet/chelsio/cxgb3/sge.c             |   12 -
 drivers/net/ethernet/chelsio/cxgb4/sge.c             |   26 +--
 drivers/net/ethernet/chelsio/cxgb4vf/sge.c           |   26 +--
 drivers/net/ethernet/cisco/enic/enic_main.c          |   12 -
 drivers/net/ethernet/emulex/benet/be_main.c          |   18 +-
 drivers/net/ethernet/ibm/ehea/ehea_main.c            |    4 
 drivers/net/ethernet/ibm/emac/core.c                 |    2 
 drivers/net/ethernet/ibm/ibmveth.c                   |    6 
 drivers/net/ethernet/intel/e1000/e1000_main.c        |    6 
 drivers/net/ethernet/intel/e1000e/netdev.c           |    6 
 drivers/net/ethernet/intel/igb/igb_main.c            |    2 
 drivers/net/ethernet/intel/igbvf/netdev.c            |    4 
 drivers/net/ethernet/intel/ixgb/ixgb_main.c          |    4 
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c        |    4 
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c    |    6 
 drivers/net/ethernet/jme.c                           |    4 
 drivers/net/ethernet/marvell/mv643xx_eth.c           |    9 -
 drivers/net/ethernet/marvell/skge.c                  |    8 -
 drivers/net/ethernet/marvell/sky2.c                  |   16 +-
 drivers/net/ethernet/mellanox/mlx4/en_rx.c           |   14 -
 drivers/net/ethernet/mellanox/mlx4/en_tx.c           |   12 -
 drivers/net/ethernet/micrel/ksz884x.c                |    2 
 drivers/net/ethernet/myricom/myri10ge/myri10ge.c     |   14 -
 drivers/net/ethernet/natsemi/ns83820.c               |    4 
 drivers/net/ethernet/neterion/s2io.c                 |   12 -
 drivers/net/ethernet/neterion/vxge/vxge-main.c       |   12 -
 drivers/net/ethernet/nvidia/forcedeth.c              |   18 +-
 drivers/net/ethernet/pasemi/pasemi_mac.c             |    8 -
 drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c |    6 
 drivers/net/ethernet/qlogic/qla3xxx.c                |    6 
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c     |    6 
 drivers/net/ethernet/qlogic/qlge/qlge_main.c         |    6 
 drivers/net/ethernet/realtek/8139cp.c                |    4 
 drivers/net/ethernet/realtek/r8169.c                 |    4 
 drivers/net/ethernet/sfc/rx.c                        |    2 
 drivers/net/ethernet/sfc/tx.c                        |    8 -
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c    |    4 
 drivers/net/ethernet/sun/cassini.c                   |    8 -
 drivers/net/ethernet/sun/niu.c                       |    6 
 drivers/net/ethernet/sun/sungem.c                    |    4 
 drivers/net/ethernet/sun/sunhme.c                    |    4 
 drivers/net/ethernet/tehuti/tehuti.c                 |    6 
 drivers/net/ethernet/tile/tilepro.c                  |    2 
 drivers/net/ethernet/tundra/tsi108_eth.c             |    6 
 drivers/net/ethernet/via/via-velocity.c              |    6 
 drivers/net/ethernet/xilinx/ll_temac_main.c          |    4 
 drivers/net/virtio_net.c                             |    8 -
 drivers/net/vmxnet3/vmxnet3_drv.c                    |   12 -
 drivers/net/xen-netback/netback.c                    |    4 
 drivers/net/xen-netfront.c                           |    4 
 drivers/scsi/cxgbi/libcxgbi.c                        |   10 -
 drivers/scsi/fcoe/fcoe_transport.c                   |    2 
 drivers/staging/hv/netvsc_drv.c                      |    4 
 include/linux/skbuff.h                               |   28 +++
 net/appletalk/ddp.c                                  |    5 
 net/core/datagram.c                                  |   16 +-
 net/core/dev.c                                       |    6 
 net/core/pktgen.c                                    |   12 -
 net/core/skbuff.c                                    |   72 +++++-----
 net/core/user_dma.c                                  |    4 
 net/ipv4/inet_lro.c                                  |    8 -
 net/ipv4/ip_fragment.c                               |    4 
 net/ipv4/ip_output.c                                 |    6 
 net/ipv4/tcp.c                                       |    9 -
 net/ipv4/tcp_output.c                                |    8 -
 net/ipv6/ip6_output.c                                |    5 
 net/ipv6/netfilter/nf_conntrack_reasm.c              |    4 
 net/ipv6/reassembly.c                                |    4 
 net/xfrm/xfrm_ipcomp.c                               |    2 
 87 files changed, 387 insertions(+), 357 deletions(-)

diff --git a/drivers/atm/eni.c b/drivers/atm/eni.c
index f7ca4c1..956e9ac 100644
--- a/drivers/atm/eni.c
+++ b/drivers/atm/eni.c
@@ -1136,7 +1136,7 @@ DPRINTK("doing direct send\n"); /* @@@ well, this doesn't work anyway */
 				put_dma(tx->index,eni_dev->dma,&j,(unsigned long)
 				    skb_frag_page(&skb_shinfo(skb)->frags[i]) +
 					skb_shinfo(skb)->frags[i].page_offset,
-				    skb_shinfo(skb)->frags[i].size);
+				    skb_frag_size(&skb_shinfo(skb)->frags[i]));
 	}
 	if (skb->len & 3)
 		put_dma(tx->index,eni_dev->dma,&j,zeroes,4-(skb->len & 3));
diff --git a/drivers/infiniband/hw/amso1100/c2.c b/drivers/infiniband/hw/amso1100/c2.c
index 6e85a75..5ce7b9e 100644
--- a/drivers/infiniband/hw/amso1100/c2.c
+++ b/drivers/infiniband/hw/amso1100/c2.c
@@ -800,8 +800,8 @@ static int c2_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	/* Loop thru additional data fragments and queue them */
 	if (skb_shinfo(skb)->nr_frags) {
 		for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
-			skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
-			maplen = frag->size;
+			const skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
+			maplen = skb_frag_size(frag);
 			mapaddr = skb_frag_dma_map(&c2dev->pcidev->dev, frag,
 						   0, maplen, DMA_TO_DEVICE);
 			elem = elem->next;
diff --git a/drivers/infiniband/hw/nes/nes_nic.c b/drivers/infiniband/hw/nes/nes_nic.c
index 7cb7f29..47b2ee4 100644
--- a/drivers/infiniband/hw/nes/nes_nic.c
+++ b/drivers/infiniband/hw/nes/nes_nic.c
@@ -444,10 +444,10 @@ static int nes_nic_send(struct sk_buff *skb, struct net_device *netdev)
 			skb_frag_t *frag =
 				&skb_shinfo(skb)->frags[skb_fragment_index];
 			bus_address = skb_frag_dma_map(&nesdev->pcidev->dev,
-						       frag, 0, frag->size,
+						       frag, 0, skb_frag_size(frag),
 						       DMA_TO_DEVICE);
 			wqe_fragment_length[wqe_fragment_index] =
-					cpu_to_le16(skb_shinfo(skb)->frags[skb_fragment_index].size);
+					cpu_to_le16(skb_frag_size(&skb_shinfo(skb)->frags[skb_fragment_index]));
 			set_wqe_64bit_value(nic_sqe->wqe_words, NES_NIC_SQ_WQE_FRAG0_LOW_IDX+(2*wqe_fragment_index),
 				bus_address);
 			wqe_fragment_index++;
@@ -565,7 +565,7 @@ tso_sq_no_longer_full:
 					&skb_shinfo(skb)->frags[tso_frag_count];
 				tso_bus_address[tso_frag_count] =
 					skb_frag_dma_map(&nesdev->pcidev->dev,
-							 frag, 0, frag->size,
+							 frag, 0, skb_frag_size(frag),
 							 DMA_TO_DEVICE);
 			}
 
@@ -637,11 +637,11 @@ tso_sq_no_longer_full:
 				}
 				while (wqe_fragment_index < 5) {
 					wqe_fragment_length[wqe_fragment_index] =
-							cpu_to_le16(skb_shinfo(skb)->frags[tso_frag_index].size);
+							cpu_to_le16(skb_frag_size(&skb_shinfo(skb)->frags[tso_frag_index]));
 					set_wqe_64bit_value(nic_sqe->wqe_words, NES_NIC_SQ_WQE_FRAG0_LOW_IDX+(2*wqe_fragment_index),
 						(u64)tso_bus_address[tso_frag_index]);
 					wqe_fragment_index++;
-					tso_wqe_length += skb_shinfo(skb)->frags[tso_frag_index++].size;
+					tso_wqe_length += skb_frag_size(&skb_shinfo(skb)->frags[tso_frag_index++]);
 					if (wqe_fragment_index < 5)
 						wqe_fragment_length[wqe_fragment_index] = 0;
 					if (tso_frag_index == tso_frag_count)
diff --git a/drivers/infiniband/ulp/ipoib/ipoib_cm.c b/drivers/infiniband/ulp/ipoib/ipoib_cm.c
index 67a477b..c74548a 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_cm.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_cm.c
@@ -543,7 +543,7 @@ static void skb_put_frags(struct sk_buff *skb, unsigned int hdr_space,
 		} else {
 			size = min(length, (unsigned) PAGE_SIZE);
 
-			frag->size = size;
+			skb_frag_size_set(frag, size);
 			skb->data_len += size;
 			skb->truesize += size;
 			skb->len += size;
diff --git a/drivers/infiniband/ulp/ipoib/ipoib_ib.c b/drivers/infiniband/ulp/ipoib/ipoib_ib.c
index 00435be..2b060f4 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_ib.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_ib.c
@@ -117,7 +117,7 @@ static void ipoib_ud_skb_put_frags(struct ipoib_dev_priv *priv,
 
 		size = length - IPOIB_UD_HEAD_SIZE;
 
-		frag->size     = size;
+		skb_frag_size_set(frag, size);
 		skb->data_len += size;
 		skb->truesize += size;
 	} else
@@ -322,10 +322,10 @@ static int ipoib_dma_map_tx(struct ib_device *ca,
 		off = 0;
 
 	for (i = 0; i < skb_shinfo(skb)->nr_frags; ++i) {
-		skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
+		const skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
 		mapping[i + off] = ib_dma_map_page(ca,
 						 skb_frag_page(frag),
-						 frag->page_offset, frag->size,
+						 frag->page_offset, skb_frag_size(frag),
 						 DMA_TO_DEVICE);
 		if (unlikely(ib_dma_mapping_error(ca, mapping[i + off])))
 			goto partial_error;
@@ -334,8 +334,9 @@ static int ipoib_dma_map_tx(struct ib_device *ca,
 
 partial_error:
 	for (; i > 0; --i) {
-		skb_frag_t *frag = &skb_shinfo(skb)->frags[i - 1];
-		ib_dma_unmap_page(ca, mapping[i - !off], frag->size, DMA_TO_DEVICE);
+		const skb_frag_t *frag = &skb_shinfo(skb)->frags[i - 1];
+
+		ib_dma_unmap_page(ca, mapping[i - !off], skb_frag_size(frag), DMA_TO_DEVICE);
 	}
 
 	if (off)
@@ -359,8 +360,9 @@ static void ipoib_dma_unmap_tx(struct ib_device *ca,
 		off = 0;
 
 	for (i = 0; i < skb_shinfo(skb)->nr_frags; ++i) {
-		skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
-		ib_dma_unmap_page(ca, mapping[i + off], frag->size,
+		const skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
+
+		ib_dma_unmap_page(ca, mapping[i + off], skb_frag_size(frag),
 				  DMA_TO_DEVICE);
 	}
 }
@@ -510,7 +512,7 @@ static inline int post_send(struct ipoib_dev_priv *priv,
 
 	for (i = 0; i < nr_frags; ++i) {
 		priv->tx_sge[i + off].addr = mapping[i + off];
-		priv->tx_sge[i + off].length = frags[i].size;
+		priv->tx_sge[i + off].length = skb_frag_size(&frags[i]);
 	}
 	priv->tx_wr.num_sge	     = nr_frags + off;
 	priv->tx_wr.wr_id 	     = wr_id;
diff --git a/drivers/net/ethernet/3com/3c59x.c b/drivers/net/ethernet/3com/3c59x.c
index 9ca45dc..b42c06b 100644
--- a/drivers/net/ethernet/3com/3c59x.c
+++ b/drivers/net/ethernet/3com/3c59x.c
@@ -2182,12 +2182,12 @@ boomerang_start_xmit(struct sk_buff *skb, struct net_device *dev)
 					cpu_to_le32(pci_map_single(
 						VORTEX_PCI(vp),
 						(void *)skb_frag_address(frag),
-						frag->size, PCI_DMA_TODEVICE));
+						skb_frag_size(frag), PCI_DMA_TODEVICE));
 
 			if (i == skb_shinfo(skb)->nr_frags-1)
-					vp->tx_ring[entry].frag[i+1].length = cpu_to_le32(frag->size|LAST_FRAG);
+					vp->tx_ring[entry].frag[i+1].length = cpu_to_le32(skb_frag_size(frag)|LAST_FRAG);
 			else
-					vp->tx_ring[entry].frag[i+1].length = cpu_to_le32(frag->size);
+					vp->tx_ring[entry].frag[i+1].length = cpu_to_le32(skb_frag_size(frag));
 		}
 	}
 #else
diff --git a/drivers/net/ethernet/3com/typhoon.c b/drivers/net/ethernet/3com/typhoon.c
index 11f8858..20ea075 100644
--- a/drivers/net/ethernet/3com/typhoon.c
+++ b/drivers/net/ethernet/3com/typhoon.c
@@ -810,15 +810,15 @@ typhoon_start_tx(struct sk_buff *skb, struct net_device *dev)
 		txd->frag.addrHi = 0;
 		first_txd->numDesc++;
 
-		for(i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
-			skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
+		for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
+			const skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
 			void *frag_addr;
 
 			txd = (struct tx_desc *) (txRing->ringBase +
 						txRing->lastWrite);
 			typhoon_inc_tx_index(&txRing->lastWrite, 1);
 
-			len = frag->size;
+			len = skb_frag_size(frag);
 			frag_addr = skb_frag_address(frag);
 			skb_dma = pci_map_single(tp->tx_pdev, frag_addr, len,
 					 PCI_DMA_TODEVICE);
diff --git a/drivers/net/ethernet/adaptec/starfire.c b/drivers/net/ethernet/adaptec/starfire.c
index d6b0155..6d9f691 100644
--- a/drivers/net/ethernet/adaptec/starfire.c
+++ b/drivers/net/ethernet/adaptec/starfire.c
@@ -1256,12 +1256,12 @@ static netdev_tx_t start_tx(struct sk_buff *skb, struct net_device *dev)
 			np->tx_info[entry].mapping =
 				pci_map_single(np->pci_dev, skb->data, skb_first_frag_len(skb), PCI_DMA_TODEVICE);
 		} else {
-			skb_frag_t *this_frag = &skb_shinfo(skb)->frags[i - 1];
-			status |= this_frag->size;
+			const skb_frag_t *this_frag = &skb_shinfo(skb)->frags[i - 1];
+			status |= skb_frag_size(this_frag);
 			np->tx_info[entry].mapping =
 				pci_map_single(np->pci_dev,
 					       skb_frag_address(this_frag),
-					       this_frag->size,
+					       skb_frag_size(this_frag),
 					       PCI_DMA_TODEVICE);
 		}
 
@@ -1378,7 +1378,7 @@ static irqreturn_t intr_handler(int irq, void *dev_instance)
 					for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
 						pci_unmap_single(np->pci_dev,
 								 np->tx_info[entry].mapping,
-								 skb_shinfo(skb)->frags[i].size,
+								 skb_frag_size(&skb_shinfo(skb)->frags[i]),
 								 PCI_DMA_TODEVICE);
 						np->dirty_tx++;
 						entry++;
diff --git a/drivers/net/ethernet/aeroflex/greth.c b/drivers/net/ethernet/aeroflex/greth.c
index 6715bf5..442fefa 100644
--- a/drivers/net/ethernet/aeroflex/greth.c
+++ b/drivers/net/ethernet/aeroflex/greth.c
@@ -198,7 +198,7 @@ static void greth_clean_rings(struct greth_private *greth)
 
 				dma_unmap_page(greth->dev,
 					       greth_read_bd(&tx_bdp->addr),
-					       frag->size,
+					       skb_frag_size(frag),
 					       DMA_TO_DEVICE);
 
 				greth->tx_last = NEXT_TX(greth->tx_last);
@@ -517,7 +517,7 @@ greth_start_xmit_gbit(struct sk_buff *skb, struct net_device *dev)
 		status = GRETH_BD_EN;
 		if (skb->ip_summed == CHECKSUM_PARTIAL)
 			status |= GRETH_TXBD_CSALL;
-		status |= frag->size & GRETH_BD_LEN;
+		status |= skb_frag_size(frag) & GRETH_BD_LEN;
 
 		/* Wrap around descriptor ring */
 		if (curr_tx == GRETH_TXBD_NUM_MASK)
@@ -531,7 +531,7 @@ greth_start_xmit_gbit(struct sk_buff *skb, struct net_device *dev)
 
 		greth_write_bd(&bdp->stat, status);
 
-		dma_addr = skb_frag_dma_map(greth->dev, frag, 0, frag->size,
+		dma_addr = skb_frag_dma_map(greth->dev, frag, 0, skb_frag_size(frag),
 					    DMA_TO_DEVICE);
 
 		if (unlikely(dma_mapping_error(greth->dev, dma_addr)))
@@ -713,7 +713,7 @@ static void greth_clean_tx_gbit(struct net_device *dev)
 
 			dma_unmap_page(greth->dev,
 				       greth_read_bd(&bdp->addr),
-				       frag->size,
+				       skb_frag_size(frag),
 				       DMA_TO_DEVICE);
 
 			greth->tx_last = NEXT_TX(greth->tx_last);
diff --git a/drivers/net/ethernet/alteon/acenic.c b/drivers/net/ethernet/alteon/acenic.c
index b1a4e82..f872748 100644
--- a/drivers/net/ethernet/alteon/acenic.c
+++ b/drivers/net/ethernet/alteon/acenic.c
@@ -2478,18 +2478,18 @@ restart:
 		idx = (idx + 1) % ACE_TX_RING_ENTRIES(ap);
 
 		for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
-			skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
+			const skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
 			struct tx_ring_info *info;
 
-			len += frag->size;
+			len += skb_frag_size(frag);
 			info = ap->skb->tx_skbuff + idx;
 			desc = ap->tx_ring + idx;
 
 			mapping = skb_frag_dma_map(&ap->pdev->dev, frag, 0,
-						   frag->size,
+						   skb_frag_size(frag),
 						   DMA_TO_DEVICE);
 
-			flagsize = (frag->size << 16);
+			flagsize = skb_frag_size(frag) << 16;
 			if (skb->ip_summed == CHECKSUM_PARTIAL)
 				flagsize |= BD_FLG_TCP_UDP_SUM;
 			idx = (idx + 1) % ACE_TX_RING_ENTRIES(ap);
@@ -2508,7 +2508,7 @@ restart:
 				info->skb = NULL;
 			}
 			dma_unmap_addr_set(info, mapping, mapping);
-			dma_unmap_len_set(info, maplen, frag->size);
+			dma_unmap_len_set(info, maplen, skb_frag_size(frag));
 			ace_load_tx_bd(ap, desc, mapping, flagsize, vlan_tag);
 		}
 	}
diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
index 12a0b30..02c7ed8 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
@@ -2179,7 +2179,7 @@ static void atl1c_tx_map(struct atl1c_adapter *adapter,
 		memcpy(use_tpd, tpd, sizeof(struct atl1c_tpd_desc));
 
 		buffer_info = atl1c_get_tx_buffer(adapter, use_tpd);
-		buffer_info->length = frag->size;
+		buffer_info->length = skb_frag_size(frag);
 		buffer_info->dma = skb_frag_dma_map(&adapter->pdev->dev,
 						    frag, 0,
 						    buffer_info->length,
diff --git a/drivers/net/ethernet/atheros/atl1e/atl1e_main.c b/drivers/net/ethernet/atheros/atl1e/atl1e_main.c
index 97c45a4..95483bc 100644
--- a/drivers/net/ethernet/atheros/atl1e/atl1e_main.c
+++ b/drivers/net/ethernet/atheros/atl1e/atl1e_main.c
@@ -1593,7 +1593,7 @@ static u16 atl1e_cal_tdp_req(const struct sk_buff *skb)
 	u16 proto_hdr_len = 0;
 
 	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
-		fg_size = skb_shinfo(skb)->frags[i].size;
+		fg_size = skb_frag_size(&skb_shinfo(skb)->frags[i]);
 		tpd_req += ((fg_size + MAX_TX_BUF_LEN - 1) >> MAX_TX_BUF_SHIFT);
 	}
 
@@ -1744,12 +1744,12 @@ static void atl1e_tx_map(struct atl1e_adapter *adapter,
 	}
 
 	for (f = 0; f < nr_frags; f++) {
-		struct skb_frag_struct *frag;
+		const struct skb_frag_struct *frag;
 		u16 i;
 		u16 seg_num;
 
 		frag = &skb_shinfo(skb)->frags[f];
-		buf_len = frag->size;
+		buf_len = skb_frag_size(frag);
 
 		seg_num = (buf_len + MAX_TX_BUF_LEN - 1) / MAX_TX_BUF_LEN;
 		for (i = 0; i < seg_num; i++) {
diff --git a/drivers/net/ethernet/atheros/atlx/atl1.c b/drivers/net/ethernet/atheros/atlx/atl1.c
index 7381a49..0405261 100644
--- a/drivers/net/ethernet/atheros/atlx/atl1.c
+++ b/drivers/net/ethernet/atheros/atlx/atl1.c
@@ -2267,11 +2267,11 @@ static void atl1_tx_map(struct atl1_adapter *adapter, struct sk_buff *skb,
 	}
 
 	for (f = 0; f < nr_frags; f++) {
-		struct skb_frag_struct *frag;
+		const struct skb_frag_struct *frag;
 		u16 i, nseg;
 
 		frag = &skb_shinfo(skb)->frags[f];
-		buf_len = frag->size;
+		buf_len = skb_frag_size(frag);
 
 		nseg = (buf_len + ATL1_MAX_TX_BUF_LEN - 1) /
 			ATL1_MAX_TX_BUF_LEN;
@@ -2356,7 +2356,6 @@ static netdev_tx_t atl1_xmit_frame(struct sk_buff *skb,
 	int count = 1;
 	int ret_val;
 	struct tx_packet_desc *ptpd;
-	u16 frag_size;
 	u16 vlan_tag;
 	unsigned int nr_frags = 0;
 	unsigned int mss = 0;
@@ -2372,10 +2371,9 @@ static netdev_tx_t atl1_xmit_frame(struct sk_buff *skb,
 
 	nr_frags = skb_shinfo(skb)->nr_frags;
 	for (f = 0; f < nr_frags; f++) {
-		frag_size = skb_shinfo(skb)->frags[f].size;
-		if (frag_size)
-			count += (frag_size + ATL1_MAX_TX_BUF_LEN - 1) /
-				ATL1_MAX_TX_BUF_LEN;
+		unsigned int f_size = skb_frag_size(&skb_shinfo(skb)->frags[f]);
+		count += (f_size + ATL1_MAX_TX_BUF_LEN - 1) /
+			 ATL1_MAX_TX_BUF_LEN;
 	}
 
 	mss = skb_shinfo(skb)->gso_size;
diff --git a/drivers/net/ethernet/broadcom/bnx2.c b/drivers/net/ethernet/broadcom/bnx2.c
index 6ff7636..965c723 100644
--- a/drivers/net/ethernet/broadcom/bnx2.c
+++ b/drivers/net/ethernet/broadcom/bnx2.c
@@ -2871,7 +2871,7 @@ bnx2_tx_int(struct bnx2 *bp, struct bnx2_napi *bnapi, int budget)
 				dma_unmap_addr(
 					&txr->tx_buf_ring[TX_RING_IDX(sw_cons)],
 					mapping),
-				skb_shinfo(skb)->frags[i].size,
+				skb_frag_size(&skb_shinfo(skb)->frags[i]),
 				PCI_DMA_TODEVICE);
 		}
 
@@ -3049,7 +3049,7 @@ bnx2_rx_skb(struct bnx2 *bp, struct bnx2_rx_ring_info *rxr, struct sk_buff *skb,
 				} else {
 					skb_frag_t *frag =
 						&skb_shinfo(skb)->frags[i - 1];
-					frag->size -= tail;
+					skb_frag_size_sub(frag, tail);
 					skb->data_len -= tail;
 				}
 				return 0;
@@ -5395,7 +5395,7 @@ bnx2_free_tx_skbs(struct bnx2 *bp)
 				tx_buf = &txr->tx_buf_ring[TX_RING_IDX(j)];
 				dma_unmap_page(&bp->pdev->dev,
 					dma_unmap_addr(tx_buf, mapping),
-					skb_shinfo(skb)->frags[k].size,
+					skb_frag_size(&skb_shinfo(skb)->frags[k]),
 					PCI_DMA_TODEVICE);
 			}
 			dev_kfree_skb(skb);
@@ -6530,13 +6530,13 @@ bnx2_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	tx_buf->is_gso = skb_is_gso(skb);
 
 	for (i = 0; i < last_frag; i++) {
-		skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
+		const skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
 
 		prod = NEXT_TX_BD(prod);
 		ring_prod = TX_RING_IDX(prod);
 		txbd = &txr->tx_desc_ring[ring_prod];
 
-		len = frag->size;
+		len = skb_frag_size(frag);
 		mapping = skb_frag_dma_map(&bp->pdev->dev, frag, 0, len,
 					   DMA_TO_DEVICE);
 		if (dma_mapping_error(&bp->pdev->dev, mapping))
@@ -6594,7 +6594,7 @@ dma_error:
 		ring_prod = TX_RING_IDX(prod);
 		tx_buf = &txr->tx_buf_ring[ring_prod];
 		dma_unmap_page(&bp->pdev->dev, dma_unmap_addr(tx_buf, mapping),
-			       skb_shinfo(skb)->frags[i].size,
+			       skb_frag_size(&skb_shinfo(skb)->frags[i]),
 			       PCI_DMA_TODEVICE);
 	}
 
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index e575e89..dd8ee56 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -2363,7 +2363,7 @@ static int bnx2x_pkt_req_lin(struct bnx2x *bp, struct sk_buff *skb,
 			/* Calculate the first sum - it's special */
 			for (frag_idx = 0; frag_idx < wnd_size - 1; frag_idx++)
 				wnd_sum +=
-					skb_shinfo(skb)->frags[frag_idx].size;
+					skb_frag_size(&skb_shinfo(skb)->frags[frag_idx]);
 
 			/* If there was data on linear skb data - check it */
 			if (first_bd_sz > 0) {
@@ -2379,14 +2379,14 @@ static int bnx2x_pkt_req_lin(struct bnx2x *bp, struct sk_buff *skb,
 			   check all windows */
 			for (wnd_idx = 0; wnd_idx <= num_wnds; wnd_idx++) {
 				wnd_sum +=
-			  skb_shinfo(skb)->frags[wnd_idx + wnd_size - 1].size;
+			  skb_frag_size(&skb_shinfo(skb)->frags[wnd_idx + wnd_size - 1]);
 
 				if (unlikely(wnd_sum < lso_mss)) {
 					to_copy = 1;
 					break;
 				}
 				wnd_sum -=
-					skb_shinfo(skb)->frags[wnd_idx].size;
+					skb_frag_size(&skb_shinfo(skb)->frags[wnd_idx]);
 			}
 		} else {
 			/* in non-LSO too fragmented packet should always
@@ -2796,8 +2796,8 @@ netdev_tx_t bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
 		skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
 
-		mapping = skb_frag_dma_map(&bp->pdev->dev, frag, 0, frag->size,
-					   DMA_TO_DEVICE);
+		mapping = skb_frag_dma_map(&bp->pdev->dev, frag, 0,
+					   skb_frag_size(frag), DMA_TO_DEVICE);
 		if (unlikely(dma_mapping_error(&bp->pdev->dev, mapping))) {
 
 			DP(NETIF_MSG_TX_QUEUED, "Unable to map page - "
@@ -2821,8 +2821,8 @@ netdev_tx_t bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 		tx_data_bd->addr_hi = cpu_to_le32(U64_HI(mapping));
 		tx_data_bd->addr_lo = cpu_to_le32(U64_LO(mapping));
-		tx_data_bd->nbytes = cpu_to_le16(frag->size);
-		le16_add_cpu(&pkt_size, frag->size);
+		tx_data_bd->nbytes = cpu_to_le16(skb_frag_size(frag));
+		le16_add_cpu(&pkt_size, skb_frag_size(frag));
 		nbd++;
 
 		DP(NETIF_MSG_TX_QUEUED,
diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index fe712f9..b89027c 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -5356,7 +5356,7 @@ static void tg3_tx(struct tg3_napi *tnapi)
 
 			pci_unmap_page(tp->pdev,
 				       dma_unmap_addr(ri, mapping),
-				       skb_shinfo(skb)->frags[i].size,
+				       skb_frag_size(&skb_shinfo(skb)->frags[i]),
 				       PCI_DMA_TODEVICE);
 
 			while (ri->fragmented) {
@@ -6510,14 +6510,14 @@ static void tg3_tx_skb_unmap(struct tg3_napi *tnapi, u32 entry, int last)
 	}
 
 	for (i = 0; i < last; i++) {
-		skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
+		const skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
 
 		entry = NEXT_TX(entry);
 		txb = &tnapi->tx_buffers[entry];
 
 		pci_unmap_page(tnapi->tp->pdev,
 			       dma_unmap_addr(txb, mapping),
-			       frag->size, PCI_DMA_TODEVICE);
+			       skb_frag_size(frag), PCI_DMA_TODEVICE);
 
 		while (txb->fragmented) {
 			txb->fragmented = false;
@@ -6777,7 +6777,7 @@ static netdev_tx_t tg3_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		for (i = 0; i <= last; i++) {
 			skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
 
-			len = frag->size;
+			len = skb_frag_size(frag);
 			mapping = skb_frag_dma_map(&tp->pdev->dev, frag, 0,
 						   len, DMA_TO_DEVICE);
 
diff --git a/drivers/net/ethernet/brocade/bna/bnad.c b/drivers/net/ethernet/brocade/bna/bnad.c
index 2f4ced6..5d7872e 100644
--- a/drivers/net/ethernet/brocade/bna/bnad.c
+++ b/drivers/net/ethernet/brocade/bna/bnad.c
@@ -116,7 +116,7 @@ bnad_pci_unmap_skb(struct device *pdev, struct bnad_skb_unmap *array,
 
 	for (j = 0; j < frag; j++) {
 		dma_unmap_page(pdev, dma_unmap_addr(&array[index], dma_addr),
-			  skb_shinfo(skb)->frags[j].size, DMA_TO_DEVICE);
+			  skb_frag_size(&skb_shinfo(skb)->frags[j]), DMA_TO_DEVICE);
 		dma_unmap_addr_set(&array[index], dma_addr, 0);
 		BNA_QE_INDX_ADD(index, 1, depth);
 	}
@@ -2741,8 +2741,8 @@ bnad_start_xmit(struct sk_buff *skb, struct net_device *netdev)
 	wis_used = 1;
 
 	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
-		struct skb_frag_struct *frag = &skb_shinfo(skb)->frags[i];
-		u16		size = frag->size;
+		const struct skb_frag_struct *frag = &skb_shinfo(skb)->frags[i];
+		u16		size = skb_frag_size(frag);
 
 		if (unlikely(size == 0)) {
 			unmap_prod = unmap_q->producer_index;
diff --git a/drivers/net/ethernet/chelsio/cxgb/sge.c b/drivers/net/ethernet/chelsio/cxgb/sge.c
index 0a511c4a..f9b6023 100644
--- a/drivers/net/ethernet/chelsio/cxgb/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb/sge.c
@@ -1135,8 +1135,8 @@ static inline unsigned int compute_large_page_tx_descs(struct sk_buff *skb)
 			len -= SGE_TX_DESC_MAX_PLEN;
 		}
 		for (i = 0; nfrags--; i++) {
-			skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
-			len = frag->size;
+			const skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
+			len = skb_frag_size(frag);
 			while (len > SGE_TX_DESC_MAX_PLEN) {
 				count++;
 				len -= SGE_TX_DESC_MAX_PLEN;
@@ -1278,9 +1278,9 @@ static inline void write_tx_descs(struct adapter *adapter, struct sk_buff *skb,
 		}
 
 		mapping = skb_frag_dma_map(&adapter->pdev->dev, frag, 0,
-					   frag->size, DMA_TO_DEVICE);
+					   skb_frag_size(frag), DMA_TO_DEVICE);
 		desc_mapping = mapping;
-		desc_len = frag->size;
+		desc_len = skb_frag_size(frag);
 
 		pidx = write_large_page_tx_descs(pidx, &e1, &ce, &gen,
 						 &desc_mapping, &desc_len,
@@ -1290,7 +1290,7 @@ static inline void write_tx_descs(struct adapter *adapter, struct sk_buff *skb,
 				      nfrags == 0);
 		ce->skb = NULL;
 		dma_unmap_addr_set(ce, dma_addr, mapping);
-		dma_unmap_len_set(ce, dma_len, frag->size);
+		dma_unmap_len_set(ce, dma_len, skb_frag_size(frag));
 	}
 	ce->skb = skb;
 	wmb();
diff --git a/drivers/net/ethernet/chelsio/cxgb3/sge.c b/drivers/net/ethernet/chelsio/cxgb3/sge.c
index 2f46b37..cfb60e1 100644
--- a/drivers/net/ethernet/chelsio/cxgb3/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb3/sge.c
@@ -254,7 +254,7 @@ static inline void unmap_skb(struct sk_buff *skb, struct sge_txq *q,
 
 	while (frag_idx < nfrags && curflit < WR_FLITS) {
 		pci_unmap_page(pdev, be64_to_cpu(sgp->addr[j]),
-			       skb_shinfo(skb)->frags[frag_idx].size,
+			       skb_frag_size(&skb_shinfo(skb)->frags[frag_idx]),
 			       PCI_DMA_TODEVICE);
 		j ^= 1;
 		if (j == 0) {
@@ -977,11 +977,11 @@ static inline unsigned int make_sgl(const struct sk_buff *skb,
 
 	nfrags = skb_shinfo(skb)->nr_frags;
 	for (i = 0; i < nfrags; i++) {
-		skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
+		const skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
 
-		mapping = skb_frag_dma_map(&pdev->dev, frag, 0, frag->size,
+		mapping = skb_frag_dma_map(&pdev->dev, frag, 0, skb_frag_size(frag),
 					   DMA_TO_DEVICE);
-		sgp->len[j] = cpu_to_be32(frag->size);
+		sgp->len[j] = cpu_to_be32(skb_frag_size(frag));
 		sgp->addr[j] = cpu_to_be64(mapping);
 		j ^= 1;
 		if (j == 0)
@@ -1544,7 +1544,7 @@ static void deferred_unmap_destructor(struct sk_buff *skb)
 
 	si = skb_shinfo(skb);
 	for (i = 0; i < si->nr_frags; i++)
-		pci_unmap_page(dui->pdev, *p++, si->frags[i].size,
+		pci_unmap_page(dui->pdev, *p++, skb_frag_size(&si->frags[i]),
 			       PCI_DMA_TODEVICE);
 }
 
@@ -2118,7 +2118,7 @@ static void lro_add_page(struct adapter *adap, struct sge_qset *qs,
 	rx_frag += nr_frags;
 	__skb_frag_set_page(rx_frag, sd->pg_chunk.page);
 	rx_frag->page_offset = sd->pg_chunk.offset + offset;
-	rx_frag->size = len;
+	skb_frag_size_set(rx_frag, len);
 
 	skb->len += len;
 	skb->data_len += len;
diff --git a/drivers/net/ethernet/chelsio/cxgb4/sge.c b/drivers/net/ethernet/chelsio/cxgb4/sge.c
index 56adf44..14f31d3 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/sge.c
@@ -215,8 +215,8 @@ static int map_skb(struct device *dev, const struct sk_buff *skb,
 	end = &si->frags[si->nr_frags];
 
 	for (fp = si->frags; fp < end; fp++) {
-		*++addr = dma_map_page(dev, fp->page, fp->page_offset, fp->size,
-				       DMA_TO_DEVICE);
+		*++addr = dma_map_page(dev, fp->page, fp->page_offset,
+				       skb_frag_size(fp), DMA_TO_DEVICE);
 		if (dma_mapping_error(dev, *addr))
 			goto unwind;
 	}
@@ -224,7 +224,7 @@ static int map_skb(struct device *dev, const struct sk_buff *skb,
 
 unwind:
 	while (fp-- > si->frags)
-		dma_unmap_page(dev, *--addr, fp->size, DMA_TO_DEVICE);
+		dma_unmap_page(dev, *--addr, skb_frag_size(fp), DMA_TO_DEVICE);
 
 	dma_unmap_single(dev, addr[-1], skb_headlen(skb), DMA_TO_DEVICE);
 out_err:
@@ -243,7 +243,7 @@ static void unmap_skb(struct device *dev, const struct sk_buff *skb,
 	si = skb_shinfo(skb);
 	end = &si->frags[si->nr_frags];
 	for (fp = si->frags; fp < end; fp++)
-		dma_unmap_page(dev, *addr++, fp->size, DMA_TO_DEVICE);
+		dma_unmap_page(dev, *addr++, skb_frag_size(fp), DMA_TO_DEVICE);
 }
 
 /**
@@ -717,7 +717,7 @@ static void write_sgl(const struct sk_buff *skb, struct sge_txq *q,
 		sgl->addr0 = cpu_to_be64(addr[0] + start);
 		nfrags++;
 	} else {
-		sgl->len0 = htonl(si->frags[0].size);
+		sgl->len0 = htonl(skb_frag_size(&si->frags[0]));
 		sgl->addr0 = cpu_to_be64(addr[1]);
 	}
 
@@ -732,13 +732,13 @@ static void write_sgl(const struct sk_buff *skb, struct sge_txq *q,
 	to = (u8 *)end > (u8 *)q->stat ? buf : sgl->sge;
 
 	for (i = (nfrags != si->nr_frags); nfrags >= 2; nfrags -= 2, to++) {
-		to->len[0] = cpu_to_be32(si->frags[i].size);
-		to->len[1] = cpu_to_be32(si->frags[++i].size);
+		to->len[0] = cpu_to_be32(skb_frag_size(&si->frags[i]));
+		to->len[1] = cpu_to_be32(skb_frag_size(&si->frags[++i]));
 		to->addr[0] = cpu_to_be64(addr[i]);
 		to->addr[1] = cpu_to_be64(addr[++i]);
 	}
 	if (nfrags) {
-		to->len[0] = cpu_to_be32(si->frags[i].size);
+		to->len[0] = cpu_to_be32(skb_frag_size(&si->frags[i]));
 		to->len[1] = cpu_to_be32(0);
 		to->addr[0] = cpu_to_be64(addr[i + 1]);
 	}
@@ -1417,7 +1417,7 @@ static inline void copy_frags(struct skb_shared_info *ssi,
 	/* usually there's just one frag */
 	ssi->frags[0].page = gl->frags[0].page;
 	ssi->frags[0].page_offset = gl->frags[0].page_offset + offset;
-	ssi->frags[0].size = gl->frags[0].size - offset;
+	skb_frag_size_set(&ssi->frags[0], skb_frag_size(&gl->frags[0]) - offset);
 	ssi->nr_frags = gl->nfrags;
 	n = gl->nfrags - 1;
 	if (n)
@@ -1718,8 +1718,8 @@ static int process_responses(struct sge_rspq *q, int budget)
 				bufsz = get_buf_size(rsd);
 				fp->page = rsd->page;
 				fp->page_offset = q->offset;
-				fp->size = min(bufsz, len);
-				len -= fp->size;
+				skb_frag_size_set(fp, min(bufsz, len));
+				len -= skb_frag_size(fp);
 				if (!len)
 					break;
 				unmap_rx_buf(q->adap, &rxq->fl);
@@ -1731,7 +1731,7 @@ static int process_responses(struct sge_rspq *q, int budget)
 			 */
 			dma_sync_single_for_cpu(q->adap->pdev_dev,
 						get_buf_addr(rsd),
-						fp->size, DMA_FROM_DEVICE);
+						skb_frag_size(fp), DMA_FROM_DEVICE);
 
 			si.va = page_address(si.frags[0].page) +
 				si.frags[0].page_offset;
@@ -1740,7 +1740,7 @@ static int process_responses(struct sge_rspq *q, int budget)
 			si.nfrags = frags + 1;
 			ret = q->handler(q, q->cur_desc, &si);
 			if (likely(ret == 0))
-				q->offset += ALIGN(fp->size, FL_ALIGN);
+				q->offset += ALIGN(skb_frag_size(fp), FL_ALIGN);
 			else
 				restore_rx_bufs(&si, &rxq->fl, frags);
 		} else if (likely(rsp_type == RSP_TYPE_CPL)) {
diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/sge.c b/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
index cffb328..c2d456d 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
@@ -296,8 +296,8 @@ static int map_skb(struct device *dev, const struct sk_buff *skb,
 	si = skb_shinfo(skb);
 	end = &si->frags[si->nr_frags];
 	for (fp = si->frags; fp < end; fp++) {
-		*++addr = dma_map_page(dev, fp->page, fp->page_offset, fp->size,
-				       DMA_TO_DEVICE);
+		*++addr = dma_map_page(dev, fp->page, fp->page_offset,
+				       skb_frag_size(fp), DMA_TO_DEVICE);
 		if (dma_mapping_error(dev, *addr))
 			goto unwind;
 	}
@@ -305,7 +305,7 @@ static int map_skb(struct device *dev, const struct sk_buff *skb,
 
 unwind:
 	while (fp-- > si->frags)
-		dma_unmap_page(dev, *--addr, fp->size, DMA_TO_DEVICE);
+		dma_unmap_page(dev, *--addr, skb_frag_size(fp), DMA_TO_DEVICE);
 	dma_unmap_single(dev, addr[-1], skb_headlen(skb), DMA_TO_DEVICE);
 
 out_err:
@@ -899,7 +899,7 @@ static void write_sgl(const struct sk_buff *skb, struct sge_txq *tq,
 		sgl->addr0 = cpu_to_be64(addr[0] + start);
 		nfrags++;
 	} else {
-		sgl->len0 = htonl(si->frags[0].size);
+		sgl->len0 = htonl(skb_frag_size(&si->frags[0]));
 		sgl->addr0 = cpu_to_be64(addr[1]);
 	}
 
@@ -915,13 +915,13 @@ static void write_sgl(const struct sk_buff *skb, struct sge_txq *tq,
 	to = (u8 *)end > (u8 *)tq->stat ? buf : sgl->sge;
 
 	for (i = (nfrags != si->nr_frags); nfrags >= 2; nfrags -= 2, to++) {
-		to->len[0] = cpu_to_be32(si->frags[i].size);
-		to->len[1] = cpu_to_be32(si->frags[++i].size);
+		to->len[0] = cpu_to_be32(skb_frag_size(&si->frags[i]));
+		to->len[1] = cpu_to_be32(skb_frag_size(&si->frags[++i]));
 		to->addr[0] = cpu_to_be64(addr[i]);
 		to->addr[1] = cpu_to_be64(addr[++i]);
 	}
 	if (nfrags) {
-		to->len[0] = cpu_to_be32(si->frags[i].size);
+		to->len[0] = cpu_to_be32(skb_frag_size(&si->frags[i]));
 		to->len[1] = cpu_to_be32(0);
 		to->addr[0] = cpu_to_be64(addr[i + 1]);
 	}
@@ -1399,7 +1399,7 @@ struct sk_buff *t4vf_pktgl_to_skb(const struct pkt_gl *gl,
 		ssi = skb_shinfo(skb);
 		ssi->frags[0].page = gl->frags[0].page;
 		ssi->frags[0].page_offset = gl->frags[0].page_offset + pull_len;
-		ssi->frags[0].size = gl->frags[0].size - pull_len;
+		skb_frag_size_set(&ssi->frags[0], skb_frag_size(&gl->frags[0]) - pull_len);
 		if (gl->nfrags > 1)
 			memcpy(&ssi->frags[1], &gl->frags[1],
 			       (gl->nfrags-1) * sizeof(skb_frag_t));
@@ -1451,7 +1451,7 @@ static inline void copy_frags(struct skb_shared_info *si,
 	/* usually there's just one frag */
 	si->frags[0].page = gl->frags[0].page;
 	si->frags[0].page_offset = gl->frags[0].page_offset + offset;
-	si->frags[0].size = gl->frags[0].size - offset;
+	skb_frag_size_set(&si->frags[0], skb_frag_size(&gl->frags[0]) - offset);
 	si->nr_frags = gl->nfrags;
 
 	n = gl->nfrags - 1;
@@ -1702,8 +1702,8 @@ int process_responses(struct sge_rspq *rspq, int budget)
 				bufsz = get_buf_size(sdesc);
 				fp->page = sdesc->page;
 				fp->page_offset = rspq->offset;
-				fp->size = min(bufsz, len);
-				len -= fp->size;
+				skb_frag_size_set(fp, min(bufsz, len));
+				len -= skb_frag_size(fp);
 				if (!len)
 					break;
 				unmap_rx_buf(rspq->adapter, &rxq->fl);
@@ -1717,7 +1717,7 @@ int process_responses(struct sge_rspq *rspq, int budget)
 			 */
 			dma_sync_single_for_cpu(rspq->adapter->pdev_dev,
 						get_buf_addr(sdesc),
-						fp->size, DMA_FROM_DEVICE);
+						skb_frag_size(fp), DMA_FROM_DEVICE);
 			gl.va = (page_address(gl.frags[0].page) +
 				 gl.frags[0].page_offset);
 			prefetch(gl.va);
@@ -1728,7 +1728,7 @@ int process_responses(struct sge_rspq *rspq, int budget)
 			 */
 			ret = rspq->handler(rspq, rspq->cur_desc, &gl);
 			if (likely(ret == 0))
-				rspq->offset += ALIGN(fp->size, FL_ALIGN);
+				rspq->offset += ALIGN(skb_frag_size(fp), FL_ALIGN);
 			else
 				restore_rx_bufs(&gl, &rxq->fl, frag);
 		} else if (likely(rsp_type == RSP_TYPE_CPL)) {
diff --git a/drivers/net/ethernet/cisco/enic/enic_main.c b/drivers/net/ethernet/cisco/enic/enic_main.c
index 1bc908f..c3786fd 100644
--- a/drivers/net/ethernet/cisco/enic/enic_main.c
+++ b/drivers/net/ethernet/cisco/enic/enic_main.c
@@ -599,16 +599,16 @@ static inline void enic_queue_wq_skb_cont(struct enic *enic,
 	struct vnic_wq *wq, struct sk_buff *skb,
 	unsigned int len_left, int loopback)
 {
-	skb_frag_t *frag;
+	const skb_frag_t *frag;
 
 	/* Queue additional data fragments */
 	for (frag = skb_shinfo(skb)->frags; len_left; frag++) {
-		len_left -= frag->size;
+		len_left -= skb_frag_size(frag);
 		enic_queue_wq_desc_cont(wq, skb,
 			skb_frag_dma_map(&enic->pdev->dev,
-					 frag, 0, frag->size,
+					 frag, 0, skb_frag_size(frag),
 					 DMA_TO_DEVICE),
-			frag->size,
+			skb_frag_size(frag),
 			(len_left == 0),	/* EOP? */
 			loopback);
 	}
@@ -717,8 +717,8 @@ static inline void enic_queue_wq_skb_tso(struct enic *enic,
 	 * for additional data fragments
 	 */
 	for (frag = skb_shinfo(skb)->frags; len_left; frag++) {
-		len_left -= frag->size;
-		frag_len_left = frag->size;
+		len_left -= skb_frag_size(frag);
+		frag_len_left = skb_frag_size(frag);
 		offset = 0;
 
 		while (frag_len_left) {
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 679b804..706fc59 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -636,17 +636,17 @@ static int make_tx_wrbs(struct be_adapter *adapter, struct be_queue_info *txq,
 	}
 
 	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
-		struct skb_frag_struct *frag =
+		const struct skb_frag_struct *frag =
 			&skb_shinfo(skb)->frags[i];
 		busaddr = skb_frag_dma_map(dev, frag, 0,
-					   frag->size, DMA_TO_DEVICE);
+					   skb_frag_size(frag), DMA_TO_DEVICE);
 		if (dma_mapping_error(dev, busaddr))
 			goto dma_err;
 		wrb = queue_head_node(txq);
-		wrb_fill(wrb, busaddr, frag->size);
+		wrb_fill(wrb, busaddr, skb_frag_size(frag));
 		be_dws_cpu_to_le(wrb, sizeof(*wrb));
 		queue_head_inc(txq);
-		copied += frag->size;
+		copied += skb_frag_size(frag);
 	}
 
 	if (dummy_wrb) {
@@ -1069,7 +1069,7 @@ static void skb_fill_rx_data(struct be_adapter *adapter, struct be_rx_obj *rxo,
 		skb_frag_set_page(skb, 0, page_info->page);
 		skb_shinfo(skb)->frags[0].page_offset =
 					page_info->page_offset + hdr_len;
-		skb_shinfo(skb)->frags[0].size = curr_frag_len - hdr_len;
+		skb_frag_size_set(&skb_shinfo(skb)->frags[0], curr_frag_len - hdr_len);
 		skb->data_len = curr_frag_len - hdr_len;
 		skb->truesize += rx_frag_size;
 		skb->tail += hdr_len;
@@ -1095,13 +1095,13 @@ static void skb_fill_rx_data(struct be_adapter *adapter, struct be_rx_obj *rxo,
 			skb_frag_set_page(skb, j, page_info->page);
 			skb_shinfo(skb)->frags[j].page_offset =
 							page_info->page_offset;
-			skb_shinfo(skb)->frags[j].size = 0;
+			skb_frag_size_set(&skb_shinfo(skb)->frags[j], 0);
 			skb_shinfo(skb)->nr_frags++;
 		} else {
 			put_page(page_info->page);
 		}
 
-		skb_shinfo(skb)->frags[j].size += curr_frag_len;
+		skb_frag_size_add(&skb_shinfo(skb)->frags[j], curr_frag_len);
 		skb->len += curr_frag_len;
 		skb->data_len += curr_frag_len;
 		skb->truesize += rx_frag_size;
@@ -1176,11 +1176,11 @@ static void be_rx_compl_process_gro(struct be_adapter *adapter,
 			skb_frag_set_page(skb, j, page_info->page);
 			skb_shinfo(skb)->frags[j].page_offset =
 							page_info->page_offset;
-			skb_shinfo(skb)->frags[j].size = 0;
+			skb_frag_size_set(&skb_shinfo(skb)->frags[j], 0);
 		} else {
 			put_page(page_info->page);
 		}
-		skb_shinfo(skb)->frags[j].size += curr_frag_len;
+		skb_frag_size_add(&skb_shinfo(skb)->frags[j], curr_frag_len);
 		skb->truesize += rx_frag_size;
 		remaining -= curr_frag_len;
 		index_inc(&rxcp->rxq_idx, rxq->len);
diff --git a/drivers/net/ethernet/ibm/ehea/ehea_main.c b/drivers/net/ethernet/ibm/ehea/ehea_main.c
index adb462d..0d4d4f6 100644
--- a/drivers/net/ethernet/ibm/ehea/ehea_main.c
+++ b/drivers/net/ethernet/ibm/ehea/ehea_main.c
@@ -1676,7 +1676,7 @@ static inline void write_swqe2_data(struct sk_buff *skb, struct net_device *dev,
 
 			/* copy sg1entry data */
 			sg1entry->l_key = lkey;
-			sg1entry->len = frag->size;
+			sg1entry->len = skb_frag_size(frag);
 			sg1entry->vaddr =
 				ehea_map_vaddr(skb_frag_address(frag));
 			swqe->descriptors++;
@@ -1689,7 +1689,7 @@ static inline void write_swqe2_data(struct sk_buff *skb, struct net_device *dev,
 			sgentry = &sg_list[i - sg1entry_contains_frag_data];
 
 			sgentry->l_key = lkey;
-			sgentry->len = frag->size;
+			sgentry->len = frag_size(frag);
 			sgentry->vaddr = ehea_map_vaddr(skb_frag_address(frag));
 			swqe->descriptors++;
 		}
diff --git a/drivers/net/ethernet/ibm/emac/core.c b/drivers/net/ethernet/ibm/emac/core.c
index 6b3a033..ed79b2d 100644
--- a/drivers/net/ethernet/ibm/emac/core.c
+++ b/drivers/net/ethernet/ibm/emac/core.c
@@ -1453,7 +1453,7 @@ static int emac_start_xmit_sg(struct sk_buff *skb, struct net_device *ndev)
 	/* skb fragments */
 	for (i = 0; i < nr_frags; ++i) {
 		struct skb_frag_struct *frag = &skb_shinfo(skb)->frags[i];
-		len = frag->size;
+		len = skb_frag_size(frag);
 
 		if (unlikely(dev->tx_cnt + mal_tx_chunks(len) >= NUM_TX_BUFF))
 			goto undo_frame;
diff --git a/drivers/net/ethernet/ibm/ibmveth.c b/drivers/net/ethernet/ibm/ibmveth.c
index 4da972e..b1cd41b 100644
--- a/drivers/net/ethernet/ibm/ibmveth.c
+++ b/drivers/net/ethernet/ibm/ibmveth.c
@@ -1014,15 +1014,15 @@ retry_bounce:
 
 	/* Map the frags */
 	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
-		skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
+		const skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
 
 		dma_addr = skb_frag_dma_map(&adapter->vdev->dev, frag, 0,
-					    frag->size, DMA_TO_DEVICE);
+					    skb_frag_size(frag), DMA_TO_DEVICE);
 
 		if (dma_mapping_error(&adapter->vdev->dev, dma_addr))
 			goto map_failed_frags;
 
-		descs[i+1].fields.flags_len = desc_flags | frag->size;
+		descs[i+1].fields.flags_len = desc_flags | skb_frag_size(frag);
 		descs[i+1].fields.address = dma_addr;
 	}
 
diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/net/ethernet/intel/e1000/e1000_main.c
index 7b54d72..cf480b5 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_main.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
@@ -2894,10 +2894,10 @@ static int e1000_tx_map(struct e1000_adapter *adapter,
 	}
 
 	for (f = 0; f < nr_frags; f++) {
-		struct skb_frag_struct *frag;
+		const struct skb_frag_struct *frag;
 
 		frag = &skb_shinfo(skb)->frags[f];
-		len = frag->size;
+		len = skb_frag_size(frag);
 		offset = 0;
 
 		while (len) {
@@ -3183,7 +3183,7 @@ static netdev_tx_t e1000_xmit_frame(struct sk_buff *skb,
 
 	nr_frags = skb_shinfo(skb)->nr_frags;
 	for (f = 0; f < nr_frags; f++)
-		count += TXD_USE_COUNT(skb_shinfo(skb)->frags[f].size,
+		count += TXD_USE_COUNT(skb_frag_size(&skb_shinfo(skb)->frags[f]),
 				       max_txd_pwr);
 	if (adapter->pcix_82544)
 		count += nr_frags;
diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 035ce73..6803127 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -4673,10 +4673,10 @@ static int e1000_tx_map(struct e1000_adapter *adapter,
 	}
 
 	for (f = 0; f < nr_frags; f++) {
-		struct skb_frag_struct *frag;
+		const struct skb_frag_struct *frag;
 
 		frag = &skb_shinfo(skb)->frags[f];
-		len = frag->size;
+		len = skb_frag_size(frag);
 		offset = 0;
 
 		while (len) {
@@ -4943,7 +4943,7 @@ static netdev_tx_t e1000_xmit_frame(struct sk_buff *skb,
 
 	nr_frags = skb_shinfo(skb)->nr_frags;
 	for (f = 0; f < nr_frags; f++)
-		count += TXD_USE_COUNT(skb_shinfo(skb)->frags[f].size,
+		count += TXD_USE_COUNT(skb_frag_size(&skb_shinfo(skb)->frags[f]),
 				       max_txd_pwr);
 
 	if (adapter->hw.mac.tx_pkt_filtering)
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 837adbb..f9b8182 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -4268,7 +4268,7 @@ static void igb_tx_map(struct igb_ring *tx_ring,
 			i = 0;
 		}
 
-		size = frag->size;
+		size = skb_frag_size(frag);
 		data_len -= size;
 
 		dma = skb_frag_dma_map(tx_ring->dev, frag, 0,
diff --git a/drivers/net/ethernet/intel/igbvf/netdev.c b/drivers/net/ethernet/intel/igbvf/netdev.c
index 23cc40f..1bd9abd 100644
--- a/drivers/net/ethernet/intel/igbvf/netdev.c
+++ b/drivers/net/ethernet/intel/igbvf/netdev.c
@@ -2045,7 +2045,7 @@ static inline int igbvf_tx_map_adv(struct igbvf_adapter *adapter,
 
 
 	for (f = 0; f < skb_shinfo(skb)->nr_frags; f++) {
-		struct skb_frag_struct *frag;
+		const struct skb_frag_struct *frag;
 
 		count++;
 		i++;
@@ -2053,7 +2053,7 @@ static inline int igbvf_tx_map_adv(struct igbvf_adapter *adapter,
 			i = 0;
 
 		frag = &skb_shinfo(skb)->frags[f];
-		len = frag->size;
+		len = skb_frag_size(frag);
 
 		buffer_info = &tx_ring->buffer_info[i];
 		BUG_ON(len >= IGBVF_MAX_DATA_PER_TXD);
diff --git a/drivers/net/ethernet/intel/ixgb/ixgb_main.c b/drivers/net/ethernet/intel/ixgb/ixgb_main.c
index 88558b1..e21148f 100644
--- a/drivers/net/ethernet/intel/ixgb/ixgb_main.c
+++ b/drivers/net/ethernet/intel/ixgb/ixgb_main.c
@@ -1383,10 +1383,10 @@ ixgb_tx_map(struct ixgb_adapter *adapter, struct sk_buff *skb,
 	}
 
 	for (f = 0; f < nr_frags; f++) {
-		struct skb_frag_struct *frag;
+		const struct skb_frag_struct *frag;
 
 		frag = &skb_shinfo(skb)->frags[f];
-		len = frag->size;
+		len = skb_frag_size(frag);
 		offset = 0;
 
 		while (len) {
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 8075d11..09b8e88 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -6545,9 +6545,9 @@ static void ixgbe_tx_map(struct ixgbe_ring *tx_ring,
 
 		frag = &skb_shinfo(skb)->frags[f];
 #ifdef IXGBE_FCOE
-		size = min_t(unsigned int, data_len, frag->size);
+		size = min_t(unsigned int, data_len, skb_frag_size(frag));
 #else
-		size = frag->size;
+		size = skb_frag_size(frag);
 #endif
 		data_len -= size;
 		f++;
diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index 4930c46..5e92cc2 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -2912,10 +2912,10 @@ static int ixgbevf_tx_map(struct ixgbevf_adapter *adapter,
 	}
 
 	for (f = 0; f < nr_frags; f++) {
-		struct skb_frag_struct *frag;
+		const struct skb_frag_struct *frag;
 
 		frag = &skb_shinfo(skb)->frags[f];
-		len = min((unsigned int)frag->size, total);
+		len = min((unsigned int)skb_frag_size(frag), total);
 		offset = 0;
 
 		while (len) {
@@ -3096,7 +3096,7 @@ static int ixgbevf_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 
 	count += TXD_USE_COUNT(skb_headlen(skb));
 	for (f = 0; f < skb_shinfo(skb)->nr_frags; f++)
-		count += TXD_USE_COUNT(skb_shinfo(skb)->frags[f].size);
+		count += TXD_USE_COUNT(skb_frag_size(&skb_shinfo(skb)->frags[f]));
 
 	if (ixgbevf_maybe_stop_tx(netdev, tx_ring, count)) {
 		adapter->tx_busy++;
diff --git a/drivers/net/ethernet/jme.c b/drivers/net/ethernet/jme.c
index 48a0a23..7a0c746f 100644
--- a/drivers/net/ethernet/jme.c
+++ b/drivers/net/ethernet/jme.c
@@ -1920,7 +1920,7 @@ jme_map_tx_skb(struct jme_adapter *jme, struct sk_buff *skb, int idx)
 	u8 hidma = jme->dev->features & NETIF_F_HIGHDMA;
 	int i, nr_frags = skb_shinfo(skb)->nr_frags;
 	int mask = jme->tx_ring_mask;
-	struct skb_frag_struct *frag;
+	const struct skb_frag_struct *frag;
 	u32 len;
 
 	for (i = 0 ; i < nr_frags ; ++i) {
@@ -1930,7 +1930,7 @@ jme_map_tx_skb(struct jme_adapter *jme, struct sk_buff *skb, int idx)
 
 		jme_fill_tx_map(jme->pdev, ctxdesc, ctxbi,
 				skb_frag_page(frag),
-				frag->page_offset, frag->size, hidma);
+				frag->page_offset, skb_frag_size(frag), hidma);
 	}
 
 	len = skb_is_nonlinear(skb) ? skb_headlen(skb) : skb->len;
diff --git a/drivers/net/ethernet/marvell/mv643xx_eth.c b/drivers/net/ethernet/marvell/mv643xx_eth.c
index f6821aa..194a031 100644
--- a/drivers/net/ethernet/marvell/mv643xx_eth.c
+++ b/drivers/net/ethernet/marvell/mv643xx_eth.c
@@ -713,8 +713,9 @@ static inline unsigned int has_tiny_unaligned_frags(struct sk_buff *skb)
 	int frag;
 
 	for (frag = 0; frag < skb_shinfo(skb)->nr_frags; frag++) {
-		skb_frag_t *fragp = &skb_shinfo(skb)->frags[frag];
-		if (fragp->size <= 8 && fragp->page_offset & 7)
+		const skb_frag_t *fragp = &skb_shinfo(skb)->frags[frag];
+
+		if (skb_frag_size(fragp) <= 8 && fragp->page_offset & 7)
 			return 1;
 	}
 
@@ -751,10 +752,10 @@ static void txq_submit_frag_skb(struct tx_queue *txq, struct sk_buff *skb)
 		}
 
 		desc->l4i_chk = 0;
-		desc->byte_cnt = this_frag->size;
+		desc->byte_cnt = skb_frag_size(this_frag);
 		desc->buf_ptr = skb_frag_dma_map(mp->dev->dev.parent,
 						 this_frag, 0,
-						 this_frag->size,
+						 skb_frag_size(this_frag),
 						 DMA_TO_DEVICE);
 	}
 }
diff --git a/drivers/net/ethernet/marvell/skge.c b/drivers/net/ethernet/marvell/skge.c
index 2977303..c7b6083 100644
--- a/drivers/net/ethernet/marvell/skge.c
+++ b/drivers/net/ethernet/marvell/skge.c
@@ -2770,10 +2770,10 @@ static netdev_tx_t skge_xmit_frame(struct sk_buff *skb,
 
 		control |= BMU_STFWD;
 		for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
-			skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
+			const skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
 
 			map = skb_frag_dma_map(&hw->pdev->dev, frag, 0,
-					       frag->size, DMA_TO_DEVICE);
+					       skb_frag_size(frag), DMA_TO_DEVICE);
 
 			e = e->next;
 			e->skb = skb;
@@ -2783,9 +2783,9 @@ static netdev_tx_t skge_xmit_frame(struct sk_buff *skb,
 			tf->dma_lo = map;
 			tf->dma_hi = (u64) map >> 32;
 			dma_unmap_addr_set(e, mapaddr, map);
-			dma_unmap_len_set(e, maplen, frag->size);
+			dma_unmap_len_set(e, maplen, skb_frag_size(frag));
 
-			tf->control = BMU_OWN | BMU_SW | control | frag->size;
+			tf->control = BMU_OWN | BMU_SW | control | skb_frag_size(frag);
 		}
 		tf->control |= BMU_EOF | BMU_IRQ_EOF;
 	}
diff --git a/drivers/net/ethernet/marvell/sky2.c b/drivers/net/ethernet/marvell/sky2.c
index 9263490..7b083c4 100644
--- a/drivers/net/ethernet/marvell/sky2.c
+++ b/drivers/net/ethernet/marvell/sky2.c
@@ -1225,10 +1225,10 @@ static int sky2_rx_map_skb(struct pci_dev *pdev, struct rx_ring_info *re,
 	dma_unmap_len_set(re, data_size, size);
 
 	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
-		skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
+		const skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
 
 		re->frag_addr[i] = skb_frag_dma_map(&pdev->dev, frag, 0,
-						    frag->size,
+						    skb_frag_size(frag),
 						    DMA_FROM_DEVICE);
 
 		if (dma_mapping_error(&pdev->dev, re->frag_addr[i]))
@@ -1239,7 +1239,7 @@ static int sky2_rx_map_skb(struct pci_dev *pdev, struct rx_ring_info *re,
 map_page_error:
 	while (--i >= 0) {
 		pci_unmap_page(pdev, re->frag_addr[i],
-			       skb_shinfo(skb)->frags[i].size,
+			       skb_frag_size(&skb_shinfo(skb)->frags[i]),
 			       PCI_DMA_FROMDEVICE);
 	}
 
@@ -1263,7 +1263,7 @@ static void sky2_rx_unmap_skb(struct pci_dev *pdev, struct rx_ring_info *re)
 
 	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++)
 		pci_unmap_page(pdev, re->frag_addr[i],
-			       skb_shinfo(skb)->frags[i].size,
+			       skb_frag_size(&skb_shinfo(skb)->frags[i]),
 			       PCI_DMA_FROMDEVICE);
 }
 
@@ -1936,7 +1936,7 @@ static netdev_tx_t sky2_xmit_frame(struct sk_buff *skb,
 		const skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
 
 		mapping = skb_frag_dma_map(&hw->pdev->dev, frag, 0,
-					   frag->size, DMA_TO_DEVICE);
+					   skb_frag_size(frag), DMA_TO_DEVICE);
 
 		if (dma_mapping_error(&hw->pdev->dev, mapping))
 			goto mapping_unwind;
@@ -1952,11 +1952,11 @@ static netdev_tx_t sky2_xmit_frame(struct sk_buff *skb,
 		re = sky2->tx_ring + slot;
 		re->flags = TX_MAP_PAGE;
 		dma_unmap_addr_set(re, mapaddr, mapping);
-		dma_unmap_len_set(re, maplen, frag->size);
+		dma_unmap_len_set(re, maplen, skb_frag_size(frag));
 
 		le = get_tx_le(sky2, &slot);
 		le->addr = cpu_to_le32(lower_32_bits(mapping));
-		le->length = cpu_to_le16(frag->size);
+		le->length = cpu_to_le16(skb_frag_size(frag));
 		le->ctrl = ctrl;
 		le->opcode = OP_BUFFER | HW_OWNER;
 	}
@@ -2484,7 +2484,7 @@ static void skb_put_frags(struct sk_buff *skb, unsigned int hdr_space,
 		} else {
 			size = min(length, (unsigned) PAGE_SIZE);
 
-			frag->size = size;
+			skb_frag_size_set(frag, size);
 			skb->data_len += size;
 			skb->truesize += PAGE_SIZE;
 			skb->len += size;
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index 37cc9e5..46a0df9 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -135,7 +135,7 @@ static void mlx4_en_init_rx_desc(struct mlx4_en_priv *priv,
 
 	/* Set size and memtype fields */
 	for (i = 0; i < priv->num_frags; i++) {
-		skb_frags[i].size = priv->frag_info[i].frag_size;
+		skb_frag_size_set(&skb_frags[i], priv->frag_info[i].frag_size);
 		rx_desc->data[i].byte_count =
 			cpu_to_be32(priv->frag_info[i].frag_size);
 		rx_desc->data[i].lkey = cpu_to_be32(priv->mdev->mr.key);
@@ -194,7 +194,7 @@ static void mlx4_en_free_rx_desc(struct mlx4_en_priv *priv,
 		dma = be64_to_cpu(rx_desc->data[nr].addr);
 
 		en_dbg(DRV, priv, "Unmapping buffer at dma:0x%llx\n", (u64) dma);
-		pci_unmap_single(mdev->pdev, dma, skb_frags[nr].size,
+		pci_unmap_single(mdev->pdev, dma, skb_frag_size(&skb_frags[nr]),
 				 PCI_DMA_FROMDEVICE);
 		put_page(skb_frags[nr].page);
 	}
@@ -421,7 +421,7 @@ static int mlx4_en_complete_rx_desc(struct mlx4_en_priv *priv,
 
 		/* Save page reference in skb */
 		skb_frags_rx[nr].page = skb_frags[nr].page;
-		skb_frags_rx[nr].size = skb_frags[nr].size;
+		skb_frag_size_set(&skb_frags_rx[nr], skb_frag_size(&skb_frags[nr]));
 		skb_frags_rx[nr].page_offset = skb_frags[nr].page_offset;
 		dma = be64_to_cpu(rx_desc->data[nr].addr);
 
@@ -430,13 +430,13 @@ static int mlx4_en_complete_rx_desc(struct mlx4_en_priv *priv,
 			goto fail;
 
 		/* Unmap buffer */
-		pci_unmap_single(mdev->pdev, dma, skb_frags_rx[nr].size,
+		pci_unmap_single(mdev->pdev, dma, skb_frag_size(&skb_frags_rx[nr]),
 				 PCI_DMA_FROMDEVICE);
 	}
 	/* Adjust size of last fragment to match actual length */
 	if (nr > 0)
-		skb_frags_rx[nr - 1].size = length -
-			priv->frag_info[nr - 1].frag_prefix_size;
+		skb_frag_size_set(&skb_frags_rx[nr - 1],
+			length - priv->frag_info[nr - 1].frag_prefix_size);
 	return nr;
 
 fail:
@@ -506,7 +506,7 @@ static struct sk_buff *mlx4_en_rx_skb(struct mlx4_en_priv *priv,
 		skb_shinfo(skb)->frags[0].page_offset += HEADER_COPY_SIZE;
 
 		/* Adjust size of first fragment */
-		skb_shinfo(skb)->frags[0].size -= HEADER_COPY_SIZE;
+		skb_frag_size_sub(&skb_shinfo(skb)->frags[0], HEADER_COPY_SIZE);
 		skb->data_len = length - HEADER_COPY_SIZE;
 	}
 	return skb;
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
index 6e03de0..2a192c2 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
@@ -226,7 +226,7 @@ static u32 mlx4_en_free_tx_desc(struct mlx4_en_priv *priv,
 				frag = &skb_shinfo(skb)->frags[i];
 				pci_unmap_page(mdev->pdev,
 					(dma_addr_t) be64_to_cpu(data[i].addr),
-					frag->size, PCI_DMA_TODEVICE);
+					skb_frag_size(frag), PCI_DMA_TODEVICE);
 			}
 		}
 		/* Stamp the freed descriptor */
@@ -256,7 +256,7 @@ static u32 mlx4_en_free_tx_desc(struct mlx4_en_priv *priv,
 				frag = &skb_shinfo(skb)->frags[i];
 				pci_unmap_page(mdev->pdev,
 					(dma_addr_t) be64_to_cpu(data->addr),
-					 frag->size, PCI_DMA_TODEVICE);
+					 skb_frag_size(frag), PCI_DMA_TODEVICE);
 				++data;
 			}
 		}
@@ -550,7 +550,7 @@ static void build_inline_wqe(struct mlx4_en_tx_desc *tx_desc, struct sk_buff *sk
 		skb_copy_from_linear_data(skb, inl + 1, skb_headlen(skb));
 		if (skb_shinfo(skb)->nr_frags)
 			memcpy(((void *)(inl + 1)) + skb_headlen(skb), fragptr,
-			       skb_shinfo(skb)->frags[0].size);
+			       skb_frag_size(&skb_shinfo(skb)->frags[0]));
 
 	} else {
 		inl->byte_count = cpu_to_be32(1 << 31 | spc);
@@ -570,7 +570,7 @@ static void build_inline_wqe(struct mlx4_en_tx_desc *tx_desc, struct sk_buff *sk
 					skb_headlen(skb) - spc);
 			if (skb_shinfo(skb)->nr_frags)
 				memcpy(((void *)(inl + 1)) + skb_headlen(skb) - spc,
-					fragptr, skb_shinfo(skb)->frags[0].size);
+					fragptr, skb_frag_size(&skb_shinfo(skb)->frags[0]));
 		}
 
 		wmb();
@@ -757,11 +757,11 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 		for (i = skb_shinfo(skb)->nr_frags - 1; i >= 0; i--) {
 			frag = &skb_shinfo(skb)->frags[i];
 			dma = pci_map_page(mdev->dev->pdev, frag->page, frag->page_offset,
-					   frag->size, PCI_DMA_TODEVICE);
+					   skb_frag_size(frag), PCI_DMA_TODEVICE);
 			data->addr = cpu_to_be64(dma);
 			data->lkey = cpu_to_be32(mdev->mr.key);
 			wmb();
-			data->byte_count = cpu_to_be32(frag->size);
+			data->byte_count = cpu_to_be32(skb_frag_size(frag));
 			--data;
 		}
 
diff --git a/drivers/net/ethernet/micrel/ksz884x.c b/drivers/net/ethernet/micrel/ksz884x.c
index 710c4ae..7ece990 100644
--- a/drivers/net/ethernet/micrel/ksz884x.c
+++ b/drivers/net/ethernet/micrel/ksz884x.c
@@ -4700,7 +4700,7 @@ static void send_packet(struct sk_buff *skb, struct net_device *dev)
 			++hw->tx_int_cnt;
 
 			dma_buf = DMA_BUFFER(desc);
-			dma_buf->len = this_frag->size;
+			dma_buf->len = skb_frag_size(this_frag);
 
 			dma_buf->dma = pci_map_single(
 				hw_priv->pdev,
diff --git a/drivers/net/ethernet/myricom/myri10ge/myri10ge.c b/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
index 2663727..c970a48 100644
--- a/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
+++ b/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
@@ -1216,7 +1216,7 @@ myri10ge_rx_skb_build(struct sk_buff *skb, u8 * va,
 	skb_frags = skb_shinfo(skb)->frags;
 	while (len > 0) {
 		memcpy(skb_frags, rx_frags, sizeof(*skb_frags));
-		len -= rx_frags->size;
+		len -= skb_frag_size(rx_frags);
 		skb_frags++;
 		rx_frags++;
 		skb_shinfo(skb)->nr_frags++;
@@ -1228,7 +1228,7 @@ myri10ge_rx_skb_build(struct sk_buff *skb, u8 * va,
 	 * manually */
 	skb_copy_to_linear_data(skb, va, hlen);
 	skb_shinfo(skb)->frags[0].page_offset += hlen;
-	skb_shinfo(skb)->frags[0].size -= hlen;
+	skb_frag_size_sub(&skb_shinfo(skb)->frags[0], hlen);
 	skb->data_len -= hlen;
 	skb->tail += hlen;
 	skb_pull(skb, MXGEFW_PAD);
@@ -1345,9 +1345,9 @@ myri10ge_rx_done(struct myri10ge_slice_state *ss, int len, __wsum csum,
 		__skb_frag_set_page(&rx_frags[i], rx->info[idx].page);
 		rx_frags[i].page_offset = rx->info[idx].page_offset;
 		if (remainder < MYRI10GE_ALLOC_SIZE)
-			rx_frags[i].size = remainder;
+			skb_frag_size_set(&rx_frags[i], remainder);
 		else
-			rx_frags[i].size = MYRI10GE_ALLOC_SIZE;
+			skb_frag_size_set(&rx_frags[i], MYRI10GE_ALLOC_SIZE);
 		rx->cnt++;
 		idx = rx->cnt & rx->mask;
 		remainder -= MYRI10GE_ALLOC_SIZE;
@@ -1355,7 +1355,7 @@ myri10ge_rx_done(struct myri10ge_slice_state *ss, int len, __wsum csum,
 
 	if (lro_enabled) {
 		rx_frags[0].page_offset += MXGEFW_PAD;
-		rx_frags[0].size -= MXGEFW_PAD;
+		skb_frag_size_sub(&rx_frags[0], MXGEFW_PAD);
 		len -= MXGEFW_PAD;
 		lro_receive_frags(&ss->rx_done.lro_mgr, rx_frags,
 				  /* opaque, will come back in get_frag_header */
@@ -1382,7 +1382,7 @@ myri10ge_rx_done(struct myri10ge_slice_state *ss, int len, __wsum csum,
 
 	/* Attach the pages to the skb, and trim off any padding */
 	myri10ge_rx_skb_build(skb, va, rx_frags, len, hlen);
-	if (skb_shinfo(skb)->frags[0].size <= 0) {
+	if (skb_frag_size(&skb_shinfo(skb)->frags[0]) <= 0) {
 		skb_frag_unref(skb, 0);
 		skb_shinfo(skb)->nr_frags = 0;
 	}
@@ -2926,7 +2926,7 @@ again:
 		idx = (count + tx->req) & tx->mask;
 		frag = &skb_shinfo(skb)->frags[frag_idx];
 		frag_idx++;
-		len = frag->size;
+		len = skb_frag_size(frag);
 		bus = skb_frag_dma_map(&mgp->pdev->dev, frag, 0, len,
 				       DMA_TO_DEVICE);
 		dma_unmap_addr_set(&tx->info[idx], bus, bus);
diff --git a/drivers/net/ethernet/natsemi/ns83820.c b/drivers/net/ethernet/natsemi/ns83820.c
index 73616b9..2b8f64d 100644
--- a/drivers/net/ethernet/natsemi/ns83820.c
+++ b/drivers/net/ethernet/natsemi/ns83820.c
@@ -1161,11 +1161,11 @@ again:
 			break;
 
 		buf = skb_frag_dma_map(&dev->pci_dev->dev, frag, 0,
-				       frag->size, DMA_TO_DEVICE);
+				       skb_frag_size(frag), DMA_TO_DEVICE);
 		dprintk("frag: buf=%08Lx  page=%08lx offset=%08lx\n",
 			(long long)buf, (long) page_to_pfn(frag->page),
 			frag->page_offset);
-		len = frag->size;
+		len = skb_frag_size(frag);
 		frag++;
 		nr_frags--;
 	}
diff --git a/drivers/net/ethernet/neterion/s2io.c b/drivers/net/ethernet/neterion/s2io.c
index bdd3e6a..c27fb3d 100644
--- a/drivers/net/ethernet/neterion/s2io.c
+++ b/drivers/net/ethernet/neterion/s2io.c
@@ -2350,12 +2350,12 @@ static struct sk_buff *s2io_txdl_getskb(struct fifo_info *fifo_data,
 	if (frg_cnt) {
 		txds++;
 		for (j = 0; j < frg_cnt; j++, txds++) {
-			skb_frag_t *frag = &skb_shinfo(skb)->frags[j];
+			const skb_frag_t *frag = &skb_shinfo(skb)->frags[j];
 			if (!txds->Buffer_Pointer)
 				break;
 			pci_unmap_page(nic->pdev,
 				       (dma_addr_t)txds->Buffer_Pointer,
-				       frag->size, PCI_DMA_TODEVICE);
+				       skb_frag_size(frag), PCI_DMA_TODEVICE);
 		}
 	}
 	memset(txdlp, 0, (sizeof(struct TxD) * fifo_data->max_txds));
@@ -4185,16 +4185,16 @@ static netdev_tx_t s2io_xmit(struct sk_buff *skb, struct net_device *dev)
 	frg_cnt = skb_shinfo(skb)->nr_frags;
 	/* For fragmented SKB. */
 	for (i = 0; i < frg_cnt; i++) {
-		skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
+		const skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
 		/* A '0' length fragment will be ignored */
-		if (!frag->size)
+		if (!skb_frag_size(frag))
 			continue;
 		txdp++;
 		txdp->Buffer_Pointer = (u64)skb_frag_dma_map(&sp->pdev->dev,
 							     frag, 0,
-							     frag->size,
+							     skb_frag_size(frag),
 							     DMA_TO_DEVICE);
-		txdp->Control_1 = TXD_BUFFER0_SIZE(frag->size);
+		txdp->Control_1 = TXD_BUFFER0_SIZE(skb_frag_size(frag));
 		if (offload_type == SKB_GSO_UDP)
 			txdp->Control_1 |= TXD_UFO_EN;
 	}
diff --git a/drivers/net/ethernet/neterion/vxge/vxge-main.c b/drivers/net/ethernet/neterion/vxge/vxge-main.c
index a66f8fc..671e166 100644
--- a/drivers/net/ethernet/neterion/vxge/vxge-main.c
+++ b/drivers/net/ethernet/neterion/vxge/vxge-main.c
@@ -585,7 +585,7 @@ vxge_xmit_compl(struct __vxge_hw_fifo *fifo_hw, void *dtr,
 		for (j = 0; j < frg_cnt; j++) {
 			pci_unmap_page(fifo->pdev,
 					txd_priv->dma_buffers[i++],
-					frag->size, PCI_DMA_TODEVICE);
+					skb_frag_size(frag), PCI_DMA_TODEVICE);
 			frag += 1;
 		}
 
@@ -920,11 +920,11 @@ vxge_xmit(struct sk_buff *skb, struct net_device *dev)
 	frag = &skb_shinfo(skb)->frags[0];
 	for (i = 0; i < frg_cnt; i++) {
 		/* ignore 0 length fragment */
-		if (!frag->size)
+		if (!skb_frag_size(frag))
 			continue;
 
 		dma_pointer = (u64)skb_frag_dma_map(&fifo->pdev->dev, frag,
-						    0, frag->size,
+						    0, skb_frag_size(frag),
 						    DMA_TO_DEVICE);
 
 		if (unlikely(dma_mapping_error(&fifo->pdev->dev, dma_pointer)))
@@ -936,7 +936,7 @@ vxge_xmit(struct sk_buff *skb, struct net_device *dev)
 
 		txdl_priv->dma_buffers[j] = dma_pointer;
 		vxge_hw_fifo_txdl_buffer_set(fifo_hw, dtr, j++, dma_pointer,
-					frag->size);
+					skb_frag_size(frag));
 		frag += 1;
 	}
 
@@ -979,7 +979,7 @@ _exit1:
 
 	for (; j < i; j++) {
 		pci_unmap_page(fifo->pdev, txdl_priv->dma_buffers[j],
-			frag->size, PCI_DMA_TODEVICE);
+			skb_frag_size(frag), PCI_DMA_TODEVICE);
 		frag += 1;
 	}
 
@@ -1050,7 +1050,7 @@ vxge_tx_term(void *dtrh, enum vxge_hw_txdl_state state, void *userdata)
 
 	for (j = 0; j < frg_cnt; j++) {
 		pci_unmap_page(fifo->pdev, txd_priv->dma_buffers[i++],
-			       frag->size, PCI_DMA_TODEVICE);
+			       skb_frag_size(frag), PCI_DMA_TODEVICE);
 		frag += 1;
 	}
 
diff --git a/drivers/net/ethernet/nvidia/forcedeth.c b/drivers/net/ethernet/nvidia/forcedeth.c
index d7763ab..1e37eb9 100644
--- a/drivers/net/ethernet/nvidia/forcedeth.c
+++ b/drivers/net/ethernet/nvidia/forcedeth.c
@@ -2099,8 +2099,10 @@ static netdev_tx_t nv_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	/* add fragments to entries count */
 	for (i = 0; i < fragments; i++) {
-		entries += (skb_shinfo(skb)->frags[i].size >> NV_TX2_TSO_MAX_SHIFT) +
-			   ((skb_shinfo(skb)->frags[i].size & (NV_TX2_TSO_MAX_SIZE-1)) ? 1 : 0);
+		u32 size = skb_frag_size(&skb_shinfo(skb)->frags[i]);
+
+		entries += (size >> NV_TX2_TSO_MAX_SHIFT) +
+			   ((size & (NV_TX2_TSO_MAX_SIZE-1)) ? 1 : 0);
 	}
 
 	spin_lock_irqsave(&np->lock, flags);
@@ -2138,8 +2140,8 @@ static netdev_tx_t nv_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	/* setup the fragments */
 	for (i = 0; i < fragments; i++) {
-		skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
-		u32 size = frag->size;
+		const skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
+		u32 size = skb_frag_size(frag);
 		offset = 0;
 
 		do {
@@ -2211,8 +2213,10 @@ static netdev_tx_t nv_start_xmit_optimized(struct sk_buff *skb,
 
 	/* add fragments to entries count */
 	for (i = 0; i < fragments; i++) {
-		entries += (skb_shinfo(skb)->frags[i].size >> NV_TX2_TSO_MAX_SHIFT) +
-			   ((skb_shinfo(skb)->frags[i].size & (NV_TX2_TSO_MAX_SIZE-1)) ? 1 : 0);
+		u32 size = skb_frag_size(&skb_shinfo(skb)->frags[i]);
+
+		entries += (size >> NV_TX2_TSO_MAX_SHIFT) +
+			   ((size & (NV_TX2_TSO_MAX_SIZE-1)) ? 1 : 0);
 	}
 
 	spin_lock_irqsave(&np->lock, flags);
@@ -2253,7 +2257,7 @@ static netdev_tx_t nv_start_xmit_optimized(struct sk_buff *skb,
 	/* setup the fragments */
 	for (i = 0; i < fragments; i++) {
 		skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
-		u32 size = frag->size;
+		u32 size = skb_frag_size(frag);
 		offset = 0;
 
 		do {
diff --git a/drivers/net/ethernet/pasemi/pasemi_mac.c b/drivers/net/ethernet/pasemi/pasemi_mac.c
index c6f0056..49b549f 100644
--- a/drivers/net/ethernet/pasemi/pasemi_mac.c
+++ b/drivers/net/ethernet/pasemi/pasemi_mac.c
@@ -300,9 +300,9 @@ static int pasemi_mac_unmap_tx_skb(struct pasemi_mac *mac,
 	pci_unmap_single(pdev, dmas[0], skb_headlen(skb), PCI_DMA_TODEVICE);
 
 	for (f = 0; f < nfrags; f++) {
-		skb_frag_t *frag = &skb_shinfo(skb)->frags[f];
+		const skb_frag_t *frag = &skb_shinfo(skb)->frags[f];
 
-		pci_unmap_page(pdev, dmas[f+1], frag->size, PCI_DMA_TODEVICE);
+		pci_unmap_page(pdev, dmas[f+1], skb_frag_size(frag), PCI_DMA_TODEVICE);
 	}
 	dev_kfree_skb_irq(skb);
 
@@ -1506,8 +1506,8 @@ static int pasemi_mac_start_tx(struct sk_buff *skb, struct net_device *dev)
 		skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
 
 		map[i + 1] = skb_frag_dma_map(&mac->dma_pdev->dev, frag, 0,
-					      frag->size, DMA_TO_DEVICE);
-		map_size[i+1] = frag->size;
+					      skb_frag_size(frag), DMA_TO_DEVICE);
+		map_size[i+1] = skb_frag_size(frag);
 		if (dma_mapping_error(&mac->dma_pdev->dev, map[i + 1])) {
 			nfrags = i;
 			goto out_err_nolock;
diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c b/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
index e2ba78b..8cf3173 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
@@ -1905,13 +1905,13 @@ netxen_map_tx_skb(struct pci_dev *pdev,
 		frag = &skb_shinfo(skb)->frags[i];
 		nf = &pbuf->frag_array[i+1];
 
-		map = skb_frag_dma_map(&pdev->dev, frag, 0, frag->size,
+		map = skb_frag_dma_map(&pdev->dev, frag, 0, skb_frag_size(frag),
 				       DMA_TO_DEVICE);
 		if (dma_mapping_error(&pdev->dev, map))
 			goto unwind;
 
 		nf->dma = map;
-		nf->length = frag->size;
+		nf->length = skb_frag_size(frag);
 	}
 
 	return 0;
@@ -1962,7 +1962,7 @@ netxen_nic_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 
 		for (i = 0; i < (frag_count - NETXEN_MAX_FRAGS_PER_TX); i++) {
 			frag = &skb_shinfo(skb)->frags[i];
-			delta += frag->size;
+			delta += skb_frag_size(frag);
 		}
 
 		if (!__pskb_pull_tail(skb, delta))
diff --git a/drivers/net/ethernet/qlogic/qla3xxx.c b/drivers/net/ethernet/qlogic/qla3xxx.c
index 46f9b64..a4bdff4 100644
--- a/drivers/net/ethernet/qlogic/qla3xxx.c
+++ b/drivers/net/ethernet/qlogic/qla3xxx.c
@@ -2388,7 +2388,7 @@ static int ql_send_map(struct ql3_adapter *qdev,
 			seg++;
 		}
 
-		map = skb_frag_dma_map(&qdev->pdev->dev, frag, 0, frag->size,
+		map = skb_frag_dma_map(&qdev->pdev->dev, frag, 0, skb_frag_size(frag),
 				       DMA_TO_DEVICE);
 
 		err = dma_mapping_error(&qdev->pdev->dev, map);
@@ -2401,9 +2401,9 @@ static int ql_send_map(struct ql3_adapter *qdev,
 
 		oal_entry->dma_lo = cpu_to_le32(LS_64BITS(map));
 		oal_entry->dma_hi = cpu_to_le32(MS_64BITS(map));
-		oal_entry->len = cpu_to_le32(frag->size);
+		oal_entry->len = cpu_to_le32(skb_frag_size(frag));
 		dma_unmap_addr_set(&tx_cb->map[seg], mapaddr, map);
-		dma_unmap_len_set(&tx_cb->map[seg], maplen, frag->size);
+		dma_unmap_len_set(&tx_cb->map[seg], maplen, skb_frag_size(frag));
 		}
 	/* Terminate the last segment. */
 	oal_entry->len |= cpu_to_le32(OAL_LAST_ENTRY);
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index eac19e7d..106503f 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -2135,13 +2135,13 @@ qlcnic_map_tx_skb(struct pci_dev *pdev,
 		frag = &skb_shinfo(skb)->frags[i];
 		nf = &pbuf->frag_array[i+1];
 
-		map = skb_frag_dma_map(&pdev->dev, frag, 0, frag->size,
+		map = skb_frag_dma_map(&pdev->dev, frag, 0, skb_frag_size(frag),
 				       DMA_TO_DEVICE);
 		if (dma_mapping_error(&pdev->dev, map))
 			goto unwind;
 
 		nf->dma = map;
-		nf->length = frag->size;
+		nf->length = skb_frag_size(frag);
 	}
 
 	return 0;
@@ -2221,7 +2221,7 @@ qlcnic_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	if (!skb_is_gso(skb) && frag_count > QLCNIC_MAX_FRAGS_PER_TX) {
 
 		for (i = 0; i < (frag_count - QLCNIC_MAX_FRAGS_PER_TX); i++)
-			delta += skb_shinfo(skb)->frags[i].size;
+			delta += skb_frag_size(&skb_shinfo(skb)->frags[i]);
 
 		if (!__pskb_pull_tail(skb, delta))
 			goto drop_packet;
diff --git a/drivers/net/ethernet/qlogic/qlge/qlge_main.c b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
index f2d9bb7..c92afcd 100644
--- a/drivers/net/ethernet/qlogic/qlge/qlge_main.c
+++ b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
@@ -1431,7 +1431,7 @@ static int ql_map_send(struct ql_adapter *qdev,
 			map_idx++;
 		}
 
-		map = skb_frag_dma_map(&qdev->pdev->dev, frag, 0, frag->size,
+		map = skb_frag_dma_map(&qdev->pdev->dev, frag, 0, skb_frag_size(frag),
 				       DMA_TO_DEVICE);
 
 		err = dma_mapping_error(&qdev->pdev->dev, map);
@@ -1443,10 +1443,10 @@ static int ql_map_send(struct ql_adapter *qdev,
 		}
 
 		tbd->addr = cpu_to_le64(map);
-		tbd->len = cpu_to_le32(frag->size);
+		tbd->len = cpu_to_le32(skb_frag_size(frag));
 		dma_unmap_addr_set(&tx_ring_desc->map[map_idx], mapaddr, map);
 		dma_unmap_len_set(&tx_ring_desc->map[map_idx], maplen,
-				  frag->size);
+				  skb_frag_size(frag));
 
 	}
 	/* Save the number of segments we've mapped. */
diff --git a/drivers/net/ethernet/realtek/8139cp.c b/drivers/net/ethernet/realtek/8139cp.c
index 5dcd5be..ee5da92 100644
--- a/drivers/net/ethernet/realtek/8139cp.c
+++ b/drivers/net/ethernet/realtek/8139cp.c
@@ -777,12 +777,12 @@ static netdev_tx_t cp_start_xmit (struct sk_buff *skb,
 		entry = NEXT_TX(entry);
 
 		for (frag = 0; frag < skb_shinfo(skb)->nr_frags; frag++) {
-			skb_frag_t *this_frag = &skb_shinfo(skb)->frags[frag];
+			const skb_frag_t *this_frag = &skb_shinfo(skb)->frags[frag];
 			u32 len;
 			u32 ctrl;
 			dma_addr_t mapping;
 
-			len = this_frag->size;
+			len = skb_frag_size(this_frag);
 			mapping = dma_map_single(&cp->pdev->dev,
 						 skb_frag_address(this_frag),
 						 len, PCI_DMA_TODEVICE);
diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 2ce6070..aa39e77 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -5413,7 +5413,7 @@ static int rtl8169_xmit_frags(struct rtl8169_private *tp, struct sk_buff *skb,
 
 	entry = tp->cur_tx;
 	for (cur_frag = 0; cur_frag < info->nr_frags; cur_frag++) {
-		skb_frag_t *frag = info->frags + cur_frag;
+		const skb_frag_t *frag = info->frags + cur_frag;
 		dma_addr_t mapping;
 		u32 status, len;
 		void *addr;
@@ -5421,7 +5421,7 @@ static int rtl8169_xmit_frags(struct rtl8169_private *tp, struct sk_buff *skb,
 		entry = (entry + 1) % NUM_TX_DESC;
 
 		txd = tp->TxDescArray + entry;
-		len = frag->size;
+		len = skb_frag_size(frag);
 		addr = skb_frag_address(frag);
 		mapping = dma_map_single(d, addr, len, DMA_TO_DEVICE);
 		if (unlikely(dma_mapping_error(d, mapping))) {
diff --git a/drivers/net/ethernet/sfc/rx.c b/drivers/net/ethernet/sfc/rx.c
index 91a6b71..adbda18 100644
--- a/drivers/net/ethernet/sfc/rx.c
+++ b/drivers/net/ethernet/sfc/rx.c
@@ -481,7 +481,7 @@ static void efx_rx_packet_gro(struct efx_channel *channel,
 		skb_frag_set_page(skb, 0, page);
 		skb_shinfo(skb)->frags[0].page_offset =
 			efx_rx_buf_offset(efx, rx_buf);
-		skb_shinfo(skb)->frags[0].size = rx_buf->len;
+		skb_frag_size_set(&skb_shinfo(skb)->frags[0], rx_buf->len);
 		skb_shinfo(skb)->nr_frags = 1;
 
 		skb->len = rx_buf->len;
diff --git a/drivers/net/ethernet/sfc/tx.c b/drivers/net/ethernet/sfc/tx.c
index 3964a62..df88c543 100644
--- a/drivers/net/ethernet/sfc/tx.c
+++ b/drivers/net/ethernet/sfc/tx.c
@@ -238,7 +238,7 @@ netdev_tx_t efx_enqueue_skb(struct efx_tx_queue *tx_queue, struct sk_buff *skb)
 		if (i >= skb_shinfo(skb)->nr_frags)
 			break;
 		fragment = &skb_shinfo(skb)->frags[i];
-		len = fragment->size;
+		len = skb_frag_size(fragment);
 		i++;
 		/* Map for DMA */
 		unmap_single = false;
@@ -926,11 +926,11 @@ static int tso_get_fragment(struct tso_state *st, struct efx_nic *efx,
 			    skb_frag_t *frag)
 {
 	st->unmap_addr = skb_frag_dma_map(&efx->pci_dev->dev, frag, 0,
-					  frag->size, DMA_TO_DEVICE);
+					  skb_frag_size(frag), DMA_TO_DEVICE);
 	if (likely(!dma_mapping_error(&efx->pci_dev->dev, st->unmap_addr))) {
 		st->unmap_single = false;
-		st->unmap_len = frag->size;
-		st->in_len = frag->size;
+		st->unmap_len = skb_frag_size(frag);
+		st->in_len = skb_frag_size(frag);
 		st->dma_addr = st->unmap_addr;
 		return 0;
 	}
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index c0ee6b6..87a6b2e 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -1106,8 +1106,8 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 	}
 
 	for (i = 0; i < nfrags; i++) {
-		skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
-		int len = frag->size;
+		const skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
+		int len = skb_frag_size(frag);
 
 		entry = (++priv->cur_tx) % txsize;
 		desc = priv->dma_tx + entry;
diff --git a/drivers/net/ethernet/sun/cassini.c b/drivers/net/ethernet/sun/cassini.c
index d9460d8..fd40988 100644
--- a/drivers/net/ethernet/sun/cassini.c
+++ b/drivers/net/ethernet/sun/cassini.c
@@ -2051,7 +2051,7 @@ static int cas_rx_process_pkt(struct cas *cp, struct cas_rx_comp *rxc,
 		__skb_frag_set_page(frag, page->buffer);
 		__skb_frag_ref(frag);
 		frag->page_offset = off;
-		frag->size = hlen - swivel;
+		skb_frag_size_set(frag, hlen - swivel);
 
 		/* any more data? */
 		if ((words[0] & RX_COMP1_SPLIT_PKT) && ((dlen -= hlen) > 0)) {
@@ -2075,7 +2075,7 @@ static int cas_rx_process_pkt(struct cas *cp, struct cas_rx_comp *rxc,
 			__skb_frag_set_page(frag, page->buffer);
 			__skb_frag_ref(frag);
 			frag->page_offset = 0;
-			frag->size = hlen;
+			skb_frag_size_set(frag, hlen);
 			RX_USED_ADD(page, hlen + cp->crc_size);
 		}
 
@@ -2826,9 +2826,9 @@ static inline int cas_xmit_tx_ringN(struct cas *cp, int ring,
 	entry = TX_DESC_NEXT(ring, entry);
 
 	for (frag = 0; frag < nr_frags; frag++) {
-		skb_frag_t *fragp = &skb_shinfo(skb)->frags[frag];
+		const skb_frag_t *fragp = &skb_shinfo(skb)->frags[frag];
 
-		len = fragp->size;
+		len = skb_frag_size(fragp);
 		mapping = skb_frag_dma_map(&cp->pdev->dev, fragp, 0, len,
 					   DMA_TO_DEVICE);
 
diff --git a/drivers/net/ethernet/sun/niu.c b/drivers/net/ethernet/sun/niu.c
index 23740e8..73c7081 100644
--- a/drivers/net/ethernet/sun/niu.c
+++ b/drivers/net/ethernet/sun/niu.c
@@ -3594,7 +3594,7 @@ static int release_tx_packet(struct niu *np, struct tx_ring_info *rp, int idx)
 		tb = &rp->tx_buffs[idx];
 		BUG_ON(tb->skb != NULL);
 		np->ops->unmap_page(np->device, tb->mapping,
-				    skb_shinfo(skb)->frags[i].size,
+				    skb_frag_size(&skb_shinfo(skb)->frags[i]),
 				    DMA_TO_DEVICE);
 		idx = NEXT_TX(rp, idx);
 	}
@@ -6727,9 +6727,9 @@ static netdev_tx_t niu_start_xmit(struct sk_buff *skb,
 	}
 
 	for (i = 0; i <  skb_shinfo(skb)->nr_frags; i++) {
-		skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
+		const skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
 
-		len = frag->size;
+		len = skb_frag_size(frag);
 		mapping = np->ops->map_page(np->device, skb_frag_page(frag),
 					    frag->page_offset, len,
 					    DMA_TO_DEVICE);
diff --git a/drivers/net/ethernet/sun/sungem.c b/drivers/net/ethernet/sun/sungem.c
index 6b62a73..ceab215 100644
--- a/drivers/net/ethernet/sun/sungem.c
+++ b/drivers/net/ethernet/sun/sungem.c
@@ -1065,12 +1065,12 @@ static netdev_tx_t gem_start_xmit(struct sk_buff *skb,
 		entry = NEXT_TX(entry);
 
 		for (frag = 0; frag < skb_shinfo(skb)->nr_frags; frag++) {
-			skb_frag_t *this_frag = &skb_shinfo(skb)->frags[frag];
+			const skb_frag_t *this_frag = &skb_shinfo(skb)->frags[frag];
 			u32 len;
 			dma_addr_t mapping;
 			u64 this_ctrl;
 
-			len = this_frag->size;
+			len = skb_frag_size(this_frag);
 			mapping = skb_frag_dma_map(&gp->pdev->dev, this_frag,
 						   0, len, DMA_TO_DEVICE);
 			this_ctrl = ctrl;
diff --git a/drivers/net/ethernet/sun/sunhme.c b/drivers/net/ethernet/sun/sunhme.c
index 869d47b..c517dac 100644
--- a/drivers/net/ethernet/sun/sunhme.c
+++ b/drivers/net/ethernet/sun/sunhme.c
@@ -2305,10 +2305,10 @@ static netdev_tx_t happy_meal_start_xmit(struct sk_buff *skb,
 		entry = NEXT_TX(entry);
 
 		for (frag = 0; frag < skb_shinfo(skb)->nr_frags; frag++) {
-			skb_frag_t *this_frag = &skb_shinfo(skb)->frags[frag];
+			const skb_frag_t *this_frag = &skb_shinfo(skb)->frags[frag];
 			u32 len, mapping, this_txflags;
 
-			len = this_frag->size;
+			len = skb_frag_size(this_frag);
 			mapping = skb_frag_dma_map(hp->dma_dev, this_frag,
 						   0, len, DMA_TO_DEVICE);
 			this_txflags = tx_flags;
diff --git a/drivers/net/ethernet/tehuti/tehuti.c b/drivers/net/ethernet/tehuti/tehuti.c
index c77e3bf..3a90af6 100644
--- a/drivers/net/ethernet/tehuti/tehuti.c
+++ b/drivers/net/ethernet/tehuti/tehuti.c
@@ -1493,12 +1493,12 @@ bdx_tx_map_skb(struct bdx_priv *priv, struct sk_buff *skb,
 	bdx_tx_db_inc_wptr(db);
 
 	for (i = 0; i < nr_frags; i++) {
-		struct skb_frag_struct *frag;
+		const struct skb_frag_struct *frag;
 
 		frag = &skb_shinfo(skb)->frags[i];
-		db->wptr->len = frag->size;
+		db->wptr->len = skb_frag_size(frag);
 		db->wptr->addr.dma = skb_frag_dma_map(&priv->pdev->dev, frag,
-						      0, frag->size,
+						      0, skb_frag_size(frag),
 						      DMA_TO_DEVICE);
 
 		pbl++;
diff --git a/drivers/net/ethernet/tile/tilepro.c b/drivers/net/ethernet/tile/tilepro.c
index 1e2af96..78e3fb2 100644
--- a/drivers/net/ethernet/tile/tilepro.c
+++ b/drivers/net/ethernet/tile/tilepro.c
@@ -1713,7 +1713,7 @@ static unsigned int tile_net_tx_frags(lepp_frag_t *frags,
 		cpa = ((phys_addr_t)pfn << PAGE_SHIFT) + f->page_offset;
 		frags[n].cpa_lo = cpa;
 		frags[n].cpa_hi = cpa >> 32;
-		frags[n].length = f->size;
+		frags[n].length = skb_frag_size(f);
 		frags[n].hash_for_home = hash_for_home;
 		n++;
 	}
diff --git a/drivers/net/ethernet/tundra/tsi108_eth.c b/drivers/net/ethernet/tundra/tsi108_eth.c
index a03996c..a8df7ec 100644
--- a/drivers/net/ethernet/tundra/tsi108_eth.c
+++ b/drivers/net/ethernet/tundra/tsi108_eth.c
@@ -709,13 +709,13 @@ static int tsi108_send_packet(struct sk_buff * skb, struct net_device *dev)
 			data->txring[tx].len = skb_headlen(skb);
 			misc |= TSI108_TX_SOF;
 		} else {
-			skb_frag_t *frag = &skb_shinfo(skb)->frags[i - 1];
+			const skb_frag_t *frag = &skb_shinfo(skb)->frags[i - 1];
 
 			data->txring[tx].buf0 = skb_frag_dma_map(NULL, frag,
 								 0,
-								 frag->size,
+								 skb_frag_size(frag),
 								 DMA_TO_DEVICE);
-			data->txring[tx].len = frag->size;
+			data->txring[tx].len = skb_frag_size(frag);
 		}
 
 		if (i == frags - 1)
diff --git a/drivers/net/ethernet/via/via-velocity.c b/drivers/net/ethernet/via/via-velocity.c
index b47bce1..4535d7c 100644
--- a/drivers/net/ethernet/via/via-velocity.c
+++ b/drivers/net/ethernet/via/via-velocity.c
@@ -2554,16 +2554,16 @@ static netdev_tx_t velocity_xmit(struct sk_buff *skb,
 
 	/* Handle fragments */
 	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
-		skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
+		const skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
 
 		tdinfo->skb_dma[i + 1] = skb_frag_dma_map(&vptr->pdev->dev,
 							  frag, 0,
-							  frag->size,
+							  skb_frag_size(frag),
 							  DMA_TO_DEVICE);
 
 		td_ptr->td_buf[i + 1].pa_low = cpu_to_le32(tdinfo->skb_dma[i + 1]);
 		td_ptr->td_buf[i + 1].pa_high = 0;
-		td_ptr->td_buf[i + 1].size = cpu_to_le16(frag->size);
+		td_ptr->td_buf[i + 1].size = cpu_to_le16(skb_frag_size(frag));
 	}
 	tdinfo->nskb_dma = i + 1;
 
diff --git a/drivers/net/ethernet/xilinx/ll_temac_main.c b/drivers/net/ethernet/xilinx/ll_temac_main.c
index 66e3c36..85ba4d9 100644
--- a/drivers/net/ethernet/xilinx/ll_temac_main.c
+++ b/drivers/net/ethernet/xilinx/ll_temac_main.c
@@ -716,8 +716,8 @@ static int temac_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 		cur_p = &lp->tx_bd_v[lp->tx_bd_tail];
 		cur_p->phys = dma_map_single(ndev->dev.parent,
 					     skb_frag_address(frag),
-					     frag->size, DMA_TO_DEVICE);
-		cur_p->len = frag->size;
+					     frag_size(frag), DMA_TO_DEVICE);
+		cur_p->len = frag_size(frag);
 		cur_p->app0 = 0;
 		frag++;
 	}
diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index b8225f3..0d4841b 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -147,14 +147,14 @@ static void set_skb_frag(struct sk_buff *skb, struct page *page,
 	skb_frag_t *f;
 
 	f = &skb_shinfo(skb)->frags[i];
-	f->size = min((unsigned)PAGE_SIZE - offset, *len);
+	skb_frag_size_set(f, min((unsigned)PAGE_SIZE - offset, *len));
 	f->page_offset = offset;
 	__skb_frag_set_page(f, page);
 
-	skb->data_len += f->size;
-	skb->len += f->size;
+	skb->data_len += skb_frag_size(f);
+	skb->len += skb_frag_size(f);
 	skb_shinfo(skb)->nr_frags++;
-	*len -= f->size;
+	*len -= skb_frag_size(f);
 }
 
 static struct sk_buff *page_to_skb(struct virtnet_info *vi,
diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vmxnet3_drv.c
index 902f284..b771eba 100644
--- a/drivers/net/vmxnet3/vmxnet3_drv.c
+++ b/drivers/net/vmxnet3/vmxnet3_drv.c
@@ -656,8 +656,8 @@ vmxnet3_append_frag(struct sk_buff *skb, struct Vmxnet3_RxCompDesc *rcd,
 
 	__skb_frag_set_page(frag, rbi->page);
 	frag->page_offset = 0;
-	frag->size = rcd->len;
-	skb->data_len += frag->size;
+	skb_frag_size_set(frag, rcd->len);
+	skb->data_len += rcd->len;
 	skb->truesize += PAGE_SIZE;
 	skb_shinfo(skb)->nr_frags++;
 }
@@ -745,21 +745,21 @@ vmxnet3_map_pkt(struct sk_buff *skb, struct vmxnet3_tx_ctx *ctx,
 	}
 
 	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
-		struct skb_frag_struct *frag = &skb_shinfo(skb)->frags[i];
+		const struct skb_frag_struct *frag = &skb_shinfo(skb)->frags[i];
 
 		tbi = tq->buf_info + tq->tx_ring.next2fill;
 		tbi->map_type = VMXNET3_MAP_PAGE;
 		tbi->dma_addr = skb_frag_dma_map(&adapter->pdev->dev, frag,
-						 0, frag->size,
+						 0, skb_frag_size(frag),
 						 DMA_TO_DEVICE);
 
-		tbi->len = frag->size;
+		tbi->len = skb_frag_size(frag);
 
 		gdesc = tq->tx_ring.base + tq->tx_ring.next2fill;
 		BUG_ON(gdesc->txd.gen == tq->tx_ring.gen);
 
 		gdesc->txd.addr = cpu_to_le64(tbi->dma_addr);
-		gdesc->dword[2] = cpu_to_le32(dw2 | frag->size);
+		gdesc->dword[2] = cpu_to_le32(dw2 | skb_frag_size(frag));
 		gdesc->dword[3] = 0;
 
 		dev_dbg(&adapter->netdev->dev,
diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index 8d70b44..d550895 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -334,7 +334,7 @@ unsigned int xen_netbk_count_skb_slots(struct xenvif *vif, struct sk_buff *skb)
 		count++;
 
 	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
-		unsigned long size = skb_shinfo(skb)->frags[i].size;
+		unsigned long size = skb_frag_size(&skb_shinfo(skb)->frags[i]);
 		unsigned long bytes;
 		while (size > 0) {
 			BUG_ON(copy_off > MAX_BUFFER_OFFSET);
@@ -526,7 +526,7 @@ static int netbk_gop_skb(struct sk_buff *skb,
 	for (i = 0; i < nr_frags; i++) {
 		netbk_gop_frag_copy(vif, skb, npo,
 				    skb_frag_page(&skb_shinfo(skb)->frags[i]),
-				    skb_shinfo(skb)->frags[i].size,
+				    skb_frag_size(&skb_shinfo(skb)->frags[i]),
 				    skb_shinfo(skb)->frags[i].page_offset,
 				    &head);
 	}
diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index 6e5d4c0..226faab 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -467,7 +467,7 @@ static void xennet_make_frags(struct sk_buff *skb, struct net_device *dev,
 
 		tx->gref = np->grant_tx_ref[id] = ref;
 		tx->offset = frag->page_offset;
-		tx->size = frag->size;
+		tx->size = skb_frag_size(frag);
 		tx->flags = 0;
 	}
 
@@ -965,7 +965,7 @@ err:
 		if (rx->status > len) {
 			skb_shinfo(skb)->frags[0].page_offset =
 				rx->offset + len;
-			skb_shinfo(skb)->frags[0].size = rx->status - len;
+			skb_frag_size_set(&skb_shinfo(skb)->frags[0], rx->status - len);
 			skb->data_len = rx->status - len;
 		} else {
 			__skb_fill_page_desc(skb, 0, NULL, 0, 0);
diff --git a/drivers/scsi/cxgbi/libcxgbi.c b/drivers/scsi/cxgbi/libcxgbi.c
index 77ac217..be69da3 100644
--- a/drivers/scsi/cxgbi/libcxgbi.c
+++ b/drivers/scsi/cxgbi/libcxgbi.c
@@ -1814,8 +1814,8 @@ static int sgl_read_to_frags(struct scatterlist *sg, unsigned int sgoffset,
 		copy = min(datalen, sglen);
 		if (i && page == frags[i - 1].page &&
 		    sgoffset + sg->offset ==
-			frags[i - 1].page_offset + frags[i - 1].size) {
-			frags[i - 1].size += copy;
+			frags[i - 1].page_offset + skb_frag_size(&frags[i - 1])) {
+			skb_frag_size_add(&frags[i - 1], copy);
 		} else {
 			if (i >= frag_max) {
 				pr_warn("too many pages %u, dlen %u.\n",
@@ -1825,7 +1825,7 @@ static int sgl_read_to_frags(struct scatterlist *sg, unsigned int sgoffset,
 
 			frags[i].page = page;
 			frags[i].page_offset = sg->offset + sgoffset;
-			frags[i].size = copy;
+			skb_frag_size_set(&frags[i], copy);
 			i++;
 		}
 		datalen -= copy;
@@ -1951,8 +1951,8 @@ int cxgbi_conn_init_pdu(struct iscsi_task *task, unsigned int offset,
 				char *src = kmap_atomic(frag->page,
 							KM_SOFTIRQ0);
 
-				memcpy(dst, src+frag->page_offset, frag->size);
-				dst += frag->size;
+				memcpy(dst, src+frag->page_offset, skb_frag_size(frag));
+				dst += skb_frag_size(frag);
 				kunmap_atomic(src, KM_SOFTIRQ0);
 			}
 			if (padlen) {
diff --git a/drivers/scsi/fcoe/fcoe_transport.c b/drivers/scsi/fcoe/fcoe_transport.c
index f6613f9..dac8e39 100644
--- a/drivers/scsi/fcoe/fcoe_transport.c
+++ b/drivers/scsi/fcoe/fcoe_transport.c
@@ -105,7 +105,7 @@ u32 fcoe_fc_crc(struct fc_frame *fp)
 	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
 		frag = &skb_shinfo(skb)->frags[i];
 		off = frag->page_offset;
-		len = frag->size;
+		len = skb_frag_size(frag);
 		while (len > 0) {
 			clen = min(len, PAGE_SIZE - (off & ~PAGE_MASK));
 			data = kmap_atomic(
diff --git a/drivers/staging/hv/netvsc_drv.c b/drivers/staging/hv/netvsc_drv.c
index 58792ae..4c7739f 100644
--- a/drivers/staging/hv/netvsc_drv.c
+++ b/drivers/staging/hv/netvsc_drv.c
@@ -169,11 +169,11 @@ static int netvsc_start_xmit(struct sk_buff *skb, struct net_device *net)
 
 	/* Additional fragments are after SKB data */
 	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
-		skb_frag_t *f = &skb_shinfo(skb)->frags[i];
+		const skb_frag_t *f = &skb_shinfo(skb)->frags[i];
 
 		packet->page_buf[i+2].pfn = page_to_pfn(skb_frag_page(f));
 		packet->page_buf[i+2].offset = f->page_offset;
-		packet->page_buf[i+2].len = f->size;
+		packet->page_buf[i+2].len = skb_frag_size(f);
 	}
 
 	/* Set the completion routine */
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 64f8695..6fcbbbd 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -150,6 +150,26 @@ struct skb_frag_struct {
 #endif
 };
 
+static inline unsigned int skb_frag_size(const skb_frag_t *frag)
+{
+	return frag->size;
+}
+
+static inline void skb_frag_size_set(skb_frag_t *frag, unsigned int size)
+{
+	frag->size = size;
+}
+
+static inline void skb_frag_size_add(skb_frag_t *frag, int delta)
+{
+	frag->size += delta;
+}
+
+static inline void skb_frag_size_sub(skb_frag_t *frag, int delta)
+{
+	frag->size -= delta;
+}
+
 #define HAVE_HW_TIME_STAMP
 
 /**
@@ -1132,7 +1152,7 @@ static inline int skb_pagelen(const struct sk_buff *skb)
 	int i, len = 0;
 
 	for (i = (int)skb_shinfo(skb)->nr_frags - 1; i >= 0; i--)
-		len += skb_shinfo(skb)->frags[i].size;
+		len += skb_frag_size(&skb_shinfo(skb)->frags[i]);
 	return len + skb_headlen(skb);
 }
 
@@ -1156,7 +1176,7 @@ static inline void __skb_fill_page_desc(struct sk_buff *skb, int i,
 
 	frag->page		  = page;
 	frag->page_offset	  = off;
-	frag->size		  = size;
+	skb_frag_size_set(frag, size);
 }
 
 /**
@@ -1907,10 +1927,10 @@ static inline int skb_can_coalesce(struct sk_buff *skb, int i,
 				   const struct page *page, int off)
 {
 	if (i) {
-		struct skb_frag_struct *frag = &skb_shinfo(skb)->frags[i - 1];
+		const struct skb_frag_struct *frag = &skb_shinfo(skb)->frags[i - 1];
 
 		return page == skb_frag_page(frag) &&
-		       off == frag->page_offset + frag->size;
+		       off == frag->page_offset + skb_frag_size(frag);
 	}
 	return 0;
 }
diff --git a/net/appletalk/ddp.c b/net/appletalk/ddp.c
index b1fe7c3..bfa9ab9 100644
--- a/net/appletalk/ddp.c
+++ b/net/appletalk/ddp.c
@@ -951,13 +951,12 @@ static unsigned long atalk_sum_skb(const struct sk_buff *skb, int offset,
 	/* checksum stuff in frags */
 	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
 		int end;
-
+		const skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
 		WARN_ON(start > offset + len);
 
-		end = start + skb_shinfo(skb)->frags[i].size;
+		end = start + skb_frag_size(frag);
 		if ((copy = end - offset) > 0) {
 			u8 *vaddr;
-			skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
 
 			if (copy > len)
 				copy = len;
diff --git a/net/core/datagram.c b/net/core/datagram.c
index 6449bed..68bbf9f 100644
--- a/net/core/datagram.c
+++ b/net/core/datagram.c
@@ -324,14 +324,14 @@ int skb_copy_datagram_iovec(const struct sk_buff *skb, int offset,
 	/* Copy paged appendix. Hmm... why does this look so complicated? */
 	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
 		int end;
+		const skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
 
 		WARN_ON(start > offset + len);
 
-		end = start + skb_shinfo(skb)->frags[i].size;
+		end = start + skb_frag_size(frag);
 		if ((copy = end - offset) > 0) {
 			int err;
 			u8  *vaddr;
-			skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
 			struct page *page = skb_frag_page(frag);
 
 			if (copy > len)
@@ -410,14 +410,14 @@ int skb_copy_datagram_const_iovec(const struct sk_buff *skb, int offset,
 	/* Copy paged appendix. Hmm... why does this look so complicated? */
 	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
 		int end;
+		const skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
 
 		WARN_ON(start > offset + len);
 
-		end = start + skb_shinfo(skb)->frags[i].size;
+		end = start + skb_frag_size(frag);
 		if ((copy = end - offset) > 0) {
 			int err;
 			u8  *vaddr;
-			skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
 			struct page *page = skb_frag_page(frag);
 
 			if (copy > len)
@@ -500,14 +500,14 @@ int skb_copy_datagram_from_iovec(struct sk_buff *skb, int offset,
 	/* Copy paged appendix. Hmm... why does this look so complicated? */
 	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
 		int end;
+		const skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
 
 		WARN_ON(start > offset + len);
 
-		end = start + skb_shinfo(skb)->frags[i].size;
+		end = start + skb_frag_size(frag);
 		if ((copy = end - offset) > 0) {
 			int err;
 			u8  *vaddr;
-			skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
 			struct page *page = skb_frag_page(frag);
 
 			if (copy > len)
@@ -585,15 +585,15 @@ static int skb_copy_and_csum_datagram(const struct sk_buff *skb, int offset,
 
 	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
 		int end;
+		const skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
 
 		WARN_ON(start > offset + len);
 
-		end = start + skb_shinfo(skb)->frags[i].size;
+		end = start + skb_frag_size(frag);
 		if ((copy = end - offset) > 0) {
 			__wsum csum2;
 			int err = 0;
 			u8  *vaddr;
-			skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
 			struct page *page = skb_frag_page(frag);
 
 			if (copy > len)
diff --git a/net/core/dev.c b/net/core/dev.c
index 8b6118a..cbb5918 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3489,9 +3489,9 @@ pull:
 		skb->data_len -= grow;
 
 		skb_shinfo(skb)->frags[0].page_offset += grow;
-		skb_shinfo(skb)->frags[0].size -= grow;
+		skb_frag_size_sub(&skb_shinfo(skb)->frags[0], grow);
 
-		if (unlikely(!skb_shinfo(skb)->frags[0].size)) {
+		if (unlikely(!skb_frag_size(&skb_shinfo(skb)->frags[0]))) {
 			skb_frag_unref(skb, 0);
 			memmove(skb_shinfo(skb)->frags,
 				skb_shinfo(skb)->frags + 1,
@@ -3559,7 +3559,7 @@ void skb_gro_reset_offset(struct sk_buff *skb)
 	    !PageHighMem(skb_frag_page(&skb_shinfo(skb)->frags[0]))) {
 		NAPI_GRO_CB(skb)->frag0 =
 			skb_frag_address(&skb_shinfo(skb)->frags[0]);
-		NAPI_GRO_CB(skb)->frag0_len = skb_shinfo(skb)->frags[0].size;
+		NAPI_GRO_CB(skb)->frag0_len = skb_frag_size(&skb_shinfo(skb)->frags[0]);
 	}
 }
 EXPORT_SYMBOL(skb_gro_reset_offset);
diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 796044a..38d6577 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -2606,13 +2606,13 @@ static void pktgen_finalize_skb(struct pktgen_dev *pkt_dev, struct sk_buff *skb,
 			skb_shinfo(skb)->frags[i].page_offset = 0;
 			/*last fragment, fill rest of data*/
 			if (i == (frags - 1))
-				skb_shinfo(skb)->frags[i].size =
-				    (datalen < PAGE_SIZE ? datalen : PAGE_SIZE);
+				skb_frag_size_set(&skb_shinfo(skb)->frags[i],
+				    (datalen < PAGE_SIZE ? datalen : PAGE_SIZE));
 			else
-				skb_shinfo(skb)->frags[i].size = frag_len;
-			datalen -= skb_shinfo(skb)->frags[i].size;
-			skb->len += skb_shinfo(skb)->frags[i].size;
-			skb->data_len += skb_shinfo(skb)->frags[i].size;
+				skb_frag_size_set(&skb_shinfo(skb)->frags[i], frag_len);
+			datalen -= skb_frag_size(&skb_shinfo(skb)->frags[i]);
+			skb->len += skb_frag_size(&skb_shinfo(skb)->frags[i]);
+			skb->data_len += skb_frag_size(&skb_shinfo(skb)->frags[i]);
 			i++;
 			skb_shinfo(skb)->nr_frags = i;
 		}
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index a7f855d..ce357d9 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -659,7 +659,7 @@ int skb_copy_ubufs(struct sk_buff *skb, gfp_t gfp_mask)
 		}
 		vaddr = kmap_skb_frag(&skb_shinfo(skb)->frags[i]);
 		memcpy(page_address(page),
-		       vaddr + f->page_offset, f->size);
+		       vaddr + f->page_offset, skb_frag_size(f));
 		kunmap_skb_frag(vaddr);
 		page->private = (unsigned long)head;
 		head = page;
@@ -1190,14 +1190,14 @@ int ___pskb_trim(struct sk_buff *skb, unsigned int len)
 		goto drop_pages;
 
 	for (; i < nfrags; i++) {
-		int end = offset + skb_shinfo(skb)->frags[i].size;
+		int end = offset + skb_frag_size(&skb_shinfo(skb)->frags[i]);
 
 		if (end < len) {
 			offset = end;
 			continue;
 		}
 
-		skb_shinfo(skb)->frags[i++].size = len - offset;
+		skb_frag_size_set(&skb_shinfo(skb)->frags[i++], len - offset);
 
 drop_pages:
 		skb_shinfo(skb)->nr_frags = i;
@@ -1306,9 +1306,11 @@ unsigned char *__pskb_pull_tail(struct sk_buff *skb, int delta)
 	/* Estimate size of pulled pages. */
 	eat = delta;
 	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
-		if (skb_shinfo(skb)->frags[i].size >= eat)
+		int size = skb_frag_size(&skb_shinfo(skb)->frags[i]);
+
+		if (size >= eat)
 			goto pull_pages;
-		eat -= skb_shinfo(skb)->frags[i].size;
+		eat -= size;
 	}
 
 	/* If we need update frag list, we are in troubles.
@@ -1371,14 +1373,16 @@ pull_pages:
 	eat = delta;
 	k = 0;
 	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
-		if (skb_shinfo(skb)->frags[i].size <= eat) {
+		int size = skb_frag_size(&skb_shinfo(skb)->frags[i]);
+
+		if (size <= eat) {
 			skb_frag_unref(skb, i);
-			eat -= skb_shinfo(skb)->frags[i].size;
+			eat -= size;
 		} else {
 			skb_shinfo(skb)->frags[k] = skb_shinfo(skb)->frags[i];
 			if (eat) {
 				skb_shinfo(skb)->frags[k].page_offset += eat;
-				skb_shinfo(skb)->frags[k].size -= eat;
+				skb_frag_size_sub(&skb_shinfo(skb)->frags[k], eat);
 				eat = 0;
 			}
 			k++;
@@ -1433,7 +1437,7 @@ int skb_copy_bits(const struct sk_buff *skb, int offset, void *to, int len)
 
 		WARN_ON(start > offset + len);
 
-		end = start + skb_shinfo(skb)->frags[i].size;
+		end = start + skb_frag_size(&skb_shinfo(skb)->frags[i]);
 		if ((copy = end - offset) > 0) {
 			u8 *vaddr;
 
@@ -1632,7 +1636,7 @@ static int __skb_splice_bits(struct sk_buff *skb, struct pipe_inode_info *pipe,
 		const skb_frag_t *f = &skb_shinfo(skb)->frags[seg];
 
 		if (__splice_segment(skb_frag_page(f),
-				     f->page_offset, f->size,
+				     f->page_offset, skb_frag_size(f),
 				     offset, len, skb, spd, 0, sk, pipe))
 			return 1;
 	}
@@ -1742,7 +1746,7 @@ int skb_store_bits(struct sk_buff *skb, int offset, const void *from, int len)
 
 		WARN_ON(start > offset + len);
 
-		end = start + frag->size;
+		end = start + skb_frag_size(frag);
 		if ((copy = end - offset) > 0) {
 			u8 *vaddr;
 
@@ -1815,7 +1819,7 @@ __wsum skb_checksum(const struct sk_buff *skb, int offset,
 
 		WARN_ON(start > offset + len);
 
-		end = start + skb_shinfo(skb)->frags[i].size;
+		end = start + skb_frag_size(&skb_shinfo(skb)->frags[i]);
 		if ((copy = end - offset) > 0) {
 			__wsum csum2;
 			u8 *vaddr;
@@ -1890,7 +1894,7 @@ __wsum skb_copy_and_csum_bits(const struct sk_buff *skb, int offset,
 
 		WARN_ON(start > offset + len);
 
-		end = start + skb_shinfo(skb)->frags[i].size;
+		end = start + skb_frag_size(&skb_shinfo(skb)->frags[i]);
 		if ((copy = end - offset) > 0) {
 			__wsum csum2;
 			u8 *vaddr;
@@ -2163,7 +2167,7 @@ static inline void skb_split_no_header(struct sk_buff *skb,
 	skb->data_len		  = len - pos;
 
 	for (i = 0; i < nfrags; i++) {
-		int size = skb_shinfo(skb)->frags[i].size;
+		int size = skb_frag_size(&skb_shinfo(skb)->frags[i]);
 
 		if (pos + size > len) {
 			skb_shinfo(skb1)->frags[k] = skb_shinfo(skb)->frags[i];
@@ -2179,8 +2183,8 @@ static inline void skb_split_no_header(struct sk_buff *skb,
 				 */
 				skb_frag_ref(skb, i);
 				skb_shinfo(skb1)->frags[0].page_offset += len - pos;
-				skb_shinfo(skb1)->frags[0].size -= len - pos;
-				skb_shinfo(skb)->frags[i].size	= len - pos;
+				skb_frag_size_sub(&skb_shinfo(skb1)->frags[0], len - pos);
+				skb_frag_size_set(&skb_shinfo(skb)->frags[i], len - pos);
 				skb_shinfo(skb)->nr_frags++;
 			}
 			k++;
@@ -2258,7 +2262,7 @@ int skb_shift(struct sk_buff *tgt, struct sk_buff *skb, int shiftlen)
 	} else {
 		merge = to - 1;
 
-		todo -= fragfrom->size;
+		todo -= skb_frag_size(fragfrom);
 		if (todo < 0) {
 			if (skb_prepare_for_shift(skb) ||
 			    skb_prepare_for_shift(tgt))
@@ -2268,8 +2272,8 @@ int skb_shift(struct sk_buff *tgt, struct sk_buff *skb, int shiftlen)
 			fragfrom = &skb_shinfo(skb)->frags[from];
 			fragto = &skb_shinfo(tgt)->frags[merge];
 
-			fragto->size += shiftlen;
-			fragfrom->size -= shiftlen;
+			skb_frag_size_add(fragto, shiftlen);
+			skb_frag_size_sub(fragfrom, shiftlen);
 			fragfrom->page_offset += shiftlen;
 
 			goto onlymerged;
@@ -2293,9 +2297,9 @@ int skb_shift(struct sk_buff *tgt, struct sk_buff *skb, int shiftlen)
 		fragfrom = &skb_shinfo(skb)->frags[from];
 		fragto = &skb_shinfo(tgt)->frags[to];
 
-		if (todo >= fragfrom->size) {
+		if (todo >= skb_frag_size(fragfrom)) {
 			*fragto = *fragfrom;
-			todo -= fragfrom->size;
+			todo -= skb_frag_size(fragfrom);
 			from++;
 			to++;
 
@@ -2303,10 +2307,10 @@ int skb_shift(struct sk_buff *tgt, struct sk_buff *skb, int shiftlen)
 			__skb_frag_ref(fragfrom);
 			fragto->page = fragfrom->page;
 			fragto->page_offset = fragfrom->page_offset;
-			fragto->size = todo;
+			skb_frag_size_set(fragto, todo);
 
 			fragfrom->page_offset += todo;
-			fragfrom->size -= todo;
+			skb_frag_size_sub(fragfrom, todo);
 			todo = 0;
 
 			to++;
@@ -2321,7 +2325,7 @@ int skb_shift(struct sk_buff *tgt, struct sk_buff *skb, int shiftlen)
 		fragfrom = &skb_shinfo(skb)->frags[0];
 		fragto = &skb_shinfo(tgt)->frags[merge];
 
-		fragto->size += fragfrom->size;
+		skb_frag_size_add(fragto, skb_frag_size(fragfrom));
 		__skb_frag_unref(fragfrom);
 	}
 
@@ -2419,7 +2423,7 @@ next_skb:
 
 	while (st->frag_idx < skb_shinfo(st->cur_skb)->nr_frags) {
 		frag = &skb_shinfo(st->cur_skb)->frags[st->frag_idx];
-		block_limit = frag->size + st->stepped_offset;
+		block_limit = skb_frag_size(frag) + st->stepped_offset;
 
 		if (abs_offset < block_limit) {
 			if (!st->frag_data)
@@ -2437,7 +2441,7 @@ next_skb:
 		}
 
 		st->frag_idx++;
-		st->stepped_offset += frag->size;
+		st->stepped_offset += skb_frag_size(frag);
 	}
 
 	if (st->frag_data) {
@@ -2567,13 +2571,13 @@ int skb_append_datato_frags(struct sock *sk, struct sk_buff *skb,
 		left = PAGE_SIZE - frag->page_offset;
 		copy = (length > left)? left : length;
 
-		ret = getfrag(from, skb_frag_address(frag) + frag->size,
+		ret = getfrag(from, skb_frag_address(frag) + skb_frag_size(frag),
 			    offset, copy, 0, skb);
 		if (ret < 0)
 			return -EFAULT;
 
 		/* copy was successful so update the size parameters */
-		frag->size += copy;
+		skb_frag_size_add(frag, copy);
 		skb->len += copy;
 		skb->data_len += copy;
 		offset += copy;
@@ -2720,11 +2724,11 @@ struct sk_buff *skb_segment(struct sk_buff *skb, u32 features)
 		while (pos < offset + len && i < nfrags) {
 			*frag = skb_shinfo(skb)->frags[i];
 			__skb_frag_ref(frag);
-			size = frag->size;
+			size = skb_frag_size(frag);
 
 			if (pos < offset) {
 				frag->page_offset += offset - pos;
-				frag->size -= offset - pos;
+				skb_frag_size_sub(frag, offset - pos);
 			}
 
 			skb_shinfo(nskb)->nr_frags++;
@@ -2733,7 +2737,7 @@ struct sk_buff *skb_segment(struct sk_buff *skb, u32 features)
 				i++;
 				pos += size;
 			} else {
-				frag->size -= pos + size - (offset + len);
+				skb_frag_size_sub(frag, pos + size - (offset + len));
 				goto skip_fraglist;
 			}
 
@@ -2813,7 +2817,7 @@ int skb_gro_receive(struct sk_buff **head, struct sk_buff *skb)
 		} while (--i);
 
 		frag->page_offset += offset;
-		frag->size -= offset;
+		skb_frag_size_sub(frag, offset);
 
 		skb->truesize -= skb->data_len;
 		skb->len -= skb->data_len;
@@ -2865,7 +2869,7 @@ merge:
 		unsigned int eat = offset - headlen;
 
 		skbinfo->frags[0].page_offset += eat;
-		skbinfo->frags[0].size -= eat;
+		skb_frag_size_sub(&skbinfo->frags[0], eat);
 		skb->data_len -= eat;
 		skb->len -= eat;
 		offset = headlen;
@@ -2936,7 +2940,7 @@ __skb_to_sgvec(struct sk_buff *skb, struct scatterlist *sg, int offset, int len)
 
 		WARN_ON(start > offset + len);
 
-		end = start + skb_shinfo(skb)->frags[i].size;
+		end = start + skb_frag_size(&skb_shinfo(skb)->frags[i]);
 		if ((copy = end - offset) > 0) {
 			skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
 
diff --git a/net/core/user_dma.c b/net/core/user_dma.c
index 34e9664..2d7cf3d 100644
--- a/net/core/user_dma.c
+++ b/net/core/user_dma.c
@@ -71,13 +71,13 @@ int dma_skb_copy_datagram_iovec(struct dma_chan *chan,
 	/* Copy paged appendix. Hmm... why does this look so complicated? */
 	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
 		int end;
+		const skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
 
 		WARN_ON(start > offset + len);
 
-		end = start + skb_shinfo(skb)->frags[i].size;
+		end = start + skb_frag_size(frag);
 		copy = end - offset;
 		if (copy > 0) {
-			skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
 			struct page *page = skb_frag_page(frag);
 
 			if (copy > len)
diff --git a/net/ipv4/inet_lro.c b/net/ipv4/inet_lro.c
index 8e6be5a..cc280a3 100644
--- a/net/ipv4/inet_lro.c
+++ b/net/ipv4/inet_lro.c
@@ -244,11 +244,11 @@ static void lro_add_frags(struct net_lro_desc *lro_desc,
 	skb->truesize += truesize;
 
 	skb_frags[0].page_offset += hlen;
-	skb_frags[0].size -= hlen;
+	skb_frag_size_sub(&skb_frags[0], hlen);
 
 	while (tcp_data_len > 0) {
 		*(lro_desc->next_frag) = *skb_frags;
-		tcp_data_len -= skb_frags->size;
+		tcp_data_len -= skb_frag_size(skb_frags);
 		lro_desc->next_frag++;
 		skb_frags++;
 		skb_shinfo(skb)->nr_frags++;
@@ -400,14 +400,14 @@ static struct sk_buff *lro_gen_skb(struct net_lro_mgr *lro_mgr,
 	skb_frags = skb_shinfo(skb)->frags;
 	while (data_len > 0) {
 		*skb_frags = *frags;
-		data_len -= frags->size;
+		data_len -= skb_frag_size(frags);
 		skb_frags++;
 		frags++;
 		skb_shinfo(skb)->nr_frags++;
 	}
 
 	skb_shinfo(skb)->frags[0].page_offset += hdr_len;
-	skb_shinfo(skb)->frags[0].size -= hdr_len;
+	skb_frag_size_sub(&skb_shinfo(skb)->frags[0], hdr_len);
 
 	skb->ip_summed = ip_summed;
 	skb->csum = sum;
diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index 763589a..fdaabf2 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -599,8 +599,8 @@ static int ip_frag_reasm(struct ipq *qp, struct sk_buff *prev,
 		head->next = clone;
 		skb_shinfo(clone)->frag_list = skb_shinfo(head)->frag_list;
 		skb_frag_list_init(head);
-		for (i=0; i<skb_shinfo(head)->nr_frags; i++)
-			plen += skb_shinfo(head)->frags[i].size;
+		for (i = 0; i < skb_shinfo(head)->nr_frags; i++)
+			plen += skb_frag_size(&skb_shinfo(head)->frags[i]);
 		clone->len = clone->data_len = head->data_len - plen;
 		head->data_len -= clone->len;
 		head->len -= clone->len;
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index ae3bb14..e1374ab 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -1015,13 +1015,13 @@ alloc_new_skb:
 				err = -EMSGSIZE;
 				goto error;
 			}
-			if (getfrag(from, skb_frag_address(frag)+frag->size,
+			if (getfrag(from, skb_frag_address(frag)+skb_frag_size(frag),
 				    offset, copy, skb->len, skb) < 0) {
 				err = -EFAULT;
 				goto error;
 			}
 			cork->off += copy;
-			frag->size += copy;
+			skb_frag_size_add(frag, copy);
 			skb->len += copy;
 			skb->data_len += copy;
 			skb->truesize += copy;
@@ -1230,7 +1230,7 @@ ssize_t	ip_append_page(struct sock *sk, struct flowi4 *fl4, struct page *page,
 		if (len > size)
 			len = size;
 		if (skb_can_coalesce(skb, i, page, offset)) {
-			skb_shinfo(skb)->frags[i-1].size += len;
+			skb_frag_size_add(&skb_shinfo(skb)->frags[i-1], len);
 		} else if (i < MAX_SKB_FRAGS) {
 			get_page(page);
 			skb_fill_page_desc(skb, i, page, offset, len);
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 4c0da24..132be08 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -813,7 +813,7 @@ new_segment:
 			goto wait_for_memory;
 
 		if (can_coalesce) {
-			skb_shinfo(skb)->frags[i - 1].size += copy;
+			skb_frag_size_add(&skb_shinfo(skb)->frags[i - 1], copy);
 		} else {
 			get_page(page);
 			skb_fill_page_desc(skb, i, page, offset, copy);
@@ -1058,8 +1058,7 @@ new_segment:
 
 				/* Update the skb. */
 				if (merge) {
-					skb_shinfo(skb)->frags[i - 1].size +=
-									copy;
+					skb_frag_size_add(&skb_shinfo(skb)->frags[i - 1], copy);
 				} else {
 					skb_fill_page_desc(skb, i, page, off, copy);
 					if (TCP_PAGE(sk)) {
@@ -3031,8 +3030,8 @@ int tcp_md5_hash_skb_data(struct tcp_md5sig_pool *hp,
 	for (i = 0; i < shi->nr_frags; ++i) {
 		const struct skb_frag_struct *f = &shi->frags[i];
 		struct page *page = skb_frag_page(f);
-		sg_set_page(&sg, page, f->size, f->page_offset);
-		if (crypto_hash_update(desc, &sg, f->size))
+		sg_set_page(&sg, page, skb_frag_size(f), f->page_offset);
+		if (crypto_hash_update(desc, &sg, skb_frag_size(f)))
 			return 1;
 	}
 
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index dde6b57..ed96c54 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1094,14 +1094,16 @@ static void __pskb_trim_head(struct sk_buff *skb, int len)
 	eat = len;
 	k = 0;
 	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
-		if (skb_shinfo(skb)->frags[i].size <= eat) {
+		int size = skb_frag_size(&skb_shinfo(skb)->frags[i]);
+
+		if (size <= eat) {
 			skb_frag_unref(skb, i);
-			eat -= skb_shinfo(skb)->frags[i].size;
+			eat -= size;
 		} else {
 			skb_shinfo(skb)->frags[k] = skb_shinfo(skb)->frags[i];
 			if (eat) {
 				skb_shinfo(skb)->frags[k].page_offset += eat;
-				skb_shinfo(skb)->frags[k].size -= eat;
+				skb_frag_size_sub(&skb_shinfo(skb)->frags[k], eat);
 				eat = 0;
 			}
 			k++;
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 1e20b64..1c9bf8b 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -1512,13 +1512,14 @@ alloc_new_skb:
 				err = -EMSGSIZE;
 				goto error;
 			}
-			if (getfrag(from, skb_frag_address(frag)+frag->size,
+			if (getfrag(from,
+				    skb_frag_address(frag) + skb_frag_size(frag),
 				    offset, copy, skb->len, skb) < 0) {
 				err = -EFAULT;
 				goto error;
 			}
 			sk->sk_sndmsg_off += copy;
-			frag->size += copy;
+			skb_frag_size_add(frag, copy);
 			skb->len += copy;
 			skb->data_len += copy;
 			skb->truesize += copy;
diff --git a/net/ipv6/netfilter/nf_conntrack_reasm.c b/net/ipv6/netfilter/nf_conntrack_reasm.c
index 0857272..e8762c7 100644
--- a/net/ipv6/netfilter/nf_conntrack_reasm.c
+++ b/net/ipv6/netfilter/nf_conntrack_reasm.c
@@ -378,8 +378,8 @@ nf_ct_frag6_reasm(struct nf_ct_frag6_queue *fq, struct net_device *dev)
 		head->next = clone;
 		skb_shinfo(clone)->frag_list = skb_shinfo(head)->frag_list;
 		skb_frag_list_init(head);
-		for (i=0; i<skb_shinfo(head)->nr_frags; i++)
-			plen += skb_shinfo(head)->frags[i].size;
+		for (i = 0; i < skb_shinfo(head)->nr_frags; i++)
+			plen += skb_frag_size(&skb_shinfo(head)->frags[i]);
 		clone->len = clone->data_len = head->data_len - plen;
 		head->data_len -= clone->len;
 		head->len -= clone->len;
diff --git a/net/ipv6/reassembly.c b/net/ipv6/reassembly.c
index 7b954e2..cc22099 100644
--- a/net/ipv6/reassembly.c
+++ b/net/ipv6/reassembly.c
@@ -464,8 +464,8 @@ static int ip6_frag_reasm(struct frag_queue *fq, struct sk_buff *prev,
 		head->next = clone;
 		skb_shinfo(clone)->frag_list = skb_shinfo(head)->frag_list;
 		skb_frag_list_init(head);
-		for (i=0; i<skb_shinfo(head)->nr_frags; i++)
-			plen += skb_shinfo(head)->frags[i].size;
+		for (i = 0; i < skb_shinfo(head)->nr_frags; i++)
+			plen += skb_frag_size(&skb_shinfo(head)->frags[i]);
 		clone->len = clone->data_len = head->data_len - plen;
 		head->data_len -= clone->len;
 		head->len -= clone->len;
diff --git a/net/xfrm/xfrm_ipcomp.c b/net/xfrm/xfrm_ipcomp.c
index f781b9a..e5246fb 100644
--- a/net/xfrm/xfrm_ipcomp.c
+++ b/net/xfrm/xfrm_ipcomp.c
@@ -90,7 +90,7 @@ static int ipcomp_decompress(struct xfrm_state *x, struct sk_buff *skb)
 			len = dlen;
 
 		frag->page_offset = 0;
-		frag->size = len;
+		skb_frag_size_set(frag, len);
 		memcpy(skb_frag_address(frag), scratch, len);
 
 		skb->truesize += len;
