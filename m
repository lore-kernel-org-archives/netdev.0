From: ben@fluff.org.uk
Subject: [patch 8/9] KS8851: Use the ks8851.h header to hold union ks8851_tx_hdr
Date: Mon, 07 Dec 2009 12:15:09 +0000
Message-ID: <20091207121647.349234115@fluff.org.uk>
References: <20091207121501.819539008@fluff.org.uk>
Cc: linux@simtec.co.uk, doong.ping@micrel.com, tristram.ha@micrel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aeryn.fluff.org.uk ([87.194.8.8]:48503 "EHLO
	kira.home.fluff.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S933563AbZLGMQl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Dec 2009 07:16:41 -0500
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

Index: b/drivers/net/ks8851.c
===================================================================
--- a/drivers/net/ks8851.c	2009-12-07 11:24:54.000000000 +0000
+++ b/drivers/net/ks8851.c	2009-12-07 11:29:02.000000000 +0000
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
--- a/drivers/net/ks8851.h	2009-12-07 11:26:50.000000000 +0000
+++ b/drivers/net/ks8851.h	2009-12-07 11:28:31.000000000 +0000
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
--- a/drivers/net/ks8851_mll.c	2009-12-07 11:24:46.000000000 +0000
+++ b/drivers/net/ks8851_mll.c	2009-12-07 11:28:49.000000000 +0000
@@ -72,20 +72,6 @@ static u8 KS_DEFAULT_MAC_ADDRESS[] = { 0
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
@@ -137,7 +123,7 @@ struct ks_net {
 	struct net_device	*netdev;
 	void __iomem    	*hw_addr;
 	void __iomem    	*hw_addr_cmd;
-	union ks_tx_hdr		txh ____cacheline_aligned;
+	union ks8851_tx_hdr	txh ____cacheline_aligned;
 	struct mutex      	lock; /* spinlock to be interrupt safe */
 	struct platform_device *pdev;
 	struct mii_if_info	mii;

