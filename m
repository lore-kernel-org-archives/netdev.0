From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] (23/25) sk98: eliminate Pnmi scratchpad
Date: Fri, 19 Nov 2004 11:41:27 -0800
Message-ID: <20041119114127.3858355b@zqx3.pdx.osdl.net>
References: <20041115155832.264aa86f@zqx3.pdx.osdl.net>
	<20041119104331.70a45312@zqx3.pdx.osdl.net>
	<20041119191117.GA13556@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, Mirko Lindner <demon@pro-linux.de>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20041119191117.GA13556@electric-eye.fr.zoreil.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This fixes the leak in the ethtool statistics code from the last patch.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/drivers/net/sk98lin/skethtool.c b/drivers/net/sk98lin/skethtool.c
--- a/drivers/net/sk98lin/skethtool.c	2004-11-19 11:40:14 -08:00
+++ b/drivers/net/sk98lin/skethtool.c	2004-11-19 11:40:14 -08:00
@@ -268,7 +268,6 @@
 	int err;
 	SK_PNMI_STRUCT_DATA *pPnmiStruct;
 
-
 	pPnmiStruct = kmalloc(sizeof(*pPnmiStruct), GFP_KERNEL);
 	if (!pPnmiStruct)
 		return;
@@ -279,8 +278,8 @@
 	err = SkPnmiGetStruct(pAC, pAC->IoBase, pPnmiStruct, &size, pNet->NetNr);
 	spin_unlock_irqrestore(&pAC->SlowPathLock, flags);
 
-	if (err)
-		return;
+	if (err) 
+		goto out;
 
 	*data++ = pPnmiStruct->Stat[0].StatRxOkCts;
 	*data++ = pPnmiStruct->Stat[0].StatTxOkCts;
@@ -309,6 +308,9 @@
 	*data++ = pPnmiStruct->Stat[0].StatTxFifoUnderrunCts;
 	*data++ = pPnmiStruct->Stat[0].StatTxCarrierCts;
 	*data++ = pAC->stats.tx_window_errors;
+
+ out:
+	kfree(pPnmiStruct);
 }
 
 
