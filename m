From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (24/25) sk98: get_stats cleanup
Date: Mon, 15 Nov 2004 16:00:30 -0800
Message-ID: <20041115160030.2413f0a5@zqx3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>, Mirko Lindner <demon@pro-linux.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Cleanup indentation and casting in the get statistics routine.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
 
diff -Nru a/drivers/net/sk98lin/skge.c b/drivers/net/sk98lin/skge.c
--- a/drivers/net/sk98lin/skge.c	2004-11-15 14:56:52 -08:00
+++ b/drivers/net/sk98lin/skge.c	2004-11-15 14:56:52 -08:00
@@ -2695,15 +2695,15 @@
  */
 static struct net_device_stats *SkGeStats(struct net_device *dev)
 {
-DEV_NET *pNet = netdev_priv(dev);
-SK_AC	*pAC = pNet->pAC;
-SK_PNMI_STRUCT_DATA *pPnmiStruct;       /* structure for all Pnmi-Data */
-SK_PNMI_STAT    *pPnmiStat;             /* pointer to virtual XMAC stat. data */
-unsigned int    Size;                   /* size of pnmi struct */
-unsigned long	Flags;			/* for spin lock */
+	DEV_NET *pNet = netdev_priv(dev);
+	SK_AC	*pAC = pNet->pAC;
+	SK_PNMI_STRUCT_DATA *pPnmiStruct;       /* structure for all Pnmi-Data */
+	SK_PNMI_STAT    *pPnmiStat;             /* pointer to virtual XMAC stat. data */
+	unsigned int    Size;                   /* size of pnmi struct */
+	unsigned long	Flags;			/* for spin lock */
 
 	SK_DBG_MSG(NULL, SK_DBGMOD_DRV, SK_DBGCAT_DRV_ENTRY,
-		("SkGeStats starts now...\n"));
+		   ("SkGeStats starts now...\n"));
 
  	pPnmiStruct = kmalloc(sizeof(*pPnmiStruct), GFP_ATOMIC);
  	if (!pPnmiStruct)
@@ -2712,60 +2712,46 @@
  	memset(pPnmiStruct, 0, sizeof(*pPnmiStruct));
 	Size = sizeof(*pPnmiStruct);
 
-#ifdef SK_DIAG_SUPPORT
-        if ((pAC->DiagModeActive == DIAG_NOTACTIVE) &&
-                (pAC->BoardLevel == SK_INIT_RUN)) {
-#endif
-        SK_MEMSET(pPnmiStruct, 0, sizeof(SK_PNMI_STRUCT_DATA));
-        spin_lock_irqsave(&pAC->SlowPathLock, Flags);
-        Size = SK_PNMI_STRUCT_SIZE;
-		SkPnmiGetStruct(pAC, pAC->IoBase, pPnmiStruct, &Size, pNet->NetNr);
-        spin_unlock_irqrestore(&pAC->SlowPathLock, Flags);
-#ifdef SK_DIAG_SUPPORT
-	}
-#endif
+	spin_lock_irqsave(&pAC->SlowPathLock, Flags);
+	SkPnmiGetStruct(pAC, pAC->IoBase, pPnmiStruct, &Size, pNet->NetNr);
+	spin_unlock_irqrestore(&pAC->SlowPathLock, Flags);
 
         pPnmiStat = &pPnmiStruct->Stat[0];
 
-	pAC->stats.rx_packets = (SK_U32) pPnmiStruct->RxDeliveredCts & 0xFFFFFFFF;
-	pAC->stats.tx_packets = (SK_U32) pPnmiStat->StatTxOkCts & 0xFFFFFFFF;
-	pAC->stats.rx_bytes = (SK_U32) pPnmiStruct->RxOctetsDeliveredCts;
-	pAC->stats.tx_bytes = (SK_U32) pPnmiStat->StatTxOctetsOkCts;
-	
-        if (dev->mtu <= 1500) {
-                pAC->stats.rx_errors = (SK_U32) pPnmiStruct->InErrorsCts & 0xFFFFFFFF;
-        } else {
-                pAC->stats.rx_errors = (SK_U32) ((pPnmiStruct->InErrorsCts -
-                        pPnmiStat->StatRxTooLongCts) & 0xFFFFFFFF);
-	}
-
-
-	if (pAC->GIni.GP[0].PhyType == SK_PHY_XMAC && pAC->HWRevision < 12)
-		pAC->stats.rx_errors = pAC->stats.rx_errors - pPnmiStat->StatRxShortsCts;
-
-	pAC->stats.tx_errors = (SK_U32) pPnmiStat->StatTxSingleCollisionCts & 0xFFFFFFFF;
-	pAC->stats.rx_dropped = (SK_U32) pPnmiStruct->RxNoBufCts & 0xFFFFFFFF;
-	pAC->stats.tx_dropped = (SK_U32) pPnmiStruct->TxNoBufCts & 0xFFFFFFFF;
-	pAC->stats.multicast = (SK_U32) pPnmiStat->StatRxMulticastOkCts & 0xFFFFFFFF;
-	pAC->stats.collisions = (SK_U32) pPnmiStat->StatTxSingleCollisionCts & 0xFFFFFFFF;
-
-	/* detailed rx_errors: */
-	pAC->stats.rx_length_errors = (SK_U32) pPnmiStat->StatRxRuntCts & 0xFFFFFFFF;
-	pAC->stats.rx_over_errors = (SK_U32) pPnmiStat->StatRxFifoOverflowCts & 0xFFFFFFFF;
-	pAC->stats.rx_crc_errors = (SK_U32) pPnmiStat->StatRxFcsCts & 0xFFFFFFFF;
-	pAC->stats.rx_frame_errors = (SK_U32) pPnmiStat->StatRxFramingCts & 0xFFFFFFFF;
-	pAC->stats.rx_fifo_errors = (SK_U32) pPnmiStat->StatRxFifoOverflowCts & 0xFFFFFFFF;
-	pAC->stats.rx_missed_errors = (SK_U32) pPnmiStat->StatRxMissedCts & 0xFFFFFFFF;
-
-	/* detailed tx_errors */
-	pAC->stats.tx_aborted_errors = (SK_U32) 0;
-	pAC->stats.tx_carrier_errors = (SK_U32) pPnmiStat->StatTxCarrierCts & 0xFFFFFFFF;
-	pAC->stats.tx_fifo_errors = (SK_U32) pPnmiStat->StatTxFifoUnderrunCts & 0xFFFFFFFF;
-	pAC->stats.tx_heartbeat_errors = (SK_U32) pPnmiStat->StatTxCarrierCts & 0xFFFFFFFF;
-	pAC->stats.tx_window_errors = (SK_U32) 0;
+	memset(&pAC->stats, 0, sizeof(struct net_device_stats));
+	pAC->stats.rx_packets = pPnmiStruct->RxDeliveredCts;
+	pAC->stats.tx_packets = pPnmiStat->StatTxOkCts;
+	pAC->stats.rx_bytes = pPnmiStruct->RxOctetsDeliveredCts;
+	pAC->stats.tx_bytes = pPnmiStat->StatTxOctetsOkCts;
+  	
+	pAC->stats.rx_errors = pPnmiStruct->InErrorsCts;
+        if (dev->mtu > 1500)
+                pAC->stats.rx_errors -= pPnmiStat->StatRxTooLongCts;
+  
+  	if (pAC->GIni.GP[0].PhyType == SK_PHY_XMAC && pAC->HWRevision < 12)
+		pAC->stats.rx_errors -= pPnmiStat->StatRxShortsCts;
+  
+	pAC->stats.tx_errors = pPnmiStat->StatTxSingleCollisionCts;
+	pAC->stats.rx_dropped = pPnmiStruct->RxNoBufCts;
+	pAC->stats.tx_dropped = pPnmiStruct->TxNoBufCts;
+	pAC->stats.multicast = pPnmiStat->StatRxMulticastOkCts;
+	pAC->stats.collisions = pPnmiStat->StatTxSingleCollisionCts;
+  
+  	/* detailed rx_errors: */
+	pAC->stats.rx_length_errors = pPnmiStat->StatRxRuntCts;
+	pAC->stats.rx_over_errors = pPnmiStat->StatRxFifoOverflowCts;
+	pAC->stats.rx_crc_errors = pPnmiStat->StatRxFcsCts;
+	pAC->stats.rx_frame_errors = pPnmiStat->StatRxFramingCts;
+	pAC->stats.rx_fifo_errors = pPnmiStat->StatRxFifoOverflowCts;
+	pAC->stats.rx_missed_errors = pPnmiStat->StatRxMissedCts;
+  
+  	/* detailed tx_errors */
+	pAC->stats.tx_carrier_errors = pPnmiStat->StatTxCarrierCts;
+	pAC->stats.tx_fifo_errors = pPnmiStat->StatTxFifoUnderrunCts;
+	pAC->stats.tx_heartbeat_errors = pPnmiStat->StatTxCarrierCts;
 
 	kfree(pPnmiStruct);
-  out:
+ out:
 	return &pAC->stats;
 } /* SkGeStats */
 
