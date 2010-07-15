From: Casey Leedom <leedom@chelsio.com>
Subject: [PATCH] cxgb4vf: fix SGE resource resource deallocation bug
Date: Thu, 15 Jul 2010 15:54:43 -0700
Message-ID: <201007151554.43269.leedom@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:18097 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933621Ab0GOW5W convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jul 2010 18:57:22 -0400
Received: from maui.asicdesigners.com (maui.asicdesigners.com [10.192.180.15])
	by stargate.chelsio.com (8.13.1/8.13.1) with SMTP id o6FMvMFr002985
	for <netdev@vger.kernel.org>; Thu, 15 Jul 2010 15:57:22 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From 1ecf246196c43d75e75525211450a64d650f4fbc Mon Sep 17 00:00:00 2001
From: Casey Leedom <leedom@chelsio.com>
Date: Thu, 15 Jul 2010 15:50:16 -0700
Subject: [PATCH] cxgb4vf: fix SGE resource resource deallocation bug

Fix SGE resource resource deallocation bug.  Forgot to increment the RXQ and
TXQ cursors in the loop ...

Signed-off-by: Casey Leedom <leedom@chelsio.com>
---
 drivers/net/cxgb4vf/sge.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/cxgb4vf/sge.c b/drivers/net/cxgb4vf/sge.c
index f2ee9b0..eb5a1c9 100644
--- a/drivers/net/cxgb4vf/sge.c
+++ b/drivers/net/cxgb4vf/sge.c
@@ -2351,7 +2351,7 @@ void t4vf_free_sge_resources(struct adapter *adapter)
 	struct sge_rspq *intrq = &s->intrq;
 	int qs;
 
-	for (qs = 0; qs < adapter->sge.ethqsets; qs++) {
+	for (qs = 0; qs < adapter->sge.ethqsets; qs++, rxq++, txq++) {
 		if (rxq->rspq.desc)
 			free_rspq_fl(adapter, &rxq->rspq, &rxq->fl);
 		if (txq->q.desc) {
-- 
1.7.0.4

