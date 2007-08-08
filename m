From: Jeff Garzik <jeff@garzik.org>
Subject: [PATCH 2/3] 8139too: clean up register defines and structs
Date: Wed, 8 Aug 2007 02:45:18 -0400
Message-ID: <20070808064518.GA16645@havoc.gtf.org>
References: <20070808064440.GA16595@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: LKML <linux-kernel@vger.kernel.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:40697 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752813AbXHHGpT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Aug 2007 02:45:19 -0400
Content-Disposition: inline
In-Reply-To: <20070808064440.GA16595@havoc.gtf.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


commit 23b0a2f0f4e98a23f6fdf5b7ae4a4d60ca0cc3e2
Author: Jeff Garzik <jeff@garzik.org>
Date:   Wed Aug 8 02:28:46 2007 -0400

    [netdrvr] 8139too: tab-align enums and structs; remove dead code
    
    * (main change) tab-align hardware register value enums, and hw struct
    
    * MMIO_FLUSH_AUDIT_COMPLETE has been defined to 1 for a while.  Remove
      the code activated when it is set to zero.
    
    Signed-off-by: Jeff Garzik <jeff@garzik.org>

 drivers/net/8139too.c |  340 ++++++++++++++++++++++++--------------------------
 1 file changed, 167 insertions(+), 173 deletions(-)

23b0a2f0f4e98a23f6fdf5b7ae4a4d60ca0cc3e2
diff --git a/drivers/net/8139too.c b/drivers/net/8139too.c
index 0198f74..87ecaf8 100644
--- a/drivers/net/8139too.c
+++ b/drivers/net/8139too.c
@@ -291,198 +291,197 @@ static struct {
 
 /* Symbolic offsets to registers. */
 enum RTL8139_registers {
-	MAC0 = 0,		/* Ethernet hardware address. */
-	MAR0 = 8,		/* Multicast filter. */
-	TxStatus0 = 0x10,	/* Transmit status (Four 32bit registers). */
-	TxAddr0 = 0x20,		/* Tx descriptors (also four 32bit). */
-	RxBuf = 0x30,
-	ChipCmd = 0x37,
-	RxBufPtr = 0x38,
-	RxBufAddr = 0x3A,
-	IntrMask = 0x3C,
-	IntrStatus = 0x3E,
-	TxConfig = 0x40,
-	RxConfig = 0x44,
-	Timer = 0x48,		/* A general-purpose counter. */
-	RxMissed = 0x4C,	/* 24 bits valid, write clears. */
-	Cfg9346 = 0x50,
-	Config0 = 0x51,
-	Config1 = 0x52,
-	FlashReg = 0x54,
-	MediaStatus = 0x58,
-	Config3 = 0x59,
-	Config4 = 0x5A,		/* absent on RTL-8139A */
-	HltClk = 0x5B,
-	MultiIntr = 0x5C,
-	TxSummary = 0x60,
-	BasicModeCtrl = 0x62,
-	BasicModeStatus = 0x64,
-	NWayAdvert = 0x66,
-	NWayLPAR = 0x68,
-	NWayExpansion = 0x6A,
+	MAC0		= 0,	 /* Ethernet hardware address. */
+	MAR0		= 8,	 /* Multicast filter. */
+	TxStatus0	= 0x10,	 /* Transmit status (Four 32bit registers). */
+	TxAddr0		= 0x20,	 /* Tx descriptors (also four 32bit). */
+	RxBuf		= 0x30,
+	ChipCmd		= 0x37,
+	RxBufPtr	= 0x38,
+	RxBufAddr	= 0x3A,
+	IntrMask	= 0x3C,
+	IntrStatus	= 0x3E,
+	TxConfig	= 0x40,
+	RxConfig	= 0x44,
+	Timer		= 0x48,	 /* A general-purpose counter. */
+	RxMissed	= 0x4C,  /* 24 bits valid, write clears. */
+	Cfg9346		= 0x50,
+	Config0		= 0x51,
+	Config1		= 0x52,
+	FlashReg	= 0x54,
+	MediaStatus	= 0x58,
+	Config3		= 0x59,
+	Config4		= 0x5A,	 /* absent on RTL-8139A */
+	HltClk		= 0x5B,
+	MultiIntr	= 0x5C,
+	TxSummary	= 0x60,
+	BasicModeCtrl	= 0x62,
+	BasicModeStatus	= 0x64,
+	NWayAdvert	= 0x66,
+	NWayLPAR	= 0x68,
+	NWayExpansion	= 0x6A,
 	/* Undocumented registers, but required for proper operation. */
-	FIFOTMS = 0x70,		/* FIFO Control and test. */
-	CSCR = 0x74,		/* Chip Status and Configuration Register. */
-	PARA78 = 0x78,
-	PARA7c = 0x7c,		/* Magic transceiver parameter register. */
-	Config5 = 0xD8,		/* absent on RTL-8139A */
+	FIFOTMS		= 0x70,	 /* FIFO Control and test. */
+	CSCR		= 0x74,	 /* Chip Status and Configuration Register. */
+	PARA78		= 0x78,
+	PARA7c		= 0x7c,	 /* Magic transceiver parameter register. */
+	Config5		= 0xD8,	 /* absent on RTL-8139A */
 };
 
 enum ClearBitMasks {
-	MultiIntrClear = 0xF000,
-	ChipCmdClear = 0xE2,
-	Config1Clear = (1<<7)|(1<<6)|(1<<3)|(1<<2)|(1<<1),
+	MultiIntrClear	= 0xF000,
+	ChipCmdClear	= 0xE2,
+	Config1Clear	= (1<<7)|(1<<6)|(1<<3)|(1<<2)|(1<<1),
 };
 
 enum ChipCmdBits {
-	CmdReset = 0x10,
-	CmdRxEnb = 0x08,
-	CmdTxEnb = 0x04,
-	RxBufEmpty = 0x01,
+	CmdReset	= 0x10,
+	CmdRxEnb	= 0x08,
+	CmdTxEnb	= 0x04,
+	RxBufEmpty	= 0x01,
 };
 
 /* Interrupt register bits, using my own meaningful names. */
 enum IntrStatusBits {
-	PCIErr = 0x8000,
-	PCSTimeout = 0x4000,
-	RxFIFOOver = 0x40,
-	RxUnderrun = 0x20,
-	RxOverflow = 0x10,
-	TxErr = 0x08,
-	TxOK = 0x04,
-	RxErr = 0x02,
-	RxOK = 0x01,
-
-	RxAckBits = RxFIFOOver | RxOverflow | RxOK,
+	PCIErr		= 0x8000,
+	PCSTimeout	= 0x4000,
+	RxFIFOOver	= 0x40,
+	RxUnderrun	= 0x20,
+	RxOverflow	= 0x10,
+	TxErr		= 0x08,
+	TxOK		= 0x04,
+	RxErr		= 0x02,
+	RxOK		= 0x01,
+
+	RxAckBits	= RxFIFOOver | RxOverflow | RxOK,
 };
 
 enum TxStatusBits {
-	TxHostOwns = 0x2000,
-	TxUnderrun = 0x4000,
-	TxStatOK = 0x8000,
-	TxOutOfWindow = 0x20000000,
-	TxAborted = 0x40000000,
-	TxCarrierLost = 0x80000000,
+	TxHostOwns	= 0x2000,
+	TxUnderrun	= 0x4000,
+	TxStatOK	= 0x8000,
+	TxOutOfWindow	= 0x20000000,
+	TxAborted	= 0x40000000,
+	TxCarrierLost	= 0x80000000,
 };
 enum RxStatusBits {
-	RxMulticast = 0x8000,
-	RxPhysical = 0x4000,
-	RxBroadcast = 0x2000,
-	RxBadSymbol = 0x0020,
-	RxRunt = 0x0010,
-	RxTooLong = 0x0008,
-	RxCRCErr = 0x0004,
-	RxBadAlign = 0x0002,
-	RxStatusOK = 0x0001,
+	RxMulticast	= 0x8000,
+	RxPhysical	= 0x4000,
+	RxBroadcast	= 0x2000,
+	RxBadSymbol	= 0x0020,
+	RxRunt		= 0x0010,
+	RxTooLong	= 0x0008,
+	RxCRCErr	= 0x0004,
+	RxBadAlign	= 0x0002,
+	RxStatusOK	= 0x0001,
 };
 
 /* Bits in RxConfig. */
 enum rx_mode_bits {
-	AcceptErr = 0x20,
-	AcceptRunt = 0x10,
-	AcceptBroadcast = 0x08,
-	AcceptMulticast = 0x04,
-	AcceptMyPhys = 0x02,
-	AcceptAllPhys = 0x01,
+	AcceptErr	= 0x20,
+	AcceptRunt	= 0x10,
+	AcceptBroadcast	= 0x08,
+	AcceptMulticast	= 0x04,
+	AcceptMyPhys	= 0x02,
+	AcceptAllPhys	= 0x01,
 };
 
 /* Bits in TxConfig. */
 enum tx_config_bits {
-
         /* Interframe Gap Time. Only TxIFG96 doesn't violate IEEE 802.3 */
-        TxIFGShift = 24,
-        TxIFG84 = (0 << TxIFGShift),    /* 8.4us / 840ns (10 / 100Mbps) */
-        TxIFG88 = (1 << TxIFGShift),    /* 8.8us / 880ns (10 / 100Mbps) */
-        TxIFG92 = (2 << TxIFGShift),    /* 9.2us / 920ns (10 / 100Mbps) */
-        TxIFG96 = (3 << TxIFGShift),    /* 9.6us / 960ns (10 / 100Mbps) */
-
-	TxLoopBack = (1 << 18) | (1 << 17), /* enable loopback test mode */
-	TxCRC = (1 << 16),	/* DISABLE appending CRC to end of Tx packets */
-	TxClearAbt = (1 << 0),	/* Clear abort (WO) */
-	TxDMAShift = 8,		/* DMA burst value (0-7) is shifted this many bits */
-	TxRetryShift = 4,	/* TXRR value (0-15) is shifted this many bits */
-
-	TxVersionMask = 0x7C800000, /* mask out version bits 30-26, 23 */
+        TxIFGShift	= 24,
+        TxIFG84		= (0 << TxIFGShift), /* 8.4us / 840ns (10 / 100Mbps) */
+        TxIFG88		= (1 << TxIFGShift), /* 8.8us / 880ns (10 / 100Mbps) */
+        TxIFG92		= (2 << TxIFGShift), /* 9.2us / 920ns (10 / 100Mbps) */
+        TxIFG96		= (3 << TxIFGShift), /* 9.6us / 960ns (10 / 100Mbps) */
+
+	TxLoopBack	= (1 << 18) | (1 << 17), /* enable loopback test mode */
+	TxCRC		= (1 << 16),	/* DISABLE Tx pkt CRC append */
+	TxClearAbt	= (1 << 0),	/* Clear abort (WO) */
+	TxDMAShift	= 8, /* DMA burst value (0-7) is shifted X many bits */
+	TxRetryShift	= 4, /* TXRR value (0-15) is shifted X many bits */
+
+	TxVersionMask	= 0x7C800000, /* mask out version bits 30-26, 23 */
 };
 
 /* Bits in Config1 */
 enum Config1Bits {
-	Cfg1_PM_Enable = 0x01,
-	Cfg1_VPD_Enable = 0x02,
-	Cfg1_PIO = 0x04,
-	Cfg1_MMIO = 0x08,
-	LWAKE = 0x10,		/* not on 8139, 8139A */
+	Cfg1_PM_Enable	= 0x01,
+	Cfg1_VPD_Enable	= 0x02,
+	Cfg1_PIO	= 0x04,
+	Cfg1_MMIO	= 0x08,
+	LWAKE		= 0x10,		/* not on 8139, 8139A */
 	Cfg1_Driver_Load = 0x20,
-	Cfg1_LED0 = 0x40,
-	Cfg1_LED1 = 0x80,
-	SLEEP = (1 << 1),	/* only on 8139, 8139A */
-	PWRDN = (1 << 0),	/* only on 8139, 8139A */
+	Cfg1_LED0	= 0x40,
+	Cfg1_LED1	= 0x80,
+	SLEEP		= (1 << 1),	/* only on 8139, 8139A */
+	PWRDN		= (1 << 0),	/* only on 8139, 8139A */
 };
 
 /* Bits in Config3 */
 enum Config3Bits {
-	Cfg3_FBtBEn    = (1 << 0), /* 1 = Fast Back to Back */
-	Cfg3_FuncRegEn = (1 << 1), /* 1 = enable CardBus Function registers */
-	Cfg3_CLKRUN_En = (1 << 2), /* 1 = enable CLKRUN */
-	Cfg3_CardB_En  = (1 << 3), /* 1 = enable CardBus registers */
-	Cfg3_LinkUp    = (1 << 4), /* 1 = wake up on link up */
-	Cfg3_Magic     = (1 << 5), /* 1 = wake up on Magic Packet (tm) */
-	Cfg3_PARM_En   = (1 << 6), /* 0 = software can set twister parameters */
-	Cfg3_GNTSel    = (1 << 7), /* 1 = delay 1 clock from PCI GNT signal */
+	Cfg3_FBtBEn   	= (1 << 0), /* 1	= Fast Back to Back */
+	Cfg3_FuncRegEn	= (1 << 1), /* 1	= enable CardBus Function registers */
+	Cfg3_CLKRUN_En	= (1 << 2), /* 1	= enable CLKRUN */
+	Cfg3_CardB_En 	= (1 << 3), /* 1	= enable CardBus registers */
+	Cfg3_LinkUp   	= (1 << 4), /* 1	= wake up on link up */
+	Cfg3_Magic    	= (1 << 5), /* 1	= wake up on Magic Packet (tm) */
+	Cfg3_PARM_En  	= (1 << 6), /* 0	= software can set twister parameters */
+	Cfg3_GNTSel   	= (1 << 7), /* 1	= delay 1 clock from PCI GNT signal */
 };
 
 /* Bits in Config4 */
 enum Config4Bits {
-	LWPTN = (1 << 2),	/* not on 8139, 8139A */
+	LWPTN	= (1 << 2),	/* not on 8139, 8139A */
 };
 
 /* Bits in Config5 */
 enum Config5Bits {
-	Cfg5_PME_STS     = (1 << 0), /* 1 = PCI reset resets PME_Status */
-	Cfg5_LANWake     = (1 << 1), /* 1 = enable LANWake signal */
-	Cfg5_LDPS        = (1 << 2), /* 0 = save power when link is down */
-	Cfg5_FIFOAddrPtr = (1 << 3), /* Realtek internal SRAM testing */
-	Cfg5_UWF         = (1 << 4), /* 1 = accept unicast wakeup frame */
-	Cfg5_MWF         = (1 << 5), /* 1 = accept multicast wakeup frame */
-	Cfg5_BWF         = (1 << 6), /* 1 = accept broadcast wakeup frame */
+	Cfg5_PME_STS   	= (1 << 0), /* 1	= PCI reset resets PME_Status */
+	Cfg5_LANWake   	= (1 << 1), /* 1	= enable LANWake signal */
+	Cfg5_LDPS      	= (1 << 2), /* 0	= save power when link is down */
+	Cfg5_FIFOAddrPtr= (1 << 3), /* Realtek internal SRAM testing */
+	Cfg5_UWF        = (1 << 4), /* 1 = accept unicast wakeup frame */
+	Cfg5_MWF        = (1 << 5), /* 1 = accept multicast wakeup frame */
+	Cfg5_BWF        = (1 << 6), /* 1 = accept broadcast wakeup frame */
 };
 
 enum RxConfigBits {
 	/* rx fifo threshold */
-	RxCfgFIFOShift = 13,
-	RxCfgFIFONone = (7 << RxCfgFIFOShift),
+	RxCfgFIFOShift	= 13,
+	RxCfgFIFONone	= (7 << RxCfgFIFOShift),
 
 	/* Max DMA burst */
-	RxCfgDMAShift = 8,
+	RxCfgDMAShift	= 8,
 	RxCfgDMAUnlimited = (7 << RxCfgDMAShift),
 
 	/* rx ring buffer length */
-	RxCfgRcv8K = 0,
-	RxCfgRcv16K = (1 << 11),
-	RxCfgRcv32K = (1 << 12),
-	RxCfgRcv64K = (1 << 11) | (1 << 12),
+	RxCfgRcv8K	= 0,
+	RxCfgRcv16K	= (1 << 11),
+	RxCfgRcv32K	= (1 << 12),
+	RxCfgRcv64K	= (1 << 11) | (1 << 12),
 
 	/* Disable packet wrap at end of Rx buffer. (not possible with 64k) */
-	RxNoWrap = (1 << 7),
+	RxNoWrap	= (1 << 7),
 };
 
 /* Twister tuning parameters from RealTek.
    Completely undocumented, but required to tune bad links on some boards. */
 enum CSCRBits {
-	CSCR_LinkOKBit = 0x0400,
-	CSCR_LinkChangeBit = 0x0800,
-	CSCR_LinkStatusBits = 0x0f000,
-	CSCR_LinkDownOffCmd = 0x003c0,
-	CSCR_LinkDownCmd = 0x0f3c0,
+	CSCR_LinkOKBit		= 0x0400,
+	CSCR_LinkChangeBit	= 0x0800,
+	CSCR_LinkStatusBits	= 0x0f000,
+	CSCR_LinkDownOffCmd	= 0x003c0,
+	CSCR_LinkDownCmd	= 0x0f3c0,
 };
 
 enum Cfg9346Bits {
-	Cfg9346_Lock = 0x00,
-	Cfg9346_Unlock = 0xC0,
+	Cfg9346_Lock	= 0x00,
+	Cfg9346_Unlock	= 0xC0,
 };
 
 typedef enum {
-	CH_8139 = 0,
+	CH_8139	= 0,
 	CH_8139_K,
 	CH_8139A,
 	CH_8139A_G,
@@ -495,8 +494,8 @@ typedef enum {
 } chip_t;
 
 enum chip_flags {
-	HasHltClk = (1 << 0),
-	HasLWake = (1 << 1),
+	HasHltClk	= (1 << 0),
+	HasLWake	= (1 << 1),
 };
 
 #define HW_REVID(b30, b29, b28, b27, b26, b23, b22) \
@@ -569,36 +568,44 @@ struct rtl_extra_stats {
 };
 
 struct rtl8139_private {
-	void __iomem *mmio_addr;
-	int drv_flags;
-	struct pci_dev *pci_dev;
-	u32 msg_enable;
-	struct net_device_stats stats;
-	unsigned char *rx_ring;
-	unsigned int cur_rx;	/* Index into the Rx buffer of next Rx pkt. */
-	unsigned int tx_flag;
-	unsigned long cur_tx;
-	unsigned long dirty_tx;
-	unsigned char *tx_buf[NUM_TX_DESC];	/* Tx bounce buffers */
-	unsigned char *tx_bufs;	/* Tx bounce buffer region. */
-	dma_addr_t rx_ring_dma;
-	dma_addr_t tx_bufs_dma;
-	signed char phys[4];		/* MII device addresses. */
-	char twistie, twist_row, twist_col;	/* Twister tune state. */
-	unsigned int watchdog_fired : 1;
-	unsigned int default_port : 4;	/* Last dev->if_port value. */
-	unsigned int have_thread : 1;
-	spinlock_t lock;
-	spinlock_t rx_lock;
-	chip_t chipset;
-	u32 rx_config;
-	struct rtl_extra_stats xstats;
-
-	struct delayed_work thread;
-
-	struct mii_if_info mii;
-	unsigned int regs_len;
-	unsigned long fifo_copy_timeout;
+	void __iomem		*mmio_addr;
+	int			drv_flags;
+	struct pci_dev		*pci_dev;
+	u32			msg_enable;
+	struct net_device_stats	stats;
+
+	unsigned char		*rx_ring;
+	unsigned int		cur_rx;	/* RX buf index of next pkt */
+	dma_addr_t		rx_ring_dma;
+
+	unsigned int		tx_flag;
+	unsigned long		cur_tx;
+	unsigned long		dirty_tx;
+	unsigned char		*tx_buf[NUM_TX_DESC];	/* Tx bounce buffers */
+	unsigned char		*tx_bufs;	/* Tx bounce buffer region. */
+	dma_addr_t		tx_bufs_dma;
+
+	signed char		phys[4];	/* MII device addresses. */
+
+				/* Twister tune state. */
+	char			twistie, twist_row, twist_col;
+
+	unsigned int		watchdog_fired : 1;
+	unsigned int		default_port : 4; /* Last dev->if_port value. */
+	unsigned int		have_thread : 1;
+
+	spinlock_t		lock;
+	spinlock_t		rx_lock;
+
+	chip_t			chipset;
+	u32			rx_config;
+	struct rtl_extra_stats	xstats;
+
+	struct delayed_work	thread;
+
+	struct mii_if_info	mii;
+	unsigned int		regs_len;
+	unsigned long		fifo_copy_timeout;
 };
 
 MODULE_AUTHOR ("Jeff Garzik <jgarzik@pobox.com>");
@@ -646,24 +653,11 @@ static const struct ethtool_ops rtl8139_ethtool_ops;
 #define RTL_W16_F(reg, val16)	do { iowrite16 ((val16), ioaddr + (reg)); ioread16 (ioaddr + (reg)); } while (0)
 #define RTL_W32_F(reg, val32)	do { iowrite32 ((val32), ioaddr + (reg)); ioread32 (ioaddr + (reg)); } while (0)
 
-
-#define MMIO_FLUSH_AUDIT_COMPLETE 1
-#if MMIO_FLUSH_AUDIT_COMPLETE
-
 /* write MMIO register */
 #define RTL_W8(reg, val8)	iowrite8 ((val8), ioaddr + (reg))
 #define RTL_W16(reg, val16)	iowrite16 ((val16), ioaddr + (reg))
 #define RTL_W32(reg, val32)	iowrite32 ((val32), ioaddr + (reg))
 
-#else
-
-/* write MMIO register, then flush */
-#define RTL_W8		RTL_W8_F
-#define RTL_W16		RTL_W16_F
-#define RTL_W32		RTL_W32_F
-
-#endif /* MMIO_FLUSH_AUDIT_COMPLETE */
-
 /* read MMIO register */
 #define RTL_R8(reg)		ioread8 (ioaddr + (reg))
 #define RTL_R16(reg)		ioread16 (ioaddr + (reg))
