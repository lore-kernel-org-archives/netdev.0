From: Li Yang <leoli@freescale.com>
Subject: [PATCH] Revert "ucc_geth: returns NETDEV_TX_BUSY when BD ring is
 full"
Date: Mon, 19 Mar 2007 11:58:02 +0800
Message-ID: <45FE0A4A.20402@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, michael.barkowski@freescale.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw01.freescale.net ([192.88.158.102]:33313 "EHLO
	az33egw01.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965453AbXCSD4v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Mar 2007 23:56:51 -0400
Received: from az33smr01.freescale.net (az33smr01.freescale.net [10.64.34.199])
	by az33egw01.freescale.net (8.12.11/az33egw01) with ESMTP id l2J3uedD003755
	for <netdev@vger.kernel.org>; Sun, 18 Mar 2007 20:56:41 -0700 (MST)
Received: from zch01exm20.fsl.freescale.net (zch01exm20.ap.freescale.net [10.192.129.204])
	by az33smr01.freescale.net (8.13.1/8.13.0) with ESMTP id l2J3udvl021478
	for <netdev@vger.kernel.org>; Sun, 18 Mar 2007 22:56:40 -0500 (CDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This reverts commit 18babd38547a042a4bfd4154a014d1ad33373eb0.

Michael Barkowski points out that it's wrong, and I agree.  The
patch causes a problem rather than fixes one after another
patch "ucc_geth: Fix BD processing" was applied.  Before that
patch, current packet should be blocked.  However after the patch
current packet is ok and we only need to block next.

Reported-by: Michael Barkowski <michael.barkowski@freescale.com>
Signed-off-by: Li Yang <leoli@freescale.com>
---
Sorry for the mistake I made.

 drivers/net/ucc_geth.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index c2db49b..64e5bb4 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -3609,7 +3609,6 @@ static int ucc_geth_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (bd == ugeth->confBd[txQ]) {
 		if (!netif_queue_stopped(dev))
 			netif_stop_queue(dev);
-		return NETDEV_TX_BUSY;
 	}
 
 	ugeth->txBd[txQ] = bd;
@@ -3625,7 +3624,7 @@ static int ucc_geth_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	spin_unlock_irq(&ugeth->lock);
 
-	return NETDEV_TX_OK;
+	return 0;
 }
 
 static int ucc_geth_rx(struct ucc_geth_private *ugeth, u8 rxQ, int rx_work_limit)

