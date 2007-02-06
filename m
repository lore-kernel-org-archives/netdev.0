From: Li Yang <leoli@freescale.com>
Subject: [PATCH 1/4] ucc_geth: Change private immrbar_virt_to_phys to generic
 iopa
Date: Tue, 06 Feb 2007 19:31:33 +0800
Message-ID: <45C86715.6090600@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw01.freescale.net ([192.88.158.102]:38433 "EHLO
	az33egw01.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751400AbXBFLaY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Feb 2007 06:30:24 -0500
Received: from az33smr02.freescale.net (az33smr02.freescale.net [10.64.34.200])
	by az33egw01.freescale.net (8.12.11/az33egw01) with ESMTP id l16BUK4q007363
	for <netdev@vger.kernel.org>; Tue, 6 Feb 2007 04:30:21 -0700 (MST)
Received: from zch01exm20.fsl.freescale.net (zch01exm20.ap.freescale.net [10.192.129.204])
	by az33smr02.freescale.net (8.13.1/8.13.0) with ESMTP id l16BUIb7020578
	for <netdev@vger.kernel.org>; Tue, 6 Feb 2007 05:30:19 -0600 (CST)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Get rid of private immrbar_virt_to_phys() routine and
use generic iopa().

Signed-off-by: Li Yang <leoli@freescale.com>
---
 drivers/net/ucc_geth.c |   29 ++++++-----------------------
 1 files changed, 6 insertions(+), 23 deletions(-)

diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index 7e4b23c..722a89f 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -3065,21 +3065,11 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 		endOfRing =
 		    ugeth->p_tx_bd_ring[i] + (ug_info->bdRingLenTx[i] -
 					      1) * sizeof(struct qe_bd);
-		if (ugeth->ug_info->uf_info.bd_mem_part == MEM_PART_SYSTEM) {
-			out_be32(&ugeth->p_send_q_mem_reg->sqqd[i].bd_ring_base,
-				 (u32) virt_to_phys(ugeth->p_tx_bd_ring[i]));
-			out_be32(&ugeth->p_send_q_mem_reg->sqqd[i].
+		out_be32(&ugeth->p_send_q_mem_reg->sqqd[i].bd_ring_base,
+				iopa((unsigned long)ugeth->p_tx_bd_ring[i]));
+		out_be32(&ugeth->p_send_q_mem_reg->sqqd[i].
 				 last_bd_completed_address,
-				 (u32) virt_to_phys(endOfRing));
-		} else if (ugeth->ug_info->uf_info.bd_mem_part ==
-			   MEM_PART_MURAM) {
-			out_be32(&ugeth->p_send_q_mem_reg->sqqd[i].bd_ring_base,
-				 (u32) immrbar_virt_to_phys(ugeth->
-							    p_tx_bd_ring[i]));
-			out_be32(&ugeth->p_send_q_mem_reg->sqqd[i].
-				 last_bd_completed_address,
-				 (u32) immrbar_virt_to_phys(endOfRing));
-		}
+				iopa((unsigned long)endOfRing));
 	}
 
 	/* schedulerbasepointer */
@@ -3331,15 +3321,8 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 	/* Setup the table */
 	/* Assume BD rings are already established */
 	for (i = 0; i < ug_info->numQueuesRx; i++) {
-		if (ugeth->ug_info->uf_info.bd_mem_part == MEM_PART_SYSTEM) {
-			out_be32(&ugeth->p_rx_bd_qs_tbl[i].externalbdbaseptr,
-				 (u32) virt_to_phys(ugeth->p_rx_bd_ring[i]));
-		} else if (ugeth->ug_info->uf_info.bd_mem_part ==
-			   MEM_PART_MURAM) {
-			out_be32(&ugeth->p_rx_bd_qs_tbl[i].externalbdbaseptr,
-				 (u32) immrbar_virt_to_phys(ugeth->
-							    p_rx_bd_ring[i]));
-		}
+		out_be32(&ugeth->p_rx_bd_qs_tbl[i].externalbdbaseptr,
+			 iopa((unsigned long)ugeth->p_rx_bd_ring[i]));
 		/* rest of fields handled by QE */
 	}

