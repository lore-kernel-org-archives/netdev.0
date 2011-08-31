From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 5/8] tg3: Eliminate tg3_stop_fw() prototype
Date: Wed, 31 Aug 2011 14:44:51 -0700
Message-ID: <1314827094-29714-6-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2582 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932166Ab1HaRzb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Aug 2011 13:55:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch moves tg3_stop_fw() earlier in the file to eliminate its
prototype.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Benjamin Li <benli@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c |   34 ++++++++++++++++------------------
 1 files changed, 16 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index dab2aa7..333f370 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -1396,6 +1396,22 @@ static void tg3_ump_link_report(struct tg3 *tp)
 	tg3_generate_fw_event(tp);
 }
 
+/* tp->lock is held. */
+static void tg3_stop_fw(struct tg3 *tp)
+{
+	if (tg3_flag(tp, ENABLE_ASF) && !tg3_flag(tp, ENABLE_APE)) {
+		/* Wait for RX cpu to ACK the previous event. */
+		tg3_wait_for_event_ack(tp);
+
+		tg3_write_mem(tp, NIC_SRAM_FW_CMD_MBOX, FWCMD_NICDRV_PAUSE_FW);
+
+		tg3_generate_fw_event(tp);
+
+		/* Wait for RX cpu to ACK this event. */
+		tg3_wait_for_event_ack(tp);
+	}
+}
+
 static void tg3_link_report(struct tg3 *tp)
 {
 	if (!netif_carrier_ok(tp->dev)) {
@@ -7426,8 +7442,6 @@ static void tg3_restore_pci_state(struct tg3 *tp)
 	}
 }
 
-static void tg3_stop_fw(struct tg3 *);
-
 /* tp->lock is held. */
 static int tg3_chip_reset(struct tg3 *tp)
 {
@@ -7675,22 +7689,6 @@ static int tg3_chip_reset(struct tg3 *tp)
 }
 
 /* tp->lock is held. */
-static void tg3_stop_fw(struct tg3 *tp)
-{
-	if (tg3_flag(tp, ENABLE_ASF) && !tg3_flag(tp, ENABLE_APE)) {
-		/* Wait for RX cpu to ACK the previous event. */
-		tg3_wait_for_event_ack(tp);
-
-		tg3_write_mem(tp, NIC_SRAM_FW_CMD_MBOX, FWCMD_NICDRV_PAUSE_FW);
-
-		tg3_generate_fw_event(tp);
-
-		/* Wait for RX cpu to ACK this event. */
-		tg3_wait_for_event_ack(tp);
-	}
-}
-
-/* tp->lock is held. */
 static int tg3_halt(struct tg3 *tp, int kind, int silent)
 {
 	int err;
-- 
1.7.3.4
