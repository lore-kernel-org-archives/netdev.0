From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 01/14] nfp: simplify nfp_net_poll()
Date: Mon, 31 Oct 2016 20:43:09 +0000
Message-ID: <1477946602-19644-2-git-send-email-jakub.kicinski@netronome.com>
References: <1477946602-19644-1-git-send-email-jakub.kicinski@netronome.com>
Cc: Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f52.google.com ([74.125.82.52]:36003 "EHLO
        mail-wm0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1030392AbcJaUn6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Oct 2016 16:43:58 -0400
Received: by mail-wm0-f52.google.com with SMTP id p190so170352610wmp.1
        for <netdev@vger.kernel.org>; Mon, 31 Oct 2016 13:43:58 -0700 (PDT)
In-Reply-To: <1477946602-19644-1-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are few variables in nfp_net_poll() which are used only
once or unused but set.  Remove them.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net_common.c | 12 +++---------
 1 file changed, 3 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index d365760fa75b..f6a42c14a1f0 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -1525,21 +1525,15 @@ static int nfp_net_poll(struct napi_struct *napi, int budget)
 {
 	struct nfp_net_r_vector *r_vec =
 		container_of(napi, struct nfp_net_r_vector, napi);
-	struct nfp_net_rx_ring *rx_ring = r_vec->rx_ring;
-	struct nfp_net_tx_ring *tx_ring = r_vec->tx_ring;
-	struct nfp_net *nn = r_vec->nfp_net;
-	struct netdev_queue *txq;
 	unsigned int pkts_polled;
 
-	tx_ring = &nn->tx_rings[rx_ring->idx];
-	txq = netdev_get_tx_queue(nn->netdev, tx_ring->idx);
-	nfp_net_tx_complete(tx_ring);
+	nfp_net_tx_complete(r_vec->tx_ring);
 
-	pkts_polled = nfp_net_rx(rx_ring, budget);
+	pkts_polled = nfp_net_rx(r_vec->rx_ring, budget);
 
 	if (pkts_polled < budget) {
 		napi_complete_done(napi, pkts_polled);
-		nfp_net_irq_unmask(nn, r_vec->irq_idx);
+		nfp_net_irq_unmask(r_vec->nfp_net, r_vec->irq_idx);
 	}
 
 	return pkts_polled;
-- 
1.9.1
