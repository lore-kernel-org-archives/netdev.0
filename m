From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 4/6] cxgb4: Add device node to ULD info
Date: Mon,  4 May 2015 21:58:18 +0530
Message-ID: <1430756900-6086-5-git-send-email-hariprasad@chelsio.com>
References: <1430756900-6086-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:7938 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752386AbbEDLQb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2015 07:16:31 -0400
In-Reply-To: <1430756900-6086-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adds device node to ULD info. Use the node info to alloc_ring() for ctrl
TX queues

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c | 1 +
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h  | 1 +
 drivers/net/ethernet/chelsio/cxgb4/sge.c        | 2 +-
 3 files changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 83cfded..21a7d3e 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -2434,6 +2434,7 @@ static void uld_attach(struct adapter *adap, unsigned int uld)
 	lli.max_ordird_qp = adap->params.max_ordird_qp;
 	lli.max_ird_adapter = adap->params.max_ird_adapter;
 	lli.ulptx_memwrite_dsgl = adap->params.ulptx_memwrite_dsgl;
+	lli.nodeid = dev_to_node(adap->pdev_dev);
 
 	handle = ulds[uld].add(&lli);
 	if (IS_ERR(handle)) {
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h
index 78ab4d4..df34293 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h
@@ -264,6 +264,7 @@ struct cxgb4_lld_info {
 	unsigned int max_ordird_qp;          /* Max ORD/IRD depth per RDMA QP */
 	unsigned int max_ird_adapter;        /* Max IRD memory per adapter */
 	bool ulptx_memwrite_dsgl;            /* use of T5 DSGL allowed */
+	int nodeid;			     /* device numa node id */
 };
 
 struct cxgb4_uld_info {
diff --git a/drivers/net/ethernet/chelsio/cxgb4/sge.c b/drivers/net/ethernet/chelsio/cxgb4/sge.c
index 757e0ab..9d6b93d 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/sge.c
@@ -2691,7 +2691,7 @@ int t4_sge_alloc_ctrl_txq(struct adapter *adap, struct sge_ctrl_txq *txq,
 
 	txq->q.desc = alloc_ring(adap->pdev_dev, nentries,
 				 sizeof(struct tx_desc), 0, &txq->q.phys_addr,
-				 NULL, 0, NUMA_NO_NODE);
+				 NULL, 0, dev_to_node(adap->pdev_dev));
 	if (!txq->q.desc)
 		return -ENOMEM;
 
-- 
2.3.4
