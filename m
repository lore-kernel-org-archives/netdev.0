From: Michael Chan <mchan@broadcom.com>
Subject: [PATCH net-next 1/2] bnxt_en: Zero pad firmware messages to 128 bytes.
Date: Thu, 7 Jan 2016 19:56:57 -0500
Message-ID: <1452214618-15519-2-git-send-email-mchan@broadcom.com>
References: <1452214618-15519-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw3-out.broadcom.com ([216.31.210.64]:28237 "EHLO
	mail-gw3-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753498AbcAHA5A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2016 19:57:00 -0500
In-Reply-To: <1452214618-15519-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For future compatibility, zero pad all messages that the driver sends
to the firmware to 128 bytes.  If these messages are extended in the
future with new byte enables, zero padding these messages now will
guarantee future compatibility.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index f956949..287bfb7 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -2614,6 +2614,9 @@ int _hwrm_send_message(struct bnxt *bp, void *msg, u32 msg_len, int timeout)
 	/* Write request msg to hwrm channel */
 	__iowrite32_copy(bp->bar0, data, msg_len / 4);
 
+	for (i = msg_len; i < HWRM_MAX_REQ_LEN; i += 4)
+		writel(0, bp->bar0 + i);
+
 	/* currently supports only one outstanding message */
 	if (intr_process)
 		bp->hwrm_intr_seq_id = le32_to_cpu(req->target_id_seq_id) &
-- 
1.8.3.1
