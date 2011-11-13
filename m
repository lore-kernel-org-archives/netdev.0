From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH] brcmsmac: Use current logging styles
Date: Sun, 13 Nov 2011 11:41:04 -0800
Message-ID: <1321213264.15834.4.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Arend van Spriel <arend-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Add and use pr_fmt and pr_<level>
Remove useless double parentheses from macros.
Remove function names from format strings, add to pr_debug use.
Coalesce formats.
Remove uncompileable undeclared variable in a DMA_NONE use.

Signed-off-by: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
---
 drivers/net/wireless/brcm80211/brcmsmac/aiutils.c |   14 +-
 drivers/net/wireless/brcm80211/brcmsmac/dma.c     |  145 ++++++++++-----------
 2 files changed, 80 insertions(+), 79 deletions(-)

diff --git a/drivers/net/wireless/brcm80211/brcmsmac/aiutils.c b/drivers/net/wireless/brcm80211/brcmsmac/aiutils.c
index 025fa0e..39e3054 100644
--- a/drivers/net/wireless/brcm80211/brcmsmac/aiutils.c
+++ b/drivers/net/wireless/brcm80211/brcmsmac/aiutils.c
@@ -16,6 +16,8 @@
  * File contents: support functions for PCI/PCIe
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/delay.h>
 #include <linux/pci.h>
 
@@ -349,9 +351,9 @@
 #define PCI_FORCEHT(si)	(PCIE(si) && (si->pub.chip == BCM4716_CHIP_ID))
 
 #ifdef BCMDBG
-#define	SI_MSG(args)	printk args
+#define	SI_MSG(fmt, ...)	pr_debug(fmt, ##__VA_ARGS__)
 #else
-#define	SI_MSG(args)
+#define	SI_MSG(fmt, ...)	no_printk(fmt, ##__VA_ARGS__)
 #endif				/* BCMDBG */
 
 #define	GOODCOREADDR(x, b) \
@@ -1073,7 +1075,7 @@ static struct si_info *ai_doattach(struct si_info *sii,
 
 	/* scan for cores */
 	if (socitype == SOCI_AI) {
-		SI_MSG(("Found chip type AI (0x%08x)\n", w));
+		SI_MSG("Found chip type AI (0x%08x)\n", w);
 		/* pass chipc address instead of original core base */
 		ai_scan(&sii->pub, cc);
 	} else {
@@ -1129,7 +1131,7 @@ static struct si_info *ai_doattach(struct si_info *sii,
 		 * set chipControl register bit 15
 		 */
 		if (sih->chiprev == 0) {
-			SI_MSG(("Applying 43224A0 WARs\n"));
+			SI_MSG("Applying 43224A0 WARs\n");
 			ai_corereg(sih, SI_CC_IDX,
 				   offsetof(struct chipcregs, chipcontrol),
 				   CCTRL43224_GPIO_TOGGLE,
@@ -1138,7 +1140,7 @@ static struct si_info *ai_doattach(struct si_info *sii,
 					   CCTRL_43224A0_12MA_LED_DRIVE);
 		}
 		if (sih->chiprev >= 1) {
-			SI_MSG(("Applying 43224B0+ WARs\n"));
+			SI_MSG("Applying 43224B0+ WARs\n");
 			si_pmu_chipcontrol(sih, 0, CCTRL_43224B0_12MA_LED_DRIVE,
 					   CCTRL_43224B0_12MA_LED_DRIVE);
 		}
@@ -1149,7 +1151,7 @@ static struct si_info *ai_doattach(struct si_info *sii,
 		 * enable 12 mA drive strenth for 4313 and
 		 * set chipControl register bit 1
 		 */
-		SI_MSG(("Applying 4313 WARs\n"));
+		SI_MSG("Applying 4313 WARs\n");
 		si_pmu_chipcontrol(sih, 0, CCTRL_4313_12MA_LED_DRIVE,
 				   CCTRL_4313_12MA_LED_DRIVE);
 	}
diff --git a/drivers/net/wireless/brcm80211/brcmsmac/dma.c b/drivers/net/wireless/brcm80211/brcmsmac/dma.c
index e286fb4..0bb8c37 100644
--- a/drivers/net/wireless/brcm80211/brcmsmac/dma.c
+++ b/drivers/net/wireless/brcm80211/brcmsmac/dma.c
@@ -13,6 +13,9 @@
  * OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN
  * CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
  */
+
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/slab.h>
 #include <linux/delay.h>
 #include <linux/pci.h>
@@ -168,26 +171,25 @@
 
 /* debug/trace */
 #ifdef BCMDBG
-#define	DMA_ERROR(args) \
-	do { \
-		if (!(*di->msg_level & 1)) \
-			; \
-		else \
-			printk args; \
-	} while (0)
-#define	DMA_TRACE(args) \
-	do { \
-		if (!(*di->msg_level & 2)) \
-			; \
-		else \
-			printk args; \
-	} while (0)
+#define	DMA_ERROR(fmt, ...)					\
+do {								\
+	if (*di->msg_level & 1)					\
+		pr_debug("%s: " fmt, __func__, ##__VA_ARGS__);	\
+} while (0)
+#define	DMA_TRACE(fmt, ...)					\
+do {								\
+	if (*di->msg_level & 2)					\
+		pr_debug("%s: " fmt, __func__, ##__VA_ARGS__);	\
+} while (0)
 #else
-#define	DMA_ERROR(args)
-#define	DMA_TRACE(args)
+#define	DMA_ERROR(fmt, ...)			\
+	no_printk(fmt, ##__VA_ARGS__)
+#define	DMA_TRACE(fmt, ...)			\
+	no_printk(fmt, ##__VA_ARGS__)
 #endif				/* BCMDBG */
 
-#define	DMA_NONE(args)
+#define	DMA_NONE(fmt, ...)			\
+	no_printk(fmt, ##__VA_ARGS__)
 
 #define	MAXNAMEL	8	/* 8 char names */
 
@@ -361,7 +363,7 @@ static uint _dma_ctrlflags(struct dma_info *di, uint mask, uint flags)
 	uint dmactrlflags;
 
 	if (di == NULL) {
-		DMA_ERROR(("_dma_ctrlflags: NULL dma handle\n"));
+		DMA_ERROR("NULL dma handle\n");
 		return 0;
 	}
 
@@ -412,13 +414,13 @@ static bool _dma_isaddrext(struct dma_info *di)
 	/* not all tx or rx channel are available */
 	if (di->d64txregs != NULL) {
 		if (!_dma64_addrext(di->d64txregs))
-			DMA_ERROR(("%s: _dma_isaddrext: DMA64 tx doesn't have "
-				   "AE set\n", di->name));
+			DMA_ERROR("%s: DMA64 tx doesn't have AE set\n",
+				  di->name);
 		return true;
 	} else if (di->d64rxregs != NULL) {
 		if (!_dma64_addrext(di->d64rxregs))
-			DMA_ERROR(("%s: _dma_isaddrext: DMA64 rx doesn't have "
-				   "AE set\n", di->name));
+			DMA_ERROR("%s: DMA64 rx doesn't have AE set\n",
+				  di->name);
 		return true;
 	}
 
@@ -519,8 +521,8 @@ static bool dma64_alloc(struct dma_info *di, uint direction)
 		va = dma_ringalloc(di, D64RINGALIGN, size, &align_bits,
 			&alloced, &di->txdpaorig);
 		if (va == NULL) {
-			DMA_ERROR(("%s: dma64_alloc: DMA_ALLOC_CONSISTENT(ntxd)"
-				   " failed\n", di->name));
+			DMA_ERROR("%s: DMA_ALLOC_CONSISTENT(ntxd) failed\n",
+				  di->name);
 			return false;
 		}
 		align = (1 << align_bits);
@@ -533,8 +535,8 @@ static bool dma64_alloc(struct dma_info *di, uint direction)
 		va = dma_ringalloc(di, D64RINGALIGN, size, &align_bits,
 			&alloced, &di->rxdpaorig);
 		if (va == NULL) {
-			DMA_ERROR(("%s: dma64_alloc: DMA_ALLOC_CONSISTENT(nrxd)"
-				   " failed\n", di->name));
+			DMA_ERROR("%s: DMA_ALLOC_CONSISTENT(nrxd) failed\n",
+				  di->name);
 			return false;
 		}
 		align = (1 << align_bits);
@@ -583,11 +585,10 @@ struct dma_pub *dma_attach(char *name, struct si_pub *sih,
 	 */
 	_dma_ctrlflags(di, DMA_CTRL_ROC | DMA_CTRL_PEN, 0);
 
-	DMA_TRACE(("%s: dma_attach: %s flags 0x%x ntxd %d nrxd %d "
-		   "rxbufsize %d rxextheadroom %d nrxpost %d rxoffset %d "
-		   "dmaregstx %p dmaregsrx %p\n", name, "DMA64",
-		   di->dma.dmactrlflags, ntxd, nrxd, rxbufsize,
-		   rxextheadroom, nrxpost, rxoffset, dmaregstx, dmaregsrx));
+	DMA_TRACE("%s: %s flags 0x%x ntxd %d nrxd %d rxbufsize %d rxextheadroom %d nrxpost %d rxoffset %d dmaregstx %p dmaregsrx %p\n",
+		  name, "DMA64",
+		  di->dma.dmactrlflags, ntxd, nrxd, rxbufsize,
+		  rxextheadroom, nrxpost, rxoffset, dmaregstx, dmaregsrx);
 
 	/* make a private copy of our callers name */
 	strncpy(di->name, name, MAXNAMEL);
@@ -645,8 +646,8 @@ struct dma_pub *dma_attach(char *name, struct si_pub *sih,
 		di->dmadesc_align = 4;	/* 16 byte alignment */
 	}
 
-	DMA_NONE(("DMA descriptor align_needed %d, align %d\n",
-		  di->aligndesc_4k, di->dmadesc_align));
+	DMA_NONE("DMA descriptor align_needed %d, align %d\n",
+		 di->aligndesc_4k, di->dmadesc_align);
 
 	/* allocate tx packet pointer vector */
 	if (ntxd) {
@@ -684,21 +685,21 @@ struct dma_pub *dma_attach(char *name, struct si_pub *sih,
 
 	if ((di->ddoffsetlow != 0) && !di->addrext) {
 		if (di->txdpa > SI_PCI_DMA_SZ) {
-			DMA_ERROR(("%s: dma_attach: txdpa 0x%x: addrext not "
-				   "supported\n", di->name, (u32)di->txdpa));
+			DMA_ERROR("%s: txdpa 0x%x: addrext not supported\n",
+				  di->name, (u32)di->txdpa);
 			goto fail;
 		}
 		if (di->rxdpa > SI_PCI_DMA_SZ) {
-			DMA_ERROR(("%s: dma_attach: rxdpa 0x%x: addrext not "
-				   "supported\n", di->name, (u32)di->rxdpa));
+			DMA_ERROR("%s: rxdpa 0x%x: addrext not supported\n",
+				  di->name, (u32)di->rxdpa);
 			goto fail;
 		}
 	}
 
-	DMA_TRACE(("ddoffsetlow 0x%x ddoffsethigh 0x%x dataoffsetlow 0x%x "
-		   "dataoffsethigh " "0x%x addrext %d\n", di->ddoffsetlow,
-		   di->ddoffsethigh, di->dataoffsetlow, di->dataoffsethigh,
-		   di->addrext));
+	DMA_TRACE("ddoffsetlow 0x%x ddoffsethigh 0x%x dataoffsetlow 0x%x dataoffsethigh 0x%x addrext %d\n",
+		  di->ddoffsetlow, di->ddoffsethigh,
+		  di->dataoffsetlow, di->dataoffsethigh,
+		  di->addrext);
 
 	return (struct dma_pub *) di;
 
@@ -744,7 +745,7 @@ void dma_detach(struct dma_pub *pub)
 {
 	struct dma_info *di = (struct dma_info *)pub;
 
-	DMA_TRACE(("%s: dma_detach\n", di->name));
+	DMA_TRACE("%s:\n", di->name);
 
 	/* free dma descriptor rings */
 	if (di->txd64)
@@ -812,7 +813,7 @@ static void _dma_rxenable(struct dma_info *di)
 	uint dmactrlflags = di->dma.dmactrlflags;
 	u32 control;
 
-	DMA_TRACE(("%s: dma_rxenable\n", di->name));
+	DMA_TRACE("%s:\n", di->name);
 
 	control =
 	    (R_REG(&di->d64rxregs->control) & D64_RC_AE) |
@@ -832,7 +833,7 @@ void dma_rxinit(struct dma_pub *pub)
 {
 	struct dma_info *di = (struct dma_info *)pub;
 
-	DMA_TRACE(("%s: dma_rxinit\n", di->name));
+	DMA_TRACE("%s:\n", di->name);
 
 	if (di->nrxd == 0)
 		return;
@@ -926,7 +927,7 @@ int dma_rx(struct dma_pub *pub, struct sk_buff_head *skb_list)
 		return 0;
 
 	len = le16_to_cpu(*(__le16 *) (p->data));
-	DMA_TRACE(("%s: dma_rx len %d\n", di->name, len));
+	DMA_TRACE("%s: dma_rx len %d\n", di->name, len);
 	dma_spin_for_len(len, p);
 
 	/* set actual length */
@@ -953,14 +954,14 @@ int dma_rx(struct dma_pub *pub, struct sk_buff_head *skb_list)
 				  D64_RS0_CD_MASK) -
 				 di->rcvptrbase) & D64_RS0_CD_MASK,
 				struct dma64desc);
-			DMA_ERROR(("dma_rx, rxin %d rxout %d, hw_curr %d\n",
-				   di->rxin, di->rxout, cur));
+			DMA_ERROR("rxin %d rxout %d, hw_curr %d\n",
+				  di->rxin, di->rxout, cur);
 		}
 #endif				/* BCMDBG */
 
 		if ((di->dma.dmactrlflags & DMA_CTRL_RXMULTI) == 0) {
-			DMA_ERROR(("%s: dma_rx: bad frame length (%d)\n",
-				   di->name, len));
+			DMA_ERROR("%s: bad frame length (%d)\n",
+				  di->name, len);
 			skb_queue_walk_safe(&dma_frames, p, next) {
 				skb_unlink(p, &dma_frames);
 				brcmu_pkt_buf_free_skb(p);
@@ -977,7 +978,7 @@ int dma_rx(struct dma_pub *pub, struct sk_buff_head *skb_list)
 
 static bool dma64_rxidle(struct dma_info *di)
 {
-	DMA_TRACE(("%s: dma_rxidle\n", di->name));
+	DMA_TRACE("%s:\n", di->name);
 
 	if (di->nrxd == 0)
 		return true;
@@ -1017,7 +1018,7 @@ bool dma_rxfill(struct dma_pub *pub)
 
 	n = di->nrxpost - nrxdactive(di, rxin, rxout);
 
-	DMA_TRACE(("%s: dma_rxfill: post %d\n", di->name, n));
+	DMA_TRACE("%s: post %d\n", di->name, n);
 
 	if (di->rxbufsize > BCMEXTRAHDROOM)
 		extra_offset = di->rxextrahdrroom;
@@ -1030,11 +1031,9 @@ bool dma_rxfill(struct dma_pub *pub)
 		p = brcmu_pkt_buf_get_skb(di->rxbufsize + extra_offset);
 
 		if (p == NULL) {
-			DMA_ERROR(("%s: dma_rxfill: out of rxbufs\n",
-				   di->name));
+			DMA_ERROR("%s: out of rxbufs\n", di->name);
 			if (i == 0 && dma64_rxidle(di)) {
-				DMA_ERROR(("%s: rxfill64: ring is empty !\n",
-					   di->name));
+				DMA_ERROR("%s: ring is empty !\n", di->name);
 				ring_empty = true;
 			}
 			di->dma.rxnobuf++;
@@ -1079,7 +1078,7 @@ void dma_rxreclaim(struct dma_pub *pub)
 	struct dma_info *di = (struct dma_info *)pub;
 	struct sk_buff *p;
 
-	DMA_TRACE(("%s: dma_rxreclaim\n", di->name));
+	DMA_TRACE("%s:\n", di->name);
 
 	while ((p = _dma_getnextrxp(di, true)))
 		brcmu_pkt_buf_free_skb(p);
@@ -1110,7 +1109,7 @@ void dma_txinit(struct dma_pub *pub)
 	struct dma_info *di = (struct dma_info *)pub;
 	u32 control = D64_XC_XE;
 
-	DMA_TRACE(("%s: dma_txinit\n", di->name));
+	DMA_TRACE("%s:\n", di->name);
 
 	if (di->ntxd == 0)
 		return;
@@ -1142,7 +1141,7 @@ void dma_txsuspend(struct dma_pub *pub)
 {
 	struct dma_info *di = (struct dma_info *)pub;
 
-	DMA_TRACE(("%s: dma_txsuspend\n", di->name));
+	DMA_TRACE("%s:\n", di->name);
 
 	if (di->ntxd == 0)
 		return;
@@ -1154,7 +1153,7 @@ void dma_txresume(struct dma_pub *pub)
 {
 	struct dma_info *di = (struct dma_info *)pub;
 
-	DMA_TRACE(("%s: dma_txresume\n", di->name));
+	DMA_TRACE("%s:\n", di->name);
 
 	if (di->ntxd == 0)
 		return;
@@ -1176,11 +1175,11 @@ void dma_txreclaim(struct dma_pub *pub, enum txd_range range)
 	struct dma_info *di = (struct dma_info *)pub;
 	struct sk_buff *p;
 
-	DMA_TRACE(("%s: dma_txreclaim %s\n", di->name,
-		   (range == DMA_RANGE_ALL) ? "all" :
-		   ((range ==
-		     DMA_RANGE_TRANSMITTED) ? "transmitted" :
-		    "transferred")));
+	DMA_TRACE("%s: %s\n",
+		  di->name,
+		  range == DMA_RANGE_ALL ? "all" :
+		  range == DMA_RANGE_TRANSMITTED ? "transmitted" :
+		  "transferred");
 
 	if (di->txin == di->txout)
 		return;
@@ -1250,7 +1249,7 @@ int dma_txfast(struct dma_pub *pub, struct sk_buff *p0, bool commit)
 	u32 flags = 0;
 	dma_addr_t pa;
 
-	DMA_TRACE(("%s: dma_txfast\n", di->name));
+	DMA_TRACE("%s:\n", di->name);
 
 	txout = di->txout;
 
@@ -1314,7 +1313,7 @@ int dma_txfast(struct dma_pub *pub, struct sk_buff *p0, bool commit)
 	return 0;
 
  outoftxd:
-	DMA_ERROR(("%s: dma_txfast: out of txds !!!\n", di->name));
+	DMA_ERROR("%s: out of txds !!!\n", di->name);
 	brcmu_pkt_buf_free_skb(p0);
 	di->dma.txavail = 0;
 	di->dma.txnobuf++;
@@ -1338,11 +1337,11 @@ struct sk_buff *dma_getnexttxp(struct dma_pub *pub, enum txd_range range)
 	u16 active_desc;
 	struct sk_buff *txp;
 
-	DMA_TRACE(("%s: dma_getnexttxp %s\n", di->name,
-		   (range == DMA_RANGE_ALL) ? "all" :
-		   ((range ==
-		     DMA_RANGE_TRANSMITTED) ? "transmitted" :
-		    "transferred")));
+	DMA_TRACE("%s: %s\n",
+		  di->name,
+		  range == DMA_RANGE_ALL ? "all" :
+		  range == DMA_RANGE_TRANSMITTED ? "transmitted" :
+		  "transferred");
 
 	if (di->ntxd == 0)
 		return NULL;
@@ -1402,8 +1401,8 @@ struct sk_buff *dma_getnexttxp(struct dma_pub *pub, enum txd_range range)
 	return txp;
 
  bogus:
-	DMA_NONE(("dma_getnexttxp: bogus curr: start %d end %d txout %d "
-		  "force %d\n", start, end, di->txout, forceall));
+	DMA_NONE("bogus curr: start %d end %d txout %d\n",
+		 start, end, di->txout);
 	return NULL;
 }
 


--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
