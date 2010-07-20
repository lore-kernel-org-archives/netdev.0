From: Casey Leedom <leedom@chelsio.com>
Subject: [PATCH net-next 2/3] cxgb4vf: Fix bug where we were only allocating one queue in MSI mode
Date: Tue, 20 Jul 2010 08:59:30 -0700
Message-ID: <201007200859.30269.leedom@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:1237 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752186Ab0GTQHM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jul 2010 12:07:12 -0400
Received: from maui.asicdesigners.com (maui.asicdesigners.com [10.192.180.15])
	by stargate.chelsio.com (8.13.1/8.13.1) with SMTP id o6KG7CLi017820
	for <netdev@vger.kernel.org>; Tue, 20 Jul 2010 09:07:12 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From 7e141cafe989958267803791aa1bcacfffe5cfb2 Mon Sep 17 00:00:00 2001
From: Casey Leedom <leedom@chelsio.com>
Date: Mon, 19 Jul 2010 17:53:48 -0700
Subject: [PATCH net-next 2/3] cxgb4vf: Fix bug where we were only allocating one queue in MSI mode

Fix bug in setup_sge_queues() where we were incorrectly only allocating a
single "Queue Set" for MSI mode.

Signed-off-by: Casey Leedom <leedom@chelsio.com>
---
 drivers/net/cxgb4vf/cxgb4vf_main.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/cxgb4vf/cxgb4vf_main.c b/drivers/net/cxgb4vf/cxgb4vf_main.c
index d065516..a165632 100644
--- a/drivers/net/cxgb4vf/cxgb4vf_main.c
+++ b/drivers/net/cxgb4vf/cxgb4vf_main.c
@@ -533,10 +533,9 @@ static int setup_sge_queues(struct adapter *adapter)
 		struct port_info *pi = netdev_priv(dev);
 		struct sge_eth_rxq *rxq = &s->ethrxq[pi->first_qset];
 		struct sge_eth_txq *txq = &s->ethtxq[pi->first_qset];
-		int nqsets = (adapter->flags & USING_MSIX) ? pi->nqsets : 1;
 		int qs;
 
-		for (qs = 0; qs < nqsets; qs++, rxq++, txq++) {
+		for (qs = 0; qs < pi->nqsets; qs++, rxq++, txq++) {
 			err = t4vf_sge_alloc_rxq(adapter, &rxq->rspq, false,
 						 dev, msix++,
 						 &rxq->fl, t4vf_ethrx_handler);
@@ -565,10 +564,9 @@ static int setup_sge_queues(struct adapter *adapter)
 		struct port_info *pi = netdev_priv(dev);
 		struct sge_eth_rxq *rxq = &s->ethrxq[pi->first_qset];
 		struct sge_eth_txq *txq = &s->ethtxq[pi->first_qset];
-		int nqsets = (adapter->flags & USING_MSIX) ? pi->nqsets : 1;
 		int qs;
 
-		for (qs = 0; qs < nqsets; qs++, rxq++, txq++) {
+		for (qs = 0; qs < pi->nqsets; qs++, rxq++, txq++) {
 			IQ_MAP(s, rxq->rspq.abs_id) = &rxq->rspq;
 			EQ_MAP(s, txq->q.abs_id) = &txq->q;
 
-- 
1.7.0.4

