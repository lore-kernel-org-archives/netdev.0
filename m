From: Adrian Bunk <bunk@kernel.org>
Subject: [2.6 patch] drivers/net/ipg.c: cleanups
Date: Wed, 24 Oct 2007 18:23:19 +0200
Message-ID: <20071024162319.GL30533@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jesse Huang <jesse@icplus.com.tw>,
	Stefan Lippers-Hollmann <s.l-h@gmx.de>,
	Francois Romieu <romieu@fr.zoreil.com>, jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout.stusta.mhn.de ([141.84.69.5]:33303 "EHLO
	mailhub.stusta.mhn.de" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756544AbXJXQWu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Oct 2007 12:22:50 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch contains the following cleanups:
- make ipg_nic_get_stats() static
- move DefaultPhyParam[] from ipg.h to ipg.c and make it static

Signed-off-by: Adrian Bunk <bunk@kernel.org>

---

 drivers/net/ipg.c |   22 +++++++++++++++++++++-
 drivers/net/ipg.h |   20 --------------------
 2 files changed, 21 insertions(+), 21 deletions(-)

a3a6ac23118e63f10ff3832dc906da6e9bc3ea3d 
diff --git a/drivers/net/ipg.c b/drivers/net/ipg.c
index 6888723..dbd23bb 100644
--- a/drivers/net/ipg.c
+++ b/drivers/net/ipg.c
@@ -55,6 +55,26 @@ MODULE_DESCRIPTION("IC Plus IP1000 Gigabit Ethernet Adapter Linux Driver "
 		   DrvVer);
 MODULE_LICENSE("GPL");
 
+//variable record -- index by leading revision/length
+//Revision/Length(=N*4), Address1, Data1, Address2, Data2,...,AddressN,DataN
+static unsigned short DefaultPhyParam[] = {
+	// 11/12/03 IP1000A v1-3 rev=0x40
+	/*--------------------------------------------------------------------------
+	(0x4000|(15*4)), 31, 0x0001, 27, 0x01e0, 31, 0x0002, 22, 0x85bd, 24, 0xfff2,
+				 27, 0x0c10, 28, 0x0c10, 29, 0x2c10, 31, 0x0003, 23, 0x92f6,
+				 31, 0x0000, 23, 0x003d, 30, 0x00de, 20, 0x20e7,  9, 0x0700,
+	  --------------------------------------------------------------------------*/
+	// 12/17/03 IP1000A v1-4 rev=0x40
+	(0x4000 | (07 * 4)), 31, 0x0001, 27, 0x01e0, 31, 0x0002, 27, 0xeb8e, 31,
+	    0x0000,
+	30, 0x005e, 9, 0x0700,
+	// 01/09/04 IP1000A v1-5 rev=0x41
+	(0x4100 | (07 * 4)), 31, 0x0001, 27, 0x01e0, 31, 0x0002, 27, 0xeb8e, 31,
+	    0x0000,
+	30, 0x005e, 9, 0x0700,
+	0x0000
+};
+
 static const char *ipg_brand_name[] = {
 	"IC PLUS IP1000 1000/100/10 based NIC",
 	"Sundance Technology ST2021 based NIC",
@@ -990,7 +1010,7 @@ static void ipg_nic_txcleanup(struct net_device *dev)
 }
 
 /* Provides statistical information about the IPG NIC. */
-struct net_device_stats *ipg_nic_get_stats(struct net_device *dev)
+static struct net_device_stats *ipg_nic_get_stats(struct net_device *dev)
 {
 	struct ipg_nic_private *sp = netdev_priv(dev);
 	void __iomem *ioaddr = sp->ioaddr;
diff --git a/drivers/net/ipg.h b/drivers/net/ipg.h
index e418b90..d5d092c 100644
--- a/drivers/net/ipg.h
+++ b/drivers/net/ipg.h
@@ -833,24 +833,4 @@ struct ipg_nic_private {
 	struct delayed_work task;
 };
 
-//variable record -- index by leading revision/length
-//Revision/Length(=N*4), Address1, Data1, Address2, Data2,...,AddressN,DataN
-unsigned short DefaultPhyParam[] = {
-	// 11/12/03 IP1000A v1-3 rev=0x40
-	/*--------------------------------------------------------------------------
-	(0x4000|(15*4)), 31, 0x0001, 27, 0x01e0, 31, 0x0002, 22, 0x85bd, 24, 0xfff2,
-				 27, 0x0c10, 28, 0x0c10, 29, 0x2c10, 31, 0x0003, 23, 0x92f6,
-				 31, 0x0000, 23, 0x003d, 30, 0x00de, 20, 0x20e7,  9, 0x0700,
-	  --------------------------------------------------------------------------*/
-	// 12/17/03 IP1000A v1-4 rev=0x40
-	(0x4000 | (07 * 4)), 31, 0x0001, 27, 0x01e0, 31, 0x0002, 27, 0xeb8e, 31,
-	    0x0000,
-	30, 0x005e, 9, 0x0700,
-	// 01/09/04 IP1000A v1-5 rev=0x41
-	(0x4100 | (07 * 4)), 31, 0x0001, 27, 0x01e0, 31, 0x0002, 27, 0xeb8e, 31,
-	    0x0000,
-	30, 0x005e, 9, 0x0700,
-	0x0000
-};
-
 #endif				/* __LINUX_IPG_H */

