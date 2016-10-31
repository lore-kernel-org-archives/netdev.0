From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 11/14] nfp: use unsigned int for vector/ring counts
Date: Mon, 31 Oct 2016 20:43:19 +0000
Message-ID: <1477946602-19644-12-git-send-email-jakub.kicinski@netronome.com>
References: <1477946602-19644-1-git-send-email-jakub.kicinski@netronome.com>
Cc: Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:38404 "EHLO
        mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1034089AbcJaUoJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Oct 2016 16:44:09 -0400
Received: by mail-wm0-f49.google.com with SMTP id n67so251681114wme.1
        for <netdev@vger.kernel.org>; Mon, 31 Oct 2016 13:44:08 -0700 (PDT)
In-Reply-To: <1477946602-19644-1-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use unsigned int consistently for vector/ring counts.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net.h        | 17 +++++++++--------
 drivers/net/ethernet/netronome/nfp/nfp_net_common.c |  5 +++--
 2 files changed, 12 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net.h b/drivers/net/ethernet/netronome/nfp/nfp_net.h
index 55a497c02237..0ea6ebd329cf 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net.h
@@ -528,11 +528,11 @@ struct nfp_net {
 	struct timer_list rx_filter_stats_timer;
 	spinlock_t rx_filter_lock;
 
-	int max_tx_rings;
-	int max_rx_rings;
+	unsigned int max_tx_rings;
+	unsigned int max_rx_rings;
 
-	int num_tx_rings;
-	int num_rx_rings;
+	unsigned int num_tx_rings;
+	unsigned int num_rx_rings;
 
 	int stride_tx;
 	int stride_rx;
@@ -540,8 +540,8 @@ struct nfp_net {
 	int txd_cnt;
 	int rxd_cnt;
 
-	u8 num_irqs;
-	u8 num_r_vecs;
+	unsigned int num_irqs;
+	unsigned int num_r_vecs;
 	struct nfp_net_r_vector r_vecs[NFP_NET_MAX_R_VECS];
 	struct msix_entry irq_entries[NFP_NET_MAX_IRQS];
 
@@ -757,8 +757,9 @@ static inline u32 nfp_qcp_wr_ptr_read(u8 __iomem *q)
 void nfp_net_get_fw_version(struct nfp_net_fw_version *fw_ver,
 			    void __iomem *ctrl_bar);
 
-struct nfp_net *nfp_net_netdev_alloc(struct pci_dev *pdev,
-				     int max_tx_rings, int max_rx_rings);
+struct nfp_net *
+nfp_net_netdev_alloc(struct pci_dev *pdev,
+		     unsigned int max_tx_rings, unsigned int max_rx_rings);
 void nfp_net_netdev_free(struct nfp_net *nn);
 int nfp_net_netdev_init(struct net_device *netdev);
 void nfp_net_netdev_clean(struct net_device *netdev);
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index 7225ab61a120..49a1f54e0787 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -318,8 +318,8 @@ static int nfp_net_msix_alloc(struct nfp_net *nn, int nr_vecs)
  */
 static int nfp_net_irqs_wanted(struct nfp_net *nn)
 {
+	unsigned int vecs;
 	int ncpus;
-	int vecs;
 
 	ncpus = num_online_cpus();
 
@@ -2701,7 +2701,8 @@ void nfp_net_info(struct nfp_net *nn)
  * Return: NFP Net device structure, or ERR_PTR on error.
  */
 struct nfp_net *nfp_net_netdev_alloc(struct pci_dev *pdev,
-				     int max_tx_rings, int max_rx_rings)
+				     unsigned int max_tx_rings,
+				     unsigned int max_rx_rings)
 {
 	struct net_device *netdev;
 	struct nfp_net *nn;
-- 
1.9.1
