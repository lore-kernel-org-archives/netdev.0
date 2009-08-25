From: Alan Cox <alan@linux.intel.com>
Subject: [PATCH 06/26] et131x: MPSend macros
Date: Tue, 25 Aug 2009 15:58:20 +0100
Message-ID: <20090825145816.16176.66807.stgit@localhost.localdomain>
References: <20090825145619.16176.68780.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: greg@kroah.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from earthlight.etchedpixels.co.uk ([81.2.110.250]:42584 "EHLO
	bob.linux.org.uk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755102AbZHYPDm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2009 11:03:42 -0400
In-Reply-To: <20090825145619.16176.68780.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Most are unused, one is used and can be replaced with the definition

Signed-off-by: Alan Cox <alan@linux.intel.com>
---

 drivers/staging/et131x/et1310_tx.c      |    8 ++++----
 drivers/staging/et131x/et131x_adapter.h |    5 -----
 2 files changed, 4 insertions(+), 9 deletions(-)


diff --git a/drivers/staging/et131x/et1310_tx.c b/drivers/staging/et131x/et1310_tx.c
index a017d27..43f5b62 100644
--- a/drivers/staging/et131x/et1310_tx.c
+++ b/drivers/staging/et131x/et1310_tx.c
@@ -1375,7 +1375,7 @@ void et131x_free_busy_send_packets(struct et131x_adapter *etdev)
 		DBG_VERBOSE(et131x_dbginfo, "pMpTcb = 0x%p\n", pMpTcb);
 
 		FreeCounter++;
-		MP_FREE_SEND_PACKET_FUN(etdev, pMpTcb);
+		et131x_free_send_packet(etdev, pMpTcb);
 
 		spin_lock_irqsave(&etdev->TCBSendQLock, flags);
 
@@ -1384,7 +1384,7 @@ void et131x_free_busy_send_packets(struct et131x_adapter *etdev)
 
 	if (FreeCounter == NUM_TCB) {
 		DBG_ERROR(et131x_dbginfo,
-		    "MpFreeBusySendPackets exitted loop for a bad reason\n");
+		    "MpFreeBusySendPackets exited loop for a bad reason\n");
 		BUG();
 	}
 
@@ -1451,7 +1451,7 @@ static void et131x_update_tcb_list(struct et131x_adapter *etdev)
 			etdev->TxRing.CurrSendTail = NULL;
 
 		spin_unlock_irqrestore(&etdev->TCBSendQLock, flags);
-		MP_FREE_SEND_PACKET_FUN(etdev, pMpTcb);
+		et131x_free_send_packet(etdev, pMpTcb);
 		spin_lock_irqsave(&etdev->TCBSendQLock, flags);
 
 		/* Goto the next packet */
@@ -1466,7 +1466,7 @@ static void et131x_update_tcb_list(struct et131x_adapter *etdev)
 			etdev->TxRing.CurrSendTail = NULL;
 
 		spin_unlock_irqrestore(&etdev->TCBSendQLock, flags);
-		MP_FREE_SEND_PACKET_FUN(etdev, pMpTcb);
+		et131x_free_send_packet(etdev, pMpTcb);
 		spin_lock_irqsave(&etdev->TCBSendQLock, flags);
 
 		/* Goto the next packet */
diff --git a/drivers/staging/et131x/et131x_adapter.h b/drivers/staging/et131x/et131x_adapter.h
index 04de4ff..df4a625 100644
--- a/drivers/staging/et131x/et131x_adapter.h
+++ b/drivers/staging/et131x/et131x_adapter.h
@@ -333,9 +333,4 @@ struct et131x_adapter {
 	struct net_device_stats net_stats_prev;
 };
 
-#define MPSendPacketsHandler  MPSendPackets
-#define MP_FREE_SEND_PACKET_FUN(Adapter, pMpTcb) \
-	et131x_free_send_packet(Adapter, pMpTcb)
-#define MpSendPacketFun(Adapter, Packet) MpSendPacket(Adapter, Packet)
-
 #endif /* __ET131X_ADAPTER_H__ */

