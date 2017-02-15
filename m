From: Ganesh Goudar <ganeshgr@chelsio.com>
Subject: [PATCH net-next] cxgb4: Update proper netdev stats for rx drops
Date: Wed, 15 Feb 2017 11:45:25 +0530
Message-ID: <1487139325-10588-1-git-send-email-ganeshgr@chelsio.com>
Cc: nirranjan@chelsio.com, Ganesh Goudar <ganeshgr@chelsio.com>,
        Arjun V <arjun@chelsio.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:23421 "EHLO
        stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750773AbdBOGP5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2017 01:15:57 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Count buffer group drops or truncates as rx drops rather than
rx errors in netdev stats.

Signed-off-by: Ganesh Goudar <ganeshgr@chelsio.com>
Signed-off-by: Arjun V <arjun@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index d75f77a..afb0967 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -2400,7 +2400,7 @@ static void cxgb_get_stats(struct net_device *dev,
 	ns->rx_over_errors   = 0;
 	ns->rx_crc_errors    = stats.rx_fcs_err;
 	ns->rx_frame_errors  = stats.rx_symbol_err;
-	ns->rx_fifo_errors   = stats.rx_ovflow0 + stats.rx_ovflow1 +
+	ns->rx_dropped	     = stats.rx_ovflow0 + stats.rx_ovflow1 +
 			       stats.rx_ovflow2 + stats.rx_ovflow3 +
 			       stats.rx_trunc0 + stats.rx_trunc1 +
 			       stats.rx_trunc2 + stats.rx_trunc3;
-- 
2.1.0
