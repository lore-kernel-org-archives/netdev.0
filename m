From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2.6.9 4/5] skge: use netdev_priv
Date: Mon, 18 Oct 2004 15:24:06 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041018152406.5353c657@zqx3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Use netdev_priv (and dev->priv can't be null).

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/drivers/net/sk98lin/skge.c b/drivers/net/sk98lin/skge.c
--- a/drivers/net/sk98lin/skge.c	2004-10-18 15:14:35 -07:00
+++ b/drivers/net/sk98lin/skge.c	2004-10-18 15:14:35 -07:00
@@ -337,22 +337,20 @@
 DEV_NET		*pNet;
 SK_AC		*pAC;
 
-	if (dev->priv) {
-		pNet = (DEV_NET*) dev->priv;
-		pAC = pNet->pAC;
-		AllocFlag = pAC->AllocFlag;
-		if (pAC->PciDev) {
-			pci_release_regions(pAC->PciDev);
-		}
-		if (AllocFlag & SK_ALLOC_IRQ) {
-			free_irq(dev->irq, dev);
-		}
-		if (pAC->IoBase) {
-			iounmap(pAC->IoBase);
-		}
-		if (pAC->pDescrMem) {
-			BoardFreeMem(pAC);
-		}
+	pNet = netdev_priv(dev);
+	pAC = pNet->pAC;
+	AllocFlag = pAC->AllocFlag;
+	if (pAC->PciDev) {
+		pci_release_regions(pAC->PciDev);
+	}
+	if (AllocFlag & SK_ALLOC_IRQ) {
+		free_irq(dev->irq, dev);
+	}
+	if (pAC->IoBase) {
+		iounmap(pAC->IoBase);
+	}
+	if (pAC->pDescrMem) {
+		BoardFreeMem(pAC);
 	}
 	
 } /* FreeResources */
@@ -887,7 +885,7 @@
 SK_AC		*pAC;
 SK_U32		IntSrc;		/* interrupts source register contents */	
 
-	pNet = (DEV_NET*) dev->priv;
+	pNet = netdev_priv(dev);
 	pAC = pNet->pAC;
 	
 	/*
@@ -1036,7 +1034,7 @@
 SK_AC		*pAC;
 SK_U32		IntSrc;		/* interrupts source register contents */	
 
-	pNet = (DEV_NET*) dev->priv;
+	pNet = netdev_priv(dev);
 	pAC = pNet->pAC;
 	
 	/*
@@ -1152,7 +1150,7 @@
 	int				i;
 	SK_EVPARA		EvPara;		/* an event parameter union */
 
-	pNet = (DEV_NET*) dev->priv;
+	pNet = netdev_priv(dev);
 	pAC = pNet->pAC;
 	
 	SK_DBG_MSG(NULL, SK_DBGMOD_DRV, SK_DBGCAT_DRV_ENTRY,
@@ -1273,7 +1271,7 @@
 	SK_DBG_MSG(NULL, SK_DBGMOD_DRV, SK_DBGCAT_DRV_ENTRY,
 		("SkGeClose: pAC=0x%lX ", (unsigned long)pAC));
 
-	pNet = (DEV_NET*) dev->priv;
+	pNet = netdev_priv(dev);
 	pAC = pNet->pAC;
 
 #ifdef SK_DIAG_SUPPORT
@@ -1284,7 +1282,7 @@
 			** by operator interaction must not be started up 
 			** again when the DIAG has finished. 
 			*/
-			newPtrNet = (DEV_NET *) pAC->dev[0]->priv;
+			newPtrNet = netdev_priv(pAC->dev[0]);
 			if (newPtrNet == pNet) {
 				pAC->WasIfUp[0] = SK_FALSE;
 			} else {
@@ -1394,7 +1392,7 @@
 SK_AC		*pAC;
 int			Rc;	/* return code of XmitFrame */
 
-	pNet = (DEV_NET*) dev->priv;
+	pNet = netdev_priv(dev);
 	pAC = pNet->pAC;
 
 	if ((!skb_shinfo(skb)->nr_frags) ||
@@ -2490,7 +2488,7 @@
 static int SkGeSetMacAddr(struct SK_NET_DEVICE *dev, void *p)
 {
 
-DEV_NET *pNet = (DEV_NET*) dev->priv;
+DEV_NET *pNet = netdev_priv(dev);
 SK_AC	*pAC = pNet->pAC;
 
 struct sockaddr	*addr = p;
@@ -2547,7 +2545,7 @@
 	SK_DBG_MSG(NULL, SK_DBGMOD_DRV, SK_DBGCAT_DRV_ENTRY,
 		("SkGeSetRxMode starts now... "));
 
-	pNet = (DEV_NET*) dev->priv;
+	pNet = netdev_priv(dev);
 	pAC = pNet->pAC;
 	if (pAC->RlmtNets == 1)
 		PortIdx = pAC->ActivePort;
@@ -2619,7 +2617,7 @@
 	SK_DBG_MSG(NULL, SK_DBGMOD_DRV, SK_DBGCAT_DRV_ENTRY,
 		("SkGeChangeMtu starts now...\n"));
 
-	pNet = (DEV_NET*) dev->priv;
+	pNet = netdev_priv(dev);
 	pAC  = pNet->pAC;
 
 	if ((NewMtu < 68) || (NewMtu > SK_JUMBO_MTU)) {
@@ -2641,7 +2639,7 @@
 #endif
 
 	pNet->Mtu = NewMtu;
-	pOtherNet = (DEV_NET*)pAC->dev[1 - pNet->NetNr]->priv;
+	pOtherNet = netdev_priv(pAC->dev[1 - pNet->NetNr]);
 	if ((pOtherNet->Mtu>1500) && (NewMtu<=1500) && (pOtherNet->Up==1)) {
 		return(0);
 	}
@@ -2847,7 +2845,7 @@
  */
 static struct net_device_stats *SkGeStats(struct SK_NET_DEVICE *dev)
 {
-DEV_NET *pNet = (DEV_NET*) dev->priv;
+DEV_NET *pNet = netdev_priv(dev);
 SK_AC	*pAC = pNet->pAC;
 SK_PNMI_STRUCT_DATA *pPnmiStruct;       /* structure for all Pnmi-Data */
 SK_PNMI_STAT    *pPnmiStat;             /* pointer to virtual XMAC stat. data */
@@ -2945,7 +2943,7 @@
 	SK_DBG_MSG(NULL, SK_DBGMOD_DRV, SK_DBGCAT_DRV_ENTRY,
 		("SkGeIoctl starts now...\n"));
 
-	pNet = (DEV_NET*) dev->priv;
+	pNet = netdev_priv(dev);
 	pAC = pNet->pAC;
 	
 	if(copy_from_user(&Ioctl, rq->ifr_data, sizeof(SK_GE_IOCTL))) {
@@ -4531,11 +4529,8 @@
 int SkDrvEnterDiagMode(
 SK_AC   *pAc)   /* pointer to adapter context */
 {
-	SK_AC   *pAC  = NULL;
-	DEV_NET *pNet = NULL;
-
-	pNet = (DEV_NET *) pAc->dev[0]->priv;
-	pAC = pNet->pAC;
+	DEV_NET *pNet = netdev_priv(pAc->dev[0]);
+	SK_AC   *pAC  = pNet->pAC;
 
 	SK_MEMCPY(&(pAc->PnmiBackup), &(pAc->PnmiStruct), 
 			sizeof(SK_PNMI_STRUCT_DATA));
@@ -4550,8 +4545,8 @@
 		} else {
 			pAC->WasIfUp[0] = SK_FALSE;
 		}
-		if (pNet != (DEV_NET *) pAc->dev[1]->priv) {
-			pNet = (DEV_NET *) pAc->dev[1]->priv;
+		if (pNet != netdev_priv(pAC->dev[1])) {
+			pNet = netdev_priv(pAC->dev[1]);
 			if (pNet->Up) {
 				pAC->WasIfUp[1] = SK_TRUE;
 				pAC->DiagFlowCtrl = SK_TRUE; /* for SkGeClose */
@@ -4897,7 +4892,7 @@
 		goto out_disable_device;
 	}
 
-	pNet = dev->priv;
+	pNet = netdev_priv(dev);
 	pNet->pAC = kmalloc(sizeof(SK_AC), GFP_KERNEL);
 	if (!pNet->pAC) {
 		printk(KERN_ERR "Unable to allocate adapter "
@@ -4997,7 +4992,7 @@
 		}
 
 		pAC->dev[1]   = dev;
-		pNet          = dev->priv;
+		pNet          = netdev_priv(dev);
 		pNet->PortNr  = 1;
 		pNet->NetNr   = 1;
 		pNet->pAC     = pAC;
@@ -5073,7 +5068,7 @@
 static void __devexit skge_remove_one(struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
-	DEV_NET *pNet = (DEV_NET *) dev->priv;
+	DEV_NET *pNet = netdev_priv(dev);
 	SK_AC *pAC = pNet->pAC;
 	int have_second_mac = 0;
 
