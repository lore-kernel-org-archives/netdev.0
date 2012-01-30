From: Andrea Shepard <andrea@persephoneslair.org>
Subject: [03/22] Cyclades PC300 driver: Fix usage of types
Date: Sun, 29 Jan 2012 18:46:05 -0800
Message-ID: <20120130024605.GD10262@cronus.persephoneslair.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: khc@pm.waw.pl, davem@davemloft.net, mmarek@suse.cz,
	jkosina@suse.cz, joe@perches.com, justinmattock@gmail.com,
	gregkh@suse.de, alan@linux.intel.com, jdmason@kudzu.us
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix non-portable usage of types and remove unnecessary typedefs.  This
patch causes some style warnings due to changes on printk lines with
previously existing violations; for organization's sake these are all
fixed later in patch 10-printk.

Signed-off-by: Andrea Shepard <andrea@persephoneslair.org>

diff --git a/drivers/net/wan/hd64572.h b/drivers/net/wan/hd64572.h
index 727dc6b..2626fea 100644
--- a/drivers/net/wan/hd64572.h
+++ b/drivers/net/wan/hd64572.h
@@ -172,11 +172,11 @@
 
 /* Block Descriptor Structure */
 typedef struct {
-	unsigned long	next;		/* pointer to next block descriptor */
-	unsigned long	ptbuf;		/* buffer pointer */
-	unsigned short	len;		/* data length */
-	unsigned char	status;		/* status */
-	unsigned char	filler[5];	/* alignment filler (16 bytes) */ 
+	u32	next;		/* pointer to next block descriptor */
+	u32	ptbuf;		/* buffer pointer */
+	u16	len;		/* data length */
+	u8	status;		/* status */
+	u8	filler[5];	/* alignment filler (16 bytes) */
 } pcsca_bd_t;
 
 /* Block Descriptor Structure */
diff --git a/drivers/net/wan/pc300.h b/drivers/net/wan/pc300.h
index 54f99a3..bd70320 100644
--- a/drivers/net/wan/pc300.h
+++ b/drivers/net/wan/pc300.h
@@ -103,18 +103,6 @@
 #include "hd64572.h"
 #include "pc300-falc-lh.h"
 
-#ifndef CY_TYPES
-#define CY_TYPES
-#if defined(__alpha__)
-typedef	unsigned long	ucdouble;	/* 64 bits, unsigned */
-typedef	unsigned int	uclong;		/* 32 bits, unsigned */
-#else
-typedef	unsigned long	uclong;		/* 32 bits, unsigned */
-#endif
-typedef	unsigned short	ucshort;	/* 16 bits, unsigned */
-typedef	unsigned char	ucchar;		/* 8 bits, unsigned */
-#endif /* CY_TYPES */
-
 #define PC300_PROTO_MLPPP 1		
 
 #define PC300_KERNEL	"2.4.x"	/* Kernel supported by this driver */
@@ -164,22 +152,25 @@ typedef	unsigned char	ucchar;		/* 8 bits, unsigned */
  * (required to support Alpha systems) *
  ***************************************/
 #ifdef __KERNEL__
-#define cpc_writeb(port,val)	{writeb((ucchar)(val),(ulong)(port)); mb();}
-#define cpc_writew(port,val)	{writew((ushort)(val),(ulong)(port)); mb();}
-#define cpc_writel(port,val)	{writel((uclong)(val),(ulong)(port)); mb();}
+#define cpc_writeb(port, val)	{writeb((u8)(val), \
+				(void __iomem *)(port)); mb(); }
+#define cpc_writew(port, val)	{writew((u16)(val), \
+				(void __iomem *)(port)); mb(); }
+#define cpc_writel(port, val)	{writel((u32)(val), \
+				(void __iomem *)(port)); mb(); }
 
-#define cpc_readb(port)		readb(port)
-#define cpc_readw(port)		readw(port)
-#define cpc_readl(port)		readl(port)
+#define cpc_readb(port)		readb((void __iomem *)(port))
+#define cpc_readw(port)		readw((void __iomem *)(port))
+#define cpc_readl(port)		readl((void __iomem *)(port))
 
 #else /* __KERNEL__ */
-#define cpc_writeb(port,val)	(*(volatile ucchar *)(port) = (ucchar)(val))
-#define cpc_writew(port,val)	(*(volatile ucshort *)(port) = (ucshort)(val))
-#define cpc_writel(port,val)	(*(volatile uclong *)(port) = (uclong)(val))
+#define cpc_writeb(port, val)	(*(u8 *)(port) = (u8)(val))
+#define cpc_writew(port, val)	(*(u16 *)(port) = (u16)(val))
+#define cpc_writel(port, val)	(*(u32 *)(port) = (u32)(val))
 
-#define cpc_readb(port)		(*(volatile ucchar *)(port))
-#define cpc_readw(port)		(*(volatile ucshort *)(port))
-#define cpc_readl(port)		(*(volatile uclong *)(port))
+#define cpc_readb(port)		(*(u8 *)(port))
+#define cpc_readw(port)		(*(u16 *)(port))
+#define cpc_readl(port)		(*(u32 *)(port))
 
 #endif /* __KERNEL__ */
 
@@ -191,15 +182,15 @@ typedef	unsigned char	ucchar;		/* 8 bits, unsigned */
  *      (memory mapped).
  */
 struct RUNTIME_9050 {
-	uclong	loc_addr_range[4];	/* 00-0Ch : Local Address Ranges */
-	uclong	loc_rom_range;		/* 10h : Local ROM Range */
-	uclong	loc_addr_base[4];	/* 14-20h : Local Address Base Addrs */
-	uclong	loc_rom_base;		/* 24h : Local ROM Base */
-	uclong	loc_bus_descr[4];	/* 28-34h : Local Bus Descriptors */
-	uclong	rom_bus_descr;		/* 38h : ROM Bus Descriptor */
-	uclong	cs_base[4];		/* 3C-48h : Chip Select Base Addrs */
-	uclong	intr_ctrl_stat;		/* 4Ch : Interrupt Control/Status */
-	uclong	init_ctrl;		/* 50h : EEPROM ctrl, Init Ctrl, etc */
+	u32 loc_addr_range[4];	/* 00-0Ch : Local Address Ranges */
+	u32 loc_rom_range;	/* 10h : Local ROM Range */
+	u32 loc_addr_base[4];	/* 14-20h : Local Address Base Addrs */
+	u32 loc_rom_base;	/* 24h : Local ROM Base */
+	u32 loc_bus_descr[4];	/* 28-34h : Local Bus Descriptors */
+	u32 rom_bus_descr;	/* 38h : ROM Bus Descriptor */
+	u32 cs_base[4];		/* 3C-48h : Chip Select Base Addrs */
+	u32 intr_ctrl_stat;	/* 4Ch : Interrupt Control/Status */
+	u32 init_ctrl;		/* 50h : EEPROM ctrl, Init Ctrl, etc */
 };
 
 #define PLX_9050_LINT1_ENABLE	0x01
@@ -243,66 +234,66 @@ struct RUNTIME_9050 {
 #define PC300_FALC_MAXLOOP	0x0000ffff	/* for falc_issue_cmd() */
 
 typedef struct falc {
-	ucchar sync;		/* If true FALC is synchronized */
-	ucchar active;		/* if TRUE then already active */
-	ucchar loop_active;	/* if TRUE a line loopback UP was received */
-	ucchar loop_gen;	/* if TRUE a line loopback UP was issued */
+	u8 sync;	/* If true FALC is synchronized */
+	u8 active;	/* if TRUE then already active */
+	u8 loop_active;	/* if TRUE a line loopback UP was received */
+	u8 loop_gen;	/* if TRUE a line loopback UP was issued */
 
-	ucchar num_channels;
-	ucchar offset;		/* 1 for T1, 0 for E1 */
-	ucchar full_bandwidth;
+	u8 num_channels;
+	u8 offset;	/* 1 for T1, 0 for E1 */
+	u8 full_bandwidth;
 
-	ucchar xmb_cause;
-	ucchar multiframe_mode;
+	u8 xmb_cause;
+	u8 multiframe_mode;
 
 	/* Statistics */
-	ucshort pden;	/* Pulse Density violation count */
-	ucshort los;	/* Loss of Signal count */
-	ucshort losr;	/* Loss of Signal recovery count */
-	ucshort lfa;	/* Loss of frame alignment count */
-	ucshort farec;	/* Frame Alignment Recovery count */
-	ucshort lmfa;	/* Loss of multiframe alignment count */
-	ucshort ais;	/* Remote Alarm indication Signal count */
-	ucshort sec;	/* One-second timer */
-	ucshort es;	/* Errored second */
-	ucshort rai;	/* remote alarm received */
-	ucshort bec;
-	ucshort fec;
-	ucshort cvc;
-	ucshort cec;
-	ucshort ebc;
+	u16 pden;	/* Pulse Density violation count */
+	u16 los;	/* Loss of Signal count */
+	u16 losr;	/* Loss of Signal recovery count */
+	u16 lfa;	/* Loss of frame alignment count */
+	u16 farec;	/* Frame Alignment Recovery count */
+	u16 lmfa;	/* Loss of multiframe alignment count */
+	u16 ais;	/* Remote Alarm indication Signal count */
+	u16 sec;	/* One-second timer */
+	u16 es;		/* Errored second */
+	u16 rai;	/* remote alarm received */
+	u16 bec;
+	u16 fec;
+	u16 cvc;
+	u16 cec;
+	u16 ebc;
 
 	/* Status */
-	ucchar red_alarm;
-	ucchar blue_alarm;
-	ucchar loss_fa;
-	ucchar yellow_alarm;
-	ucchar loss_mfa;
-	ucchar prbs;
+	u8 red_alarm;
+	u8 blue_alarm;
+	u8 loss_fa;
+	u8 yellow_alarm;
+	u8 loss_mfa;
+	u8 prbs;
 } falc_t;
 
 typedef struct falc_status {
-	ucchar sync;  /* If true FALC is synchronized */
-	ucchar red_alarm;
-	ucchar blue_alarm;
-	ucchar loss_fa;
-	ucchar yellow_alarm;
-	ucchar loss_mfa;
-	ucchar prbs;
+	u8 sync;	/* If true FALC is synchronized */
+	u8 red_alarm;
+	u8 blue_alarm;
+	u8 loss_fa;
+	u8 yellow_alarm;
+	u8 loss_mfa;
+	u8 prbs;
 } falc_status_t;
 
 typedef struct rsv_x21_status {
-	ucchar dcd;
-	ucchar dsr;
-	ucchar cts;
-	ucchar rts;
-	ucchar dtr;
+	u8 dcd;
+	u8 dsr;
+	u8 cts;
+	u8 rts;
+	u8 dtr;
 } rsv_x21_status_t;
 
 typedef struct pc300stats {
 	int hw_type;
-	uclong line_on;
-	uclong line_off;
+	u32 line_on;
+	u32 line_off;
 	struct net_device_stats gen_stats;
 	falc_t te_stats;
 } pc300stats_t;
@@ -320,15 +311,15 @@ typedef struct pc300loopback {
 
 typedef struct pc300patterntst {
 	char patrntst_on;       /* 0 - off; 1 - on; 2 - read num_errors */
-	ucshort num_errors;
+	u16 num_errors;
 } pc300patterntst_t;
 
 typedef struct pc300dev {
 	void *if_ptr;		/* General purpose pointer */
 	struct pc300ch *chan;
-	ucchar trace_on;
-	uclong line_on;		/* DCD(X.21, RSV) / sync(TE) change counters */
-	uclong line_off;
+	u8 trace_on;
+	u32 line_on;		/* DCD(X.21, RSV) / sync(TE) change counters */
+	u32 line_off;
 #ifdef __KERNEL__
 	char name[16];
 	hdlc_device *hdlc;
@@ -349,43 +340,43 @@ typedef struct pc300hw {
 	int bus;		/* Bus (PCI, PMC, etc.) */
 	int nchan;		/* number of channels */
 	int irq;		/* interrupt request level */
-	uclong clock;		/* Board clock */
-	ucchar cpld_id;		/* CPLD ID (TE only) */
-	ucshort cpld_reg1;	/* CPLD reg 1 (TE only) */
-	ucshort cpld_reg2;	/* CPLD reg 2 (TE only) */
-	ucshort gpioc_reg;	/* PLX GPIOC reg */
-	ucshort intctl_reg;	/* PLX Int Ctrl/Status reg */
-	uclong iophys;		/* PLX registers I/O base */
-	uclong iosize;		/* PLX registers I/O size */
-	uclong plxphys;		/* PLX registers MMIO base (physical) */
-	uclong plxbase;		/* PLX registers MMIO base (virtual) */
-	uclong plxsize;		/* PLX registers MMIO size */
-	uclong scaphys;		/* SCA registers MMIO base (physical) */
-	uclong scabase;		/* SCA registers MMIO base (virtual) */
-	uclong scasize;		/* SCA registers MMIO size */
-	uclong ramphys;		/* On-board RAM MMIO base (physical) */
-	uclong rambase;		/* On-board RAM MMIO base (virtual) */
-	uclong alloc_ramsize;	/* RAM MMIO size allocated by the PCI bridge */
-	uclong ramsize;		/* On-board RAM MMIO size */
-	uclong falcphys;	/* FALC registers MMIO base (physical) */
-	uclong falcbase;	/* FALC registers MMIO base (virtual) */
-	uclong falcsize;	/* FALC registers MMIO size */
+	u32 clock;		/* Board clock */
+	u8 cpld_id;		/* CPLD ID (TE only) */
+	u16 cpld_reg1;		/* CPLD reg 1 (TE only) */
+	u16 cpld_reg2;		/* CPLD reg 2 (TE only) */
+	u16 gpioc_reg;		/* PLX GPIOC reg */
+	u16 intctl_reg;		/* PLX Int Ctrl/Status reg */
+	phys_addr_t iophys;	/* PLX registers I/O base */
+	u32 iosize;		/* PLX registers I/O size */
+	phys_addr_t plxphys;	/* PLX registers MMIO base (physical) */
+	void __iomem *plxbase;	/* PLX registers MMIO base (virtual) */
+	u32 plxsize;		/* PLX registers MMIO size */
+	phys_addr_t scaphys;	/* SCA registers MMIO base (physical) */
+	void __iomem *scabase;	/* SCA registers MMIO base (virtual) */
+	u32 scasize;		/* SCA registers MMIO size */
+	phys_addr_t ramphys;	/* On-board RAM MMIO base (physical) */
+	void __iomem *rambase;	/* On-board RAM MMIO base (virtual) */
+	u32 alloc_ramsize;	/* RAM MMIO size allocated by the PCI bridge */
+	u32 ramsize;		/* On-board RAM MMIO size */
+	phys_addr_t falcphys;	/* FALC registers MMIO base (physical) */
+	void __iomem *falcbase;/* FALC registers MMIO base (virtual) */
+	u32 falcsize;		/* FALC registers MMIO size */
 } pc300hw_t;
 
 typedef struct pc300chconf {
 	sync_serial_settings	phys_settings;	/* Clock type/rate (in bps), 
 						   loopback mode */
 	raw_hdlc_proto		proto_settings;	/* Encoding, parity (CRC) */
-	uclong media;		/* HW media (RS232, V.35, etc.) */
-	uclong proto;		/* Protocol (PPP, X.25, etc.) */
-	ucchar monitor;		/* Monitor mode (0 = off, !0 = on) */
+	u32 media;		/* HW media (RS232, V.35, etc.) */
+	u32 proto;		/* Protocol (PPP, X.25, etc.) */
+	u8 monitor;		/* Monitor mode (0 = off, !0 = on) */
 
 	/* TE-specific parameters */
-	ucchar lcode;		/* Line Code (AMI, B8ZS, etc.) */
-	ucchar fr_mode;		/* Frame Mode (ESF, D4, etc.) */
-	ucchar lbo;		/* Line Build Out */
-	ucchar rx_sens;		/* Rx Sensitivity (long- or short-haul) */
-	uclong tslot_bitmap;	/* bit[i]=1  =>  timeslot _i_ is active */
+	u8 lcode;		/* Line Code (AMI, B8ZS, etc.) */
+	u8 fr_mode;		/* Frame Mode (ESF, D4, etc.) */
+	u8 lbo;			/* Line Build Out */
+	u8 rx_sens;		/* Rx Sensitivity (long- or short-haul) */
+	u32 tslot_bitmap;	/* bit[i]=1  =>  timeslot _i_ is active */
 } pc300chconf_t;
 
 typedef struct pc300ch {
@@ -393,12 +384,12 @@ typedef struct pc300ch {
 	int channel;
 	pc300dev_t d;
 	pc300chconf_t conf;
-	ucchar tx_first_bd;	/* First TX DMA block descr. w/ data */
-	ucchar tx_next_bd;	/* Next free TX DMA block descriptor */
-	ucchar rx_first_bd;	/* First free RX DMA block descriptor */
-	ucchar rx_last_bd;	/* Last free RX DMA block descriptor */
-	ucchar nfree_tx_bd;	/* Number of free TX DMA block descriptors */
-	falc_t falc;		/* FALC structure (TE only) */
+	u8 tx_first_bd;	/* First TX DMA block descr. w/ data */
+	u8 tx_next_bd;	/* Next free TX DMA block descriptor */
+	u8 rx_first_bd;	/* First free RX DMA block descriptor */
+	u8 rx_last_bd;	/* Last free RX DMA block descriptor */
+	u8 nfree_tx_bd;	/* Number of free TX DMA block descriptors */
+	falc_t falc;	/* FALC structure (TE only) */
 } pc300ch_t;
 
 typedef struct pc300 {
diff --git a/drivers/net/wan/pc300_drv.c b/drivers/net/wan/pc300_drv.c
index 1d2bd69..b5781e9 100644
--- a/drivers/net/wan/pc300_drv.c
+++ b/drivers/net/wan/pc300_drv.c
@@ -288,8 +288,8 @@ static void tx_dma_buf_check(pc300_t *, int);
 static void rx_dma_buf_check(pc300_t *, int);
 static irqreturn_t cpc_intr(int, void *, struct pt_regs *);
 static struct net_device_stats *cpc_get_stats(struct net_device *);
-static int clock_rate_calc(uclong, uclong, int *);
-static uclong detect_ram(pc300_t *);
+static int clock_rate_calc(u32, u32, int *);
+static u32 detect_ram(pc300_t *);
 static void plx_init(pc300_t *);
 static void cpc_trace(struct net_device *, struct sk_buff *, char);
 static int cpc_attach(hdlc_device *, unsigned short, unsigned short);
@@ -309,14 +309,14 @@ static void tx_dma_buf_pt_init(pc300_t * card, int ch)
 {
 	int i;
 	int ch_factor = ch * N_DMA_TX_BUF;
-	volatile pcsca_bd_t *ptdescr = (pcsca_bd_t *) (card->hw.rambase
+	pcsca_bd_t __iomem *ptdescr = (card->hw.rambase
 			               + DMA_TX_BD_BASE + ch_factor * sizeof(pcsca_bd_t));
 
 	for (i = 0; i < N_DMA_TX_BUF; i++, ptdescr++) {
-		cpc_writel(&ptdescr->next, (uclong) (DMA_TX_BD_BASE +
+		cpc_writel(&ptdescr->next, (u32)(DMA_TX_BD_BASE +
 			(ch_factor + ((i + 1) & (N_DMA_TX_BUF - 1))) * sizeof(pcsca_bd_t)));
-		cpc_writel(&ptdescr->ptbuf, 
-						(uclong) (DMA_TX_BASE + (ch_factor + i) * BD_DEF_LEN));
+		cpc_writel(&ptdescr->ptbuf,
+			   (u32)(DMA_TX_BASE + (ch_factor + i) * BD_DEF_LEN));
 	}
 }
 
@@ -324,7 +324,7 @@ static void tx_dma_buf_init(pc300_t * card, int ch)
 {
 	int i;
 	int ch_factor = ch * N_DMA_TX_BUF;
-	volatile pcsca_bd_t *ptdescr = (pcsca_bd_t *) (card->hw.rambase
+	pcsca_bd_t __iomem *ptdescr = (card->hw.rambase
 			       + DMA_TX_BD_BASE + ch_factor * sizeof(pcsca_bd_t));
 
 	for (i = 0; i < N_DMA_TX_BUF; i++, ptdescr++) {
@@ -339,14 +339,15 @@ static void rx_dma_buf_pt_init(pc300_t * card, int ch)
 {
 	int i;
 	int ch_factor = ch * N_DMA_RX_BUF;
-	volatile pcsca_bd_t *ptdescr = (pcsca_bd_t *) (card->hw.rambase
+	pcsca_bd_t __iomem *ptdescr = (card->hw.rambase
 				       + DMA_RX_BD_BASE + ch_factor * sizeof(pcsca_bd_t));
 
 	for (i = 0; i < N_DMA_RX_BUF; i++, ptdescr++) {
-		cpc_writel(&ptdescr->next, (uclong) (DMA_RX_BD_BASE +
-	     	(ch_factor + ((i + 1) & (N_DMA_RX_BUF - 1))) * sizeof(pcsca_bd_t)));
+		cpc_writel(&ptdescr->next, (u32)(DMA_RX_BD_BASE +
+			(ch_factor + ((i + 1) & (N_DMA_RX_BUF - 1))) *
+			sizeof(pcsca_bd_t)));
 		cpc_writel(&ptdescr->ptbuf,
-			   (uclong) (DMA_RX_BASE + (ch_factor + i) * BD_DEF_LEN));
+			   (u32)(DMA_RX_BASE + (ch_factor + i) * BD_DEF_LEN));
 	}
 }
 
@@ -354,7 +355,7 @@ static void rx_dma_buf_init(pc300_t * card, int ch)
 {
 	int i;
 	int ch_factor = ch * N_DMA_RX_BUF;
-	volatile pcsca_bd_t *ptdescr = (pcsca_bd_t *) (card->hw.rambase
+	pcsca_bd_t __iomem *ptdescr = (card->hw.rambase
 				       + DMA_RX_BD_BASE + ch_factor * sizeof(pcsca_bd_t));
 
 	for (i = 0; i < N_DMA_RX_BUF; i++, ptdescr++) {
@@ -367,10 +368,10 @@ static void rx_dma_buf_init(pc300_t * card, int ch)
 
 static void tx_dma_buf_check(pc300_t * card, int ch)
 {
-	volatile pcsca_bd_t *ptdescr;
+	pcsca_bd_t __iomem *ptdescr;
 	int i;
-	ucshort first_bd = card->chan[ch].tx_first_bd;
-	ucshort next_bd = card->chan[ch].tx_next_bd;
+	u16 first_bd = card->chan[ch].tx_first_bd;
+	u16 next_bd = card->chan[ch].tx_next_bd;
 
 	printk("#CH%d: f_bd = %d(0x%08x), n_bd = %d(0x%08x)\n", ch,
 	       first_bd, TX_BD_ADDR(ch, first_bd),
@@ -380,9 +381,9 @@ static void tx_dma_buf_check(pc300_t * card, int ch)
 	     i != ((next_bd + 1) & (N_DMA_TX_BUF - 1));
 	     i = (i + 1) & (N_DMA_TX_BUF - 1), 
 		 ptdescr = (pcsca_bd_t *) (card->hw.rambase + TX_BD_ADDR(ch, i))) {
-		printk("\n CH%d TX%d: next=0x%lx, ptbuf=0x%lx, ST=0x%x, len=%d",
-		       ch, i, (uclong) cpc_readl(&ptdescr->next),
-		       (uclong) cpc_readl(&ptdescr->ptbuf),
+		printk("\n CH%d TX%d: next=0x%08x, ptbuf=0x%08x, ST=0x%2x, len=%d",
+		       ch, i, (u32) cpc_readl(&ptdescr->next),
+		       (u32) cpc_readl(&ptdescr->ptbuf),
 		       cpc_readb(&ptdescr->status), cpc_readw(&ptdescr->len));
 	}
 	printk("\n");
@@ -392,24 +393,24 @@ static void tx_dma_buf_check(pc300_t * card, int ch)
 /* Show all TX buffer descriptors */
 static void tx1_dma_buf_check(pc300_t * card, int ch)
 {
-	volatile pcsca_bd_t *ptdescr;
+	pcsca_bd_t __iomem *ptdescr;
 	int i;
-	ucshort first_bd = card->chan[ch].tx_first_bd;
-	ucshort next_bd = card->chan[ch].tx_next_bd;
-	uclong scabase = card->hw.scabase;
+	u16 first_bd = card->chan[ch].tx_first_bd;
+	u16 next_bd = card->chan[ch].tx_next_bd;
+	uintptr_t scabase = card->hw.scabase;
 
 	printk ("\nnfree_tx_bd = %d \n", card->chan[ch].nfree_tx_bd);
 	printk("#CH%d: f_bd = %d(0x%08x), n_bd = %d(0x%08x)\n", ch,
-	       first_bd, TX_BD_ADDR(ch, first_bd),
-	       next_bd, TX_BD_ADDR(ch, next_bd));
-	printk("TX_CDA=0x%08lx, TX_EDA=0x%08lx\n",
-	       (uclong) cpc_readl(scabase + DTX_REG(CDAL, ch)),
-	       (uclong) cpc_readl(scabase + DTX_REG(EDAL, ch)));
+	       first_bd, (u32)TX_BD_ADDR(ch, first_bd),
+	       next_bd, (u32)TX_BD_ADDR(ch, next_bd));
+	printk("TX_CDA=0x%08x, TX_EDA=0x%08x\n",
+	       (u32)(cpc_readl(scabase + DTX_REG(CDAL, ch))),
+	       (u32)(cpc_readl(scabase + DTX_REG(EDAL, ch))));
 	for (i = 0; i < N_DMA_TX_BUF; i++) {
-		ptdescr = (pcsca_bd_t *) (card->hw.rambase + TX_BD_ADDR(ch, i));
-		printk("\n CH%d TX%d: next=0x%lx, ptbuf=0x%lx, ST=0x%x, len=%d",
-		       ch, i, (uclong) cpc_readl(&ptdescr->next),
-		       (uclong) cpc_readl(&ptdescr->ptbuf),
+		ptdescr = (card->hw.rambase + TX_BD_ADDR(ch, i));
+		printk("\n CH%d TX%d: next=0x%x, ptbuf=0x%x, ST=0x%x, len=%d",
+		       ch, i, (u32) cpc_readl(&ptdescr->next),
+		       (u32) cpc_readl(&ptdescr->ptbuf),
 		       cpc_readb(&ptdescr->status), cpc_readw(&ptdescr->len));
 	}
 	printk("\n");
@@ -418,10 +419,10 @@ static void tx1_dma_buf_check(pc300_t * card, int ch)
 			 
 static void rx_dma_buf_check(pc300_t * card, int ch)
 {
-	volatile pcsca_bd_t *ptdescr;
+	pcsca_bd_t __iomem *ptdescr;
 	int i;
-	ucshort first_bd = card->chan[ch].rx_first_bd;
-	ucshort last_bd = card->chan[ch].rx_last_bd;
+	u16 first_bd = card->chan[ch].rx_first_bd;
+	u16 last_bd = card->chan[ch].rx_last_bd;
 	int ch_factor;
 
 	ch_factor = ch * N_DMA_RX_BUF;
@@ -430,21 +431,21 @@ static void rx_dma_buf_check(pc300_t * card, int ch)
 					      DMA_RX_BD_BASE + ch_factor * sizeof(pcsca_bd_t));
 	     i < N_DMA_RX_BUF; i++, ptdescr++) {
 		if (cpc_readb(&ptdescr->status) & DST_OSB)
-			printk ("\n CH%d RX%d: next=0x%lx, ptbuf=0x%lx, ST=0x%x, len=%d",
-				 ch, i, (uclong) cpc_readl(&ptdescr->next),
-				 (uclong) cpc_readl(&ptdescr->ptbuf),
-				 cpc_readb(&ptdescr->status),
-				 cpc_readw(&ptdescr->len));
+			printk("\n CH%d RX%d: next=0x%08x, ptbuf=0x%08x, ST=0x%2x, len=%d",
+				ch, i, (u32) cpc_readl(&ptdescr->next),
+				(u32) cpc_readl(&ptdescr->ptbuf),
+				cpc_readb(&ptdescr->status),
+				cpc_readw(&ptdescr->len));
 	}
 	printk("\n");
 }
 
 int dma_get_rx_frame_size(pc300_t * card, int ch)
 {
-	volatile pcsca_bd_t *ptdescr;
-	ucshort first_bd = card->chan[ch].rx_first_bd;
+	pcsca_bd_t __iomem *ptdescr;
+	u16 first_bd = card->chan[ch].rx_first_bd;
 	int rcvd = 0;
-	volatile ucchar status;
+	u8 status;
 
 	ptdescr = (pcsca_bd_t *)(card->hw.rambase + RX_BD_ADDR(ch, first_bd));
 	while ((status = cpc_readb(&ptdescr->status)) & DST_OSB) {
@@ -467,9 +468,9 @@ int dma_get_rx_frame_size(pc300_t * card, int ch)
 int dma_buf_write(pc300_t * card, int ch, ucchar * ptdata, int len)
 {
 	int i, nchar;
-	volatile pcsca_bd_t *ptdescr;
+	pcsca_bd_t __iomem *ptdescr;
 	int tosend = len;
-	ucchar nbuf = ((len - 1) / BD_DEF_LEN) + 1;
+	u8 nbuf = ((len - 1) / BD_DEF_LEN) + 1;
 
 	if (nbuf >= card->chan[ch].nfree_tx_bd) {
 		return -ENOMEM;
@@ -480,7 +481,8 @@ int dma_buf_write(pc300_t * card, int ch, ucchar * ptdata, int len)
 					  TX_BD_ADDR(ch, card->chan[ch].tx_next_bd));
 		nchar = cpc_min(BD_DEF_LEN, tosend);
 		if (cpc_readb(&ptdescr->status) & DST_OSB) {
-			memcpy_toio((void *)(card->hw.rambase + cpc_readl(&ptdescr->ptbuf)),
+			memcpy_toio((card->hw.rambase +
+				cpc_readl(&ptdescr->ptbuf)),
 				    &ptdata[len - tosend], nchar);
 			cpc_writew(&ptdescr->len, nchar);
 			card->chan[ch].nfree_tx_bd--;
@@ -509,11 +511,11 @@ int dma_buf_read(pc300_t * card, int ch, struct sk_buff *skb)
 {
 	int nchar;
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
-	volatile pcsca_bd_t *ptdescr;
+	pcsca_bd_t __iomem *ptdescr;
 	int rcvd = 0;
-	volatile ucchar status;
+	u8 status;
 
-	ptdescr = (pcsca_bd_t *) (card->hw.rambase +
+	ptdescr = (pcsca_bd_t *)(card->hw.rambase +
 				  RX_BD_ADDR(ch, chan->rx_first_bd));
 	while ((status = cpc_readb(&ptdescr->status)) & DST_OSB) {
 		nchar = cpc_readw(&ptdescr->len);
@@ -564,9 +566,9 @@ int dma_buf_read(pc300_t * card, int ch, struct sk_buff *skb)
 
 void tx_dma_stop(pc300_t * card, int ch)
 {
-	uclong scabase = card->hw.scabase;
-	ucchar drr_ena_bit = 1 << (5 + 2 * ch);
-	ucchar drr_rst_bit = 1 << (1 + 2 * ch);
+	uintptr_t scabase = (uintptr_t)(card->hw.scabase);
+	u8 drr_ena_bit = 1 << (5 + 2 * ch);
+	u8 drr_rst_bit = 1 << (1 + 2 * ch);
 
 	/* Disable DMA */
 	cpc_writeb(scabase + DRR, drr_ena_bit);
@@ -575,9 +577,9 @@ void tx_dma_stop(pc300_t * card, int ch)
 
 void rx_dma_stop(pc300_t * card, int ch)
 {
-	uclong scabase = card->hw.scabase;
-	ucchar drr_ena_bit = 1 << (4 + 2 * ch);
-	ucchar drr_rst_bit = 1 << (2 * ch);
+	uintptr_t scabase = (uintptr_t)(card->hw.scabase);
+	u8 drr_ena_bit = 1 << (4 + 2 * ch);
+	u8 drr_rst_bit = 1 << (2 * ch);
 
 	/* Disable DMA */
 	cpc_writeb(scabase + DRR, drr_ena_bit);
@@ -586,7 +588,7 @@ void rx_dma_stop(pc300_t * card, int ch)
 
 void rx_dma_start(pc300_t * card, int ch)
 {
-	uclong scabase = card->hw.scabase;
+	uintptr_t scabase = (uintptr_t)(card->hw.scabase);
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	
 	/* Start DMA */
@@ -611,7 +613,7 @@ void rx_dma_start(pc300_t * card, int ch)
 /*************************/
 void falc_issue_cmd(pc300_t * card, int ch, ucchar cmd)
 {
-	uclong falcbase = card->hw.falcbase;
+	uintptr_t falcbase = (uintptr_t)(card->hw.falcbase);
 	unsigned long i = 0;
 
 	while (cpc_readb(falcbase + F_REG(SIS, ch)) & SIS_CEC) {
@@ -629,7 +631,7 @@ void falc_intr_enable(pc300_t * card, int ch)
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	pc300chconf_t *conf = (pc300chconf_t *) & chan->conf;
 	falc_t *pfalc = (falc_t *) & chan->falc;
-	uclong falcbase = card->hw.falcbase;
+	uintptr_t falcbase = (uintptr_t)(card->hw.falcbase);
 
 	/* Interrupt pins are open-drain */
 	cpc_writeb(falcbase + F_REG(IPC, ch),
@@ -676,8 +678,8 @@ void falc_intr_enable(pc300_t * card, int ch)
 
 void falc_open_timeslot(pc300_t * card, int ch, int timeslot)
 {
-	uclong falcbase = card->hw.falcbase;
-	ucchar tshf = card->chan[ch].falc.offset;
+	uintptr_t falcbase = (uintptr_t)(card->hw.falcbase);
+	u8 tshf = card->chan[ch].falc.offset;
 
 	cpc_writeb(falcbase + F_REG((ICB1 + (timeslot - tshf) / 8), ch),
 		   cpc_readb(falcbase + F_REG((ICB1 + (timeslot - tshf) / 8), ch)) & 
@@ -692,8 +694,8 @@ void falc_open_timeslot(pc300_t * card, int ch, int timeslot)
 
 void falc_close_timeslot(pc300_t * card, int ch, int timeslot)
 {
-	uclong falcbase = card->hw.falcbase;
-	ucchar tshf = card->chan[ch].falc.offset;
+	uintptr_t falcbase = (uintptr_t)(card->hw.falcbase);
+	u8 tshf = card->chan[ch].falc.offset;
 
 	cpc_writeb(falcbase + F_REG((ICB1 + (timeslot - tshf) / 8), ch),
 		   cpc_readb(falcbase + F_REG((ICB1 + (timeslot - tshf) / 8), ch)) | 
@@ -710,7 +712,7 @@ void falc_close_all_timeslots(pc300_t * card, int ch)
 {
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	pc300chconf_t *conf = (pc300chconf_t *) & chan->conf;
-	uclong falcbase = card->hw.falcbase;
+	uintptr_t falcbase = (uintptr_t)(card->hw.falcbase);
 
 	cpc_writeb(falcbase + F_REG(ICB1, ch), 0xff);
 	cpc_writeb(falcbase + F_REG(TTR1, ch), 0);
@@ -732,7 +734,7 @@ void falc_open_all_timeslots(pc300_t * card, int ch)
 {
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	pc300chconf_t *conf = (pc300chconf_t *) & chan->conf;
-	uclong falcbase = card->hw.falcbase;
+	uintptr_t falcbase = (uintptr_t)(card->hw.falcbase);
 
 	cpc_writeb(falcbase + F_REG(ICB1, ch), 0);
 	if (conf->fr_mode == PC300_FR_UNFRAMED) {
@@ -813,8 +815,8 @@ void falc_init_t1(pc300_t * card, int ch)
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	pc300chconf_t *conf = (pc300chconf_t *) & chan->conf;
 	falc_t *pfalc = (falc_t *) & chan->falc;
-	uclong falcbase = card->hw.falcbase;
-	ucchar dja = (ch ? (LIM2_DJA2 | LIM2_DJA1) : 0);
+	uintptr_t falcbase = (uintptr_t)(card->hw.falcbase);
+	u8 dja = (ch ? (LIM2_DJA2 | LIM2_DJA1) : 0);
 
 	/* Switch to T1 mode (PCM 24) */
 	cpc_writeb(falcbase + F_REG(FMR1, ch), FMR1_PMOD);
@@ -982,8 +984,8 @@ void falc_init_e1(pc300_t * card, int ch)
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	pc300chconf_t *conf = (pc300chconf_t *) & chan->conf;
 	falc_t *pfalc = (falc_t *) & chan->falc;
-	uclong falcbase = card->hw.falcbase;
-	ucchar dja = (ch ? (LIM2_DJA2 | LIM2_DJA1) : 0);
+	uintptr_t falcbase = (uintptr_t)(card->hw.falcbase);
+	u8 dja = (ch ? (LIM2_DJA2 | LIM2_DJA1) : 0);
 
 	/* Switch to E1 mode (PCM 30) */
 	cpc_writeb(falcbase + F_REG(FMR1, ch),
@@ -1159,7 +1161,7 @@ void falc_init_e1(pc300_t * card, int ch)
 
 void falc_init_hdlc(pc300_t * card, int ch)
 {
-	uclong falcbase = card->hw.falcbase;
+	uintptr_t falcbase = (uintptr_t)(card->hw.falcbase);
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	pc300chconf_t *conf = (pc300chconf_t *) & chan->conf;
 
@@ -1188,8 +1190,8 @@ void te_config(pc300_t * card, int ch)
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	pc300chconf_t *conf = (pc300chconf_t *) & chan->conf;
 	falc_t *pfalc = (falc_t *) & chan->falc;
-	uclong falcbase = card->hw.falcbase;
-	ucchar dummy;
+	uintptr_t falcbase = (uintptr_t)(card->hw.falcbase);
+	u8 dummy;
 	unsigned long flags;
 
 	memset(pfalc, 0, sizeof(falc_t));
@@ -1248,7 +1250,7 @@ void falc_check_status(pc300_t * card, int ch, unsigned char frs0)
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	pc300chconf_t *conf = (pc300chconf_t *) & chan->conf;
 	falc_t *pfalc = (falc_t *) & chan->falc;
-	uclong falcbase = card->hw.falcbase;
+	uintptr_t falcbase = (uintptr_t)(card->hw.falcbase);
 
 	/* Verify LOS */
 	if (frs0 & FRS0_LOS) {
@@ -1404,8 +1406,8 @@ void falc_update_stats(pc300_t * card, int ch)
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	pc300chconf_t *conf = (pc300chconf_t *) & chan->conf;
 	falc_t *pfalc = (falc_t *) & chan->falc;
-	uclong falcbase = card->hw.falcbase;
-	ucshort counter;
+	uintptr_t falcbase = (uintptr_t)(card->hw.falcbase);
+	u16 counter;
 
 	counter = cpc_readb(falcbase + F_REG(FECL, ch));
 	counter |= cpc_readb(falcbase + F_REG(FECH, ch)) << 8;
@@ -1457,7 +1459,7 @@ void falc_remote_loop(pc300_t * card, int ch, int loop_on)
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	pc300chconf_t *conf = (pc300chconf_t *) & chan->conf;
 	falc_t *pfalc = (falc_t *) & chan->falc;
-	uclong falcbase = card->hw.falcbase;
+	uintptr_t falcbase = (uintptr_t)(card->hw.falcbase);
 
 	if (loop_on) {
 		// EVENT_FALC_ABNORMAL
@@ -1501,7 +1503,7 @@ void falc_local_loop(pc300_t * card, int ch, int loop_on)
 {
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	falc_t *pfalc = (falc_t *) & chan->falc;
-	uclong falcbase = card->hw.falcbase;
+	uintptr_t falcbase = (uintptr_t)(card->hw.falcbase);
 
 	if (loop_on) {
 		cpc_writeb(falcbase + F_REG(LIM0, ch),
@@ -1529,7 +1531,7 @@ void falc_payload_loop(pc300_t * card, int ch, int loop_on)
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	pc300chconf_t *conf = (pc300chconf_t *) & chan->conf;
 	falc_t *pfalc = (falc_t *) & chan->falc;
-	uclong falcbase = card->hw.falcbase;
+	uintptr_t falcbase = (uintptr_t)(card->hw.falcbase);
 
 	if (loop_on) {
 		// EVENT_FALC_ABNORMAL
@@ -1582,7 +1584,7 @@ void turn_off_xlu(pc300_t * card, int ch)
 {
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	pc300chconf_t *conf = (pc300chconf_t *) & chan->conf;
-	uclong falcbase = card->hw.falcbase;
+	uintptr_t falcbase = (uintptr_t)(card->hw.falcbase);
 
 	if (conf->media == IF_IFACE_T1) {
 		cpc_writeb(falcbase + F_REG(FMR5, ch),
@@ -1603,7 +1605,7 @@ void turn_off_xld(pc300_t * card, int ch)
 {
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	pc300chconf_t *conf = (pc300chconf_t *) & chan->conf;
-	uclong falcbase = card->hw.falcbase;
+	uintptr_t falcbase = (uintptr_t)(card->hw.falcbase);
 
 	if (conf->media == IF_IFACE_T1) {
 		cpc_writeb(falcbase + F_REG(FMR5, ch),
@@ -1626,7 +1628,7 @@ void falc_generate_loop_up_code(pc300_t * card, int ch)
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	pc300chconf_t *conf = (pc300chconf_t *) & chan->conf;
 	falc_t *pfalc = (falc_t *) & chan->falc;
-	uclong falcbase = card->hw.falcbase;
+	uintptr_t falcbase = (uintptr_t)(card->hw.falcbase);
 
 	if (conf->media == IF_IFACE_T1) {
 		cpc_writeb(falcbase + F_REG(FMR5, ch),
@@ -1659,7 +1661,7 @@ void falc_generate_loop_down_code(pc300_t * card, int ch)
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	pc300chconf_t *conf = (pc300chconf_t *) & chan->conf;
 	falc_t *pfalc = (falc_t *) & chan->falc;
-	uclong falcbase = card->hw.falcbase;
+	uintptr_t falcbase = (uintptr_t)(card->hw.falcbase);
 
 	if (conf->media == IF_IFACE_T1) {
 		cpc_writeb(falcbase + F_REG(FMR5, ch),
@@ -1689,7 +1691,7 @@ void falc_pattern_test(pc300_t * card, int ch, unsigned int activate)
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	pc300chconf_t *conf = (pc300chconf_t *) & chan->conf;
 	falc_t *pfalc = (falc_t *) & chan->falc;
-	uclong falcbase = card->hw.falcbase;
+	uintptr_t falcbase = (uintptr_t)(card->hw.falcbase);
 
 	if (activate) {
 		pfalc->prbs = 1;
@@ -1731,7 +1733,7 @@ void falc_pattern_test(pc300_t * card, int ch, unsigned int activate)
  * Description:	This routine returns the bit error counter value
  *----------------------------------------------------------------------------
  */
-ucshort falc_pattern_test_error(pc300_t * card, int ch)
+u16 falc_pattern_test_error(pc300_t *card, int ch)
 {
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	falc_t *pfalc = (falc_t *) & chan->falc;
@@ -1778,8 +1780,8 @@ void cpc_tx_timeout(struct net_device *dev)
 	pc300_t *card = (pc300_t *) chan->card;
 	struct net_device_stats *stats = &d->hdlc->stats;
 	int ch = chan->channel;
-	uclong flags;
-	ucchar ilar;
+	unsigned long flags;
+	u8 ilar;
 
 	stats->tx_errors++;
 	stats->tx_aborted_errors++;
@@ -1806,7 +1808,7 @@ int cpc_queue_xmit(struct sk_buff *skb, struct net_device *dev)
 	pc300_t *card = (pc300_t *) chan->card;
 	struct net_device_stats *stats = &d->hdlc->stats;
 	int ch = chan->channel;
-	uclong flags;
+	unsigned long flags;
 #ifdef PC300_DEBUG_TX
 	int i;
 #endif
@@ -1840,8 +1842,8 @@ int cpc_queue_xmit(struct sk_buff *skb, struct net_device *dev)
 	}
 
 	/* Write buffer to DMA buffers */
-	if (dma_buf_write(card, ch, (ucchar *) skb->data, skb->len) != 0) {
-//		printk("%s: write error. Dropping TX packet.\n", dev->name);
+	if (dma_buf_write(card, ch, (u8 *) skb->data, skb->len) != 0) {
+		printk("%s: write error. Dropping TX packet.\n", dev->name);
 		netif_stop_queue(dev);
 		dev_kfree_skb(skb);
 		stats->tx_errors++;
@@ -2009,8 +2011,8 @@ static void sca_tx_intr(pc300dev_t *dev)
 
 static void sca_intr(pc300_t * card)
 {
-	uclong scabase = card->hw.scabase;
-	volatile uclong status;
+	uintptr_t scabase = (uintptr_t)(card->hw.scabase);
+	u32 status;
 	int ch;
 	int intr_count = 0;
 	unsigned char dsr_rx;
@@ -2026,7 +2028,7 @@ static void sca_intr(pc300_t * card)
 
 	    /**** Reception ****/
 			if (status & IR0_DRX((IR0_DMIA | IR0_DMIB), ch)) {
-				ucchar drx_stat = cpc_readb(scabase + DSR_RX(ch));
+				u8 drx_stat = cpc_readb(scabase + DSR_RX(ch));
 
 				/* Clear RX interrupts */
 				cpc_writeb(scabase + DSR_RX(ch), drx_stat | DSR_DWE);
@@ -2100,7 +2102,7 @@ static void sca_intr(pc300_t * card)
 
 	    /**** Transmission ****/
 			if (status & IR0_DTX((IR0_EFT | IR0_DMIA | IR0_DMIB), ch)) {
-				ucchar dtx_stat = cpc_readb(scabase + DSR_TX(ch));
+				u8 dtx_stat = cpc_readb(scabase + DSR_TX(ch));
 
 				/* Clear TX interrupts */
 				cpc_writeb(scabase + DSR_TX(ch), dtx_stat | DSR_DWE);
@@ -2144,7 +2146,7 @@ static void sca_intr(pc300_t * card)
 
 	    /**** MSCI ****/
 			if (status & IR0_M(IR0_RXINTA, ch)) {
-				ucchar st1 = cpc_readb(scabase + M_REG(ST1, ch));
+				u8 st1 = cpc_readb(scabase + M_REG(ST1, ch));
 
 				/* Clear MSCI interrupts */
 				cpc_writeb(scabase + M_REG(ST1, ch), st1);
@@ -2186,11 +2188,11 @@ static void sca_intr(pc300_t * card)
 	}
 }
 
-static void falc_t1_loop_detection(pc300_t * card, int ch, ucchar frs1)
+static void falc_t1_loop_detection(pc300_t *card, int ch, u8 frs1)
 {
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	falc_t *pfalc = (falc_t *) & chan->falc;
-	uclong falcbase = card->hw.falcbase;
+	uintptr_t falcbase = (uintptr_t)(card->hw.falcbase);
 
 	if (((cpc_readb(falcbase + F_REG(LCR1, ch)) & LCR1_XPRBS) == 0) &&
 	    !pfalc->loop_gen) {
@@ -2211,11 +2213,11 @@ static void falc_t1_loop_detection(pc300_t * card, int ch, ucchar frs1)
 	}
 }
 
-static void falc_e1_loop_detection(pc300_t * card, int ch, ucchar rsp)
+static void falc_e1_loop_detection(pc300_t *card, int ch, u8 rsp)
 {
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	falc_t *pfalc = (falc_t *) & chan->falc;
-	uclong falcbase = card->hw.falcbase;
+	uintptr_t falcbase = (uintptr_t)(card->hw.falcbase);
 
 	if (((cpc_readb(falcbase + F_REG(LCR1, ch)) & LCR1_XPRBS) == 0) &&
 	    !pfalc->loop_gen) {
@@ -2240,9 +2242,9 @@ static void falc_t1_intr(pc300_t * card, int ch)
 {
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	falc_t *pfalc = (falc_t *) & chan->falc;
-	uclong falcbase = card->hw.falcbase;
-	ucchar isr0, isr3, gis;
-	ucchar dummy;
+	uintptr_t falcbase = (uintptr_t)(card->hw.falcbase);
+	u8 isr0, isr3, gis;
+	u8 dummy;
 
 	while ((gis = cpc_readb(falcbase + F_REG(GIS, ch))) != 0) {
 		if (gis & GIS_ISR0) {
@@ -2287,9 +2289,9 @@ static void falc_e1_intr(pc300_t * card, int ch)
 {
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	falc_t *pfalc = (falc_t *) & chan->falc;
-	uclong falcbase = card->hw.falcbase;
-	ucchar isr1, isr2, isr3, gis, rsp;
-	ucchar dummy;
+	uintptr_t falcbase = (uintptr_t)(card->hw.falcbase);
+	u8 isr1, isr2, isr3, gis, rsp;
+	u8 dummy;
 
 	while ((gis = cpc_readb(falcbase + F_REG(GIS, ch))) != 0) {
 		rsp = cpc_readb(falcbase + F_REG(RSP, ch));
@@ -2371,7 +2373,7 @@ static void falc_intr(pc300_t * card)
 static irqreturn_t cpc_intr(int irq, void *dev_id, struct pt_regs *regs)
 {
 	pc300_t *card;
-	volatile ucchar plx_status;
+	u8 plx_status;
 
 	if ((card = (pc300_t *) dev_id) == 0) {
 #ifdef PC300_DEBUG_INTR
@@ -2410,9 +2412,9 @@ static irqreturn_t cpc_intr(int irq, void *dev_id, struct pt_regs *regs)
 
 void cpc_sca_status(pc300_t * card, int ch)
 {
-	ucchar ilar;
-	uclong scabase = card->hw.scabase;
-	uclong flags;
+	u8 ilar;
+	uintptr_t scabase = (uintptr_t)(card->hw.scabase);
+	unsigned long flags;
 
 	tx_dma_buf_check(card, ch);
 	rx_dma_buf_check(card, ch);
@@ -2420,12 +2422,12 @@ void cpc_sca_status(pc300_t * card, int ch)
 	printk ("ILAR=0x%02x, WCRL=0x%02x, PCR=0x%02x, BTCR=0x%02x, BOLR=0x%02x\n",
 		 ilar, cpc_readb(scabase + WCRL), cpc_readb(scabase + PCR),
 		 cpc_readb(scabase + BTCR), cpc_readb(scabase + BOLR));
-	printk("TX_CDA=0x%08lx, TX_EDA=0x%08lx\n",
-	       (uclong) cpc_readl(scabase + DTX_REG(CDAL, ch)),
-	       (uclong) cpc_readl(scabase + DTX_REG(EDAL, ch)));
-	printk("RX_CDA=0x%08lx, RX_EDA=0x%08lx, BFL=0x%04x\n",
-	       (uclong) cpc_readl(scabase + DRX_REG(CDAL, ch)),
-	       (uclong) cpc_readl(scabase + DRX_REG(EDAL, ch)),
+	printk("TX_CDA=0x%08x, TX_EDA=0x%08x\n",
+	       (u32) cpc_readl(scabase + DTX_REG(CDAL, ch)),
+	       (u32) cpc_readl(scabase + DTX_REG(EDAL, ch)));
+	printk("RX_CDA=0x%08x, RX_EDA=0x%08x, BFL=0x%04x\n",
+	       (u32) cpc_readl(scabase + DRX_REG(CDAL, ch)),
+	       (u32) cpc_readl(scabase + DRX_REG(EDAL, ch)),
 	       cpc_readw(scabase + DRX_REG(BFLL, ch)));
 	printk("DMER=0x%02x, DSR_TX=0x%02x, DSR_RX=0x%02x\n",
 	       cpc_readb(scabase + DMER), cpc_readb(scabase + DSR_TX(ch)),
@@ -2490,7 +2492,7 @@ void cpc_sca_status(pc300_t * card, int ch)
 	       cpc_readb(scabase + M_REG(IE2, ch)),
 	       cpc_readb(scabase + M_REG(IE4, ch)),
 	       cpc_readb(scabase + M_REG(FIE, ch)));
-	printk("IER0=0x%08lx\n", (uclong) cpc_readl(scabase + IER0));
+	printk("IER0=0x%08x\n", (u32) cpc_readl(scabase + IER0));
 
 	if (ilar != 0) {
 		CPC_LOCK(card, flags);
@@ -2504,7 +2506,7 @@ void cpc_falc_status(pc300_t * card, int ch)
 {
 	pc300ch_t *chan = &card->chan[ch];
 	falc_t *pfalc = (falc_t *) & chan->falc;
-	uclong flags;
+	unsigned long flags;
 
 	CPC_LOCK(card, flags);
 	printk("CH%d:   %s %s  %d channels\n",
@@ -2547,7 +2549,7 @@ int cpc_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 	int ch = chan->channel;
 	void *arg = (void *) ifr->ifr_data;
 	struct if_settings *settings = &ifr->ifr_settings;
-	uclong scabase = card->hw.scabase;
+	uintptr_t scabase = (uintptr_t)(card->hw.scabase);
 
 	if (!capable(CAP_NET_ADMIN))
 		return -EPERM;
@@ -2839,7 +2841,7 @@ static struct net_device_stats *cpc_get_stats(struct net_device *dev)
 		return NULL;
 }
 
-static int clock_rate_calc(uclong rate, uclong clock, int *br_io)
+static int clock_rate_calc(u32 rate, u32 clock, int *br_io)
 {
 	int br, tc;
 	int br_pwr, error;
@@ -2871,15 +2873,15 @@ int ch_config(pc300dev_t * d)
 	pc300ch_t *chan = (pc300ch_t *) d->chan;
 	pc300chconf_t *conf = (pc300chconf_t *) & chan->conf;
 	pc300_t *card = (pc300_t *) chan->card;
-	uclong scabase = card->hw.scabase;
-	uclong plxbase = card->hw.plxbase;
+	uintptr_t scabase = (uintptr_t)(card->hw.scabase);
+	uintptr_t plxbase = (uintptr_t)(card->hw.plxbase);
 	int ch = chan->channel;
-	uclong clkrate = chan->conf.phys_settings.clock_rate;
-	uclong clktype = chan->conf.phys_settings.clock_type;
-	ucshort encoding = chan->conf.proto_settings.encoding;
-	ucshort parity = chan->conf.proto_settings.parity;   
+	u32 clkrate = chan->conf.phys_settings.clock_rate;
+	u32 clktype = chan->conf.phys_settings.clock_type;
+	u16 encoding = chan->conf.proto_settings.encoding;
+	u16 parity = chan->conf.proto_settings.parity;
 	int tmc, br;
-	ucchar md0, md2;
+	u8 md0, md2;
     
 	/* Reset the channel */
 	cpc_writeb(scabase + M_REG(CMD, ch), CMD_CH_RST);
@@ -3018,7 +3020,7 @@ int rx_config(pc300dev_t * d)
 {
 	pc300ch_t *chan = (pc300ch_t *) d->chan;
 	pc300_t *card = (pc300_t *) chan->card;
-	uclong scabase = card->hw.scabase;
+	uintptr_t scabase = (uintptr_t)(card->hw.scabase);
 	int ch = chan->channel;
 
 	cpc_writeb(scabase + DSR_RX(ch), 0);
@@ -3049,7 +3051,7 @@ int tx_config(pc300dev_t * d)
 {
 	pc300ch_t *chan = (pc300ch_t *) d->chan;
 	pc300_t *card = (pc300_t *) chan->card;
-	uclong scabase = card->hw.scabase;
+	uintptr_t scabase = (uintptr_t)(card->hw.scabase);
 	int ch = chan->channel;
 
 	cpc_writeb(scabase + DSR_TX(ch), 0);
@@ -3113,8 +3115,8 @@ void cpc_opench(pc300dev_t * d)
 {
 	pc300ch_t *chan = (pc300ch_t *) d->chan;
 	pc300_t *card = (pc300_t *) chan->card;
-	int ch = chan->channel;
-	uclong scabase = card->hw.scabase;
+	int ch = chan->channel, rc;
+	uintptr_t scabase = (uintptr_t)(card->hw.scabase);
 
 	ch_config(d);
 
@@ -3190,7 +3192,7 @@ int cpc_close(struct net_device *dev)
 	pc300dev_t *d = (pc300dev_t *) dev->priv;
 	pc300ch_t *chan = (pc300ch_t *) d->chan;
 	pc300_t *card = (pc300_t *) chan->card;
-	uclong flags;
+	unsigned long flags;
 
 #ifdef	PC300_DEBUG_OTHER
 	printk("pc300: cpc_close");
@@ -3216,16 +3218,16 @@ int cpc_close(struct net_device *dev)
 	return 0;
 }
 
-static uclong detect_ram(pc300_t * card)
+static u32 detect_ram(pc300_t *card)
 {
-	uclong i;
-	ucchar data;
-	uclong rambase = card->hw.rambase;
+	u32 i;
+	u8 data;
+	uintptr_t rambase = (uintptr_t)(card->hw.rambase);
 
 	card->hw.ramsize = PC300_RAMSIZE;
 	/* Let's find out how much RAM is present on this board */
 	for (i = 0; i < card->hw.ramsize; i++) {
-		data = (ucchar) (i & 0xff);
+		data = (u8)(i & 0xff);
 		cpc_writeb(rambase + i, data);
 		if (cpc_readb(rambase + i) != data) {
 			break;
@@ -3236,7 +3238,8 @@ static uclong detect_ram(pc300_t * card)
 
 static void plx_init(pc300_t * card)
 {
-	struct RUNTIME_9050 *plx_ctl = (struct RUNTIME_9050 *) card->hw.plxbase;
+	struct RUNTIME_9050 __iomem *plx_ctl =
+		(struct RUNTIME_9050 __iomem *) card->hw.plxbase;
 
 	/* Reset PLX */
 	cpc_writel(&plx_ctl->init_ctrl,
@@ -3302,7 +3305,7 @@ static void cpc_init_card(pc300_t * card)
 	cpc_writeb(card->hw.scabase + DMER, 0x80);
 
 	if (card->hw.type == PC300_TE) {
-		ucchar reg1;
+		u8 reg1;
 
 		/* Check CPLD version */
 		reg1 = cpc_readb(card->hw.falcbase + CPLD_REG1);
@@ -3441,9 +3444,9 @@ static int __devinit
 cpc_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
 	static int first_time = 1;
-	ucchar cpc_rev_id;
+	u8 cpc_rev_id;
 	int err = 0, eeprom_outdated = 0;
-	ucshort device_id;
+	u16 device_id;
 	pc300_t *card;
 
 	if (first_time) {
@@ -3521,7 +3524,7 @@ cpc_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 				"PLX Registers")) {
 		printk("PC300 found at RAM 0x%08lx, "
 		       "but could not allocate PLX mem region.\n",
-		       card->hw.ramphys);
+		       (unsigned int)(card->hw.ramphys));
 		err = -ENODEV;
 		goto err_release_io;
 	}
@@ -3529,7 +3532,7 @@ cpc_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 				"On-board RAM")) {
 		printk("PC300 found at RAM 0x%08lx, "
 		       "but could not allocate RAM mem region.\n",
-		       card->hw.ramphys);
+		       (unsigned int)(card->hw.ramphys));
 		err = -ENODEV;
 		goto err_release_plx;
 	}
@@ -3537,7 +3540,7 @@ cpc_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 				"SCA-II Registers")) {
 		printk("PC300 found at RAM 0x%08lx, "
 		       "but could not allocate SCA mem region.\n",
-		       card->hw.ramphys);
+		       (unsigned int)(card->hw.ramphys));
 		err = -ENODEV;
 		goto err_release_ram;
 	}
@@ -3545,10 +3548,12 @@ cpc_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	if ((err = pci_enable_device(pdev)) != 0)
 		goto err_release_sca;
 
-	card->hw.plxbase = (uclong) ioremap(card->hw.plxphys, card->hw.plxsize);
-	card->hw.rambase = (uclong) ioremap(card->hw.ramphys,
+	card->hw.plxbase =
+		(void __iomem *) ioremap(card->hw.plxphys, card->hw.plxsize);
+	card->hw.rambase = (void __iomem *) ioremap(card->hw.ramphys,
 					    card->hw.alloc_ramsize);
-	card->hw.scabase = (uclong) ioremap(card->hw.scaphys, card->hw.scasize);
+	card->hw.scabase =
+		(void __iomem *) ioremap(card->hw.scaphys, card->hw.scasize);
 	switch (device_id) {
 		case PCI_DEVICE_ID_PC300_TE_1:
 		case PCI_DEVICE_ID_PC300_TE_2:
@@ -3556,14 +3561,15 @@ cpc_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 		case PCI_DEVICE_ID_PC300_TE_M_2:
 			request_mem_region(card->hw.falcphys, card->hw.falcsize,
 					   "FALC Registers");
-			card->hw.falcbase = (uclong) ioremap(card->hw.falcphys,
+			card->hw.falcbase =
+				(void __iomem *) ioremap(card->hw.falcphys,
 							     card->hw.falcsize);
 			break;
 
 		case PCI_DEVICE_ID_PC300_RX_1:
 		case PCI_DEVICE_ID_PC300_RX_2:
 		default:
-			card->hw.falcbase = 0;
+			card->hw.falcbase = NULL;
 			break;
 	}
 
@@ -3629,11 +3635,11 @@ cpc_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	return 0;
 
 err_io_unmap:
-	iounmap((void *) card->hw.plxbase);
-	iounmap((void *) card->hw.scabase);
-	iounmap((void *) card->hw.rambase);
+	iounmap(card->hw.plxbase);
+	iounmap(card->hw.scabase);
+	iounmap(card->hw.rambase);
 	if (card->hw.type == PC300_TE) {
-		iounmap((void *) card->hw.falcbase);
+		iounmap(card->hw.falcbase);
 		release_mem_region(card->hw.falcphys, card->hw.falcsize);
 	}
 err_release_sca:
@@ -3662,15 +3668,15 @@ static void __devexit cpc_remove_one(struct pci_dev *pdev)
 		for (i = 0; i < card->hw.nchan; i++) {
 			unregister_hdlc_device(card->chan[i].d.hdlc);
 		}
-		iounmap((void *) card->hw.plxbase);
-		iounmap((void *) card->hw.scabase);
-		iounmap((void *) card->hw.rambase);
+		iounmap(card->hw.plxbase);
+		iounmap(card->hw.scabase);
+		iounmap(card->hw.rambase);
 		release_mem_region(card->hw.plxphys, card->hw.plxsize);
 		release_mem_region(card->hw.ramphys, card->hw.alloc_ramsize);
 		release_mem_region(card->hw.scaphys, card->hw.scasize);
 		release_region(card->hw.iophys, card->hw.iosize);
 		if (card->hw.type == PC300_TE) {
-			iounmap((void *) card->hw.falcbase);
+			iounmap(card->hw.falcbase);
 			release_mem_region(card->hw.falcphys, card->hw.falcsize);
 		}
 		if (card->hw.irq)
@@ -3688,7 +3694,7 @@ static struct pci_driver cpc_driver = {
 
 static int __init cpc_init(void)
 {
-	return pci_module_init(&cpc_driver);
+	return pci_register_driver(&cpc_driver);
 }
 
 static void __exit cpc_cleanup_module(void)
diff --git a/drivers/net/wan/pc300_tty.c b/drivers/net/wan/pc300_tty.c
index db1a21a..cddf896 100644
--- a/drivers/net/wan/pc300_tty.c
+++ b/drivers/net/wan/pc300_tty.c
@@ -728,13 +728,13 @@ static void cpc_tty_rx_work(void * data)
  */
 static void cpc_tty_rx_disc_frame(pc300ch_t *pc300chan)
 {
-	volatile pcsca_bd_t * ptdescr; 
+	pcsca_bd_t *ptdescr;
 	volatile unsigned char status; 
 	pc300_t *card = (pc300_t *)pc300chan->card; 
 	int ch = pc300chan->channel; 
 
 	/* dma buf read */ 
-	ptdescr = (pcsca_bd_t *)(card->hw.rambase + 
+	ptdescr = (pcsca_bd_t __iomem *)(card->hw.rambase +
 				RX_BD_ADDR(ch, pc300chan->rx_first_bd)); 
 	while (pc300chan->rx_first_bd != pc300chan->rx_last_bd) { 
 		status = cpc_readb(&ptdescr->status); 
@@ -745,7 +745,8 @@ static void cpc_tty_rx_disc_frame(pc300ch_t *pc300chan)
 		if (status & DST_EOM) { 
 			break; /* end of message */
 		}
-		ptdescr = (pcsca_bd_t *)(card->hw.rambase + cpc_readl(&ptdescr->next)); 
+		ptdescr = (pcsca_bd_t __iomem *)(card->hw.rambase +
+			cpc_readl(&ptdescr->next));
 	}
 }
 
@@ -755,8 +756,8 @@ void cpc_tty_receive(pc300dev_t *pc300dev)
 	pc300ch_t *pc300chan = (pc300ch_t *)pc300dev->chan; 
 	pc300_t *card = (pc300_t *)pc300chan->card; 
 	int ch = pc300chan->channel; 
-	volatile pcsca_bd_t * ptdescr; 
-	struct net_device_stats *stats = &pc300dev->hdlc->stats; 
+	pcsca_bd_t  __iomem *ptdescr;
+	struct net_device_stats *stats = &pc300dev->netdev->stats;
 	int rx_len, rx_aux; 
 	volatile unsigned char status; 
 	unsigned short first_bd = pc300chan->rx_first_bd;
@@ -773,14 +774,16 @@ void cpc_tty_receive(pc300dev_t *pc300dev)
 
 	while (1) { 
 		rx_len = 0;
-		ptdescr = (pcsca_bd_t *)(card->hw.rambase + RX_BD_ADDR(ch, first_bd));
+		ptdescr = (pcsca_bd_t  __iomem *)(card->hw.rambase +
+			RX_BD_ADDR(ch, first_bd));
 		while ((status = cpc_readb(&ptdescr->status)) & DST_OSB) {
 			rx_len += cpc_readw(&ptdescr->len);
 			first_bd = (first_bd + 1) & (N_DMA_RX_BUF - 1);
 			if (status & DST_EOM) {
 				break;
 			}
-			ptdescr=(pcsca_bd_t*)(card->hw.rambase+cpc_readl(&ptdescr->next));
+			ptdescr = (pcsca_bd_t __iomem *)(card->hw.rambase +
+				cpc_readl(&ptdescr->next));
 		}
 			
 		if (!rx_len) { 
@@ -808,7 +811,7 @@ void cpc_tty_receive(pc300dev_t *pc300dev)
 		}
 		
 		/* dma buf read */ 
-		ptdescr = (pcsca_bd_t *)(card->hw.rambase + 
+		ptdescr = (pcsca_bd_t __iomem *)(card->hw.rambase +
 				RX_BD_ADDR(ch, pc300chan->rx_first_bd)); 
 
 		rx_len = 0;	/* counter frame size */
@@ -850,7 +853,7 @@ void cpc_tty_receive(pc300dev_t *pc300dev)
 			/* read the segment of the frame */
 			if (rx_aux != 0) {
 				memcpy_fromio((new->data + rx_len), 
-					(void *)(card->hw.rambase + 
+					(void __iomem *)(card->hw.rambase +
 					 cpc_readl(&ptdescr->ptbuf)), rx_aux);
 				rx_len += rx_aux; 
 			}
@@ -860,7 +863,7 @@ void cpc_tty_receive(pc300dev_t *pc300dev)
 					(N_DMA_RX_BUF -1); 
 			if (status & DST_EOM)break;
 			
-			ptdescr = (pcsca_bd_t *) (card->hw.rambase + 
+			ptdescr = (pcsca_bd_t __iomem *) (card->hw.rambase +
 					cpc_readl(&ptdescr->next)); 
 		}
 		/* update pointer */ 
@@ -934,7 +937,7 @@ static int cpc_tty_send_to_card(pc300dev_t *dev,void* buf, int len)
 	int ch = chan->channel; 
 	struct net_device_stats *stats = &dev->hdlc->stats; 
 	unsigned long flags; 
-	volatile pcsca_bd_t * ptdescr; 
+	pcsca_bd_t __iomem *ptdescr;
 	int i, nchar;
 	int tosend = len;
 	int nbuf = ((len - 1)/BD_DEF_LEN) + 1;
@@ -951,11 +954,11 @@ static int cpc_tty_send_to_card(pc300dev_t *dev,void* buf, int len)
 	CPC_TTY_DBG("%s: call dma_buf_write\n",
 			(st_cpc_tty_area *)dev->cpc_tty->name);	
 	for (i = 0 ; i < nbuf ; i++) {
-		ptdescr = (pcsca_bd_t *)(card->hw.rambase + 
+		ptdescr = (pcsca_bd_t __iomem *)(card->hw.rambase +
 			TX_BD_ADDR(ch, card->chan[ch].tx_next_bd));
 		nchar = (BD_DEF_LEN > tosend) ? tosend : BD_DEF_LEN;
 		if (cpc_readb(&ptdescr->status) & DST_OSB) {
-			memcpy_toio((void *)(card->hw.rambase + 
+			memcpy_toio((void __iomem *)(card->hw.rambase +
 				cpc_readl(&ptdescr->ptbuf)), 
 				&pdata[len - tosend], 
 				nchar);
