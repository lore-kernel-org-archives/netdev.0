From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 04/16] nfp: move nfp_net_vecs_init()
Date: Mon,  5 Jun 2017 17:01:45 -0700
Message-ID: <20170606000157.17556-5-jakub.kicinski@netronome.com>
References: <20170606000157.17556-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f51.google.com ([74.125.83.51]:33913 "EHLO
        mail-pg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751266AbdFFACS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Jun 2017 20:02:18 -0400
Received: by mail-pg0-f51.google.com with SMTP id v18so17453454pgb.1
        for <netdev@vger.kernel.org>; Mon, 05 Jun 2017 17:02:18 -0700 (PDT)
In-Reply-To: <20170606000157.17556-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move nfp_net_vecs_init() after all datapath functions.  We will need
to init poll() callbacks from this function soon.

No functional changes.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 .../net/ethernet/netronome/nfp/nfp_net_common.c    | 54 +++++++++++-----------
 1 file changed, 27 insertions(+), 27 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index 23419883cfd4..f8dba793a8fe 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -504,33 +504,6 @@ nfp_net_rx_ring_init(struct nfp_net_rx_ring *rx_ring,
 }
 
 /**
- * nfp_net_vecs_init() - Assign IRQs and setup rvecs.
- * @nn:		NFP Network structure
- */
-static void nfp_net_vecs_init(struct nfp_net *nn)
-{
-	struct nfp_net_r_vector *r_vec;
-	int r;
-
-	nn->lsc_handler = nfp_net_irq_lsc;
-	nn->exn_handler = nfp_net_irq_exn;
-
-	for (r = 0; r < nn->max_r_vecs; r++) {
-		struct msix_entry *entry;
-
-		entry = &nn->irq_entries[NFP_NET_NON_Q_VECTORS + r];
-
-		r_vec = &nn->r_vecs[r];
-		r_vec->nfp_net = nn;
-		r_vec->handler = nfp_net_irq_rxtx;
-		r_vec->irq_entry = entry->entry;
-		r_vec->irq_vector = entry->vector;
-
-		cpumask_set_cpu(r, &r_vec->affinity_mask);
-	}
-}
-
-/**
  * nfp_net_aux_irq_request() - Request an auxiliary interrupt (LSC or EXN)
  * @nn:		NFP Network structure
  * @ctrl_offset: Control BAR offset where IRQ configuration should be written
@@ -1773,6 +1746,33 @@ static int nfp_net_poll(struct napi_struct *napi, int budget)
  */
 
 /**
+ * nfp_net_vecs_init() - Assign IRQs and setup rvecs.
+ * @nn:		NFP Network structure
+ */
+static void nfp_net_vecs_init(struct nfp_net *nn)
+{
+	struct nfp_net_r_vector *r_vec;
+	int r;
+
+	nn->lsc_handler = nfp_net_irq_lsc;
+	nn->exn_handler = nfp_net_irq_exn;
+
+	for (r = 0; r < nn->max_r_vecs; r++) {
+		struct msix_entry *entry;
+
+		entry = &nn->irq_entries[NFP_NET_NON_Q_VECTORS + r];
+
+		r_vec = &nn->r_vecs[r];
+		r_vec->nfp_net = nn;
+		r_vec->handler = nfp_net_irq_rxtx;
+		r_vec->irq_entry = entry->entry;
+		r_vec->irq_vector = entry->vector;
+
+		cpumask_set_cpu(r, &r_vec->affinity_mask);
+	}
+}
+
+/**
  * nfp_net_tx_ring_free() - Free resources allocated to a TX ring
  * @tx_ring:   TX ring to free
  */
-- 
2.11.0
