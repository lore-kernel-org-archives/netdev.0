From: margitsw@t-online.de (Margit Schubert-While)
Subject: [PATCH 2/2 linux-2.6.9-rc3/linux-2.4.28-pre4]
	prism54 sparse fixes
Date: Sun, 17 Oct 2004 14:08:25 +0200
Sender: prism54-devel-bounces@prism54.org
Message-ID: <200410101530.13397.margitsw@t-online.de>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_5CmcBi7BHwbPvNp"
Cc: netdev@oss.sgi.com, prism54-devel@prism54.org
Return-path: <prism54-devel-bounces@prism54.org>
To: jgarzik@pobox.com
List-Unsubscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=unsubscribe>
List-Archive: <http://prism54.org/pipermail/prism54-devel>
List-Post: <mailto:prism54-devel@prism54.org>
List-Help: <mailto:prism54-devel-request@prism54.org?subject=help>
List-Subscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=subscribe>
Errors-To: prism54-devel-bounces@prism54.org
List-Id: netdev.vger.kernel.org


--Boundary-00=_5CmcBi7BHwbPvNp
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

2004-10-17 Margit Schubert-While <margitsw@t-online.de>

* 02_sparse.patch
*  On top of Linus's sparse changes, here is a
*  fix that further reduces sparse warnings.

We are still left with 2 warnings caused by the
member "data.pointer" in struct "iwreq_data" being
"__user" (from wireless.h).

Margit




--Boundary-00=_5CmcBi7BHwbPvNp
Content-Type: text/x-diff;
  charset="us-ascii";
  name="02_sparse.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="02_sparse.patch"

diff -Naur linux-2.6.9rc3/drivers/net/wireless/prism54/isl_ioctl.c linux-2.6.9-rc3msw/drivers/net/wireless/prism54/isl_ioctl.c
--- linux-2.6.9rc3/drivers/net/wireless/prism54/isl_ioctl.c	2004-10-09 14:32:52.000000000 +0200
+++ linux-2.6.9-rc3msw/drivers/net/wireless/prism54/isl_ioctl.c	2004-10-09 14:43:06.000000000 +0200
@@ -1524,31 +1524,35 @@
 		     const struct obj_mlme *mlme, int error)
 {
 	union iwreq_data wrqu;
+	char *memptr;
 
-	wrqu.data.pointer = kmalloc(IW_CUSTOM_MAX, GFP_KERNEL);
-	if (!wrqu.data.pointer)
+	memptr = kmalloc(IW_CUSTOM_MAX, GFP_KERNEL);
+	if (!memptr)
 		return;
+	wrqu.data.pointer = memptr;
 	wrqu.data.length = 0;
-	format_event(priv, wrqu.data.pointer, str, mlme, &wrqu.data.length,
+	format_event(priv, memptr, str, mlme, &wrqu.data.length,
 		     error);
-	wireless_send_event(priv->ndev, IWEVCUSTOM, &wrqu, wrqu.data.pointer);
-	kfree(wrqu.data.pointer);
+	wireless_send_event(priv->ndev, IWEVCUSTOM, &wrqu, memptr);
+	kfree(memptr);
 }
 
 static void
 send_simple_event(islpci_private *priv, const char *str)
 {
 	union iwreq_data wrqu;
+	char *memptr;
 	int n = strlen(str);
 
-	wrqu.data.pointer = kmalloc(IW_CUSTOM_MAX, GFP_KERNEL);
-	if (!wrqu.data.pointer)
+	memptr = kmalloc(IW_CUSTOM_MAX, GFP_KERNEL);
+	if (!memptr)
 		return;
 	BUG_ON(n > IW_CUSTOM_MAX);
+	wrqu.data.pointer = memptr;
 	wrqu.data.length = n;
-	strcpy(wrqu.data.pointer, str);
-	wireless_send_event(priv->ndev, IWEVCUSTOM, &wrqu, wrqu.data.pointer);
-	kfree(wrqu.data.pointer);
+	strcpy(memptr, str);
+	wireless_send_event(priv->ndev, IWEVCUSTOM, &wrqu, memptr);
+	kfree(memptr);
 }
 
 static void
diff -Naur linux-2.6.9rc3/drivers/net/wireless/prism54/prismcompat.h linux-2.6.9-rc3msw/drivers/net/wireless/prism54/prismcompat.h
--- linux-2.6.9rc3/drivers/net/wireless/prism54/prismcompat.h	2004-10-09 14:32:52.000000000 +0200
+++ linux-2.6.9-rc3msw/drivers/net/wireless/prism54/prismcompat.h	2004-10-09 15:20:50.000000000 +0200
@@ -38,6 +38,10 @@
 #error Firmware Loading is not configured in the kernel !
 #endif
 
+#ifndef __iomem
+#define __iomem
+#endif
+
 #define prism54_synchronize_irq(irq) synchronize_irq(irq)
 
 #define PRISM_FW_PDEV		&priv->pdev->dev

--Boundary-00=_5CmcBi7BHwbPvNp
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Prism54-devel mailing list
Prism54-devel@prism54.org
http://prism54.org/mailman/listinfo/prism54-devel

--Boundary-00=_5CmcBi7BHwbPvNp--
