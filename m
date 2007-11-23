From: Pekka J Enberg <penberg@cs.helsinki.fi>
Subject: [PATCH 8/8] ipg: fix checkpatch reported errors
Date: Fri, 23 Nov 2007 10:20:19 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0711231020040.18378@sbz-30.cs.Helsinki.FI>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: romieu@fr.zoreil.com, sorbica@icplus.com.tw, jesse@icplus.com.tw,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:42513 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753166AbXKWIUV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Nov 2007 03:20:21 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pekka Enberg <penberg@cs.helsinki.fi>

Cc: Francois Romieu <romieu@fr.zoreil.com>
Cc: Sorbica Shieh <sorbica@icplus.com.tw>
Cc: Jesse Huang <jesse@icplus.com.tw>
Signed-off-by: Pekka Enberg <penberg@cs.helsinki.fi>
---
 drivers/net/ipg.c |   48 +++++++++++++++++++++++++-----------------------
 drivers/net/ipg.h |   32 ++++++++++++++++----------------
 2 files changed, 41 insertions(+), 39 deletions(-)

Index: 2.6/drivers/net/ipg.c
===================================================================
--- 2.6.orig/drivers/net/ipg.c	2007-11-23 10:08:41.000000000 +0200
+++ 2.6/drivers/net/ipg.c	2007-11-23 10:14:00.000000000 +0200
@@ -34,9 +34,9 @@  * Copyright (C) 2003, 2007  IC Plus Cor
 	 IPG_AC_DMA | IPG_AC_FIFO | IPG_AC_NETWORK | IPG_AC_HOST | \
 	 IPG_AC_AUTO_INIT)
 
-#define ipg_w32(val32,reg)	iowrite32((val32), ioaddr + (reg))
-#define ipg_w16(val16,reg)	iowrite16((val16), ioaddr + (reg))
-#define ipg_w8(val8,reg)	iowrite8((val8), ioaddr + (reg))
+#define ipg_w32(val32, reg)	iowrite32((val32), ioaddr + (reg))
+#define ipg_w16(val16, reg)	iowrite16((val16), ioaddr + (reg))
+#define ipg_w8(val8, reg)	iowrite8((val8), ioaddr + (reg))
 
 #define ipg_r32(reg)		ioread32(ioaddr + (reg))
 #define ipg_r16(reg)		ioread16(ioaddr + (reg))
@@ -54,20 +54,22 @@ MODULE_AUTHOR("IC Plus Corp. 2003");
 MODULE_DESCRIPTION("IC Plus IP1000 Gigabit Ethernet Adapter Linux Driver");
 MODULE_LICENSE("GPL");
 
-//variable record -- index by leading revision/length
-//Revision/Length(=N*4), Address1, Data1, Address2, Data2,...,AddressN,DataN
+/*
+ * variable record -- index by leading revision/length
+ * Revision/Length(=N*4), Address1, Data1, Address2, Data2,...,AddressN,DataN
+ */
 static unsigned short DefaultPhyParam[] = {
-	// 11/12/03 IP1000A v1-3 rev=0x40
+	/* 11/12/03 IP1000A v1-3 rev=0x40 */
 	/*--------------------------------------------------------------------------
 	(0x4000|(15*4)), 31, 0x0001, 27, 0x01e0, 31, 0x0002, 22, 0x85bd, 24, 0xfff2,
 				 27, 0x0c10, 28, 0x0c10, 29, 0x2c10, 31, 0x0003, 23, 0x92f6,
 				 31, 0x0000, 23, 0x003d, 30, 0x00de, 20, 0x20e7,  9, 0x0700,
 	  --------------------------------------------------------------------------*/
-	// 12/17/03 IP1000A v1-4 rev=0x40
+	/* 12/17/03 IP1000A v1-4 rev=0x40 */
 	(0x4000 | (07 * 4)), 31, 0x0001, 27, 0x01e0, 31, 0x0002, 27, 0xeb8e, 31,
 	    0x0000,
 	30, 0x005e, 9, 0x0700,
-	// 01/09/04 IP1000A v1-5 rev=0x41
+	/* 01/09/04 IP1000A v1-5 rev=0x41 */
 	(0x4100 | (07 * 4)), 31, 0x0001, 27, 0x01e0, 31, 0x0002, 27, 0xeb8e, 31,
 	    0x0000,
 	30, 0x005e, 9, 0x0700,
@@ -187,7 +189,7 @@ 	ipg_w8((IPG_PC_MGMTCLK_LO | (IPG_PC_MGM
 		phyctrlpolarity) & IPG_PC_RSVD_MASK, PHY_CTRL);
 }
 
-static u16 read_phy_bit(void __iomem * ioaddr, u8 phyctrlpolarity)
+static u16 read_phy_bit(void __iomem *ioaddr, u8 phyctrlpolarity)
 {
 	u16 bit_data;
 
@@ -204,7 +206,7 @@ static u16 read_phy_bit(void __iomem * i
  * Read a register from the Physical Layer device located
  * on the IPG NIC, using the IPG PHYCTRL register.
  */
-static int mdio_read(struct net_device * dev, int phy_id, int phy_reg)
+static int mdio_read(struct net_device *dev, int phy_id, int phy_reg)
 {
 	void __iomem *ioaddr = ipg_ioaddr(dev);
 	/*
@@ -548,7 +550,7 @@ 		return 0;
 		printk("\n");
 	} else {
 		/* Configure IPG for half duplex operation. */
-	        printk(KERN_INFO "%s: setting half duplex, "
+		printk(KERN_INFO "%s: setting half duplex, "
 		       "no TX flow control, no RX flow control.\n", dev->name);
 
 		mac_ctrl_val &= ~IPG_MC_DUPLEX_SELECT_FD &
@@ -1089,12 +1091,12 @@ 	return 0;
 #ifdef JUMBO_FRAME
 
 /* use jumboindex and jumbosize to control jumbo frame status
-   initial status is jumboindex=-1 and jumbosize=0
-   1. jumboindex = -1 and jumbosize=0 : previous jumbo frame has been done.
-   2. jumboindex != -1 and jumbosize != 0 : jumbo frame is not over size and receiving
-   3. jumboindex = -1 and jumbosize != 0 : jumbo frame is over size, already dump
-                previous receiving and need to continue dumping the current one
-*/
+ * initial status is jumboindex=-1 and jumbosize=0
+ * 1. jumboindex = -1 and jumbosize=0 : previous jumbo frame has been done.
+ * 2. jumboindex != -1 and jumbosize != 0 : jumbo frame is not over size and receiving
+ * 3. jumboindex = -1 and jumbosize != 0 : jumbo frame is over size, already dump
+ *               previous receiving and need to continue dumping the current one
+ */
 enum {
 	NORMAL_PACKET,
 	ERROR_PACKET
@@ -1209,7 +1211,7 @@ 		jumbo->current_size = 0;
 		jumbo->skb = NULL;
 	}
 
-	// 1: found error, 0 no error
+	/* 1: found error, 0 no error */
 	if (ipg_nic_rx_check_error(dev) != NORMAL_PACKET)
 		return;
 
@@ -1217,7 +1219,7 @@ 	// 1: found error, 0 no error
 	if (!skb)
 		return;
 
-	// accept this frame and send to upper layer
+	/* accept this frame and send to upper layer */
 	framelen = le64_to_cpu(rxfd->rfs) & IPG_RFS_RXFRAMELEN;
 	if (framelen > IPG_RXFRAG_SIZE)
 		framelen = IPG_RXFRAG_SIZE;
@@ -1238,11 +1240,11 @@ static void ipg_nic_rx_with_start(struct
 	struct pci_dev *pdev = sp->pdev;
 	struct sk_buff *skb;
 
-	// 1: found error, 0 no error
+	/* 1: found error, 0 no error */
 	if (ipg_nic_rx_check_error(dev) != NORMAL_PACKET)
 		return;
 
-	// accept this frame and send to upper layer
+	/* accept this frame and send to upper layer */
 	skb = sp->rx_buff[entry];
 	if (!skb)
 		return;
@@ -1269,7 +1271,7 @@ static void ipg_nic_rx_with_end(struct n
 {
 	struct ipg_jumbo *jumbo = &sp->jumbo;
 
-	//1: found error, 0 no error
+	/* 1: found error, 0 no error */
 	if (ipg_nic_rx_check_error(dev) == NORMAL_PACKET) {
 		struct sk_buff *skb = sp->rx_buff[entry];
 
@@ -1320,7 +1322,7 @@ static void ipg_nic_rx_no_start_no_end(s
 {
 	struct ipg_jumbo *jumbo = &sp->jumbo;
 
-	//1: found error, 0 no error
+	/* 1: found error, 0 no error */
 	if (ipg_nic_rx_check_error(dev) == NORMAL_PACKET) {
 		struct sk_buff *skb = sp->rx_buff[entry];
 
Index: 2.6/drivers/net/ipg.h
===================================================================
--- 2.6.orig/drivers/net/ipg.h	2007-11-23 10:08:41.000000000 +0200
+++ 2.6/drivers/net/ipg.h	2007-11-23 10:12:05.000000000 +0200
@@ -51,7 +51,7 @@ #define         GMII_TA_WRITE           
 /* I/O register offsets. */
 enum ipg_regs {
 	DMA_CTRL		= 0x00,
-	RX_DMA_STATUS		= 0x08, // Unused + reserved
+	RX_DMA_STATUS		= 0x08, /* Unused + reserved */
 	TFD_LIST_PTR_0		= 0x10,
 	TFD_LIST_PTR_1		= 0x14,
 	TX_DMA_BURST_THRESH	= 0x18,
@@ -64,21 +64,21 @@ 	RX_DMA_URGENT_THRESH	= 0x25,
 	RX_DMA_POLL_PERIOD	= 0x26,
 	DEBUG_CTRL		= 0x2c,
 	ASIC_CTRL		= 0x30,
-	FIFO_CTRL		= 0x38, // Unused
+	FIFO_CTRL		= 0x38, /* Unused */
 	FLOW_OFF_THRESH		= 0x3c,
 	FLOW_ON_THRESH		= 0x3e,
 	EEPROM_DATA		= 0x48,
 	EEPROM_CTRL		= 0x4a,
-	EXPROM_ADDR		= 0x4c, // Unused
-	EXPROM_DATA		= 0x50, // Unused
-	WAKE_EVENT		= 0x51, // Unused
-	COUNTDOWN		= 0x54, // Unused
+	EXPROM_ADDR		= 0x4c, /* Unused */
+	EXPROM_DATA		= 0x50, /* Unused */
+	WAKE_EVENT		= 0x51, /* Unused */
+	COUNTDOWN		= 0x54, /* Unused */
 	INT_STATUS_ACK		= 0x5a,
 	INT_ENABLE		= 0x5c,
-	INT_STATUS		= 0x5e, // Unused
+	INT_STATUS		= 0x5e, /* Unused */
 	TX_STATUS		= 0x60,
 	MAC_CTRL		= 0x6c,
-	VLAN_TAG		= 0x70, // Unused
+	VLAN_TAG		= 0x70, /* Unused */
 	PHY_SET			= 0x75,
 	PHY_CTRL		= 0x76,
 	STATION_ADDRESS_0	= 0x78,
@@ -90,11 +90,11 @@ 	HASHTABLE_0		= 0x8c,
 	HASHTABLE_1		= 0x90,
 	RMON_STATISTICS_MASK	= 0x98,
 	STATISTICS_MASK		= 0x9c,
-	RX_JUMBO_FRAMES		= 0xbc, // Unused
-	TCP_CHECKSUM_ERRORS	= 0xc0, // Unused
-	IP_CHECKSUM_ERRORS	= 0xc2, // Unused
-	UDP_CHECKSUM_ERRORS	= 0xc4, // Unused
-	TX_JUMBO_FRAMES		= 0xf4  // Unused
+	RX_JUMBO_FRAMES		= 0xbc, /* Unused */
+	TCP_CHECKSUM_ERRORS	= 0xc0, /* Unused */
+	IP_CHECKSUM_ERRORS	= 0xc2, /* Unused */
+	UDP_CHECKSUM_ERRORS	= 0xc4, /* Unused */
+	TX_JUMBO_FRAMES		= 0xf4  /* Unused */
 };
 
 /* Ethernet MIB statistic register offsets. */
@@ -590,7 +590,7 @@ /* Size of allocated received buffers. N
  * Define larger if expecting jumbo frames.
  */
 #ifdef JUMBO_FRAME
-//IPG_TXFRAG_SIZE must <= 0x2b00, or TX will crash
+/* IPG_TXFRAG_SIZE must <= 0x2b00, or TX will crash */
 #define		IPG_TXFRAG_SIZE		JUMBO_FRAME_SIZE
 #endif
 
@@ -598,7 +598,7 @@ /* Size of allocated received buffers. N
  * Define larger if expecting jumbo frames.
  */
 #ifdef JUMBO_FRAME
-//4088=4096-8
+/* 4088=4096-8 */
 #define		IPG_RXFRAG_SIZE		__IPG_RXFRAG_SIZE
 #define     IPG_RXSUPPORT_SIZE   IPG_MAX_RXFRAME_SIZE
 #else
@@ -628,7 +628,7 @@ #define		IPG_MINUSEDRFDSTOFREE	0x80
 /* specify the jumbo frame maximum size
  * per unit is 0x600 (the rx_buffer size that one RFD can carry)
  */
-#define     MAX_JUMBOSIZE	        0x8	// max is 12K
+#define     MAX_JUMBOSIZE	        0x8	/* max is 12K */
 
 /* Key register values loaded at driver start up. */
 
