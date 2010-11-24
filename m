From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 05/10] tg3: Reorg tg3_napi members
Date: Wed, 24 Nov 2010 10:31:49 -0800
Message-ID: <1290623514-18193-6-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4209 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751691Ab0KXScJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Nov 2010 13:32:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch reorders and realigns the tg3_napi members for a ~3-4%
performance improvement on small packet performance tests.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.h |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index 4107036..2938d18 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -2715,17 +2715,17 @@ struct tg3_napi {
 	u32				last_irq_tag;
 	u32				int_mbox;
 	u32				coal_now;
-	u32				tx_prod;
-	u32				tx_cons;
-	u32				tx_pending;
-	u32				prodmbox;
 
-	u32				consmbox;
+	u32				consmbox ____cacheline_aligned;
 	u32				rx_rcb_ptr;
 	u16				*rx_rcb_prod_idx;
 	struct tg3_rx_prodring_set	prodring;
-
 	struct tg3_rx_buffer_desc	*rx_rcb;
+
+	u32				tx_prod	____cacheline_aligned;
+	u32				tx_cons;
+	u32				tx_pending;
+	u32				prodmbox;
 	struct tg3_tx_buffer_desc	*tx_ring;
 	struct ring_info		*tx_buffers;
 
-- 
1.7.2.2


