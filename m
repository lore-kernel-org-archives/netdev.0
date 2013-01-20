From: Patrik Karlin <patrik.karlin@gmail.com>
Subject: [PATCH 5/5] drivers: atm: checkpatch.pl fixed coding style issues in eni.c
Date: Mon, 21 Jan 2013 00:12:55 +0100
Message-ID: <1358723575-8345-5-git-send-email-patrik.karlin@gmail.com>
References: <1358723575-8345-1-git-send-email-patrik.karlin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Patrik Karlin <patrik.karlin@gmail.com>
To: chas@cmf.nrl.navy.mil
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f44.google.com ([209.85.215.44]:63228 "EHLO
	mail-la0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752305Ab3ATXNc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jan 2013 18:13:32 -0500
In-Reply-To: <1358723575-8345-1-git-send-email-patrik.karlin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes statement placement around if/else/for statments
as suggested by checkpatch.pl

Signed-off-by: Patrik K=C3=A5rlin <patrik.karlin@gmail.com>
---
 drivers/atm/eni.c |  318 ++++++++++++++++++++++++++++++++++-----------=
--------
 1 file changed, 205 insertions(+), 113 deletions(-)

diff --git a/drivers/atm/eni.c b/drivers/atm/eni.c
index 2877832..a8a18d4 100644
--- a/drivers/atm/eni.c
+++ b/drivers/atm/eni.c
@@ -214,7 +214,8 @@ static void eni_put_free(struct eni_dev *eni_dev, v=
oid __iomem *start,
 			       start, size);
 			break;
 		}
-		for (order =3D 0; !(((unsigned long)start | size) & (1 << order)); o=
rder++);
+		for (order =3D 0; !(((unsigned long)start | size) & (1 << order)); o=
rder++)
+			;
 		if (MID_MIN_BUF_SIZE > (1 << order)) {
 			printk(KERN_CRIT "eni_put_free: order %d too small\n",
 			       order);
@@ -239,9 +240,12 @@ static void __iomem *eni_alloc_mem(struct eni_dev =
*eni_dev, unsigned long *size)
=20
 	list =3D eni_dev->free_list;
 	len =3D eni_dev->free_len;
-	if (*size < MID_MIN_BUF_SIZE) *size =3D MID_MIN_BUF_SIZE;
-	if (*size > MID_MAX_BUF_SIZE) return NULL;
-	for (order =3D 0; (1 << order) < *size; order++);
+	if (*size < MID_MIN_BUF_SIZE)
+		*size =3D MID_MIN_BUF_SIZE;
+	if (*size > MID_MAX_BUF_SIZE)
+		return NULL;
+	for (order =3D 0; (1 << order) < *size; order++)
+		;
 	DPRINTK("trying: %ld->%d\n", *size, order);
 	best_order =3D 65; /* we don't have more than 2^64 of anything ... */
 	index =3D 0; /* silence GCC */
@@ -250,12 +254,12 @@ static void __iomem *eni_alloc_mem(struct eni_dev=
 *eni_dev, unsigned long *size)
 			best_order =3D order;
 			index =3D i;
 			break;
-		}
-		else if (best_order > list[i].order && list[i].order > order) {
+		} else if (best_order > list[i].order && list[i].order > order) {
 			best_order =3D list[i].order;
 			index =3D i;
 		}
-	if (best_order =3D=3D 65) return NULL;
+	if (best_order =3D=3D 65)
+		return NULL;
 	start =3D list[index].start-eni_dev->base_diff;
 	list[index] =3D list[--len];
 	eni_dev->free_len =3D len;
@@ -277,7 +281,8 @@ static void eni_free_mem(struct eni_dev *eni_dev, v=
oid __iomem *start,
 	start +=3D eni_dev->base_diff;
 	list =3D eni_dev->free_list;
 	len =3D eni_dev->free_len;
-	for (order =3D -1; size; order++) size >>=3D 1;
+	for (order =3D -1; size; order++)
+		size >>=3D 1;
 	DPRINTK("eni_free_mem: %p+0x%lx (order %d)\n", start, size, order);
 	for (i =3D 0; i < len; i++)
 		if (((unsigned long) list[i].start) =3D=3D ((unsigned long)start^(1 =
<< order)) &&
@@ -373,7 +378,8 @@ static int do_rx_dma(struct atm_vcc *vcc, struct sk=
_buff *skb,
 		j++;
 	}
 	here =3D (eni_vcc->descr+size+skip) & (eni_vcc->words-1);
-	if (!eff) size +=3D skip;
+	if (!eff)
+		size +=3D skip;
 	else {
 		unsigned long words;
=20
@@ -387,7 +393,8 @@ static int do_rx_dma(struct atm_vcc *vcc, struct sk=
_buff *skb,
 			unsigned long init;
=20
 			init =3D 4-((paddr & 15) >> 2);
-			if (init > words) init =3D words;
+			if (init > words)
+				init =3D words;
 			dma[j++] =3D MID_DT_WORD | (init << MID_DMA_COUNT_SHIFT) |
 				(vcc->vci << MID_DMA_VCI_SHIFT);
 			dma[j++] =3D paddr;
@@ -481,7 +488,8 @@ trouble:
 	if (paddr)
 		pci_unmap_single(eni_dev->pci_dev, paddr, skb->len,
 				 PCI_DMA_FROMDEVICE);
-	if (skb) dev_kfree_skb_irq(skb);
+	if (skb)
+		dev_kfree_skb_irq(skb);
 	return -1;
 }
=20
@@ -492,10 +500,13 @@ static void discard(struct atm_vcc *vcc, unsigned=
 long size)
=20
 	eni_vcc =3D ENI_VCC(vcc);
 	EVENT("discard (size=3D%ld)\n", size, 0);
-	while (do_rx_dma(vcc, NULL, 1, size, 0)) EVENT("BUSY LOOP", 0, 0);
+	while (do_rx_dma(vcc, NULL, 1, size, 0))
+		EVENT("BUSY LOOP", 0, 0);
 	/* could do a full fallback, but that might be more expensive */
-	if (eni_vcc->rxing) ENI_PRV_POS(eni_vcc->last) +=3D size+1;
-	else eni_vcc->rx_pos =3D (eni_vcc->rx_pos+size+1) & (eni_vcc->words-1=
);
+	if (eni_vcc->rxing)
+		ENI_PRV_POS(eni_vcc->last) +=3D size+1;
+	else
+		eni_vcc->rx_pos =3D (eni_vcc->rx_pos+size+1) & (eni_vcc->words-1);
 }
=20
=20
@@ -523,8 +534,7 @@ static int rx_aal0(struct atm_vcc *vcc)
 			vcc->dev->number);
 		length =3D 0;
 		atomic_inc(&vcc->stats->rx_err);
-	}
-	else {
+	} else {
 		length =3D ATM_CELL_SIZE-1; /* no HEC */
 	}
 	skb =3D length ? atm_alloc_charge(vcc, length, GFP_ATOMIC) : NULL;
@@ -535,7 +545,8 @@ static int rx_aal0(struct atm_vcc *vcc)
 	skb_put(skb, length);
 	skb->tstamp =3D eni_vcc->timestamp;
 	DPRINTK("got len %ld\n", length);
-	if (do_rx_dma(vcc, skb, 1, length >> 2, length >> 2)) return 1;
+	if (do_rx_dma(vcc, skb, 1, length >> 2, length >> 2))
+		return 1;
 	eni_vcc->rxing++;
 	return 0;
 }
@@ -562,8 +573,7 @@ static int rx_aal5(struct atm_vcc *vcc)
 			DPRINTK(DEV_LABEL "(itf %d): trashing empty cell\n",
 				vcc->dev->number);
 			size =3D 0;
-		}
-		else {
+		} else {
 			static unsigned long silence =3D 0;
=20
 			if (time_after(jiffies, silence) || silence =3D=3D 0) {
@@ -578,15 +588,15 @@ static int rx_aal5(struct atm_vcc *vcc)
 		}
 		eff =3D length =3D 0;
 		atomic_inc(&vcc->stats->rx_err);
-	}
-	else {
+	} else {
 		size =3D (descr & MID_RED_COUNT)*(ATM_CELL_PAYLOAD >> 2);
 		DPRINTK("size=3D%ld\n", size);
 		length =3D readl(eni_vcc->recv+(((eni_vcc->descr+size-1) &
 					       (eni_vcc->words-1)))*4) & 0xffff;
 		/* -trailer(2)+header(1) */
 		if (length && length <=3D (size << 2)-8 && length <=3D
-		    ATM_MAX_AAL5_PDU) eff =3D (length+3) >> 2;
+		    ATM_MAX_AAL5_PDU)=20
+			eff =3D (length+3) >> 2;
 		else {				 /* ^ trailer length (8) */
 			EVENT("bad PDU (descr=3D0x08%lx,length=3D%ld)\n", descr,
 			      length);
@@ -604,7 +614,8 @@ static int rx_aal5(struct atm_vcc *vcc)
 	}
 	skb_put(skb, length);
 	DPRINTK("got len %ld\n", length);
-	if (do_rx_dma(vcc, skb, 1, size, eff)) return 1;
+	if (do_rx_dma(vcc, skb, 1, size, eff))
+		return 1;
 	eni_vcc->rxing++;
 	return 0;
 }
@@ -626,7 +637,8 @@ static inline int rx_vcc(struct atm_vcc *vcc)
 		DPRINTK("CB_DESCR %ld REG_DESCR %d\n", ENI_VCC(vcc)->descr,
 			(((unsigned) readl(vci_dsc+4) & MID_VCI_DESCR) >>
 			 MID_VCI_DESCR_SHIFT));
-		if (ENI_VCC(vcc)->rx(vcc)) return 1;
+		if (ENI_VCC(vcc)->rx(vcc))
+			return 1;
 	}
 	/* clear IN_SERVICE flag */
 	writel(readl(vci_dsc) & ~MID_VCI_IN_SERVICE, vci_dsc);
@@ -643,7 +655,8 @@ static inline int rx_vcc(struct atm_vcc *vcc)
 		DPRINTK("CB_DESCR %ld REG_DESCR %d\n", ENI_VCC(vcc)->descr,
 			(((unsigned) readl(vci_dsc+4) & MID_VCI_DESCR) >>
 			 MID_VCI_DESCR_SHIFT));
-		if (ENI_VCC(vcc)->rx(vcc)) return 1;
+		if (ENI_VCC(vcc)->rx(vcc))
+			return 1;
 	}
 	return 0;
 }
@@ -657,7 +670,8 @@ static void poll_rx(struct atm_dev *dev)
 	eni_dev =3D ENI_DEV(dev);
 	while ((curr =3D eni_dev->fast)) {
 		EVENT("poll_rx.fast\n", 0, 0);
-		if (rx_vcc(curr)) return;
+		if (rx_vcc(curr))
+			return;
 		eni_dev->fast =3D ENI_VCC(curr)->next;
 		ENI_VCC(curr)->next =3D ENI_VCC_NOS;
 		barrier();
@@ -665,7 +679,8 @@ static void poll_rx(struct atm_dev *dev)
 	}
 	while ((curr =3D eni_dev->slow)) {
 		EVENT("poll_rx.slow\n", 0, 0);
-		if (rx_vcc(curr)) return;
+		if (rx_vcc(curr))
+			return;
 		eni_dev->slow =3D ENI_VCC(curr)->next;
 		ENI_VCC(curr)->next =3D ENI_VCC_NOS;
 		barrier();
@@ -703,13 +718,14 @@ static void get_service(struct atm_dev *dev)
 		if (vcc->qos.rxtp.traffic_class =3D=3D ATM_CBR) {
 			if (eni_dev->fast)
 				ENI_VCC(eni_dev->last_fast)->next =3D vcc;
-			else eni_dev->fast =3D vcc;
+			else
+				eni_dev->fast =3D vcc;
 			eni_dev->last_fast =3D vcc;
-		}
-		else {
+		} else {
 			if (eni_dev->slow)
 				ENI_VCC(eni_dev->last_slow)->next =3D vcc;
-			else eni_dev->slow =3D vcc;
+			else
+				eni_dev->slow =3D vcc;
 			eni_dev->last_slow =3D vcc;
 		}
 		putting++;
@@ -757,7 +773,8 @@ static void dequeue_rx(struct atm_dev *dev)
 		eni_vcc->rx_pos =3D ENI_PRV_POS(skb) & (eni_vcc->words-1);
 		pci_unmap_single(eni_dev->pci_dev, ENI_PRV_PADDR(skb), skb->len,
 				 PCI_DMA_TODEVICE);
-		if (!skb->len) dev_kfree_skb_irq(skb);
+		if (!skb->len)
+			dev_kfree_skb_irq(skb);
 		else {
 			EVENT("pushing (len=3D%ld)\n", skb->len, 0);
 			if (vcc->qos.aal =3D=3D ATM_AAL0)
@@ -783,7 +800,8 @@ static int open_rx_first(struct atm_vcc *vcc)
 	eni_dev =3D ENI_DEV(vcc->dev);
 	eni_vcc =3D ENI_VCC(vcc);
 	eni_vcc->rx =3D NULL;
-	if (vcc->qos.rxtp.traffic_class =3D=3D ATM_NONE) return 0;
+	if (vcc->qos.rxtp.traffic_class =3D=3D ATM_NONE)
+		return 0;
 	size =3D vcc->qos.rxtp.max_sdu*eni_dev->rx_mult/100;
 	if (size > MID_MAX_BUF_SIZE && vcc->qos.rxtp.max_sdu <=3D
 	    MID_MAX_BUF_SIZE)
@@ -791,7 +809,8 @@ static int open_rx_first(struct atm_vcc *vcc)
 	eni_vcc->recv =3D eni_alloc_mem(eni_dev, &size);
 	DPRINTK("rx at 0x%lx\n", eni_vcc->recv);
 	eni_vcc->words =3D size >> 2;
-	if (!eni_vcc->recv) return -ENOBUFS;
+	if (!eni_vcc->recv)
+		return -ENOBUFS;
 	eni_vcc->rx =3D vcc->qos.aal =3D=3D ATM_AAL5 ? rx_aal5 : rx_aal0;
 	eni_vcc->descr =3D 0;
 	eni_vcc->rx_pos =3D 0;
@@ -813,12 +832,14 @@ static int open_rx_second(struct atm_vcc *vcc)
 	DPRINTK("open_rx_second\n");
 	eni_dev =3D ENI_DEV(vcc->dev);
 	eni_vcc =3D ENI_VCC(vcc);
-	if (!eni_vcc->rx) return 0;
+	if (!eni_vcc->rx)
+		return 0;
 	/* set up VCI descriptor */
 	here =3D eni_dev->vci+vcc->vci*16;
 	DPRINTK("loc 0x%x\n", (unsigned) (eni_vcc->recv-eni_dev->ram)/4);
 	size =3D eni_vcc->words >> 8;
-	for (order =3D -1; size; order++) size >>=3D 1;
+	for (order =3D -1; size; order++)
+		size >>=3D 1;
 	writel(0, here+4); /* descr, read =3D 0 */
 	writel(0, here+8); /* write, state, count =3D 0 */
 	if (eni_dev->rx_map[vcc->vci])
@@ -841,7 +862,8 @@ static void close_rx(struct atm_vcc *vcc)
 	struct eni_vcc *eni_vcc;
=20
 	eni_vcc =3D ENI_VCC(vcc);
-	if (!eni_vcc->rx) return;
+	if (!eni_vcc->rx)
+		return;
 	eni_dev =3D ENI_DEV(vcc->dev);
 	if (vcc->vpi !=3D ATM_VPI_UNSPEC && vcc->vci !=3D ATM_VCI_UNSPEC) {
 		here =3D eni_dev->vci+vcc->vci*16;
@@ -864,7 +886,8 @@ static void close_rx(struct atm_vcc *vcc)
 			/* transition service->rx: rxing++, servicing-- */
 			if (!eni_vcc->servicing) {
 				barrier();
-				if (!eni_vcc->rxing) break;
+				if (!eni_vcc->rxing)
+					break;
 			}
 			EVENT("drain PDUs (rx %ld, serv %ld)\n", eni_vcc->rxing,
 			      eni_vcc->servicing);
@@ -881,7 +904,8 @@ static void close_rx(struct atm_vcc *vcc)
 			tmp =3D readl(eni_dev->vci+vcc->vci*16+4) & MID_VCI_READ;
 			at_end =3D eni_vcc->rx_pos =3D=3D tmp >> MID_VCI_READ_SHIFT;
 			tasklet_enable(&eni_dev->task);
-			if (at_end) break;
+			if (at_end)
+				break;
 			EVENT("drain discard (host 0x%lx, nic 0x%lx)\n",
 			      eni_vcc->rx_pos, tmp);
 			printk(KERN_INFO "draining RX: host 0x%lx, nic 0x%x\n",
@@ -941,7 +965,8 @@ static inline void put_dma(int chan, u32 *dma, int =
*j, dma_addr_t paddr,
 #endif
 	if (paddr & 3) {
 		init =3D 4-(paddr & 3);
-		if (init > size || size < 7) init =3D size;
+		if (init > size || size < 7)
+			init =3D size;
 		DPRINTK("put_dma: %lx DMA: %d/%d bytes\n",
 			(unsigned long) paddr, init, size);
 		dma[(*j)++] =3D MID_DT_BYTE | (init << MID_DMA_COUNT_SHIFT) |
@@ -954,7 +979,8 @@ static inline void put_dma(int chan, u32 *dma, int =
*j, dma_addr_t paddr,
 	size &=3D 3;
 	if (words && (paddr & 31)) {
 		init =3D 8-((paddr & 31) >> 2);
-		if (init > words) init =3D words;
+		if (init > words)
+			init =3D words;
 		DPRINTK("put_dma: %lx DMA: %d/%d words\n",
 			(unsigned long) paddr, init, words);
 		dma[(*j)++] =3D MID_DT_WORD | (init << MID_DMA_COUNT_SHIFT) |
@@ -1096,8 +1122,10 @@ static enum enq_res do_tx(struct sk_buff *skb)
 	dma_size =3D 3; /* JK for descriptor and final fill, plus final size
 			 mis-alignment fix */
 	DPRINTK("iovcnt =3D %d\n", skb_shinfo(skb)->nr_frags);
-	if (!skb_shinfo(skb)->nr_frags) dma_size +=3D 5;
-	else dma_size +=3D 5*(skb_shinfo(skb)->nr_frags+1);
+	if (!skb_shinfo(skb)->nr_frags)
+		dma_size +=3D 5;
+	else
+		dma_size +=3D 5*(skb_shinfo(skb)->nr_frags+1);
 	if (dma_size > TX_DMA_BUF) {
 		printk(KERN_CRIT DEV_LABEL "(itf %d): needs %d DMA entries "
 		       "(got only %d)\n", vcc->dev->number, dma_size, TX_DMA_BUF);
@@ -1119,8 +1147,10 @@ static enum enq_res do_tx(struct sk_buff *skb)
 		MID_DT_JK;
 	j++;
 	if (!skb_shinfo(skb)->nr_frags)
-		if (aal5) put_dma(tx->index, eni_dev->dma, &j, paddr, skb->len);
-		else put_dma(tx->index, eni_dev->dma, &j, paddr+4, skb->len-4);
+		if (aal5)
+			put_dma(tx->index, eni_dev->dma, &j, paddr, skb->len);
+		else
+			put_dma(tx->index, eni_dev->dma, &j, paddr+4, skb->len-4);
 	else {
 		DPRINTK("doing direct send\n"); /* @@@ well, this doesn't work anywa=
y */
 		for (i =3D -1; i < skb_shinfo(skb)->nr_frags; i++)
@@ -1189,11 +1219,13 @@ static void poll_tx(struct atm_dev *dev)
 		if (tx->send)
 			while ((skb =3D skb_dequeue(&tx->backlog))) {
 				res =3D do_tx(skb);
-				if (res =3D=3D enq_ok) continue;
+				if (res =3D=3D enq_ok)
+					continue;
 				DPRINTK("re-queuing TX PDU\n");
 				skb_queue_head(&tx->backlog, skb);
 				requeued++;
-				if (res =3D=3D enq_jam) return;
+				if (res =3D=3D enq_jam)
+					return;
 				break;
 			}
 	}
@@ -1225,8 +1257,10 @@ static void dequeue_tx(struct atm_dev *dev)
 		ENI_VCC(vcc)->txing -=3D ENI_PRV_SIZE(skb);
 		pci_unmap_single(eni_dev->pci_dev, ENI_PRV_PADDR(skb), skb->len,
 				 PCI_DMA_TODEVICE);
-		if (vcc->pop) vcc->pop(vcc, skb);
-		else dev_kfree_skb_irq(skb);
+		if (vcc->pop)
+			vcc->pop(vcc, skb);
+		else
+			dev_kfree_skb_irq(skb);
 		atomic_inc(&vcc->stats->tx);
 		wake_up(&eni_dev->tx_wait);
 		dma_complete++;
@@ -1239,7 +1273,8 @@ static struct eni_tx *alloc_tx(struct eni_dev *en=
i_dev, int ubr)
 	int i;
=20
 	for (i =3D !ubr; i < NR_CHAN; i++)
-		if (!eni_dev->tx[i].send) return eni_dev->tx+i;
+		if (!eni_dev->tx[i].send)
+			return eni_dev->tx+i;
 	return NULL;
 }
=20
@@ -1250,30 +1285,36 @@ static int comp_tx(struct eni_dev *eni_dev, int=
 *pcr, int reserved, int *pre,
 	static const int pre_div[] =3D { 4, 16, 128, 2048 };
 	/* 2^(((x+2)^2-(x+2))/2+1) */
=20
-	if (unlimited) *pre =3D *res =3D 0;
+	if (unlimited)
+		*pre =3D *res =3D 0;
 	else {
 		if (*pcr > 0) {
 			int div;
=20
 			for (*pre =3D 0; *pre < 3; (*pre)++)
-				if (TS_CLOCK/pre_div[*pre]/64 <=3D *pcr) break;
+				if (TS_CLOCK/pre_div[*pre]/64 <=3D *pcr)
+					break;
 			div =3D pre_div[*pre]**pcr;
 			DPRINTK("min div %d\n", div);
 			*res =3D TS_CLOCK/div-1;
-		}
-		else {
+		} else {
 			int div;
=20
-			if (!*pcr) *pcr =3D eni_dev->tx_bw+reserved;
+			if (!*pcr)
+				*pcr =3D eni_dev->tx_bw+reserved;
 			for (*pre =3D 3; *pre >=3D 0; (*pre)--)
-				if (TS_CLOCK/pre_div[*pre]/64 > -*pcr) break;
-			if (*pre < 3) (*pre)++; /* else fail later */
+				if (TS_CLOCK/pre_div[*pre]/64 > -*pcr)
+					break;
+			if (*pre < 3)
+				(*pre)++; /* else fail later */
 			div =3D pre_div[*pre]*-*pcr;
 			DPRINTK("max div %d\n", div);
 			*res =3D DIV_ROUND_UP(TS_CLOCK, div)-1;
 		}
-		if (*res < 0) *res =3D 0;
-		if (*res > MID_SEG_MAX_RATE) *res =3D MID_SEG_MAX_RATE;
+		if (*res < 0)
+			*res =3D 0;
+		if (*res > MID_SEG_MAX_RATE)
+			*res =3D MID_SEG_MAX_RATE;
 	}
 	*pcr =3D TS_CLOCK/pre_div[*pre]/(*res+1);
 	DPRINTK("out pcr: %d (%d:%d)\n", *pcr, *pre, *res);
@@ -1302,8 +1343,7 @@ static int reserve_or_set_tx(struct atm_vcc *vcc,=
 struct atm_trafprm *txtp,
 		if (size > MID_MAX_BUF_SIZE && txtp->max_sdu <=3D
 		    MID_MAX_BUF_SIZE)
 			size =3D MID_MAX_BUF_SIZE;
-	}
-	else {
+	} else {
 		if (eni_dev->ubr) {
 			eni_vcc->tx =3D eni_dev->ubr;
 			txtp->pcr =3D ATM_OC3_PCR;
@@ -1313,10 +1353,12 @@ static int reserve_or_set_tx(struct atm_vcc *vc=
c, struct atm_trafprm *txtp,
 	}
 	new_tx =3D !eni_vcc->tx;
 	mem =3D NULL; /* for gcc */
-	if (!new_tx) tx =3D eni_vcc->tx;
+	if (!new_tx)
+		tx =3D eni_vcc->tx;
 	else {
 		mem =3D eni_alloc_mem(eni_dev, &size);
-		if (!mem) return -ENOBUFS;
+		if (!mem)
+			return -ENOBUFS;
 		tx =3D alloc_tx(eni_dev, unlimited);
 		if (!tx) {
 			eni_free_mem(eni_dev, mem, size);
@@ -1327,7 +1369,8 @@ static int reserve_or_set_tx(struct atm_vcc *vcc,=
 struct atm_trafprm *txtp,
 		tx->send =3D mem;
 		tx->words =3D size >> 2;
 		skb_queue_head_init(&tx->backlog);
-		for (order =3D 0; size > (1 << (order+10)); order++);
+		for (order =3D 0; size > (1 << (order+10)); order++)
+			;
 		eni_out((order << MID_SIZE_SHIFT) |
 			((tx->send-eni_dev->ram) >> (MID_LOC_SKIP+2)),
 			MID_TX_PLACE(tx->index));
@@ -1335,9 +1378,11 @@ static int reserve_or_set_tx(struct atm_vcc *vcc=
, struct atm_trafprm *txtp,
 			MID_DESCR_START;
 	}
 	error =3D comp_tx(eni_dev, &rate, tx->reserved, &pre, &res, unlimited=
);
-	if (!error  && txtp->min_pcr > rate) error =3D -EINVAL;
+	if (!error  && txtp->min_pcr > rate)
+		error =3D -EINVAL;
 	if (!error && txtp->max_pcr && txtp->max_pcr !=3D ATM_MAX_PCR &&
-	    txtp->max_pcr < rate) error =3D -EINVAL;
+	    txtp->max_pcr < rate)
+		error =3D -EINVAL;
 	if (!error && !ubr && rate > eni_dev->tx_bw+tx->reserved)
 		error =3D -EINVAL;
 	if (!error && set_rsv && !set_shp && rate < tx->shaping)
@@ -1358,12 +1403,14 @@ static int reserve_or_set_tx(struct atm_vcc *vc=
c, struct atm_trafprm *txtp,
 		eni_dev->tx_bw -=3D rate;
 	}
 	if (set_shp || (unlimited && new_tx)) {
-		if (unlimited && new_tx) eni_dev->ubr =3D tx;
+		if (unlimited && new_tx)
+			eni_dev->ubr =3D tx;
 		tx->prescaler =3D pre;
 		tx->resolution =3D res;
 		tx->shaping =3D rate;
 	}
-	if (set_shp) eni_vcc->tx =3D tx;
+	if (set_shp)
+		eni_vcc->tx =3D tx;
 	DPRINTK("rsv %d shp %d\n", tx->reserved, tx->shaping);
 	return 0;
 }
@@ -1372,7 +1419,8 @@ static int reserve_or_set_tx(struct atm_vcc *vcc,=
 struct atm_trafprm *txtp,
 static int open_tx_first(struct atm_vcc *vcc)
 {
 	ENI_VCC(vcc)->tx =3D NULL;
-	if (vcc->qos.txtp.traffic_class =3D=3D ATM_NONE) return 0;
+	if (vcc->qos.txtp.traffic_class =3D=3D ATM_NONE)
+		return 0;
 	ENI_VCC(vcc)->txing =3D 0;
 	return reserve_or_set_tx(vcc, &vcc->qos.txtp, 1, 1);
 }
@@ -1391,7 +1439,8 @@ static void close_tx(struct atm_vcc *vcc)
 	struct eni_vcc *eni_vcc;
=20
 	eni_vcc =3D ENI_VCC(vcc);
-	if (!eni_vcc->tx) return;
+	if (!eni_vcc->tx)
+		return;
 	eni_dev =3D ENI_DEV(vcc->dev);
 	/* wait for TX queue to drain */
 	DPRINTK("eni_close: waiting for TX ...\n");
@@ -1403,7 +1452,8 @@ static void close_tx(struct atm_vcc *vcc)
 		tasklet_disable(&eni_dev->task);
 		txing =3D skb_peek(&eni_vcc->tx->backlog) || eni_vcc->txing;
 		tasklet_enable(&eni_dev->task);
-		if (!txing) break;
+		if (!txing)
+			break;
 		DPRINTK("%d TX left\n", eni_vcc->txing);
 		schedule();
 		set_current_state(TASK_UNINTERRUPTIBLE);
@@ -1460,7 +1510,8 @@ static void foo(void)
 	       "backlogged=3D%d,rx_enqueued=3D%d,rx_dequeued=3D%d,putting=3D%=
d,pushed=3D%d\n",
 	       tx_complete, dma_complete, queued, requeued, submitted, backlo=
gged,
 	       rx_enqueued, rx_dequeued, putting, pushed);
-	if (eni_boards) printk(KERN_INFO "loss: %ld\n", ENI_DEV(eni_boards)->=
lost);
+	if (eni_boards)
+		printk(KERN_INFO "loss: %ld\n", ENI_DEV(eni_boards)->lost);
 }
=20
 #endif
@@ -1634,7 +1685,8 @@ static int get_esi_asic(struct atm_dev *dev)
 		SET_SEPROM;
 		tonga |=3D SEPROM_DATA;
 		SET_SEPROM;
-		if (failed) error =3D -EIO;
+		if (failed)
+			error =3D -EIO;
 		else {
 			dev->esi[i] =3D 0;
 			for (j =3D 7; j >=3D 0; j--) {
@@ -1644,7 +1696,8 @@ static int get_esi_asic(struct atm_dev *dev)
 				tonga |=3D SEPROM_CLK;
 				SET_SEPROM;
 				GET_SEPROM;
-				if (tonga & SEPROM_DATA) dev->esi[i] |=3D 1;
+				if (tonga & SEPROM_DATA)
+					dev->esi[i] |=3D 1;
 				tonga &=3D ~SEPROM_CLK;
 				SET_SEPROM;
 				tonga |=3D SEPROM_DATA;
@@ -1656,7 +1709,8 @@ static int get_esi_asic(struct atm_dev *dev)
 			tonga |=3D SEPROM_CLK;
 			SET_SEPROM;
 			GET_SEPROM;
-			if (!(tonga & SEPROM_DATA)) error =3D -EIO;
+			if (!(tonga & SEPROM_DATA))
+				error =3D -EIO;
 			tonga &=3D ~SEPROM_CLK;
 			SET_SEPROM;
 			tonga |=3D SEPROM_DATA;
@@ -1689,7 +1743,8 @@ static int get_esi_fpga(struct atm_dev *dev, void=
 __iomem *base)
 	int i;
=20
 	mac_base =3D base+EPROM_SIZE-sizeof(struct midway_eprom);
-	for (i =3D 0; i < ESI_LEN; i++) dev->esi[i] =3D readb(mac_base+(i^3))=
;
+	for (i =3D 0; i < ESI_LEN; i++)
+		dev->esi[i] =3D readb(mac_base+(i^3));
 	return 0;
 }
=20
@@ -1747,15 +1802,19 @@ static int eni_do_init(struct atm_dev *dev)
 	last =3D MAP_MAX_SIZE-RAM_BASE;
 	for (i =3D last-RAM_INCREMENT; i >=3D 0; i -=3D RAM_INCREMENT) {
 		writel(0x55555555, eni_dev->ram+i);
-		if (readl(eni_dev->ram+i) !=3D 0x55555555) last =3D i;
+		if (readl(eni_dev->ram+i) !=3D 0x55555555)
+			last =3D i;
 		else {
 			writel(0xAAAAAAAA, eni_dev->ram+i);
-			if (readl(eni_dev->ram+i) !=3D 0xAAAAAAAA) last =3D i;
-			else writel(i, eni_dev->ram+i);
+			if (readl(eni_dev->ram+i) !=3D 0xAAAAAAAA)
+				last =3D i;
+			else
+				writel(i, eni_dev->ram+i);
 		}
 	}
 	for (i =3D 0; i < last; i +=3D RAM_INCREMENT)
-		if (readl(eni_dev->ram+i) !=3D i) break;
+		if (readl(eni_dev->ram+i) !=3D i)
+			break;
 	eni_dev->mem =3D i;
 	memset_io(eni_dev->ram, 0, eni_dev->mem);
 	/* TODO: should shrink allocation now */
@@ -1864,11 +1923,14 @@ static int eni_start(struct atm_dev *dev)
 	 */
 	eni_out(0xffffffff, MID_IE);
 	error =3D start_tx(dev);
-	if (error) goto free_list;
+	if (error)
+		goto free_list;
 	error =3D start_rx(dev);
-	if (error) goto free_list;
+	if (error)
+		goto free_list;
 	error =3D dev->phy->start(dev);
-	if (error) goto free_list;
+	if (error)
+		goto free_list;
 	eni_out(eni_in(MID_MC_S) | (1 << MID_INT_SEL_SHIFT) |
 		MID_TX_LOCK_MODE | MID_DMA_ENABLE | MID_TX_ENABLE | MID_RX_ENABLE,
 		MID_MC_S);
@@ -1890,7 +1952,8 @@ out:
 static void eni_close(struct atm_vcc *vcc)
 {
 	DPRINTK(">eni_close\n");
-	if (!ENI_VCC(vcc)) return;
+	if (!ENI_VCC(vcc))
+		return;
 	clear_bit(ATM_VF_READY, &vcc->flags);
 	close_rx(vcc);
 	close_tx(vcc);
@@ -1922,7 +1985,8 @@ static int eni_open(struct atm_vcc *vcc)
 		vcc->vci);
 	if (!test_bit(ATM_VF_PARTIAL, &vcc->flags)) {
 		eni_vcc =3D kmalloc(sizeof(struct eni_vcc), GFP_KERNEL);
-		if (!eni_vcc) return -ENOMEM;
+		if (!eni_vcc)
+			return -ENOMEM;
 		vcc->dev_data =3D eni_vcc;
 		eni_vcc->tx =3D NULL; /* for eni_close after open_rx */
 		if ((error =3D open_rx_first(vcc))) {
@@ -1934,7 +1998,8 @@ static int eni_open(struct atm_vcc *vcc)
 			return error;
 		}
 	}
-	if (vci =3D=3D ATM_VPI_UNSPEC || vpi =3D=3D ATM_VCI_UNSPEC) return 0;
+	if (vci =3D=3D ATM_VPI_UNSPEC || vpi =3D=3D ATM_VCI_UNSPEC)
+		return 0;
 	if ((error =3D open_rx_second(vcc))) {
 		eni_close(vcc);
 		return error;
@@ -1956,19 +2021,29 @@ static int eni_change_qos(struct atm_vcc *vcc, =
struct atm_qos *qos, int flgs)
 	struct sk_buff *skb;
 	int error, rate, rsv, shp;
=20
-	if (qos->txtp.traffic_class =3D=3D ATM_NONE) return 0;
-	if (tx =3D=3D eni_dev->ubr) return -EBADFD;
+	if (qos->txtp.traffic_class =3D=3D ATM_NONE)
+		return 0;
+	if (tx =3D=3D eni_dev->ubr)
+		return -EBADFD;
 	rate =3D atm_pcr_goal(&qos->txtp);
-	if (rate < 0) rate =3D -rate;
+	if (rate < 0)
+		rate =3D -rate;
 	rsv =3D shp =3D 0;
-	if ((flgs & ATM_MF_DEC_RSV) && rate && rate < tx->reserved) rsv =3D 1=
;
-	if ((flgs & ATM_MF_INC_RSV) && (!rate || rate > tx->reserved)) rsv =3D=
 1;
-	if ((flgs & ATM_MF_DEC_SHP) && rate && rate < tx->shaping) shp =3D 1;
-	if ((flgs & ATM_MF_INC_SHP) && (!rate || rate > tx->shaping)) shp =3D=
 1;
-	if (!rsv && !shp) return 0;
+	if ((flgs & ATM_MF_DEC_RSV) && rate && rate < tx->reserved)
+		rsv =3D 1;
+	if ((flgs & ATM_MF_INC_RSV) && (!rate || rate > tx->reserved))
+		rsv =3D 1;
+	if ((flgs & ATM_MF_DEC_SHP) && rate && rate < tx->shaping)
+		shp =3D 1;
+	if ((flgs & ATM_MF_INC_SHP) && (!rate || rate > tx->shaping))
+		shp =3D 1;
+	if (!rsv && !shp)
+		return 0;
 	error =3D reserve_or_set_tx(vcc, &qos->txtp, rsv, shp);
-	if (error) return error;
-	if (shp && !(flgs & ATM_MF_IMMED)) return 0;
+	if (error)
+		return error;
+	if (shp && !(flgs & ATM_MF_IMMED))
+		return 0;
 	/*
 	 * Walk through the send buffer and patch the rate information in all
 	 * segmentation buffer descriptors of this VCC.
@@ -1977,7 +2052,8 @@ static int eni_change_qos(struct atm_vcc *vcc, st=
ruct atm_qos *qos, int flgs)
 	skb_queue_walk(&eni_dev->tx_queue, skb) {
 		void __iomem *dsc;
=20
-		if (ATM_SKB(skb)->vcc !=3D vcc) continue;
+		if (ATM_SKB(skb)->vcc !=3D vcc)
+			continue;
 		dsc =3D tx->send+ENI_PRV_POS(skb)*4;
 		writel((readl(dsc) & ~(MID_SEG_RATE | MID_SEG_PR)) |
 		       (tx->prescaler << MID_SEG_PR_SHIFT) |
@@ -1993,7 +2069,8 @@ static int eni_ioctl(struct atm_dev *dev, unsigne=
d int cmd, void __user *arg)
 	struct eni_dev *eni_dev =3D ENI_DEV(dev);
=20
 	if (cmd =3D=3D ENI_MEMDUMP) {
-		if (!capable(CAP_NET_ADMIN)) return -EPERM;
+		if (!capable(CAP_NET_ADMIN))
+			return -EPERM;
 		printk(KERN_WARNING "Please use /proc/atm/" DEV_LABEL ":%d "
 		       "instead of obsolete ioctl ENI_MEMDUMP\n", dev->number);
 		dump(dev);
@@ -2002,15 +2079,18 @@ static int eni_ioctl(struct atm_dev *dev, unsig=
ned int cmd, void __user *arg)
 	if (cmd =3D=3D ENI_SETMULT) {
 		struct eni_multipliers mult;
=20
-		if (!capable(CAP_NET_ADMIN)) return -EPERM;
+		if (!capable(CAP_NET_ADMIN))
+			return -EPERM;
 		if (copy_from_user(&mult, arg,
 				   sizeof(struct eni_multipliers)))
 			return -EFAULT;
 		if ((mult.tx && mult.tx <=3D 100) || (mult.rx &&mult.rx <=3D 100) ||
 		    mult.tx > 65536 || mult.rx > 65536)
 			return -EINVAL;
-		if (mult.tx) eni_dev->tx_mult =3D mult.tx;
-		if (mult.rx) eni_dev->rx_mult =3D mult.rx;
+		if (mult.tx)
+			eni_dev->tx_mult =3D mult.tx;
+		if (mult.rx)
+			eni_dev->rx_mult =3D mult.rx;
 		return 0;
 	}
 	if (cmd =3D=3D ATM_SETCIRANGE) {
@@ -2023,7 +2103,8 @@ static int eni_ioctl(struct atm_dev *dev, unsigne=
d int cmd, void __user *arg)
 			return 0;
 		return -EINVAL;
 	}
-	if (!dev->phy->ioctl) return -ENOIOCTLCMD;
+	if (!dev->phy->ioctl)
+		return -ENOIOCTLCMD;
 	return dev->phy->ioctl(dev, cmd, arg);
 }
=20
@@ -2048,19 +2129,24 @@ static int eni_send(struct atm_vcc *vcc, struct=
 sk_buff *skb)
=20
 	DPRINTK(">eni_send\n");
 	if (!ENI_VCC(vcc)->tx) {
-		if (vcc->pop) vcc->pop(vcc, skb);
-		else dev_kfree_skb(skb);
+		if (vcc->pop)
+			vcc->pop(vcc, skb);
+		else
+			dev_kfree_skb(skb);
 		return -EINVAL;
 	}
 	if (!skb) {
 		printk(KERN_CRIT "!skb in eni_send ?\n");
-		if (vcc->pop) vcc->pop(vcc, skb);
+		if (vcc->pop)
+			vcc->pop(vcc, skb);
 		return -EINVAL;
 	}
 	if (vcc->qos.aal =3D=3D ATM_AAL0) {
 		if (skb->len !=3D ATM_CELL_SIZE-1) {
-			if (vcc->pop) vcc->pop(vcc, skb);
-			else dev_kfree_skb(skb);
+			if (vcc->pop)
+				vcc->pop(vcc, skb);
+			else
+				dev_kfree_skb(skb);
 			return -EINVAL;
 		}
 		*(u32 *) skb->data =3D htonl(*(u32 *) skb->data);
@@ -2070,7 +2156,8 @@ static int eni_send(struct atm_vcc *vcc, struct s=
k_buff *skb)
 	tasklet_disable(&ENI_DEV(vcc->dev)->task);
 	res =3D do_tx(skb);
 	tasklet_enable(&ENI_DEV(vcc->dev)->task);
-	if (res =3D=3D enq_ok) return 0;
+	if (res =3D=3D enq_ok)
+		return 0;
 	skb_queue_tail(&ENI_VCC(vcc)->tx->backlog, skb);
 	backlogged++;
 	tasklet_schedule(&ENI_DEV(vcc->dev)->task);
@@ -2154,7 +2241,8 @@ static int eni_proc_read(struct atm_dev *dev, lof=
f_t *pos, char *page)
 	for (i =3D 0; i < NR_CHAN; i++) {
 		struct eni_tx *tx =3D eni_dev->tx+i;
=20
-		if (!tx->send) continue;
+		if (!tx->send)
+			continue;
 		if (!--left) {
 			return sprintf(page, "tx[%d]:	 0x%ld-0x%ld "
 				       "(%6ld bytes), rsv %d cps, shp %d cps%s\n", i,
@@ -2163,7 +2251,8 @@ static int eni_proc_read(struct atm_dev *dev, lof=
f_t *pos, char *page)
 				       tx->reserved, tx->shaping,
 				       tx =3D=3D eni_dev->ubr ? " (UBR)" : "");
 		}
-		if (--left) continue;
+		if (--left)
+			continue;
 		return sprintf(page, "%10sbacklog %u packets\n", "",
 			       skb_queue_len(&tx->backlog));
 	}
@@ -2179,7 +2268,8 @@ static int eni_proc_read(struct atm_dev *dev, lof=
f_t *pos, char *page)
 			if (vcc->dev !=3D dev)
 				continue;
 			eni_vcc =3D ENI_VCC(vcc);
-			if (--left) continue;
+			if (--left)
+				continue;
 			length =3D sprintf(page, "vcc %4d: ", vcc->vci);
 			if (eni_vcc->rx) {
 				length +=3D sprintf(page+length, "0x%ld-0x%ld "
@@ -2187,7 +2277,8 @@ static int eni_proc_read(struct atm_dev *dev, lof=
f_t *pos, char *page)
 						  (unsigned long) (eni_vcc->recv - eni_dev->ram),
 						  eni_vcc->recv-eni_dev->ram+eni_vcc->words*4-1,
 						  eni_vcc->words*4);
-				if (eni_vcc->tx) length +=3D sprintf(page+length, ", ");
+				if (eni_vcc->tx)
+					length +=3D sprintf(page+length, ", ");
 			}
 			if (eni_vcc->tx)
 				length +=3D sprintf(page+length, "tx[%d], txing %d bytes",
@@ -2202,7 +2293,8 @@ static int eni_proc_read(struct atm_dev *dev, lof=
f_t *pos, char *page)
 		struct eni_free *fe =3D eni_dev->free_list+i;
 		unsigned long offset;
=20
-		if (--left) continue;
+		if (--left)
+			continue;
 		offset =3D (unsigned long) eni_dev->ram+eni_dev->base_diff;
 		return sprintf(page, "free	%p-%p (%6d bytes)\n",
 			       fe->start-offset, fe->start-offset+(1 << fe->order)-1,
--=20
1.7.10.4
