From: "Michael Chan" <mchan@broadcom.com>
Subject: [BNX2]: Fix link interrupt problem.
Date: Wed, 28 Mar 2007 13:57:18 -0800
Message-ID: <1175119038.7911.11.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4759 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753021AbXC1VNF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Mar 2007 17:13:05 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[BNX2]: Fix link interrupt problem.

bnx2_has_work()'s logic is flawed and can cause the driver to miss
a link event.  The fix is to compare the status block's attn_bits
and attn_bits_ack to determine if there is a link event.

Update version to 1.5.6.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index c12e5ea..d43fe28 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -54,8 +54,8 @@
 
 #define DRV_MODULE_NAME		"bnx2"
 #define PFX DRV_MODULE_NAME	": "
-#define DRV_MODULE_VERSION	"1.5.5"
-#define DRV_MODULE_RELDATE	"February 1, 2007"
+#define DRV_MODULE_VERSION	"1.5.6"
+#define DRV_MODULE_RELDATE	"March 28, 2007"
 
 #define RUN_AT(x) (jiffies + (x))
 
@@ -2033,8 +2033,8 @@ bnx2_has_work(struct bnx2 *bp)
 	    (sblk->status_tx_quick_consumer_index0 != bp->hw_tx_cons))
 		return 1;
 
-	if (((sblk->status_attn_bits & STATUS_ATTN_BITS_LINK_STATE) != 0) !=
-	    bp->link_up)
+	if ((sblk->status_attn_bits & STATUS_ATTN_BITS_LINK_STATE) !=
+	    (sblk->status_attn_bits_ack & STATUS_ATTN_BITS_LINK_STATE))
 		return 1;
 
 	return 0;


