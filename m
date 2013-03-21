From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: [PATCH net-next 1/3] gianfar: Remove 'maybe-uninitialized' compile warning
Date: Thu, 21 Mar 2013 15:12:13 +0200
Message-ID: <1363871535-29612-1-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S. Miller" <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from co9ehsobe001.messaging.microsoft.com ([207.46.163.24]:3194 "EHLO
	co9outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755771Ab3CUNMY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Mar 2013 09:12:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Warning message:
warning: 'budget_per_q' may be used uninitialized in this function

budget_per_q won't be used uninitialized since the only time
it doesn't get initialized is when entering gfar_poll with
num_act_queues == 0, meaning rstat_rxf == 0, in which case
budget_per_q is not utilized (as it has no meaning).
Inititalize budget_per_q to 0 though to suppress this compile
warning.

Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>
---
(Sorry I didn't notice this (unexpected) warning before submitting
the patches that introduced 'budget_per_q'.)

 drivers/net/ethernet/freescale/gianfar.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index 49ce83b..37fbf67 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -2838,7 +2838,7 @@ static int gfar_poll(struct napi_struct *napi, int budget)
 	struct gfar_priv_tx_q *tx_queue = NULL;
 	struct gfar_priv_rx_q *rx_queue = NULL;
 	int work_done = 0, work_done_per_q = 0;
-	int i, budget_per_q;
+	int i, budget_per_q = 0;
 	int has_tx_work;
 	unsigned long rstat_rxf;
 	int num_act_queues;
-- 
1.7.11.3
