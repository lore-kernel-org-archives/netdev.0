From: Li Yang <leoli@freescale.com>
Subject: [Patch 2/3] ucc_geth: returns NETDEV_TX_BUSY when BD ring is full
Date: Tue, 06 Mar 2007 16:54:05 +0800
Message-ID: <45ED2C2D.9050403@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw02.freescale.net ([192.88.165.103]:47464 "EHLO
	de01egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933097AbXCFIwr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Mar 2007 03:52:47 -0500
Received: from de01smr02.am.mot.com (de01smr02.freescale.net [10.208.0.151])
	by de01egw02.freescale.net (8.12.11/de01egw02) with ESMTP id l268qiYG000059
	for <netdev@vger.kernel.org>; Tue, 6 Mar 2007 01:52:45 -0700 (MST)
Received: from zch01exm20.fsl.freescale.net (zch01exm20.ap.freescale.net [10.192.129.204])
	by de01smr02.am.mot.com (8.13.1/8.13.0) with ESMTP id l268qfOZ023769
	for <netdev@vger.kernel.org>; Tue, 6 Mar 2007 02:52:42 -0600 (CST)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Returns NETDEV_TX_BUSY when BD ring is full.

Signed-off-by: Li Yang <leoli@freescale.com>
---
 drivers/net/ucc_geth.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index 639e1e6..dab88b9 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -3607,6 +3607,7 @@ static int ucc_geth_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (bd == ugeth->confBd[txQ]) {
 		if (!netif_queue_stopped(dev))
 			netif_stop_queue(dev);
+		return NETDEV_TX_BUSY;
 	}
 
 	ugeth->txBd[txQ] = bd;
@@ -3622,7 +3623,7 @@ static int ucc_geth_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	spin_unlock_irq(&ugeth->lock);
 
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 static int ucc_geth_rx(struct ucc_geth_private *ugeth, u8 rxQ, int rx_work_limit)

