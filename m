From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net 3/3] nfp: don't pad frames on receive
Date: Wed,  7 Sep 2016 19:45:37 +0100
Message-ID: <1473273937-9230-4-git-send-email-jakub.kicinski@netronome.com>
References: <1473273937-9230-1-git-send-email-jakub.kicinski@netronome.com>
Cc: Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:35587 "EHLO
        mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751810AbcIGSqW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Sep 2016 14:46:22 -0400
Received: by mail-wm0-f47.google.com with SMTP id i204so101041217wma.0
        for <netdev@vger.kernel.org>; Wed, 07 Sep 2016 11:46:21 -0700 (PDT)
In-Reply-To: <1473273937-9230-1-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is no need to pad frames to ETH_ZLEN on RX.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Simon Horman <simon.horman@netronome.com>
Reviewed-by: Dinan Gunawardena <dinan.gunawardena@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net_common.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index e4fe0f080f34..252e4924de0f 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -1440,10 +1440,6 @@ static int nfp_net_rx(struct nfp_net_rx_ring *rx_ring, int budget)
 
 		nfp_net_set_hash(nn->netdev, skb, rxd);
 
-		/* Pad small frames to minimum */
-		if (skb_put_padto(skb, 60))
-			break;
-
 		/* Stats update */
 		u64_stats_update_begin(&r_vec->rx_sync);
 		r_vec->rx_pkts++;
-- 
1.9.1
