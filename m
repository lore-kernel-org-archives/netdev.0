From: "Maciej W. Rozycki" <macro@linux-mips.org>
Subject: [PATCH 2.6.18 7/6]: sb1250-mac: Remove "typedef" obfuscation
Date: Thu, 5 Oct 2006 17:28:50 +0100 (BST)
Message-ID: <Pine.LNX.4.64N.0610051707430.22085@blysk.ds.pg.gda.pl>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, linux-mips@linux-mips.org
Return-path: <linux-mips-bounce@linux-mips.org>
To: Andrew Morton <akpm@osdl.org>, Jeff Garzik <jgarzik@pobox.com>,
	Ralf Baechle <ralf@linux-mips.org>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-Id: netdev.vger.kernel.org

 This is a set of changes to remove unneeded type definitions that only 
make code less obvious.  It applies to all "enum" and "struct" types as 
well as to potentially unsafe use of them within sizeof().

Signed-off-by: Maciej W. Rozycki <macro@linux-mips.org>
---

 This applies on top of 4/6.  Please consider.

  Maciej

patch-mips-2.6.18-20060920-sb1250-mac-typedef-3
diff -up --recursive --new-file linux-mips-2.6.18-20060920.macro/drivers/net/sb1250-mac.c linux-mips-2.6.18-20060920/drivers/net/sb1250-mac.c
--- linux-mips-2.6.18-20060920.macro/drivers/net/sb1250-mac.c	2006-09-28 02:51:29.000000000 +0000
+++ linux-mips-2.6.18-20060920/drivers/net/sb1250-mac.c	2006-10-05 16:18:41.000000000 +0000
@@ -129,33 +129,33 @@ MODULE_PARM_DESC(int_timeout, "Timeout v
  *  Simple types
  ********************************************************************* */
 
-typedef enum {
+enum sbmac_speed {
 	sbmac_speed_none = 0,
 	sbmac_speed_10 = SPEED_10,
 	sbmac_speed_100 = SPEED_100,
 	sbmac_speed_1000 = SPEED_1000,
-} sbmac_speed_t;
+};
 
-typedef enum {
+enum sbmac_duplex {
 	sbmac_duplex_none = -1,
 	sbmac_duplex_half = DUPLEX_HALF,
 	sbmac_duplex_full = DUPLEX_FULL,
-} sbmac_duplex_t;
+};
 
-typedef enum {
+enum sbmac_fc {
 	sbmac_fc_none,
 	sbmac_fc_disabled,
 	sbmac_fc_frame,
 	sbmac_fc_collision,
 	sbmac_fc_carrier,
-} sbmac_fc_t;
+};
 
-typedef enum {
+enum sbmac_state {
 	sbmac_state_uninit,
 	sbmac_state_off,
 	sbmac_state_on,
 	sbmac_state_broken,
-} sbmac_state_t;
+};
 
 
 /**********************************************************************
@@ -181,52 +181,58 @@ typedef enum {
  *  DMA Descriptor structure
  ********************************************************************* */
 
-typedef struct sbdmadscr_s {
+struct sbdmadscr {
 	uint64_t  dscr_a;
 	uint64_t  dscr_b;
-} sbdmadscr_t;
-
-typedef unsigned long paddr_t;
+};
 
 /**********************************************************************
  *  DMA Controller structure
  ********************************************************************* */
 
-typedef struct sbmacdma_s {
+struct sbmacdma {
 
 	/*
 	 * This stuff is used to identify the channel and the registers
 	 * associated with it.
 	 */
-
-	struct sbmac_softc *sbdma_eth;	        /* back pointer to associated MAC */
-	int              sbdma_channel;	/* channel number */
-	int		 sbdma_txdir;       /* direction (1=transmit) */
-	int		 sbdma_maxdescr;	/* total # of descriptors in ring */
+	struct sbmac_softc	*sbdma_eth;	/* back pointer to associated
+						   MAC */
+	int			sbdma_channel;	/* channel number */
+	int			sbdma_txdir;	/* direction (1=transmit) */
+	int			sbdma_maxdescr;	/* total # of descriptors
+						   in ring */
 #ifdef CONFIG_SBMAC_COALESCE
-	int		 sbdma_int_pktcnt;  /* # descriptors rx/tx before interrupt*/
-	int		 sbdma_int_timeout; /* # usec rx/tx interrupt */
+	int			sbdma_int_pktcnt;
+						/* # descriptors rx/tx
+						   before interrupt */
+	int			sbdma_int_timeout;
+						/* # usec rx/tx interrupt */
 #endif
-
-	volatile void __iomem *sbdma_config0;	/* DMA config register 0 */
-	volatile void __iomem *sbdma_config1;	/* DMA config register 1 */
-	volatile void __iomem *sbdma_dscrbase;	/* Descriptor base address */
-	volatile void __iomem *sbdma_dscrcnt;     /* Descriptor count register */
-	volatile void __iomem *sbdma_curdscr;	/* current descriptor address */
+	volatile void __iomem	*sbdma_config0;	/* DMA config register 0 */
+	volatile void __iomem	*sbdma_config1;	/* DMA config register 1 */
+	volatile void __iomem	*sbdma_dscrbase;
+						/* descriptor base address */
+	volatile void __iomem	*sbdma_dscrcnt;	/* descriptor count register */
+	volatile void __iomem	*sbdma_curdscr;	/* current descriptor
+						   address */
 
 	/*
 	 * This stuff is for maintenance of the ring
 	 */
-
-	sbdmadscr_t     *sbdma_dscrtable;	/* base of descriptor table */
-	sbdmadscr_t     *sbdma_dscrtable_end; /* end of descriptor table */
-
-	struct sk_buff **sbdma_ctxtable;    /* context table, one per descr */
-
-	paddr_t          sbdma_dscrtable_phys; /* and also the phys addr */
-	sbdmadscr_t     *sbdma_addptr;	/* next dscr for sw to add */
-	sbdmadscr_t     *sbdma_remptr;	/* next dscr for sw to remove */
-} sbmacdma_t;
+	struct sbdmadscr	*sbdma_dscrtable;
+						/* base of descriptor table */
+	struct sbdmadscr	*sbdma_dscrtable_end;
+						/* end of descriptor table */
+	struct sk_buff		**sbdma_ctxtable;
+						/* context table, one
+						   per descr */
+	dma_addr_t		sbdma_dscrtable_phys;
+						/* and also the phys addr */
+	struct sbdmadscr	*sbdma_addptr;	/* next dscr for sw to add */
+	struct sbdmadscr	*sbdma_remptr;	/* next dscr for sw
+						   to remove */
+};
 
 
 /**********************************************************************
@@ -238,7 +244,6 @@ struct sbmac_softc {
 	/*
 	 * Linux-specific things
 	 */
-
 	struct net_device	*sbm_dev;	/* pointer to linux device */
 	struct phy_device	*phy_dev;	/* the associated PHY device */
 	struct mii_bus		mii_bus;	/* the MII bus */
@@ -253,9 +258,8 @@ struct sbmac_softc {
 	/*
 	 * Controller-specific things
 	 */
-
 	volatile void __iomem	*sbm_base;	/* MAC's base address */
-	sbmac_state_t		sbm_state;	/* current state */
+	enum sbmac_state	sbm_state;	/* current state */
 
 	volatile void __iomem	*sbm_macenable;	/* MAC Enable Register */
 	volatile void __iomem	*sbm_maccfg;	/* MAC Config Register */
@@ -267,16 +271,16 @@ struct sbmac_softc {
 	volatile void __iomem	*sbm_mdio;	/* MDIO Register */
 
 
-	sbmac_speed_t		sbm_speed;	/* current speed */
-	sbmac_duplex_t		sbm_duplex;	/* current duplex */
-	sbmac_fc_t		sbm_fc;		/* cur. flow control setting */
+	enum sbmac_speed	sbm_speed;	/* current speed */
+	enum sbmac_duplex	sbm_duplex;	/* current duplex */
+	enum sbmac_fc		sbm_fc;		/* cur. flow control setting */
 	int			sbm_pause;	/* current pause setting */
 	int			sbm_link;	/* current link state */
 
 	unsigned char		sbm_hwaddr[ETHER_ADDR_LEN];
 
-	sbmacdma_t		sbm_txdma;	/* only channel 0 for now */
-	sbmacdma_t		sbm_rxdma;
+	struct sbmacdma		sbm_txdma;	/* only channel 0 for now */
+	struct sbmacdma		sbm_rxdma;
 	int			rx_hw_checksum;
 	int			sbe_idx;
 };
@@ -290,30 +294,30 @@ struct sbmac_softc {
  *  Prototypes
  ********************************************************************* */
 
-static void sbdma_initctx(sbmacdma_t *d,
-			  struct sbmac_softc *s,
-			  int chan,
-			  int txrx,
-			  int maxdescr);
-static void sbdma_channel_start(sbmacdma_t *d, int rxtx);
-static int sbdma_add_rcvbuffer(sbmacdma_t *d,struct sk_buff *m);
-static int sbdma_add_txbuffer(sbmacdma_t *d,struct sk_buff *m);
-static void sbdma_emptyring(sbmacdma_t *d);
-static void sbdma_fillring(sbmacdma_t *d);
-static void sbdma_rx_process(struct sbmac_softc *sc,sbmacdma_t *d);
-static void sbdma_tx_process(struct sbmac_softc *sc,sbmacdma_t *d);
+static void sbdma_initctx(struct sbmacdma *d, struct sbmac_softc *s, int chan,
+			  int txrx, int maxdescr);
+static void sbdma_channel_start(struct sbmacdma *d, int rxtx);
+static int sbdma_add_rcvbuffer(struct sbmacdma *d, struct sk_buff *m);
+static int sbdma_add_txbuffer(struct sbmacdma *d, struct sk_buff *m);
+static void sbdma_emptyring(struct sbmacdma *d);
+static void sbdma_fillring(struct sbmacdma *d);
+static void sbdma_rx_process(struct sbmac_softc *sc, struct sbmacdma *d);
+static void sbdma_tx_process(struct sbmac_softc *sc, struct sbmacdma *d);
 static int sbmac_initctx(struct sbmac_softc *s);
 static void sbmac_channel_start(struct sbmac_softc *s);
 static void sbmac_channel_stop(struct sbmac_softc *s);
-static sbmac_state_t sbmac_set_channel_state(struct sbmac_softc *,sbmac_state_t);
-static void sbmac_promiscuous_mode(struct sbmac_softc *sc,int onoff);
+static enum sbmac_state sbmac_set_channel_state(struct sbmac_softc *,
+						enum sbmac_state);
+static void sbmac_promiscuous_mode(struct sbmac_softc *sc, int onoff);
 static uint64_t sbmac_addr2reg(unsigned char *ptr);
-static irqreturn_t sbmac_intr(int irq,void *dev_instance,struct pt_regs *rgs);
+static irqreturn_t sbmac_intr(int irq, void *dev_instance,
+			      struct pt_regs *rgs);
 static int sbmac_start_tx(struct sk_buff *skb, struct net_device *dev);
 static void sbmac_setmulti(struct sbmac_softc *sc);
 static int sbmac_init(struct platform_device *pldev, long long base);
-static int sbmac_set_speed(struct sbmac_softc *s,sbmac_speed_t speed);
-static int sbmac_set_duplex(struct sbmac_softc *s,sbmac_duplex_t duplex,sbmac_fc_t fc);
+static int sbmac_set_speed(struct sbmac_softc *s, enum sbmac_speed speed);
+static int sbmac_set_duplex(struct sbmac_softc *s, enum sbmac_duplex duplex,
+			    enum sbmac_fc fc);
 
 static int sbmac_open(struct net_device *dev);
 static void sbmac_tx_timeout (struct net_device *dev);
@@ -567,8 +571,8 @@ static int sbmac_mii_write(struct mii_bu
  *  way.
  *
  *  Input parameters:
- *  	   d - sbmacdma_t structure (DMA channel context)
- *  	   s - sbmac_softc structure (pointer to a MAC)
+ *  	   d - struct sbmacdma (DMA channel context)
+ *  	   s - struct sbmac_softc (pointer to a MAC)
  *  	   chan - channel number (0..1 right now)
  *  	   txrx - Identifies DMA_TX or DMA_RX for channel direction
  *      maxdescr - number of descriptors
@@ -577,11 +581,8 @@ static int sbmac_mii_write(struct mii_bu
  *  	   nothing
  ********************************************************************* */
 
-static void sbdma_initctx(sbmacdma_t *d,
-			  struct sbmac_softc *s,
-			  int chan,
-			  int txrx,
-			  int maxdescr)
+static void sbdma_initctx(struct sbmacdma *d, struct sbmac_softc *s, int chan,
+			  int txrx, int maxdescr)
 {
 	/*
 	 * Save away interesting stuff in the structure
@@ -639,17 +640,19 @@ static void sbdma_initctx(sbmacdma_t *d,
 
 	d->sbdma_maxdescr = maxdescr;
 
-	d->sbdma_dscrtable = (sbdmadscr_t *)
-		kmalloc((d->sbdma_maxdescr+1)*sizeof(sbdmadscr_t), GFP_KERNEL);
+	d->sbdma_dscrtable = kmalloc((d->sbdma_maxdescr + 1) *
+				     sizeof(*d->sbdma_dscrtable), GFP_KERNEL);
 
 	/*
 	 * The descriptor table must be aligned to at least 16 bytes or the
 	 * MAC will corrupt it.
 	 */
-	d->sbdma_dscrtable = (sbdmadscr_t *)
-		ALIGN((unsigned long)d->sbdma_dscrtable, sizeof(sbdmadscr_t));
+	d->sbdma_dscrtable = (struct sbdmadscr *)
+			     ALIGN((unsigned long)d->sbdma_dscrtable,
+				   sizeof(*d->sbdma_dscrtable));
 
-	memset(d->sbdma_dscrtable,0,d->sbdma_maxdescr*sizeof(sbdmadscr_t));
+	memset(d->sbdma_dscrtable, 0,
+	       d->sbdma_maxdescr * sizeof(*d->sbdma_dscrtable));
 
 	d->sbdma_dscrtable_end = d->sbdma_dscrtable + d->sbdma_maxdescr;
 
@@ -659,10 +662,11 @@ static void sbdma_initctx(sbmacdma_t *d,
 	 * And context table
 	 */
 
-	d->sbdma_ctxtable = (struct sk_buff **)
-		kmalloc(d->sbdma_maxdescr*sizeof(struct sk_buff *), GFP_KERNEL);
+	d->sbdma_ctxtable = kmalloc(d->sbdma_maxdescr *
+				    sizeof(*d->sbdma_ctxtable), GFP_KERNEL);
 
-	memset(d->sbdma_ctxtable,0,d->sbdma_maxdescr*sizeof(struct sk_buff *));
+	memset(d->sbdma_ctxtable, 0,
+	       d->sbdma_maxdescr * sizeof(*d->sbdma_ctxtable));
 
 #ifdef CONFIG_SBMAC_COALESCE
 	/*
@@ -697,7 +701,7 @@ static void sbdma_initctx(sbmacdma_t *d,
  *  	   nothing
  ********************************************************************* */
 
-static void sbdma_channel_start(sbmacdma_t *d, int rxtx )
+static void sbdma_channel_start(struct sbmacdma *d, int rxtx)
 {
 	/*
 	 * Turn on the DMA channel
@@ -738,7 +742,7 @@ static void sbdma_channel_start(sbmacdma
  *  	   nothing
  ********************************************************************* */
 
-static void sbdma_channel_stop(sbmacdma_t *d)
+static void sbdma_channel_stop(struct sbmacdma *d)
 {
 	/*
 	 * Turn off the DMA channel
@@ -787,10 +791,10 @@ static void sbdma_align_skb(struct sk_bu
  ********************************************************************* */
 
 
-static int sbdma_add_rcvbuffer(sbmacdma_t *d,struct sk_buff *sb)
+static int sbdma_add_rcvbuffer(struct sbmacdma *d, struct sk_buff *sb)
 {
-	sbdmadscr_t *dsc;
-	sbdmadscr_t *nextdsc;
+	struct sbdmadscr *dsc;
+	struct sbdmadscr *nextdsc;
 	struct sk_buff *sb_new = NULL;
 	int pktsize = ENET_PACKET_SIZE;
 
@@ -905,10 +909,10 @@ static int sbdma_add_rcvbuffer(sbmacdma_
  ********************************************************************* */
 
 
-static int sbdma_add_txbuffer(sbmacdma_t *d,struct sk_buff *sb)
+static int sbdma_add_txbuffer(struct sbmacdma *d, struct sk_buff *sb)
 {
-	sbdmadscr_t *dsc;
-	sbdmadscr_t *nextdsc;
+	struct sbdmadscr *dsc;
+	struct sbdmadscr *nextdsc;
 	uint64_t phys;
 	uint64_t ncb;
 	int length;
@@ -994,7 +998,7 @@ static int sbdma_add_txbuffer(sbmacdma_t
  *  	   nothing
  ********************************************************************* */
 
-static void sbdma_emptyring(sbmacdma_t *d)
+static void sbdma_emptyring(struct sbmacdma *d)
 {
 	int idx;
 	struct sk_buff *sb;
@@ -1022,7 +1026,7 @@ static void sbdma_emptyring(sbmacdma_t *
  *  	   nothing
  ********************************************************************* */
 
-static void sbdma_fillring(sbmacdma_t *d)
+static void sbdma_fillring(struct sbmacdma *d)
 {
 	int idx;
 
@@ -1049,11 +1053,11 @@ static void sbdma_fillring(sbmacdma_t *d
  *  	   nothing
  ********************************************************************* */
 
-static void sbdma_rx_process(struct sbmac_softc *sc,sbmacdma_t *d)
+static void sbdma_rx_process(struct sbmac_softc *sc, struct sbmacdma *d)
 {
 	int curidx;
 	int hwidx;
-	sbdmadscr_t *dsc;
+	struct sbdmadscr *dsc;
 	struct sk_buff *sb;
 	int len;
 
@@ -1070,8 +1074,9 @@ static void sbdma_rx_process(struct sbma
 		 */
 
 		curidx = d->sbdma_remptr - d->sbdma_dscrtable;
-		hwidx = (int) (((__raw_readq(d->sbdma_curdscr) & M_DMA_CURDSCR_ADDR) -
-				d->sbdma_dscrtable_phys) / sizeof(sbdmadscr_t));
+		hwidx = ((__raw_readq(d->sbdma_curdscr) &
+			  M_DMA_CURDSCR_ADDR) - d->sbdma_dscrtable_phys) /
+			sizeof(*d->sbdma_dscrtable);
 
 		/*
 		 * If they're the same, that means we've processed all
@@ -1174,11 +1179,11 @@ static void sbdma_rx_process(struct sbma
  *  	   nothing
  ********************************************************************* */
 
-static void sbdma_tx_process(struct sbmac_softc *sc,sbmacdma_t *d)
+static void sbdma_tx_process(struct sbmac_softc *sc, struct sbmacdma *d)
 {
 	int curidx;
 	int hwidx;
-	sbdmadscr_t *dsc;
+	struct sbdmadscr *dsc;
 	struct sk_buff *sb;
 	unsigned long flags;
 
@@ -1197,8 +1202,9 @@ static void sbdma_tx_process(struct sbma
 		 */
 
 		curidx = d->sbdma_remptr - d->sbdma_dscrtable;
-		hwidx = (int) (((__raw_readq(d->sbdma_curdscr) & M_DMA_CURDSCR_ADDR) -
-				d->sbdma_dscrtable_phys) / sizeof(sbdmadscr_t));
+		hwidx = ((__raw_readq(d->sbdma_curdscr) &
+			  M_DMA_CURDSCR_ADDR) - d->sbdma_dscrtable_phys) /
+			sizeof(*d->sbdma_dscrtable);
 
 		/*
 		 * If they're the same, that means we've processed all
@@ -1301,7 +1307,7 @@ static int sbmac_initctx(struct sbmac_so
 }
 
 
-static void sbdma_uninitctx(struct sbmacdma_s *d)
+static void sbdma_uninitctx(struct sbmacdma *d)
 {
 	if (d->sbdma_dscrtable) {
 		kfree(d->sbdma_dscrtable);
@@ -1606,10 +1612,10 @@ static void sbmac_channel_stop(struct sb
  *  Return value:
  *  	   old state
  ********************************************************************* */
-static sbmac_state_t sbmac_set_channel_state(struct sbmac_softc *sc,
-					     sbmac_state_t state)
+static enum sbmac_state sbmac_set_channel_state(struct sbmac_softc *sc,
+						enum sbmac_state state)
 {
-	sbmac_state_t oldstate = sc->sbm_state;
+	enum sbmac_state oldstate = sc->sbm_state;
 
 	/*
 	 * If same as previous state, return
@@ -1744,14 +1750,14 @@ static uint64_t sbmac_addr2reg(unsigned 
  *
  *  Input parameters:
  *  	   s - sbmac structure
- *  	   speed - speed to set MAC to (see sbmac_speed_t enum)
+ *  	   speed - speed to set MAC to (see enum sbmac_speed)
  *
  *  Return value:
  *  	   1 if successful
  *      0 indicates invalid parameters
  ********************************************************************* */
 
-static int sbmac_set_speed(struct sbmac_softc *s,sbmac_speed_t speed)
+static int sbmac_set_speed(struct sbmac_softc *s, enum sbmac_speed speed)
 {
 	uint64_t cfg;
 	uint64_t framecfg;
@@ -1831,15 +1837,16 @@ static int sbmac_set_speed(struct sbmac_
  *
  *  Input parameters:
  *  	   s - sbmac structure
- *  	   duplex - duplex setting (see sbmac_duplex_t)
- *  	   fc - flow control setting (see sbmac_fc_t)
+ *  	   duplex - duplex setting (see enum sbmac_duplex)
+ *  	   fc - flow control setting (see enum sbmac_fc)
  *
  *  Return value:
  *  	   1 if ok
  *  	   0 if an invalid parameter combination was specified
  ********************************************************************* */
 
-static int sbmac_set_duplex(struct sbmac_softc *s,sbmac_duplex_t duplex,sbmac_fc_t fc)
+static int sbmac_set_duplex(struct sbmac_softc *s, enum sbmac_duplex duplex,
+			    enum sbmac_fc fc)
 {
 	uint64_t cfg;
 
@@ -2455,7 +2462,7 @@ static void sbmac_mii_poll(struct net_de
 	struct sbmac_softc *sc = netdev_priv(dev);
 	struct phy_device *phy_dev = sc->phy_dev;
 	unsigned long flags;
-	sbmac_fc_t fc;
+	enum sbmac_fc fc;
 	int link_chg, speed_chg, duplex_chg, pause_chg, fc_chg;
 
 	link_chg = (sc->sbm_link != phy_dev->link);
