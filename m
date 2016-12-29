From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 02/14] bnxt_en: Use napi_complete_done()
Date: Thu, 29 Dec 2016 12:13:32 -0500
Message-ID: <1483031624-20076-3-git-send-email-michael.chan@broadcom.com>
References: <1483031624-20076-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f48.google.com ([74.125.83.48]:34281 "EHLO
        mail-pg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752839AbcL2ROB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Dec 2016 12:14:01 -0500
Received: by mail-pg0-f48.google.com with SMTP id y62so116419587pgy.1
        for <netdev@vger.kernel.org>; Thu, 29 Dec 2016 09:14:01 -0800 (PST)
In-Reply-To: <1483031624-20076-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For better busy polling and GRO support.  Do not re-arm IRQ if
napi_complete_done() returns false.

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index b53f958..3fbc842 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -1778,8 +1778,9 @@ static int bnxt_poll(struct napi_struct *napi, int budget)
 			break;
 
 		if (!bnxt_has_work(bp, cpr)) {
-			napi_complete(napi);
-			BNXT_CP_DB_REARM(cpr->cp_doorbell, cpr->cp_raw_cons);
+			if (napi_complete_done(napi, work_done))
+				BNXT_CP_DB_REARM(cpr->cp_doorbell,
+						 cpr->cp_raw_cons);
 			break;
 		}
 	}
-- 
1.8.3.1
