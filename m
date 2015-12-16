From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next] nfp: clear ring delayed kick counters
Date: Wed, 16 Dec 2015 19:08:52 +0000
Message-ID: <1450292932-24393-1-git-send-email-jakub.kicinski@netronome.com>
Cc: simon.horman@netronome.com, rolf.neugebauer@netronome.com,
	Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f42.google.com ([74.125.82.42]:34952 "EHLO
	mail-wm0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751226AbbLPTI7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Dec 2015 14:08:59 -0500
Received: by mail-wm0-f42.google.com with SMTP id l126so53274311wml.0
        for <netdev@vger.kernel.org>; Wed, 16 Dec 2015 11:08:58 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We need to clear delayed kick counters when we free rings otherwise
after ndo_close()/ndo_open() we could kick HW by more entries than
actually written to rings.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Rolf Neugebauer <rolf.neugebauer@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net_common.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index 7060539d276a..6c5af4cb5bdc 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -1363,6 +1363,7 @@ static void nfp_net_tx_ring_free(struct nfp_net_tx_ring *tx_ring)
 	tx_ring->wr_p = 0;
 	tx_ring->rd_p = 0;
 	tx_ring->qcp_rd_p = 0;
+	tx_ring->wr_ptr_add = 0;
 
 	tx_ring->txbufs = NULL;
 	tx_ring->txds = NULL;
@@ -1437,6 +1438,7 @@ static void nfp_net_rx_ring_free(struct nfp_net_rx_ring *rx_ring)
 	rx_ring->cnt = 0;
 	rx_ring->wr_p = 0;
 	rx_ring->rd_p = 0;
+	rx_ring->wr_ptr_add = 0;
 
 	rx_ring->rxbufs = NULL;
 	rx_ring->rxds = NULL;
-- 
1.9.1
