From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH v2 46/46] net: mark drivers that drop packets from rx queue
 head under memory pressure
Date: Mon, 11 Jul 2011 02:52:50 +0200 (CEST)
Message-ID: <c84a04a957128ae664f4a80da23fad4b9f71a85f.1310339689.git.mirq-linux@rere.qmqm.pl>
References: <cover.1310339688.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Hartley Sweeten <hsweeten@visionengravers.com>,
	Michael Chan <mchan@broadcom.com>,
	Eilon Greenstein <eilong@broadcom.com>,
	Guo-Fu Tseng <cooldavid@cooldavid.org>,
	Realtek linux nic maintainers <nic_swsd@realtek.com>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Matt Carlson <mcarlson@broadcom.com>,
	Jon Mason <jdmason@kudzu.us>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:43663 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753755Ab1GKAw4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 10 Jul 2011 20:52:56 -0400
In-Reply-To: <cover.1310339688.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 drivers/net/arm/ep93xx_eth.c    |    3 +++
 drivers/net/bnx2.c              |    3 +++
 drivers/net/bnx2x/bnx2x_cmn.c   |    3 +++
 drivers/net/cassini.c           |    3 +++
 drivers/net/jme.c               |    3 +++
 drivers/net/mlx4/en_rx.c        |    6 ++++++
 drivers/net/r8169.c             |    3 +++
 drivers/net/skge.c              |    3 +++
 drivers/net/sky2.c              |    2 ++
 drivers/net/tg3.c               |    2 ++
 drivers/net/tokenring/olympic.c |    2 ++
 drivers/net/vxge/vxge-main.c    |    3 +++
 12 files changed, 36 insertions(+), 0 deletions(-)

diff --git a/drivers/net/arm/ep93xx_eth.c b/drivers/net/arm/ep93xx_eth.=
c
index ba3bf43..55a42c0 100644
--- a/drivers/net/arm/ep93xx_eth.c
+++ b/drivers/net/arm/ep93xx_eth.c
@@ -282,6 +282,9 @@ static int ep93xx_rx(struct net_device *dev, int pr=
ocessed, int budget)
 		if (rstat0 & RSTAT0_CRCI)
 			length -=3D 4;
=20
+#warning drops packets from rx queue head on memory pressure
+#warning (like dev_skb_finish_rx_dma_refill() users)
+
 		skb =3D dev_alloc_skb(length + 2);
 		if (likely(skb !=3D NULL)) {
 			struct ep93xx_rdesc *rxd =3D &ep->descs->rdesc[entry];
diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index d627886..14f9a5f 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -2952,6 +2952,9 @@ bnx2_rx_skb(struct bnx2 *bp, struct bnx2_rx_ring_=
info *rxr, struct sk_buff *skb,
 	int err;
 	u16 prod =3D ring_idx & 0xffff;
=20
+#warning drops packets from rx queue head on memory pressure
+#warning (like dev_skb_finish_rx_dma_refill() users)
+
 	err =3D bnx2_alloc_rx_skb(bp, rxr, prod, GFP_ATOMIC);
 	if (unlikely(err)) {
 		bnx2_reuse_rx_skb(bp, rxr, skb, (u16) (ring_idx >> 16), prod);
diff --git a/drivers/net/bnx2x/bnx2x_cmn.c b/drivers/net/bnx2x/bnx2x_cm=
n.c
index 4f9164c..a6da01a 100644
--- a/drivers/net/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/bnx2x/bnx2x_cmn.c
@@ -673,6 +673,9 @@ int bnx2x_rx_int(struct bnx2x_fastpath *fp, int bud=
get)
 				goto reuse_rx;
 			}
=20
+#warning drops packets from rx queue head on memory pressure
+#warning (like dev_skb_finish_rx_dma_refill() users)
+
 			/* Since we don't have a jumbo ring
 			 * copy small packets if mtu > 1500
 			 */
diff --git a/drivers/net/cassini.c b/drivers/net/cassini.c
index 788ab13..a05a490 100644
--- a/drivers/net/cassini.c
+++ b/drivers/net/cassini.c
@@ -1975,6 +1975,9 @@ static int cas_rx_process_pkt(struct cas *cp, str=
uct cas_rx_comp *rxc,
 	else
 		alloclen =3D max(hlen, RX_COPY_MIN);
=20
+#warning drops packets from rx queue head on memory pressure
+#warning (like dev_skb_finish_rx_dma_refill() users)
+
 	skb =3D dev_alloc_skb(alloclen + swivel + cp->crc_size);
 	if (skb =3D=3D NULL)
 		return -1;
diff --git a/drivers/net/jme.c b/drivers/net/jme.c
index ad69dae..e9ac9bd 100644
--- a/drivers/net/jme.c
+++ b/drivers/net/jme.c
@@ -1022,6 +1022,9 @@ jme_alloc_and_feed_skb(struct jme_adapter *jme, i=
nt idx)
 	dma_unmap_single(&jme->pdev->dev, rxbi->mapping, rxbi->len,
 			 DMA_FROM_DEVICE);
=20
+#warning drops packets from rx queue head on memory pressure
+#warning (like dev_skb_finish_rx_dma_refill() users)
+
 	if (unlikely(jme_make_new_rx_buf(jme, idx))) {
 		rxbi->mapping =3D dma_map_single(&jme->pdev->dev, skb->data,
 						rxbi->len, DMA_FROM_DEVICE);
diff --git a/drivers/net/mlx4/en_rx.c b/drivers/net/mlx4/en_rx.c
index ee15295..e2baa3f 100644
--- a/drivers/net/mlx4/en_rx.c
+++ b/drivers/net/mlx4/en_rx.c
@@ -413,6 +413,9 @@ static int mlx4_en_complete_rx_desc(struct mlx4_en_=
priv *priv,
 	int nr;
 	dma_addr_t dma;
=20
+#warning drops packets from rx queue head on memory pressure
+#warning (like dev_skb_finish_rx_dma_refill() users)
+
 	/* Collect used fragments while replacing them in the HW descirptors =
*/
 	for (nr =3D 0; nr < priv->num_frags; nr++) {
 		frag_info =3D &priv->frag_info[nr];
@@ -462,6 +465,9 @@ static struct sk_buff *mlx4_en_rx_skb(struct mlx4_e=
n_priv *priv,
 	int used_frags;
 	dma_addr_t dma;
=20
+#warning drops packets from rx queue head on memory pressure
+#warning (like dev_skb_finish_rx_dma_refill() users)
+
 	skb =3D dev_alloc_skb(SMALL_PACKET_SIZE + NET_IP_ALIGN);
 	if (!skb) {
 		en_dbg(RX_ERR, priv, "Failed allocating skb\n");
diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index e2c2884..ce4bdaf 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -4999,6 +4999,9 @@ static struct sk_buff *rtl8169_try_rx_copy(void *=
data,
 	struct sk_buff *skb;
 	struct device *d =3D &tp->pci_dev->dev;
=20
+#warning drops packets from rx queue head on memory pressure
+#warning (like dev_skb_finish_rx_dma_refill() users)
+
 	data =3D rtl8169_align(data);
 	dma_sync_single_for_cpu(d, addr, pkt_size, DMA_FROM_DEVICE);
 	prefetch(data);
diff --git a/drivers/net/skge.c b/drivers/net/skge.c
index 11e5229..79bf015 100644
--- a/drivers/net/skge.c
+++ b/drivers/net/skge.c
@@ -3022,6 +3022,9 @@ static struct sk_buff *skge_rx_get(struct net_dev=
ice *dev,
 	if (phy_length(skge->hw, status) !=3D len)
 		goto error;
=20
+#warning drops packets from rx queue head on memory pressure
+#warning (like dev_skb_finish_rx_dma_refill() users)
+
 	if (len < RX_COPY_THRESHOLD) {
 		skb =3D netdev_alloc_skb_ip_align(dev, len);
 		if (!skb)
diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index 5f720b9..aaf56e4 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -2540,6 +2540,8 @@ okay:
 		skb =3D receive_copy(sky2, re, length);
 	else
 		skb =3D receive_new(sky2, re, length);
+#warning drops packets from rx queue head on memory pressure
+#warning (like dev_skb_finish_rx_dma_refill() users)
=20
 	dev->stats.rx_dropped +=3D (skb =3D=3D NULL);
=20
diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index b43d473..42e0d31 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -4973,6 +4973,8 @@ static int tg3_rx(struct tg3_napi *tnapi, int bud=
get)
=20
 			skb_size =3D tg3_alloc_rx_skb(tp, tpr, opaque_key,
 						    *post_ptr);
+#warning drops packets from rx queue head on memory pressure
+#warning (like dev_skb_finish_rx_dma_refill() users)
 			if (skb_size < 0)
 				goto drop_it;
=20
diff --git a/drivers/net/tokenring/olympic.c b/drivers/net/tokenring/ol=
ympic.c
index 30fb6e8..e0c3cca 100644
--- a/drivers/net/tokenring/olympic.c
+++ b/drivers/net/tokenring/olympic.c
@@ -797,6 +797,8 @@ static void olympic_rx(struct net_device *dev)
 				}
=20
 				if (skb =3D=3D NULL) {
+#warning drops packets from rx queue head on memory pressure
+#warning (like dev_skb_finish_rx_dma_refill() users)
 					printk(KERN_WARNING "%s: Not enough memory to copy packet to uppe=
r layers.\n",dev->name) ;
 					dev->stats.rx_dropped++;
 					/* Update counters even though we don't transfer the frame */
diff --git a/drivers/net/vxge/vxge-main.c b/drivers/net/vxge/vxge-main.=
c
index 00d435d..00a9003 100644
--- a/drivers/net/vxge/vxge-main.c
+++ b/drivers/net/vxge/vxge-main.c
@@ -414,6 +414,9 @@ vxge_rx_1b_compl(struct __vxge_hw_ring *ringh, void=
 *dtr,
 			}
 		}
=20
+#warning drops packets from rx queue head on memory pressure
+#warning (like dev_skb_finish_rx_dma_refill() users)
+
 		if (pkt_length > VXGE_LL_RX_COPY_THRESHOLD) {
 			if (vxge_rx_alloc(dtr, ring, data_size) !=3D NULL) {
 				if (!vxge_rx_map(dtr, ring)) {
--=20
1.7.5.4

