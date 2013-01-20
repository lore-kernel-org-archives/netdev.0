From: Patrik Karlin <patrik.karlin@gmail.com>
Subject: [PATCH 1/5] drivers: atm: checkpatch.pl fixed coding style errors in eni.c
Date: Mon, 21 Jan 2013 00:12:51 +0100
Message-ID: <1358723575-8345-1-git-send-email-patrik.karlin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Patrik Karlin <patrik.karlin@gmail.com>
To: chas@cmf.nrl.navy.mil
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch removes all space after , errors in eni.c

Signed-off-by: Patrik K=C3=A5rlin <patrik.karlin@gmail.com>
---
 drivers/atm/eni.c |  632 ++++++++++++++++++++++++++-------------------=
--------
 1 file changed, 316 insertions(+), 316 deletions(-)

diff --git a/drivers/atm/eni.c b/drivers/atm/eni.c
index c1eb6fa..6ae0d89 100644
--- a/drivers/atm/eni.c
+++ b/drivers/atm/eni.c
@@ -32,7 +32,7 @@
=20
 #if !defined(__i386__) && !defined(__x86_64__)
 #ifndef ioremap_nocache
-#define ioremap_nocache(X,Y) ioremap(X,Y)
+#define ioremap_nocache(X, Y) ioremap(X, Y)
 #endif=20
 #endif
=20
@@ -62,9 +62,9 @@
=20
=20
 #if 0
-#define DPRINTK(format,args...) printk(KERN_DEBUG format,##args)
+#define DPRINTK(format, args...) printk(KERN_DEBUG format, ##args)
 #else
-#define DPRINTK(format,args...)
+#define DPRINTK(format, args...)
 #endif
=20
=20
@@ -79,7 +79,7 @@
=20
 #define NULLCHECK(x)
=20
-#define EVENT(s,a,b)
+#define EVENT(s, a, b)
=20
=20
 static void event_dump(void)
@@ -96,7 +96,7 @@ static void event_dump(void)
=20
 #define NULLCHECK(x) \
 	if ((unsigned long) (x) < 0x30) \
-		printk(KERN_CRIT #x "=3D=3D0x%lx\n",(unsigned long) (x))
+		printk(KERN_CRIT #x "=3D=3D0x%lx\n", (unsigned long) (x))
=20
 /*
  * Very extensive activity logging. Greatly improves bug detection spe=
ed but
@@ -106,11 +106,11 @@ static void event_dump(void)
 #define EV 64
=20
 static const char *ev[EV];
-static unsigned long ev_a[EV],ev_b[EV];
+static unsigned long ev_a[EV], ev_b[EV];
 static int ec =3D 0;
=20
=20
-static void EVENT(const char *s,unsigned long a,unsigned long b)
+static void EVENT(const char *s, unsigned long a, unsigned long b)
 {
 	ev[ec] =3D s;=20
 	ev_a[ec] =3D a;
@@ -121,12 +121,12 @@ static void EVENT(const char *s,unsigned long a,u=
nsigned long b)
=20
 static void event_dump(void)
 {
-	int n,i;
+	int n, i;
=20
 	for (n =3D 0; n < EV; n++) {
 		i =3D (ec+n) % EV;
 		printk(KERN_NOTICE);
-		printk(ev[i] ? ev[i] : "(null)",ev_a[i],ev_b[i]);
+		printk(ev[i] ? ev[i] : "(null)", ev_a[i], ev_b[i]);
 	}
 }
=20
@@ -141,23 +141,23 @@ static void event_dump(void)
  * xxPMOK operating on a circular buffer of "c" words
  */
=20
-#define NEPJOK(a0,a1,b) \
+#define NEPJOK(a0, a1, b) \
     ((a0) < (a1) ? (b) <=3D (a0) || (b) > (a1) : (b) <=3D (a0) && (b) =
> (a1))
-#define EEPJOK(a0,a1,b) \
+#define EEPJOK(a0, a1, b) \
     ((a0) < (a1) ? (b) < (a0) || (b) >=3D (a1) : (b) < (a0) && (b) >=3D=
 (a1))
-#define NEPMOK(a0,d,b,c) NEPJOK(a0,(a0+d) & (c-1),b)
-#define EEPMOK(a0,d,b,c) EEPJOK(a0,(a0+d) & (c-1),b)
+#define NEPMOK(a0, d, b, c) NEPJOK(a0, (a0+d) & (c-1), b)
+#define EEPMOK(a0, d, b, c) EEPJOK(a0, (a0+d) & (c-1), b)
=20
=20
-static int tx_complete =3D 0,dma_complete =3D 0,queued =3D 0,requeued =
=3D 0,
-  backlogged =3D 0,rx_enqueued =3D 0,rx_dequeued =3D 0,pushed =3D 0,su=
bmitted =3D 0,
+static int tx_complete =3D 0, dma_complete =3D 0, queued =3D 0, requeu=
ed =3D 0,
+  backlogged =3D 0, rx_enqueued =3D 0, rx_dequeued =3D 0, pushed =3D 0=
, submitted =3D 0,
   putting =3D 0;
=20
 static struct atm_dev *eni_boards =3D NULL;
=20
 /* Read/write registers on card */
 #define eni_in(r)	readl(eni_dev->reg+(r)*4)
-#define eni_out(v,r)	writel((v),eni_dev->reg+(r)*4)
+#define eni_out(v, r)	writel((v), eni_dev->reg+(r)*4)
=20
=20
 /*-------------------------------- utilities -------------------------=
-------*/
@@ -168,7 +168,7 @@ static void dump_mem(struct eni_dev *eni_dev)
 	int i;
=20
 	for (i =3D 0; i < eni_dev->free_len; i++)
-		printk(KERN_DEBUG "  %d: %p %d\n",i,
+		printk(KERN_DEBUG "  %d: %p %d\n", i,
 		    eni_dev->free_list[i].start,
 		    1 << eni_dev->free_list[i].order);
 }
@@ -186,12 +186,12 @@ static void dump(struct atm_dev *dev)
 	printk(KERN_NOTICE "TX buffers\n");
 	for (i =3D 0; i < NR_CHAN; i++)
 		if (eni_dev->tx[i].send)
-			printk(KERN_NOTICE "  TX %d @ %p: %ld\n",i,
-			    eni_dev->tx[i].send,eni_dev->tx[i].words*4);
+			printk(KERN_NOTICE "  TX %d @ %p: %ld\n", i,
+			    eni_dev->tx[i].send, eni_dev->tx[i].words*4);
 	printk(KERN_NOTICE "RX buffers\n");
 	for (i =3D 0; i < 1024; i++)
 		if (eni_dev->rx_map[i] && ENI_VCC(eni_dev->rx_map[i])->rx)
-			printk(KERN_NOTICE "  RX %d @ %p: %ld\n",i,
+			printk(KERN_NOTICE "  RX %d @ %p: %ld\n", i,
 			    ENI_VCC(eni_dev->rx_map[i])->recv,
 			    ENI_VCC(eni_dev->rx_map[i])->words*4);
 	printk(KERN_NOTICE "----\n");
@@ -202,16 +202,16 @@ static void eni_put_free(struct eni_dev *eni_dev,=
 void __iomem *start,
     unsigned long size)
 {
 	struct eni_free *list;
-	int len,order;
+	int len, order;
=20
-	DPRINTK("init 0x%lx+%ld(0x%lx)\n",start,size,size);
+	DPRINTK("init 0x%lx+%ld(0x%lx)\n", start, size, size);
 	start +=3D eni_dev->base_diff;
 	list =3D eni_dev->free_list;
 	len =3D eni_dev->free_len;
 	while (size) {
 		if (len >=3D eni_dev->free_list_size) {
 			printk(KERN_CRIT "eni_put_free overflow (%p,%ld)\n",
-			    start,size);
+			    start, size);
 			break;
 		}
 		for (order =3D 0; !(((unsigned long)start | size) & (1 << order)); o=
rder++);
@@ -235,14 +235,14 @@ static void __iomem *eni_alloc_mem(struct eni_dev=
 *eni_dev, unsigned long *size)
 {
 	struct eni_free *list;
 	void __iomem *start;
-	int len,i,order,best_order,index;
+	int len, i, order, best_order, index;
=20
 	list =3D eni_dev->free_list;
 	len =3D eni_dev->free_len;
 	if (*size < MID_MIN_BUF_SIZE) *size =3D MID_MIN_BUF_SIZE;
 	if (*size > MID_MAX_BUF_SIZE) return NULL;
 	for (order =3D 0; (1 << order) < *size; order++);
-	DPRINTK("trying: %ld->%d\n",*size,order);
+	DPRINTK("trying: %ld->%d\n", *size, order);
 	best_order =3D 65; /* we don't have more than 2^64 of anything ... */
 	index =3D 0; /* silence GCC */
 	for (i =3D 0; i < len; i++)
@@ -260,9 +260,9 @@ static void __iomem *eni_alloc_mem(struct eni_dev *=
eni_dev, unsigned long *size)
 	list[index] =3D list[--len];
 	eni_dev->free_len =3D len;
 	*size =3D 1 << order;
-	eni_put_free(eni_dev,start+*size,(1 << best_order)-*size);
-	DPRINTK("%ld bytes (order %d) at 0x%lx\n",*size,order,start);
-	memset_io(start,0,*size);       /* never leak data */
+	eni_put_free(eni_dev, start+*size, (1 << best_order)-*size);
+	DPRINTK("%ld bytes (order %d) at 0x%lx\n", *size, order, start);
+	memset_io(start, 0, *size);       /* never leak data */
 	/*dump_mem(eni_dev);*/
 	return start;
 }
@@ -272,18 +272,18 @@ static void eni_free_mem(struct eni_dev *eni_dev,=
 void __iomem *start,
     unsigned long size)
 {
 	struct eni_free *list;
-	int len,i,order;
+	int len, i, order;
=20
 	start +=3D eni_dev->base_diff;
 	list =3D eni_dev->free_list;
 	len =3D eni_dev->free_len;
 	for (order =3D -1; size; order++) size >>=3D 1;
-	DPRINTK("eni_free_mem: %p+0x%lx (order %d)\n",start,size,order);
+	DPRINTK("eni_free_mem: %p+0x%lx (order %d)\n", start, size, order);
 	for (i =3D 0; i < len; i++)
 		if (((unsigned long) list[i].start) =3D=3D ((unsigned long)start^(1 =
<< order)) &&
 		    list[i].order =3D=3D order) {
-			DPRINTK("match[%d]: 0x%lx/0x%lx(0x%x), %d/%d\n",i,
-			    list[i].start,start,1 << order,list[i].order,order);
+			DPRINTK("match[%d]: 0x%lx/0x%lx(0x%x), %d/%d\n", i,
+			    list[i].start, start, 1 << order, list[i].order, order);
 			list[i] =3D list[--len];
 			start =3D (void __iomem *) ((unsigned long) start & ~(unsigned long=
) (1 << order));
 			order++;
@@ -291,7 +291,7 @@ static void eni_free_mem(struct eni_dev *eni_dev, v=
oid __iomem *start,
 			continue;
 		}
 	if (len >=3D eni_dev->free_list_size) {
-		printk(KERN_ALERT "eni_free_mem overflow (%p,%d)\n",start,
+		printk(KERN_ALERT "eni_free_mem overflow (%p,%d)\n", start,
 		    order);
 		return;
 	}
@@ -318,19 +318,19 @@ static void rx_ident_err(struct atm_vcc *vcc)
 	eni_dev =3D ENI_DEV(dev);
 	/* immediately halt adapter */
 	eni_out(eni_in(MID_MC_S) &
-	    ~(MID_DMA_ENABLE | MID_TX_ENABLE | MID_RX_ENABLE),MID_MC_S);
+	    ~(MID_DMA_ENABLE | MID_TX_ENABLE | MID_RX_ENABLE), MID_MC_S);
 	/* dump useful information */
 	eni_vcc =3D ENI_VCC(vcc);
 	printk(KERN_ALERT DEV_LABEL "(itf %d): driver error - RX ident "
-	    "mismatch\n",dev->number);
-	printk(KERN_ALERT "  VCI %d, rxing %d, words %ld\n",vcc->vci,
-	    eni_vcc->rxing,eni_vcc->words);
+	    "mismatch\n", dev->number);
+	printk(KERN_ALERT "  VCI %d, rxing %d, words %ld\n", vcc->vci,
+	    eni_vcc->rxing, eni_vcc->words);
 	printk(KERN_ALERT "  host descr 0x%lx, rx pos 0x%lx, descr value "
-	    "0x%x\n",eni_vcc->descr,eni_vcc->rx_pos,
+	    "0x%x\n", eni_vcc->descr, eni_vcc->rx_pos,
 	    (unsigned) readl(eni_vcc->recv+eni_vcc->descr*4));
-	printk(KERN_ALERT "  last %p, servicing %d\n",eni_vcc->last,
+	printk(KERN_ALERT "  last %p, servicing %d\n", eni_vcc->last,
 	    eni_vcc->servicing);
-	EVENT("---dump ends here---\n",0,0);
+	EVENT("---dump ends here---\n", 0, 0);
 	printk(KERN_NOTICE "---recent events---\n");
 	event_dump();
 	ENI_DEV(dev)->fast =3D NULL; /* really stop it */
@@ -339,28 +339,28 @@ static void rx_ident_err(struct atm_vcc *vcc)
 }
=20
=20
-static int do_rx_dma(struct atm_vcc *vcc,struct sk_buff *skb,
-    unsigned long skip,unsigned long size,unsigned long eff)
+static int do_rx_dma(struct atm_vcc *vcc, struct sk_buff *skb,
+                     unsigned long skip, unsigned long size, unsigned =
long eff)
 {
 	struct eni_dev *eni_dev;
 	struct eni_vcc *eni_vcc;
-	u32 dma_rd,dma_wr;
+	u32 dma_rd, dma_wr;
 	u32 dma[RX_DMA_BUF*2];
 	dma_addr_t paddr;
 	unsigned long here;
-	int i,j;
+	int i, j;
=20
 	eni_dev =3D ENI_DEV(vcc->dev);
 	eni_vcc =3D ENI_VCC(vcc);
 	paddr =3D 0; /* GCC, shut up */
 	if (skb) {
-		paddr =3D pci_map_single(eni_dev->pci_dev,skb->data,skb->len,
+		paddr =3D pci_map_single(eni_dev->pci_dev, skb->data, skb->len,
 		    PCI_DMA_FROMDEVICE);
 		ENI_PRV_PADDR(skb) =3D paddr;
 		if (paddr & 3)
 			printk(KERN_CRIT DEV_LABEL "(itf %d): VCI %d has "
-			    "mis-aligned RX data (0x%lx)\n",vcc->dev->number,
-			    vcc->vci,(unsigned long) paddr);
+			    "mis-aligned RX data (0x%lx)\n", vcc->dev->number,
+			    vcc->vci, (unsigned long) paddr);
 		ENI_PRV_SIZE(skb) =3D size+skip;
 		    /* PDU plus descriptor */
 		ATM_SKB(skb)->vcc =3D vcc;
@@ -380,7 +380,7 @@ static int do_rx_dma(struct atm_vcc *vcc,struct sk_=
buff *skb,
 		if (!size) {
 			DPRINTK("strange things happen ...\n");
 			EVENT("strange things happen ... (skip=3D%ld,eff=3D%ld)\n",
-			    size,eff);
+			    size, eff);
 		}
 		words =3D eff;
 		if (paddr & 15) {
@@ -457,42 +457,42 @@ static int do_rx_dma(struct atm_vcc *vcc,struct s=
k_buff *skb,
 	 * Can I move the dma_wr pointer by 2j+1 positions without overwritin=
g
 	 * data that hasn't been read (position of dma_rd) yet ?
 	 */
-	if (!NEPMOK(dma_wr,j+j+1,dma_rd,NR_DMA_RX)) { /* @@@ +1 is ugly */
+	if (!NEPMOK(dma_wr, j+j+1, dma_rd, NR_DMA_RX)) { /* @@@ +1 is ugly */
 		printk(KERN_WARNING DEV_LABEL "(itf %d): RX DMA full\n",
 		    vcc->dev->number);
 		goto trouble;
 	}
         for (i =3D 0; i < j; i++) {
-		writel(dma[i*2],eni_dev->rx_dma+dma_wr*8);
-		writel(dma[i*2+1],eni_dev->rx_dma+dma_wr*8+4);
+		writel(dma[i*2], eni_dev->rx_dma+dma_wr*8);
+		writel(dma[i*2+1], eni_dev->rx_dma+dma_wr*8+4);
 		dma_wr =3D (dma_wr+1) & (NR_DMA_RX-1);
         }
 	if (skb) {
 		ENI_PRV_POS(skb) =3D eni_vcc->descr+size+1;
-		skb_queue_tail(&eni_dev->rx_queue,skb);
+		skb_queue_tail(&eni_dev->rx_queue, skb);
 		eni_vcc->last =3D skb;
 rx_enqueued++;
 	}
 	eni_vcc->descr =3D here;
-	eni_out(dma_wr,MID_DMA_WR_RX);
+	eni_out(dma_wr, MID_DMA_WR_RX);
 	return 0;
=20
 trouble:
 	if (paddr)
-		pci_unmap_single(eni_dev->pci_dev,paddr,skb->len,
+		pci_unmap_single(eni_dev->pci_dev, paddr, skb->len,
 		    PCI_DMA_FROMDEVICE);
 	if (skb) dev_kfree_skb_irq(skb);
 	return -1;
 }
=20
=20
-static void discard(struct atm_vcc *vcc,unsigned long size)
+static void discard(struct atm_vcc *vcc, unsigned long size)
 {
 	struct eni_vcc *eni_vcc;
=20
 	eni_vcc =3D ENI_VCC(vcc);
-	EVENT("discard (size=3D%ld)\n",size,0);
-	while (do_rx_dma(vcc,NULL,1,size,0)) EVENT("BUSY LOOP",0,0);
+	EVENT("discard (size=3D%ld)\n", size, 0);
+	while (do_rx_dma(vcc, NULL, 1, size, 0)) EVENT("BUSY LOOP", 0, 0);
 	    /* could do a full fallback, but that might be more expensive */
 	if (eni_vcc->rxing) ENI_PRV_POS(eni_vcc->last) +=3D size+1;
 	else eni_vcc->rx_pos =3D (eni_vcc->rx_pos+size+1) & (eni_vcc->words-1=
);
@@ -527,15 +527,15 @@ static int rx_aal0(struct atm_vcc *vcc)
 	else {
 		length =3D ATM_CELL_SIZE-1; /* no HEC */
 	}
-	skb =3D length ? atm_alloc_charge(vcc,length,GFP_ATOMIC) : NULL;
+	skb =3D length ? atm_alloc_charge(vcc, length, GFP_ATOMIC) : NULL;
 	if (!skb) {
-		discard(vcc,length >> 2);
+		discard(vcc, length >> 2);
 		return 0;
 	}
-	skb_put(skb,length);
+	skb_put(skb, length);
 	skb->tstamp =3D eni_vcc->timestamp;
-	DPRINTK("got len %ld\n",length);
-	if (do_rx_dma(vcc,skb,1,length >> 2,length >> 2)) return 1;
+	DPRINTK("got len %ld\n", length);
+	if (do_rx_dma(vcc, skb, 1, length >> 2, length >> 2)) return 1;
 	eni_vcc->rxing++;
 	return 0;
 }
@@ -545,10 +545,10 @@ static int rx_aal5(struct atm_vcc *vcc)
 {
 	struct eni_vcc *eni_vcc;
 	unsigned long descr;
-	unsigned long size,eff,length;
+	unsigned long size, eff, length;
 	struct sk_buff *skb;
=20
-	EVENT("rx_aal5\n",0,0);
+	EVENT("rx_aal5\n", 0, 0);
 	DPRINTK(">rx_aal5\n");
 	eni_vcc =3D ENI_VCC(vcc);
 	descr =3D readl(eni_vcc->recv+eni_vcc->descr*4);
@@ -558,7 +558,7 @@ static int rx_aal5(struct atm_vcc *vcc)
 	}
 	if (descr & (MID_RED_T | MID_RED_CRC_ERR)) {
 		if (descr & MID_RED_T) {
-			EVENT("empty cell (descr=3D0x%lx)\n",descr,0);
+			EVENT("empty cell (descr=3D0x%lx)\n", descr, 0);
 			DPRINTK(DEV_LABEL "(itf %d): trashing empty cell\n",
 			    vcc->dev->number);
 			size =3D 0;
@@ -573,7 +573,7 @@ static int rx_aal5(struct atm_vcc *vcc)
 				silence =3D (jiffies+2*HZ)|1;
 			}
 			size =3D (descr & MID_RED_COUNT)*(ATM_CELL_PAYLOAD >> 2);
-			EVENT("CRC error (descr=3D0x%lx,size=3D%ld)\n",descr,
+			EVENT("CRC error (descr=3D0x%lx,size=3D%ld)\n", descr,
 			    size);
 		}
 		eff =3D length =3D 0;
@@ -581,30 +581,30 @@ static int rx_aal5(struct atm_vcc *vcc)
 	}
 	else {
 		size =3D (descr & MID_RED_COUNT)*(ATM_CELL_PAYLOAD >> 2);
-		DPRINTK("size=3D%ld\n",size);
+		DPRINTK("size=3D%ld\n", size);
 		length =3D readl(eni_vcc->recv+(((eni_vcc->descr+size-1) &
 		    (eni_vcc->words-1)))*4) & 0xffff;
 				/* -trailer(2)+header(1) */
 		if (length && length <=3D (size << 2)-8 && length <=3D
 		  ATM_MAX_AAL5_PDU) eff =3D (length+3) >> 2;
 		else {				 /* ^ trailer length (8) */
-			EVENT("bad PDU (descr=3D0x08%lx,length=3D%ld)\n",descr,
-			    length);
+			EVENT("bad PDU (descr=3D0x08%lx,length=3D%ld)\n", descr,
+                              length);
 			printk(KERN_ERR DEV_LABEL "(itf %d): bad AAL5 PDU "
 			    "(VCI=3D%d,length=3D%ld,size=3D%ld (descr 0x%lx))\n",
-			    vcc->dev->number,vcc->vci,length,size << 2,descr);
+			    vcc->dev->number, vcc->vci, length, size << 2, descr);
 			length =3D eff =3D 0;
 			atomic_inc(&vcc->stats->rx_err);
 		}
 	}
-	skb =3D eff ? atm_alloc_charge(vcc,eff << 2,GFP_ATOMIC) : NULL;
+	skb =3D eff ? atm_alloc_charge(vcc, eff << 2, GFP_ATOMIC) : NULL;
 	if (!skb) {
-		discard(vcc,size);
+		discard(vcc, size);
 		return 0;
 	}
-	skb_put(skb,length);
-	DPRINTK("got len %ld\n",length);
-	if (do_rx_dma(vcc,skb,1,size,eff)) return 1;
+	skb_put(skb, length);
+	DPRINTK("got len %ld\n", length);
+	if (do_rx_dma(vcc, skb, 1, size, eff)) return 1;
 	eni_vcc->rxing++;
 	return 0;
 }
@@ -618,29 +618,29 @@ static inline int rx_vcc(struct atm_vcc *vcc)
=20
 	eni_vcc =3D ENI_VCC(vcc);
 	vci_dsc =3D ENI_DEV(vcc->dev)->vci+vcc->vci*16;
-	EVENT("rx_vcc(1)\n",0,0);
+	EVENT("rx_vcc(1)\n", 0, 0);
 	while (eni_vcc->descr !=3D (tmp =3D (readl(vci_dsc+4) & MID_VCI_DESCR=
) >>
 	    MID_VCI_DESCR_SHIFT)) {
 		EVENT("rx_vcc(2: host dsc=3D0x%lx, nic dsc=3D0x%lx)\n",
-		    eni_vcc->descr,tmp);
-		DPRINTK("CB_DESCR %ld REG_DESCR %d\n",ENI_VCC(vcc)->descr,
+		    eni_vcc->descr, tmp);
+		DPRINTK("CB_DESCR %ld REG_DESCR %d\n", ENI_VCC(vcc)->descr,
 		    (((unsigned) readl(vci_dsc+4) & MID_VCI_DESCR) >>
 		    MID_VCI_DESCR_SHIFT));
 		if (ENI_VCC(vcc)->rx(vcc)) return 1;
 	}
 	/* clear IN_SERVICE flag */
-	writel(readl(vci_dsc) & ~MID_VCI_IN_SERVICE,vci_dsc);
+	writel(readl(vci_dsc) & ~MID_VCI_IN_SERVICE, vci_dsc);
 	/*
 	 * If new data has arrived between evaluating the while condition and
 	 * clearing IN_SERVICE, we wouldn't be notified until additional data
 	 * follows. So we have to loop again to be sure.
 	 */
-	EVENT("rx_vcc(3)\n",0,0);
+	EVENT("rx_vcc(3)\n", 0, 0);
 	while (ENI_VCC(vcc)->descr !=3D (tmp =3D (readl(vci_dsc+4) & MID_VCI_=
DESCR)
 	    >> MID_VCI_DESCR_SHIFT)) {
 		EVENT("rx_vcc(4: host dsc=3D0x%lx, nic dsc=3D0x%lx)\n",
-		    eni_vcc->descr,tmp);
-		DPRINTK("CB_DESCR %ld REG_DESCR %d\n",ENI_VCC(vcc)->descr,
+		    eni_vcc->descr, tmp);
+		DPRINTK("CB_DESCR %ld REG_DESCR %d\n", ENI_VCC(vcc)->descr,
 		    (((unsigned) readl(vci_dsc+4) & MID_VCI_DESCR) >>
 		    MID_VCI_DESCR_SHIFT));
 		if (ENI_VCC(vcc)->rx(vcc)) return 1;
@@ -656,7 +656,7 @@ static void poll_rx(struct atm_dev *dev)
=20
 	eni_dev =3D ENI_DEV(dev);
 	while ((curr =3D eni_dev->fast)) {
-		EVENT("poll_rx.fast\n",0,0);
+		EVENT("poll_rx.fast\n", 0, 0);
 		if (rx_vcc(curr)) return;
 		eni_dev->fast =3D ENI_VCC(curr)->next;
 		ENI_VCC(curr)->next =3D ENI_VCC_NOS;
@@ -664,7 +664,7 @@ static void poll_rx(struct atm_dev *dev)
 		ENI_VCC(curr)->servicing--;
 	}
 	while ((curr =3D eni_dev->slow)) {
-		EVENT("poll_rx.slow\n",0,0);
+		EVENT("poll_rx.slow\n", 0, 0);
 		if (rx_vcc(curr)) return;
 		eni_dev->slow =3D ENI_VCC(curr)->next;
 		ENI_VCC(curr)->next =3D ENI_VCC_NOS;
@@ -688,14 +688,14 @@ static void get_service(struct atm_dev *dev)
 		vcc =3D eni_dev->rx_map[vci & 1023];
 		if (!vcc) {
 			printk(KERN_CRIT DEV_LABEL "(itf %d): VCI %ld not "
-			    "found\n",dev->number,vci);
+			    "found\n", dev->number, vci);
 			continue; /* nasty but we try to go on anyway */
 			/* @@@ nope, doesn't work */
 		}
-		EVENT("getting from service\n",0,0);
+		EVENT("getting from service\n", 0, 0);
 		if (ENI_VCC(vcc)->next !=3D ENI_VCC_NOS) {
-			EVENT("double service\n",0,0);
-			DPRINTK("Grr, servicing VCC %ld twice\n",vci);
+			EVENT("double service\n", 0, 0);
+			DPRINTK("Grr, servicing VCC %ld twice\n", vci);
 			continue;
 		}
 		ENI_VCC(vcc)->timestamp =3D ktime_get_real();
@@ -734,37 +734,37 @@ static void dequeue_rx(struct atm_dev *dev)
 		if (!skb) {
 			if (first) {
 				DPRINTK(DEV_LABEL "(itf %d): RX but not "
-				    "rxing\n",dev->number);
-				EVENT("nothing to dequeue\n",0,0);
+				    "rxing\n", dev->number);
+				EVENT("nothing to dequeue\n", 0, 0);
 			}
 			break;
 		}
-		EVENT("dequeued (size=3D%ld,pos=3D0x%lx)\n",ENI_PRV_SIZE(skb),
-		    ENI_PRV_POS(skb));
+		EVENT("dequeued (size=3D%ld,pos=3D0x%lx)\n", ENI_PRV_SIZE(skb),
+                      ENI_PRV_POS(skb));
 rx_dequeued++;
 		vcc =3D ATM_SKB(skb)->vcc;
 		eni_vcc =3D ENI_VCC(vcc);
 		first =3D 0;
 		vci_dsc =3D eni_dev->vci+vcc->vci*16;
-		if (!EEPMOK(eni_vcc->rx_pos,ENI_PRV_SIZE(skb),
+		if (!EEPMOK(eni_vcc->rx_pos, ENI_PRV_SIZE(skb),
 		    (readl(vci_dsc+4) & MID_VCI_READ) >> MID_VCI_READ_SHIFT,
 		    eni_vcc->words)) {
-			EVENT("requeuing\n",0,0);
-			skb_queue_head(&eni_dev->rx_queue,skb);
+			EVENT("requeuing\n", 0, 0);
+			skb_queue_head(&eni_dev->rx_queue, skb);
 			break;
 		}
 		eni_vcc->rxing--;
 		eni_vcc->rx_pos =3D ENI_PRV_POS(skb) & (eni_vcc->words-1);
-		pci_unmap_single(eni_dev->pci_dev,ENI_PRV_PADDR(skb),skb->len,
-		    PCI_DMA_TODEVICE);
+		pci_unmap_single(eni_dev->pci_dev, ENI_PRV_PADDR(skb), skb->len,
+                                 PCI_DMA_TODEVICE);
 		if (!skb->len) dev_kfree_skb_irq(skb);
 		else {
-			EVENT("pushing (len=3D%ld)\n",skb->len,0);
+			EVENT("pushing (len=3D%ld)\n", skb->len, 0);
 			if (vcc->qos.aal =3D=3D ATM_AAL0)
 				*(unsigned long *) skb->data =3D
 				    ntohl(*(unsigned long *) skb->data);
-			memset(skb->cb,0,sizeof(struct eni_skb_prv));
-			vcc->push(vcc,skb);
+			memset(skb->cb, 0, sizeof(struct eni_skb_prv));
+			vcc->push(vcc, skb);
 			pushed++;
 		}
 		atomic_inc(&vcc->stats->rx);
@@ -788,8 +788,8 @@ static int open_rx_first(struct atm_vcc *vcc)
 	if (size > MID_MAX_BUF_SIZE && vcc->qos.rxtp.max_sdu <=3D
 	    MID_MAX_BUF_SIZE)
 		size =3D MID_MAX_BUF_SIZE;
-	eni_vcc->recv =3D eni_alloc_mem(eni_dev,&size);
-	DPRINTK("rx at 0x%lx\n",eni_vcc->recv);
+	eni_vcc->recv =3D eni_alloc_mem(eni_dev, &size);
+	DPRINTK("rx at 0x%lx\n", eni_vcc->recv);
 	eni_vcc->words =3D size >> 2;
 	if (!eni_vcc->recv) return -ENOBUFS;
 	eni_vcc->rx =3D vcc->qos.aal =3D=3D ATM_AAL5 ? rx_aal5 : rx_aal0;
@@ -816,26 +816,26 @@ static int open_rx_second(struct atm_vcc *vcc)
 	if (!eni_vcc->rx) return 0;
 	/* set up VCI descriptor */
 	here =3D eni_dev->vci+vcc->vci*16;
-	DPRINTK("loc 0x%x\n",(unsigned) (eni_vcc->recv-eni_dev->ram)/4);
+	DPRINTK("loc 0x%x\n", (unsigned) (eni_vcc->recv-eni_dev->ram)/4);
 	size =3D eni_vcc->words >> 8;
 	for (order =3D -1; size; order++) size >>=3D 1;
-	writel(0,here+4); /* descr, read =3D 0 */
-	writel(0,here+8); /* write, state, count =3D 0 */
+	writel(0, here+4); /* descr, read =3D 0 */
+	writel(0, here+8); /* write, state, count =3D 0 */
 	if (eni_dev->rx_map[vcc->vci])
 		printk(KERN_CRIT DEV_LABEL "(itf %d): BUG - VCI %d already "
-		    "in use\n",vcc->dev->number,vcc->vci);
+		    "in use\n", vcc->dev->number, vcc->vci);
 	eni_dev->rx_map[vcc->vci] =3D vcc; /* now it counts */
 	writel(((vcc->qos.aal !=3D ATM_AAL5 ? MID_MODE_RAW : MID_MODE_AAL5) <=
<
 	    MID_VCI_MODE_SHIFT) | MID_VCI_PTI_MODE |
 	    (((eni_vcc->recv-eni_dev->ram) >> (MID_LOC_SKIP+2)) <<
-	    MID_VCI_LOCATION_SHIFT) | (order << MID_VCI_SIZE_SHIFT),here);
+	    MID_VCI_LOCATION_SHIFT) | (order << MID_VCI_SIZE_SHIFT), here);
 	return 0;
 }
=20
=20
 static void close_rx(struct atm_vcc *vcc)
 {
-	DECLARE_WAITQUEUE(wait,current);
+	DECLARE_WAITQUEUE(wait, current);
 	void __iomem *here;
 	struct eni_dev *eni_dev;
 	struct eni_vcc *eni_vcc;
@@ -847,17 +847,17 @@ static void close_rx(struct atm_vcc *vcc)
 		here =3D eni_dev->vci+vcc->vci*16;
 		/* block receiver */
 		writel((readl(here) & ~MID_VCI_MODE) | (MID_MODE_TRASH <<
-		    MID_VCI_MODE_SHIFT),here);
+		    MID_VCI_MODE_SHIFT), here);
 		/* wait for receiver to become idle */
 		udelay(27);
 		/* discard pending cell */
-		writel(readl(here) & ~MID_VCI_IN_SERVICE,here);
+		writel(readl(here) & ~MID_VCI_IN_SERVICE, here);
 		/* don't accept any new ones */
 		eni_dev->rx_map[vcc->vci] =3D NULL;
 		/* wait for RX queue to drain */
 		DPRINTK("eni_close: waiting for RX ...\n");
-		EVENT("RX closing\n",0,0);
-		add_wait_queue(&eni_dev->rx_wait,&wait);
+		EVENT("RX closing\n", 0, 0);
+		add_wait_queue(&eni_dev->rx_wait, &wait);
 		set_current_state(TASK_UNINTERRUPTIBLE);
 		barrier();
 		for (;;) {
@@ -866,9 +866,9 @@ static void close_rx(struct atm_vcc *vcc)
 				barrier();
 				if (!eni_vcc->rxing) break;
 			}
-			EVENT("drain PDUs (rx %ld, serv %ld)\n",eni_vcc->rxing,
+			EVENT("drain PDUs (rx %ld, serv %ld)\n", eni_vcc->rxing,
 			    eni_vcc->servicing);
-			printk(KERN_INFO "%d+%d RX left\n",eni_vcc->servicing,
+			printk(KERN_INFO "%d+%d RX left\n", eni_vcc->servicing,
 			    eni_vcc->rxing);
 			schedule();
 			set_current_state(TASK_UNINTERRUPTIBLE);
@@ -883,16 +883,16 @@ static void close_rx(struct atm_vcc *vcc)
 			tasklet_enable(&eni_dev->task);
 			if (at_end) break;
 			EVENT("drain discard (host 0x%lx, nic 0x%lx)\n",
-			    eni_vcc->rx_pos,tmp);
+			    eni_vcc->rx_pos, tmp);
 			printk(KERN_INFO "draining RX: host 0x%lx, nic 0x%x\n",
-			    eni_vcc->rx_pos,tmp);
+			    eni_vcc->rx_pos, tmp);
 			schedule();
 			set_current_state(TASK_UNINTERRUPTIBLE);
 		}
 		set_current_state(TASK_RUNNING);
-		remove_wait_queue(&eni_dev->rx_wait,&wait);
+		remove_wait_queue(&eni_dev->rx_wait, &wait);
 	}
-	eni_free_mem(eni_dev,eni_vcc->recv,eni_vcc->words << 2);
+	eni_free_mem(eni_dev, eni_vcc->recv, eni_vcc->words << 2);
 	eni_vcc->rx =3D NULL;
 }
=20
@@ -915,7 +915,7 @@ static int start_rx(struct atm_dev *dev)
 	init_waitqueue_head(&eni_dev->rx_wait);
 	skb_queue_head_init(&eni_dev->rx_queue);
 	eni_dev->serv_read =3D eni_in(MID_SERV_WRITE);
-	eni_out(0,MID_DMA_WR_RX);
+	eni_out(0, MID_DMA_WR_RX);
 	return 0;
 }
=20
@@ -923,27 +923,27 @@ static int start_rx(struct atm_dev *dev)
 /*----------------------------------- TX -----------------------------=
-------*/
=20
=20
-enum enq_res { enq_ok,enq_next,enq_jam };
+enum enq_res { enq_ok, enq_next, enq_jam };
=20
=20
-static inline void put_dma(int chan,u32 *dma,int *j,dma_addr_t paddr,
-    u32 size)
+static inline void put_dma(int chan, u32 *dma, int *j, dma_addr_t padd=
r,
+                           u32 size)
 {
-	u32 init,words;
+	u32 init, words;
=20
-	DPRINTK("put_dma: 0x%lx+0x%x\n",(unsigned long) paddr,size);
-	EVENT("put_dma: 0x%lx+0x%lx\n",(unsigned long) paddr,size);
+	DPRINTK("put_dma: 0x%lx+0x%x\n", (unsigned long) paddr, size);
+	EVENT("put_dma: 0x%lx+0x%lx\n", (unsigned long) paddr, size);
 #if 0 /* don't complain anymore */
 	if (paddr & 3)
-		printk(KERN_ERR "put_dma: unaligned addr (0x%lx)\n",paddr);
+		printk(KERN_ERR "put_dma: unaligned addr (0x%lx)\n", paddr);
 	if (size & 3)
-		printk(KERN_ERR "put_dma: unaligned size (0x%lx)\n",size);
+		printk(KERN_ERR "put_dma: unaligned size (0x%lx)\n", size);
 #endif
 	if (paddr & 3) {
 		init =3D 4-(paddr & 3);
 		if (init > size || size < 7) init =3D size;
 		DPRINTK("put_dma: %lx DMA: %d/%d bytes\n",
-		    (unsigned long) paddr,init,size);
+		    (unsigned long) paddr, init, size);
 		dma[(*j)++] =3D MID_DT_BYTE | (init << MID_DMA_COUNT_SHIFT) |
 		    (chan << MID_DMA_CHAN_SHIFT);
 		dma[(*j)++] =3D paddr;
@@ -956,7 +956,7 @@ static inline void put_dma(int chan,u32 *dma,int *j=
,dma_addr_t paddr,
 		init =3D 8-((paddr & 31) >> 2);
 		if (init > words) init =3D words;
 		DPRINTK("put_dma: %lx DMA: %d/%d words\n",
-		    (unsigned long) paddr,init,words);
+		    (unsigned long) paddr, init, words);
 		dma[(*j)++] =3D MID_DT_WORD | (init << MID_DMA_COUNT_SHIFT) |
 		    (chan << MID_DMA_CHAN_SHIFT);
 		dma[(*j)++] =3D paddr;
@@ -966,7 +966,7 @@ static inline void put_dma(int chan,u32 *dma,int *j=
,dma_addr_t paddr,
 #ifdef CONFIG_ATM_ENI_BURST_TX_16W /* may work with some PCI chipsets =
=2E.. */
 	if (words & ~15) {
 		DPRINTK("put_dma: %lx DMA: %d*16/%d words\n",
-		    (unsigned long) paddr,words >> 4,words);
+		    (unsigned long) paddr, words >> 4, words);
 		dma[(*j)++] =3D MID_DT_16W | ((words >> 4) << MID_DMA_COUNT_SHIFT)
 		    | (chan << MID_DMA_CHAN_SHIFT);
 		dma[(*j)++] =3D paddr;
@@ -977,7 +977,7 @@ static inline void put_dma(int chan,u32 *dma,int *j=
,dma_addr_t paddr,
 #ifdef CONFIG_ATM_ENI_BURST_TX_8W /* recommended */
 	if (words & ~7) {
 		DPRINTK("put_dma: %lx DMA: %d*8/%d words\n",
-		    (unsigned long) paddr,words >> 3,words);
+		    (unsigned long) paddr, words >> 3, words);
 		dma[(*j)++] =3D MID_DT_8W | ((words >> 3) << MID_DMA_COUNT_SHIFT)
 		    | (chan << MID_DMA_CHAN_SHIFT);
 		dma[(*j)++] =3D paddr;
@@ -988,7 +988,7 @@ static inline void put_dma(int chan,u32 *dma,int *j=
,dma_addr_t paddr,
 #ifdef CONFIG_ATM_ENI_BURST_TX_4W /* probably useless if TX_8W or TX_1=
6W */
 	if (words & ~3) {
 		DPRINTK("put_dma: %lx DMA: %d*4/%d words\n",
-		    (unsigned long) paddr,words >> 2,words);
+		    (unsigned long) paddr, words >> 2, words);
 		dma[(*j)++] =3D MID_DT_4W | ((words >> 2) << MID_DMA_COUNT_SHIFT)
 		    | (chan << MID_DMA_CHAN_SHIFT);
 		dma[(*j)++] =3D paddr;
@@ -999,7 +999,7 @@ static inline void put_dma(int chan,u32 *dma,int *j=
,dma_addr_t paddr,
 #ifdef CONFIG_ATM_ENI_BURST_TX_2W /* probably useless if TX_4W, TX_8W,=
 ... */
 	if (words & ~1) {
 		DPRINTK("put_dma: %lx DMA: %d*2/%d words\n",
-		    (unsigned long) paddr,words >> 1,words);
+		    (unsigned long) paddr, words >> 1, words);
 		dma[(*j)++] =3D MID_DT_2W | ((words >> 1) << MID_DMA_COUNT_SHIFT)
 		    | (chan << MID_DMA_CHAN_SHIFT);
 		dma[(*j)++] =3D paddr;
@@ -1008,16 +1008,16 @@ static inline void put_dma(int chan,u32 *dma,in=
t *j,dma_addr_t paddr,
 	}
 #endif
 	if (words) {
-		DPRINTK("put_dma: %lx DMA: %d words\n",(unsigned long) paddr,
-		    words);
+		DPRINTK("put_dma: %lx DMA: %d words\n", (unsigned long) paddr,
+                        words);
 		dma[(*j)++] =3D MID_DT_WORD | (words << MID_DMA_COUNT_SHIFT) |
 		    (chan << MID_DMA_CHAN_SHIFT);
 		dma[(*j)++] =3D paddr;
 		paddr +=3D words << 2;
 	}
 	if (size) {
-		DPRINTK("put_dma: %lx DMA: %d bytes\n",(unsigned long) paddr,
-		    size);
+		DPRINTK("put_dma: %lx DMA: %d bytes\n", (unsigned long) paddr,
+                        size);
 		dma[(*j)++] =3D MID_DT_BYTE | (size << MID_DMA_COUNT_SHIFT) |
 		    (chan << MID_DMA_CHAN_SHIFT);
 		dma[(*j)++] =3D paddr;
@@ -1032,13 +1032,13 @@ static enum enq_res do_tx(struct sk_buff *skb)
 	struct eni_vcc *eni_vcc;
 	struct eni_tx *tx;
 	dma_addr_t paddr;
-	u32 dma_rd,dma_wr;
+	u32 dma_rd, dma_wr;
 	u32 size; /* in words */
-	int aal5,dma_size,i,j;
+	int aal5, dma_size, i, j;
=20
 	DPRINTK(">do_tx\n");
 	NULLCHECK(skb);
-	EVENT("do_tx: skb=3D0x%lx, %ld bytes\n",(unsigned long) skb,skb->len)=
;
+	EVENT("do_tx: skb=3D0x%lx, %ld bytes\n", (unsigned long) skb, skb->le=
n);
 	vcc =3D ATM_SKB(skb)->vcc;
 	NULLCHECK(vcc);
 	eni_dev =3D ENI_DEV(vcc->dev);
@@ -1059,7 +1059,7 @@ static enum enq_res do_tx(struct sk_buff *skb)
 #if 0 /* should work now */
 	if ((unsigned long) skb->data & 3)
 		printk(KERN_ERR DEV_LABEL "(itf %d): VCI %d has mis-aligned "
-		    "TX data\n",vcc->dev->number,vcc->vci);
+		    "TX data\n", vcc->dev->number, vcc->vci);
 #endif
 	/*
 	 * Potential future IP speedup: make hard_header big enough to put
@@ -1084,10 +1084,10 @@ static enum enq_res do_tx(struct sk_buff *skb)
 	 * to the read pointer ? TX_GAP means to leave some space for what
 	 * the manual calls "too close".
 	 */
-	if (!NEPMOK(tx->tx_pos,size+TX_GAP,
-	    eni_in(MID_TX_RDPTR(tx->index)),tx->words)) {
+	if (!NEPMOK(tx->tx_pos, size+TX_GAP,
+	    eni_in(MID_TX_RDPTR(tx->index)), tx->words)) {
 		DPRINTK(DEV_LABEL "(itf %d): TX full (size %d)\n",
-		    vcc->dev->number,size);
+		    vcc->dev->number, size);
 		return enq_next;
 	}
 	/* check DMA */
@@ -1095,22 +1095,22 @@ static enum enq_res do_tx(struct sk_buff *skb)
 	dma_rd =3D eni_in(MID_DMA_RD_TX);
 	dma_size =3D 3; /* JK for descriptor and final fill, plus final size
 			 mis-alignment fix */
-DPRINTK("iovcnt =3D %d\n",skb_shinfo(skb)->nr_frags);
+DPRINTK("iovcnt =3D %d\n", skb_shinfo(skb)->nr_frags);
 	if (!skb_shinfo(skb)->nr_frags) dma_size +=3D 5;
 	else dma_size +=3D 5*(skb_shinfo(skb)->nr_frags+1);
 	if (dma_size > TX_DMA_BUF) {
 		printk(KERN_CRIT DEV_LABEL "(itf %d): needs %d DMA entries "
-		    "(got only %d)\n",vcc->dev->number,dma_size,TX_DMA_BUF);
+		    "(got only %d)\n", vcc->dev->number, dma_size, TX_DMA_BUF);
 	}
-	DPRINTK("dma_wr is %d, tx_pos is %ld\n",dma_wr,tx->tx_pos);
+	DPRINTK("dma_wr is %d, tx_pos is %ld\n", dma_wr, tx->tx_pos);
 	if (dma_wr !=3D dma_rd && ((dma_rd+NR_DMA_TX-dma_wr) & (NR_DMA_TX-1))=
 <
 	     dma_size) {
 		printk(KERN_WARNING DEV_LABEL "(itf %d): TX DMA full\n",
-		    vcc->dev->number);
+                       vcc->dev->number);
 		return enq_jam;
 	}
-	paddr =3D pci_map_single(eni_dev->pci_dev,skb->data,skb->len,
-	    PCI_DMA_TODEVICE);
+	paddr =3D pci_map_single(eni_dev->pci_dev, skb->data, skb->len,
+                               PCI_DMA_TODEVICE);
 	ENI_PRV_PADDR(skb) =3D paddr;
 	/* prepare DMA queue entries */
 	j =3D 0;
@@ -1119,20 +1119,20 @@ DPRINTK("iovcnt =3D %d\n",skb_shinfo(skb)->nr_f=
rags);
 	     MID_DT_JK;
 	j++;
 	if (!skb_shinfo(skb)->nr_frags)
-		if (aal5) put_dma(tx->index,eni_dev->dma,&j,paddr,skb->len);
-		else put_dma(tx->index,eni_dev->dma,&j,paddr+4,skb->len-4);
+		if (aal5) put_dma(tx->index, eni_dev->dma, &j, paddr, skb->len);
+		else put_dma(tx->index, eni_dev->dma, &j, paddr+4, skb->len-4);
 	else {
-DPRINTK("doing direct send\n"); /* @@@ well, this doesn't work anyway =
*/
+                DPRINTK("doing direct send\n"); /* @@@ well, this does=
n't work anyway */
 		for (i =3D -1; i < skb_shinfo(skb)->nr_frags; i++)
 			if (i =3D=3D -1)
-				put_dma(tx->index,eni_dev->dma,&j,(unsigned long)
-				    skb->data,
-				    skb_headlen(skb));
+				put_dma(tx->index, eni_dev->dma, &j, (unsigned long)
+                                        skb->data,
+                                        skb_headlen(skb));
 			else
-				put_dma(tx->index,eni_dev->dma,&j,(unsigned long)
-				    skb_frag_page(&skb_shinfo(skb)->frags[i]) +
+				put_dma(tx->index, eni_dev->dma, &j, (unsigned long)
+                                        skb_frag_page(&skb_shinfo(skb)=
->frags[i]) +
 					skb_shinfo(skb)->frags[i].page_offset,
-				    skb_frag_size(&skb_shinfo(skb)->frags[i]));
+                                        skb_frag_size(&skb_shinfo(skb)=
->frags[i]));
 	}
 	if (skb->len & 3) {
 		put_dma(tx->index, eni_dev->dma, &j, eni_dev->zero.dma,
@@ -1143,34 +1143,34 @@ DPRINTK("doing direct send\n"); /* @@@ well, th=
is doesn't work anyway */
 	     MID_DMA_COUNT_SHIFT) | (tx->index << MID_DMA_CHAN_SHIFT) |
 	     MID_DMA_END | MID_DT_JK;
 	j++;
-	DPRINTK("DMA at end: %d\n",j);
+	DPRINTK("DMA at end: %d\n", j);
 	/* store frame */
 	writel((MID_SEG_TX_ID << MID_SEG_ID_SHIFT) |
 	    (aal5 ? MID_SEG_AAL5 : 0) | (tx->prescaler << MID_SEG_PR_SHIFT) |
 	    (tx->resolution << MID_SEG_RATE_SHIFT) |
-	    (size/(ATM_CELL_PAYLOAD/4)),tx->send+tx->tx_pos*4);
+	    (size/(ATM_CELL_PAYLOAD/4)), tx->send+tx->tx_pos*4);
 /*printk("dsc =3D 0x%08lx\n",(unsigned long) readl(tx->send+tx->tx_pos=
*4));*/
 	writel((vcc->vci << MID_SEG_VCI_SHIFT) |
             (aal5 ? 0 : (skb->data[3] & 0xf)) |
 	    (ATM_SKB(skb)->atm_options & ATM_ATMOPT_CLP ? MID_SEG_CLP : 0),
 	    tx->send+((tx->tx_pos+1) & (tx->words-1))*4);
-	DPRINTK("size: %d, len:%d\n",size,skb->len);
+	DPRINTK("size: %d, len:%d\n", size, skb->len);
 	if (aal5)
-		writel(skb->len,tx->send+
+		writel(skb->len, tx->send+
                     ((tx->tx_pos+size-AAL5_TRAILER) & (tx->words-1))*4=
);
 	j =3D j >> 1;
 	for (i =3D 0; i < j; i++) {
-		writel(eni_dev->dma[i*2],eni_dev->tx_dma+dma_wr*8);
-		writel(eni_dev->dma[i*2+1],eni_dev->tx_dma+dma_wr*8+4);
+		writel(eni_dev->dma[i*2], eni_dev->tx_dma+dma_wr*8);
+		writel(eni_dev->dma[i*2+1], eni_dev->tx_dma+dma_wr*8+4);
 		dma_wr =3D (dma_wr+1) & (NR_DMA_TX-1);
 	}
 	ENI_PRV_POS(skb) =3D tx->tx_pos;
 	ENI_PRV_SIZE(skb) =3D size;
 	ENI_VCC(vcc)->txing +=3D size;
 	tx->tx_pos =3D (tx->tx_pos+size) & (tx->words-1);
-	DPRINTK("dma_wr set to %d, tx_pos is now %ld\n",dma_wr,tx->tx_pos);
-	eni_out(dma_wr,MID_DMA_WR_TX);
-	skb_queue_tail(&eni_dev->tx_queue,skb);
+	DPRINTK("dma_wr set to %d, tx_pos is now %ld\n", dma_wr, tx->tx_pos);
+	eni_out(dma_wr, MID_DMA_WR_TX);
+	skb_queue_tail(&eni_dev->tx_queue, skb);
 queued++;
 	return enq_ok;
 }
@@ -1191,7 +1191,7 @@ static void poll_tx(struct atm_dev *dev)
 				res =3D do_tx(skb);
 				if (res =3D=3D enq_ok) continue;
 				DPRINTK("re-queuing TX PDU\n");
-				skb_queue_head(&tx->backlog,skb);
+				skb_queue_head(&tx->backlog, skb);
 requeued++;
 				if (res =3D=3D enq_jam) return;
 				break;
@@ -1215,17 +1215,17 @@ static void dequeue_tx(struct atm_dev *dev)
 		NULLCHECK(vcc);
 		tx =3D ENI_VCC(vcc)->tx;
 		NULLCHECK(ENI_VCC(vcc)->tx);
-		DPRINTK("dequeue_tx: next 0x%lx curr 0x%x\n",ENI_PRV_POS(skb),
+		DPRINTK("dequeue_tx: next 0x%lx curr 0x%x\n", ENI_PRV_POS(skb),
 		    (unsigned) eni_in(MID_TX_DESCRSTART(tx->index)));
 		if (ENI_VCC(vcc)->txing < tx->words && ENI_PRV_POS(skb) =3D=3D
 		    eni_in(MID_TX_DESCRSTART(tx->index))) {
-			skb_queue_head(&eni_dev->tx_queue,skb);
+			skb_queue_head(&eni_dev->tx_queue, skb);
 			break;
 		}
 		ENI_VCC(vcc)->txing -=3D ENI_PRV_SIZE(skb);
-		pci_unmap_single(eni_dev->pci_dev,ENI_PRV_PADDR(skb),skb->len,
-		    PCI_DMA_TODEVICE);
-		if (vcc->pop) vcc->pop(vcc,skb);
+		pci_unmap_single(eni_dev->pci_dev, ENI_PRV_PADDR(skb), skb->len,
+                                 PCI_DMA_TODEVICE);
+		if (vcc->pop) vcc->pop(vcc, skb);
 		else dev_kfree_skb_irq(skb);
 		atomic_inc(&vcc->stats->tx);
 		wake_up(&eni_dev->tx_wait);
@@ -1234,7 +1234,7 @@ dma_complete++;
 }
=20
=20
-static struct eni_tx *alloc_tx(struct eni_dev *eni_dev,int ubr)
+static struct eni_tx *alloc_tx(struct eni_dev *eni_dev, int ubr)
 {
 	int i;
=20
@@ -1244,10 +1244,10 @@ static struct eni_tx *alloc_tx(struct eni_dev *=
eni_dev,int ubr)
 }
=20
=20
-static int comp_tx(struct eni_dev *eni_dev,int *pcr,int reserved,int *=
pre,
-    int *res,int unlimited)
+static int comp_tx(struct eni_dev *eni_dev, int *pcr, int reserved, in=
t *pre,
+                   int *res, int unlimited)
 {
-	static const int pre_div[] =3D { 4,16,128,2048 };
+	static const int pre_div[] =3D { 4, 16, 128, 2048 };
 	    /* 2^(((x+2)^2-(x+2))/2+1) */
=20
 	if (unlimited) *pre =3D *res =3D 0;
@@ -1258,7 +1258,7 @@ static int comp_tx(struct eni_dev *eni_dev,int *p=
cr,int reserved,int *pre,
 			for (*pre =3D 0; *pre < 3; (*pre)++)
 				if (TS_CLOCK/pre_div[*pre]/64 <=3D *pcr) break;
 			div =3D pre_div[*pre]**pcr;
-			DPRINTK("min div %d\n",div);
+			DPRINTK("min div %d\n", div);
 			*res =3D TS_CLOCK/div-1;
 		}
 		else {
@@ -1269,28 +1269,28 @@ static int comp_tx(struct eni_dev *eni_dev,int =
*pcr,int reserved,int *pre,
 				if (TS_CLOCK/pre_div[*pre]/64 > -*pcr) break;
 			if (*pre < 3) (*pre)++; /* else fail later */
 			div =3D pre_div[*pre]*-*pcr;
-			DPRINTK("max div %d\n",div);
+			DPRINTK("max div %d\n", div);
 			*res =3D DIV_ROUND_UP(TS_CLOCK, div)-1;
 		}
 		if (*res < 0) *res =3D 0;
 		if (*res > MID_SEG_MAX_RATE) *res =3D MID_SEG_MAX_RATE;
 	}
 	*pcr =3D TS_CLOCK/pre_div[*pre]/(*res+1);
-	DPRINTK("out pcr: %d (%d:%d)\n",*pcr,*pre,*res);
+	DPRINTK("out pcr: %d (%d:%d)\n", *pcr, *pre, *res);
 	return 0;
 }
=20
=20
-static int reserve_or_set_tx(struct atm_vcc *vcc,struct atm_trafprm *t=
xtp,
-    int set_rsv,int set_shp)
+static int reserve_or_set_tx(struct atm_vcc *vcc, struct atm_trafprm *=
txtp,
+                             int set_rsv, int set_shp)
 {
 	struct eni_dev *eni_dev =3D ENI_DEV(vcc->dev);
 	struct eni_vcc *eni_vcc =3D ENI_VCC(vcc);
 	struct eni_tx *tx;
 	unsigned long size;
 	void __iomem *mem;
-	int rate,ubr,unlimited,new_tx;
-	int pre,res,order;
+	int rate, ubr, unlimited, new_tx;
+	int pre, res, order;
 	int error;
=20
 	rate =3D atm_pcr_goal(txtp);
@@ -1315,26 +1315,26 @@ static int reserve_or_set_tx(struct atm_vcc *vc=
c,struct atm_trafprm *txtp,
 	mem =3D NULL; /* for gcc */
 	if (!new_tx) tx =3D eni_vcc->tx;
 	else {
-		mem =3D eni_alloc_mem(eni_dev,&size);
+		mem =3D eni_alloc_mem(eni_dev, &size);
 		if (!mem) return -ENOBUFS;
-		tx =3D alloc_tx(eni_dev,unlimited);
+		tx =3D alloc_tx(eni_dev, unlimited);
 		if (!tx) {
-			eni_free_mem(eni_dev,mem,size);
+			eni_free_mem(eni_dev, mem, size);
 			return -EBUSY;
 		}
-		DPRINTK("got chan %d\n",tx->index);
+		DPRINTK("got chan %d\n", tx->index);
 		tx->reserved =3D tx->shaping =3D 0;
 		tx->send =3D mem;
 		tx->words =3D size >> 2;
 		skb_queue_head_init(&tx->backlog);
 		for (order =3D 0; size > (1 << (order+10)); order++);
 		eni_out((order << MID_SIZE_SHIFT) |
-		    ((tx->send-eni_dev->ram) >> (MID_LOC_SKIP+2)),
-		    MID_TX_PLACE(tx->index));
+                        ((tx->send-eni_dev->ram) >> (MID_LOC_SKIP+2)),
+                        MID_TX_PLACE(tx->index));
 		tx->tx_pos =3D eni_in(MID_TX_DESCRSTART(tx->index)) &
 		    MID_DESCR_START;
 	}
-	error =3D comp_tx(eni_dev,&rate,tx->reserved,&pre,&res,unlimited);
+	error =3D comp_tx(eni_dev, &rate, tx->reserved, &pre, &res, unlimited=
);
 	if (!error  && txtp->min_pcr > rate) error =3D -EINVAL;
 	if (!error && txtp->max_pcr && txtp->max_pcr !=3D ATM_MAX_PCR &&
 	    txtp->max_pcr < rate) error =3D -EINVAL;
@@ -1347,7 +1347,7 @@ static int reserve_or_set_tx(struct atm_vcc *vcc,=
struct atm_trafprm *txtp,
 	if (error) {
 		if (new_tx) {
 			tx->send =3D NULL;
-			eni_free_mem(eni_dev,mem,size);
+			eni_free_mem(eni_dev, mem, size);
 		}
 		return error;
 	}
@@ -1364,7 +1364,7 @@ static int reserve_or_set_tx(struct atm_vcc *vcc,=
struct atm_trafprm *txtp,
 		tx->shaping =3D rate;
 	}
 	if (set_shp) eni_vcc->tx =3D tx;
-	DPRINTK("rsv %d shp %d\n",tx->reserved,tx->shaping);
+	DPRINTK("rsv %d shp %d\n", tx->reserved, tx->shaping);
 	return 0;
 }
=20
@@ -1374,7 +1374,7 @@ static int open_tx_first(struct atm_vcc *vcc)
 	ENI_VCC(vcc)->tx =3D NULL;
 	if (vcc->qos.txtp.traffic_class =3D=3D ATM_NONE) return 0;
 	ENI_VCC(vcc)->txing =3D 0;
-	return reserve_or_set_tx(vcc,&vcc->qos.txtp,1,1);
+	return reserve_or_set_tx(vcc, &vcc->qos.txtp, 1, 1);
 }
=20
=20
@@ -1386,7 +1386,7 @@ static int open_tx_second(struct atm_vcc *vcc)
=20
 static void close_tx(struct atm_vcc *vcc)
 {
-	DECLARE_WAITQUEUE(wait,current);
+	DECLARE_WAITQUEUE(wait, current);
 	struct eni_dev *eni_dev;
 	struct eni_vcc *eni_vcc;
=20
@@ -1395,7 +1395,7 @@ static void close_tx(struct atm_vcc *vcc)
 	eni_dev =3D ENI_DEV(vcc->dev);
 	/* wait for TX queue to drain */
 	DPRINTK("eni_close: waiting for TX ...\n");
-	add_wait_queue(&eni_dev->tx_wait,&wait);
+	add_wait_queue(&eni_dev->tx_wait, &wait);
 	set_current_state(TASK_UNINTERRUPTIBLE);
 	for (;;) {
 		int txing;
@@ -1404,12 +1404,12 @@ static void close_tx(struct atm_vcc *vcc)
 		txing =3D skb_peek(&eni_vcc->tx->backlog) || eni_vcc->txing;
 		tasklet_enable(&eni_dev->task);
 		if (!txing) break;
-		DPRINTK("%d TX left\n",eni_vcc->txing);
+		DPRINTK("%d TX left\n", eni_vcc->txing);
 		schedule();
 		set_current_state(TASK_UNINTERRUPTIBLE);
 	}
 	set_current_state(TASK_RUNNING);
-	remove_wait_queue(&eni_dev->tx_wait,&wait);
+	remove_wait_queue(&eni_dev->tx_wait, &wait);
 	if (eni_vcc->tx !=3D eni_dev->ubr) {
 		/*
 		 * Looping a few times in here is probably far cheaper than
@@ -1419,7 +1419,7 @@ static void close_tx(struct atm_vcc *vcc)
 		while (eni_in(MID_TX_RDPTR(eni_vcc->tx->index)) !=3D
 		    eni_in(MID_TX_DESCRSTART(eni_vcc->tx->index)))
 			schedule();
-		eni_free_mem(eni_dev,eni_vcc->tx->send,eni_vcc->tx->words << 2);
+		eni_free_mem(eni_dev, eni_vcc->tx->send, eni_vcc->tx->words << 2);
 		eni_vcc->tx->send =3D NULL;
 		eni_dev->tx_bw +=3D eni_vcc->tx->reserved;
 	}
@@ -1439,7 +1439,7 @@ static int start_tx(struct atm_dev *dev)
 	init_waitqueue_head(&eni_dev->tx_wait);
 	eni_dev->ubr =3D NULL;
 	skb_queue_head_init(&eni_dev->tx_queue);
-	eni_out(0,MID_DMA_WR_TX);
+	eni_out(0, MID_DMA_WR_TX);
 	for (i =3D 0; i < NR_CHAN; i++) {
 		eni_dev->tx[i].send =3D NULL;
 		eni_dev->tx[i].index =3D i;
@@ -1458,33 +1458,33 @@ static void foo(void)
 printk(KERN_INFO
   "tx_complete=3D%d,dma_complete=3D%d,queued=3D%d,requeued=3D%d,sub=3D=
%d,\n"
   "backlogged=3D%d,rx_enqueued=3D%d,rx_dequeued=3D%d,putting=3D%d,push=
ed=3D%d\n",
-  tx_complete,dma_complete,queued,requeued,submitted,backlogged,
-  rx_enqueued,rx_dequeued,putting,pushed);
-if (eni_boards) printk(KERN_INFO "loss: %ld\n",ENI_DEV(eni_boards)->lo=
st);
+  tx_complete, dma_complete, queued, requeued, submitted, backlogged,
+  rx_enqueued, rx_dequeued, putting, pushed);
+if (eni_boards) printk(KERN_INFO "loss: %ld\n", ENI_DEV(eni_boards)->l=
ost);
 }
=20
 #endif
=20
=20
-static void bug_int(struct atm_dev *dev,unsigned long reason)
+static void bug_int(struct atm_dev *dev, unsigned long reason)
 {
 	DPRINTK(">bug_int\n");
 	if (reason & MID_DMA_ERR_ACK)
 		printk(KERN_CRIT DEV_LABEL "(itf %d): driver error - DMA "
-		    "error\n",dev->number);
+		    "error\n", dev->number);
 	if (reason & MID_TX_IDENT_MISM)
 		printk(KERN_CRIT DEV_LABEL "(itf %d): driver error - ident "
-		    "mismatch\n",dev->number);
+		    "mismatch\n", dev->number);
 	if (reason & MID_TX_DMA_OVFL)
 		printk(KERN_CRIT DEV_LABEL "(itf %d): driver error - DMA "
-		    "overflow\n",dev->number);
-	EVENT("---dump ends here---\n",0,0);
+		    "overflow\n", dev->number);
+	EVENT("---dump ends here---\n", 0, 0);
 	printk(KERN_NOTICE "---recent events---\n");
 	event_dump();
 }
=20
=20
-static irqreturn_t eni_int(int irq,void *dev_id)
+static irqreturn_t eni_int(int irq, void *dev_id)
 {
 	struct atm_dev *dev;
 	struct eni_dev *eni_dev;
@@ -1494,7 +1494,7 @@ static irqreturn_t eni_int(int irq,void *dev_id)
 	dev =3D dev_id;
 	eni_dev =3D ENI_DEV(dev);
 	reason =3D eni_in(MID_ISA);
-	DPRINTK(DEV_LABEL ": int 0x%lx\n",(unsigned long) reason);
+	DPRINTK(DEV_LABEL ": int 0x%lx\n", (unsigned long) reason);
 	/*
 	 * Must handle these two right now, because reading ISA doesn't clear
 	 * them, so they re-occur and we never make it to the tasklet. Since
@@ -1502,11 +1502,11 @@ static irqreturn_t eni_int(int irq,void *dev_id=
)
 	 * with eni_dev->events =3D=3D 0.
 	 */
 	if (reason & MID_STAT_OVFL) {
-		EVENT("stat overflow\n",0,0);
+		EVENT("stat overflow\n", 0, 0);
 		eni_dev->lost +=3D eni_in(MID_STAT) & MID_OVFL_TRASH;
 	}
 	if (reason & MID_SUNI_INT) {
-		EVENT("SUNI int\n",0,0);
+		EVENT("SUNI int\n", 0, 0);
 		dev->phy->interrupt(dev);
 #if 0
 		foo();
@@ -1527,38 +1527,38 @@ static void eni_tasklet(unsigned long data)
 	unsigned long flags;
 	u32 events;
=20
-	DPRINTK("eni_tasklet (dev %p)\n",dev);
-	spin_lock_irqsave(&eni_dev->lock,flags);
-	events =3D xchg(&eni_dev->events,0);
-	spin_unlock_irqrestore(&eni_dev->lock,flags);
+	DPRINTK("eni_tasklet (dev %p)\n", dev);
+	spin_lock_irqsave(&eni_dev->lock, flags);
+	events =3D xchg(&eni_dev->events, 0);
+	spin_unlock_irqrestore(&eni_dev->lock, flags);
 	if (events & MID_RX_DMA_COMPLETE) {
-		EVENT("INT: RX DMA complete, starting dequeue_rx\n",0,0);
+		EVENT("INT: RX DMA complete, starting dequeue_rx\n", 0, 0);
 		dequeue_rx(dev);
-		EVENT("dequeue_rx done, starting poll_rx\n",0,0);
+		EVENT("dequeue_rx done, starting poll_rx\n", 0, 0);
 		poll_rx(dev);
-		EVENT("poll_rx done\n",0,0);
+		EVENT("poll_rx done\n", 0, 0);
 		/* poll_tx ? */
 	}
 	if (events & MID_SERVICE) {
-		EVENT("INT: service, starting get_service\n",0,0);
+		EVENT("INT: service, starting get_service\n", 0, 0);
 		get_service(dev);
-		EVENT("get_service done, starting poll_rx\n",0,0);
+		EVENT("get_service done, starting poll_rx\n", 0, 0);
 		poll_rx(dev);
-		EVENT("poll_rx done\n",0,0);
+		EVENT("poll_rx done\n", 0, 0);
 	}
  	if (events & MID_TX_DMA_COMPLETE) {
-		EVENT("INT: TX DMA COMPLETE\n",0,0);
+		EVENT("INT: TX DMA COMPLETE\n", 0, 0);
 		dequeue_tx(dev);
 	}
 	if (events & MID_TX_COMPLETE) {
-		EVENT("INT: TX COMPLETE\n",0,0);
+		EVENT("INT: TX COMPLETE\n", 0, 0);
 tx_complete++;
 		wake_up(&eni_dev->tx_wait);
 		/* poll_rx ? */
 	}
 	if (events & (MID_DMA_ERR_ACK | MID_TX_IDENT_MISM | MID_TX_DMA_OVFL))=
 {
-		EVENT("bug interrupt\n",0,0);
-		bug_int(dev,events);
+		EVENT("bug interrupt\n", 0, 0);
+		bug_int(dev, events);
 	}
 	poll_tx(dev);
 }
@@ -1570,7 +1570,7 @@ tx_complete++;
 static char * const media_name[] =3D {
     "MMF", "SMF", "MMF", "03?", /*  0- 3 */
     "UTP", "05?", "06?", "07?", /*  4- 7 */
-    "TAXI","09?", "10?", "11?", /*  8-11 */
+    "TAXI", "09?", "10?", "11?", /*  8-11 */
     "12?", "13?", "14?", "15?", /* 12-15 */
     "MMF", "SMF", "18?", "19?", /* 16-19 */
     "UTP", "21?", "22?", "23?", /* 20-23 */
@@ -1581,12 +1581,12 @@ static char * const media_name[] =3D {
=20
 #define SET_SEPROM \
   ({ if (!error && !pci_error) { \
-    pci_error =3D pci_write_config_byte(eni_dev->pci_dev,PCI_TONGA_CTR=
L,tonga); \
+    pci_error =3D pci_write_config_byte(eni_dev->pci_dev, PCI_TONGA_CT=
RL, tonga); \
     udelay(10); /* 10 usecs */ \
   } })
 #define GET_SEPROM \
   ({ if (!error && !pci_error) { \
-    pci_error =3D pci_read_config_byte(eni_dev->pci_dev,PCI_TONGA_CTRL=
,&tonga); \
+    pci_error =3D pci_read_config_byte(eni_dev->pci_dev, PCI_TONGA_CTR=
L, &tonga); \
     udelay(10); /* 10 usecs */ \
   } })
=20
@@ -1595,8 +1595,8 @@ static int get_esi_asic(struct atm_dev *dev)
 {
 	struct eni_dev *eni_dev;
 	unsigned char tonga;
-	int error,failed,pci_error;
-	int address,i,j;
+	int error, failed, pci_error;
+	int address, i, j;
=20
 	eni_dev =3D ENI_DEV(dev);
 	error =3D pci_error =3D 0;
@@ -1672,7 +1672,7 @@ static int get_esi_asic(struct atm_dev *dev)
 	}
 	if (pci_error) {
 		printk(KERN_ERR DEV_LABEL "(itf %d): error reading ESI "
-		    "(0x%02x)\n",dev->number,pci_error);
+		    "(0x%02x)\n", dev->number, pci_error);
 		error =3D -EIO;
 	}
 	return error;
@@ -1701,7 +1701,7 @@ static int eni_do_init(struct atm_dev *dev)
 	struct pci_dev *pci_dev;
 	unsigned long real_base;
 	void __iomem *base;
-	int error,i,last;
+	int error, i, last;
=20
 	DPRINTK(">eni_init\n");
 	dev->ci_range.vpi_bits =3D 0;
@@ -1711,19 +1711,19 @@ static int eni_do_init(struct atm_dev *dev)
 	pci_dev =3D eni_dev->pci_dev;
 	real_base =3D pci_resource_start(pci_dev, 0);
 	eni_dev->irq =3D pci_dev->irq;
-	if ((error =3D pci_write_config_word(pci_dev,PCI_COMMAND,
+	if ((error =3D pci_write_config_word(pci_dev, PCI_COMMAND,
 	    PCI_COMMAND_MEMORY |
 	    (eni_dev->asic ? PCI_COMMAND_PARITY | PCI_COMMAND_SERR : 0)))) {
 		printk(KERN_ERR DEV_LABEL "(itf %d): can't enable memory "
-		    "(0x%02x)\n",dev->number,error);
+		    "(0x%02x)\n", dev->number, error);
 		return -EIO;
 	}
 	printk(KERN_NOTICE DEV_LABEL "(itf %d): rev.%d,base=3D0x%lx,irq=3D%d,=
",
-	    dev->number,pci_dev->revision,real_base,eni_dev->irq);
-	if (!(base =3D ioremap_nocache(real_base,MAP_MAX_SIZE))) {
+	    dev->number, pci_dev->revision, real_base, eni_dev->irq);
+	if (!(base =3D ioremap_nocache(real_base, MAP_MAX_SIZE))) {
 		printk("\n");
 		printk(KERN_ERR DEV_LABEL "(itf %d): can't set up page "
-		    "mapping\n",dev->number);
+		    "mapping\n", dev->number);
 		return error;
 	}
 	eni_dev->ioaddr =3D base;
@@ -1746,35 +1746,35 @@ static int eni_do_init(struct atm_dev *dev)
 	eni_dev->ram =3D base+RAM_BASE;
 	last =3D MAP_MAX_SIZE-RAM_BASE;
 	for (i =3D last-RAM_INCREMENT; i >=3D 0; i -=3D RAM_INCREMENT) {
-		writel(0x55555555,eni_dev->ram+i);
+		writel(0x55555555, eni_dev->ram+i);
 		if (readl(eni_dev->ram+i) !=3D 0x55555555) last =3D i;
 		else {
-			writel(0xAAAAAAAA,eni_dev->ram+i);
+			writel(0xAAAAAAAA, eni_dev->ram+i);
 			if (readl(eni_dev->ram+i) !=3D 0xAAAAAAAA) last =3D i;
-			else writel(i,eni_dev->ram+i);
+			else writel(i, eni_dev->ram+i);
 		}
 	}
 	for (i =3D 0; i < last; i +=3D RAM_INCREMENT)
 		if (readl(eni_dev->ram+i) !=3D i) break;
 	eni_dev->mem =3D i;
-	memset_io(eni_dev->ram,0,eni_dev->mem);
+	memset_io(eni_dev->ram, 0, eni_dev->mem);
 	/* TODO: should shrink allocation now */
-	printk("mem=3D%dkB (",eni_dev->mem >> 10);
+	printk("mem=3D%dkB (", eni_dev->mem >> 10);
 	/* TODO: check for non-SUNI, check for TAXI ? */
 	if (!(eni_in(MID_RES_ID_MCON) & 0x200) !=3D !eni_dev->asic) {
 		printk(")\n");
 		printk(KERN_ERR DEV_LABEL "(itf %d): ERROR - wrong id 0x%x\n",
-		    dev->number,(unsigned) eni_in(MID_RES_ID_MCON));
+		    dev->number, (unsigned) eni_in(MID_RES_ID_MCON));
 		error =3D -EINVAL;
 		goto unmap;
 	}
-	error =3D eni_dev->asic ? get_esi_asic(dev) : get_esi_fpga(dev,base);
+	error =3D eni_dev->asic ? get_esi_asic(dev) : get_esi_fpga(dev, base)=
;
 	if (error)
 		goto unmap;
 	for (i =3D 0; i < ESI_LEN; i++)
-		printk("%s%02X",i ? "-" : "",dev->esi[i]);
+		printk("%s%02X", i ? "-" : "", dev->esi[i]);
 	printk(")\n");
-	printk(KERN_NOTICE DEV_LABEL "(itf %d): %s,%s\n",dev->number,
+	printk(KERN_NOTICE DEV_LABEL "(itf %d): %s,%s\n", dev->number,
 	    eni_in(MID_RES_ID_MCON) & 0x200 ? "ASIC" : "FPGA",
 	    media_name[eni_in(MID_RES_ID_MCON) & DAUGTHER_ID]);
=20
@@ -1807,24 +1807,24 @@ static int eni_start(struct atm_dev *dev)
=20
 	DPRINTK(">eni_start\n");
 	eni_dev =3D ENI_DEV(dev);
-	if (request_irq(eni_dev->irq,&eni_int,IRQF_SHARED,DEV_LABEL,dev)) {
+	if (request_irq(eni_dev->irq, &eni_int, IRQF_SHARED, DEV_LABEL, dev))=
 {
 		printk(KERN_ERR DEV_LABEL "(itf %d): IRQ%d is already in use\n",
-		    dev->number,eni_dev->irq);
+		    dev->number, eni_dev->irq);
 		error =3D -EAGAIN;
 		goto out;
 	}
 	pci_set_master(eni_dev->pci_dev);
-	if ((error =3D pci_write_config_word(eni_dev->pci_dev,PCI_COMMAND,
+	if ((error =3D pci_write_config_word(eni_dev->pci_dev, PCI_COMMAND,
 	    PCI_COMMAND_MEMORY | PCI_COMMAND_MASTER |
 	    (eni_dev->asic ? PCI_COMMAND_PARITY | PCI_COMMAND_SERR : 0)))) {
 		printk(KERN_ERR DEV_LABEL "(itf %d): can't enable memory+"
-		    "master (0x%02x)\n",dev->number,error);
+		    "master (0x%02x)\n", dev->number, error);
 		goto free_irq;
 	}
-	if ((error =3D pci_write_config_byte(eni_dev->pci_dev,PCI_TONGA_CTRL,
-	    END_SWAP_DMA))) {
+	if ((error =3D pci_write_config_byte(eni_dev->pci_dev, PCI_TONGA_CTRL=
,
+                                           END_SWAP_DMA))) {
 		printk(KERN_ERR DEV_LABEL "(itf %d): can't set endian swap "
-		    "(0x%02x)\n",dev->number,error);
+		    "(0x%02x)\n", dev->number, error);
 		goto free_irq;
 	}
 	/* determine addresses of internal tables */
@@ -1834,16 +1834,16 @@ static int eni_start(struct atm_dev *dev)
 	eni_dev->service =3D eni_dev->tx_dma+NR_DMA_TX*8;
 	buf =3D eni_dev->service+NR_SERVICE*4;
 	DPRINTK("vci 0x%lx,rx 0x%lx, tx 0x%lx,srv 0x%lx,buf 0x%lx\n",
-	     eni_dev->vci,eni_dev->rx_dma,eni_dev->tx_dma,
-	     eni_dev->service,buf);
+	     eni_dev->vci, eni_dev->rx_dma, eni_dev->tx_dma,
+	     eni_dev->service, buf);
 	spin_lock_init(&eni_dev->lock);
-	tasklet_init(&eni_dev->task,eni_tasklet,(unsigned long) dev);
+	tasklet_init(&eni_dev->task, eni_tasklet, (unsigned long) dev);
 	eni_dev->events =3D 0;
 	/* initialize memory management */
 	buffer_mem =3D eni_dev->mem - (buf - eni_dev->ram);
 	eni_dev->free_list_size =3D buffer_mem/MID_MIN_BUF_SIZE/2;
 	eni_dev->free_list =3D kmalloc(
-	    sizeof(struct eni_free)*(eni_dev->free_list_size+1),GFP_KERNEL);
+                sizeof(struct eni_free)*(eni_dev->free_list_size+1), G=
=46P_KERNEL);
 	if (!eni_dev->free_list) {
 		printk(KERN_ERR DEV_LABEL "(itf %d): couldn't get free page\n",
 		    dev->number);
@@ -1851,8 +1851,8 @@ static int eni_start(struct atm_dev *dev)
 		goto free_irq;
 	}
 	eni_dev->free_len =3D 0;
-	eni_put_free(eni_dev,buf,buffer_mem);
-	memset_io(eni_dev->vci,0,16*NR_VCI); /* clear VCI table */
+	eni_put_free(eni_dev, buf, buffer_mem);
+	memset_io(eni_dev->vci, 0, 16*NR_VCI); /* clear VCI table */
 	/*
 	 * byte_addr  free (k)
 	 * 0x00000000     512  VCI table
@@ -1862,7 +1862,7 @@ static int eni_start(struct atm_dev *dev)
 	 * 0x00007000	  484  buffers
 	 * 0x00080000	    0  end (512kB)
 	 */
-	eni_out(0xffffffff,MID_IE);
+	eni_out(0xffffffff, MID_IE);
 	error =3D start_tx(dev);
 	if (error) goto free_list;
 	error =3D start_rx(dev);
@@ -1891,14 +1891,14 @@ static void eni_close(struct atm_vcc *vcc)
 {
 	DPRINTK(">eni_close\n");
 	if (!ENI_VCC(vcc)) return;
-	clear_bit(ATM_VF_READY,&vcc->flags);
+	clear_bit(ATM_VF_READY, &vcc->flags);
 	close_rx(vcc);
 	close_tx(vcc);
 	DPRINTK("eni_close: done waiting\n");
 	/* deallocate memory */
 	kfree(ENI_VCC(vcc));
 	vcc->dev_data =3D NULL;
-	clear_bit(ATM_VF_ADDR,&vcc->flags);
+	clear_bit(ATM_VF_ADDR, &vcc->flags);
 	/*foo();*/
 }
=20
@@ -1911,17 +1911,17 @@ static int eni_open(struct atm_vcc *vcc)
 	int vci =3D vcc->vci;
=20
 	DPRINTK(">eni_open\n");
-	EVENT("eni_open\n",0,0);
-	if (!test_bit(ATM_VF_PARTIAL,&vcc->flags))
+	EVENT("eni_open\n", 0, 0);
+	if (!test_bit(ATM_VF_PARTIAL, &vcc->flags))
 		vcc->dev_data =3D NULL;
 	if (vci !=3D ATM_VPI_UNSPEC && vpi !=3D ATM_VCI_UNSPEC)
-		set_bit(ATM_VF_ADDR,&vcc->flags);
+		set_bit(ATM_VF_ADDR, &vcc->flags);
 	if (vcc->qos.aal !=3D ATM_AAL0 && vcc->qos.aal !=3D ATM_AAL5)
 		return -EINVAL;
-	DPRINTK(DEV_LABEL "(itf %d): open %d.%d\n",vcc->dev->number,vcc->vpi,
-	    vcc->vci);
-	if (!test_bit(ATM_VF_PARTIAL,&vcc->flags)) {
-		eni_vcc =3D kmalloc(sizeof(struct eni_vcc),GFP_KERNEL);
+	DPRINTK(DEV_LABEL "(itf %d): open %d.%d\n", vcc->dev->number, vcc->vp=
i,
+                vcc->vci);
+	if (!test_bit(ATM_VF_PARTIAL, &vcc->flags)) {
+		eni_vcc =3D kmalloc(sizeof(struct eni_vcc), GFP_KERNEL);
 		if (!eni_vcc) return -ENOMEM;
 		vcc->dev_data =3D eni_vcc;
 		eni_vcc->tx =3D NULL; /* for eni_close after open_rx */
@@ -1943,18 +1943,18 @@ static int eni_open(struct atm_vcc *vcc)
 		eni_close(vcc);
 		return error;
 	}
-	set_bit(ATM_VF_READY,&vcc->flags);
+	set_bit(ATM_VF_READY, &vcc->flags);
 	/* should power down SUNI while !ref_count @@@ */
 	return 0;
 }
=20
=20
-static int eni_change_qos(struct atm_vcc *vcc,struct atm_qos *qos,int =
flgs)
+static int eni_change_qos(struct atm_vcc *vcc, struct atm_qos *qos, in=
t flgs)
 {
 	struct eni_dev *eni_dev =3D ENI_DEV(vcc->dev);
 	struct eni_tx *tx =3D ENI_VCC(vcc)->tx;
 	struct sk_buff *skb;
-	int error,rate,rsv,shp;
+	int error, rate, rsv, shp;
=20
 	if (qos->txtp.traffic_class =3D=3D ATM_NONE) return 0;
 	if (tx =3D=3D eni_dev->ubr) return -EBADFD;
@@ -1966,7 +1966,7 @@ static int eni_change_qos(struct atm_vcc *vcc,str=
uct atm_qos *qos,int flgs)
 	if ((flgs & ATM_MF_DEC_SHP) && rate && rate < tx->shaping) shp =3D 1;
 	if ((flgs & ATM_MF_INC_SHP) && (!rate || rate > tx->shaping)) shp =3D=
 1;
 	if (!rsv && !shp) return 0;
-	error =3D reserve_or_set_tx(vcc,&qos->txtp,rsv,shp);
+	error =3D reserve_or_set_tx(vcc, &qos->txtp, rsv, shp);
 	if (error) return error;
 	if (shp && !(flgs & ATM_MF_IMMED)) return 0;
 	/*
@@ -1988,14 +1988,14 @@ static int eni_change_qos(struct atm_vcc *vcc,s=
truct atm_qos *qos,int flgs)
 }
=20
=20
-static int eni_ioctl(struct atm_dev *dev,unsigned int cmd,void __user =
*arg)
+static int eni_ioctl(struct atm_dev *dev, unsigned int cmd, void __use=
r *arg)
 {
 	struct eni_dev *eni_dev =3D ENI_DEV(dev);
=20
 	if (cmd =3D=3D ENI_MEMDUMP) {
 		if (!capable(CAP_NET_ADMIN)) return -EPERM;
 		printk(KERN_WARNING "Please use /proc/atm/" DEV_LABEL ":%d "
-		    "instead of obsolete ioctl ENI_MEMDUMP\n",dev->number);
+		    "instead of obsolete ioctl ENI_MEMDUMP\n", dev->number);
 		dump(dev);
 		return 0;
 	}
@@ -2016,7 +2016,7 @@ static int eni_ioctl(struct atm_dev *dev,unsigned=
 int cmd,void __user *arg)
 	if (cmd =3D=3D ATM_SETCIRANGE) {
 		struct atm_cirange ci;
=20
-		if (copy_from_user(&ci, arg,sizeof(struct atm_cirange)))
+		if (copy_from_user(&ci, arg, sizeof(struct atm_cirange)))
 			return -EFAULT;
 		if ((ci.vpi_bits =3D=3D 0 || ci.vpi_bits =3D=3D ATM_CI_MAX) &&
 		    (ci.vci_bits =3D=3D NR_VCI_LD || ci.vpi_bits =3D=3D ATM_CI_MAX))
@@ -2024,42 +2024,42 @@ static int eni_ioctl(struct atm_dev *dev,unsign=
ed int cmd,void __user *arg)
 		return -EINVAL;
 	}
 	if (!dev->phy->ioctl) return -ENOIOCTLCMD;
-	return dev->phy->ioctl(dev,cmd,arg);
+	return dev->phy->ioctl(dev, cmd, arg);
 }
=20
=20
-static int eni_getsockopt(struct atm_vcc *vcc,int level,int optname,
-    void __user *optval,int optlen)
+static int eni_getsockopt(struct atm_vcc *vcc, int level, int optname,
+                          void __user *optval, int optlen)
 {
 	return -EINVAL;
 }
=20
=20
-static int eni_setsockopt(struct atm_vcc *vcc,int level,int optname,
-    void __user *optval,unsigned int optlen)
+static int eni_setsockopt(struct atm_vcc *vcc, int level, int optname,
+                          void __user *optval, unsigned int optlen)
 {
 	return -EINVAL;
 }
=20
=20
-static int eni_send(struct atm_vcc *vcc,struct sk_buff *skb)
+static int eni_send(struct atm_vcc *vcc, struct sk_buff *skb)
 {
 	enum enq_res res;
=20
 	DPRINTK(">eni_send\n");
 	if (!ENI_VCC(vcc)->tx) {
-		if (vcc->pop) vcc->pop(vcc,skb);
+		if (vcc->pop) vcc->pop(vcc, skb);
 		else dev_kfree_skb(skb);
 		return -EINVAL;
 	}
 	if (!skb) {
 		printk(KERN_CRIT "!skb in eni_send ?\n");
-		if (vcc->pop) vcc->pop(vcc,skb);
+		if (vcc->pop) vcc->pop(vcc, skb);
 		return -EINVAL;
 	}
 	if (vcc->qos.aal =3D=3D ATM_AAL0) {
 		if (skb->len !=3D ATM_CELL_SIZE-1) {
-			if (vcc->pop) vcc->pop(vcc,skb);
+			if (vcc->pop) vcc->pop(vcc, skb);
 			else dev_kfree_skb(skb);
 			return -EINVAL;
 		}
@@ -2071,42 +2071,42 @@ submitted++;
 	res =3D do_tx(skb);
 	tasklet_enable(&ENI_DEV(vcc->dev)->task);
 	if (res =3D=3D enq_ok) return 0;
-	skb_queue_tail(&ENI_VCC(vcc)->tx->backlog,skb);
+	skb_queue_tail(&ENI_VCC(vcc)->tx->backlog, skb);
 backlogged++;
 	tasklet_schedule(&ENI_DEV(vcc->dev)->task);
 	return 0;
 }
=20
-static void eni_phy_put(struct atm_dev *dev,unsigned char value,
-    unsigned long addr)
+static void eni_phy_put(struct atm_dev *dev, unsigned char value,
+                        unsigned long addr)
 {
-	writel(value,ENI_DEV(dev)->phy+addr*4);
+	writel(value, ENI_DEV(dev)->phy+addr*4);
 }
=20
=20
=20
-static unsigned char eni_phy_get(struct atm_dev *dev,unsigned long add=
r)
+static unsigned char eni_phy_get(struct atm_dev *dev, unsigned long ad=
dr)
 {
 	return readl(ENI_DEV(dev)->phy+addr*4);
 }
=20
=20
-static int eni_proc_read(struct atm_dev *dev,loff_t *pos,char *page)
+static int eni_proc_read(struct atm_dev *dev, loff_t *pos, char *page)
 {
 	struct hlist_node *node;
 	struct sock *s;
-	static const char *signal[] =3D { "LOST","unknown","okay" };
+	static const char *signal[] =3D { "LOST", "unknown", "okay" };
 	struct eni_dev *eni_dev =3D ENI_DEV(dev);
 	struct atm_vcc *vcc;
-	int left,i;
+	int left, i;
=20
 	left =3D *pos;
 	if (!left)
-		return sprintf(page,DEV_LABEL "(itf %d) signal %s, %dkB, "
-		    "%d cps remaining\n",dev->number,signal[(int) dev->signal],
-		    eni_dev->mem >> 10,eni_dev->tx_bw);
+		return sprintf(page, DEV_LABEL "(itf %d) signal %s, %dkB, "
+		    "%d cps remaining\n", dev->number, signal[(int) dev->signal],
+		    eni_dev->mem >> 10, eni_dev->tx_bw);
 	if (!--left)
-		return sprintf(page,"%4sBursts: TX"
+		return sprintf(page, "%4sBursts: TX"
 #if !defined(CONFIG_ATM_ENI_BURST_TX_16W) && \
     !defined(CONFIG_ATM_ENI_BURST_TX_8W) && \
     !defined(CONFIG_ATM_ENI_BURST_TX_4W) && \
@@ -2147,24 +2147,24 @@ static int eni_proc_read(struct atm_dev *dev,lo=
ff_t *pos,char *page)
 #ifndef CONFIG_ATM_ENI_TUNE_BURST
 		    " (default)"
 #endif
-		    "\n","");
+		    "\n", "");
 	if (!--left)=20
-		return sprintf(page,"%4sBuffer multipliers: tx %d%%, rx %d%%\n",
-		    "",eni_dev->tx_mult,eni_dev->rx_mult);
+		return sprintf(page, "%4sBuffer multipliers: tx %d%%, rx %d%%\n",
+		    "", eni_dev->tx_mult, eni_dev->rx_mult);
 	for (i =3D 0; i < NR_CHAN; i++) {
 		struct eni_tx *tx =3D eni_dev->tx+i;
=20
 		if (!tx->send) continue;
 		if (!--left) {
-			return sprintf(page,"tx[%d]:    0x%ld-0x%ld "
-			    "(%6ld bytes), rsv %d cps, shp %d cps%s\n",i,
+			return sprintf(page, "tx[%d]:    0x%ld-0x%ld "
+			    "(%6ld bytes), rsv %d cps, shp %d cps%s\n", i,
 			    (unsigned long) (tx->send - eni_dev->ram),
-			    tx->send-eni_dev->ram+tx->words*4-1,tx->words*4,
-			    tx->reserved,tx->shaping,
+			    tx->send-eni_dev->ram+tx->words*4-1, tx->words*4,
+			    tx->reserved, tx->shaping,
 			    tx =3D=3D eni_dev->ubr ? " (UBR)" : "");
 		}
 		if (--left) continue;
-		return sprintf(page,"%10sbacklog %u packets\n","",
+		return sprintf(page, "%10sbacklog %u packets\n", "",
 		    skb_queue_len(&tx->backlog));
 	}
 	read_lock(&vcc_sklist_lock);
@@ -2180,18 +2180,18 @@ static int eni_proc_read(struct atm_dev *dev,lo=
ff_t *pos,char *page)
 				continue;
 			eni_vcc =3D ENI_VCC(vcc);
 			if (--left) continue;
-			length =3D sprintf(page,"vcc %4d: ",vcc->vci);
+			length =3D sprintf(page, "vcc %4d: ", vcc->vci);
 			if (eni_vcc->rx) {
-				length +=3D sprintf(page+length,"0x%ld-0x%ld "
+				length +=3D sprintf(page+length, "0x%ld-0x%ld "
 				    "(%6ld bytes)",
 				    (unsigned long) (eni_vcc->recv - eni_dev->ram),
 				    eni_vcc->recv-eni_dev->ram+eni_vcc->words*4-1,
 				    eni_vcc->words*4);
-				if (eni_vcc->tx) length +=3D sprintf(page+length,", ");
+				if (eni_vcc->tx) length +=3D sprintf(page+length, ", ");
 			}
 			if (eni_vcc->tx)
-				length +=3D sprintf(page+length,"tx[%d], txing %d bytes",
-				    eni_vcc->tx->index,eni_vcc->txing);
+				length +=3D sprintf(page+length, "tx[%d], txing %d bytes",
+				    eni_vcc->tx->index, eni_vcc->txing);
 			page[length] =3D '\n';
 			read_unlock(&vcc_sklist_lock);
 			return length+1;
@@ -2204,8 +2204,8 @@ static int eni_proc_read(struct atm_dev *dev,loff=
_t *pos,char *page)
=20
 		if (--left) continue;
 		offset =3D (unsigned long) eni_dev->ram+eni_dev->base_diff;
-		return sprintf(page,"free      %p-%p (%6d bytes)\n",
-		    fe->start-offset,fe->start-offset+(1 << fe->order)-1,
+		return sprintf(page, "free      %p-%p (%6d bytes)\n",
+		    fe->start-offset, fe->start-offset+(1 << fe->order)-1,
 		    1 << fe->order);
 	}
 	return 0;
@@ -2289,7 +2289,7 @@ static struct pci_device_id eni_pci_tbl[] =3D {
 	{ PCI_VDEVICE(EF, PCI_DEVICE_ID_EF_ATM_ASIC), 1 /* ASIC */ },
 	{ 0, }
 };
-MODULE_DEVICE_TABLE(pci,eni_pci_tbl);
+MODULE_DEVICE_TABLE(pci, eni_pci_tbl);
=20
=20
 static void eni_remove_one(struct pci_dev *pdev)
@@ -2320,7 +2320,7 @@ static int __init eni_init(void)
=20
 	if (sizeof(skb->cb) < sizeof(struct eni_skb_prv)) {
 		printk(KERN_ERR "eni_detect: skb->cb is too small (%Zd < %Zd)\n",
-		    sizeof(skb->cb),sizeof(struct eni_skb_prv));
+		    sizeof(skb->cb), sizeof(struct eni_skb_prv));
 		return -EIO;
 	}
 	return pci_register_driver(&eni_driver);
--=20
1.7.10.4
