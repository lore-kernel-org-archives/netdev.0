From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 2/6] bnxt: fix unused variable warnings
Date: Mon, 24 Jul 2017 10:25:19 -0700
Message-ID: <20170724172523.13135-3-sthemmin@microsoft.com>
References: <20170724172523.13135-1-sthemmin@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, linux-bluetooth@vger.kernel.org,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        Stephen Hemminger <sthemmin@microsoft.com>
To: marcel@holtmann.org, gustavo@padovan.org, johan.hedberg@gmail.com,
        davem@davemloft.net, pablo@netfilter.org, kadlec@blackhole.kfki.hu,
        fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f42.google.com ([74.125.83.42]:37902 "EHLO
        mail-pg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754834AbdGXRZd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Jul 2017 13:25:33 -0400
Received: by mail-pg0-f42.google.com with SMTP id s4so59743939pgr.5
        for <netdev@vger.kernel.org>; Mon, 24 Jul 2017 10:25:33 -0700 (PDT)
In-Reply-To: <20170724172523.13135-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix a couple of warnings where variable ‘txq’ set but not used

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index e7c8539cbddf..54b732de2850 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -5559,12 +5559,10 @@ void bnxt_tx_disable(struct bnxt *bp)
 {
 	int i;
 	struct bnxt_tx_ring_info *txr;
-	struct netdev_queue *txq;
 
 	if (bp->tx_ring) {
 		for (i = 0; i < bp->tx_nr_rings; i++) {
 			txr = &bp->tx_ring[i];
-			txq = netdev_get_tx_queue(bp->dev, i);
 			txr->dev_state = BNXT_DEV_STATE_CLOSING;
 		}
 	}
@@ -5577,11 +5575,9 @@ void bnxt_tx_enable(struct bnxt *bp)
 {
 	int i;
 	struct bnxt_tx_ring_info *txr;
-	struct netdev_queue *txq;
 
 	for (i = 0; i < bp->tx_nr_rings; i++) {
 		txr = &bp->tx_ring[i];
-		txq = netdev_get_tx_queue(bp->dev, i);
 		txr->dev_state = 0;
 	}
 	netif_tx_wake_all_queues(bp->dev);
-- 
2.11.0
