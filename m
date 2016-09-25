From: Baoyou Xie <baoyou.xie@linaro.org>
Subject: [PATCH] cxgb4: mark symbols static where possible
Date: Sun, 25 Sep 2016 14:10:09 +0800
Message-ID: <1474783809-7615-1-git-send-email-baoyou.xie@linaro.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        arnd@arndb.de, baoyou.xie@linaro.org, xie.baoyou@zte.com.cn
To: hariprasad@chelsio.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We get 10 warnings when building kernel with W=1:
drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c:304:5: warning: no previous prototype for 'cxgb4_dcb_enabled' [-Wmissing-prototypes]
drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.c:194:5: warning: no previous prototype for 'setup_sge_queues_uld' [-Wmissing-prototypes]
drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.c:241:6: warning: no previous prototype for 'free_sge_queues_uld' [-Wmissing-prototypes]
drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.c:268:5: warning: no previous prototype for 'cfg_queues_uld' [-Wmissing-prototypes]
drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.c:344:6: warning: no previous prototype for 'free_queues_uld' [-Wmissing-prototypes]
drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.c:353:5: warning: no previous prototype for 'request_msix_queue_irqs_uld' [-Wmissing-prototypes]
drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.c:379:6: warning: no previous prototype for 'free_msix_queue_irqs_uld' [-Wmissing-prototypes]
drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.c:393:6: warning: no previous prototype for 'name_msix_vecs_uld' [-Wmissing-prototypes]
drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.c:433:6: warning: no previous prototype for 'enable_rx_uld' [-Wmissing-prototypes]
drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.c:442:6: warning: no previous prototype for 'quiesce_rx_uld' [-Wmissing-prototypes]

In fact, these functions are only used in the file in which they are
declared and don't need a declaration, but can be made static.
so this patch marks these functions with 'static'.

Signed-off-by: Baoyou Xie <baoyou.xie@linaro.org>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c |  2 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.c  | 23 +++++++++++++----------
 2 files changed, 14 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index d1ebb84..fc434ee 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -301,7 +301,7 @@ static void dcb_tx_queue_prio_enable(struct net_device *dev, int enable)
 }
 #endif /* CONFIG_CHELSIO_T4_DCB */
 
-int cxgb4_dcb_enabled(const struct net_device *dev)
+static int cxgb4_dcb_enabled(const struct net_device *dev)
 {
 #ifdef CONFIG_CHELSIO_T4_DCB
 	struct port_info *pi = netdev_priv(dev);
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.c
index d12a73e..a460c7c 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.c
@@ -191,7 +191,8 @@ static int alloc_uld_rxqs(struct adapter *adap,
 	return err;
 }
 
-int setup_sge_queues_uld(struct adapter *adap, unsigned int uld_type, bool lro)
+static int
+setup_sge_queues_uld(struct adapter *adap, unsigned int uld_type, bool lro)
 {
 	struct sge_uld_rxq_info *rxq_info = adap->sge.uld_rxq_info[uld_type];
 	int i, ret = 0;
@@ -238,7 +239,7 @@ static void t4_free_uld_rxqs(struct adapter *adap, int n,
 	}
 }
 
-void free_sge_queues_uld(struct adapter *adap, unsigned int uld_type)
+static void free_sge_queues_uld(struct adapter *adap, unsigned int uld_type)
 {
 	struct sge_uld_rxq_info *rxq_info = adap->sge.uld_rxq_info[uld_type];
 
@@ -265,8 +266,8 @@ void free_sge_queues_uld(struct adapter *adap, unsigned int uld_type)
 		kfree(rxq_info->msix_tbl);
 }
 
-int cfg_queues_uld(struct adapter *adap, unsigned int uld_type,
-		   const struct cxgb4_uld_info *uld_info)
+static int cfg_queues_uld(struct adapter *adap, unsigned int uld_type,
+			  const struct cxgb4_uld_info *uld_info)
 {
 	struct sge *s = &adap->sge;
 	struct sge_uld_rxq_info *rxq_info;
@@ -341,7 +342,7 @@ int cfg_queues_uld(struct adapter *adap, unsigned int uld_type,
 	return 0;
 }
 
-void free_queues_uld(struct adapter *adap, unsigned int uld_type)
+static void free_queues_uld(struct adapter *adap, unsigned int uld_type)
 {
 	struct sge_uld_rxq_info *rxq_info = adap->sge.uld_rxq_info[uld_type];
 
@@ -350,7 +351,8 @@ void free_queues_uld(struct adapter *adap, unsigned int uld_type)
 	kfree(rxq_info);
 }
 
-int request_msix_queue_irqs_uld(struct adapter *adap, unsigned int uld_type)
+static int
+request_msix_queue_irqs_uld(struct adapter *adap, unsigned int uld_type)
 {
 	struct sge_uld_rxq_info *rxq_info = adap->sge.uld_rxq_info[uld_type];
 	int err = 0;
@@ -376,7 +378,8 @@ int request_msix_queue_irqs_uld(struct adapter *adap, unsigned int uld_type)
 	return err;
 }
 
-void free_msix_queue_irqs_uld(struct adapter *adap, unsigned int uld_type)
+static void
+free_msix_queue_irqs_uld(struct adapter *adap, unsigned int uld_type)
 {
 	struct sge_uld_rxq_info *rxq_info = adap->sge.uld_rxq_info[uld_type];
 	unsigned int idx, bmap_idx;
@@ -390,7 +393,7 @@ void free_msix_queue_irqs_uld(struct adapter *adap, unsigned int uld_type)
 	}
 }
 
-void name_msix_vecs_uld(struct adapter *adap, unsigned int uld_type)
+static void name_msix_vecs_uld(struct adapter *adap, unsigned int uld_type)
 {
 	struct sge_uld_rxq_info *rxq_info = adap->sge.uld_rxq_info[uld_type];
 	int n = sizeof(adap->msix_info_ulds[0].desc);
@@ -430,7 +433,7 @@ static void quiesce_rx(struct adapter *adap, struct sge_rspq *q)
 	}
 }
 
-void enable_rx_uld(struct adapter *adap, unsigned int uld_type)
+static void enable_rx_uld(struct adapter *adap, unsigned int uld_type)
 {
 	struct sge_uld_rxq_info *rxq_info = adap->sge.uld_rxq_info[uld_type];
 	int idx;
@@ -439,7 +442,7 @@ void enable_rx_uld(struct adapter *adap, unsigned int uld_type)
 		enable_rx(adap, &rxq_info->uldrxq[idx].rspq);
 }
 
-void quiesce_rx_uld(struct adapter *adap, unsigned int uld_type)
+static void quiesce_rx_uld(struct adapter *adap, unsigned int uld_type)
 {
 	struct sge_uld_rxq_info *rxq_info = adap->sge.uld_rxq_info[uld_type];
 	int idx;
-- 
2.7.4
