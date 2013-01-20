From: Patrik Karlin <patrik.karlin@gmail.com>
Subject: [PATCH 3/5] drivers: atm: checkpatch.pl fixed tabbed indentation in eni.c
Date: Mon, 21 Jan 2013 00:12:53 +0100
Message-ID: <1358723575-8345-3-git-send-email-patrik.karlin@gmail.com>
References: <1358723575-8345-1-git-send-email-patrik.karlin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Patrik Karlin <patrik.karlin@gmail.com>
To: chas@cmf.nrl.navy.mil
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1358723575-8345-1-git-send-email-patrik.karlin@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This removes all dont use spaces att beginning of lines errors
from checkpatch.pl

Signed-off-by: Patrik K=C3=A5rlin <patrik.karlin@gmail.com>
---
 drivers/atm/eni.c |  512 ++++++++++++++++++++++++++-------------------=
--------
 1 file changed, 256 insertions(+), 256 deletions(-)

diff --git a/drivers/atm/eni.c b/drivers/atm/eni.c
index 1d5adc2..f4a136a 100644
--- a/drivers/atm/eni.c
+++ b/drivers/atm/eni.c
@@ -94,8 +94,8 @@ static void event_dump(void)
  * NULL pointer checking
  */
=20
-#define NULLCHECK(x) \
-	if ((unsigned long) (x) < 0x30) \
+#define NULLCHECK(x)							\
+	if ((unsigned long) (x) < 0x30)					\
 		printk(KERN_CRIT #x "=3D=3D0x%lx\n", (unsigned long) (x))
=20
 /*
@@ -135,23 +135,23 @@ static void event_dump(void)
=20
=20
 /*
- * NExx   must not be equal at end
- * EExx   may be equal at end
+ * NExx	  must not be equal at end
+ * EExx	  may be equal at end
  * xxPJOK verify validity of pointer jumps
  * xxPMOK operating on a circular buffer of "c" words
  */
=20
-#define NEPJOK(a0, a1, b) \
-    ((a0) < (a1) ? (b) <=3D (a0) || (b) > (a1) : (b) <=3D (a0) && (b) =
> (a1))
-#define EEPJOK(a0, a1, b) \
-    ((a0) < (a1) ? (b) < (a0) || (b) >=3D (a1) : (b) < (a0) && (b) >=3D=
 (a1))
+#define NEPJOK(a0, a1, b)						\
+	((a0) < (a1) ? (b) <=3D (a0) || (b) > (a1) : (b) <=3D (a0) && (b) > (=
a1))
+#define EEPJOK(a0, a1, b)						\
+	((a0) < (a1) ? (b) < (a0) || (b) >=3D (a1) : (b) < (a0) && (b) >=3D (=
a1))
 #define NEPMOK(a0, d, b, c) NEPJOK(a0, (a0+d) & (c-1), b)
 #define EEPMOK(a0, d, b, c) EEPJOK(a0, (a0+d) & (c-1), b)
=20
=20
 static int tx_complete =3D 0, dma_complete =3D 0, queued =3D 0, requeu=
ed =3D 0,
-  backlogged =3D 0, rx_enqueued =3D 0, rx_dequeued =3D 0, pushed =3D 0=
, submitted =3D 0,
-  putting =3D 0;
+	backlogged =3D 0, rx_enqueued =3D 0, rx_dequeued =3D 0, pushed =3D 0,=
 submitted =3D 0,
+	putting =3D 0;
=20
 static struct atm_dev *eni_boards =3D NULL;
=20
@@ -166,11 +166,11 @@ static struct atm_dev *eni_boards =3D NULL;
 static void dump_mem(struct eni_dev *eni_dev)
 {
 	int i;
-
+=09
 	for (i =3D 0; i < eni_dev->free_len; i++)
 		printk(KERN_DEBUG "  %d: %p %d\n", i,
-		    eni_dev->free_list[i].start,
-		    1 << eni_dev->free_list[i].order);
+		       eni_dev->free_list[i].start,
+		       1 << eni_dev->free_list[i].order);
 }
=20
=20
@@ -187,19 +187,19 @@ static void dump(struct atm_dev *dev)
 	for (i =3D 0; i < NR_CHAN; i++)
 		if (eni_dev->tx[i].send)
 			printk(KERN_NOTICE "  TX %d @ %p: %ld\n", i,
-			    eni_dev->tx[i].send, eni_dev->tx[i].words*4);
+			       eni_dev->tx[i].send, eni_dev->tx[i].words*4);
 	printk(KERN_NOTICE "RX buffers\n");
 	for (i =3D 0; i < 1024; i++)
 		if (eni_dev->rx_map[i] && ENI_VCC(eni_dev->rx_map[i])->rx)
 			printk(KERN_NOTICE "  RX %d @ %p: %ld\n", i,
-			    ENI_VCC(eni_dev->rx_map[i])->recv,
-			    ENI_VCC(eni_dev->rx_map[i])->words*4);
+			       ENI_VCC(eni_dev->rx_map[i])->recv,
+			       ENI_VCC(eni_dev->rx_map[i])->words*4);
 	printk(KERN_NOTICE "----\n");
 }
=20
=20
 static void eni_put_free(struct eni_dev *eni_dev, void __iomem *start,
-    unsigned long size)
+			 unsigned long size)
 {
 	struct eni_free *list;
 	int len, order;
@@ -211,13 +211,13 @@ static void eni_put_free(struct eni_dev *eni_dev,=
 void __iomem *start,
 	while (size) {
 		if (len >=3D eni_dev->free_list_size) {
 			printk(KERN_CRIT "eni_put_free overflow (%p,%ld)\n",
-			    start, size);
+			       start, size);
 			break;
 		}
 		for (order =3D 0; !(((unsigned long)start | size) & (1 << order)); o=
rder++);
 		if (MID_MIN_BUF_SIZE > (1 << order)) {
 			printk(KERN_CRIT "eni_put_free: order %d too small\n",
-			    order);
+			       order);
 			break;
 		}
 		list[len].start =3D (void __iomem *) start;
@@ -252,9 +252,9 @@ static void __iomem *eni_alloc_mem(struct eni_dev *=
eni_dev, unsigned long *size)
 			break;
 		}
 		else if (best_order > list[i].order && list[i].order > order) {
-				best_order =3D list[i].order;
-				index =3D i;
-			}
+			best_order =3D list[i].order;
+			index =3D i;
+		}
 	if (best_order =3D=3D 65) return NULL;
 	start =3D list[index].start-eni_dev->base_diff;
 	list[index] =3D list[--len];
@@ -262,14 +262,14 @@ static void __iomem *eni_alloc_mem(struct eni_dev=
 *eni_dev, unsigned long *size)
 	*size =3D 1 << order;
 	eni_put_free(eni_dev, start+*size, (1 << best_order)-*size);
 	DPRINTK("%ld bytes (order %d) at 0x%lx\n", *size, order, start);
-	memset_io(start, 0, *size);       /* never leak data */
+	memset_io(start, 0, *size);	  /* never leak data */
 	/*dump_mem(eni_dev);*/
 	return start;
 }
=20
=20
 static void eni_free_mem(struct eni_dev *eni_dev, void __iomem *start,
-    unsigned long size)
+			 unsigned long size)
 {
 	struct eni_free *list;
 	int len, i, order;
@@ -283,7 +283,7 @@ static void eni_free_mem(struct eni_dev *eni_dev, v=
oid __iomem *start,
 		if (((unsigned long) list[i].start) =3D=3D ((unsigned long)start^(1 =
<< order)) &&
 		    list[i].order =3D=3D order) {
 			DPRINTK("match[%d]: 0x%lx/0x%lx(0x%x), %d/%d\n", i,
-			    list[i].start, start, 1 << order, list[i].order, order);
+				list[i].start, start, 1 << order, list[i].order, order);
 			list[i] =3D list[--len];
 			start =3D (void __iomem *) ((unsigned long) start & ~(unsigned long=
) (1 << order));
 			order++;
@@ -292,7 +292,7 @@ static void eni_free_mem(struct eni_dev *eni_dev, v=
oid __iomem *start,
 		}
 	if (len >=3D eni_dev->free_list_size) {
 		printk(KERN_ALERT "eni_free_mem overflow (%p,%d)\n", start,
-		    order);
+		       order);
 		return;
 	}
 	list[len].start =3D start;
@@ -318,18 +318,18 @@ static void rx_ident_err(struct atm_vcc *vcc)
 	eni_dev =3D ENI_DEV(dev);
 	/* immediately halt adapter */
 	eni_out(eni_in(MID_MC_S) &
-	    ~(MID_DMA_ENABLE | MID_TX_ENABLE | MID_RX_ENABLE), MID_MC_S);
+		~(MID_DMA_ENABLE | MID_TX_ENABLE | MID_RX_ENABLE), MID_MC_S);
 	/* dump useful information */
 	eni_vcc =3D ENI_VCC(vcc);
 	printk(KERN_ALERT DEV_LABEL "(itf %d): driver error - RX ident "
-	    "mismatch\n", dev->number);
+	       "mismatch\n", dev->number);
 	printk(KERN_ALERT "  VCI %d, rxing %d, words %ld\n", vcc->vci,
-	    eni_vcc->rxing, eni_vcc->words);
+	       eni_vcc->rxing, eni_vcc->words);
 	printk(KERN_ALERT "  host descr 0x%lx, rx pos 0x%lx, descr value "
-	    "0x%x\n", eni_vcc->descr, eni_vcc->rx_pos,
-	    (unsigned) readl(eni_vcc->recv+eni_vcc->descr*4));
+	       "0x%x\n", eni_vcc->descr, eni_vcc->rx_pos,
+	       (unsigned) readl(eni_vcc->recv+eni_vcc->descr*4));
 	printk(KERN_ALERT "  last %p, servicing %d\n", eni_vcc->last,
-	    eni_vcc->servicing);
+	       eni_vcc->servicing);
 	EVENT("---dump ends here---\n", 0, 0);
 	printk(KERN_NOTICE "---recent events---\n");
 	event_dump();
@@ -340,7 +340,7 @@ static void rx_ident_err(struct atm_vcc *vcc)
=20
=20
 static int do_rx_dma(struct atm_vcc *vcc, struct sk_buff *skb,
-                     unsigned long skip, unsigned long size, unsigned =
long eff)
+		     unsigned long skip, unsigned long size, unsigned long eff)
 {
 	struct eni_dev *eni_dev;
 	struct eni_vcc *eni_vcc;
@@ -355,21 +355,21 @@ static int do_rx_dma(struct atm_vcc *vcc, struct =
sk_buff *skb,
 	paddr =3D 0; /* GCC, shut up */
 	if (skb) {
 		paddr =3D pci_map_single(eni_dev->pci_dev, skb->data, skb->len,
-		    PCI_DMA_FROMDEVICE);
+				       PCI_DMA_FROMDEVICE);
 		ENI_PRV_PADDR(skb) =3D paddr;
 		if (paddr & 3)
 			printk(KERN_CRIT DEV_LABEL "(itf %d): VCI %d has "
-			    "mis-aligned RX data (0x%lx)\n", vcc->dev->number,
-			    vcc->vci, (unsigned long) paddr);
+			       "mis-aligned RX data (0x%lx)\n", vcc->dev->number,
+			       vcc->vci, (unsigned long) paddr);
 		ENI_PRV_SIZE(skb) =3D size+skip;
-		    /* PDU plus descriptor */
+		/* PDU plus descriptor */
 		ATM_SKB(skb)->vcc =3D vcc;
 	}
 	j =3D 0;
 	if ((eff && skip) || 1) { /* @@@ actually, skip is always =3D=3D 1 ..=
=2E */
 		here =3D (eni_vcc->descr+skip) & (eni_vcc->words-1);
 		dma[j++] =3D (here << MID_DMA_COUNT_SHIFT) | (vcc->vci
-		    << MID_DMA_VCI_SHIFT) | MID_DT_JK;
+							    << MID_DMA_VCI_SHIFT) | MID_DT_JK;
 		j++;
 	}
 	here =3D (eni_vcc->descr+size+skip) & (eni_vcc->words-1);
@@ -380,7 +380,7 @@ static int do_rx_dma(struct atm_vcc *vcc, struct sk=
_buff *skb,
 		if (!size) {
 			DPRINTK("strange things happen ...\n");
 			EVENT("strange things happen ... (skip=3D%ld,eff=3D%ld)\n",
-			    size, eff);
+			      size, eff);
 		}
 		words =3D eff;
 		if (paddr & 15) {
@@ -389,7 +389,7 @@ static int do_rx_dma(struct atm_vcc *vcc, struct sk=
_buff *skb,
 			init =3D 4-((paddr & 15) >> 2);
 			if (init > words) init =3D words;
 			dma[j++] =3D MID_DT_WORD | (init << MID_DMA_COUNT_SHIFT) |
-			    (vcc->vci << MID_DMA_VCI_SHIFT);
+				(vcc->vci << MID_DMA_VCI_SHIFT);
 			dma[j++] =3D paddr;
 			paddr +=3D init << 2;
 			words -=3D init;
@@ -397,8 +397,8 @@ static int do_rx_dma(struct atm_vcc *vcc, struct sk=
_buff *skb,
 #ifdef CONFIG_ATM_ENI_BURST_RX_16W /* may work with some PCI chipsets =
=2E.. */
 		if (words & ~15) {
 			dma[j++] =3D MID_DT_16W | ((words >> 4) <<
-			    MID_DMA_COUNT_SHIFT) | (vcc->vci <<
-			    MID_DMA_VCI_SHIFT);
+						 MID_DMA_COUNT_SHIFT) | (vcc->vci <<
+									 MID_DMA_VCI_SHIFT);
 			dma[j++] =3D paddr;
 			paddr +=3D (words & ~15) << 2;
 			words &=3D 15;
@@ -407,8 +407,8 @@ static int do_rx_dma(struct atm_vcc *vcc, struct sk=
_buff *skb,
 #ifdef CONFIG_ATM_ENI_BURST_RX_8W  /* works only with *some* PCI chips=
ets ... */
 		if (words & ~7) {
 			dma[j++] =3D MID_DT_8W | ((words >> 3) <<
-			    MID_DMA_COUNT_SHIFT) | (vcc->vci <<
-			    MID_DMA_VCI_SHIFT);
+						MID_DMA_COUNT_SHIFT) | (vcc->vci <<
+									MID_DMA_VCI_SHIFT);
 			dma[j++] =3D paddr;
 			paddr +=3D (words & ~7) << 2;
 			words &=3D 7;
@@ -417,8 +417,8 @@ static int do_rx_dma(struct atm_vcc *vcc, struct sk=
_buff *skb,
 #ifdef CONFIG_ATM_ENI_BURST_RX_4W /* recommended */
 		if (words & ~3) {
 			dma[j++] =3D MID_DT_4W | ((words >> 2) <<
-			    MID_DMA_COUNT_SHIFT) | (vcc->vci <<
-			    MID_DMA_VCI_SHIFT);
+						MID_DMA_COUNT_SHIFT) | (vcc->vci <<
+									MID_DMA_VCI_SHIFT);
 			dma[j++] =3D paddr;
 			paddr +=3D (words & ~3) << 2;
 			words &=3D 3;
@@ -427,8 +427,8 @@ static int do_rx_dma(struct atm_vcc *vcc, struct sk=
_buff *skb,
 #ifdef CONFIG_ATM_ENI_BURST_RX_2W /* probably useless if RX_4W, RX_8W,=
 ... */
 		if (words & ~1) {
 			dma[j++] =3D MID_DT_2W | ((words >> 1) <<
-			    MID_DMA_COUNT_SHIFT) | (vcc->vci <<
-			    MID_DMA_VCI_SHIFT);
+						MID_DMA_COUNT_SHIFT) | (vcc->vci <<
+									MID_DMA_VCI_SHIFT);
 			dma[j++] =3D paddr;
 			paddr +=3D (words & ~1) << 2;
 			words &=3D 1;
@@ -436,13 +436,13 @@ static int do_rx_dma(struct atm_vcc *vcc, struct =
sk_buff *skb,
 #endif
 		if (words) {
 			dma[j++] =3D MID_DT_WORD | (words << MID_DMA_COUNT_SHIFT)
-			    | (vcc->vci << MID_DMA_VCI_SHIFT);
+				| (vcc->vci << MID_DMA_VCI_SHIFT);
 			dma[j++] =3D paddr;
 		}
 	}
 	if (size !=3D eff) {
 		dma[j++] =3D (here << MID_DMA_COUNT_SHIFT) |
-		    (vcc->vci << MID_DMA_VCI_SHIFT) | MID_DT_JK;
+			(vcc->vci << MID_DMA_VCI_SHIFT) | MID_DT_JK;
 		j++;
 	}
 	if (!j || j > 2*RX_DMA_BUF) {
@@ -459,19 +459,19 @@ static int do_rx_dma(struct atm_vcc *vcc, struct =
sk_buff *skb,
 	 */
 	if (!NEPMOK(dma_wr, j+j+1, dma_rd, NR_DMA_RX)) { /* @@@ +1 is ugly */
 		printk(KERN_WARNING DEV_LABEL "(itf %d): RX DMA full\n",
-		    vcc->dev->number);
+		       vcc->dev->number);
 		goto trouble;
 	}
-        for (i =3D 0; i < j; i++) {
+	for (i =3D 0; i < j; i++) {
 		writel(dma[i*2], eni_dev->rx_dma+dma_wr*8);
 		writel(dma[i*2+1], eni_dev->rx_dma+dma_wr*8+4);
 		dma_wr =3D (dma_wr+1) & (NR_DMA_RX-1);
-        }
+	}
 	if (skb) {
 		ENI_PRV_POS(skb) =3D eni_vcc->descr+size+1;
 		skb_queue_tail(&eni_dev->rx_queue, skb);
 		eni_vcc->last =3D skb;
-rx_enqueued++;
+		rx_enqueued++;
 	}
 	eni_vcc->descr =3D here;
 	eni_out(dma_wr, MID_DMA_WR_RX);
@@ -480,7 +480,7 @@ rx_enqueued++;
 trouble:
 	if (paddr)
 		pci_unmap_single(eni_dev->pci_dev, paddr, skb->len,
-		    PCI_DMA_FROMDEVICE);
+				 PCI_DMA_FROMDEVICE);
 	if (skb) dev_kfree_skb_irq(skb);
 	return -1;
 }
@@ -493,7 +493,7 @@ static void discard(struct atm_vcc *vcc, unsigned l=
ong size)
 	eni_vcc =3D ENI_VCC(vcc);
 	EVENT("discard (size=3D%ld)\n", size, 0);
 	while (do_rx_dma(vcc, NULL, 1, size, 0)) EVENT("BUSY LOOP", 0, 0);
-	    /* could do a full fallback, but that might be more expensive */
+	/* could do a full fallback, but that might be more expensive */
 	if (eni_vcc->rxing) ENI_PRV_POS(eni_vcc->last) +=3D size+1;
 	else eni_vcc->rx_pos =3D (eni_vcc->rx_pos+size+1) & (eni_vcc->words-1=
);
 }
@@ -520,7 +520,7 @@ static int rx_aal0(struct atm_vcc *vcc)
 	}
 	if (descr & MID_RED_T) {
 		DPRINTK(DEV_LABEL "(itf %d): trashing empty cell\n",
-		    vcc->dev->number);
+			vcc->dev->number);
 		length =3D 0;
 		atomic_inc(&vcc->stats->rx_err);
 	}
@@ -560,7 +560,7 @@ static int rx_aal5(struct atm_vcc *vcc)
 		if (descr & MID_RED_T) {
 			EVENT("empty cell (descr=3D0x%lx)\n", descr, 0);
 			DPRINTK(DEV_LABEL "(itf %d): trashing empty cell\n",
-			    vcc->dev->number);
+				vcc->dev->number);
 			size =3D 0;
 		}
 		else {
@@ -568,13 +568,13 @@ static int rx_aal5(struct atm_vcc *vcc)
=20
 			if (time_after(jiffies, silence) || silence =3D=3D 0) {
 				printk(KERN_WARNING DEV_LABEL "(itf %d): "
-				    "discarding PDU(s) with CRC error\n",
-				    vcc->dev->number);
+				       "discarding PDU(s) with CRC error\n",
+				       vcc->dev->number);
 				silence =3D (jiffies+2*HZ)|1;
 			}
 			size =3D (descr & MID_RED_COUNT)*(ATM_CELL_PAYLOAD >> 2);
 			EVENT("CRC error (descr=3D0x%lx,size=3D%ld)\n", descr,
-			    size);
+			      size);
 		}
 		eff =3D length =3D 0;
 		atomic_inc(&vcc->stats->rx_err);
@@ -583,16 +583,16 @@ static int rx_aal5(struct atm_vcc *vcc)
 		size =3D (descr & MID_RED_COUNT)*(ATM_CELL_PAYLOAD >> 2);
 		DPRINTK("size=3D%ld\n", size);
 		length =3D readl(eni_vcc->recv+(((eni_vcc->descr+size-1) &
-		    (eni_vcc->words-1)))*4) & 0xffff;
-				/* -trailer(2)+header(1) */
+					       (eni_vcc->words-1)))*4) & 0xffff;
+		/* -trailer(2)+header(1) */
 		if (length && length <=3D (size << 2)-8 && length <=3D
-		  ATM_MAX_AAL5_PDU) eff =3D (length+3) >> 2;
+		    ATM_MAX_AAL5_PDU) eff =3D (length+3) >> 2;
 		else {				 /* ^ trailer length (8) */
 			EVENT("bad PDU (descr=3D0x08%lx,length=3D%ld)\n", descr,
-                              length);
+			      length);
 			printk(KERN_ERR DEV_LABEL "(itf %d): bad AAL5 PDU "
-			    "(VCI=3D%d,length=3D%ld,size=3D%ld (descr 0x%lx))\n",
-			    vcc->dev->number, vcc->vci, length, size << 2, descr);
+			       "(VCI=3D%d,length=3D%ld,size=3D%ld (descr 0x%lx))\n",
+			       vcc->dev->number, vcc->vci, length, size << 2, descr);
 			length =3D eff =3D 0;
 			atomic_inc(&vcc->stats->rx_err);
 		}
@@ -620,12 +620,12 @@ static inline int rx_vcc(struct atm_vcc *vcc)
 	vci_dsc =3D ENI_DEV(vcc->dev)->vci+vcc->vci*16;
 	EVENT("rx_vcc(1)\n", 0, 0);
 	while (eni_vcc->descr !=3D (tmp =3D (readl(vci_dsc+4) & MID_VCI_DESCR=
) >>
-	    MID_VCI_DESCR_SHIFT)) {
+				  MID_VCI_DESCR_SHIFT)) {
 		EVENT("rx_vcc(2: host dsc=3D0x%lx, nic dsc=3D0x%lx)\n",
-		    eni_vcc->descr, tmp);
+		      eni_vcc->descr, tmp);
 		DPRINTK("CB_DESCR %ld REG_DESCR %d\n", ENI_VCC(vcc)->descr,
-		    (((unsigned) readl(vci_dsc+4) & MID_VCI_DESCR) >>
-		    MID_VCI_DESCR_SHIFT));
+			(((unsigned) readl(vci_dsc+4) & MID_VCI_DESCR) >>
+			 MID_VCI_DESCR_SHIFT));
 		if (ENI_VCC(vcc)->rx(vcc)) return 1;
 	}
 	/* clear IN_SERVICE flag */
@@ -637,12 +637,12 @@ static inline int rx_vcc(struct atm_vcc *vcc)
 	 */
 	EVENT("rx_vcc(3)\n", 0, 0);
 	while (ENI_VCC(vcc)->descr !=3D (tmp =3D (readl(vci_dsc+4) & MID_VCI_=
DESCR)
-	    >> MID_VCI_DESCR_SHIFT)) {
+				       >> MID_VCI_DESCR_SHIFT)) {
 		EVENT("rx_vcc(4: host dsc=3D0x%lx, nic dsc=3D0x%lx)\n",
-		    eni_vcc->descr, tmp);
+		      eni_vcc->descr, tmp);
 		DPRINTK("CB_DESCR %ld REG_DESCR %d\n", ENI_VCC(vcc)->descr,
-		    (((unsigned) readl(vci_dsc+4) & MID_VCI_DESCR) >>
-		    MID_VCI_DESCR_SHIFT));
+			(((unsigned) readl(vci_dsc+4) & MID_VCI_DESCR) >>
+			 MID_VCI_DESCR_SHIFT));
 		if (ENI_VCC(vcc)->rx(vcc)) return 1;
 	}
 	return 0;
@@ -688,7 +688,7 @@ static void get_service(struct atm_dev *dev)
 		vcc =3D eni_dev->rx_map[vci & 1023];
 		if (!vcc) {
 			printk(KERN_CRIT DEV_LABEL "(itf %d): VCI %ld not "
-			    "found\n", dev->number, vci);
+			       "found\n", dev->number, vci);
 			continue; /* nasty but we try to go on anyway */
 			/* @@@ nope, doesn't work */
 		}
@@ -712,7 +712,7 @@ static void get_service(struct atm_dev *dev)
 			else eni_dev->slow =3D vcc;
 			eni_dev->last_slow =3D vcc;
 		}
-putting++;
+		putting++;
 		ENI_VCC(vcc)->servicing++;
 	}
 }
@@ -734,21 +734,21 @@ static void dequeue_rx(struct atm_dev *dev)
 		if (!skb) {
 			if (first) {
 				DPRINTK(DEV_LABEL "(itf %d): RX but not "
-				    "rxing\n", dev->number);
+					"rxing\n", dev->number);
 				EVENT("nothing to dequeue\n", 0, 0);
 			}
 			break;
 		}
 		EVENT("dequeued (size=3D%ld,pos=3D0x%lx)\n", ENI_PRV_SIZE(skb),
-                      ENI_PRV_POS(skb));
-rx_dequeued++;
+		      ENI_PRV_POS(skb));
+		rx_dequeued++;
 		vcc =3D ATM_SKB(skb)->vcc;
 		eni_vcc =3D ENI_VCC(vcc);
 		first =3D 0;
 		vci_dsc =3D eni_dev->vci+vcc->vci*16;
 		if (!EEPMOK(eni_vcc->rx_pos, ENI_PRV_SIZE(skb),
-		    (readl(vci_dsc+4) & MID_VCI_READ) >> MID_VCI_READ_SHIFT,
-		    eni_vcc->words)) {
+			    (readl(vci_dsc+4) & MID_VCI_READ) >> MID_VCI_READ_SHIFT,
+			    eni_vcc->words)) {
 			EVENT("requeuing\n", 0, 0);
 			skb_queue_head(&eni_dev->rx_queue, skb);
 			break;
@@ -756,13 +756,13 @@ rx_dequeued++;
 		eni_vcc->rxing--;
 		eni_vcc->rx_pos =3D ENI_PRV_POS(skb) & (eni_vcc->words-1);
 		pci_unmap_single(eni_dev->pci_dev, ENI_PRV_PADDR(skb), skb->len,
-                                 PCI_DMA_TODEVICE);
+				 PCI_DMA_TODEVICE);
 		if (!skb->len) dev_kfree_skb_irq(skb);
 		else {
 			EVENT("pushing (len=3D%ld)\n", skb->len, 0);
 			if (vcc->qos.aal =3D=3D ATM_AAL0)
 				*(unsigned long *) skb->data =3D
-				    ntohl(*(unsigned long *) skb->data);
+					ntohl(*(unsigned long *) skb->data);
 			memset(skb->cb, 0, sizeof(struct eni_skb_prv));
 			vcc->push(vcc, skb);
 			pushed++;
@@ -823,12 +823,12 @@ static int open_rx_second(struct atm_vcc *vcc)
 	writel(0, here+8); /* write, state, count =3D 0 */
 	if (eni_dev->rx_map[vcc->vci])
 		printk(KERN_CRIT DEV_LABEL "(itf %d): BUG - VCI %d already "
-		    "in use\n", vcc->dev->number, vcc->vci);
+		       "in use\n", vcc->dev->number, vcc->vci);
 	eni_dev->rx_map[vcc->vci] =3D vcc; /* now it counts */
 	writel(((vcc->qos.aal !=3D ATM_AAL5 ? MID_MODE_RAW : MID_MODE_AAL5) <=
<
-	    MID_VCI_MODE_SHIFT) | MID_VCI_PTI_MODE |
-	    (((eni_vcc->recv-eni_dev->ram) >> (MID_LOC_SKIP+2)) <<
-	    MID_VCI_LOCATION_SHIFT) | (order << MID_VCI_SIZE_SHIFT), here);
+		MID_VCI_MODE_SHIFT) | MID_VCI_PTI_MODE |
+	       (((eni_vcc->recv-eni_dev->ram) >> (MID_LOC_SKIP+2)) <<
+		MID_VCI_LOCATION_SHIFT) | (order << MID_VCI_SIZE_SHIFT), here);
 	return 0;
 }
=20
@@ -847,7 +847,7 @@ static void close_rx(struct atm_vcc *vcc)
 		here =3D eni_dev->vci+vcc->vci*16;
 		/* block receiver */
 		writel((readl(here) & ~MID_VCI_MODE) | (MID_MODE_TRASH <<
-		    MID_VCI_MODE_SHIFT), here);
+							MID_VCI_MODE_SHIFT), here);
 		/* wait for receiver to become idle */
 		udelay(27);
 		/* discard pending cell */
@@ -867,9 +867,9 @@ static void close_rx(struct atm_vcc *vcc)
 				if (!eni_vcc->rxing) break;
 			}
 			EVENT("drain PDUs (rx %ld, serv %ld)\n", eni_vcc->rxing,
-			    eni_vcc->servicing);
+			      eni_vcc->servicing);
 			printk(KERN_INFO "%d+%d RX left\n", eni_vcc->servicing,
-			    eni_vcc->rxing);
+			       eni_vcc->rxing);
 			schedule();
 			set_current_state(TASK_UNINTERRUPTIBLE);
 		}
@@ -883,9 +883,9 @@ static void close_rx(struct atm_vcc *vcc)
 			tasklet_enable(&eni_dev->task);
 			if (at_end) break;
 			EVENT("drain discard (host 0x%lx, nic 0x%lx)\n",
-			    eni_vcc->rx_pos, tmp);
+			      eni_vcc->rx_pos, tmp);
 			printk(KERN_INFO "draining RX: host 0x%lx, nic 0x%x\n",
-			    eni_vcc->rx_pos, tmp);
+			       eni_vcc->rx_pos, tmp);
 			schedule();
 			set_current_state(TASK_UNINTERRUPTIBLE);
 		}
@@ -905,7 +905,7 @@ static int start_rx(struct atm_dev *dev)
 	eni_dev->rx_map =3D (struct atm_vcc **) get_zeroed_page(GFP_KERNEL);
 	if (!eni_dev->rx_map) {
 		printk(KERN_ERR DEV_LABEL "(itf %d): couldn't get free page\n",
-		    dev->number);
+		       dev->number);
 		free_page((unsigned long) eni_dev->free_list);
 		return -ENOMEM;
 	}
@@ -927,7 +927,7 @@ enum enq_res { enq_ok, enq_next, enq_jam };
=20
=20
 static inline void put_dma(int chan, u32 *dma, int *j, dma_addr_t padd=
r,
-                           u32 size)
+			   u32 size)
 {
 	u32 init, words;
=20
@@ -943,9 +943,9 @@ static inline void put_dma(int chan, u32 *dma, int =
*j, dma_addr_t paddr,
 		init =3D 4-(paddr & 3);
 		if (init > size || size < 7) init =3D size;
 		DPRINTK("put_dma: %lx DMA: %d/%d bytes\n",
-		    (unsigned long) paddr, init, size);
+			(unsigned long) paddr, init, size);
 		dma[(*j)++] =3D MID_DT_BYTE | (init << MID_DMA_COUNT_SHIFT) |
-		    (chan << MID_DMA_CHAN_SHIFT);
+			(chan << MID_DMA_CHAN_SHIFT);
 		dma[(*j)++] =3D paddr;
 		paddr +=3D init;
 		size -=3D init;
@@ -956,9 +956,9 @@ static inline void put_dma(int chan, u32 *dma, int =
*j, dma_addr_t paddr,
 		init =3D 8-((paddr & 31) >> 2);
 		if (init > words) init =3D words;
 		DPRINTK("put_dma: %lx DMA: %d/%d words\n",
-		    (unsigned long) paddr, init, words);
+			(unsigned long) paddr, init, words);
 		dma[(*j)++] =3D MID_DT_WORD | (init << MID_DMA_COUNT_SHIFT) |
-		    (chan << MID_DMA_CHAN_SHIFT);
+			(chan << MID_DMA_CHAN_SHIFT);
 		dma[(*j)++] =3D paddr;
 		paddr +=3D init << 2;
 		words -=3D init;
@@ -966,9 +966,9 @@ static inline void put_dma(int chan, u32 *dma, int =
*j, dma_addr_t paddr,
 #ifdef CONFIG_ATM_ENI_BURST_TX_16W /* may work with some PCI chipsets =
=2E.. */
 	if (words & ~15) {
 		DPRINTK("put_dma: %lx DMA: %d*16/%d words\n",
-		    (unsigned long) paddr, words >> 4, words);
+			(unsigned long) paddr, words >> 4, words);
 		dma[(*j)++] =3D MID_DT_16W | ((words >> 4) << MID_DMA_COUNT_SHIFT)
-		    | (chan << MID_DMA_CHAN_SHIFT);
+			| (chan << MID_DMA_CHAN_SHIFT);
 		dma[(*j)++] =3D paddr;
 		paddr +=3D (words & ~15) << 2;
 		words &=3D 15;
@@ -977,9 +977,9 @@ static inline void put_dma(int chan, u32 *dma, int =
*j, dma_addr_t paddr,
 #ifdef CONFIG_ATM_ENI_BURST_TX_8W /* recommended */
 	if (words & ~7) {
 		DPRINTK("put_dma: %lx DMA: %d*8/%d words\n",
-		    (unsigned long) paddr, words >> 3, words);
+			(unsigned long) paddr, words >> 3, words);
 		dma[(*j)++] =3D MID_DT_8W | ((words >> 3) << MID_DMA_COUNT_SHIFT)
-		    | (chan << MID_DMA_CHAN_SHIFT);
+			| (chan << MID_DMA_CHAN_SHIFT);
 		dma[(*j)++] =3D paddr;
 		paddr +=3D (words & ~7) << 2;
 		words &=3D 7;
@@ -988,9 +988,9 @@ static inline void put_dma(int chan, u32 *dma, int =
*j, dma_addr_t paddr,
 #ifdef CONFIG_ATM_ENI_BURST_TX_4W /* probably useless if TX_8W or TX_1=
6W */
 	if (words & ~3) {
 		DPRINTK("put_dma: %lx DMA: %d*4/%d words\n",
-		    (unsigned long) paddr, words >> 2, words);
+			(unsigned long) paddr, words >> 2, words);
 		dma[(*j)++] =3D MID_DT_4W | ((words >> 2) << MID_DMA_COUNT_SHIFT)
-		    | (chan << MID_DMA_CHAN_SHIFT);
+			| (chan << MID_DMA_CHAN_SHIFT);
 		dma[(*j)++] =3D paddr;
 		paddr +=3D (words & ~3) << 2;
 		words &=3D 3;
@@ -999,9 +999,9 @@ static inline void put_dma(int chan, u32 *dma, int =
*j, dma_addr_t paddr,
 #ifdef CONFIG_ATM_ENI_BURST_TX_2W /* probably useless if TX_4W, TX_8W,=
 ... */
 	if (words & ~1) {
 		DPRINTK("put_dma: %lx DMA: %d*2/%d words\n",
-		    (unsigned long) paddr, words >> 1, words);
+			(unsigned long) paddr, words >> 1, words);
 		dma[(*j)++] =3D MID_DT_2W | ((words >> 1) << MID_DMA_COUNT_SHIFT)
-		    | (chan << MID_DMA_CHAN_SHIFT);
+			| (chan << MID_DMA_CHAN_SHIFT);
 		dma[(*j)++] =3D paddr;
 		paddr +=3D (words & ~1) << 2;
 		words &=3D 1;
@@ -1009,17 +1009,17 @@ static inline void put_dma(int chan, u32 *dma, =
int *j, dma_addr_t paddr,
 #endif
 	if (words) {
 		DPRINTK("put_dma: %lx DMA: %d words\n", (unsigned long) paddr,
-                        words);
+			words);
 		dma[(*j)++] =3D MID_DT_WORD | (words << MID_DMA_COUNT_SHIFT) |
-		    (chan << MID_DMA_CHAN_SHIFT);
+			(chan << MID_DMA_CHAN_SHIFT);
 		dma[(*j)++] =3D paddr;
 		paddr +=3D words << 2;
 	}
 	if (size) {
 		DPRINTK("put_dma: %lx DMA: %d bytes\n", (unsigned long) paddr,
-                        size);
+			size);
 		dma[(*j)++] =3D MID_DT_BYTE | (size << MID_DMA_COUNT_SHIFT) |
-		    (chan << MID_DMA_CHAN_SHIFT);
+			(chan << MID_DMA_CHAN_SHIFT);
 		dma[(*j)++] =3D paddr;
 	}
 }
@@ -1059,7 +1059,7 @@ static enum enq_res do_tx(struct sk_buff *skb)
 #if 0 /* should work now */
 	if ((unsigned long) skb->data & 3)
 		printk(KERN_ERR DEV_LABEL "(itf %d): VCI %d has mis-aligned "
-		    "TX data\n", vcc->dev->number, vcc->vci);
+		       "TX data\n", vcc->dev->number, vcc->vci);
 #endif
 	/*
 	 * Potential future IP speedup: make hard_header big enough to put
@@ -1071,13 +1071,13 @@ static enum enq_res do_tx(struct sk_buff *skb)
 	/* check space in buffer */
 	if (!aal5)
 		size =3D (ATM_CELL_PAYLOAD >> 2)+TX_DESCR_SIZE;
-			/* cell without HEC plus segmentation header (includes
-			   four-byte cell header) */
+	/* cell without HEC plus segmentation header (includes
+	   four-byte cell header) */
 	else {
 		size =3D skb->len+4*AAL5_TRAILER+ATM_CELL_PAYLOAD-1;
-			/* add AAL5 trailer */
+		/* add AAL5 trailer */
 		size =3D ((size-(size % ATM_CELL_PAYLOAD)) >> 2)+TX_DESCR_SIZE;
-						/* add segmentation header */
+		/* add segmentation header */
 	}
 	/*
 	 * Can I move tx_pos by size bytes without getting closer than TX_GAP
@@ -1085,9 +1085,9 @@ static enum enq_res do_tx(struct sk_buff *skb)
 	 * the manual calls "too close".
 	 */
 	if (!NEPMOK(tx->tx_pos, size+TX_GAP,
-	    eni_in(MID_TX_RDPTR(tx->index)), tx->words)) {
+		    eni_in(MID_TX_RDPTR(tx->index)), tx->words)) {
 		DPRINTK(DEV_LABEL "(itf %d): TX full (size %d)\n",
-		    vcc->dev->number, size);
+			vcc->dev->number, size);
 		return enq_next;
 	}
 	/* check DMA */
@@ -1095,44 +1095,44 @@ static enum enq_res do_tx(struct sk_buff *skb)
 	dma_rd =3D eni_in(MID_DMA_RD_TX);
 	dma_size =3D 3; /* JK for descriptor and final fill, plus final size
 			 mis-alignment fix */
-DPRINTK("iovcnt =3D %d\n", skb_shinfo(skb)->nr_frags);
+	DPRINTK("iovcnt =3D %d\n", skb_shinfo(skb)->nr_frags);
 	if (!skb_shinfo(skb)->nr_frags) dma_size +=3D 5;
 	else dma_size +=3D 5*(skb_shinfo(skb)->nr_frags+1);
 	if (dma_size > TX_DMA_BUF) {
 		printk(KERN_CRIT DEV_LABEL "(itf %d): needs %d DMA entries "
-		    "(got only %d)\n", vcc->dev->number, dma_size, TX_DMA_BUF);
+		       "(got only %d)\n", vcc->dev->number, dma_size, TX_DMA_BUF);
 	}
 	DPRINTK("dma_wr is %d, tx_pos is %ld\n", dma_wr, tx->tx_pos);
 	if (dma_wr !=3D dma_rd && ((dma_rd+NR_DMA_TX-dma_wr) & (NR_DMA_TX-1))=
 <
-	     dma_size) {
+	    dma_size) {
 		printk(KERN_WARNING DEV_LABEL "(itf %d): TX DMA full\n",
-                       vcc->dev->number);
+		       vcc->dev->number);
 		return enq_jam;
 	}
 	paddr =3D pci_map_single(eni_dev->pci_dev, skb->data, skb->len,
-                               PCI_DMA_TODEVICE);
+			       PCI_DMA_TODEVICE);
 	ENI_PRV_PADDR(skb) =3D paddr;
 	/* prepare DMA queue entries */
 	j =3D 0;
 	eni_dev->dma[j++] =3D (((tx->tx_pos+TX_DESCR_SIZE) & (tx->words-1)) <=
<
-	     MID_DMA_COUNT_SHIFT) | (tx->index << MID_DMA_CHAN_SHIFT) |
-	     MID_DT_JK;
+			     MID_DMA_COUNT_SHIFT) | (tx->index << MID_DMA_CHAN_SHIFT) |
+		MID_DT_JK;
 	j++;
 	if (!skb_shinfo(skb)->nr_frags)
 		if (aal5) put_dma(tx->index, eni_dev->dma, &j, paddr, skb->len);
 		else put_dma(tx->index, eni_dev->dma, &j, paddr+4, skb->len-4);
 	else {
-                DPRINTK("doing direct send\n"); /* @@@ well, this does=
n't work anyway */
+		DPRINTK("doing direct send\n"); /* @@@ well, this doesn't work anywa=
y */
 		for (i =3D -1; i < skb_shinfo(skb)->nr_frags; i++)
 			if (i =3D=3D -1)
 				put_dma(tx->index, eni_dev->dma, &j, (unsigned long)
-                                        skb->data,
-                                        skb_headlen(skb));
+					skb->data,
+					skb_headlen(skb));
 			else
 				put_dma(tx->index, eni_dev->dma, &j, (unsigned long)
-                                        skb_frag_page(&skb_shinfo(skb)=
->frags[i]) +
+					skb_frag_page(&skb_shinfo(skb)->frags[i]) +
 					skb_shinfo(skb)->frags[i].page_offset,
-                                        skb_frag_size(&skb_shinfo(skb)=
->frags[i]));
+					skb_frag_size(&skb_shinfo(skb)->frags[i]));
 	}
 	if (skb->len & 3) {
 		put_dma(tx->index, eni_dev->dma, &j, eni_dev->zero.dma,
@@ -1140,24 +1140,24 @@ DPRINTK("iovcnt =3D %d\n", skb_shinfo(skb)->nr_=
frags);
 	}
 	/* JK for AAL5 trailer - AAL0 doesn't need it, but who cares ... */
 	eni_dev->dma[j++] =3D (((tx->tx_pos+size) & (tx->words-1)) <<
-	     MID_DMA_COUNT_SHIFT) | (tx->index << MID_DMA_CHAN_SHIFT) |
-	     MID_DMA_END | MID_DT_JK;
+			     MID_DMA_COUNT_SHIFT) | (tx->index << MID_DMA_CHAN_SHIFT) |
+		MID_DMA_END | MID_DT_JK;
 	j++;
 	DPRINTK("DMA at end: %d\n", j);
 	/* store frame */
 	writel((MID_SEG_TX_ID << MID_SEG_ID_SHIFT) |
-	    (aal5 ? MID_SEG_AAL5 : 0) | (tx->prescaler << MID_SEG_PR_SHIFT) |
-	    (tx->resolution << MID_SEG_RATE_SHIFT) |
-	    (size/(ATM_CELL_PAYLOAD/4)), tx->send+tx->tx_pos*4);
+	       (aal5 ? MID_SEG_AAL5 : 0) | (tx->prescaler << MID_SEG_PR_SHIFT=
) |
+	       (tx->resolution << MID_SEG_RATE_SHIFT) |
+	       (size/(ATM_CELL_PAYLOAD/4)), tx->send+tx->tx_pos*4);
 /*printk("dsc =3D 0x%08lx\n",(unsigned long) readl(tx->send+tx->tx_pos=
*4));*/
 	writel((vcc->vci << MID_SEG_VCI_SHIFT) |
-            (aal5 ? 0 : (skb->data[3] & 0xf)) |
-	    (ATM_SKB(skb)->atm_options & ATM_ATMOPT_CLP ? MID_SEG_CLP : 0),
-	    tx->send+((tx->tx_pos+1) & (tx->words-1))*4);
+	       (aal5 ? 0 : (skb->data[3] & 0xf)) |
+	       (ATM_SKB(skb)->atm_options & ATM_ATMOPT_CLP ? MID_SEG_CLP : 0)=
,
+	       tx->send+((tx->tx_pos+1) & (tx->words-1))*4);
 	DPRINTK("size: %d, len:%d\n", size, skb->len);
 	if (aal5)
 		writel(skb->len, tx->send+
-                    ((tx->tx_pos+size-AAL5_TRAILER) & (tx->words-1))*4=
);
+		       ((tx->tx_pos+size-AAL5_TRAILER) & (tx->words-1))*4);
 	j =3D j >> 1;
 	for (i =3D 0; i < j; i++) {
 		writel(eni_dev->dma[i*2], eni_dev->tx_dma+dma_wr*8);
@@ -1171,7 +1171,7 @@ DPRINTK("iovcnt =3D %d\n", skb_shinfo(skb)->nr_fr=
ags);
 	DPRINTK("dma_wr set to %d, tx_pos is now %ld\n", dma_wr, tx->tx_pos);
 	eni_out(dma_wr, MID_DMA_WR_TX);
 	skb_queue_tail(&eni_dev->tx_queue, skb);
-queued++;
+	queued++;
 	return enq_ok;
 }
=20
@@ -1192,7 +1192,7 @@ static void poll_tx(struct atm_dev *dev)
 				if (res =3D=3D enq_ok) continue;
 				DPRINTK("re-queuing TX PDU\n");
 				skb_queue_head(&tx->backlog, skb);
-requeued++;
+				requeued++;
 				if (res =3D=3D enq_jam) return;
 				break;
 			}
@@ -1216,7 +1216,7 @@ static void dequeue_tx(struct atm_dev *dev)
 		tx =3D ENI_VCC(vcc)->tx;
 		NULLCHECK(ENI_VCC(vcc)->tx);
 		DPRINTK("dequeue_tx: next 0x%lx curr 0x%x\n", ENI_PRV_POS(skb),
-		    (unsigned) eni_in(MID_TX_DESCRSTART(tx->index)));
+			(unsigned) eni_in(MID_TX_DESCRSTART(tx->index)));
 		if (ENI_VCC(vcc)->txing < tx->words && ENI_PRV_POS(skb) =3D=3D
 		    eni_in(MID_TX_DESCRSTART(tx->index))) {
 			skb_queue_head(&eni_dev->tx_queue, skb);
@@ -1224,12 +1224,12 @@ static void dequeue_tx(struct atm_dev *dev)
 		}
 		ENI_VCC(vcc)->txing -=3D ENI_PRV_SIZE(skb);
 		pci_unmap_single(eni_dev->pci_dev, ENI_PRV_PADDR(skb), skb->len,
-                                 PCI_DMA_TODEVICE);
+				 PCI_DMA_TODEVICE);
 		if (vcc->pop) vcc->pop(vcc, skb);
 		else dev_kfree_skb_irq(skb);
 		atomic_inc(&vcc->stats->tx);
 		wake_up(&eni_dev->tx_wait);
-dma_complete++;
+		dma_complete++;
 	}
 }
=20
@@ -1245,10 +1245,10 @@ static struct eni_tx *alloc_tx(struct eni_dev *=
eni_dev, int ubr)
=20
=20
 static int comp_tx(struct eni_dev *eni_dev, int *pcr, int reserved, in=
t *pre,
-                   int *res, int unlimited)
+		   int *res, int unlimited)
 {
 	static const int pre_div[] =3D { 4, 16, 128, 2048 };
-	    /* 2^(((x+2)^2-(x+2))/2+1) */
+	/* 2^(((x+2)^2-(x+2))/2+1) */
=20
 	if (unlimited) *pre =3D *res =3D 0;
 	else {
@@ -1282,7 +1282,7 @@ static int comp_tx(struct eni_dev *eni_dev, int *=
pcr, int reserved, int *pre,
=20
=20
 static int reserve_or_set_tx(struct atm_vcc *vcc, struct atm_trafprm *=
txtp,
-                             int set_rsv, int set_shp)
+			     int set_rsv, int set_shp)
 {
 	struct eni_dev *eni_dev =3D ENI_DEV(vcc->dev);
 	struct eni_vcc *eni_vcc =3D ENI_VCC(vcc);
@@ -1296,7 +1296,7 @@ static int reserve_or_set_tx(struct atm_vcc *vcc,=
 struct atm_trafprm *txtp,
 	rate =3D atm_pcr_goal(txtp);
 	ubr =3D txtp->traffic_class =3D=3D ATM_UBR;
 	unlimited =3D ubr && (!rate || rate <=3D -ATM_OC3_PCR ||
-	    rate >=3D ATM_OC3_PCR);
+			    rate >=3D ATM_OC3_PCR);
 	if (!unlimited) {
 		size =3D txtp->max_sdu*eni_dev->tx_mult/100;
 		if (size > MID_MAX_BUF_SIZE && txtp->max_sdu <=3D
@@ -1329,10 +1329,10 @@ static int reserve_or_set_tx(struct atm_vcc *vc=
c, struct atm_trafprm *txtp,
 		skb_queue_head_init(&tx->backlog);
 		for (order =3D 0; size > (1 << (order+10)); order++);
 		eni_out((order << MID_SIZE_SHIFT) |
-                        ((tx->send-eni_dev->ram) >> (MID_LOC_SKIP+2)),
-                        MID_TX_PLACE(tx->index));
+			((tx->send-eni_dev->ram) >> (MID_LOC_SKIP+2)),
+			MID_TX_PLACE(tx->index));
 		tx->tx_pos =3D eni_in(MID_TX_DESCRSTART(tx->index)) &
-		    MID_DESCR_START;
+			MID_DESCR_START;
 	}
 	error =3D comp_tx(eni_dev, &rate, tx->reserved, &pre, &res, unlimited=
);
 	if (!error  && txtp->min_pcr > rate) error =3D -EINVAL;
@@ -1417,7 +1417,7 @@ static void close_tx(struct atm_vcc *vcc)
 		 * a bit ...
 		 */
 		while (eni_in(MID_TX_RDPTR(eni_vcc->tx->index)) !=3D
-		    eni_in(MID_TX_DESCRSTART(eni_vcc->tx->index)))
+		       eni_in(MID_TX_DESCRSTART(eni_vcc->tx->index)))
 			schedule();
 		eni_free_mem(eni_dev, eni_vcc->tx->send, eni_vcc->tx->words << 2);
 		eni_vcc->tx->send =3D NULL;
@@ -1455,12 +1455,12 @@ static int start_tx(struct atm_dev *dev)
=20
 static void foo(void)
 {
-printk(KERN_INFO
-  "tx_complete=3D%d,dma_complete=3D%d,queued=3D%d,requeued=3D%d,sub=3D=
%d,\n"
-  "backlogged=3D%d,rx_enqueued=3D%d,rx_dequeued=3D%d,putting=3D%d,push=
ed=3D%d\n",
-  tx_complete, dma_complete, queued, requeued, submitted, backlogged,
-  rx_enqueued, rx_dequeued, putting, pushed);
-if (eni_boards) printk(KERN_INFO "loss: %ld\n", ENI_DEV(eni_boards)->l=
ost);
+	printk(KERN_INFO
+	       "tx_complete=3D%d,dma_complete=3D%d,queued=3D%d,requeued=3D%d,=
sub=3D%d,\n"
+	       "backlogged=3D%d,rx_enqueued=3D%d,rx_dequeued=3D%d,putting=3D%=
d,pushed=3D%d\n",
+	       tx_complete, dma_complete, queued, requeued, submitted, backlo=
gged,
+	       rx_enqueued, rx_dequeued, putting, pushed);
+	if (eni_boards) printk(KERN_INFO "loss: %ld\n", ENI_DEV(eni_boards)->=
lost);
 }
=20
 #endif
@@ -1471,13 +1471,13 @@ static void bug_int(struct atm_dev *dev, unsign=
ed long reason)
 	DPRINTK(">bug_int\n");
 	if (reason & MID_DMA_ERR_ACK)
 		printk(KERN_CRIT DEV_LABEL "(itf %d): driver error - DMA "
-		    "error\n", dev->number);
+		       "error\n", dev->number);
 	if (reason & MID_TX_IDENT_MISM)
 		printk(KERN_CRIT DEV_LABEL "(itf %d): driver error - ident "
-		    "mismatch\n", dev->number);
+		       "mismatch\n", dev->number);
 	if (reason & MID_TX_DMA_OVFL)
 		printk(KERN_CRIT DEV_LABEL "(itf %d): driver error - DMA "
-		    "overflow\n", dev->number);
+		       "overflow\n", dev->number);
 	EVENT("---dump ends here---\n", 0, 0);
 	printk(KERN_NOTICE "---recent events---\n");
 	event_dump();
@@ -1546,13 +1546,13 @@ static void eni_tasklet(unsigned long data)
 		poll_rx(dev);
 		EVENT("poll_rx done\n", 0, 0);
 	}
- 	if (events & MID_TX_DMA_COMPLETE) {
+	if (events & MID_TX_DMA_COMPLETE) {
 		EVENT("INT: TX DMA COMPLETE\n", 0, 0);
 		dequeue_tx(dev);
 	}
 	if (events & MID_TX_COMPLETE) {
 		EVENT("INT: TX COMPLETE\n", 0, 0);
-tx_complete++;
+		tx_complete++;
 		wake_up(&eni_dev->tx_wait);
 		/* poll_rx ? */
 	}
@@ -1568,27 +1568,27 @@ tx_complete++;
=20
=20
 static char * const media_name[] =3D {
-    "MMF", "SMF", "MMF", "03?", /*  0- 3 */
-    "UTP", "05?", "06?", "07?", /*  4- 7 */
-    "TAXI", "09?", "10?", "11?", /*  8-11 */
-    "12?", "13?", "14?", "15?", /* 12-15 */
-    "MMF", "SMF", "18?", "19?", /* 16-19 */
-    "UTP", "21?", "22?", "23?", /* 20-23 */
-    "24?", "25?", "26?", "27?", /* 24-27 */
-    "28?", "29?", "30?", "31?"  /* 28-31 */
+	"MMF", "SMF", "MMF", "03?", /*	0- 3 */
+	"UTP", "05?", "06?", "07?", /*	4- 7 */
+	"TAXI", "09?", "10?", "11?", /*	 8-11 */
+	"12?", "13?", "14?", "15?", /* 12-15 */
+	"MMF", "SMF", "18?", "19?", /* 16-19 */
+	"UTP", "21?", "22?", "23?", /* 20-23 */
+	"24?", "25?", "26?", "27?", /* 24-27 */
+	"28?", "29?", "30?", "31?"	/* 28-31 */
 };
=20
=20
-#define SET_SEPROM \
-  ({ if (!error && !pci_error) { \
-    pci_error =3D pci_write_config_byte(eni_dev->pci_dev, PCI_TONGA_CT=
RL, tonga); \
-    udelay(10); /* 10 usecs */ \
-  } })
-#define GET_SEPROM \
-  ({ if (!error && !pci_error) { \
-    pci_error =3D pci_read_config_byte(eni_dev->pci_dev, PCI_TONGA_CTR=
L, &tonga); \
-    udelay(10); /* 10 usecs */ \
-  } })
+#define SET_SEPROM							\
+	({ if (!error && !pci_error) {					\
+			pci_error =3D pci_write_config_byte(eni_dev->pci_dev, PCI_TONGA_CTR=
L, tonga); \
+			udelay(10); /* 10 usecs */			\
+		} })
+#define GET_SEPROM							\
+	({ if (!error && !pci_error) {					\
+			pci_error =3D pci_read_config_byte(eni_dev->pci_dev, PCI_TONGA_CTRL=
, &tonga); \
+			udelay(10); /* 10 usecs */			\
+		} })
=20
=20
 static int get_esi_asic(struct atm_dev *dev)
@@ -1616,7 +1616,7 @@ static int get_esi_asic(struct atm_dev *dev)
 		address =3D ((i+SEPROM_ESI_BASE) << 1)+1;
 		for (j =3D 7; j >=3D 0; j--) {
 			tonga =3D (address >> j) & 1 ? tonga | SEPROM_DATA :
-			    tonga & ~SEPROM_DATA;
+				tonga & ~SEPROM_DATA;
 			SET_SEPROM;
 			tonga |=3D SEPROM_CLK;
 			SET_SEPROM;
@@ -1672,7 +1672,7 @@ static int get_esi_asic(struct atm_dev *dev)
 	}
 	if (pci_error) {
 		printk(KERN_ERR DEV_LABEL "(itf %d): error reading ESI "
-		    "(0x%02x)\n", dev->number, pci_error);
+		       "(0x%02x)\n", dev->number, pci_error);
 		error =3D -EIO;
 	}
 	return error;
@@ -1712,18 +1712,18 @@ static int eni_do_init(struct atm_dev *dev)
 	real_base =3D pci_resource_start(pci_dev, 0);
 	eni_dev->irq =3D pci_dev->irq;
 	if ((error =3D pci_write_config_word(pci_dev, PCI_COMMAND,
-	    PCI_COMMAND_MEMORY |
-	    (eni_dev->asic ? PCI_COMMAND_PARITY | PCI_COMMAND_SERR : 0)))) {
+					   PCI_COMMAND_MEMORY |
+					   (eni_dev->asic ? PCI_COMMAND_PARITY | PCI_COMMAND_SERR : 0))))=
 {
 		printk(KERN_ERR DEV_LABEL "(itf %d): can't enable memory "
-		    "(0x%02x)\n", dev->number, error);
+		       "(0x%02x)\n", dev->number, error);
 		return -EIO;
 	}
 	printk(KERN_NOTICE DEV_LABEL "(itf %d): rev.%d,base=3D0x%lx,irq=3D%d,=
",
-	    dev->number, pci_dev->revision, real_base, eni_dev->irq);
+	       dev->number, pci_dev->revision, real_base, eni_dev->irq);
 	if (!(base =3D ioremap_nocache(real_base, MAP_MAX_SIZE))) {
 		printk("\n");
 		printk(KERN_ERR DEV_LABEL "(itf %d): can't set up page "
-		    "mapping\n", dev->number);
+		       "mapping\n", dev->number);
 		return error;
 	}
 	eni_dev->ioaddr =3D base;
@@ -1764,7 +1764,7 @@ static int eni_do_init(struct atm_dev *dev)
 	if (!(eni_in(MID_RES_ID_MCON) & 0x200) !=3D !eni_dev->asic) {
 		printk(")\n");
 		printk(KERN_ERR DEV_LABEL "(itf %d): ERROR - wrong id 0x%x\n",
-		    dev->number, (unsigned) eni_in(MID_RES_ID_MCON));
+		       dev->number, (unsigned) eni_in(MID_RES_ID_MCON));
 		error =3D -EINVAL;
 		goto unmap;
 	}
@@ -1775,8 +1775,8 @@ static int eni_do_init(struct atm_dev *dev)
 		printk("%s%02X", i ? "-" : "", dev->esi[i]);
 	printk(")\n");
 	printk(KERN_NOTICE DEV_LABEL "(itf %d): %s,%s\n", dev->number,
-	    eni_in(MID_RES_ID_MCON) & 0x200 ? "ASIC" : "FPGA",
-	    media_name[eni_in(MID_RES_ID_MCON) & DAUGTHER_ID]);
+	       eni_in(MID_RES_ID_MCON) & 0x200 ? "ASIC" : "FPGA",
+	       media_name[eni_in(MID_RES_ID_MCON) & DAUGTHER_ID]);
=20
 	error =3D suni_init(dev);
 	if (error)
@@ -1809,22 +1809,22 @@ static int eni_start(struct atm_dev *dev)
 	eni_dev =3D ENI_DEV(dev);
 	if (request_irq(eni_dev->irq, &eni_int, IRQF_SHARED, DEV_LABEL, dev))=
 {
 		printk(KERN_ERR DEV_LABEL "(itf %d): IRQ%d is already in use\n",
-		    dev->number, eni_dev->irq);
+		       dev->number, eni_dev->irq);
 		error =3D -EAGAIN;
 		goto out;
 	}
 	pci_set_master(eni_dev->pci_dev);
 	if ((error =3D pci_write_config_word(eni_dev->pci_dev, PCI_COMMAND,
-	    PCI_COMMAND_MEMORY | PCI_COMMAND_MASTER |
-	    (eni_dev->asic ? PCI_COMMAND_PARITY | PCI_COMMAND_SERR : 0)))) {
+					   PCI_COMMAND_MEMORY | PCI_COMMAND_MASTER |
+					   (eni_dev->asic ? PCI_COMMAND_PARITY | PCI_COMMAND_SERR : 0))))=
 {
 		printk(KERN_ERR DEV_LABEL "(itf %d): can't enable memory+"
-		    "master (0x%02x)\n", dev->number, error);
+		       "master (0x%02x)\n", dev->number, error);
 		goto free_irq;
 	}
 	if ((error =3D pci_write_config_byte(eni_dev->pci_dev, PCI_TONGA_CTRL=
,
-                                           END_SWAP_DMA))) {
+					   END_SWAP_DMA))) {
 		printk(KERN_ERR DEV_LABEL "(itf %d): can't set endian swap "
-		    "(0x%02x)\n", dev->number, error);
+		       "(0x%02x)\n", dev->number, error);
 		goto free_irq;
 	}
 	/* determine addresses of internal tables */
@@ -1834,8 +1834,8 @@ static int eni_start(struct atm_dev *dev)
 	eni_dev->service =3D eni_dev->tx_dma+NR_DMA_TX*8;
 	buf =3D eni_dev->service+NR_SERVICE*4;
 	DPRINTK("vci 0x%lx,rx 0x%lx, tx 0x%lx,srv 0x%lx,buf 0x%lx\n",
-	     eni_dev->vci, eni_dev->rx_dma, eni_dev->tx_dma,
-	     eni_dev->service, buf);
+		eni_dev->vci, eni_dev->rx_dma, eni_dev->tx_dma,
+		eni_dev->service, buf);
 	spin_lock_init(&eni_dev->lock);
 	tasklet_init(&eni_dev->task, eni_tasklet, (unsigned long) dev);
 	eni_dev->events =3D 0;
@@ -1843,10 +1843,10 @@ static int eni_start(struct atm_dev *dev)
 	buffer_mem =3D eni_dev->mem - (buf - eni_dev->ram);
 	eni_dev->free_list_size =3D buffer_mem/MID_MIN_BUF_SIZE/2;
 	eni_dev->free_list =3D kmalloc(
-                sizeof(struct eni_free)*(eni_dev->free_list_size+1), G=
=46P_KERNEL);
+		sizeof(struct eni_free)*(eni_dev->free_list_size+1), GFP_KERNEL);
 	if (!eni_dev->free_list) {
 		printk(KERN_ERR DEV_LABEL "(itf %d): couldn't get free page\n",
-		    dev->number);
+		       dev->number);
 		error =3D -ENOMEM;
 		goto free_irq;
 	}
@@ -1855,7 +1855,7 @@ static int eni_start(struct atm_dev *dev)
 	memset_io(eni_dev->vci, 0, 16*NR_VCI); /* clear VCI table */
 	/*
 	 * byte_addr  free (k)
-	 * 0x00000000     512  VCI table
+	 * 0x00000000	  512  VCI table
 	 * 0x00004000	  496  RX DMA
 	 * 0x00005000	  492  TX DMA
 	 * 0x00006000	  488  service list
@@ -1870,9 +1870,9 @@ static int eni_start(struct atm_dev *dev)
 	error =3D dev->phy->start(dev);
 	if (error) goto free_list;
 	eni_out(eni_in(MID_MC_S) | (1 << MID_INT_SEL_SHIFT) |
-	    MID_TX_LOCK_MODE | MID_DMA_ENABLE | MID_TX_ENABLE | MID_RX_ENABLE=
,
-	    MID_MC_S);
-	    /* Tonga uses SBus INTReq1 */
+		MID_TX_LOCK_MODE | MID_DMA_ENABLE | MID_TX_ENABLE | MID_RX_ENABLE,
+		MID_MC_S);
+	/* Tonga uses SBus INTReq1 */
 	(void) eni_in(MID_ISA); /* clear Midway interrupts */
 	return 0;
=20
@@ -1919,7 +1919,7 @@ static int eni_open(struct atm_vcc *vcc)
 	if (vcc->qos.aal !=3D ATM_AAL0 && vcc->qos.aal !=3D ATM_AAL5)
 		return -EINVAL;
 	DPRINTK(DEV_LABEL "(itf %d): open %d.%d\n", vcc->dev->number, vcc->vp=
i,
-                vcc->vci);
+		vcc->vci);
 	if (!test_bit(ATM_VF_PARTIAL, &vcc->flags)) {
 		eni_vcc =3D kmalloc(sizeof(struct eni_vcc), GFP_KERNEL);
 		if (!eni_vcc) return -ENOMEM;
@@ -1980,8 +1980,8 @@ static int eni_change_qos(struct atm_vcc *vcc, st=
ruct atm_qos *qos, int flgs)
 		if (ATM_SKB(skb)->vcc !=3D vcc) continue;
 		dsc =3D tx->send+ENI_PRV_POS(skb)*4;
 		writel((readl(dsc) & ~(MID_SEG_RATE | MID_SEG_PR)) |
-		    (tx->prescaler << MID_SEG_PR_SHIFT) |
-		    (tx->resolution << MID_SEG_RATE_SHIFT), dsc);
+		       (tx->prescaler << MID_SEG_PR_SHIFT) |
+		       (tx->resolution << MID_SEG_RATE_SHIFT), dsc);
 	}
 	tasklet_enable(&eni_dev->task);
 	return 0;
@@ -1995,7 +1995,7 @@ static int eni_ioctl(struct atm_dev *dev, unsigne=
d int cmd, void __user *arg)
 	if (cmd =3D=3D ENI_MEMDUMP) {
 		if (!capable(CAP_NET_ADMIN)) return -EPERM;
 		printk(KERN_WARNING "Please use /proc/atm/" DEV_LABEL ":%d "
-		    "instead of obsolete ioctl ENI_MEMDUMP\n", dev->number);
+		       "instead of obsolete ioctl ENI_MEMDUMP\n", dev->number);
 		dump(dev);
 		return 0;
 	}
@@ -2004,7 +2004,7 @@ static int eni_ioctl(struct atm_dev *dev, unsigne=
d int cmd, void __user *arg)
=20
 		if (!capable(CAP_NET_ADMIN)) return -EPERM;
 		if (copy_from_user(&mult, arg,
-		    sizeof(struct eni_multipliers)))
+				   sizeof(struct eni_multipliers)))
 			return -EFAULT;
 		if ((mult.tx && mult.tx <=3D 100) || (mult.rx &&mult.rx <=3D 100) ||
 		    mult.tx > 65536 || mult.rx > 65536)
@@ -2020,7 +2020,7 @@ static int eni_ioctl(struct atm_dev *dev, unsigne=
d int cmd, void __user *arg)
 			return -EFAULT;
 		if ((ci.vpi_bits =3D=3D 0 || ci.vpi_bits =3D=3D ATM_CI_MAX) &&
 		    (ci.vci_bits =3D=3D NR_VCI_LD || ci.vpi_bits =3D=3D ATM_CI_MAX))
-		    return 0;
+			return 0;
 		return -EINVAL;
 	}
 	if (!dev->phy->ioctl) return -ENOIOCTLCMD;
@@ -2029,14 +2029,14 @@ static int eni_ioctl(struct atm_dev *dev, unsig=
ned int cmd, void __user *arg)
=20
=20
 static int eni_getsockopt(struct atm_vcc *vcc, int level, int optname,
-                          void __user *optval, int optlen)
+			  void __user *optval, int optlen)
 {
 	return -EINVAL;
 }
=20
=20
 static int eni_setsockopt(struct atm_vcc *vcc, int level, int optname,
-                          void __user *optval, unsigned int optlen)
+			  void __user *optval, unsigned int optlen)
 {
 	return -EINVAL;
 }
@@ -2065,20 +2065,20 @@ static int eni_send(struct atm_vcc *vcc, struct=
 sk_buff *skb)
 		}
 		*(u32 *) skb->data =3D htonl(*(u32 *) skb->data);
 	}
-submitted++;
+	submitted++;
 	ATM_SKB(skb)->vcc =3D vcc;
 	tasklet_disable(&ENI_DEV(vcc->dev)->task);
 	res =3D do_tx(skb);
 	tasklet_enable(&ENI_DEV(vcc->dev)->task);
 	if (res =3D=3D enq_ok) return 0;
 	skb_queue_tail(&ENI_VCC(vcc)->tx->backlog, skb);
-backlogged++;
+	backlogged++;
 	tasklet_schedule(&ENI_DEV(vcc->dev)->task);
 	return 0;
 }
=20
 static void eni_phy_put(struct atm_dev *dev, unsigned char value,
-                        unsigned long addr)
+			unsigned long addr)
 {
 	writel(value, ENI_DEV(dev)->phy+addr*4);
 }
@@ -2103,69 +2103,69 @@ static int eni_proc_read(struct atm_dev *dev, l=
off_t *pos, char *page)
 	left =3D *pos;
 	if (!left)
 		return sprintf(page, DEV_LABEL "(itf %d) signal %s, %dkB, "
-		    "%d cps remaining\n", dev->number, signal[(int) dev->signal],
-		    eni_dev->mem >> 10, eni_dev->tx_bw);
+			       "%d cps remaining\n", dev->number, signal[(int) dev->signal]=
,
+			       eni_dev->mem >> 10, eni_dev->tx_bw);
 	if (!--left)
 		return sprintf(page, "%4sBursts: TX"
-#if !defined(CONFIG_ATM_ENI_BURST_TX_16W) && \
-    !defined(CONFIG_ATM_ENI_BURST_TX_8W) && \
-    !defined(CONFIG_ATM_ENI_BURST_TX_4W) && \
-    !defined(CONFIG_ATM_ENI_BURST_TX_2W)
-		    " none"
+#if !defined(CONFIG_ATM_ENI_BURST_TX_16W) &&	\
+	!defined(CONFIG_ATM_ENI_BURST_TX_8W) && \
+	!defined(CONFIG_ATM_ENI_BURST_TX_4W) && \
+	!defined(CONFIG_ATM_ENI_BURST_TX_2W)
+			       " none"
 #endif
 #ifdef CONFIG_ATM_ENI_BURST_TX_16W
-		    " 16W"
+			       " 16W"
 #endif
 #ifdef CONFIG_ATM_ENI_BURST_TX_8W
-		    " 8W"
+			       " 8W"
 #endif
 #ifdef CONFIG_ATM_ENI_BURST_TX_4W
-		    " 4W"
+			       " 4W"
 #endif
 #ifdef CONFIG_ATM_ENI_BURST_TX_2W
-		    " 2W"
+			       " 2W"
 #endif
-		    ", RX"
-#if !defined(CONFIG_ATM_ENI_BURST_RX_16W) && \
-    !defined(CONFIG_ATM_ENI_BURST_RX_8W) && \
-    !defined(CONFIG_ATM_ENI_BURST_RX_4W) && \
-    !defined(CONFIG_ATM_ENI_BURST_RX_2W)
-		    " none"
+			       ", RX"
+#if !defined(CONFIG_ATM_ENI_BURST_RX_16W) &&	\
+	!defined(CONFIG_ATM_ENI_BURST_RX_8W) && \
+	!defined(CONFIG_ATM_ENI_BURST_RX_4W) && \
+	!defined(CONFIG_ATM_ENI_BURST_RX_2W)
+			       " none"
 #endif
 #ifdef CONFIG_ATM_ENI_BURST_RX_16W
-		    " 16W"
+			       " 16W"
 #endif
 #ifdef CONFIG_ATM_ENI_BURST_RX_8W
-		    " 8W"
+			       " 8W"
 #endif
 #ifdef CONFIG_ATM_ENI_BURST_RX_4W
-		    " 4W"
+			       " 4W"
 #endif
 #ifdef CONFIG_ATM_ENI_BURST_RX_2W
-		    " 2W"
+			       " 2W"
 #endif
 #ifndef CONFIG_ATM_ENI_TUNE_BURST
-		    " (default)"
+			       " (default)"
 #endif
-		    "\n", "");
+			       "\n", "");
 	if (!--left)
 		return sprintf(page, "%4sBuffer multipliers: tx %d%%, rx %d%%\n",
-		    "", eni_dev->tx_mult, eni_dev->rx_mult);
+			       "", eni_dev->tx_mult, eni_dev->rx_mult);
 	for (i =3D 0; i < NR_CHAN; i++) {
 		struct eni_tx *tx =3D eni_dev->tx+i;
=20
 		if (!tx->send) continue;
 		if (!--left) {
-			return sprintf(page, "tx[%d]:    0x%ld-0x%ld "
-			    "(%6ld bytes), rsv %d cps, shp %d cps%s\n", i,
-			    (unsigned long) (tx->send - eni_dev->ram),
-			    tx->send-eni_dev->ram+tx->words*4-1, tx->words*4,
-			    tx->reserved, tx->shaping,
-			    tx =3D=3D eni_dev->ubr ? " (UBR)" : "");
+			return sprintf(page, "tx[%d]:	 0x%ld-0x%ld "
+				       "(%6ld bytes), rsv %d cps, shp %d cps%s\n", i,
+				       (unsigned long) (tx->send - eni_dev->ram),
+				       tx->send-eni_dev->ram+tx->words*4-1, tx->words*4,
+				       tx->reserved, tx->shaping,
+				       tx =3D=3D eni_dev->ubr ? " (UBR)" : "");
 		}
 		if (--left) continue;
 		return sprintf(page, "%10sbacklog %u packets\n", "",
-		    skb_queue_len(&tx->backlog));
+			       skb_queue_len(&tx->backlog));
 	}
 	read_lock(&vcc_sklist_lock);
 	for(i =3D 0; i < VCC_HTABLE_SIZE; ++i) {
@@ -2183,15 +2183,15 @@ static int eni_proc_read(struct atm_dev *dev, l=
off_t *pos, char *page)
 			length =3D sprintf(page, "vcc %4d: ", vcc->vci);
 			if (eni_vcc->rx) {
 				length +=3D sprintf(page+length, "0x%ld-0x%ld "
-				    "(%6ld bytes)",
-				    (unsigned long) (eni_vcc->recv - eni_dev->ram),
-				    eni_vcc->recv-eni_dev->ram+eni_vcc->words*4-1,
-				    eni_vcc->words*4);
+						  "(%6ld bytes)",
+						  (unsigned long) (eni_vcc->recv - eni_dev->ram),
+						  eni_vcc->recv-eni_dev->ram+eni_vcc->words*4-1,
+						  eni_vcc->words*4);
 				if (eni_vcc->tx) length +=3D sprintf(page+length, ", ");
 			}
 			if (eni_vcc->tx)
 				length +=3D sprintf(page+length, "tx[%d], txing %d bytes",
-				    eni_vcc->tx->index, eni_vcc->txing);
+						  eni_vcc->tx->index, eni_vcc->txing);
 			page[length] =3D '\n';
 			read_unlock(&vcc_sklist_lock);
 			return length+1;
@@ -2204,9 +2204,9 @@ static int eni_proc_read(struct atm_dev *dev, lof=
f_t *pos, char *page)
=20
 		if (--left) continue;
 		offset =3D (unsigned long) eni_dev->ram+eni_dev->base_diff;
-		return sprintf(page, "free      %p-%p (%6d bytes)\n",
-		    fe->start-offset, fe->start-offset+(1 << fe->order)-1,
-		    1 << fe->order);
+		return sprintf(page, "free	%p-%p (%6d bytes)\n",
+			       fe->start-offset, fe->start-offset+(1 << fe->order)-1,
+			       1 << fe->order);
 	}
 	return 0;
 }
@@ -2320,7 +2320,7 @@ static int __init eni_init(void)
=20
 	if (sizeof(skb->cb) < sizeof(struct eni_skb_prv)) {
 		printk(KERN_ERR "eni_detect: skb->cb is too small (%Zd < %Zd)\n",
-		    sizeof(skb->cb), sizeof(struct eni_skb_prv));
+		       sizeof(skb->cb), sizeof(struct eni_skb_prv));
 		return -EIO;
 	}
 	return pci_register_driver(&eni_driver);
--=20
1.7.10.4
