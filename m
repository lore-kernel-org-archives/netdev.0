From: Hauke Mehrtens <hauke@hauke-m.de>
Subject: [PATCH 2/2] bgmac: activate irqs only if there is nothing to poll
Date: Sun, 18 Jan 2015 19:49:59 +0100
Message-ID: <1421606999-23692-3-git-send-email-hauke@hauke-m.de>
References: <1421606999-23692-1-git-send-email-hauke@hauke-m.de>
Cc: netdev@vger.kernel.org, Hauke Mehrtens <hauke@hauke-m.de>
To: zajec5@gmail.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from hauke-m.de ([5.39.93.123]:33046 "EHLO hauke-m.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750968AbbARSun (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 18 Jan 2015 13:50:43 -0500
In-Reply-To: <1421606999-23692-1-git-send-email-hauke@hauke-m.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IRQs should only get activated when there is nothing to poll in the
queue any more and to after every poll.

Signed-off-by: Hauke Mehrtens <hauke@hauke-m.de>
---
 drivers/net/ethernet/broadcom/bgmac.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/ethernet/broadcom/bgmac.c
index aa9f950..3007d95 100644
--- a/drivers/net/ethernet/broadcom/bgmac.c
+++ b/drivers/net/ethernet/broadcom/bgmac.c
@@ -1167,10 +1167,10 @@ static int bgmac_poll(struct napi_struct *napi, int weight)
 		bgmac->int_status = 0;
 	}
 
-	if (handled < weight)
+	if (handled < weight) {
 		napi_complete(napi);
-
-	bgmac_chip_intrs_on(bgmac);
+		bgmac_chip_intrs_on(bgmac);
+	}
 
 	return handled;
 }
-- 
1.9.1
