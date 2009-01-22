From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 1/4]bnx2x: Calling napi_del
Date: Thu, 22 Jan 2009 18:01:25 +0200
Message-ID: <1232640085.29087.51.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Harvey Harrison" <harvey.harrison@gmail.com>,
	"Yitchak Gertner" <gertner@broadcom.com>, netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4815 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752895AbZAVQCb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jan 2009 11:02:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

rmmod might hang without this patch since the reference counter is not going
down

Signed-off-by: Yitchak Gertner <gertner@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_main.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index fbd7165..71fbf2d 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -6547,6 +6547,8 @@ load_error2:
 	bnx2x_free_irq(bp);
 load_error1:
 	bnx2x_napi_disable(bp);
+	for_each_queue(bp, i)
+		netif_napi_del(&bnx2x_fp(bp, i, napi));
 	bnx2x_free_mem(bp);
 
 	/* TBD we really need to reset the chip
@@ -6855,6 +6857,8 @@ unload_error:
 	bnx2x_free_skbs(bp);
 	for_each_queue(bp, i)
 		bnx2x_free_rx_sge_range(bp, bp->fp + i, NUM_RX_SGE);
+	for_each_queue(bp, i)
+		netif_napi_del(&bnx2x_fp(bp, i, napi));
 	bnx2x_free_mem(bp);
 
 	bp->state = BNX2X_STATE_CLOSED;
@@ -10481,6 +10485,8 @@ static int bnx2x_eeh_nic_unload(struct bnx2x *bp)
 	bnx2x_free_skbs(bp);
 	for_each_queue(bp, i)
 		bnx2x_free_rx_sge_range(bp, bp->fp + i, NUM_RX_SGE);
+	for_each_queue(bp, i)
+		netif_napi_del(&bnx2x_fp(bp, i, napi));
 	bnx2x_free_mem(bp);
 
 	bp->state = BNX2X_STATE_CLOSED;
-- 
1.5.4.3




