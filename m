From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next v2 6/9] bnxt_en: Fix length value in dmesg log firmware error message.
Date: Sun, 15 May 2016 03:04:48 -0400
Message-ID: <1463295891-15216-7-git-send-email-michael.chan@broadcom.com>
References: <1463295891-15216-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:33634 "EHLO
	mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754115AbcEOHFN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 May 2016 03:05:13 -0400
Received: by mail-pf0-f171.google.com with SMTP id 206so56891458pfu.0
        for <netdev@vger.kernel.org>; Sun, 15 May 2016 00:05:13 -0700 (PDT)
In-Reply-To: <1463295891-15216-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The len value in the hwrm error message is wrong.  Use the properly adjusted
value in the variable len.

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index d33b20f..0a83fd8 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -2774,7 +2774,7 @@ static int bnxt_hwrm_do_send_msg(struct bnxt *bp, void *msg, u32 msg_len,
 		if (i >= tmo_count) {
 			netdev_err(bp->dev, "Error (timeout: %d) msg {0x%x 0x%x} len:%d\n",
 				   timeout, le16_to_cpu(req->req_type),
-				   le16_to_cpu(req->seq_id), *resp_len);
+				   le16_to_cpu(req->seq_id), len);
 			return -1;
 		}
 
-- 
1.8.3.1
