From: Baoyou Xie <baoyou.xie@linaro.org>
Subject: [PATCH] cxgb4: mark symbols static where possible
Date: Sun, 18 Sep 2016 17:18:23 +0800
Message-ID: <1474190303-14976-1-git-send-email-baoyou.xie@linaro.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        arnd@arndb.de, baoyou.xie@linaro.org, xie.baoyou@zte.com.cn
To: hariprasad@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:35570 "EHLO
        mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754235AbcIRJSh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 18 Sep 2016 05:18:37 -0400
Received: by mail-pa0-f49.google.com with SMTP id oz2so34489024pac.2
        for <netdev@vger.kernel.org>; Sun, 18 Sep 2016 02:18:37 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We get a few warnings when building kernel with W=1:
drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.c:178:5: warning: no previous prototype for 'setup_sge_queues_uld' [-Wmissing-prototypes]
drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.c:205:6: warning: no previous prototype for 'free_sge_queues_uld' [-Wmissing-prototypes]
....

In fact, these functions are only used in the file in which they are
declared and don't need a declaration, but can be made static.
so this patch marks these functions with 'static'.

Signed-off-by: Baoyou Xie <baoyou.xie@linaro.org>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.c | 23 +++++++++++++----------
 1 file changed, 13 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.c
index 5d402ba..fb40ddb 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.c
@@ -175,7 +175,8 @@ freeout:
 	return err;
 }
 
-int setup_sge_queues_uld(struct adapter *adap, unsigned int uld_type, bool lro)
+static int
+setup_sge_queues_uld(struct adapter *adap, unsigned int uld_type, bool lro)
 {
 	struct sge_uld_rxq_info *rxq_info = adap->sge.uld_rxq_info[uld_type];
 
@@ -202,7 +203,7 @@ static void t4_free_uld_rxqs(struct adapter *adap, int n,
 	}
 }
 
-void free_sge_queues_uld(struct adapter *adap, unsigned int uld_type)
+static void free_sge_queues_uld(struct adapter *adap, unsigned int uld_type)
 {
 	struct sge_uld_rxq_info *rxq_info = adap->sge.uld_rxq_info[uld_type];
 
@@ -214,8 +215,8 @@ void free_sge_queues_uld(struct adapter *adap, unsigned int uld_type)
 		kfree(rxq_info->msix_tbl);
 }
 
-int cfg_queues_uld(struct adapter *adap, unsigned int uld_type,
-		   const struct cxgb4_pci_uld_info *uld_info)
+static int cfg_queues_uld(struct adapter *adap, unsigned int uld_type,
+			  const struct cxgb4_pci_uld_info *uld_info)
 {
 	struct sge *s = &adap->sge;
 	struct sge_uld_rxq_info *rxq_info;
@@ -273,7 +274,7 @@ int cfg_queues_uld(struct adapter *adap, unsigned int uld_type,
 	return 0;
 }
 
-void free_queues_uld(struct adapter *adap, unsigned int uld_type)
+static void free_queues_uld(struct adapter *adap, unsigned int uld_type)
 {
 	struct sge_uld_rxq_info *rxq_info = adap->sge.uld_rxq_info[uld_type];
 
@@ -282,7 +283,8 @@ void free_queues_uld(struct adapter *adap, unsigned int uld_type)
 	kfree(rxq_info);
 }
 
-int request_msix_queue_irqs_uld(struct adapter *adap, unsigned int uld_type)
+static int
+request_msix_queue_irqs_uld(struct adapter *adap, unsigned int uld_type)
 {
 	struct sge_uld_rxq_info *rxq_info = adap->sge.uld_rxq_info[uld_type];
 	int idx, bmap_idx, err = 0;
@@ -307,7 +309,8 @@ unwind:
 	return err;
 }
 
-void free_msix_queue_irqs_uld(struct adapter *adap, unsigned int uld_type)
+static void
+free_msix_queue_irqs_uld(struct adapter *adap, unsigned int uld_type)
 {
 	struct sge_uld_rxq_info *rxq_info = adap->sge.uld_rxq_info[uld_type];
 	int idx;
@@ -321,7 +324,7 @@ void free_msix_queue_irqs_uld(struct adapter *adap, unsigned int uld_type)
 	}
 }
 
-void name_msix_vecs_uld(struct adapter *adap, unsigned int uld_type)
+static void name_msix_vecs_uld(struct adapter *adap, unsigned int uld_type)
 {
 	struct sge_uld_rxq_info *rxq_info = adap->sge.uld_rxq_info[uld_type];
 	int n = sizeof(adap->msix_info_ulds[0].desc);
@@ -361,7 +364,7 @@ static void quiesce_rx(struct adapter *adap, struct sge_rspq *q)
 	}
 }
 
-void enable_rx_uld(struct adapter *adap, unsigned int uld_type)
+static void enable_rx_uld(struct adapter *adap, unsigned int uld_type)
 {
 	struct sge_uld_rxq_info *rxq_info = adap->sge.uld_rxq_info[uld_type];
 	int idx;
@@ -370,7 +373,7 @@ void enable_rx_uld(struct adapter *adap, unsigned int uld_type)
 		enable_rx(adap, &rxq_info->uldrxq[idx].rspq);
 }
 
-void quiesce_rx_uld(struct adapter *adap, unsigned int uld_type)
+static void quiesce_rx_uld(struct adapter *adap, unsigned int uld_type)
 {
 	struct sge_uld_rxq_info *rxq_info = adap->sge.uld_rxq_info[uld_type];
 	int idx;
-- 
2.7.4
