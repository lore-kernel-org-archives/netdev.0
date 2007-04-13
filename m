From: Kim Phillips <kim.phillips@freescale.com>
Subject: [PATCH v2 4/7] ucc_geth: Fix interrupt coalescing size and
 alignment
Date: Fri, 13 Apr 2007 01:26:15 -0500
Message-ID: <20070413012615.3b6d6fce.kim.phillips@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw01.freescale.net ([192.88.165.102]:39498 "EHLO
	de01egw01.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752051AbXDMG1M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Apr 2007 02:27:12 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Michael Barkowski <michael.barkowski@freescale.com>

The rx interrupt coalescing table alignment was "guessed" to be 4,
but should be 64. The size should be 8 * number of queues + 4.
Verified in the MPC8323E manual.

Signed-off-by: Michael Barkowski <Michael.Barkowski@freescale.com>
Signed-off-by: Kim Phillips <kim.phillips@freescale.com>
---
 drivers/net/ucc_geth.c |    4 ++--
 drivers/net/ucc_geth.h |    3 +--
 2 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index 60be1e7..1a16ab2 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -2958,8 +2958,8 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 	/* Size varies with number of Rx queues */
 	ugeth->rx_irq_coalescing_tbl_offset =
 	    qe_muram_alloc(ug_info->numQueuesRx *
-			   sizeof(struct ucc_geth_rx_interrupt_coalescing_entry),
-			   UCC_GETH_RX_INTERRUPT_COALESCING_ALIGNMENT);
+			   sizeof(struct ucc_geth_rx_interrupt_coalescing_entry)
+			   + 4, UCC_GETH_RX_INTERRUPT_COALESCING_ALIGNMENT);
 	if (IS_MURAM_ERR(ugeth->rx_irq_coalescing_tbl_offset)) {
 		ugeth_err
 		    ("%s: Can not allocate DPRAM memory for"
diff --git a/drivers/net/ucc_geth.h b/drivers/net/ucc_geth.h
index 7cf3dbc..a29e1c3 100644
--- a/drivers/net/ucc_geth.h
+++ b/drivers/net/ucc_geth.h
@@ -867,8 +867,7 @@ struct ucc_geth_hardware_statistics {
 #define UCC_GETH_SCHEDULER_ALIGNMENT		4	/* This is a guess */
 #define UCC_GETH_TX_STATISTICS_ALIGNMENT	4	/* This is a guess */
 #define UCC_GETH_RX_STATISTICS_ALIGNMENT	4	/* This is a guess */
-#define UCC_GETH_RX_INTERRUPT_COALESCING_ALIGNMENT	4	/* This is a
-								   guess */
+#define UCC_GETH_RX_INTERRUPT_COALESCING_ALIGNMENT	64
 #define UCC_GETH_RX_BD_QUEUES_ALIGNMENT		8	/* This is a guess */
 #define UCC_GETH_RX_PREFETCHED_BDS_ALIGNMENT	128	/* This is a guess */
 #define UCC_GETH_RX_EXTENDED_FILTERING_GLOBAL_PARAMETERS_ALIGNMENT 4	/* This
-- 
1.5.0.1

