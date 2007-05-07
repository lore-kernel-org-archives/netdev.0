From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: [PATCH 2/3] ARM: include IXP4xx "fuses" support
Date: Mon, 07 May 2007 02:07:05 +0200
Message-ID: <m3wszlbiom.fsf@maximus.localdomain>
References: <m3abwhcy74.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Russell King <rmk@arm.linux.org.uk>,
	lkml <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.arm.linux.org.uk
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:43808 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752784AbXEGAHH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 6 May 2007 20:07:07 -0400
In-Reply-To: <m3abwhcy74.fsf@maximus.localdomain> (Krzysztof Halasa's message of "Mon, 07 May 2007 01:46:39 +0200")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adds "fuse" functions to help determine installed IXP4xx CPU
components and to reset/disable/enable them (only NPE - network
coprocessors - can be reset and reenabled).

Signed-off-by: Krzysztof Halasa <khc@pm.waw.pl>

diff --git a/include/asm-arm/arch-ixp4xx/ixp4xx-regs.h b/include/asm-arm/arch-ixp4xx/ixp4xx-regs.h
index 5d949d7..780c851 100644
--- a/include/asm-arm/arch-ixp4xx/ixp4xx-regs.h
+++ b/include/asm-arm/arch-ixp4xx/ixp4xx-regs.h
@@ -607,4 +607,51 @@
 
 #define DCMD_LENGTH	0x01fff		/* length mask (max = 8K - 1) */
 
+/* Fuse Bits of IXP_EXP_CFG2 */
+#define IXP4XX_FUSE_RCOMP		(1 << 0)
+#define IXP4XX_FUSE_USB_DEVICE		(1 << 1)
+#define IXP4XX_FUSE_HASH		(1 << 2)
+#define IXP4XX_FUSE_AES			(1 << 3)
+#define IXP4XX_FUSE_DES			(1 << 4)
+#define IXP4XX_FUSE_HDLC		(1 << 5)
+#define IXP4XX_FUSE_AAL			(1 << 6)
+#define IXP4XX_FUSE_HSS			(1 << 7)
+#define IXP4XX_FUSE_UTOPIA		(1 << 8)
+#define IXP4XX_FUSE_NPEB_ETH0		(1 << 9)
+#define IXP4XX_FUSE_NPEC_ETH		(1 << 10)
+#define IXP4XX_FUSE_RESET_NPEA		(1 << 11)
+#define IXP4XX_FUSE_RESET_NPEB		(1 << 12)
+#define IXP4XX_FUSE_RESET_NPEC		(1 << 13)
+#define IXP4XX_FUSE_PCI			(1 << 14)
+#define IXP4XX_FUSE_ECC_TIMESYNC	(1 << 15)
+#define IXP4XX_FUSE_UTOPIA_PHY_LIMIT	(3 << 16)
+#define IXP4XX_FUSE_USB_HOST		(1 << 18)
+#define IXP4XX_FUSE_NPEA_ETH		(1 << 19)
+#define IXP4XX_FUSE_NPEB_ETH_1_TO_3	(1 << 20)
+#define IXP4XX_FUSE_RSA			(1 << 21)
+#define IXP4XX_FUSE_XSCALE_MAX_FREQ	(3 << 22)
+#define IXP4XX_FUSE_RESERVED		(0xFF << 24)
+
+#define IXP4XX_FUSE_IXP46X_ONLY (IXP4XX_FUSE_ECC_TIMESYNC |		\
+				 IXP4XX_FUSE_USB_HOST |			\
+				 IXP4XX_FUSE_NPEA_ETH |			\
+				 IXP4XX_FUSE_NPEB_ETH_1_TO_3 |		\
+				 IXP4XX_FUSE_RSA |			\
+				 IXP4XX_FUSE_XSCALE_MAX_FREQ)
+
+static inline u32 ixp4xx_read_fuses(void)
+{
+	unsigned int fuses = ~*IXP4XX_EXP_CFG2;
+	fuses &= ~IXP4XX_FUSE_RESERVED;
+	if (!cpu_is_ixp46x())
+		fuses &= ~IXP4XX_FUSE_IXP46X_ONLY;
+
+	return fuses;
+}
+
+static inline void ixp4xx_write_fuses(u32 value)
+{
+	*IXP4XX_EXP_CFG2 = ~value;
+}
+
 #endif
