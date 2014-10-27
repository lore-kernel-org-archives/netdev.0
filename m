From: Roberto Medina <robertoxmed@gmail.com>
Subject: [PATCH v2] net: ethernet: realtek: atp: checkpatch errors and warnings corrected
Date: Tue, 28 Oct 2014 00:51:56 +0100
Message-ID: <1414453916-27976-1-git-send-email-robertoxmed@gmail.com>
Cc: linux-kernel@vger.kernel.org,
	Roberto Medina <robertoxmed@gmail.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Roberto Medina <robertoxmed@gmail.com>

Several warnings and errors of coding style rules corrected.
Compile tested.

Signed-off-by: Roberto Medina <robertoxmed@gmail.com>

---
 drivers/net/ethernet/realtek/atp.h | 246 +++++++++++++++++++------------------
 1 file changed, 127 insertions(+), 119 deletions(-)

diff --git a/drivers/net/ethernet/realtek/atp.h b/drivers/net/ethernet/realtek/atp.h
index 040b137..32497f0 100644
--- a/drivers/net/ethernet/realtek/atp.h
+++ b/drivers/net/ethernet/realtek/atp.h
@@ -6,10 +6,10 @@
 
 /* The header prepended to received packets. */
 struct rx_header {
-    ushort pad;			/* Pad. */
-    ushort rx_count;
-    ushort rx_status;		/* Unknown bit assignments :-<.  */
-    ushort cur_addr;		/* Apparently the current buffer address(?) */
+	ushort pad;		/* Pad. */
+	ushort rx_count;
+	ushort rx_status;	/* Unknown bit assignments :-<.  */
+	ushort cur_addr;	/* Apparently the current buffer address(?) */
 };
 
 #define PAR_DATA	0
@@ -29,22 +29,25 @@ struct rx_header {
 #define RdAddr	0xC0
 #define HNib	0x10
 
-enum page0_regs
-{
-    /* The first six registers hold the ethernet physical station address. */
-    PAR0 = 0, PAR1 = 1, PAR2 = 2, PAR3 = 3, PAR4 = 4, PAR5 = 5,
-    TxCNT0 = 6, TxCNT1 = 7,		/* The transmit byte count. */
-    TxSTAT = 8, RxSTAT = 9,		/* Tx and Rx status. */
-    ISR = 10, IMR = 11,			/* Interrupt status and mask. */
-    CMR1 = 12,				/* Command register 1. */
-    CMR2 = 13,				/* Command register 2. */
-    MODSEL = 14,			/* Mode select register. */
-    MAR = 14,				/* Memory address register (?). */
-    CMR2_h = 0x1d, };
-
-enum eepage_regs
-{ PROM_CMD = 6, PROM_DATA = 7 };	/* Note that PROM_CMD is in the "high" bits. */
+enum page0_regs {
+	/* The first six registers hold
+	 * the ethernet physical station address.
+	 */
+	PAR0 = 0, PAR1 = 1, PAR2 = 2, PAR3 = 3, PAR4 = 4, PAR5 = 5,
+	TxCNT0 = 6, TxCNT1 = 7,		/* The transmit byte count. */
+	TxSTAT = 8, RxSTAT = 9,		/* Tx and Rx status. */
+	ISR = 10, IMR = 11,		/* Interrupt status and mask. */
+	CMR1 = 12,			/* Command register 1. */
+	CMR2 = 13,			/* Command register 2. */
+	MODSEL = 14,		/* Mode select register. */
+	MAR = 14,			/* Memory address register (?). */
+	CMR2_h = 0x1d,
+};
 
+enum eepage_regs {
+	PROM_CMD = 6,
+	PROM_DATA = 7	/* Note that PROM_CMD is in the "high" bits. */
+};
 
 #define ISR_TxOK	0x01
 #define ISR_RxOK	0x04
@@ -72,141 +75,146 @@ enum eepage_regs
 #define CMR2h_Normal	2	/* Accept physical and broadcast address. */
 #define CMR2h_PROMISC	3	/* Promiscuous mode. */
 
-/* An inline function used below: it differs from inb() by explicitly return an unsigned
-   char, saving a truncation. */
+/* An inline function used below: it differs from inb() by explicitly
+ * return an unsigned char, saving a truncation.
+ */
 static inline unsigned char inbyte(unsigned short port)
 {
-    unsigned char _v;
-    __asm__ __volatile__ ("inb %w1,%b0" :"=a" (_v):"d" (port));
-    return _v;
+	unsigned char _v;
+
+	__asm__ __volatile__ ("inb %w1,%b0" : "=a" (_v) : "d" (port));
+	return _v;
 }
 
 /* Read register OFFSET.
-   This command should always be terminated with read_end(). */
+ * This command should always be terminated with read_end().
+ */
 static inline unsigned char read_nibble(short port, unsigned char offset)
 {
-    unsigned char retval;
-    outb(EOC+offset, port + PAR_DATA);
-    outb(RdAddr+offset, port + PAR_DATA);
-    inbyte(port + PAR_STATUS);		/* Settling time delay */
-    retval = inbyte(port + PAR_STATUS);
-    outb(EOC+offset, port + PAR_DATA);
-
-    return retval;
+	unsigned char retval;
+
+	outb(EOC+offset, port + PAR_DATA);
+	outb(RdAddr+offset, port + PAR_DATA);
+	inbyte(port + PAR_STATUS);	/* Settling time delay */
+	retval = inbyte(port + PAR_STATUS);
+	outb(EOC+offset, port + PAR_DATA);
+
+	return retval;
 }
 
 /* Functions for bulk data read.  The interrupt line is always disabled. */
 /* Get a byte using read mode 0, reading data from the control lines. */
 static inline unsigned char read_byte_mode0(short ioaddr)
 {
-    unsigned char low_nib;
-
-    outb(Ctrl_LNibRead, ioaddr + PAR_CONTROL);
-    inbyte(ioaddr + PAR_STATUS);
-    low_nib = (inbyte(ioaddr + PAR_STATUS) >> 3) & 0x0f;
-    outb(Ctrl_HNibRead, ioaddr + PAR_CONTROL);
-    inbyte(ioaddr + PAR_STATUS);	/* Settling time delay -- needed!  */
-    inbyte(ioaddr + PAR_STATUS);	/* Settling time delay -- needed!  */
-    return low_nib | ((inbyte(ioaddr + PAR_STATUS) << 1) & 0xf0);
+	unsigned char low_nib;
+
+	outb(Ctrl_LNibRead, ioaddr + PAR_CONTROL);
+	inbyte(ioaddr + PAR_STATUS);
+	low_nib = (inbyte(ioaddr + PAR_STATUS) >> 3) & 0x0f;
+	outb(Ctrl_HNibRead, ioaddr + PAR_CONTROL);
+	inbyte(ioaddr + PAR_STATUS);	/* Settling time delay -- needed!  */
+	inbyte(ioaddr + PAR_STATUS);	/* Settling time delay -- needed!  */
+	return low_nib | ((inbyte(ioaddr + PAR_STATUS) << 1) & 0xf0);
 }
 
 /* The same as read_byte_mode0(), but does multiple inb()s for stability. */
 static inline unsigned char read_byte_mode2(short ioaddr)
 {
-    unsigned char low_nib;
-
-    outb(Ctrl_LNibRead, ioaddr + PAR_CONTROL);
-    inbyte(ioaddr + PAR_STATUS);
-    low_nib = (inbyte(ioaddr + PAR_STATUS) >> 3) & 0x0f;
-    outb(Ctrl_HNibRead, ioaddr + PAR_CONTROL);
-    inbyte(ioaddr + PAR_STATUS);	/* Settling time delay -- needed!  */
-    return low_nib | ((inbyte(ioaddr + PAR_STATUS) << 1) & 0xf0);
+	unsigned char low_nib;
+
+	outb(Ctrl_LNibRead, ioaddr + PAR_CONTROL);
+	inbyte(ioaddr + PAR_STATUS);
+	low_nib = (inbyte(ioaddr + PAR_STATUS) >> 3) & 0x0f;
+	outb(Ctrl_HNibRead, ioaddr + PAR_CONTROL);
+	inbyte(ioaddr + PAR_STATUS);	/* Settling time delay -- needed!  */
+	return low_nib | ((inbyte(ioaddr + PAR_STATUS) << 1) & 0xf0);
 }
 
 /* Read a byte through the data register. */
 static inline unsigned char read_byte_mode4(short ioaddr)
 {
-    unsigned char low_nib;
+	unsigned char low_nib;
 
-    outb(RdAddr | MAR, ioaddr + PAR_DATA);
-    low_nib = (inbyte(ioaddr + PAR_STATUS) >> 3) & 0x0f;
-    outb(RdAddr | HNib | MAR, ioaddr + PAR_DATA);
-    return low_nib | ((inbyte(ioaddr + PAR_STATUS) << 1) & 0xf0);
+	outb(RdAddr | MAR, ioaddr + PAR_DATA);
+	low_nib = (inbyte(ioaddr + PAR_STATUS) >> 3) & 0x0f;
+	outb(RdAddr | HNib | MAR, ioaddr + PAR_DATA);
+	return low_nib | ((inbyte(ioaddr + PAR_STATUS) << 1) & 0xf0);
 }
 
 /* Read a byte through the data register, double reading to allow settling. */
 static inline unsigned char read_byte_mode6(short ioaddr)
 {
-    unsigned char low_nib;
-
-    outb(RdAddr | MAR, ioaddr + PAR_DATA);
-    inbyte(ioaddr + PAR_STATUS);
-    low_nib = (inbyte(ioaddr + PAR_STATUS) >> 3) & 0x0f;
-    outb(RdAddr | HNib | MAR, ioaddr + PAR_DATA);
-    inbyte(ioaddr + PAR_STATUS);
-    return low_nib | ((inbyte(ioaddr + PAR_STATUS) << 1) & 0xf0);
+	unsigned char low_nib;
+
+	outb(RdAddr | MAR, ioaddr + PAR_DATA);
+	inbyte(ioaddr + PAR_STATUS);
+	low_nib = (inbyte(ioaddr + PAR_STATUS) >> 3) & 0x0f;
+	outb(RdAddr | HNib | MAR, ioaddr + PAR_DATA);
+	inbyte(ioaddr + PAR_STATUS);
+	return low_nib | ((inbyte(ioaddr + PAR_STATUS) << 1) & 0xf0);
 }
 
 static inline void
 write_reg(short port, unsigned char reg, unsigned char value)
 {
-    unsigned char outval;
-    outb(EOC | reg, port + PAR_DATA);
-    outval = WrAddr | reg;
-    outb(outval, port + PAR_DATA);
-    outb(outval, port + PAR_DATA);	/* Double write for PS/2. */
-
-    outval &= 0xf0;
-    outval |= value;
-    outb(outval, port + PAR_DATA);
-    outval &= 0x1f;
-    outb(outval, port + PAR_DATA);
-    outb(outval, port + PAR_DATA);
-
-    outb(EOC | outval, port + PAR_DATA);
+	unsigned char outval;
+
+	outb(EOC | reg, port + PAR_DATA);
+	outval = WrAddr | reg;
+	outb(outval, port + PAR_DATA);
+	outb(outval, port + PAR_DATA);	/* Double write for PS/2. */
+
+	outval &= 0xf0;
+	outval |= value;
+	outb(outval, port + PAR_DATA);
+	outval &= 0x1f;
+	outb(outval, port + PAR_DATA);
+	outb(outval, port + PAR_DATA);
+
+	outb(EOC | outval, port + PAR_DATA);
 }
 
 static inline void
 write_reg_high(short port, unsigned char reg, unsigned char value)
 {
-    unsigned char outval = EOC | HNib | reg;
+	unsigned char outval = EOC | HNib | reg;
 
-    outb(outval, port + PAR_DATA);
-    outval &= WrAddr | HNib | 0x0f;
-    outb(outval, port + PAR_DATA);
-    outb(outval, port + PAR_DATA);	/* Double write for PS/2. */
+	outb(outval, port + PAR_DATA);
+	outval &= WrAddr | HNib | 0x0f;
+	outb(outval, port + PAR_DATA);
+	outb(outval, port + PAR_DATA);	/* Double write for PS/2. */
 
-    outval = WrAddr | HNib | value;
-    outb(outval, port + PAR_DATA);
-    outval &= HNib | 0x0f;		/* HNib | value */
-    outb(outval, port + PAR_DATA);
-    outb(outval, port + PAR_DATA);
+	outval = WrAddr | HNib | value;
+	outb(outval, port + PAR_DATA);
+	outval &= HNib | 0x0f;		/* HNib | value */
+	outb(outval, port + PAR_DATA);
+	outb(outval, port + PAR_DATA);
 
-    outb(EOC | HNib | outval, port + PAR_DATA);
+	outb(EOC | HNib | outval, port + PAR_DATA);
 }
 
 /* Write a byte out using nibble mode.  The low nibble is written first. */
 static inline void
 write_reg_byte(short port, unsigned char reg, unsigned char value)
 {
-    unsigned char outval;
-    outb(EOC | reg, port + PAR_DATA); 	/* Reset the address register. */
-    outval = WrAddr | reg;
-    outb(outval, port + PAR_DATA);
-    outb(outval, port + PAR_DATA);	/* Double write for PS/2. */
-
-    outb((outval & 0xf0) | (value & 0x0f), port + PAR_DATA);
-    outb(value & 0x0f, port + PAR_DATA);
-    value >>= 4;
-    outb(value, port + PAR_DATA);
-    outb(0x10 | value, port + PAR_DATA);
-    outb(0x10 | value, port + PAR_DATA);
-
-    outb(EOC  | value, port + PAR_DATA); 	/* Reset the address register. */
+	unsigned char outval;
+
+	outb(EOC | reg, port + PAR_DATA); /* Reset the address register. */
+	outval = WrAddr | reg;
+	outb(outval, port + PAR_DATA);
+	outb(outval, port + PAR_DATA);	/* Double write for PS/2. */
+
+	outb((outval & 0xf0) | (value & 0x0f), port + PAR_DATA);
+	outb(value & 0x0f, port + PAR_DATA);
+	value >>= 4;
+	outb(value, port + PAR_DATA);
+	outb(0x10 | value, port + PAR_DATA);
+	outb(0x10 | value, port + PAR_DATA);
+
+	outb(EOC  | value, port + PAR_DATA); /* Reset the address register. */
 }
 
-/*
- * Bulk data writes to the packet buffer.  The interrupt line remains enabled.
+/* Bulk data writes to the packet buffer.  The interrupt line remains enabled.
  * The first, faster method uses only the dataport (data modes 0, 2 & 4).
  * The second (backup) method uses data and control regs (modes 1, 3 & 5).
  * It should only be needed when there is skew between the individual data
@@ -214,28 +222,28 @@ write_reg_byte(short port, unsigned char reg, unsigned char value)
  */
 static inline void write_byte_mode0(short ioaddr, unsigned char value)
 {
-    outb(value & 0x0f, ioaddr + PAR_DATA);
-    outb((value>>4) | 0x10, ioaddr + PAR_DATA);
+	outb(value & 0x0f, ioaddr + PAR_DATA);
+	outb((value>>4) | 0x10, ioaddr + PAR_DATA);
 }
 
 static inline void write_byte_mode1(short ioaddr, unsigned char value)
 {
-    outb(value & 0x0f, ioaddr + PAR_DATA);
-    outb(Ctrl_IRQEN | Ctrl_LNibWrite, ioaddr + PAR_CONTROL);
-    outb((value>>4) | 0x10, ioaddr + PAR_DATA);
-    outb(Ctrl_IRQEN | Ctrl_HNibWrite, ioaddr + PAR_CONTROL);
+	outb(value & 0x0f, ioaddr + PAR_DATA);
+	outb(Ctrl_IRQEN | Ctrl_LNibWrite, ioaddr + PAR_CONTROL);
+	outb((value>>4) | 0x10, ioaddr + PAR_DATA);
+	outb(Ctrl_IRQEN | Ctrl_HNibWrite, ioaddr + PAR_CONTROL);
 }
 
 /* Write 16bit VALUE to the packet buffer: the same as above just doubled. */
 static inline void write_word_mode0(short ioaddr, unsigned short value)
 {
-    outb(value & 0x0f, ioaddr + PAR_DATA);
-    value >>= 4;
-    outb((value & 0x0f) | 0x10, ioaddr + PAR_DATA);
-    value >>= 4;
-    outb(value & 0x0f, ioaddr + PAR_DATA);
-    value >>= 4;
-    outb((value & 0x0f) | 0x10, ioaddr + PAR_DATA);
+	outb(value & 0x0f, ioaddr + PAR_DATA);
+	value >>= 4;
+	outb((value & 0x0f) | 0x10, ioaddr + PAR_DATA);
+	value >>= 4;
+	outb(value & 0x0f, ioaddr + PAR_DATA);
+	value >>= 4;
+	outb((value & 0x0f) | 0x10, ioaddr + PAR_DATA);
 }
 
 /*  EEPROM_Ctrl bits. */
@@ -248,10 +256,10 @@ static inline void write_word_mode0(short ioaddr, unsigned short value)
 
 /* Delay between EEPROM clock transitions. */
 #define eeprom_delay(ticks) \
-do { int _i = 40; while (--_i > 0) { __SLOW_DOWN_IO; }} while (0)
+do { int _i = 40; while (--_i > 0) { __SLOW_DOWN_IO; } } while (0)
 
 /* The EEPROM commands include the alway-set leading bit. */
 #define EE_WRITE_CMD(offset)	(((5 << 6) + (offset)) << 17)
-#define EE_READ(offset) 	(((6 << 6) + (offset)) << 17)
+#define EE_READ(offset)		(((6 << 6) + (offset)) << 17)
 #define EE_ERASE(offset)	(((7 << 6) + (offset)) << 17)
 #define EE_CMD_SIZE	27	/* The command+address+data size. */
-- 
2.1.2
