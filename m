From: <gerg@snapgear.com>
Subject: [PATCH v2 1/2] m68knommu: move the badly named mcfne.h to a better mcf8390.h
Date: Thu, 5 Jul 2012 09:49:59 +1000
Message-ID: <1341445800-396-2-git-send-email-gerg@snapgear.com>
References: <1341445800-396-1-git-send-email-gerg@snapgear.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Greg Ungerer <gerg@uclinux.org>
To: <netdev@vger.kernel.org>, <linux-m68k@vger.kernel.org>
Return-path: <linux-m68k-owner@vger.kernel.org>
In-Reply-To: <1341445800-396-1-git-send-email-gerg@snapgear.com>
Sender: linux-m68k-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Greg Ungerer <gerg@uclinux.org>

The mcfne.h include contains definitions to support NS8390 eth based hardware
on ColdFire based CPU boards. So change its name to reflect that better.

Signed-off-by: Greg Ungerer <gerg@uclinux.org>
---
 arch/m68k/include/asm/mcf8390.h |  242 +++++++++++++++++++++++++++++++++++++++
 arch/m68k/include/asm/mcfne.h   |  242 ---------------------------------------
 2 files changed, 242 insertions(+), 242 deletions(-)
 create mode 100644 arch/m68k/include/asm/mcf8390.h
 delete mode 100644 arch/m68k/include/asm/mcfne.h

diff --git a/arch/m68k/include/asm/mcf8390.h b/arch/m68k/include/asm/mcf8390.h
new file mode 100644
index 0000000..bf3d97b
--- /dev/null
+++ b/arch/m68k/include/asm/mcf8390.h
@@ -0,0 +1,242 @@
+/****************************************************************************/
+
+/*
+ *	mcf8390.h -- NS8390 support for ColdFire eval boards.
+ *
+ *	(C) Copyright 1999-2000, Greg Ungerer (gerg@snapgear.com)
+ *	(C) Copyright 2000,      Lineo (www.lineo.com)
+ *	(C) Copyright 2001,      SnapGear (www.snapgear.com)
+ *
+ *      19990409 David W. Miller  Converted from m5206ne.h for 5307 eval board
+ *
+ *      Hacked support for m5206e Cadre III evaluation board
+ *      Fred Stevens (fred.stevens@pemstar.com) 13 April 1999
+ */
+
+/****************************************************************************/
+#ifndef	mcf8390_h
+#define	mcf8390_h
+/****************************************************************************/
+
+
+/*
+ *	Support for NE2000 clones devices in ColdFire based boards.
+ *	Not all boards address these parts the same way, some use a
+ *	direct addressing method, others use a side-band address space
+ *	to access odd address registers, some require byte swapping
+ *	others do not.
+ */
+#define	BSWAP(w)	(((w) << 8) | ((w) >> 8))
+#define	RSWAP(w)	(w)
+
+
+/*
+ *	Define the basic hardware resources of NE2000 boards.
+ */
+
+#if defined(CONFIG_ARN5206)
+#define NE2000_ADDR		0x40000300
+#define NE2000_ODDOFFSET	0x00010000
+#define	NE2000_IRQ_VECTOR	0xf0
+#define	NE2000_IRQ_PRIORITY	2
+#define	NE2000_IRQ_LEVEL	4
+#define	NE2000_BYTE		volatile unsigned short
+#endif
+
+#if defined(CONFIG_M5206eC3)
+#define	NE2000_ADDR		0x40000300
+#define	NE2000_ODDOFFSET	0x00010000
+#define	NE2000_IRQ_VECTOR	0x1c
+#define	NE2000_IRQ_PRIORITY	2
+#define	NE2000_IRQ_LEVEL	4
+#define	NE2000_BYTE		volatile unsigned short
+#endif
+
+#if defined(CONFIG_M5206e) && defined(CONFIG_NETtel)
+#define NE2000_ADDR		0x30000300
+#define NE2000_IRQ_VECTOR	25
+#define NE2000_IRQ_PRIORITY	1
+#define NE2000_IRQ_LEVEL	3
+#define	NE2000_BYTE		volatile unsigned char
+#endif
+
+#if defined(CONFIG_M5307C3)
+#define NE2000_ADDR		0x40000300
+#define NE2000_ODDOFFSET	0x00010000
+#define NE2000_IRQ_VECTOR	0x1b
+#define	NE2000_BYTE		volatile unsigned short
+#endif
+
+#if defined(CONFIG_M5272) && defined(CONFIG_NETtel)
+#define NE2000_ADDR		0x30600300
+#define NE2000_ODDOFFSET	0x00008000
+#define NE2000_IRQ_VECTOR	67
+#undef	BSWAP
+#define	BSWAP(w)		(w)
+#define	NE2000_BYTE		volatile unsigned short
+#undef	RSWAP
+#define	RSWAP(w)		(((w) << 8) | ((w) >> 8))
+#endif
+
+#if defined(CONFIG_M5307) && defined(CONFIG_NETtel)
+#define NE2000_ADDR0		0x30600300
+#define NE2000_ADDR1		0x30800300
+#define NE2000_ODDOFFSET	0x00008000
+#define NE2000_IRQ_VECTOR0	27
+#define NE2000_IRQ_VECTOR1	29
+#undef	BSWAP
+#define	BSWAP(w)		(w)
+#define	NE2000_BYTE		volatile unsigned short
+#undef	RSWAP
+#define	RSWAP(w)		(((w) << 8) | ((w) >> 8))
+#endif
+
+#if defined(CONFIG_M5307) && defined(CONFIG_SECUREEDGEMP3)
+#define NE2000_ADDR		0x30600300
+#define NE2000_ODDOFFSET	0x00008000
+#define NE2000_IRQ_VECTOR	27
+#undef	BSWAP
+#define	BSWAP(w)		(w)
+#define	NE2000_BYTE		volatile unsigned short
+#undef	RSWAP
+#define	RSWAP(w)		(((w) << 8) | ((w) >> 8))
+#endif
+
+#if defined(CONFIG_ARN5307)
+#define NE2000_ADDR		0xfe600300
+#define NE2000_ODDOFFSET	0x00010000
+#define NE2000_IRQ_VECTOR	0x1b
+#define NE2000_IRQ_PRIORITY	2
+#define NE2000_IRQ_LEVEL	3
+#define	NE2000_BYTE		volatile unsigned short
+#endif
+
+#if defined(CONFIG_M5407C3)
+#define NE2000_ADDR		0x40000300
+#define NE2000_ODDOFFSET	0x00010000
+#define NE2000_IRQ_VECTOR	0x1b
+#define	NE2000_BYTE		volatile unsigned short
+#endif
+
+/****************************************************************************/
+
+/*
+ *	Side-band address space for odd address requires re-mapping
+ *	many of the standard ISA access functions.
+ */
+#ifdef NE2000_ODDOFFSET
+
+#undef outb
+#undef outb_p
+#undef inb
+#undef inb_p
+#undef outsb
+#undef outsw
+#undef insb
+#undef insw
+
+#define	outb	ne2000_outb
+#define	inb	ne2000_inb
+#define	outb_p	ne2000_outb
+#define	inb_p	ne2000_inb
+#define	outsb	ne2000_outsb
+#define	outsw	ne2000_outsw
+#define	insb	ne2000_insb
+#define	insw	ne2000_insw
+
+
+#ifndef COLDFIRE_NE2000_FUNCS
+
+void ne2000_outb(unsigned int val, unsigned int addr);
+int  ne2000_inb(unsigned int addr);
+void ne2000_insb(unsigned int addr, void *vbuf, int unsigned long len);
+void ne2000_insw(unsigned int addr, void *vbuf, unsigned long len);
+void ne2000_outsb(unsigned int addr, void *vbuf, unsigned long len);
+void ne2000_outsw(unsigned int addr, void *vbuf, unsigned long len);
+
+#else
+
+/*
+ *	This macro converts a conventional register address into the
+ *	real memory pointer of the mapped NE2000 device.
+ *	On most NE2000 implementations on ColdFire boards the chip is
+ *	mapped in kinda funny, due to its ISA heritage.
+ */
+#define	NE2000_PTR(addr)	((addr&0x1)?(NE2000_ODDOFFSET+addr-1):(addr))
+#define	NE2000_DATA_PTR(addr)	(addr)
+
+
+void ne2000_outb(unsigned int val, unsigned int addr)
+{
+	NE2000_BYTE	*rp;
+
+	rp = (NE2000_BYTE *) NE2000_PTR(addr);
+	*rp = RSWAP(val);
+}
+
+int ne2000_inb(unsigned int addr)
+{
+	NE2000_BYTE	*rp, val;
+
+	rp = (NE2000_BYTE *) NE2000_PTR(addr);
+	val = *rp;
+	return((int) ((NE2000_BYTE) RSWAP(val)));
+}
+
+void ne2000_insb(unsigned int addr, void *vbuf, int unsigned long len)
+{
+	NE2000_BYTE	*rp, val;
+	unsigned char	*buf;
+
+	buf = (unsigned char *) vbuf;
+	rp = (NE2000_BYTE *) NE2000_DATA_PTR(addr);
+	for (; (len > 0); len--) {
+		val = *rp;
+		*buf++ = RSWAP(val);
+	}
+}
+
+void ne2000_insw(unsigned int addr, void *vbuf, unsigned long len)
+{
+	volatile unsigned short	*rp;
+	unsigned short		w, *buf;
+
+	buf = (unsigned short *) vbuf;
+	rp = (volatile unsigned short *) NE2000_DATA_PTR(addr);
+	for (; (len > 0); len--) {
+		w = *rp;
+		*buf++ = BSWAP(w);
+	}
+}
+
+void ne2000_outsb(unsigned int addr, const void *vbuf, unsigned long len)
+{
+	NE2000_BYTE	*rp, val;
+	unsigned char	*buf;
+
+	buf = (unsigned char *) vbuf;
+	rp = (NE2000_BYTE *) NE2000_DATA_PTR(addr);
+	for (; (len > 0); len--) {
+		val = *buf++;
+		*rp = RSWAP(val);
+	}
+}
+
+void ne2000_outsw(unsigned int addr, const void *vbuf, unsigned long len)
+{
+	volatile unsigned short	*rp;
+	unsigned short		w, *buf;
+
+	buf = (unsigned short *) vbuf;
+	rp = (volatile unsigned short *) NE2000_DATA_PTR(addr);
+	for (; (len > 0); len--) {
+		w = *buf++;
+		*rp = BSWAP(w);
+	}
+}
+
+#endif /* COLDFIRE_NE2000_FUNCS */
+#endif /* NE2000_OFFOFFSET */
+
+/****************************************************************************/
+#endif	/* mcf8390_h */
diff --git a/arch/m68k/include/asm/mcfne.h b/arch/m68k/include/asm/mcfne.h
deleted file mode 100644
index bf638be..0000000
--- a/arch/m68k/include/asm/mcfne.h
+++ /dev/null
@@ -1,242 +0,0 @@
-/****************************************************************************/
-
-/*
- *	mcfne.h -- NE2000 in ColdFire eval boards.
- *
- *	(C) Copyright 1999-2000, Greg Ungerer (gerg@snapgear.com)
- *	(C) Copyright 2000,      Lineo (www.lineo.com)
- *	(C) Copyright 2001,      SnapGear (www.snapgear.com)
- *
- *      19990409 David W. Miller  Converted from m5206ne.h for 5307 eval board
- *
- *      Hacked support for m5206e Cadre III evaluation board
- *      Fred Stevens (fred.stevens@pemstar.com) 13 April 1999
- */
-
-/****************************************************************************/
-#ifndef	mcfne_h
-#define	mcfne_h
-/****************************************************************************/
-
-
-/*
- *	Support for NE2000 clones devices in ColdFire based boards.
- *	Not all boards address these parts the same way, some use a
- *	direct addressing method, others use a side-band address space
- *	to access odd address registers, some require byte swapping
- *	others do not.
- */
-#define	BSWAP(w)	(((w) << 8) | ((w) >> 8))
-#define	RSWAP(w)	(w)
-
-
-/*
- *	Define the basic hardware resources of NE2000 boards.
- */
-
-#if defined(CONFIG_ARN5206)
-#define NE2000_ADDR		0x40000300
-#define NE2000_ODDOFFSET	0x00010000
-#define	NE2000_IRQ_VECTOR	0xf0
-#define	NE2000_IRQ_PRIORITY	2
-#define	NE2000_IRQ_LEVEL	4
-#define	NE2000_BYTE		volatile unsigned short
-#endif
-
-#if defined(CONFIG_M5206eC3)
-#define	NE2000_ADDR		0x40000300
-#define	NE2000_ODDOFFSET	0x00010000
-#define	NE2000_IRQ_VECTOR	0x1c
-#define	NE2000_IRQ_PRIORITY	2
-#define	NE2000_IRQ_LEVEL	4
-#define	NE2000_BYTE		volatile unsigned short
-#endif
-
-#if defined(CONFIG_M5206e) && defined(CONFIG_NETtel)
-#define NE2000_ADDR		0x30000300
-#define NE2000_IRQ_VECTOR	25
-#define NE2000_IRQ_PRIORITY	1
-#define NE2000_IRQ_LEVEL	3
-#define	NE2000_BYTE		volatile unsigned char
-#endif
-
-#if defined(CONFIG_M5307C3)
-#define NE2000_ADDR		0x40000300
-#define NE2000_ODDOFFSET	0x00010000
-#define NE2000_IRQ_VECTOR	0x1b
-#define	NE2000_BYTE		volatile unsigned short
-#endif
-
-#if defined(CONFIG_M5272) && defined(CONFIG_NETtel)
-#define NE2000_ADDR		0x30600300
-#define NE2000_ODDOFFSET	0x00008000
-#define NE2000_IRQ_VECTOR	67
-#undef	BSWAP
-#define	BSWAP(w)		(w)
-#define	NE2000_BYTE		volatile unsigned short
-#undef	RSWAP
-#define	RSWAP(w)		(((w) << 8) | ((w) >> 8))
-#endif
-
-#if defined(CONFIG_M5307) && defined(CONFIG_NETtel)
-#define NE2000_ADDR0		0x30600300
-#define NE2000_ADDR1		0x30800300
-#define NE2000_ODDOFFSET	0x00008000
-#define NE2000_IRQ_VECTOR0	27
-#define NE2000_IRQ_VECTOR1	29
-#undef	BSWAP
-#define	BSWAP(w)		(w)
-#define	NE2000_BYTE		volatile unsigned short
-#undef	RSWAP
-#define	RSWAP(w)		(((w) << 8) | ((w) >> 8))
-#endif
-
-#if defined(CONFIG_M5307) && defined(CONFIG_SECUREEDGEMP3)
-#define NE2000_ADDR		0x30600300
-#define NE2000_ODDOFFSET	0x00008000
-#define NE2000_IRQ_VECTOR	27
-#undef	BSWAP
-#define	BSWAP(w)		(w)
-#define	NE2000_BYTE		volatile unsigned short
-#undef	RSWAP
-#define	RSWAP(w)		(((w) << 8) | ((w) >> 8))
-#endif
-
-#if defined(CONFIG_ARN5307)
-#define NE2000_ADDR		0xfe600300
-#define NE2000_ODDOFFSET	0x00010000
-#define NE2000_IRQ_VECTOR	0x1b
-#define NE2000_IRQ_PRIORITY	2
-#define NE2000_IRQ_LEVEL	3
-#define	NE2000_BYTE		volatile unsigned short
-#endif
-
-#if defined(CONFIG_M5407C3)
-#define NE2000_ADDR		0x40000300
-#define NE2000_ODDOFFSET	0x00010000
-#define NE2000_IRQ_VECTOR	0x1b
-#define	NE2000_BYTE		volatile unsigned short
-#endif
-
-/****************************************************************************/
-
-/*
- *	Side-band address space for odd address requires re-mapping
- *	many of the standard ISA access functions.
- */
-#ifdef NE2000_ODDOFFSET
-
-#undef outb
-#undef outb_p
-#undef inb
-#undef inb_p
-#undef outsb
-#undef outsw
-#undef insb
-#undef insw
-
-#define	outb	ne2000_outb
-#define	inb	ne2000_inb
-#define	outb_p	ne2000_outb
-#define	inb_p	ne2000_inb
-#define	outsb	ne2000_outsb
-#define	outsw	ne2000_outsw
-#define	insb	ne2000_insb
-#define	insw	ne2000_insw
-
-
-#ifndef COLDFIRE_NE2000_FUNCS
-
-void ne2000_outb(unsigned int val, unsigned int addr);
-int  ne2000_inb(unsigned int addr);
-void ne2000_insb(unsigned int addr, void *vbuf, int unsigned long len);
-void ne2000_insw(unsigned int addr, void *vbuf, unsigned long len);
-void ne2000_outsb(unsigned int addr, void *vbuf, unsigned long len);
-void ne2000_outsw(unsigned int addr, void *vbuf, unsigned long len);
-
-#else
-
-/*
- *	This macro converts a conventional register address into the
- *	real memory pointer of the mapped NE2000 device.
- *	On most NE2000 implementations on ColdFire boards the chip is
- *	mapped in kinda funny, due to its ISA heritage.
- */
-#define	NE2000_PTR(addr)	((addr&0x1)?(NE2000_ODDOFFSET+addr-1):(addr))
-#define	NE2000_DATA_PTR(addr)	(addr)
-
-
-void ne2000_outb(unsigned int val, unsigned int addr)
-{
-	NE2000_BYTE	*rp;
-
-	rp = (NE2000_BYTE *) NE2000_PTR(addr);
-	*rp = RSWAP(val);
-}
-
-int ne2000_inb(unsigned int addr)
-{
-	NE2000_BYTE	*rp, val;
-
-	rp = (NE2000_BYTE *) NE2000_PTR(addr);
-	val = *rp;
-	return((int) ((NE2000_BYTE) RSWAP(val)));
-}
-
-void ne2000_insb(unsigned int addr, void *vbuf, int unsigned long len)
-{
-	NE2000_BYTE	*rp, val;
-	unsigned char	*buf;
-
-	buf = (unsigned char *) vbuf;
-	rp = (NE2000_BYTE *) NE2000_DATA_PTR(addr);
-	for (; (len > 0); len--) {
-		val = *rp;
-		*buf++ = RSWAP(val);
-	}
-}
-
-void ne2000_insw(unsigned int addr, void *vbuf, unsigned long len)
-{
-	volatile unsigned short	*rp;
-	unsigned short		w, *buf;
-
-	buf = (unsigned short *) vbuf;
-	rp = (volatile unsigned short *) NE2000_DATA_PTR(addr);
-	for (; (len > 0); len--) {
-		w = *rp;
-		*buf++ = BSWAP(w);
-	}
-}
-
-void ne2000_outsb(unsigned int addr, const void *vbuf, unsigned long len)
-{
-	NE2000_BYTE	*rp, val;
-	unsigned char	*buf;
-
-	buf = (unsigned char *) vbuf;
-	rp = (NE2000_BYTE *) NE2000_DATA_PTR(addr);
-	for (; (len > 0); len--) {
-		val = *buf++;
-		*rp = RSWAP(val);
-	}
-}
-
-void ne2000_outsw(unsigned int addr, const void *vbuf, unsigned long len)
-{
-	volatile unsigned short	*rp;
-	unsigned short		w, *buf;
-
-	buf = (unsigned short *) vbuf;
-	rp = (volatile unsigned short *) NE2000_DATA_PTR(addr);
-	for (; (len > 0); len--) {
-		w = *buf++;
-		*rp = BSWAP(w);
-	}
-}
-
-#endif /* COLDFIRE_NE2000_FUNCS */
-#endif /* NE2000_OFFOFFSET */
-
-/****************************************************************************/
-#endif	/* mcfne_h */
-- 
1.7.0.4
