From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCHv2 net-next 3/4] cxgb4: Use the node info to alloc_ring() for RX queues
Date: Wed, 23 Dec 2015 11:29:55 +0530
Message-ID: <1450850396-24141-4-git-send-email-hariprasad@chelsio.com>
References: <1450850396-24141-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:20693 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752514AbbLWF6e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Dec 2015 00:58:34 -0500
In-Reply-To: <1450850396-24141-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/sge.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/sge.c b/drivers/net/ethernet/chelsio/cxgb4/sge.c
index 0333435..138be46 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/sge.c
@@ -2555,7 +2555,8 @@ int t4_sge_alloc_rxq(struct adapter *adap, struct sge_rspq *iq, bool fwevtq,
 	iq->size = roundup(iq->size, 16);
 
 	iq->desc = alloc_ring(adap->pdev_dev, iq->size, iq->iqe_len, 0,
-			      &iq->phys_addr, NULL, 0, NUMA_NO_NODE);
+			      &iq->phys_addr, NULL, 0,
+			      dev_to_node(adap->pdev_dev));
 	if (!iq->desc)
 		return -ENOMEM;
 
@@ -2595,7 +2596,8 @@ int t4_sge_alloc_rxq(struct adapter *adap, struct sge_rspq *iq, bool fwevtq,
 		fl->size = roundup(fl->size, 8);
 		fl->desc = alloc_ring(adap->pdev_dev, fl->size, sizeof(__be64),
 				      sizeof(struct rx_sw_desc), &fl->addr,
-				      &fl->sdesc, s->stat_len, NUMA_NO_NODE);
+				      &fl->sdesc, s->stat_len,
+				      dev_to_node(adap->pdev_dev));
 		if (!fl->desc)
 			goto fl_nomem;
 
-- 
2.3.4
