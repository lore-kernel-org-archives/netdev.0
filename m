From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 22/34]bnx2x: Free IRQ
Date: Wed, 14 Jan 2009 18:43:48 +0200
Message-ID: <1231951428.11301.143.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: "David Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2683 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1764026AbZANQot (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Jan 2009 11:44:49 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Error check could result with not freeing the IRQ

Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_main.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 967f4dc..6ce1388 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -6719,6 +6719,9 @@ static int bnx2x_nic_unload(struct bnx2x *bp, int unload_mode)
 		 (DRV_PULSE_ALWAYS_ALIVE | bp->fw_drv_pulse_wr_seq));
 	bnx2x_stats_handle(bp, STATS_EVENT_STOP);
 
+	/* Release IRQs */
+	bnx2x_free_irq(bp);
+
 	/* Wait until tx fast path tasks complete */
 	for_each_queue(bp, i) {
 		struct bnx2x_fastpath *fp = &bp->fp[i];
@@ -6746,9 +6749,6 @@ static int bnx2x_nic_unload(struct bnx2x *bp, int unload_mode)
 	/* Give HW time to discard old tx messages */
 	msleep(1);
 
-	/* Release IRQs */
-	bnx2x_free_irq(bp);
-
 	if (CHIP_IS_E1(bp)) {
 		struct mac_configuration_cmd *config =
 						bnx2x_sp(bp, mcast_config);
-- 
1.5.4.3




