From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (2/10) sk98: open error codes
Date: Thu, 18 Nov 2004 14:40:38 -0800
Message-ID: <20041118144038.259333bc@zqx3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Mirko Lindner <demon@pro-linux.de>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Sk98lin open would return -1 in case of error instead of a useful
errno value.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/drivers/net/sk98lin/skge.c b/drivers/net/sk98lin/skge.c
--- a/drivers/net/sk98lin/skge.c	2004-11-17 09:22:56 -08:00
+++ b/drivers/net/sk98lin/skge.c	2004-11-17 09:22:56 -08:00
@@ -1122,11 +1122,8 @@
 		("SkGeOpen: pAC=0x%lX:\n", (unsigned long)pAC));
 
 #ifdef SK_DIAG_SUPPORT
-	if (pAC->DiagModeActive) {
-		if (pAC->Pnmi.DiagAttached == SK_DIAG_RUNNING) {
-			return (-1);   /* still in use by diag; deny actions */
-		} 
-	}
+	if (pAC->DiagModeActive && pAC->Pnmi.DiagAttached == SK_DIAG_RUNNING)
+		return -EBUSY;
 #endif
 
 	/* Set blink mode */
@@ -1137,7 +1134,7 @@
 		/* level 1 init common modules here */
 		if (SkGeInit(pAC, pAC->IoBase, SK_INIT_IO) != 0) {
 			printk(KERN_ERR "%s: HWInit (1) failed.\n", pAC->dev[pNet->PortNr]->name);
-			return (-1);
+			return -EIO;
 		}
 		SkI2cInit	(pAC, pAC->IoBase, SK_INIT_IO);
 		SkEventInit	(pAC, pAC->IoBase, SK_INIT_IO);
@@ -1152,7 +1149,7 @@
 		/* tschilling: Level 2 init modules here, check return value. */
 		if (SkGeInit(pAC, pAC->IoBase, SK_INIT_RUN) != 0) {
 			printk(KERN_ERR "%s: HWInit (2) failed.\n", pAC->dev[pNet->PortNr]->name);
-			return (-1);
+			return -EIO;
 		}
 		SkI2cInit	(pAC, pAC->IoBase, SK_INIT_RUN);
 		SkEventInit	(pAC, pAC->IoBase, SK_INIT_RUN);
@@ -1204,7 +1201,7 @@
 	SK_DBG_MSG(NULL, SK_DBGMOD_DRV, SK_DBGCAT_DRV_ENTRY,
 		("SkGeOpen suceeded\n"));
 
-	return (0);
+	return 0;
 } /* SkGeOpen */
 
 
