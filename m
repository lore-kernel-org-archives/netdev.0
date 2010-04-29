From: Ben Dooks <ben@simtec.co.uk>
Subject: [patch 12/13] KS8851: Use the ks8851.h header to hold union ks8851_tx_hdr
Date: Fri, 30 Apr 2010 00:16:33 +0100
Message-ID: <20100429231740.843226825@fluff.org.uk>
References: <20100429231621.015936077@fluff.org.uk>
Cc: tristram.ha@micrel.com, support@tincantools.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aeryn.fluff.org.uk ([87.194.8.8]:27351 "EHLO
	kira.home.fluff.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932839Ab0D3Vsk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Apr 2010 17:48:40 -0400
Content-Disposition: inline; filename=ks8851-reduce-header-duplication3.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The union ks8851_tx_hdr turns up in both ks8851.c and ks8851_mll.c in two
different formats, thus making a common version in ks8851.h is going to
save source file usage.

The ks8851_mll.c uses the name ks_tx_hdr instead of ks8851_tx_hdr, so
rename this instance.

Signed-off-by: Ben Dooks <ben@simtec.co.uk>

---

---
 drivers/net/ks8851.c     |   13 -------------
 drivers/net/ks8851.h     |   14 ++++++++++++++
 drivers/net/ks8851_mll.c |   16 +---------------
 3 files changed, 15 insertions(+), 28 deletions(-)

Index: b/drivers/net/ks8851.c
===================================================================
--- a/drivers/net/ks8851.c	2010-04-29 01:25:54.217027162 +0900
+++ b/drivers/net/ks8851.c	2010-04-29 01:28:32.719525804 +0900
@@ -46,19 +46,6 @@ struct ks8851_rxctrl {
 	u16	rxcr2;
 };
 
-/**
- * union ks8851_tx_hdr - tx header data
- * @txb: The header as bytes
- * @txw: The header as 16bit, little-endian words
- *
- * A dual representation of the tx header data to allow
- * access to individual bytes, and to allow 16bit accesses
- * with 16bit alignment.
- */
-union ks8851_tx_hdr {
-	u8	txb[6];
-	__le16	txw[3];
-};
 
 /**
  * struct ks8851_net - KS8851 driver private data
Index: b/drivers/net/ks8851.h
===================================================================
--- a/drivers/net/ks8851.h	2010-04-29 01:26:03.329527219 +0900
+++ b/drivers/net/ks8851.h	2010-04-29 01:26:04.169526711 +0900
@@ -323,3 +323,17 @@
 #define KS_SPIOP_WR				(0x40)
 #define KS_SPIOP_RXFIFO				(0x80)
 #define KS_SPIOP_TXFIFO				(0xC0)
+
+/**
+ * union ks8851_tx_hdr - tx header data
+ * @txb: The header as bytes
+ * @txw: The header as 16bit, little-endian words
+ *
+ * A dual representation of the tx header data to allow
+ * access to individual bytes, and to allow 16bit accesses
+ * with 16bit alignment.
+ */
+union ks8851_tx_hdr {
+	u8	txb[6];
+	__le16	txw[3];
+};
Index: b/drivers/net/ks8851_mll.c
===================================================================
--- a/drivers/net/ks8851_mll.c	2010-04-29 01:26:03.329527219 +0900
+++ b/drivers/net/ks8851_mll.c	2010-04-29 01:26:04.169526711 +0900
@@ -73,20 +73,6 @@ static u8 KS_DEFAULT_MAC_ADDRESS[] = { 0
 #define MAC_ADDR_LEN			6
 
 /**
- * union ks_tx_hdr - tx header data
- * @txb: The header as bytes
- * @txw: The header as 16bit, little-endian words
- *
- * A dual representation of the tx header data to allow
- * access to individual bytes, and to allow 16bit accesses
- * with 16bit alignment.
- */
-union ks_tx_hdr {
-	u8      txb[4];
-	__le16  txw[2];
-};
-
-/**
  * struct ks_net - KS8851 driver private data
  * @net_device 	: The network device we're bound to
  * @hw_addr	: start address of data register.
@@ -138,7 +124,7 @@ struct ks_net {
 	struct net_device	*netdev;
 	void __iomem    	*hw_addr;
 	void __iomem    	*hw_addr_cmd;
-	union ks_tx_hdr		txh ____cacheline_aligned;
+	union ks8851_tx_hdr	txh ____cacheline_aligned;
 	struct mutex      	lock; /* spinlock to be interrupt safe */
 	struct platform_device *pdev;
 	struct mii_if_info	mii;

