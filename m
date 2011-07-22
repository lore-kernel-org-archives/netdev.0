From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH 08/13] net: convert drivers to paged frag API.
Date: Fri, 22 Jul 2011 14:17:28 +0100
Message-ID: <1311340653-19336-8-git-send-email-ian.campbell@citrix.com>
References: <1311340095.12772.57.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ian Campbell <ian.campbell@citrix.com>
To: netdev@vger.kernel.org, linux-nfs@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:5329 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754378Ab1GVNR6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Jul 2011 09:17:58 -0400
In-Reply-To: <1311340095.12772.57.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Coccinelle was quite useful in the initial stages of this conversion bu=
t a) my
spatch was ugly as sin and b) I've done several rounds of updates since=
 then so
they no longer actually represent the resultant changes anyway.

NB: should be split into individual patches to be acked by relevant dri=
ver
maintainers.

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
[since v1:
  Remove skb_frag_pci_map and switch everyone to skb_frag_dma_map (on
  recommendation of Micha=C5=82 Miros=C5=82aw, drivers should be switch=
ing to use the
  DMA API directly instead of the PCI DMA API)
]
---
 drivers/atm/eni.c                       |    4 +-
 drivers/infiniband/hw/amso1100/c2.c     |    8 ++----
 drivers/infiniband/hw/nes/nes_nic.c     |   20 +++++++++---------
 drivers/infiniband/ulp/ipoib/ipoib_cm.c |    6 +++-
 drivers/infiniband/ulp/ipoib/ipoib_ib.c |    6 +++-
 drivers/net/3c59x.c                     |    4 +-
 drivers/net/8139cp.c                    |    3 +-
 drivers/net/acenic.c                    |    6 ++--
 drivers/net/atl1c/atl1c_main.c          |    9 +++----
 drivers/net/atl1e/atl1e_main.c          |   11 ++++-----
 drivers/net/atlx/atl1.c                 |   10 ++++----
 drivers/net/benet/be_main.c             |   10 ++++----
 drivers/net/bna/bnad.c                  |    4 +-
 drivers/net/bnx2.c                      |    8 +++---
 drivers/net/bnx2x/bnx2x_cmn.c           |    3 +-
 drivers/net/cassini.c                   |   15 ++++++-------
 drivers/net/chelsio/sge.c               |    5 +--
 drivers/net/cxgb3/sge.c                 |    6 ++--
 drivers/net/cxgb4/sge.c                 |   14 +++++++-----
 drivers/net/cxgb4vf/sge.c               |   13 ++++++-----
 drivers/net/e1000/e1000_main.c          |    9 +++----
 drivers/net/e1000e/netdev.c             |    7 ++---
 drivers/net/enic/enic_main.c            |   14 ++++++------
 drivers/net/forcedeth.c                 |   12 +++++++---
 drivers/net/gianfar.c                   |   10 ++++----
 drivers/net/greth.c                     |    9 ++-----
 drivers/net/ibmveth.c                   |    5 +--
 drivers/net/igb/igb_main.c              |    5 +---
 drivers/net/igbvf/netdev.c              |    5 +---
 drivers/net/ixgb/ixgb_main.c            |    6 ++--
 drivers/net/ixgbe/ixgbe_main.c          |    9 +++----
 drivers/net/ixgbevf/ixgbevf_main.c      |   10 +++-----
 drivers/net/jme.c                       |    5 ++-
 drivers/net/ksz884x.c                   |    3 +-
 drivers/net/mlx4/en_rx.c                |   22 +++++++++-----------
 drivers/net/mlx4/en_tx.c                |   20 +++--------------
 drivers/net/mv643xx_eth.c               |    8 +++---
 drivers/net/myri10ge/myri10ge.c         |   12 +++++-----
 drivers/net/netxen/netxen_nic_main.c    |    4 +-
 drivers/net/niu.c                       |    4 +-
 drivers/net/ns83820.c                   |    5 +--
 drivers/net/pasemi_mac.c                |    5 +--
 drivers/net/qla3xxx.c                   |    5 +--
 drivers/net/qlcnic/qlcnic_main.c        |    4 +-
 drivers/net/qlge/qlge_main.c            |    8 ++----
 drivers/net/r8169.c                     |    2 +-
 drivers/net/s2io.c                      |    8 +++---
 drivers/net/sfc/rx.c                    |    2 +-
 drivers/net/sfc/tx.c                    |   13 +++--------
 drivers/net/skge.c                      |    4 +-
 drivers/net/sky2.c                      |   13 +++++------
 drivers/net/starfire.c                  |    2 +-
 drivers/net/stmmac/stmmac_main.c        |    5 +--
 drivers/net/sungem.c                    |    6 +---
 drivers/net/sunhme.c                    |    5 +--
 drivers/net/tehuti.c                    |    6 ++--
 drivers/net/tg3.c                       |    6 +---
 drivers/net/tsi108_eth.c                |    7 +++--
 drivers/net/typhoon.c                   |    3 +-
 drivers/net/via-velocity.c              |    7 +++--
 drivers/net/virtio_net.c                |    2 +-
 drivers/net/vmxnet3/vmxnet3_drv.c       |    8 +++---
 drivers/net/vxge/vxge-main.c            |    6 ++--
 drivers/net/xen-netback/netback.c       |   34 +++++++++++++++++++++--=
--------
 drivers/net/xen-netfront.c              |   28 +++++++++++++++--------=
--
 drivers/scsi/bnx2fc/bnx2fc_fcoe.c       |    2 +-
 drivers/scsi/cxgbi/libcxgbi.c           |    6 ++--
 drivers/scsi/fcoe/fcoe.c                |    2 +-
 drivers/scsi/fcoe/fcoe_transport.c      |    5 ++-
 drivers/staging/et131x/et1310_tx.c      |   11 ++++-----
 drivers/staging/hv/netvsc_drv.c         |    2 +-
 71 files changed, 271 insertions(+), 295 deletions(-)

diff --git a/drivers/atm/eni.c b/drivers/atm/eni.c
index 3230ea0..60bc9c5 100644
--- a/drivers/atm/eni.c
+++ b/drivers/atm/eni.c
@@ -1133,8 +1133,8 @@ DPRINTK("doing direct send\n"); /* @@@ well, this=
 doesn't work anyway */
 				    skb->data,
 				    skb_headlen(skb));
 			else
-				put_dma(tx->index,eni_dev->dma,&j,(unsigned long)
-				    skb_shinfo(skb)->frags[i].page + skb_shinfo(skb)->frags[i].pag=
e_offset,
+				put_dma(tx->index,eni_dev->dma,&j,
+				    (unsigned long)skb_frag_address(&skb_shinfo(skb)->frags[i]),
 				    skb_shinfo(skb)->frags[i].size);
 	}
 	if (skb->len & 3)
diff --git a/drivers/infiniband/hw/amso1100/c2.c b/drivers/infiniband/h=
w/amso1100/c2.c
index 0cfc455..f1fff58 100644
--- a/drivers/infiniband/hw/amso1100/c2.c
+++ b/drivers/infiniband/hw/amso1100/c2.c
@@ -801,11 +801,9 @@ static int c2_xmit_frame(struct sk_buff *skb, stru=
ct net_device *netdev)
 		for (i =3D 0; i < skb_shinfo(skb)->nr_frags; i++) {
 			skb_frag_t *frag =3D &skb_shinfo(skb)->frags[i];
 			maplen =3D frag->size;
-			mapaddr =3D
-			    pci_map_page(c2dev->pcidev, frag->page,
-					 frag->page_offset, maplen,
-					 PCI_DMA_TODEVICE);
-
+			mapaddr =3D skb_frag_dma_map(&c2dev->pcidev->dev, frag,
+						   0, maplen,
+						   PCI_DMA_TODEVICE);
 			elem =3D elem->next;
 			elem->skb =3D NULL;
 			elem->mapaddr =3D mapaddr;
diff --git a/drivers/infiniband/hw/nes/nes_nic.c b/drivers/infiniband/h=
w/nes/nes_nic.c
index d3a1c41..b60f10f 100644
--- a/drivers/infiniband/hw/nes/nes_nic.c
+++ b/drivers/infiniband/hw/nes/nes_nic.c
@@ -441,11 +441,11 @@ static int nes_nic_send(struct sk_buff *skb, stru=
ct net_device *netdev)
 		nesnic->tx_skb[nesnic->sq_head] =3D skb;
 		for (skb_fragment_index =3D 0; skb_fragment_index < skb_shinfo(skb)-=
>nr_frags;
 				skb_fragment_index++) {
-			bus_address =3D pci_map_page( nesdev->pcidev,
-					skb_shinfo(skb)->frags[skb_fragment_index].page,
-					skb_shinfo(skb)->frags[skb_fragment_index].page_offset,
-					skb_shinfo(skb)->frags[skb_fragment_index].size,
-					PCI_DMA_TODEVICE);
+			bus_address =3D skb_frag_dma_map(&nesdev->pcidev->dev,
+						       &skb_shinfo(skb)->frags[skb_fragment_index],
+						       0,
+						       skb_shinfo(skb)->frags[skb_fragment_index].size,
+						       PCI_DMA_TODEVICE);
 			wqe_fragment_length[wqe_fragment_index] =3D
 					cpu_to_le16(skb_shinfo(skb)->frags[skb_fragment_index].size);
 			set_wqe_64bit_value(nic_sqe->wqe_words, NES_NIC_SQ_WQE_FRAG0_LOW_ID=
X+(2*wqe_fragment_index),
@@ -561,11 +561,11 @@ tso_sq_no_longer_full:
 			/* Map all the buffers */
 			for (tso_frag_count=3D0; tso_frag_count < skb_shinfo(skb)->nr_frags=
;
 					tso_frag_count++) {
-				tso_bus_address[tso_frag_count] =3D pci_map_page( nesdev->pcidev,
-						skb_shinfo(skb)->frags[tso_frag_count].page,
-						skb_shinfo(skb)->frags[tso_frag_count].page_offset,
-						skb_shinfo(skb)->frags[tso_frag_count].size,
-						PCI_DMA_TODEVICE);
+				tso_bus_address[tso_frag_count] =3D skb_frag_dma_map(&nesdev->pcid=
ev->dev,
+										   &skb_shinfo(skb)->frags[tso_frag_count],
+										   0,
+										   skb_shinfo(skb)->frags[tso_frag_count].size,
+										   PCI_DMA_TODEVICE);
 			}
=20
 			tso_frag_index =3D 0;
diff --git a/drivers/infiniband/ulp/ipoib/ipoib_cm.c b/drivers/infiniba=
nd/ulp/ipoib/ipoib_cm.c
index 39913a0..1f20e40 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_cm.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_cm.c
@@ -169,7 +169,8 @@ static struct sk_buff *ipoib_cm_alloc_rx_skb(struct=
 net_device *dev,
 			goto partial_error;
 		skb_fill_page_desc(skb, i, page, 0, PAGE_SIZE);
=20
-		mapping[i + 1] =3D ib_dma_map_page(priv->ca, skb_shinfo(skb)->frags[=
i].page,
+		mapping[i + 1] =3D ib_dma_map_page(priv->ca,
+						 __skb_frag_page(&skb_shinfo(skb)->frags[i]),
 						 0, PAGE_SIZE, DMA_FROM_DEVICE);
 		if (unlikely(ib_dma_mapping_error(priv->ca, mapping[i + 1])))
 			goto partial_error;
@@ -537,7 +538,8 @@ static void skb_put_frags(struct sk_buff *skb, unsi=
gned int hdr_space,
=20
 		if (length =3D=3D 0) {
 			/* don't need this page */
-			skb_fill_page_desc(toskb, i, frag->page, 0, PAGE_SIZE);
+			skb_fill_page_desc(toskb, i, __skb_frag_page(frag),
+					   0, PAGE_SIZE);/* XXX */
 			--skb_shinfo(skb)->nr_frags;
 		} else {
 			size =3D min(length, (unsigned) PAGE_SIZE);
diff --git a/drivers/infiniband/ulp/ipoib/ipoib_ib.c b/drivers/infiniba=
nd/ulp/ipoib/ipoib_ib.c
index 81ae61d..f6ef6c2 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_ib.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_ib.c
@@ -182,7 +182,8 @@ static struct sk_buff *ipoib_alloc_rx_skb(struct ne=
t_device *dev, int id)
 			goto partial_error;
 		skb_fill_page_desc(skb, 0, page, 0, PAGE_SIZE);
 		mapping[1] =3D
-			ib_dma_map_page(priv->ca, skb_shinfo(skb)->frags[0].page,
+			ib_dma_map_page(priv->ca,
+					__skb_frag_page(&skb_shinfo(skb)->frags[0]),
 					0, PAGE_SIZE, DMA_FROM_DEVICE);
 		if (unlikely(ib_dma_mapping_error(priv->ca, mapping[1])))
 			goto partial_error;
@@ -323,7 +324,8 @@ static int ipoib_dma_map_tx(struct ib_device *ca,
=20
 	for (i =3D 0; i < skb_shinfo(skb)->nr_frags; ++i) {
 		skb_frag_t *frag =3D &skb_shinfo(skb)->frags[i];
-		mapping[i + off] =3D ib_dma_map_page(ca, frag->page,
+		mapping[i + off] =3D ib_dma_map_page(ca,
+						 __skb_frag_page(frag),
 						 frag->page_offset, frag->size,
 						 DMA_TO_DEVICE);
 		if (unlikely(ib_dma_mapping_error(ca, mapping[i + off])))
diff --git a/drivers/net/3c59x.c b/drivers/net/3c59x.c
index 8cc2256..fcd3820 100644
--- a/drivers/net/3c59x.c
+++ b/drivers/net/3c59x.c
@@ -2180,8 +2180,8 @@ boomerang_start_xmit(struct sk_buff *skb, struct =
net_device *dev)
=20
 			vp->tx_ring[entry].frag[i+1].addr =3D
 					cpu_to_le32(pci_map_single(VORTEX_PCI(vp),
-											   (void*)page_address(frag->page) + frag->page_offset,
-											   frag->size, PCI_DMA_TODEVICE));
+								   (void*)skb_frag_address(frag),
+								   frag->size, PCI_DMA_TODEVICE));
=20
 			if (i =3D=3D skb_shinfo(skb)->nr_frags-1)
 					vp->tx_ring[entry].frag[i+1].length =3D cpu_to_le32(frag->size|LA=
ST_FRAG);
diff --git a/drivers/net/8139cp.c b/drivers/net/8139cp.c
index 10c4505..c418aa3 100644
--- a/drivers/net/8139cp.c
+++ b/drivers/net/8139cp.c
@@ -815,8 +815,7 @@ static netdev_tx_t cp_start_xmit (struct sk_buff *s=
kb,
=20
 			len =3D this_frag->size;
 			mapping =3D dma_map_single(&cp->pdev->dev,
-						 ((void *) page_address(this_frag->page) +
-						  this_frag->page_offset),
+						 skb_frag_address(this_frag),
 						 len, PCI_DMA_TODEVICE);
 			eor =3D (entry =3D=3D (CP_TX_RING_SIZE - 1)) ? RingEnd : 0;
=20
diff --git a/drivers/net/acenic.c b/drivers/net/acenic.c
index d7c1bfe4..cc73b49 100644
--- a/drivers/net/acenic.c
+++ b/drivers/net/acenic.c
@@ -2528,9 +2528,9 @@ restart:
 			info =3D ap->skb->tx_skbuff + idx;
 			desc =3D ap->tx_ring + idx;
=20
-			mapping =3D pci_map_page(ap->pdev, frag->page,
-					       frag->page_offset, frag->size,
-					       PCI_DMA_TODEVICE);
+			mapping =3D skb_frag_dma_map(&ap->pdev->dev, frag, 0,
+						   frag->size,
+						   PCI_DMA_TODEVICE);
=20
 			flagsize =3D (frag->size << 16);
 			if (skb->ip_summed =3D=3D CHECKSUM_PARTIAL)
diff --git a/drivers/net/atl1c/atl1c_main.c b/drivers/net/atl1c/atl1c_m=
ain.c
index 1269ba5..ce6dbc5 100644
--- a/drivers/net/atl1c/atl1c_main.c
+++ b/drivers/net/atl1c/atl1c_main.c
@@ -2161,11 +2161,10 @@ static void atl1c_tx_map(struct atl1c_adapter *=
adapter,
=20
 		buffer_info =3D atl1c_get_tx_buffer(adapter, use_tpd);
 		buffer_info->length =3D frag->size;
-		buffer_info->dma =3D
-			pci_map_page(adapter->pdev, frag->page,
-					frag->page_offset,
-					buffer_info->length,
-					PCI_DMA_TODEVICE);
+		buffer_info->dma =3D skb_frag_dma_map(&adapter->pdev->dev,
+						    frag, 0,
+						    buffer_info->length,
+						    PCI_DMA_TODEVICE);
 		ATL1C_SET_BUFFER_STATE(buffer_info, ATL1C_BUFFER_BUSY);
 		ATL1C_SET_PCIMAP_TYPE(buffer_info, ATL1C_PCIMAP_PAGE,
 			ATL1C_PCIMAP_TODEVICE);
diff --git a/drivers/net/atl1e/atl1e_main.c b/drivers/net/atl1e/atl1e_m=
ain.c
index 86a9122..b292c2a 100644
--- a/drivers/net/atl1e/atl1e_main.c
+++ b/drivers/net/atl1e/atl1e_main.c
@@ -1745,12 +1745,11 @@ static void atl1e_tx_map(struct atl1e_adapter *=
adapter,
 				MAX_TX_BUF_LEN : buf_len;
 			buf_len -=3D tx_buffer->length;
=20
-			tx_buffer->dma =3D
-				pci_map_page(adapter->pdev, frag->page,
-						frag->page_offset +
-						(i * MAX_TX_BUF_LEN),
-						tx_buffer->length,
-						PCI_DMA_TODEVICE);
+			tx_buffer->dma =3D skb_frag_dma_map(&adapter->pdev->dev,
+							  frag,
+							  (i * MAX_TX_BUF_LEN),
+							  tx_buffer->length,
+							  PCI_DMA_TODEVICE);
 			ATL1E_SET_PCIMAP_TYPE(tx_buffer, ATL1E_TX_PCIMAP_PAGE);
 			use_tpd->buffer_addr =3D cpu_to_le64(tx_buffer->dma);
 			use_tpd->word2 =3D (use_tpd->word2 & (~TPD_BUFLEN_MASK)) |
diff --git a/drivers/net/atlx/atl1.c b/drivers/net/atlx/atl1.c
index cd5789f..d76229c 100644
--- a/drivers/net/atlx/atl1.c
+++ b/drivers/net/atlx/atl1.c
@@ -2283,11 +2283,11 @@ static void atl1_tx_map(struct atl1_adapter *ad=
apter, struct sk_buff *skb,
 			buffer_info->length =3D (buf_len > ATL1_MAX_TX_BUF_LEN) ?
 				ATL1_MAX_TX_BUF_LEN : buf_len;
 			buf_len -=3D buffer_info->length;
-			buffer_info->dma =3D pci_map_page(adapter->pdev,
-				frag->page,
-				frag->page_offset + (i * ATL1_MAX_TX_BUF_LEN),
-				buffer_info->length, PCI_DMA_TODEVICE);
-
+			buffer_info->dma =3D skb_frag_dma_map(&adapter->pdev->dev,
+							    frag,
+							    (i * ATL1_MAX_TX_BUF_LEN),
+							    buffer_info->length,
+							    PCI_DMA_TODEVICE);
 			if (++next_to_use =3D=3D tpd_ring->count)
 				next_to_use =3D 0;
 		}
diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index a485f7f..3e4f643 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -715,8 +715,8 @@ static int make_tx_wrbs(struct be_adapter *adapter,
 	for (i =3D 0; i < skb_shinfo(skb)->nr_frags; i++) {
 		struct skb_frag_struct *frag =3D
 			&skb_shinfo(skb)->frags[i];
-		busaddr =3D dma_map_page(dev, frag->page, frag->page_offset,
-				       frag->size, DMA_TO_DEVICE);
+		busaddr =3D skb_frag_dma_map(dev, frag, 0,
+					   frag->size, DMA_TO_DEVICE);
 		if (dma_mapping_error(dev, busaddr))
 			goto dma_err;
 		wrb =3D queue_head_node(txq);
@@ -1122,7 +1122,7 @@ static void skb_fill_rx_data(struct be_adapter *a=
dapter, struct be_rx_obj *rxo,
 		skb->tail +=3D curr_frag_len;
 	} else {
 		skb_shinfo(skb)->nr_frags =3D 1;
-		skb_shinfo(skb)->frags[0].page =3D page_info->page;
+		skb_frag_set_page(skb, 0, page_info->page);
 		skb_shinfo(skb)->frags[0].page_offset =3D
 					page_info->page_offset + hdr_len;
 		skb_shinfo(skb)->frags[0].size =3D curr_frag_len - hdr_len;
@@ -1147,7 +1147,7 @@ static void skb_fill_rx_data(struct be_adapter *a=
dapter, struct be_rx_obj *rxo,
 		if (page_info->page_offset =3D=3D 0) {
 			/* Fresh page */
 			j++;
-			skb_shinfo(skb)->frags[j].page =3D page_info->page;
+			skb_frag_set_page(skb, j, page_info->page);
 			skb_shinfo(skb)->frags[j].page_offset =3D
 							page_info->page_offset;
 			skb_shinfo(skb)->frags[j].size =3D 0;
@@ -1236,7 +1236,7 @@ static void be_rx_compl_process_gro(struct be_ada=
pter *adapter,
 		if (i =3D=3D 0 || page_info->page_offset =3D=3D 0) {
 			/* First frag or Fresh page */
 			j++;
-			skb_shinfo(skb)->frags[j].page =3D page_info->page;
+			skb_frag_set_page(skb, j, page_info->page);
 			skb_shinfo(skb)->frags[j].page_offset =3D
 							page_info->page_offset;
 			skb_shinfo(skb)->frags[j].size =3D 0;
diff --git a/drivers/net/bna/bnad.c b/drivers/net/bna/bnad.c
index 44e219c..31b0f16 100644
--- a/drivers/net/bna/bnad.c
+++ b/drivers/net/bna/bnad.c
@@ -2635,8 +2635,8 @@ bnad_start_xmit(struct sk_buff *skb, struct net_d=
evice *netdev)
=20
 		BUG_ON(!(size <=3D BFI_TX_MAX_DATA_PER_VECTOR));
 		txqent->vector[vect_id].length =3D htons(size);
-		dma_addr =3D dma_map_page(&bnad->pcidev->dev, frag->page,
-					frag->page_offset, size, DMA_TO_DEVICE);
+		dma_addr =3D skb_frag_dma_map(&bnad->pcidev->dev, frag,
+					    0, size, DMA_TO_DEVICE);
 		dma_unmap_addr_set(&unmap_q->unmap_array[unmap_prod], dma_addr,
 				   dma_addr);
 		BNA_SET_DMA_ADDR(dma_addr, &txqent->vector[vect_id].host_addr);
diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 57d3293..ff90b13 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -2880,8 +2880,8 @@ bnx2_reuse_rx_skb_pages(struct bnx2 *bp, struct b=
nx2_rx_ring_info *rxr,
=20
 		shinfo =3D skb_shinfo(skb);
 		shinfo->nr_frags--;
-		page =3D shinfo->frags[shinfo->nr_frags].page;
-		shinfo->frags[shinfo->nr_frags].page =3D NULL;
+		page =3D __skb_frag_page(&shinfo->frags[shinfo->nr_frags]);
+		__skb_frag_set_page(&shinfo->frags[shinfo->nr_frags], NULL);
=20
 		cons_rx_pg->page =3D page;
 		dev_kfree_skb(skb);
@@ -6461,8 +6461,8 @@ bnx2_start_xmit(struct sk_buff *skb, struct net_d=
evice *dev)
 		txbd =3D &txr->tx_desc_ring[ring_prod];
=20
 		len =3D frag->size;
-		mapping =3D dma_map_page(&bp->pdev->dev, frag->page, frag->page_offs=
et,
-				       len, PCI_DMA_TODEVICE);
+		mapping =3D skb_frag_dma_map(&bp->pdev->dev, frag, 0, len,
+					   PCI_DMA_TODEVICE);
 		if (dma_mapping_error(&bp->pdev->dev, mapping))
 			goto dma_error;
 		dma_unmap_addr_set(&txr->tx_buf_ring[ring_prod], mapping,
diff --git a/drivers/net/bnx2x/bnx2x_cmn.c b/drivers/net/bnx2x/bnx2x_cm=
n.c
index 28904433..dee09d7 100644
--- a/drivers/net/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/bnx2x/bnx2x_cmn.c
@@ -2406,8 +2406,7 @@ netdev_tx_t bnx2x_start_xmit(struct sk_buff *skb,=
 struct net_device *dev)
 		if (total_pkt_bd =3D=3D NULL)
 			total_pkt_bd =3D &fp->tx_desc_ring[bd_prod].reg_bd;
=20
-		mapping =3D dma_map_page(&bp->pdev->dev, frag->page,
-				       frag->page_offset,
+		mapping =3D skb_frag_dma_map(&bp->pdev->dev, frag, 0,
 				       frag->size, DMA_TO_DEVICE);
=20
 		tx_data_bd->addr_hi =3D cpu_to_le32(U64_HI(mapping));
diff --git a/drivers/net/cassini.c b/drivers/net/cassini.c
index 22ce03e..903d88d 100644
--- a/drivers/net/cassini.c
+++ b/drivers/net/cassini.c
@@ -2047,8 +2047,8 @@ static int cas_rx_process_pkt(struct cas *cp, str=
uct cas_rx_comp *rxc,
 		skb->truesize +=3D hlen - swivel;
 		skb->len      +=3D hlen - swivel;
=20
-		get_page(page->buffer);
-		frag->page =3D page->buffer;
+		__skb_frag_set_page(frag, page->buffer);
+		__skb_frag_ref(frag);
 		frag->page_offset =3D off;
 		frag->size =3D hlen - swivel;
=20
@@ -2071,8 +2071,8 @@ static int cas_rx_process_pkt(struct cas *cp, str=
uct cas_rx_comp *rxc,
 			skb->len      +=3D hlen;
 			frag++;
=20
-			get_page(page->buffer);
-			frag->page =3D page->buffer;
+			__skb_frag_set_page(frag, page->buffer);
+			__skb_frag_ref(frag);
 			frag->page_offset =3D 0;
 			frag->size =3D hlen;
 			RX_USED_ADD(page, hlen + cp->crc_size);
@@ -2829,9 +2829,8 @@ static inline int cas_xmit_tx_ringN(struct cas *c=
p, int ring,
 		skb_frag_t *fragp =3D &skb_shinfo(skb)->frags[frag];
=20
 		len =3D fragp->size;
-		mapping =3D pci_map_page(cp->pdev, fragp->page,
-				       fragp->page_offset, len,
-				       PCI_DMA_TODEVICE);
+		mapping =3D skb_frag_dma_map(&cp->pdev->dev, fragp, 0, len,
+					   PCI_DMA_TODEVICE);
=20
 		tabort =3D cas_calc_tabort(cp, fragp->page_offset, len);
 		if (unlikely(tabort)) {
@@ -2842,7 +2841,7 @@ static inline int cas_xmit_tx_ringN(struct cas *c=
p, int ring,
 				      ctrl, 0);
 			entry =3D TX_DESC_NEXT(ring, entry);
=20
-			addr =3D cas_page_map(fragp->page);
+			addr =3D cas_page_map(__skb_frag_page(fragp));
 			memcpy(tx_tiny_buf(cp, ring, entry),
 			       addr + fragp->page_offset + len - tabort,
 			       tabort);
diff --git a/drivers/net/chelsio/sge.c b/drivers/net/chelsio/sge.c
index 58380d2..39c06d9 100644
--- a/drivers/net/chelsio/sge.c
+++ b/drivers/net/chelsio/sge.c
@@ -1276,9 +1276,8 @@ static inline void write_tx_descs(struct adapter =
*adapter, struct sk_buff *skb,
 			ce =3D q->centries;
 		}
=20
-		mapping =3D pci_map_page(adapter->pdev, frag->page,
-				       frag->page_offset, frag->size,
-				       PCI_DMA_TODEVICE);
+		mapping =3D skb_frag_dma_map(&adapter->pdev->dev, frag, 0,
+					   frag->size, PCI_DMA_TODEVICE);
 		desc_mapping =3D mapping;
 		desc_len =3D frag->size;
=20
diff --git a/drivers/net/cxgb3/sge.c b/drivers/net/cxgb3/sge.c
index 76bf589..3f73a5c 100644
--- a/drivers/net/cxgb3/sge.c
+++ b/drivers/net/cxgb3/sge.c
@@ -979,8 +979,8 @@ static inline unsigned int make_sgl(const struct sk=
_buff *skb,
 	for (i =3D 0; i < nfrags; i++) {
 		skb_frag_t *frag =3D &skb_shinfo(skb)->frags[i];
=20
-		mapping =3D pci_map_page(pdev, frag->page, frag->page_offset,
-				       frag->size, PCI_DMA_TODEVICE);
+		mapping =3D skb_frag_dma_map(&pdev->dev, frag, 0, frag->size,
+					   PCI_DMA_TODEVICE);
 		sgp->len[j] =3D cpu_to_be32(frag->size);
 		sgp->addr[j] =3D cpu_to_be64(mapping);
 		j ^=3D 1;
@@ -2133,7 +2133,7 @@ static void lro_add_page(struct adapter *adap, st=
ruct sge_qset *qs,
 	len -=3D offset;
=20
 	rx_frag +=3D nr_frags;
-	rx_frag->page =3D sd->pg_chunk.page;
+	__skb_frag_set_page(rx_frag, sd->pg_chunk.page);
 	rx_frag->page_offset =3D sd->pg_chunk.offset + offset;
 	rx_frag->size =3D len;
=20
diff --git a/drivers/net/cxgb4/sge.c b/drivers/net/cxgb4/sge.c
index 56adf44..f1813b5 100644
--- a/drivers/net/cxgb4/sge.c
+++ b/drivers/net/cxgb4/sge.c
@@ -215,8 +215,8 @@ static int map_skb(struct device *dev, const struct=
 sk_buff *skb,
 	end =3D &si->frags[si->nr_frags];
=20
 	for (fp =3D si->frags; fp < end; fp++) {
-		*++addr =3D dma_map_page(dev, fp->page, fp->page_offset, fp->size,
-				       DMA_TO_DEVICE);
+		*++addr =3D skb_frag_dma_map(dev, fp, 0, fp->size,
+					   DMA_TO_DEVICE);
 		if (dma_mapping_error(dev, *addr))
 			goto unwind;
 	}
@@ -1409,13 +1409,14 @@ int cxgb4_ofld_send(struct net_device *dev, str=
uct sk_buff *skb)
 }
 EXPORT_SYMBOL(cxgb4_ofld_send);
=20
-static inline void copy_frags(struct skb_shared_info *ssi,
+static inline void copy_frags(struct sk_buff *skb,
 			      const struct pkt_gl *gl, unsigned int offset)
 {
+	struct skb_shared_info *ssi =3D skb_shinfo(skb);
 	unsigned int n;
=20
 	/* usually there's just one frag */
-	ssi->frags[0].page =3D gl->frags[0].page;
+	skb_frag_set_page(skb, 0, gl->frags[0].page);
 	ssi->frags[0].page_offset =3D gl->frags[0].page_offset + offset;
 	ssi->frags[0].size =3D gl->frags[0].size - offset;
 	ssi->nr_frags =3D gl->nfrags;
@@ -1459,7 +1460,7 @@ struct sk_buff *cxgb4_pktgl_to_skb(const struct p=
kt_gl *gl,
 		__skb_put(skb, pull_len);
 		skb_copy_to_linear_data(skb, gl->va, pull_len);
=20
-		copy_frags(skb_shinfo(skb), gl, pull_len);
+		copy_frags(skb, gl, pull_len);
 		skb->len =3D gl->tot_len;
 		skb->data_len =3D skb->len - pull_len;
 		skb->truesize +=3D skb->data_len;
@@ -1522,7 +1523,7 @@ static void do_gro(struct sge_eth_rxq *rxq, const=
 struct pkt_gl *gl,
 		return;
 	}
=20
-	copy_frags(skb_shinfo(skb), gl, RX_PKT_PAD);
+	copy_frags(skb, gl, RX_PKT_PAD);
 	skb->len =3D gl->tot_len - RX_PKT_PAD;
 	skb->data_len =3D skb->len;
 	skb->truesize +=3D skb->data_len;
@@ -1735,6 +1736,7 @@ static int process_responses(struct sge_rspq *q, =
int budget)
=20
 			si.va =3D page_address(si.frags[0].page) +
 				si.frags[0].page_offset;
+
 			prefetch(si.va);
=20
 			si.nfrags =3D frags + 1;
diff --git a/drivers/net/cxgb4vf/sge.c b/drivers/net/cxgb4vf/sge.c
index 5fd75fd..f4c4480 100644
--- a/drivers/net/cxgb4vf/sge.c
+++ b/drivers/net/cxgb4vf/sge.c
@@ -296,8 +296,8 @@ static int map_skb(struct device *dev, const struct=
 sk_buff *skb,
 	si =3D skb_shinfo(skb);
 	end =3D &si->frags[si->nr_frags];
 	for (fp =3D si->frags; fp < end; fp++) {
-		*++addr =3D dma_map_page(dev, fp->page, fp->page_offset, fp->size,
-				       DMA_TO_DEVICE);
+		*++addr =3D skb_frag_dma_map(dev, fp, 0, fp->size,
+					   DMA_TO_DEVICE);
 		if (dma_mapping_error(dev, *addr))
 			goto unwind;
 	}
@@ -1397,7 +1397,7 @@ struct sk_buff *t4vf_pktgl_to_skb(const struct pk=
t_gl *gl,
 		skb_copy_to_linear_data(skb, gl->va, pull_len);
=20
 		ssi =3D skb_shinfo(skb);
-		ssi->frags[0].page =3D gl->frags[0].page;
+		skb_frag_set_page(skb, 0, gl->frags[0].page);
 		ssi->frags[0].page_offset =3D gl->frags[0].page_offset + pull_len;
 		ssi->frags[0].size =3D gl->frags[0].size - pull_len;
 		if (gl->nfrags > 1)
@@ -1442,14 +1442,15 @@ void t4vf_pktgl_free(const struct pkt_gl *gl)
  *	Copy an internal packet gather list into a Linux skb_shared_info
  *	structure.
  */
-static inline void copy_frags(struct skb_shared_info *si,
+static inline void copy_frags(struct sk_buff *skb,
 			      const struct pkt_gl *gl,
 			      unsigned int offset)
 {
+	struct skb_shared_info *si =3D skb_shinfo(skb);
 	unsigned int n;
=20
 	/* usually there's just one frag */
-	si->frags[0].page =3D gl->frags[0].page;
+	skb_frag_set_page(skb, 0, gl->frags[0].page);
 	si->frags[0].page_offset =3D gl->frags[0].page_offset + offset;
 	si->frags[0].size =3D gl->frags[0].size - offset;
 	si->nr_frags =3D gl->nfrags;
@@ -1484,7 +1485,7 @@ static void do_gro(struct sge_eth_rxq *rxq, const=
 struct pkt_gl *gl,
 		return;
 	}
=20
-	copy_frags(skb_shinfo(skb), gl, PKTSHIFT);
+	copy_frags(skb, gl, PKTSHIFT);
 	skb->len =3D gl->tot_len - PKTSHIFT;
 	skb->data_len =3D skb->len;
 	skb->truesize +=3D skb->data_len;
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_m=
ain.c
index 76e8af0..e902cd0 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -2861,7 +2861,7 @@ static int e1000_tx_map(struct e1000_adapter *ada=
pter,
=20
 		frag =3D &skb_shinfo(skb)->frags[f];
 		len =3D frag->size;
-		offset =3D frag->page_offset;
+		offset =3D 0;
=20
 		while (len) {
 			i++;
@@ -2878,7 +2878,7 @@ static int e1000_tx_map(struct e1000_adapter *ada=
pter,
 			 * Avoid terminating buffers within evenly-aligned
 			 * dwords. */
 			if (unlikely(adapter->pcix_82544 &&
-			    !((unsigned long)(page_to_phys(frag->page) + offset
+			    !((unsigned long)(page_to_phys(__skb_frag_page(frag)) + offset
 			                      + size - 1) & 4) &&
 			    size > 4))
 				size -=3D 4;
@@ -2886,9 +2886,8 @@ static int e1000_tx_map(struct e1000_adapter *ada=
pter,
 			buffer_info->length =3D size;
 			buffer_info->time_stamp =3D jiffies;
 			buffer_info->mapped_as_page =3D true;
-			buffer_info->dma =3D dma_map_page(&pdev->dev, frag->page,
-							offset,	size,
-							DMA_TO_DEVICE);
+			buffer_info->dma =3D skb_frag_dma_map(&pdev->dev, frag,
+						offset, size, DMA_TO_DEVICE);
 			if (dma_mapping_error(&pdev->dev, buffer_info->dma))
 				goto dma_error;
 			buffer_info->next_to_watch =3D i;
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 3310c3d..30f8a5c 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -4599,7 +4599,7 @@ static int e1000_tx_map(struct e1000_adapter *ada=
pter,
=20
 		frag =3D &skb_shinfo(skb)->frags[f];
 		len =3D frag->size;
-		offset =3D frag->page_offset;
+		offset =3D 0;
=20
 		while (len) {
 			i++;
@@ -4612,9 +4612,8 @@ static int e1000_tx_map(struct e1000_adapter *ada=
pter,
 			buffer_info->length =3D size;
 			buffer_info->time_stamp =3D jiffies;
 			buffer_info->next_to_watch =3D i;
-			buffer_info->dma =3D dma_map_page(&pdev->dev, frag->page,
-							offset, size,
-							DMA_TO_DEVICE);
+			buffer_info->dma =3D skb_frag_dma_map(&pdev->dev, frag,
+						offset, size, DMA_TO_DEVICE);
 			buffer_info->mapped_as_page =3D true;
 			if (dma_mapping_error(&pdev->dev, buffer_info->dma))
 				goto dma_error;
diff --git a/drivers/net/enic/enic_main.c b/drivers/net/enic/enic_main.=
c
index 2f433fb..31bf8cb 100644
--- a/drivers/net/enic/enic_main.c
+++ b/drivers/net/enic/enic_main.c
@@ -584,9 +584,9 @@ static inline void enic_queue_wq_skb_cont(struct en=
ic *enic,
 	for (frag =3D skb_shinfo(skb)->frags; len_left; frag++) {
 		len_left -=3D frag->size;
 		enic_queue_wq_desc_cont(wq, skb,
-			pci_map_page(enic->pdev, frag->page,
-				frag->page_offset, frag->size,
-				PCI_DMA_TODEVICE),
+			skb_frag_dma_map(&enic->pdev->dev,
+					 frag, 0, frag->size,
+					 PCI_DMA_TODEVICE),
 			frag->size,
 			(len_left =3D=3D 0),	/* EOP? */
 			loopback);
@@ -698,14 +698,14 @@ static inline void enic_queue_wq_skb_tso(struct e=
nic *enic,
 	for (frag =3D skb_shinfo(skb)->frags; len_left; frag++) {
 		len_left -=3D frag->size;
 		frag_len_left =3D frag->size;
-		offset =3D frag->page_offset;
+		offset =3D 0;
=20
 		while (frag_len_left) {
 			len =3D min(frag_len_left,
 				(unsigned int)WQ_ENET_MAX_DESC_LEN);
-			dma_addr =3D pci_map_page(enic->pdev, frag->page,
-				offset, len,
-				PCI_DMA_TODEVICE);
+			dma_addr =3D skb_frag_dma_map(&enic->pdev->dev, frag,
+						    offset, len,
+						    PCI_DMA_TODEVICE);
 			enic_queue_wq_desc_cont(wq, skb,
 				dma_addr,
 				len,
diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index 537b695..df0cb1c 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -2149,8 +2149,10 @@ static netdev_tx_t nv_start_xmit(struct sk_buff =
*skb, struct net_device *dev)
 			prev_tx =3D put_tx;
 			prev_tx_ctx =3D np->put_tx_ctx;
 			bcnt =3D (size > NV_TX2_TSO_MAX_SIZE) ? NV_TX2_TSO_MAX_SIZE : size;
-			np->put_tx_ctx->dma =3D pci_map_page(np->pci_dev, frag->page, frag-=
>page_offset+offset, bcnt,
-							   PCI_DMA_TODEVICE);
+			np->put_tx_ctx->dma =3D skb_frag_dma_map(&np->pci_dev->dev,
+							       frag, offset,
+							       bcnt,
+							       PCI_DMA_TODEVICE);
 			np->put_tx_ctx->dma_len =3D bcnt;
 			np->put_tx_ctx->dma_single =3D 0;
 			put_tx->buf =3D cpu_to_le32(np->put_tx_ctx->dma);
@@ -2260,8 +2262,10 @@ static netdev_tx_t nv_start_xmit_optimized(struc=
t sk_buff *skb,
 			prev_tx =3D put_tx;
 			prev_tx_ctx =3D np->put_tx_ctx;
 			bcnt =3D (size > NV_TX2_TSO_MAX_SIZE) ? NV_TX2_TSO_MAX_SIZE : size;
-			np->put_tx_ctx->dma =3D pci_map_page(np->pci_dev, frag->page, frag-=
>page_offset+offset, bcnt,
-							   PCI_DMA_TODEVICE);
+			np->put_tx_ctx->dma =3D skb_frag_dma_map(&np->pci_dev->dev,
+							       frag, offset,
+							       bcnt,
+							       PCI_DMA_TODEVICE);
 			np->put_tx_ctx->dma_len =3D bcnt;
 			np->put_tx_ctx->dma_single =3D 0;
 			put_tx->bufhigh =3D cpu_to_le32(dma_high(np->put_tx_ctx->dma));
diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 2dfcc80..766e037 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -2141,11 +2141,11 @@ static int gfar_start_xmit(struct sk_buff *skb,=
 struct net_device *dev)
 			if (i =3D=3D nr_frags - 1)
 				lstatus |=3D BD_LFLAG(TXBD_LAST | TXBD_INTERRUPT);
=20
-			bufaddr =3D dma_map_page(&priv->ofdev->dev,
-					skb_shinfo(skb)->frags[i].page,
-					skb_shinfo(skb)->frags[i].page_offset,
-					length,
-					DMA_TO_DEVICE);
+			bufaddr =3D skb_frag_dma_map(&priv->ofdev->dev,
+						   &skb_shinfo(skb)->frags[i],
+						   0,
+						   length,
+						   DMA_TO_DEVICE);
=20
 			/* set the TxBD length and buffer pointer */
 			txbdp->bufPtr =3D bufaddr;
diff --git a/drivers/net/greth.c b/drivers/net/greth.c
index 672f096..26acb8d 100644
--- a/drivers/net/greth.c
+++ b/drivers/net/greth.c
@@ -111,7 +111,7 @@ static void greth_print_tx_packet(struct sk_buff *s=
kb)
 	for (i =3D 0; i < skb_shinfo(skb)->nr_frags; i++) {
=20
 		print_hex_dump(KERN_DEBUG, "TX: ", DUMP_PREFIX_OFFSET, 16, 1,
-			       phys_to_virt(page_to_phys(skb_shinfo(skb)->frags[i].page)) +
+			       phys_to_virt(page_to_phys(skb_frag_page(&skb_shinfo(skb)->fr=
ags[i]))) +
 			       skb_shinfo(skb)->frags[i].page_offset,
 			       length, true);
 	}
@@ -526,11 +526,8 @@ greth_start_xmit_gbit(struct sk_buff *skb, struct =
net_device *dev)
=20
 		greth_write_bd(&bdp->stat, status);
=20
-		dma_addr =3D dma_map_page(greth->dev,
-					frag->page,
-					frag->page_offset,
-					frag->size,
-					DMA_TO_DEVICE);
+		dma_addr =3D skb_frag_dma_map(greth->dev, frag, 0, frag->size,
+					    DMA_TO_DEVICE);
=20
 		if (unlikely(dma_mapping_error(greth->dev, dma_addr)))
 			goto frag_map_error;
diff --git a/drivers/net/ibmveth.c b/drivers/net/ibmveth.c
index b388d78..65e5874 100644
--- a/drivers/net/ibmveth.c
+++ b/drivers/net/ibmveth.c
@@ -1001,9 +1001,8 @@ retry_bounce:
 		unsigned long dma_addr;
 		skb_frag_t *frag =3D &skb_shinfo(skb)->frags[i];
=20
-		dma_addr =3D dma_map_page(&adapter->vdev->dev, frag->page,
-					frag->page_offset, frag->size,
-					DMA_TO_DEVICE);
+		dma_addr =3D skb_frag_dma_map(&adapter->vdev->dev, frag, 0,
+					    frag->size, DMA_TO_DEVICE);
=20
 		if (dma_mapping_error(&adapter->vdev->dev, dma_addr))
 			goto map_failed_frags;
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 2c28621..17f94f4 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -4132,10 +4132,7 @@ static inline int igb_tx_map_adv(struct igb_ring=
 *tx_ring, struct sk_buff *skb,
 		buffer_info->time_stamp =3D jiffies;
 		buffer_info->next_to_watch =3D i;
 		buffer_info->mapped_as_page =3D true;
-		buffer_info->dma =3D dma_map_page(dev,
-						frag->page,
-						frag->page_offset,
-						len,
+		buffer_info->dma =3D skb_frag_dma_map(dev, frag, 0, len,
 						DMA_TO_DEVICE);
 		if (dma_mapping_error(dev, buffer_info->dma))
 			goto dma_error;
diff --git a/drivers/net/igbvf/netdev.c b/drivers/net/igbvf/netdev.c
index 1c77fb3..3f6655f 100644
--- a/drivers/net/igbvf/netdev.c
+++ b/drivers/net/igbvf/netdev.c
@@ -2074,10 +2074,7 @@ static inline int igbvf_tx_map_adv(struct igbvf_=
adapter *adapter,
 		buffer_info->time_stamp =3D jiffies;
 		buffer_info->next_to_watch =3D i;
 		buffer_info->mapped_as_page =3D true;
-		buffer_info->dma =3D dma_map_page(&pdev->dev,
-						frag->page,
-						frag->page_offset,
-						len,
+		buffer_info->dma =3D skb_frag_dma_map(&pdev->dev, frag, 0, len,
 						DMA_TO_DEVICE);
 		if (dma_mapping_error(&pdev->dev, buffer_info->dma))
 			goto dma_error;
diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.=
c
index 6a130eb..45c4e90 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -1341,7 +1341,7 @@ ixgb_tx_map(struct ixgb_adapter *adapter, struct =
sk_buff *skb,
=20
 		frag =3D &skb_shinfo(skb)->frags[f];
 		len =3D frag->size;
-		offset =3D frag->page_offset;
+		offset =3D 0;
=20
 		while (len) {
 			i++;
@@ -1361,8 +1361,8 @@ ixgb_tx_map(struct ixgb_adapter *adapter, struct =
sk_buff *skb,
 			buffer_info->time_stamp =3D jiffies;
 			buffer_info->mapped_as_page =3D true;
 			buffer_info->dma =3D
-				dma_map_page(&pdev->dev, frag->page,
-					     offset, size, DMA_TO_DEVICE);
+				skb_frag_dma_map(&pdev->dev, frag, offset, size,
+						 DMA_TO_DEVICE);
 			if (dma_mapping_error(&pdev->dev, buffer_info->dma))
 				goto dma_error;
 			buffer_info->next_to_watch =3D 0;
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_m=
ain.c
index 08e8e25..307cf06 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -6632,7 +6632,7 @@ static int ixgbe_tx_map(struct ixgbe_adapter *ada=
pter,
=20
 		frag =3D &skb_shinfo(skb)->frags[f];
 		len =3D min((unsigned int)frag->size, total);
-		offset =3D frag->page_offset;
+		offset =3D 0;
=20
 		while (len) {
 			i++;
@@ -6643,10 +6643,9 @@ static int ixgbe_tx_map(struct ixgbe_adapter *ad=
apter,
 			size =3D min(len, (uint)IXGBE_MAX_DATA_PER_TXD);
=20
 			tx_buffer_info->length =3D size;
-			tx_buffer_info->dma =3D dma_map_page(dev,
-							   frag->page,
-							   offset, size,
-							   DMA_TO_DEVICE);
+			tx_buffer_info->dma =3D
+				skb_frag_dma_map(dev, frag, offset, size,
+					     DMA_TO_DEVICE);
 			tx_buffer_info->mapped_as_page =3D true;
 			if (dma_mapping_error(dev, tx_buffer_info->dma))
 				goto dma_error;
diff --git a/drivers/net/ixgbevf/ixgbevf_main.c b/drivers/net/ixgbevf/i=
xgbevf_main.c
index 28d3cb2..ad05ad9 100644
--- a/drivers/net/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ixgbevf/ixgbevf_main.c
@@ -2951,18 +2951,16 @@ static int ixgbevf_tx_map(struct ixgbevf_adapte=
r *adapter,
=20
 		frag =3D &skb_shinfo(skb)->frags[f];
 		len =3D min((unsigned int)frag->size, total);
-		offset =3D frag->page_offset;
+		offset =3D 0;
=20
 		while (len) {
 			tx_buffer_info =3D &tx_ring->tx_buffer_info[i];
 			size =3D min(len, (unsigned int)IXGBE_MAX_DATA_PER_TXD);
=20
 			tx_buffer_info->length =3D size;
-			tx_buffer_info->dma =3D dma_map_page(&adapter->pdev->dev,
-							   frag->page,
-							   offset,
-							   size,
-							   DMA_TO_DEVICE);
+			tx_buffer_info->dma =3D
+				skb_frag_dma_map(&adapter->pdev->dev, frag,
+						 offset, size, DMA_TO_DEVICE);
 			tx_buffer_info->mapped_as_page =3D true;
 			if (dma_mapping_error(&pdev->dev, tx_buffer_info->dma))
 				goto dma_error;
diff --git a/drivers/net/jme.c b/drivers/net/jme.c
index b5b174a..a73e895 100644
--- a/drivers/net/jme.c
+++ b/drivers/net/jme.c
@@ -1928,8 +1928,9 @@ jme_map_tx_skb(struct jme_adapter *jme, struct sk=
_buff *skb, int idx)
 		ctxdesc =3D txdesc + ((idx + i + 2) & (mask));
 		ctxbi =3D txbi + ((idx + i + 2) & (mask));
=20
-		jme_fill_tx_map(jme->pdev, ctxdesc, ctxbi, frag->page,
-				 frag->page_offset, frag->size, hidma);
+		jme_fill_tx_map(jme->pdev, ctxdesc, ctxbi,
+				__skb_frag_page(frag),
+				frag->page_offset, frag->size, hidma);
 	}
=20
 	len =3D skb_is_nonlinear(skb) ? skb_headlen(skb) : skb->len;
diff --git a/drivers/net/ksz884x.c b/drivers/net/ksz884x.c
index 41ea592..e610d88 100644
--- a/drivers/net/ksz884x.c
+++ b/drivers/net/ksz884x.c
@@ -4703,8 +4703,7 @@ static void send_packet(struct sk_buff *skb, stru=
ct net_device *dev)
=20
 			dma_buf->dma =3D pci_map_single(
 				hw_priv->pdev,
-				page_address(this_frag->page) +
-				this_frag->page_offset,
+				skb_frag_address(this_frag),
 				dma_buf->len,
 				PCI_DMA_TODEVICE);
 			set_tx_buf(desc, dma_buf->dma);
diff --git a/drivers/net/mlx4/en_rx.c b/drivers/net/mlx4/en_rx.c
index 277215f..21a89e0 100644
--- a/drivers/net/mlx4/en_rx.c
+++ b/drivers/net/mlx4/en_rx.c
@@ -60,20 +60,18 @@ static int mlx4_en_alloc_frag(struct mlx4_en_priv *=
priv,
 		if (!page)
 			return -ENOMEM;
=20
-		skb_frags[i].page =3D page_alloc->page;
+		__skb_frag_set_page(&skb_frags[i], page_alloc->page);
 		skb_frags[i].page_offset =3D page_alloc->offset;
 		page_alloc->page =3D page;
 		page_alloc->offset =3D frag_info->frag_align;
 	} else {
-		page =3D page_alloc->page;
-		get_page(page);
-
-		skb_frags[i].page =3D page;
+		__skb_frag_set_page(&skb_frags[i], page_alloc->page);
+		__skb_frag_ref(&skb_frags[i]);
 		skb_frags[i].page_offset =3D page_alloc->offset;
 		page_alloc->offset +=3D frag_info->frag_stride;
 	}
-	dma =3D pci_map_single(mdev->pdev, page_address(skb_frags[i].page) +
-			     skb_frags[i].page_offset, frag_info->frag_size,
+	dma =3D pci_map_single(mdev->pdev, skb_frag_address(&skb_frags[i]),
+			     frag_info->frag_size,
 			     PCI_DMA_FROMDEVICE);
 	rx_desc->data[i].addr =3D cpu_to_be64(dma);
 	return 0;
@@ -169,7 +167,7 @@ static int mlx4_en_prepare_rx_desc(struct mlx4_en_p=
riv *priv,
=20
 err:
 	while (i--)
-		put_page(skb_frags[i].page);
+		__skb_frag_unref(&skb_frags[i]);
 	return -ENOMEM;
 }
=20
@@ -196,7 +194,7 @@ static void mlx4_en_free_rx_desc(struct mlx4_en_pri=
v *priv,
 		en_dbg(DRV, priv, "Unmapping buffer at dma:0x%llx\n", (u64) dma);
 		pci_unmap_single(mdev->pdev, dma, skb_frags[nr].size,
 				 PCI_DMA_FROMDEVICE);
-		put_page(skb_frags[nr].page);
+		__skb_frag_unref(&skb_frags[nr]);
 	}
 }
=20
@@ -420,7 +418,7 @@ static int mlx4_en_complete_rx_desc(struct mlx4_en_=
priv *priv,
 			break;
=20
 		/* Save page reference in skb */
-		skb_frags_rx[nr].page =3D skb_frags[nr].page;
+		__skb_frag_set_page(&skb_frags_rx[nr], skb_frags[nr].page);
 		skb_frags_rx[nr].size =3D skb_frags[nr].size;
 		skb_frags_rx[nr].page_offset =3D skb_frags[nr].page_offset;
 		dma =3D be64_to_cpu(rx_desc->data[nr].addr);
@@ -444,7 +442,7 @@ fail:
 	 * the descriptor) of this packet; remaining fragments are reused... =
*/
 	while (nr > 0) {
 		nr--;
-		put_page(skb_frags_rx[nr].page);
+		__skb_frag_unref(&skb_frags_rx[nr]);
 	}
 	return 0;
 }
@@ -474,7 +472,7 @@ static struct sk_buff *mlx4_en_rx_skb(struct mlx4_e=
n_priv *priv,
=20
 	/* Get pointer to first fragment so we could copy the headers into th=
e
 	 * (linear part of the) skb */
-	va =3D page_address(skb_frags[0].page) + skb_frags[0].page_offset;
+	va =3D skb_frag_address(&skb_frags[0]);
=20
 	if (length <=3D SMALL_PACKET_SIZE) {
 		/* We are copying all relevant data to the skb - temporarily
diff --git a/drivers/net/mlx4/en_tx.c b/drivers/net/mlx4/en_tx.c
index b229acf..29816d6 100644
--- a/drivers/net/mlx4/en_tx.c
+++ b/drivers/net/mlx4/en_tx.c
@@ -461,26 +461,13 @@ static inline void mlx4_en_xmit_poll(struct mlx4_=
en_priv *priv, int tx_ind)
 		}
 }
=20
-static void *get_frag_ptr(struct sk_buff *skb)
-{
-	struct skb_frag_struct *frag =3D  &skb_shinfo(skb)->frags[0];
-	struct page *page =3D frag->page;
-	void *ptr;
-
-	ptr =3D page_address(page);
-	if (unlikely(!ptr))
-		return NULL;
-
-	return ptr + frag->page_offset;
-}
-
 static int is_inline(struct sk_buff *skb, void **pfrag)
 {
 	void *ptr;
=20
 	if (inline_thold && !skb_is_gso(skb) && skb->len <=3D inline_thold) {
 		if (skb_shinfo(skb)->nr_frags =3D=3D 1) {
-			ptr =3D get_frag_ptr(skb);
+			ptr =3D skb_frag_address_safe(&skb_shinfo(skb)->frags[0]);
 			if (unlikely(!ptr))
 				return 0;
=20
@@ -757,8 +744,9 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struc=
t net_device *dev)
 		/* Map fragments */
 		for (i =3D skb_shinfo(skb)->nr_frags - 1; i >=3D 0; i--) {
 			frag =3D &skb_shinfo(skb)->frags[i];
-			dma =3D pci_map_page(mdev->dev->pdev, frag->page, frag->page_offset=
,
-					   frag->size, PCI_DMA_TODEVICE);
+			dma =3D skb_frag_dma_map(&mdev->dev->pdev->dev, frag,
+					       0, frag->size,
+					       PCI_DMA_TODEVICE);
 			data->addr =3D cpu_to_be64(dma);
 			data->lkey =3D cpu_to_be32(mdev->mr.key);
 			wmb();
diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index a5d9b1c..d02a034 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -752,10 +752,10 @@ static void txq_submit_frag_skb(struct tx_queue *=
txq, struct sk_buff *skb)
=20
 		desc->l4i_chk =3D 0;
 		desc->byte_cnt =3D this_frag->size;
-		desc->buf_ptr =3D dma_map_page(mp->dev->dev.parent,
-					     this_frag->page,
-					     this_frag->page_offset,
-					     this_frag->size, DMA_TO_DEVICE);
+		desc->buf_ptr =3D skb_frag_dma_map(mp->dev->dev.parent,
+						 this_frag, 0,
+						 this_frag->size,
+						 DMA_TO_DEVICE);
 	}
 }
=20
diff --git a/drivers/net/myri10ge/myri10ge.c b/drivers/net/myri10ge/myr=
i10ge.c
index bf84849..35b64f4 100644
--- a/drivers/net/myri10ge/myri10ge.c
+++ b/drivers/net/myri10ge/myri10ge.c
@@ -1339,7 +1339,7 @@ myri10ge_rx_done(struct myri10ge_slice_state *ss,=
 int len, __wsum csum,
 	/* Fill skb_frag_struct(s) with data from our receive */
 	for (i =3D 0, remainder =3D len; remainder > 0; i++) {
 		myri10ge_unmap_rx_page(pdev, &rx->info[idx], bytes);
-		rx_frags[i].page =3D rx->info[idx].page;
+		__skb_frag_set_page(&rx_frags[i], rx->info[idx].page); /* XXX */
 		rx_frags[i].page_offset =3D rx->info[idx].page_offset;
 		if (remainder < MYRI10GE_ALLOC_SIZE)
 			rx_frags[i].size =3D remainder;
@@ -1372,7 +1372,7 @@ myri10ge_rx_done(struct myri10ge_slice_state *ss,=
 int len, __wsum csum,
 		ss->stats.rx_dropped++;
 		do {
 			i--;
-			put_page(rx_frags[i].page);
+			__skb_frag_unref(&rx_frags[i]); /* XXX */
 		} while (i !=3D 0);
 		return 0;
 	}
@@ -1380,7 +1380,7 @@ myri10ge_rx_done(struct myri10ge_slice_state *ss,=
 int len, __wsum csum,
 	/* Attach the pages to the skb, and trim off any padding */
 	myri10ge_rx_skb_build(skb, va, rx_frags, len, hlen);
 	if (skb_shinfo(skb)->frags[0].size <=3D 0) {
-		put_page(skb_shinfo(skb)->frags[0].page);
+		skb_frag_unref(skb, 0);
 		skb_shinfo(skb)->nr_frags =3D 0;
 	}
 	skb->protocol =3D eth_type_trans(skb, dev);
@@ -2220,7 +2220,7 @@ myri10ge_get_frag_header(struct skb_frag_struct *=
frag, void **mac_hdr,
 	struct ethhdr *eh;
 	struct vlan_ethhdr *veh;
 	struct iphdr *iph;
-	u8 *va =3D page_address(frag->page) + frag->page_offset;
+	u8 *va =3D skb_frag_address(frag);
 	unsigned long ll_hlen;
 	/* passed opaque through lro_receive_frags() */
 	__wsum csum =3D (__force __wsum) (unsigned long)priv;
@@ -2863,8 +2863,8 @@ again:
 		frag =3D &skb_shinfo(skb)->frags[frag_idx];
 		frag_idx++;
 		len =3D frag->size;
-		bus =3D pci_map_page(mgp->pdev, frag->page, frag->page_offset,
-				   len, PCI_DMA_TODEVICE);
+		bus =3D skb_frag_dma_map(&mgp->pdev->dev, frag, 0, len,
+				       PCI_DMA_TODEVICE);
 		dma_unmap_addr_set(&tx->info[idx], bus, bus);
 		dma_unmap_len_set(&tx->info[idx], len, len);
 	}
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/=
netxen_nic_main.c
index c0788a3..d9c5864 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -1836,8 +1836,8 @@ netxen_map_tx_skb(struct pci_dev *pdev,
 		frag =3D &skb_shinfo(skb)->frags[i];
 		nf =3D &pbuf->frag_array[i+1];
=20
-		map =3D pci_map_page(pdev, frag->page, frag->page_offset,
-				frag->size, PCI_DMA_TODEVICE);
+		map =3D skb_frag_dma_map(&pdev->dev, frag, 0, frag->size,
+				       PCI_DMA_TODEVICE);
 		if (pci_dma_mapping_error(pdev, map))
 			goto unwind;
=20
diff --git a/drivers/net/niu.c b/drivers/net/niu.c
index cc25bff..a901193 100644
--- a/drivers/net/niu.c
+++ b/drivers/net/niu.c
@@ -3290,7 +3290,7 @@ static void niu_rx_skb_append(struct sk_buff *skb=
, struct page *page,
 	int i =3D skb_shinfo(skb)->nr_frags;
 	skb_frag_t *frag =3D &skb_shinfo(skb)->frags[i];
=20
-	frag->page =3D page;
+	__skb_frag_set_page(frag, page);
 	frag->page_offset =3D offset;
 	frag->size =3D size;
=20
@@ -6731,7 +6731,7 @@ static netdev_tx_t niu_start_xmit(struct sk_buff =
*skb,
 		skb_frag_t *frag =3D &skb_shinfo(skb)->frags[i];
=20
 		len =3D frag->size;
-		mapping =3D np->ops->map_page(np->device, frag->page,
+		mapping =3D np->ops->map_page(np->device, __skb_frag_page(frag),
 					    frag->page_offset, len,
 					    DMA_TO_DEVICE);
=20
diff --git a/drivers/net/ns83820.c b/drivers/net/ns83820.c
index 3e4040f..6b3508d 100644
--- a/drivers/net/ns83820.c
+++ b/drivers/net/ns83820.c
@@ -1181,9 +1181,8 @@ again:
 		if (!nr_frags)
 			break;
=20
-		buf =3D pci_map_page(dev->pci_dev, frag->page,
-				   frag->page_offset,
-				   frag->size, PCI_DMA_TODEVICE);
+		buf =3D skb_frag_dma_map(&dev->pci_dev->dev, frag, 0,
+				       frag->size, PCI_DMA_TODEVICE);
 		dprintk("frag: buf=3D%08Lx  page=3D%08lx offset=3D%08lx\n",
 			(long long)buf, (long) page_to_pfn(frag->page),
 			frag->page_offset);
diff --git a/drivers/net/pasemi_mac.c b/drivers/net/pasemi_mac.c
index 9ec112c..3cd2cd3 100644
--- a/drivers/net/pasemi_mac.c
+++ b/drivers/net/pasemi_mac.c
@@ -1505,9 +1505,8 @@ static int pasemi_mac_start_tx(struct sk_buff *sk=
b, struct net_device *dev)
 	for (i =3D 0; i < nfrags; i++) {
 		skb_frag_t *frag =3D &skb_shinfo(skb)->frags[i];
=20
-		map[i+1] =3D pci_map_page(mac->dma_pdev, frag->page,
-					frag->page_offset, frag->size,
-					PCI_DMA_TODEVICE);
+		map[i + 1] =3D skb_frag_dma_map(&mac->dma_pdev->dev, frag, 0,
+					      frag->size, PCI_DMA_TODEVICE);
 		map_size[i+1] =3D frag->size;
 		if (pci_dma_mapping_error(mac->dma_pdev, map[i+1])) {
 			nfrags =3D i;
diff --git a/drivers/net/qla3xxx.c b/drivers/net/qla3xxx.c
index 771bb61..8a95fc7 100644
--- a/drivers/net/qla3xxx.c
+++ b/drivers/net/qla3xxx.c
@@ -2388,9 +2388,8 @@ static int ql_send_map(struct ql3_adapter *qdev,
 			seg++;
 		}
=20
-		map =3D pci_map_page(qdev->pdev, frag->page,
-				   frag->page_offset, frag->size,
-				   PCI_DMA_TODEVICE);
+		map =3D skb_frag_dma_map(&qdev->pdev->dev, frag, 0, frag->size,
+				       PCI_DMA_TODEVICE);
=20
 		err =3D pci_dma_mapping_error(qdev->pdev, map);
 		if (err) {
diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcn=
ic_main.c
index 0f6af5c..fe8d1f8 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -2120,8 +2120,8 @@ qlcnic_map_tx_skb(struct pci_dev *pdev,
 		frag =3D &skb_shinfo(skb)->frags[i];
 		nf =3D &pbuf->frag_array[i+1];
=20
-		map =3D pci_map_page(pdev, frag->page, frag->page_offset,
-				frag->size, PCI_DMA_TODEVICE);
+		map =3D skb_frag_dma_map(&pdev->dev, frag, 0, frag->size,
+				       PCI_DMA_TODEVICE);
 		if (pci_dma_mapping_error(pdev, map))
 			goto unwind;
=20
diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.=
c
index 6b4ff97..cc04e5b 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -1430,10 +1430,8 @@ static int ql_map_send(struct ql_adapter *qdev,
 			map_idx++;
 		}
=20
-		map =3D
-		    pci_map_page(qdev->pdev, frag->page,
-				 frag->page_offset, frag->size,
-				 PCI_DMA_TODEVICE);
+		map =3D skb_frag_dma_map(&qdev->pdev->dev, frag, 0, frag->size,
+				       PCI_DMA_TODEVICE);
=20
 		err =3D pci_dma_mapping_error(qdev->pdev, map);
 		if (err) {
@@ -1494,7 +1492,7 @@ static void ql_process_mac_rx_gro_page(struct ql_=
adapter *qdev,
 	rx_frag =3D skb_shinfo(skb)->frags;
 	nr_frags =3D skb_shinfo(skb)->nr_frags;
 	rx_frag +=3D nr_frags;
-	rx_frag->page =3D lbq_desc->p.pg_chunk.page;
+	__skb_frag_set_page(rx_frag, lbq_desc->p.pg_chunk.page);
 	rx_frag->page_offset =3D lbq_desc->p.pg_chunk.offset;
 	rx_frag->size =3D length;
=20
diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 5990621f..44e27bd 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -4630,7 +4630,7 @@ static int rtl8169_xmit_frags(struct rtl8169_priv=
ate *tp, struct sk_buff *skb,
=20
 		txd =3D tp->TxDescArray + entry;
 		len =3D frag->size;
-		addr =3D ((void *) page_address(frag->page)) + frag->page_offset;
+		addr =3D skb_frag_address(frag);
 		mapping =3D dma_map_single(d, addr, len, DMA_TO_DEVICE);
 		if (unlikely(dma_mapping_error(d, mapping))) {
 			if (net_ratelimit())
diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index df0d2c8..93f20fa 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -4242,10 +4242,10 @@ static netdev_tx_t s2io_xmit(struct sk_buff *sk=
b, struct net_device *dev)
 		if (!frag->size)
 			continue;
 		txdp++;
-		txdp->Buffer_Pointer =3D (u64)pci_map_page(sp->pdev, frag->page,
-							 frag->page_offset,
-							 frag->size,
-							 PCI_DMA_TODEVICE);
+		txdp->Buffer_Pointer =3D (u64)skb_frag_dma_map(&sp->pdev->dev,
+							     frag, 0,
+							     frag->size,
+							     PCI_DMA_TODEVICE);
 		txdp->Control_1 =3D TXD_BUFFER0_SIZE(frag->size);
 		if (offload_type =3D=3D SKB_GSO_UDP)
 			txdp->Control_1 |=3D TXD_UFO_EN;
diff --git a/drivers/net/sfc/rx.c b/drivers/net/sfc/rx.c
index 62e4364..91a6b71 100644
--- a/drivers/net/sfc/rx.c
+++ b/drivers/net/sfc/rx.c
@@ -478,7 +478,7 @@ static void efx_rx_packet_gro(struct efx_channel *c=
hannel,
 		if (efx->net_dev->features & NETIF_F_RXHASH)
 			skb->rxhash =3D efx_rx_buf_hash(eh);
=20
-		skb_shinfo(skb)->frags[0].page =3D page;
+		skb_frag_set_page(skb, 0, page);
 		skb_shinfo(skb)->frags[0].page_offset =3D
 			efx_rx_buf_offset(efx, rx_buf);
 		skb_shinfo(skb)->frags[0].size =3D rx_buf->len;
diff --git a/drivers/net/sfc/tx.c b/drivers/net/sfc/tx.c
index 84eb99e..f2467a1 100644
--- a/drivers/net/sfc/tx.c
+++ b/drivers/net/sfc/tx.c
@@ -137,8 +137,6 @@ netdev_tx_t efx_enqueue_skb(struct efx_tx_queue *tx=
_queue, struct sk_buff *skb)
 	struct pci_dev *pci_dev =3D efx->pci_dev;
 	struct efx_tx_buffer *buffer;
 	skb_frag_t *fragment;
-	struct page *page;
-	int page_offset;
 	unsigned int len, unmap_len =3D 0, fill_level, insert_ptr;
 	dma_addr_t dma_addr, unmap_addr =3D 0;
 	unsigned int dma_len;
@@ -241,13 +239,11 @@ netdev_tx_t efx_enqueue_skb(struct efx_tx_queue *=
tx_queue, struct sk_buff *skb)
 			break;
 		fragment =3D &skb_shinfo(skb)->frags[i];
 		len =3D fragment->size;
-		page =3D fragment->page;
-		page_offset =3D fragment->page_offset;
 		i++;
 		/* Map for DMA */
 		unmap_single =3D false;
-		dma_addr =3D pci_map_page(pci_dev, page, page_offset, len,
-					PCI_DMA_TODEVICE);
+		dma_addr =3D skb_frag_dma_map(&pci_dev->dev, fragment, 0, len,
+					    PCI_DMA_TODEVICE);
 	}
=20
 	/* Transfer ownership of the skb to the final buffer */
@@ -929,9 +925,8 @@ static void tso_start(struct tso_state *st, const s=
truct sk_buff *skb)
 static int tso_get_fragment(struct tso_state *st, struct efx_nic *efx,
 			    skb_frag_t *frag)
 {
-	st->unmap_addr =3D pci_map_page(efx->pci_dev, frag->page,
-				      frag->page_offset, frag->size,
-				      PCI_DMA_TODEVICE);
+	st->unmap_addr =3D skb_frag_dma_map(&efx->pci_dev->dev, frag, 0,
+					  frag->size, PCI_DMA_TODEVICE);
 	if (likely(!pci_dma_mapping_error(efx->pci_dev, st->unmap_addr))) {
 		st->unmap_single =3D false;
 		st->unmap_len =3D frag->size;
diff --git a/drivers/net/skge.c b/drivers/net/skge.c
index f4be5c7..cf635f7 100644
--- a/drivers/net/skge.c
+++ b/drivers/net/skge.c
@@ -2747,8 +2747,8 @@ static netdev_tx_t skge_xmit_frame(struct sk_buff=
 *skb,
 		for (i =3D 0; i < skb_shinfo(skb)->nr_frags; i++) {
 			skb_frag_t *frag =3D &skb_shinfo(skb)->frags[i];
=20
-			map =3D pci_map_page(hw->pdev, frag->page, frag->page_offset,
-					   frag->size, PCI_DMA_TODEVICE);
+			map =3D skb_frag_dma_map(&hw->pdev->dev, frag, 0,
+					       frag->size, PCI_DMA_TODEVICE);
=20
 			e =3D e->next;
 			e->skb =3D skb;
diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index 3ee41da..e1cf142 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -1143,10 +1143,9 @@ static int sky2_rx_map_skb(struct pci_dev *pdev,=
 struct rx_ring_info *re,
 	for (i =3D 0; i < skb_shinfo(skb)->nr_frags; i++) {
 		skb_frag_t *frag =3D &skb_shinfo(skb)->frags[i];
=20
-		re->frag_addr[i] =3D pci_map_page(pdev, frag->page,
-						frag->page_offset,
-						frag->size,
-						PCI_DMA_FROMDEVICE);
+		re->frag_addr[i] =3D skb_frag_dma_map(&pdev->dev, frag, 0,
+						    frag->size,
+						    PCI_DMA_FROMDEVICE);
=20
 		if (pci_dma_mapping_error(pdev, re->frag_addr[i]))
 			goto map_page_error;
@@ -1826,8 +1825,8 @@ static netdev_tx_t sky2_xmit_frame(struct sk_buff=
 *skb,
 	for (i =3D 0; i < skb_shinfo(skb)->nr_frags; i++) {
 		const skb_frag_t *frag =3D &skb_shinfo(skb)->frags[i];
=20
-		mapping =3D pci_map_page(hw->pdev, frag->page, frag->page_offset,
-				       frag->size, PCI_DMA_TODEVICE);
+		mapping =3D skb_frag_dma_map(&hw->pdev->dev, frag, 0,
+					   frag->size, PCI_DMA_TODEVICE);
=20
 		if (pci_dma_mapping_error(hw->pdev, mapping))
 			goto mapping_unwind;
@@ -2360,7 +2359,7 @@ static void skb_put_frags(struct sk_buff *skb, un=
signed int hdr_space,
=20
 		if (length =3D=3D 0) {
 			/* don't need this page */
-			__free_page(frag->page);
+			__skb_frag_unref(frag);
 			--skb_shinfo(skb)->nr_frags;
 		} else {
 			size =3D min(length, (unsigned) PAGE_SIZE);
diff --git a/drivers/net/starfire.c b/drivers/net/starfire.c
index 36045f3..a0c8f34 100644
--- a/drivers/net/starfire.c
+++ b/drivers/net/starfire.c
@@ -1270,7 +1270,7 @@ static netdev_tx_t start_tx(struct sk_buff *skb, =
struct net_device *dev)
 			skb_frag_t *this_frag =3D &skb_shinfo(skb)->frags[i - 1];
 			status |=3D this_frag->size;
 			np->tx_info[entry].mapping =3D
-				pci_map_single(np->pci_dev, page_address(this_frag->page) + this_f=
rag->page_offset, this_frag->size, PCI_DMA_TODEVICE);
+				pci_map_single(np->pci_dev, skb_frag_address(this_frag), this_frag=
->size, PCI_DMA_TODEVICE);
 		}
=20
 		np->tx_ring[entry].addr =3D cpu_to_dma(np->tx_info[entry].mapping);
diff --git a/drivers/net/stmmac/stmmac_main.c b/drivers/net/stmmac/stmm=
ac_main.c
index e25e44a..5157624 100644
--- a/drivers/net/stmmac/stmmac_main.c
+++ b/drivers/net/stmmac/stmmac_main.c
@@ -1040,9 +1040,8 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *sk=
b, struct net_device *dev)
 		desc =3D priv->dma_tx + entry;
=20
 		TX_DBG("\t[entry %d] segment len: %d\n", entry, len);
-		desc->des2 =3D dma_map_page(priv->device, frag->page,
-					  frag->page_offset,
-					  len, DMA_TO_DEVICE);
+		desc->des2 =3D skb_frag_dma_map(priv->device, frag, 0, len,
+					      DMA_TO_DEVICE);
 		priv->tx_skbuff[entry] =3D NULL;
 		priv->hw->desc->prepare_tx_desc(desc, 0, len, csum_insertion);
 		priv->hw->desc->set_tx_owner(desc);
diff --git a/drivers/net/sungem.c b/drivers/net/sungem.c
index ab59300..6b8a7bf 100644
--- a/drivers/net/sungem.c
+++ b/drivers/net/sungem.c
@@ -1078,10 +1078,8 @@ static netdev_tx_t gem_start_xmit(struct sk_buff=
 *skb,
 			u64 this_ctrl;
=20
 			len =3D this_frag->size;
-			mapping =3D pci_map_page(gp->pdev,
-					       this_frag->page,
-					       this_frag->page_offset,
-					       len, PCI_DMA_TODEVICE);
+			mapping =3D skb_frag_dma_map(&gp->pdev->dev, this_frag,
+						   0, len, PCI_DMA_TODEVICE);
 			this_ctrl =3D ctrl;
 			if (frag =3D=3D skb_shinfo(skb)->nr_frags - 1)
 				this_ctrl |=3D TXDCTRL_EOF;
diff --git a/drivers/net/sunhme.c b/drivers/net/sunhme.c
index 30aad54..3baef5e 100644
--- a/drivers/net/sunhme.c
+++ b/drivers/net/sunhme.c
@@ -2315,9 +2315,8 @@ static netdev_tx_t happy_meal_start_xmit(struct s=
k_buff *skb,
 			u32 len, mapping, this_txflags;
=20
 			len =3D this_frag->size;
-			mapping =3D dma_map_page(hp->dma_dev, this_frag->page,
-					       this_frag->page_offset, len,
-					       DMA_TO_DEVICE);
+			mapping =3D skb_frag_dma_map(hp->dma_dev, this_frag,
+						   0, len, DMA_TO_DEVICE);
 			this_txflags =3D tx_flags;
 			if (frag =3D=3D skb_shinfo(skb)->nr_frags - 1)
 				this_txflags |=3D TXFLAG_EOP;
diff --git a/drivers/net/tehuti.c b/drivers/net/tehuti.c
index 80fbee0..d552617 100644
--- a/drivers/net/tehuti.c
+++ b/drivers/net/tehuti.c
@@ -1519,9 +1519,9 @@ bdx_tx_map_skb(struct bdx_priv *priv, struct sk_b=
uff *skb,
=20
 		frag =3D &skb_shinfo(skb)->frags[i];
 		db->wptr->len =3D frag->size;
-		db->wptr->addr.dma =3D
-		    pci_map_page(priv->pdev, frag->page, frag->page_offset,
-				 frag->size, PCI_DMA_TODEVICE);
+		db->wptr->addr.dma =3D skb_frag_dma_map(&priv->pdev->dev, frag,
+						      0, frag->size,
+						      PCI_DMA_TODEVICE);
=20
 		pbl++;
 		pbl->len =3D CPU_CHIP_SWAP32(db->wptr->len);
diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index a1f9f9e..c53104d 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -6040,10 +6040,8 @@ static netdev_tx_t tg3_start_xmit(struct sk_buff=
 *skb, struct net_device *dev)
 			skb_frag_t *frag =3D &skb_shinfo(skb)->frags[i];
=20
 			len =3D frag->size;
-			mapping =3D pci_map_page(tp->pdev,
-					       frag->page,
-					       frag->page_offset,
-					       len, PCI_DMA_TODEVICE);
+			mapping =3D skb_frag_dma_map(&tp->pdev->dev, frag, 0,
+						   len, PCI_DMA_TODEVICE);
=20
 			tnapi->tx_buffers[entry].skb =3D NULL;
 			dma_unmap_addr_set(&tnapi->tx_buffers[entry], mapping,
diff --git a/drivers/net/tsi108_eth.c b/drivers/net/tsi108_eth.c
index 5c633a3..52f89a5 100644
--- a/drivers/net/tsi108_eth.c
+++ b/drivers/net/tsi108_eth.c
@@ -710,9 +710,10 @@ static int tsi108_send_packet(struct sk_buff * skb=
, struct net_device *dev)
 		} else {
 			skb_frag_t *frag =3D &skb_shinfo(skb)->frags[i - 1];
=20
-			data->txring[tx].buf0 =3D
-			    dma_map_page(NULL, frag->page, frag->page_offset,
-					    frag->size, DMA_TO_DEVICE);
+			data->txring[tx].buf0 =3D skb_frag_dma_map(NULL, frag,
+								 0,
+								 frag->size,
+								 DMA_TO_DEVICE);
 			data->txring[tx].len =3D frag->size;
 		}
=20
diff --git a/drivers/net/typhoon.c b/drivers/net/typhoon.c
index 3de4283..eb32147 100644
--- a/drivers/net/typhoon.c
+++ b/drivers/net/typhoon.c
@@ -819,8 +819,7 @@ typhoon_start_tx(struct sk_buff *skb, struct net_de=
vice *dev)
 			typhoon_inc_tx_index(&txRing->lastWrite, 1);
=20
 			len =3D frag->size;
-			frag_addr =3D (void *) page_address(frag->page) +
-						frag->page_offset;
+			frag_addr =3D skb_frag_address(frag);
 			skb_dma =3D pci_map_single(tp->tx_pdev, frag_addr, len,
 					 PCI_DMA_TODEVICE);
 			txd->flags =3D TYPHOON_FRAG_DESC | TYPHOON_DESC_VALID;
diff --git a/drivers/net/via-velocity.c b/drivers/net/via-velocity.c
index 06daa9d..6e34b78 100644
--- a/drivers/net/via-velocity.c
+++ b/drivers/net/via-velocity.c
@@ -2580,9 +2580,10 @@ static netdev_tx_t velocity_xmit(struct sk_buff =
*skb,
 	for (i =3D 0; i < skb_shinfo(skb)->nr_frags; i++) {
 		skb_frag_t *frag =3D &skb_shinfo(skb)->frags[i];
=20
-		tdinfo->skb_dma[i + 1] =3D pci_map_page(vptr->pdev, frag->page,
-				frag->page_offset, frag->size,
-				PCI_DMA_TODEVICE);
+		tdinfo->skb_dma[i + 1] =3D skb_frag_dma_map(&vptr->pdev->dev,
+							  frag, 0,
+							  frag->size,
+							  PCI_DMA_TODEVICE);
=20
 		td_ptr->td_buf[i + 1].pa_low =3D cpu_to_le32(tdinfo->skb_dma[i + 1])=
;
 		td_ptr->td_buf[i + 1].pa_high =3D 0;
diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index f685324..c35ae8f 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -137,7 +137,7 @@ static void set_skb_frag(struct sk_buff *skb, struc=
t page *page,
 	f =3D &skb_shinfo(skb)->frags[i];
 	f->size =3D min((unsigned)PAGE_SIZE - offset, *len);
 	f->page_offset =3D offset;
-	f->page =3D page;
+	__skb_frag_set_page(f, page);
=20
 	skb->data_len +=3D f->size;
 	skb->len +=3D f->size;
diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vm=
xnet3_drv.c
index 6740235..c4a8d2e 100644
--- a/drivers/net/vmxnet3/vmxnet3_drv.c
+++ b/drivers/net/vmxnet3/vmxnet3_drv.c
@@ -656,7 +656,7 @@ vmxnet3_append_frag(struct sk_buff *skb, struct Vmx=
net3_RxCompDesc *rcd,
=20
 	BUG_ON(skb_shinfo(skb)->nr_frags >=3D MAX_SKB_FRAGS);
=20
-	frag->page =3D rbi->page;
+	__skb_frag_set_page(frag, rbi->page);
 	frag->page_offset =3D 0;
 	frag->size =3D rcd->len;
 	skb->data_len +=3D frag->size;
@@ -750,9 +750,9 @@ vmxnet3_map_pkt(struct sk_buff *skb, struct vmxnet3=
_tx_ctx *ctx,
=20
 		tbi =3D tq->buf_info + tq->tx_ring.next2fill;
 		tbi->map_type =3D VMXNET3_MAP_PAGE;
-		tbi->dma_addr =3D pci_map_page(adapter->pdev, frag->page,
-					     frag->page_offset, frag->size,
-					     PCI_DMA_TODEVICE);
+		tbi->dma_addr =3D skb_frag_dma_map(&adapter->pdev->dev, frag,
+						 0, frag->size,
+						 PCI_DMA_TODEVICE);
=20
 		tbi->len =3D frag->size;
=20
diff --git a/drivers/net/vxge/vxge-main.c b/drivers/net/vxge/vxge-main.=
c
index 8ab870a..63e7797 100644
--- a/drivers/net/vxge/vxge-main.c
+++ b/drivers/net/vxge/vxge-main.c
@@ -921,9 +921,9 @@ vxge_xmit(struct sk_buff *skb, struct net_device *d=
ev)
 		if (!frag->size)
 			continue;
=20
-		dma_pointer =3D (u64) pci_map_page(fifo->pdev, frag->page,
-				frag->page_offset, frag->size,
-				PCI_DMA_TODEVICE);
+		dma_pointer =3D (u64)skb_frag_dma_map(&fifo->pdev->dev, frag,
+						    0, frag->size,
+						    PCI_DMA_TODEVICE);
=20
 		if (unlikely(pci_dma_mapping_error(fifo->pdev, dma_pointer)))
 			goto _exit2;
diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netbac=
k/netback.c
index 0e4851b..5c79483 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -215,6 +215,16 @@ static int get_page_ext(struct page *pg,
 			 sizeof(struct iphdr) + MAX_IPOPTLEN + \
 			 sizeof(struct tcphdr) + MAX_TCP_OPTION_SPACE)
=20
+static unsigned long frag_get_pending_idx(skb_frag_t *frag)
+{
+	return (unsigned long)skb_frag_page(frag);
+}
+
+static void frag_set_pending_idx(skb_frag_t *frag, unsigned long pendi=
ng_idx)
+{
+	__skb_frag_set_page(frag, (void *)pending_idx);
+}
+
 static inline pending_ring_idx_t pending_index(unsigned i)
 {
 	return i & (MAX_PENDING_REQS-1);
@@ -512,7 +522,7 @@ static int netbk_gop_skb(struct sk_buff *skb,
=20
 	for (i =3D 0; i < nr_frags; i++) {
 		netbk_gop_frag_copy(vif, skb, npo,
-				    skb_shinfo(skb)->frags[i].page,
+				    __skb_frag_page(&skb_shinfo(skb)->frags[i]),
 				    skb_shinfo(skb)->frags[i].size,
 				    skb_shinfo(skb)->frags[i].page_offset,
 				    &head);
@@ -913,7 +923,7 @@ static struct gnttab_copy *xen_netbk_get_requests(s=
truct xen_netbk *netbk,
 	int i, start;
=20
 	/* Skip first skb fragment if it is on same page as header fragment. =
*/
-	start =3D ((unsigned long)shinfo->frags[0].page =3D=3D pending_idx);
+	start =3D (frag_get_pending_idx(&shinfo->frags[0]) =3D=3D pending_idx=
);
=20
 	for (i =3D start; i < shinfo->nr_frags; i++, txp++) {
 		struct page *page;
@@ -945,7 +955,7 @@ static struct gnttab_copy *xen_netbk_get_requests(s=
truct xen_netbk *netbk,
 		memcpy(&pending_tx_info[pending_idx].req, txp, sizeof(*txp));
 		xenvif_get(vif);
 		pending_tx_info[pending_idx].vif =3D vif;
-		frags[i].page =3D (void *)pending_idx;
+		frag_set_pending_idx(&frags[i], pending_idx);
 	}
=20
 	return gop;
@@ -976,13 +986,13 @@ static int xen_netbk_tx_check_gop(struct xen_netb=
k *netbk,
 	}
=20
 	/* Skip first skb fragment if it is on same page as header fragment. =
*/
-	start =3D ((unsigned long)shinfo->frags[0].page =3D=3D pending_idx);
+	start =3D (frag_get_pending_idx(&shinfo->frags[0]) =3D=3D pending_idx=
);
=20
 	for (i =3D start; i < nr_frags; i++) {
 		int j, newerr;
 		pending_ring_idx_t index;
=20
-		pending_idx =3D (unsigned long)shinfo->frags[i].page;
+		pending_idx =3D frag_get_pending_idx(&shinfo->frags[i]);
=20
 		/* Check error status: if okay then remember grant handle. */
 		newerr =3D (++gop)->status;
@@ -1008,7 +1018,7 @@ static int xen_netbk_tx_check_gop(struct xen_netb=
k *netbk,
 		pending_idx =3D *((u16 *)skb->data);
 		xen_netbk_idx_release(netbk, pending_idx);
 		for (j =3D start; j < i; j++) {
-			pending_idx =3D (unsigned long)shinfo->frags[i].page;
+			pending_idx =3D frag_get_pending_idx(&shinfo->frags[i]);
 			xen_netbk_idx_release(netbk, pending_idx);
 		}
=20
@@ -1029,12 +1039,14 @@ static void xen_netbk_fill_frags(struct xen_net=
bk *netbk, struct sk_buff *skb)
 	for (i =3D 0; i < nr_frags; i++) {
 		skb_frag_t *frag =3D shinfo->frags + i;
 		struct xen_netif_tx_request *txp;
+		struct page *page;
 		unsigned long pending_idx;
=20
-		pending_idx =3D (unsigned long)frag->page;
+		pending_idx =3D frag_get_pending_idx(frag);
=20
 		txp =3D &netbk->pending_tx_info[pending_idx].req;
-		frag->page =3D virt_to_page(idx_to_kaddr(netbk, pending_idx));
+		page =3D virt_to_page(idx_to_kaddr(netbk, pending_idx));
+		__skb_frag_set_page(frag, page);
 		frag->size =3D txp->size;
 		frag->page_offset =3D txp->offset;
=20
@@ -1349,11 +1361,11 @@ static unsigned xen_netbk_tx_build_gops(struct =
xen_netbk *netbk)
 		skb_shinfo(skb)->nr_frags =3D ret;
 		if (data_len < txreq.size) {
 			skb_shinfo(skb)->nr_frags++;
-			skb_shinfo(skb)->frags[0].page =3D
-				(void *)(unsigned long)pending_idx;
+			frag_set_pending_idx(&skb_shinfo(skb)->frags[0],
+					     pending_idx);
 		} else {
 			/* Discriminate from any valid pending_idx value. */
-			skb_shinfo(skb)->frags[0].page =3D (void *)~0UL;
+			frag_set_pending_idx(&skb_shinfo(skb)->frags[0], ~0UL);
 		}
=20
 		__skb_queue_tail(&netbk->tx_queue, skb);
diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index d29365a..ecc4b4b 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -265,7 +265,7 @@ no_skb:
 			break;
 		}
=20
-		skb_shinfo(skb)->frags[0].page =3D page;
+		skb_frag_set_page(skb, 0, page);
 		skb_shinfo(skb)->nr_frags =3D 1;
 		__skb_queue_tail(&np->rx_batch, skb);
 	}
@@ -299,8 +299,8 @@ no_skb:
 		BUG_ON((signed short)ref < 0);
 		np->grant_rx_ref[id] =3D ref;
=20
-		pfn =3D page_to_pfn(skb_shinfo(skb)->frags[0].page);
-		vaddr =3D page_address(skb_shinfo(skb)->frags[0].page);
+		pfn =3D page_to_pfn(skb_frag_page(&skb_shinfo(skb)->frags[0]));
+		vaddr =3D page_address(skb_frag_page(&skb_shinfo(skb)->frags[0]));
=20
 		req =3D RING_GET_REQUEST(&np->rx, req_prod + i);
 		gnttab_grant_foreign_access_ref(ref,
@@ -451,7 +451,7 @@ static void xennet_make_frags(struct sk_buff *skb, =
struct net_device *dev,
 		ref =3D gnttab_claim_grant_reference(&np->gref_tx_head);
 		BUG_ON((signed short)ref < 0);
=20
-		mfn =3D pfn_to_mfn(page_to_pfn(frag->page));
+		mfn =3D pfn_to_mfn(page_to_pfn(skb_frag_page(frag)));
 		gnttab_grant_foreign_access_ref(ref, np->xbdev->otherend_id,
 						mfn, GNTMAP_readonly);
=20
@@ -755,8 +755,9 @@ static RING_IDX xennet_fill_frags(struct netfront_i=
nfo *np,
 	while ((nskb =3D __skb_dequeue(list))) {
 		struct xen_netif_rx_response *rx =3D
 			RING_GET_RESPONSE(&np->rx, ++cons);
+		skb_frag_t *nfrag =3D &skb_shinfo(nskb)->frags[0];
=20
-		frag->page =3D skb_shinfo(nskb)->frags[0].page;
+		__skb_frag_set_page(frag, __skb_frag_page(nfrag));
 		frag->page_offset =3D rx->offset;
 		frag->size =3D rx->status;
=20
@@ -858,7 +859,7 @@ static int handle_incoming_queue(struct net_device =
*dev,
 		memcpy(skb->data, vaddr + offset,
 		       skb_headlen(skb));
=20
-		if (page !=3D skb_shinfo(skb)->frags[0].page)
+		if (page !=3D skb_frag_page(&skb_shinfo(skb)->frags[0]))
 			__free_page(page);
=20
 		/* Ethernet work: Delayed to here as it peeks the header. */
@@ -937,7 +938,8 @@ err:
 			}
 		}
=20
-		NETFRONT_SKB_CB(skb)->page =3D skb_shinfo(skb)->frags[0].page;
+		NETFRONT_SKB_CB(skb)->page =3D
+			__skb_frag_page(&skb_shinfo(skb)->frags[0]);
 		NETFRONT_SKB_CB(skb)->offset =3D rx->offset;
=20
 		len =3D rx->status;
@@ -951,7 +953,7 @@ err:
 			skb_shinfo(skb)->frags[0].size =3D rx->status - len;
 			skb->data_len =3D rx->status - len;
 		} else {
-			skb_shinfo(skb)->frags[0].page =3D NULL;
+			skb_frag_set_page(skb, 0, NULL);
 			skb_shinfo(skb)->nr_frags =3D 0;
 		}
=20
@@ -1094,7 +1096,8 @@ static void xennet_release_rx_bufs(struct netfron=
t_info *np)
=20
 		if (!xen_feature(XENFEAT_auto_translated_physmap)) {
 			/* Remap the page. */
-			struct page *page =3D skb_shinfo(skb)->frags[0].page;
+			const struct page *page =3D
+				skb_frag_page(&skb_shinfo(skb)->frags[0]);
 			unsigned long pfn =3D page_to_pfn(page);
 			void *vaddr =3D page_address(page);
=20
@@ -1593,6 +1596,8 @@ static int xennet_connect(struct net_device *dev)
=20
 	/* Step 2: Rebuild the RX buffer freelist and the RX ring itself. */
 	for (requeue_idx =3D 0, i =3D 0; i < NET_RX_RING_SIZE; i++) {
+		skb_frag_t *frag;
+		const struct page *page;
 		if (!np->rx_skbs[i])
 			continue;
=20
@@ -1600,10 +1605,11 @@ static int xennet_connect(struct net_device *de=
v)
 		ref =3D np->grant_rx_ref[requeue_idx] =3D xennet_get_rx_ref(np, i);
 		req =3D RING_GET_REQUEST(&np->rx, requeue_idx);
=20
+		frag =3D &skb_shinfo(skb)->frags[0];
+		page =3D skb_frag_page(frag);
 		gnttab_grant_foreign_access_ref(
 			ref, np->xbdev->otherend_id,
-			pfn_to_mfn(page_to_pfn(skb_shinfo(skb)->
-					       frags->page)),
+			pfn_to_mfn(page_to_pfn(page)),
 			0);
 		req->gref =3D ref;
 		req->id   =3D requeue_idx;
diff --git a/drivers/scsi/bnx2fc/bnx2fc_fcoe.c b/drivers/scsi/bnx2fc/bn=
x2fc_fcoe.c
index ab255fb..f7a3517 100644
--- a/drivers/scsi/bnx2fc/bnx2fc_fcoe.c
+++ b/drivers/scsi/bnx2fc/bnx2fc_fcoe.c
@@ -296,7 +296,7 @@ static int bnx2fc_xmit(struct fc_lport *lport, stru=
ct fc_frame *fp)
 			return -ENOMEM;
 		}
 		frag =3D &skb_shinfo(skb)->frags[skb_shinfo(skb)->nr_frags - 1];
-		cp =3D kmap_atomic(frag->page, KM_SKB_DATA_SOFTIRQ)
+		cp =3D kmap_atomic(__skb_frag_page(frag), KM_SKB_DATA_SOFTIRQ)
 				+ frag->page_offset;
 	} else {
 		cp =3D (struct fcoe_crc_eof *)skb_put(skb, tlen);
diff --git a/drivers/scsi/cxgbi/libcxgbi.c b/drivers/scsi/cxgbi/libcxgb=
i.c
index a2a9c7c..949ee48 100644
--- a/drivers/scsi/cxgbi/libcxgbi.c
+++ b/drivers/scsi/cxgbi/libcxgbi.c
@@ -1812,7 +1812,7 @@ static int sgl_read_to_frags(struct scatterlist *=
sg, unsigned int sgoffset,
=20
 		}
 		copy =3D min(datalen, sglen);
-		if (i && page =3D=3D frags[i - 1].page &&
+		if (i && page =3D=3D skb_frag_page(&frags[i - 1]) &&
 		    sgoffset + sg->offset =3D=3D
 			frags[i - 1].page_offset + frags[i - 1].size) {
 			frags[i - 1].size +=3D copy;
@@ -1948,7 +1948,7 @@ int cxgbi_conn_init_pdu(struct iscsi_task *task, =
unsigned int offset,
=20
 			/* data fits in the skb's headroom */
 			for (i =3D 0; i < tdata->nr_frags; i++, frag++) {
-				char *src =3D kmap_atomic(frag->page,
+				char *src =3D kmap_atomic(__skb_frag_page(frag),
 							KM_SOFTIRQ0);
=20
 				memcpy(dst, src+frag->page_offset, frag->size);
@@ -1963,7 +1963,7 @@ int cxgbi_conn_init_pdu(struct iscsi_task *task, =
unsigned int offset,
 		} else {
 			/* data fit into frag_list */
 			for (i =3D 0; i < tdata->nr_frags; i++)
-				get_page(tdata->frags[i].page);
+				__skb_frag_ref(&tdata->frags[i]);
=20
 			memcpy(skb_shinfo(skb)->frags, tdata->frags,
 				sizeof(skb_frag_t) * tdata->nr_frags);
diff --git a/drivers/scsi/fcoe/fcoe.c b/drivers/scsi/fcoe/fcoe.c
index 155d7b9..deee71a 100644
--- a/drivers/scsi/fcoe/fcoe.c
+++ b/drivers/scsi/fcoe/fcoe.c
@@ -1425,7 +1425,7 @@ int fcoe_xmit(struct fc_lport *lport, struct fc_f=
rame *fp)
 			return -ENOMEM;
 		}
 		frag =3D &skb_shinfo(skb)->frags[skb_shinfo(skb)->nr_frags - 1];
-		cp =3D kmap_atomic(frag->page, KM_SKB_DATA_SOFTIRQ)
+		cp =3D kmap_atomic(__skb_frag_page(frag), KM_SKB_DATA_SOFTIRQ)
 			+ frag->page_offset;
 	} else {
 		cp =3D (struct fcoe_crc_eof *)skb_put(skb, tlen);
diff --git a/drivers/scsi/fcoe/fcoe_transport.c b/drivers/scsi/fcoe/fco=
e_transport.c
index 41068e8..40243ce 100644
--- a/drivers/scsi/fcoe/fcoe_transport.c
+++ b/drivers/scsi/fcoe/fcoe_transport.c
@@ -108,8 +108,9 @@ u32 fcoe_fc_crc(struct fc_frame *fp)
 		len =3D frag->size;
 		while (len > 0) {
 			clen =3D min(len, PAGE_SIZE - (off & ~PAGE_MASK));
-			data =3D kmap_atomic(frag->page + (off >> PAGE_SHIFT),
-					   KM_SKB_DATA_SOFTIRQ);
+			data =3D kmap_atomic(
+				__skb_frag_page(frag) + (off >> PAGE_SHIFT),
+				KM_SKB_DATA_SOFTIRQ);
 			crc =3D crc32(crc, data + (off & ~PAGE_MASK), clen);
 			kunmap_atomic(data, KM_SKB_DATA_SOFTIRQ);
 			off +=3D clen;
diff --git a/drivers/staging/et131x/et1310_tx.c b/drivers/staging/et131=
x/et1310_tx.c
index 4241d2a..63ee8af 100644
--- a/drivers/staging/et131x/et1310_tx.c
+++ b/drivers/staging/et131x/et1310_tx.c
@@ -519,12 +519,11 @@ static int nic_send_packet(struct et131x_adapter =
*etdev, struct tcb *tcb)
 			 * returned by pci_map_page() is always 32-bit
 			 * addressable (as defined by the pci/dma subsystem)
 			 */
-			desc[frag++].addr_lo =3D
-			    pci_map_page(etdev->pdev,
-					 frags[i - 1].page,
-					 frags[i - 1].page_offset,
-					 frags[i - 1].size,
-					 PCI_DMA_TODEVICE);
+			desc[frag++].addr_lo =3D skb_frag_dma_map(&etdev->pdev->dev,
+								&frags[i - 1],
+								0,
+								frags[i - 1].size,
+								PCI_DMA_TODEVICE);
 		}
 	}
=20
diff --git a/drivers/staging/hv/netvsc_drv.c b/drivers/staging/hv/netvs=
c_drv.c
index 7b9c229..80d1f1f 100644
--- a/drivers/staging/hv/netvsc_drv.c
+++ b/drivers/staging/hv/netvsc_drv.c
@@ -172,7 +172,7 @@ static int netvsc_start_xmit(struct sk_buff *skb, s=
truct net_device *net)
 	for (i =3D 0; i < skb_shinfo(skb)->nr_frags; i++) {
 		skb_frag_t *f =3D &skb_shinfo(skb)->frags[i];
=20
-		packet->page_buf[i+2].pfn =3D page_to_pfn(f->page);
+		packet->page_buf[i+2].pfn =3D page_to_pfn(skb_frag_page(f));
 		packet->page_buf[i+2].offset =3D f->page_offset;
 		packet->page_buf[i+2].len =3D f->size;
 	}
--=20
1.7.2.5

