From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next 1/2] bnxt_en: do not call napi_hash_add()
Date: Tue, 08 Nov 2016 11:06:53 -0800
Message-ID: <1478632013.17367.23.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        Michael Chan <michael.chan@broadcom.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:36470 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751865AbcKHTGz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 8 Nov 2016 14:06:55 -0500
Received: by mail-pf0-f194.google.com with SMTP id n85so20522244pfi.3
        for <netdev@vger.kernel.org>; Tue, 08 Nov 2016 11:06:55 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

This is automatically done from netif_napi_add(), and we want to not
export napi_hash_add() anymore in the following patch.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c |    1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index a042da1ff4b90e9aae4f76db71c99c2c4da321d3..d313b02485a10b2b7995076578ce3632865b475f 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -4954,7 +4954,6 @@ static void bnxt_init_napi(struct bnxt *bp)
 			bnapi = bp->bnapi[cp_nr_rings];
 			netif_napi_add(bp->dev, &bnapi->napi,
 				       bnxt_poll_nitroa0, 64);
-			napi_hash_add(&bnapi->napi);
 		}
 	} else {
 		bnapi = bp->bnapi[0];
