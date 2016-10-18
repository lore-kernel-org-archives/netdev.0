From: Ganesh Goudar <ganeshgr@chelsio.com>
Subject: [PATCH] cxgb4: Fix number of queue sets corssing the limit
Date: Tue, 18 Oct 2016 14:21:25 +0530
Message-ID: <1476780685-31363-1-git-send-email-ganeshgr@chelsio.com>
Cc: netdev@vger.kernel.org, linteam@chelsio.com,
        hariprasad@chelsio.com, nirranjan@chelsio.com,
        Ganesh Goudar <ganeshgr@chelsio.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:59198 "EHLO
        stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757838AbcJRIwY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Oct 2016 04:52:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Do not let number of offload queue sets to go more than
MAX_OFLD_QSETS, which would otherwise crash the driver
on machines with cores more than MAX_OFLD_QSETS.

Signed-off-by: Ganesh Goudar <ganeshgr@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index f320497..57eb4e1 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -4057,7 +4057,7 @@ static void cfg_queues(struct adapter *adap)
 		 * capped by the number of available cores.
 		 */
 		if (n10g) {
-			i = num_online_cpus();
+			i = min_t(int, MAX_OFLD_QSETS, num_online_cpus());
 			s->ofldqsets = roundup(i, adap->params.nports);
 		} else {
 			s->ofldqsets = adap->params.nports;
-- 
2.1.0
