From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (25/25) sk98: change type of DiagModeActive
Date: Mon, 15 Nov 2004 16:36:16 -0800
Message-ID: <20041115163616.17dfe933@zqx3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>, Mirko Lindner <demon@pro-linux.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

DiagModeActive is just a boolean, doesn't need whole u32

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/drivers/net/sk98lin/h/skdrv2nd.h b/drivers/net/sk98lin/h/skdrv2nd.h
--- a/drivers/net/sk98lin/h/skdrv2nd.h	2004-11-15 16:24:29 -08:00
+++ b/drivers/net/sk98lin/h/skdrv2nd.h	2004-11-15 16:24:29 -08:00
@@ -378,11 +378,6 @@
 	SK_TIMER        ModTimer; /* just some timer */
 };
 
-#ifdef SK_DIAG_SUPPORT
-#define	DIAG_ACTIVE		1
-#define	DIAG_NOTACTIVE		0
-#endif
-
 /****************************************************************************
  * Per board structure / Adapter Context structure:
  *	Allocated within attach(9e) and freed within detach(9e).
@@ -440,7 +435,7 @@
 					 *  1 == Yukon family support
 					 */
 #ifdef SK_DIAG_SUPPORT
-	SK_U32		DiagModeActive;		/* is diag active?	*/
+	SK_BOOL		DiagModeActive;		/* is diag active?	*/
 	SK_BOOL		DiagFlowCtrl;		/* for control purposes	*/
 	SK_BOOL         WasIfUp[SK_MAX_MACS];   /* for OpenClose while 
 						 * DIAG is busy with NIC 
diff -Nru a/drivers/net/sk98lin/skge.c b/drivers/net/sk98lin/skge.c
--- a/drivers/net/sk98lin/skge.c	2004-11-15 16:24:29 -08:00
+++ b/drivers/net/sk98lin/skge.c	2004-11-15 16:24:29 -08:00
@@ -1122,7 +1122,7 @@
 		("SkGeOpen: pAC=0x%lX:\n", (unsigned long)pAC));
 
 #ifdef SK_DIAG_SUPPORT
-	if (pAC->DiagModeActive == DIAG_ACTIVE) {
+	if (pAC->DiagModeActive) {
 		if (pAC->Pnmi.DiagAttached == SK_DIAG_RUNNING) {
 			return (-1);   /* still in use by diag; deny actions */
 		} 
@@ -1238,7 +1238,7 @@
 	pAC = pNet->pAC;
 
 #ifdef SK_DIAG_SUPPORT
-	if (pAC->DiagModeActive == DIAG_ACTIVE) {
+	if (pAC->DiagModeActive) {
 		if (pAC->DiagFlowCtrl == SK_FALSE) {
 			/* 
 			** notify that the interface which has been closed
@@ -2492,7 +2492,7 @@
 	}
 
 #ifdef SK_DIAG_SUPPORT
-	if (pAC->DiagModeActive == DIAG_ACTIVE) {
+	if (pAC->DiagModeActive) {
 		if (pAC->DiagFlowCtrl == SK_FALSE) {
 			return -1; /* still in use, deny any actions of MTU */
 		} else {
@@ -4343,7 +4343,7 @@
 	DEV_NET *pNet = netdev_priv(pAc->dev[0]);
 	SK_AC   *pAC  = pNet->pAC;
 
-	pAC->DiagModeActive = DIAG_ACTIVE;
+	pAC->DiagModeActive = SK_TRUE;
 	if (pAC->BoardLevel > SK_INIT_DATA) {
 		if (netif_running(pAC->dev[0])) {
 			pAC->WasIfUp[0] = SK_TRUE;
@@ -4384,7 +4384,7 @@
 int SkDrvLeaveDiagMode(
 SK_AC   *pAc)   /* pointer to adapter control context */
 { 
-	pAc->DiagModeActive    = DIAG_NOTACTIVE;
+	pAc->DiagModeActive    = SK_FALSE;
 	pAc->Pnmi.DiagAttached = SK_DIAG_IDLE;
         if (pAc->WasIfUp[0] == SK_TRUE) {
                 pAc->DiagFlowCtrl = SK_TRUE; /* for SkGeClose */
