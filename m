From: David Vrabel <dvrabel@cantab.net>
Subject: Re: [PATCH 2/2] ipg: redundancy with mii.h
Date: Sat, 20 May 2006 22:03:10 +0100
Message-ID: <446F840E.3020808@cantab.net>
References: <44554ADE.8030200@cantab.net> <4455F1D8.5030102@cantab.net> <1146506939.23931.2.camel@localhost> <20060501231206.GD7419@electric-eye.fr.zoreil.com> <Pine.LNX.4.58.0605020945010.4066@sbz-30.cs.Helsinki.FI> <20060502214520.GC26357@electric-eye.fr.zoreil.com> <20060502215559.GA1119@electric-eye.fr.zoreil.com> <Pine.LNX.4.58.0605030913210.6032@sbz-30.cs.Helsinki.FI> <20060503233558.GA27232@electric-eye.fr.zoreil.com> <1146750276.11422.0.camel@localhost> <20060504235549.GA9128@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080300000806070909030101"
Cc: Pekka Enberg <penberg@cs.helsinki.fi>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	david@pleyades.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from rutherford.zen.co.uk ([212.23.3.142]:49813 "EHLO
	rutherford.zen.co.uk") by vger.kernel.org with ESMTP
	id S932273AbWETVDX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 20 May 2006 17:03:23 -0400
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20060504235549.GA9128@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------080300000806070909030101
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Apologies for the (very) late response.

0007-ipg-plug-leaks-in-the-error-path-of-ipg_nic_open.txt broke receive 
since it was skipping the initialization of the Rx buffers.  Patch attached.

Did anyone manage to get a response from IC Plus regarding the required 
Signed-off-by line?

David Vrabel

--------------080300000806070909030101
Content-Type: text/plain;
 name="ipg-fix-init_rfdlist"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="ipg-fix-init_rfdlist"

ipg: initialize Rx buffers correctly

A previous patch resulted in the initialization of the Rx buffers
being skipped.

Signed-off-by: David Vrabel <dvrabel@cantab.net>

--- linux-source-2.6.16.orig/drivers/net/ipg.c	2006-05-20 21:38:44.604788258 +0100
+++ linux-source-2.6.16/drivers/net/ipg.c	2006-05-20 21:39:14.298898552 +0100
@@ -1298,18 +1298,16 @@
 	sp->RxBuffNotReady = 0;
 
 	for (i = 0; i < IPG_RFDLIST_LENGTH; i++) {
-		if (!sp->RxBuff[i])
-			continue;
-
-		/* Free any allocated receive buffers. */
-		pci_unmap_single(sp->pdev,
-				 sp->RxBuffDMAhandle[i].dmahandle,
-				 sp->RxBuffDMAhandle[i].len,
-				 PCI_DMA_FROMDEVICE);
-
-		IPG_DEV_KFREE_SKB(sp->RxBuff[i]);
-		sp->RxBuff[i] = NULL;
+		if (sp->RxBuff[i]) {
+			/* Free any allocated receive buffers. */
+			pci_unmap_single(sp->pdev,
+					 sp->RxBuffDMAhandle[i].dmahandle,
+					 sp->RxBuffDMAhandle[i].len,
+					 PCI_DMA_FROMDEVICE);
 
+			IPG_DEV_KFREE_SKB(sp->RxBuff[i]);
+			sp->RxBuff[i] = NULL;
+		}
 		/* Clear out the RFS field. */
 		sp->RFDList[i].RFS = 0x0000000000000000;
 

--------------080300000806070909030101--
