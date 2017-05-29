From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next v2 12/13] nfp: don't add ring size to index calculations
Date: Sun, 28 May 2017 17:53:03 -0700
Message-ID: <20170529005304.20847-13-jakub.kicinski@netronome.com>
References: <20170529005304.20847-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f43.google.com ([74.125.83.43]:35949 "EHLO
        mail-pg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750995AbdE2Ayn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 28 May 2017 20:54:43 -0400
Received: by mail-pg0-f43.google.com with SMTP id x64so15377796pgd.3
        for <netdev@vger.kernel.org>; Sun, 28 May 2017 17:54:43 -0700 (PDT)
In-Reply-To: <20170529005304.20847-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adding ring size to index calculation is pointless, since index
will be masked with ring size - 1.

Suggested-by: David Laight <David.Laight@ACULAB.COM>
Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net_common.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index 9312a737fbc9..68013d048e9d 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -928,7 +928,7 @@ static void nfp_net_tx_complete(struct nfp_net_tx_ring *tx_ring)
 	if (qcp_rd_p == tx_ring->qcp_rd_p)
 		return;
 
-	todo = D_IDX(tx_ring, qcp_rd_p + tx_ring->cnt - tx_ring->qcp_rd_p);
+	todo = D_IDX(tx_ring, qcp_rd_p - tx_ring->qcp_rd_p);
 
 	while (todo--) {
 		idx = D_IDX(tx_ring, tx_ring->rd_p++);
@@ -999,7 +999,7 @@ static bool nfp_net_xdp_complete(struct nfp_net_tx_ring *tx_ring)
 	if (qcp_rd_p == tx_ring->qcp_rd_p)
 		return true;
 
-	todo = D_IDX(tx_ring, qcp_rd_p + tx_ring->cnt - tx_ring->qcp_rd_p);
+	todo = D_IDX(tx_ring, qcp_rd_p - tx_ring->qcp_rd_p);
 
 	done_all = todo <= NFP_NET_XDP_MAX_COMPLETE;
 	todo = min(todo, NFP_NET_XDP_MAX_COMPLETE);
-- 
2.11.0
