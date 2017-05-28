From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 11/12] nfp: don't add ring size to index calculations
Date: Sat, 27 May 2017 17:34:10 -0700
Message-ID: <20170528003411.17603-12-jakub.kicinski@netronome.com>
References: <20170528003411.17603-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:36407 "EHLO
        mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750815AbdE1Aev (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 27 May 2017 20:34:51 -0400
Received: by mail-pf0-f180.google.com with SMTP id m17so32499869pfg.3
        for <netdev@vger.kernel.org>; Sat, 27 May 2017 17:34:50 -0700 (PDT)
In-Reply-To: <20170528003411.17603-1-jakub.kicinski@netronome.com>
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
