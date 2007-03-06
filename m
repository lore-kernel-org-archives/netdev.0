From: Li Yang <leoli@freescale.com>
Subject: [Patch 3/3] ucc_geth: suppress compile warnings
Date: Tue, 06 Mar 2007 16:54:12 +0800
Message-ID: <45ED2C34.5060901@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw02.freescale.net ([192.88.165.103]:47479 "EHLO
	de01egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933091AbXCFIww (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Mar 2007 03:52:52 -0500
Received: from de01smr01.freescale.net (de01smr01.freescale.net [10.208.0.31])
	by de01egw02.freescale.net (8.12.11/de01egw02) with ESMTP id l268qnXE000080
	for <netdev@vger.kernel.org>; Tue, 6 Mar 2007 01:52:50 -0700 (MST)
Received: from zch01exm20.fsl.freescale.net (zch01exm20.ap.freescale.net [10.192.129.204])
	by de01smr01.freescale.net (8.13.1/8.13.0) with ESMTP id l268qmfZ028989
	for <netdev@vger.kernel.org>; Tue, 6 Mar 2007 02:52:49 -0600 (CST)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add casts to suppress warnings introduced by kmalloc cast cleanup patch.

Signed-off-by: Li Yang <leoli@freescale.com>
---
 drivers/net/ucc_geth.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index dab88b9..c2db49b 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -2804,7 +2804,8 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 			if (UCC_GETH_TX_BD_RING_ALIGNMENT > 4)
 				align = UCC_GETH_TX_BD_RING_ALIGNMENT;
 			ugeth->tx_bd_ring_offset[j] =
-				kmalloc((u32) (length + align), GFP_KERNEL);
+				(u32)kmalloc((u32) (length + align),
+					     GFP_KERNEL);
 
 			if (ugeth->tx_bd_ring_offset[j] != 0)
 				ugeth->p_tx_bd_ring[j] =
@@ -2840,7 +2841,8 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 			if (UCC_GETH_RX_BD_RING_ALIGNMENT > 4)
 				align = UCC_GETH_RX_BD_RING_ALIGNMENT;
 			ugeth->rx_bd_ring_offset[j] =
-				kmalloc((u32) (length + align), GFP_KERNEL);
+				(u32)kmalloc((u32) (length + align),
+					     GFP_KERNEL);
 			if (ugeth->rx_bd_ring_offset[j] != 0)
 				ugeth->p_rx_bd_ring[j] =
 					(void*)((ugeth->rx_bd_ring_offset[j] +

