From: "Maciej W. Rozycki" <macro@linux-mips.org>
Subject: Re: [PATCH] sb1250-mac.c: De-typedef, de-volatile, de-etc...
Date: Thu, 20 Sep 2007 19:14:01 +0100 (BST)
Message-ID: <Pine.LNX.4.64N.0709201829290.30788@blysk.ds.pg.gda.pl>
References: <Pine.LNX.4.64N.0709101310030.25038@blysk.ds.pg.gda.pl>
 <46E8B56E.7060705@pobox.com> <Pine.LNX.4.64N.0709131506040.31069@blysk.ds.pg.gda.pl>
 <20070913151452.GB29665@linux-mips.org> <46E95C7F.1050302@pobox.com>
 <Pine.LNX.4.64N.0709141135290.1926@blysk.ds.pg.gda.pl> <46F1F2CE.7020300@pobox.com>
 <Pine.LNX.4.64N.0709201354320.30788@blysk.ds.pg.gda.pl> <46F2A779.2040904@pobox.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Ralf Baechle <ralf@linux-mips.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, linux-mips@linux-mips.org,
	linux-kernel@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cerber.ds.pg.gda.pl ([153.19.208.18]:38676 "EHLO
	cerber.ds.pg.gda.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752797AbXITSOO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Sep 2007 14:14:14 -0400
In-Reply-To: <46F2A779.2040904@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 Remove typedefs, volatiles and convert kmalloc()/memset() pairs to
kcalloc().  Also reformat the surrounding clutter.

Signed-off-by: Maciej W. Rozycki <macro@linux-mips.org>
---
On Thu, 20 Sep 2007, Jeff Garzik wrote:

> Remove the "linux-" prefix.

 Hmm, it looks like a bad application of `sed' by myself.  Sorry for the 
noise.

  Maciej

patch-netdev-2.6.23-rc6-20070920-sb1250-mac-typedef-9
diff -up --recursive --new-file linux-netdev-2.6.23-rc6-20070920.macro/drivers/net/sb1250-mac.c linux-netdev-2.6.23-rc6-20070920/drivers/net/sb1250-mac.c
--- linux-netdev-2.6.23-rc6-20070920.macro/drivers/net/sb1250-mac.c	2007-09-20 17:55:14.000000000 +0000
+++ linux-netdev-2.6.23-rc6-20070920/drivers/net/sb1250-mac.c	2007-09-20 18:09:18.000000000 +0000
@@ -140,17 +140,17 @@ MODULE_PARM_DESC(int_timeout_rx, "RX tim
  ********************************************************************* */
 
 
-typedef enum { sbmac_speed_auto, sbmac_speed_10,
-	       sbmac_speed_100, sbmac_speed_1000 } sbmac_speed_t;
+enum sbmac_speed { sbmac_speed_auto, sbmac_speed_10,
+		   sbmac_speed_100, sbmac_speed_1000 };
 
-typedef enum { sbmac_duplex_auto, sbmac_duplex_half,
-	       sbmac_duplex_full } sbmac_duplex_t;
+enum sbmac_duplex { sbmac_duplex_auto, sbmac_duplex_half,
+		    sbmac_duplex_full };
 
-typedef enum { sbmac_fc_auto, sbmac_fc_disabled, sbmac_fc_frame,
-	       sbmac_fc_collision, sbmac_fc_carrier } sbmac_fc_t;
+enum sbmac_fc { sbmac_fc_auto, sbmac_fc_disabled, sbmac_fc_frame,
+		sbmac_fc_collision, sbmac_fc_carrier } sbmac_fc_t;
 
-typedef enum { sbmac_state_uninit, sbmac_state_off, sbmac_state_on,
-	       sbmac_state_broken } sbmac_state_t;
+enum sbmac_state { sbmac_state_uninit, sbmac_state_off, sbmac_state_on,
+		   sbmac_state_broken };
 
 
 /**********************************************************************
@@ -176,55 +176,61 @@ typedef enum { sbmac_state_uninit, sbmac
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
-	struct sbmac_softc *sbdma_eth;	    /* back pointer to associated MAC */
-	int              sbdma_channel;	    /* channel number */
-	int		 sbdma_txdir;       /* direction (1=transmit) */
-	int		 sbdma_maxdescr;    /* total # of descriptors in ring */
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
-	volatile void __iomem *sbdma_dscrcnt;   /* Descriptor count register */
-	volatile void __iomem *sbdma_curdscr;	/* current descriptor address */
-	volatile void __iomem *sbdma_oodpktlost;/* pkt drop (rx only) */
-
+	void __iomem		*sbdma_config0;	/* DMA config register 0 */
+	void __iomem		*sbdma_config1;	/* DMA config register 1 */
+	void __iomem		*sbdma_dscrbase;
+						/* descriptor base address */
+	void __iomem		*sbdma_dscrcnt;	/* descriptor count register */
+	void __iomem		*sbdma_curdscr;	/* current descriptor
+						   address */
+	void __iomem		*sbdma_oodpktlost;
+						/* pkt drop (rx only) */
 
 	/*
 	 * This stuff is for maintenance of the ring
 	 */
-
-	sbdmadscr_t     *sbdma_dscrtable_unaligned;
-	sbdmadscr_t     *sbdma_dscrtable;	/* base of descriptor table */
-	sbdmadscr_t     *sbdma_dscrtable_end; /* end of descriptor table */
-
-	struct sk_buff **sbdma_ctxtable;    /* context table, one per descr */
-
-	paddr_t          sbdma_dscrtable_phys; /* and also the phys addr */
-	sbdmadscr_t     *sbdma_addptr;	/* next dscr for sw to add */
-	sbdmadscr_t     *sbdma_remptr;	/* next dscr for sw to remove */
-} sbmacdma_t;
+	void			*sbdma_dscrtable_unaligned;
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
@@ -236,47 +242,45 @@ struct sbmac_softc {
 	/*
 	 * Linux-specific things
 	 */
+	struct net_device	*sbm_dev;	/* pointer to linux device */
+	struct napi_struct	napi;
+	spinlock_t		sbm_lock;	/* spin lock */
+	struct timer_list	sbm_timer;	/* for monitoring MII */
+	int			sbm_devflags;	/* current device flags */
+
+	int			sbm_phy_oldbmsr;
+	int			sbm_phy_oldanlpar;
+	int			sbm_phy_oldk1stsr;
+	int			sbm_phy_oldlinkstat;
+	int			sbm_buffersize;
 
-	struct net_device *sbm_dev;		/* pointer to linux device */
-	struct napi_struct napi;
-	spinlock_t sbm_lock;		/* spin lock */
-	struct timer_list sbm_timer;     	/* for monitoring MII */
-	int sbm_devflags;			/* current device flags */
-
-	int	     sbm_phy_oldbmsr;
-	int	     sbm_phy_oldanlpar;
-	int	     sbm_phy_oldk1stsr;
-	int	     sbm_phy_oldlinkstat;
-	int sbm_buffersize;
-
-	unsigned char sbm_phys[2];
+	unsigned char		sbm_phys[2];
 
 	/*
 	 * Controller-specific things
 	 */
+	void __iomem		*sbm_base;	/* MAC's base address */
+	enum sbmac_state	sbm_state;	/* current state */
 
-	void __iomem		*sbm_base;          /* MAC's base address */
-	sbmac_state_t    sbm_state;         /* current state */
-
-	volatile void __iomem	*sbm_macenable;	/* MAC Enable Register */
-	volatile void __iomem	*sbm_maccfg;	/* MAC Configuration Register */
-	volatile void __iomem	*sbm_fifocfg;	/* FIFO configuration register */
-	volatile void __iomem	*sbm_framecfg;	/* Frame configuration register */
-	volatile void __iomem	*sbm_rxfilter;	/* receive filter register */
-	volatile void __iomem	*sbm_isr;	/* Interrupt status register */
-	volatile void __iomem	*sbm_imr;	/* Interrupt mask register */
-	volatile void __iomem	*sbm_mdio;	/* MDIO register */
-
-	sbmac_speed_t    sbm_speed;		/* current speed */
-	sbmac_duplex_t   sbm_duplex;	/* current duplex */
-	sbmac_fc_t       sbm_fc;		/* current flow control setting */
-
-	unsigned char    sbm_hwaddr[ETHER_ADDR_LEN];
-
-	sbmacdma_t       sbm_txdma;		/* for now, only use channel 0 */
-	sbmacdma_t       sbm_rxdma;
-	int              rx_hw_checksum;
-	int 		 sbe_idx;
+	void __iomem		*sbm_macenable;	/* MAC Enable Register */
+	void __iomem		*sbm_maccfg;	/* MAC Config Register */
+	void __iomem		*sbm_fifocfg;	/* FIFO Config Register */
+	void __iomem		*sbm_framecfg;	/* Frame Config Register */
+	void __iomem		*sbm_rxfilter;	/* Receive Filter Register */
+	void __iomem		*sbm_isr;	/* Interrupt Status Register */
+	void __iomem		*sbm_imr;	/* Interrupt Mask Register */
+	void __iomem		*sbm_mdio;	/* MDIO Register */
+
+	enum sbmac_speed	sbm_speed;	/* current speed */
+	enum sbmac_duplex	sbm_duplex;	/* current duplex */
+	enum sbmac_fc		sbm_fc;		/* cur. flow control setting */
+
+	unsigned char		sbm_hwaddr[ETHER_ADDR_LEN];
+
+	struct sbmacdma		sbm_txdma;	/* only channel 0 for now */
+	struct sbmacdma		sbm_rxdma;
+	int			rx_hw_checksum;
+	int			sbe_idx;
 };
 
 
@@ -288,30 +292,31 @@ struct sbmac_softc {
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
-static int sbdma_rx_process(struct sbmac_softc *sc,sbmacdma_t *d, int work_to_do, int poll);
-static void sbdma_tx_process(struct sbmac_softc *sc,sbmacdma_t *d, int poll);
+static void sbdma_initctx(struct sbmacdma *d, struct sbmac_softc *s, int chan,
+			  int txrx, int maxdescr);
+static void sbdma_channel_start(struct sbmacdma *d, int rxtx);
+static int sbdma_add_rcvbuffer(struct sbmacdma *d, struct sk_buff *m);
+static int sbdma_add_txbuffer(struct sbmacdma *d, struct sk_buff *m);
+static void sbdma_emptyring(struct sbmacdma *d);
+static void sbdma_fillring(struct sbmacdma *d);
+static int sbdma_rx_process(struct sbmac_softc *sc, struct sbmacdma *d,
+			    int work_to_do, int poll);
+static void sbdma_tx_process(struct sbmac_softc *sc, struct sbmacdma *d,
+			     int poll);
 static int sbmac_initctx(struct sbmac_softc *s);
 static void sbmac_channel_start(struct sbmac_softc *s);
 static void sbmac_channel_stop(struct sbmac_softc *s);
-static sbmac_state_t sbmac_set_channel_state(struct sbmac_softc *,sbmac_state_t);
-static void sbmac_promiscuous_mode(struct sbmac_softc *sc,int onoff);
+static enum sbmac_state sbmac_set_channel_state(struct sbmac_softc *,
+						enum sbmac_state);
+static void sbmac_promiscuous_mode(struct sbmac_softc *sc, int onoff);
 static uint64_t sbmac_addr2reg(unsigned char *ptr);
-static irqreturn_t sbmac_intr(int irq,void *dev_instance);
+static irqreturn_t sbmac_intr(int irq, void *dev_instance);
 static int sbmac_start_tx(struct sk_buff *skb, struct net_device *dev);
 static void sbmac_setmulti(struct sbmac_softc *sc);
 static int sbmac_init(struct net_device *dev, int idx);
-static int sbmac_set_speed(struct sbmac_softc *s,sbmac_speed_t speed);
-static int sbmac_set_duplex(struct sbmac_softc *s,sbmac_duplex_t duplex,sbmac_fc_t fc);
+static int sbmac_set_speed(struct sbmac_softc *s, enum sbmac_speed speed);
+static int sbmac_set_duplex(struct sbmac_softc *s, enum sbmac_duplex duplex,
+			    enum sbmac_fc fc);
 
 static int sbmac_open(struct net_device *dev);
 static void sbmac_timer(unsigned long data);
@@ -321,13 +326,15 @@ static int sbmac_mii_ioctl(struct net_de
 static int sbmac_close(struct net_device *dev);
 static int sbmac_poll(struct napi_struct *napi, int budget);
 
-static int sbmac_mii_poll(struct sbmac_softc *s,int noisy);
+static int sbmac_mii_poll(struct sbmac_softc *s, int noisy);
 static int sbmac_mii_probe(struct net_device *dev);
 
 static void sbmac_mii_sync(struct sbmac_softc *s);
-static void sbmac_mii_senddata(struct sbmac_softc *s,unsigned int data, int bitcnt);
-static unsigned int sbmac_mii_read(struct sbmac_softc *s,int phyaddr,int regidx);
-static void sbmac_mii_write(struct sbmac_softc *s,int phyaddr,int regidx,
+static void sbmac_mii_senddata(struct sbmac_softc *s, unsigned int data,
+			       int bitcnt);
+static unsigned int sbmac_mii_read(struct sbmac_softc *s, int phyaddr,
+				   int regidx);
+static void sbmac_mii_write(struct sbmac_softc *s, int phyaddr, int regidx,
 			    unsigned int regval);
 
 
@@ -676,8 +683,8 @@ static void sbmac_mii_write(struct sbmac
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
@@ -686,11 +693,8 @@ static void sbmac_mii_write(struct sbmac
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
 #ifdef CONFIG_SBMAC_COALESCE
 	int int_pktcnt, int_timeout;
@@ -757,18 +761,17 @@ static void sbdma_initctx(sbmacdma_t *d,
 
 	d->sbdma_maxdescr = maxdescr;
 
-	d->sbdma_dscrtable_unaligned =
-	d->sbdma_dscrtable = (sbdmadscr_t *)
-		kmalloc((d->sbdma_maxdescr+1)*sizeof(sbdmadscr_t), GFP_KERNEL);
+	d->sbdma_dscrtable_unaligned = kcalloc(d->sbdma_maxdescr + 1,
+					       sizeof(*d->sbdma_dscrtable),
+					       GFP_KERNEL);
 
 	/*
 	 * The descriptor table must be aligned to at least 16 bytes or the
 	 * MAC will corrupt it.
 	 */
-	d->sbdma_dscrtable = (sbdmadscr_t *)
-		ALIGN((unsigned long)d->sbdma_dscrtable, sizeof(sbdmadscr_t));
-
-	memset(d->sbdma_dscrtable,0,d->sbdma_maxdescr*sizeof(sbdmadscr_t));
+	d->sbdma_dscrtable = (struct sbdmadscr *)
+			     ALIGN((unsigned long)d->sbdma_dscrtable_unaligned,
+				   sizeof(*d->sbdma_dscrtable));
 
 	d->sbdma_dscrtable_end = d->sbdma_dscrtable + d->sbdma_maxdescr;
 
@@ -779,7 +782,7 @@ static void sbdma_initctx(sbmacdma_t *d,
 	 */
 
 	d->sbdma_ctxtable = kcalloc(d->sbdma_maxdescr,
-				    sizeof(struct sk_buff *), GFP_KERNEL);
+				    sizeof(*d->sbdma_ctxtable), GFP_KERNEL);
 
 #ifdef CONFIG_SBMAC_COALESCE
 	/*
@@ -816,7 +819,7 @@ static void sbdma_initctx(sbmacdma_t *d,
  *  	   nothing
  ********************************************************************* */
 
-static void sbdma_channel_start(sbmacdma_t *d, int rxtx )
+static void sbdma_channel_start(struct sbmacdma *d, int rxtx)
 {
 	/*
 	 * Turn on the DMA channel
@@ -857,7 +860,7 @@ static void sbdma_channel_start(sbmacdma
  *  	   nothing
  ********************************************************************* */
 
-static void sbdma_channel_stop(sbmacdma_t *d)
+static void sbdma_channel_stop(struct sbmacdma *d)
 {
 	/*
 	 * Turn off the DMA channel
@@ -906,10 +909,10 @@ static void sbdma_align_skb(struct sk_bu
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
 
@@ -1021,10 +1024,10 @@ static int sbdma_add_rcvbuffer(sbmacdma_
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
@@ -1110,7 +1113,7 @@ static int sbdma_add_txbuffer(sbmacdma_t
  *  	   nothing
  ********************************************************************* */
 
-static void sbdma_emptyring(sbmacdma_t *d)
+static void sbdma_emptyring(struct sbmacdma *d)
 {
 	int idx;
 	struct sk_buff *sb;
@@ -1138,7 +1141,7 @@ static void sbdma_emptyring(sbmacdma_t *
  *  	   nothing
  ********************************************************************* */
 
-static void sbdma_fillring(sbmacdma_t *d)
+static void sbdma_fillring(struct sbmacdma *d)
 {
 	int idx;
 
@@ -1185,13 +1188,13 @@ static void sbmac_netpoll(struct net_dev
  *  	   nothing
  ********************************************************************* */
 
-static int sbdma_rx_process(struct sbmac_softc *sc,sbmacdma_t *d,
-                             int work_to_do, int poll)
+static int sbdma_rx_process(struct sbmac_softc *sc, struct sbmacdma *d,
+			    int work_to_do, int poll)
 {
 	struct net_device *dev = sc->sbm_dev;
 	int curidx;
 	int hwidx;
-	sbdmadscr_t *dsc;
+	struct sbdmadscr *dsc;
 	struct sk_buff *sb;
 	int len;
 	int work_done = 0;
@@ -1223,8 +1226,9 @@ again:
 		prefetch(dsc);
 		prefetch(&d->sbdma_ctxtable[curidx]);
 
-		hwidx = (int) (((__raw_readq(d->sbdma_curdscr) & M_DMA_CURDSCR_ADDR) -
-				d->sbdma_dscrtable_phys) / sizeof(sbdmadscr_t));
+		hwidx = ((__raw_readq(d->sbdma_curdscr) & M_DMA_CURDSCR_ADDR) -
+			 d->sbdma_dscrtable_phys) /
+			sizeof(*d->sbdma_dscrtable);
 
 		/*
 		 * If they're the same, that means we've processed all
@@ -1348,12 +1352,13 @@ done:
  *  	   nothing
  ********************************************************************* */
 
-static void sbdma_tx_process(struct sbmac_softc *sc,sbmacdma_t *d, int poll)
+static void sbdma_tx_process(struct sbmac_softc *sc, struct sbmacdma *d,
+			     int poll)
 {
 	struct net_device *dev = sc->sbm_dev;
 	int curidx;
 	int hwidx;
-	sbdmadscr_t *dsc;
+	struct sbdmadscr *dsc;
 	struct sk_buff *sb;
 	unsigned long flags;
 	int packets_handled = 0;
@@ -1363,8 +1368,8 @@ static void sbdma_tx_process(struct sbma
 	if (d->sbdma_remptr == d->sbdma_addptr)
 	  goto end_unlock;
 
-	hwidx = (int) (((__raw_readq(d->sbdma_curdscr) & M_DMA_CURDSCR_ADDR) -
-			d->sbdma_dscrtable_phys) / sizeof(sbdmadscr_t));
+	hwidx = ((__raw_readq(d->sbdma_curdscr) & M_DMA_CURDSCR_ADDR) -
+		 d->sbdma_dscrtable_phys) / sizeof(*d->sbdma_dscrtable);
 
 	for (;;) {
 		/*
@@ -1501,7 +1506,7 @@ static int sbmac_initctx(struct sbmac_so
 }
 
 
-static void sbdma_uninitctx(struct sbmacdma_s *d)
+static void sbdma_uninitctx(struct sbmacdma *d)
 {
 	if (d->sbdma_dscrtable_unaligned) {
 		kfree(d->sbdma_dscrtable_unaligned);
@@ -1537,7 +1542,7 @@ static void sbmac_uninitctx(struct sbmac
 static void sbmac_channel_start(struct sbmac_softc *s)
 {
 	uint64_t reg;
-	volatile void __iomem *port;
+	void __iomem *port;
 	uint64_t cfg,fifo,framecfg;
 	int idx, th_value;
 
@@ -1800,10 +1805,10 @@ static void sbmac_channel_stop(struct sb
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
@@ -1938,14 +1943,14 @@ static uint64_t sbmac_addr2reg(unsigned 
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
@@ -2027,15 +2032,16 @@ static int sbmac_set_speed(struct sbmac_
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
 
@@ -2228,7 +2234,7 @@ static int sbmac_start_tx(struct sk_buff
 static void sbmac_setmulti(struct sbmac_softc *sc)
 {
 	uint64_t reg;
-	volatile void __iomem *port;
+	void __iomem *port;
 	int idx;
 	struct dev_mc_list *mclist;
 	struct net_device *dev = sc->sbm_dev;
