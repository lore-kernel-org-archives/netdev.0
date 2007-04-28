From: olof@lixom.net (Olof Johansson)
Subject: [PATCH v3] [6/10] pasemi_mac: Minor cleanup / define fixes
Date: Sat, 28 Apr 2007 15:37:39 -0500
Message-ID: <20070428203739.GG4331@lixom.net>
References: <20070428203624.GA4331@lixom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from lixom.net ([66.141.50.11]:50938 "EHLO mail.lixom.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753915AbXD1UhD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 28 Apr 2007 16:37:03 -0400
Content-Disposition: inline
In-Reply-To: <20070428203624.GA4331@lixom.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Remove some unused defines
* Fix a couple of wrong chip register defines, and add a few more fields
  that might be used in the near future.

Signed-off-by: Olof Johansson <olof@lixom.net>

Index: netdev-2.6/drivers/net/pasemi_mac.c
===================================================================
--- netdev-2.6.orig/drivers/net/pasemi_mac.c
+++ netdev-2.6/drivers/net/pasemi_mac.c
@@ -61,12 +61,6 @@
 
 #define BUF_SIZE 1646 /* 1500 MTU + ETH_HLEN + VLAN_HLEN + 2 64B cachelines */
 
-/* XXXOJN these should come out of the device tree some day */
-#define PAS_DMA_CAP_BASE   0xe00d0040
-#define PAS_DMA_CAP_SIZE   0x100
-#define PAS_DMA_COM_BASE   0xe00d0100
-#define PAS_DMA_COM_SIZE   0x100
-
 static struct pasdma_status *dma_status;
 
 static int pasemi_get_mac_addr(struct pasemi_mac *mac)
Index: netdev-2.6/drivers/net/pasemi_mac.h
===================================================================
--- netdev-2.6.orig/drivers/net/pasemi_mac.h
+++ netdev-2.6/drivers/net/pasemi_mac.h
@@ -195,11 +195,15 @@ enum {
 #define PAS_DMA_RXINT_RCMDSTA(i)	(0x200+(i)*_PAS_DMA_RXINT_STRIDE)
 #define    PAS_DMA_RXINT_RCMDSTA_EN	0x00000001
 #define    PAS_DMA_RXINT_RCMDSTA_ST	0x00000002
-#define    PAS_DMA_RXINT_RCMDSTA_OO	0x00000100
-#define    PAS_DMA_RXINT_RCMDSTA_BP	0x00000200
-#define    PAS_DMA_RXINT_RCMDSTA_DR	0x00000400
+#define    PAS_DMA_RXINT_RCMDSTA_MBT	0x00000008
+#define    PAS_DMA_RXINT_RCMDSTA_MDR	0x00000010
+#define    PAS_DMA_RXINT_RCMDSTA_MOO	0x00000020
+#define    PAS_DMA_RXINT_RCMDSTA_MBP	0x00000040
 #define    PAS_DMA_RXINT_RCMDSTA_BT	0x00000800
-#define    PAS_DMA_RXINT_RCMDSTA_TB	0x00001000
+#define    PAS_DMA_RXINT_RCMDSTA_DR	0x00001000
+#define    PAS_DMA_RXINT_RCMDSTA_OO	0x00002000
+#define    PAS_DMA_RXINT_RCMDSTA_BP	0x00004000
+#define    PAS_DMA_RXINT_RCMDSTA_TB	0x00008000
 #define    PAS_DMA_RXINT_RCMDSTA_ACT	0x00010000
 #define    PAS_DMA_RXINT_RCMDSTA_DROPS_M	0xfffe0000
 #define    PAS_DMA_RXINT_RCMDSTA_DROPS_S	17
