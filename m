From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 4/5] tg3: tg3.h cleanups
Date: Thu, 18 Dec 2008 16:55:29 -0800
Message-ID: <1229717361.5505@xw6200>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Michael Chan" <mchan@broadcom.com>,
	andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1850 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751238AbYLSUJd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Dec 2008 15:09:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch cleans up the tg3 header file by removing the preprocessor
definitions for standard PCI configuration space registers.  The driver
should be using the standard definitions when needed.  The patch
continues by removing redundant PHY related definitions and reorganizes
some of the remaining entries.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Benjamin Li <benli@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |    2 --
 drivers/net/tg3.h |   38 +++++---------------------------------
 2 files changed, 5 insertions(+), 35 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 218c11a..604215f 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -63,8 +63,6 @@
 #define TG3_VLAN_TAG_USED 0
 #endif
 
-#define TG3_TSO_SUPPORT	1
-
 #include "tg3.h"
 
 #define DRV_MODULE_NAME		"tg3"
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index 814d82b..8936edf 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -44,26 +44,7 @@
 #define  TG3PCI_DEVICE_TIGON3_57760	 0x1690
 #define  TG3PCI_DEVICE_TIGON3_57790	 0x1694
 #define  TG3PCI_DEVICE_TIGON3_57720	 0x168c
-#define TG3PCI_COMMAND			0x00000004
-#define TG3PCI_STATUS			0x00000006
-#define TG3PCI_CCREVID			0x00000008
-#define TG3PCI_CACHELINESZ		0x0000000c
-#define TG3PCI_LATTIMER			0x0000000d
-#define TG3PCI_HEADERTYPE		0x0000000e
-#define TG3PCI_BIST			0x0000000f
-#define TG3PCI_BASE0_LOW		0x00000010
-#define TG3PCI_BASE0_HIGH		0x00000014
-/* 0x18 --> 0x2c unused */
-#define TG3PCI_SUBSYSVENID		0x0000002c
-#define TG3PCI_SUBSYSID			0x0000002e
-#define TG3PCI_ROMADDR			0x00000030
-#define TG3PCI_CAPLIST			0x00000034
-/* 0x35 --> 0x3c unused */
-#define TG3PCI_IRQ_LINE			0x0000003c
-#define TG3PCI_IRQ_PIN			0x0000003d
-#define TG3PCI_MIN_GNT			0x0000003e
-#define TG3PCI_MAX_LAT			0x0000003f
-/* 0x40 --> 0x64 unused */
+/* 0x04 --> 0x64 unused */
 #define TG3PCI_MSI_DATA			0x00000064
 /* 0x66 --> 0x68 unused */
 #define TG3PCI_MISC_HOST_CTRL		0x00000068
@@ -114,10 +95,6 @@
 #define  CHIPREV_ID_5752_A1		 0x6001
 #define  CHIPREV_ID_5714_A2		 0x9002
 #define  CHIPREV_ID_5906_A1		 0xc001
-#define  CHIPREV_ID_5784_A0		 0x5784000
-#define  CHIPREV_ID_5784_A1		 0x5784001
-#define  CHIPREV_ID_5761_A0		 0x5761000
-#define  CHIPREV_ID_5761_A1		 0x5761001
 #define  GET_ASIC_REV(CHIP_REV_ID)	((CHIP_REV_ID) >> 12)
 #define   ASIC_REV_5700			 0x07
 #define   ASIC_REV_5701			 0x00
@@ -1946,12 +1923,6 @@
 #define MII_TG3_ISTAT			0x1a /* IRQ status register */
 #define MII_TG3_IMASK			0x1b /* IRQ mask register */
 
-#define MII_TG3_MISC_SHDW		0x1c
-#define MII_TG3_MISC_SHDW_WREN		0x8000
-#define MII_TG3_MISC_SHDW_APD_SEL	0x2800
-
-#define MII_TG3_MISC_SHDW_APD_WKTM_84MS	0x0001
-
 /* ISTAT/IMASK event bits */
 #define MII_TG3_INT_LINKCHG		0x0002
 #define MII_TG3_INT_SPEEDCHG		0x0004
@@ -1960,7 +1931,9 @@
 
 #define MII_TG3_MISC_SHDW		0x1c
 #define MII_TG3_MISC_SHDW_WREN		0x8000
-#define MII_TG3_MISC_SHDW_SCR5_SEL	0x1400
+
+#define MII_TG3_MISC_SHDW_APD_WKTM_84MS	0x0001
+#define MII_TG3_MISC_SHDW_APD_ENABLE	0x0020
 #define MII_TG3_MISC_SHDW_APD_SEL	0x2800
 
 #define MII_TG3_MISC_SHDW_SCR5_C125OE	0x0001
@@ -1968,9 +1941,8 @@
 #define MII_TG3_MISC_SHDW_SCR5_SDTL	0x0004
 #define MII_TG3_MISC_SHDW_SCR5_DLPTLM	0x0008
 #define MII_TG3_MISC_SHDW_SCR5_LPED	0x0010
+#define MII_TG3_MISC_SHDW_SCR5_SEL	0x1400
 
-#define MII_TG3_MISC_SHDW_APD_WKTM_84MS	0x0001
-#define MII_TG3_MISC_SHDW_APD_ENABLE	0x0020
 
 #define MII_TG3_EPHY_TEST		0x1f /* 5906 PHY register */
 #define MII_TG3_EPHY_SHADOW_EN		0x80
-- 
1.5.6.4


