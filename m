From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Resend: [NETDRV] Fix successive calls to spin_lock_irqsave in sk98lin
Date: Thu, 1 Jul 2004 21:04:18 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040701110418.GA10797@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="Nq2Wo0NMKNjxTN9z"
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>, netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--Nq2Wo0NMKNjxTN9z
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Jeff:

This patch fixes the few places in sk98lin where it calls
spin_lock_saveirq on the same flags variable thus causing
interrupts to be disabled upon leaving the driver.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--Nq2Wo0NMKNjxTN9z
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

Index: drivers/net/sk98lin/skge.c
===================================================================
RCS file: /home/gondolin/herbert/src/CVS/debian/kernel-source-2.5/drivers/net/sk98lin/skge.c,v
retrieving revision 1.1.1.17
diff -u -r1.1.1.17 skge.c
--- drivers/net/sk98lin/skge.c	10 May 2004 09:47:55 -0000	1.1.1.17
+++ drivers/net/sk98lin/skge.c	22 Jun 2004 10:45:23 -0000
@@ -3093,8 +3093,7 @@
 	SkEventDispatcher(pAC, pAC->IoBase);
 
 	for (i=0; i<pAC->GIni.GIMacsFound; i++) {
-		spin_lock_irqsave(
-			&pAC->TxPort[i][TX_PRIO_LOW].TxDesRingLock, Flags);
+		spin_lock(&pAC->TxPort[i][TX_PRIO_LOW].TxDesRingLock);
 		netif_stop_queue(pAC->dev[i]);
 
 	}
@@ -4773,12 +4772,10 @@
 		spin_lock_irqsave(
 			&pAC->TxPort[FromPort][TX_PRIO_LOW].TxDesRingLock,
 			Flags);
-		spin_lock_irqsave(
-			&pAC->TxPort[ToPort][TX_PRIO_LOW].TxDesRingLock, Flags);
+		spin_lock(&pAC->TxPort[ToPort][TX_PRIO_LOW].TxDesRingLock);
 		SkGeStopPort(pAC, IoC, FromPort, SK_STOP_ALL, SK_SOFT_RST);
 		SkGeStopPort(pAC, IoC, ToPort, SK_STOP_ALL, SK_SOFT_RST);
-		spin_unlock_irqrestore(
-			&pAC->TxPort[ToPort][TX_PRIO_LOW].TxDesRingLock, Flags);
+		spin_unlock(&pAC->TxPort[ToPort][TX_PRIO_LOW].TxDesRingLock);
 		spin_unlock_irqrestore(
 			&pAC->TxPort[FromPort][TX_PRIO_LOW].TxDesRingLock,
 			Flags);
@@ -4791,8 +4788,7 @@
 		spin_lock_irqsave(
 			&pAC->TxPort[FromPort][TX_PRIO_LOW].TxDesRingLock,
 			Flags);
-		spin_lock_irqsave(
-			&pAC->TxPort[ToPort][TX_PRIO_LOW].TxDesRingLock, Flags);
+		spin_lock(&pAC->TxPort[ToPort][TX_PRIO_LOW].TxDesRingLock);
 		pAC->ActivePort = ToPort;
 #if 0
 		SetQueueSizes(pAC);
@@ -4807,8 +4803,7 @@
 			pAC,
 			pAC->ActivePort,
 			DualNet)) {
-			spin_unlock_irqrestore(
-				&pAC->TxPort[ToPort][TX_PRIO_LOW].TxDesRingLock, Flags);
+			spin_unlock(&pAC->TxPort[ToPort][TX_PRIO_LOW].TxDesRingLock);
 			spin_unlock_irqrestore(
 				&pAC->TxPort[FromPort][TX_PRIO_LOW].TxDesRingLock,
 				Flags);
@@ -4834,8 +4829,7 @@
 		SkGePollTxD(pAC, IoC, ToPort, SK_TRUE);
 		ClearAndStartRx(pAC, FromPort);
 		ClearAndStartRx(pAC, ToPort);
-		spin_unlock_irqrestore(
-			&pAC->TxPort[ToPort][TX_PRIO_LOW].TxDesRingLock, Flags);
+		spin_unlock(&pAC->TxPort[ToPort][TX_PRIO_LOW].TxDesRingLock);
 		spin_unlock_irqrestore(
 			&pAC->TxPort[FromPort][TX_PRIO_LOW].TxDesRingLock,
 			Flags);

--Nq2Wo0NMKNjxTN9z--
