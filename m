From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] cxgb4: do not call napi_hash_del()
Date: Wed, 16 Nov 2016 06:19:02 -0800
Message-ID: <1479305942.8455.179.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        Hariprasad S <hariprasad@chelsio.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:36386 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751522AbcKPOTE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2016 09:19:04 -0500
Received: by mail-pf0-f195.google.com with SMTP id c4so7386551pfb.3
        for <netdev@vger.kernel.org>; Wed, 16 Nov 2016 06:19:04 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Calling napi_hash_del() before netif_napi_del() is dangerous
if a synchronize_rcu() is not enforced before NAPI struct freeing.

Lets leave this detail to core networking stack and feel
more comfortable.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Hariprasad S <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/sge.c |    1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/sge.c b/drivers/net/ethernet/chelsio/cxgb4/sge.c
index 1e74fd6085df..e19a0ca8e5dd 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/sge.c
@@ -2951,7 +2951,6 @@ void free_rspq_fl(struct adapter *adap, struct sge_rspq *rq,
 		   rq->cntxt_id, fl_id, 0xffff);
 	dma_free_coherent(adap->pdev_dev, (rq->size + 1) * rq->iqe_len,
 			  rq->desc, rq->phys_addr);
-	napi_hash_del(&rq->napi);
 	netif_napi_del(&rq->napi);
 	rq->netdev = NULL;
 	rq->cntxt_id = rq->abs_id = 0;
