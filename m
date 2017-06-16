From: Ganesh Goudar <ganeshgr@chelsio.com>
Subject: [PATCH net-next] cxgb4: fix a NULL dereference
Date: Fri, 16 Jun 2017 15:36:09 +0530
Message-ID: <1497607569-7273-1-git-send-email-ganeshgr@chelsio.com>
Cc: nirranjan@chelsio.com, indranil@chelsio.com, venkatesh@chelsio.com,
        Ganesh Goudar <ganeshgr@chelsio.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:13653 "EHLO
        stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753296AbdFPKN0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Jun 2017 06:13:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Avoid NULL dereference in setup_sge_queues() when the adapter is
in non offload mode.

Fixes: 0fbc81b3ad51 ('chcr/cxgb4i/cxgbit/RDMA/cxgb4: Allocate resources dynamically for all cxgb4 ULD's')
Signed-off-by: Ganesh Goudar <ganeshgr@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 2c6de76..19a06f9 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -824,9 +824,12 @@ static int setup_sge_queues(struct adapter *adap)
 {
 	int err, i, j;
 	struct sge *s = &adap->sge;
-	struct sge_uld_rxq_info *rxq_info = s->uld_rxq_info[CXGB4_ULD_RDMA];
+	struct sge_uld_rxq_info *rxq_info = NULL;
 	unsigned int cmplqid = 0;
 
+	if (is_uld(adap))
+		rxq_info = s->uld_rxq_info[CXGB4_ULD_RDMA];
+
 	for_each_port(adap, i) {
 		struct net_device *dev = adap->port[i];
 		struct port_info *pi = netdev_priv(dev);
-- 
2.1.0
